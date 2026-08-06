---
name: researcher
description: Collect prior art and cite it properly. Fans out parallel research workers, captures each source with its license, archive snapshot, and access date, downloads material into a gitignored quarantine, and builds a semantic index plus a tracked SOURCES.md. Also handles the one-off case — "add a citation for this URL" — without running the pipeline. Trigger on "prior art", "research this", "cite this", "add a citation", "collect sources", "what's been written about", or a request to bootstrap a project's research trail. Do NOT use for a single factual lookup that needs no record.
version: 1.0.0
metadata:
  tags: [research, citation, prior-art, provenance, sources]
  category: research
---

# Researcher

**The point is citations that hold up.** Everything else is in service of that.

A source you captured six months ago is worth nothing if you can't say where it came
from, whether you were allowed to quote it, or what it said before the page changed.
So provenance is captured at fetch time — the only moment it is cheap — and the thing
that survives into version control is a record, not a mirror.

Third-party text stays quarantined. Your own work on it gets tracked. That split is
both the copyright rule and the note-taking rule; see `SOURCE-POLICY.md` at the project
root for why they're the same rule.

## Entry points

| Command | Does |
|---|---|
| `/researcher cite <url>` | **The common case.** One source: resolve license, archive it, append a `SOURCES.md` record. No pipeline. |
| `/researcher research <question>` | Fan out parallel workers → `_docs/research/*.md` |
| `/researcher collect` | Build the manifest, then download → `_inspiration/` |
| `/researcher index` | Semantic index + `SOURCES.md` (`--rebuild` to regenerate) |
| `/researcher <question>` | All four, in order |

Run them independently. Sources arrive over weeks; every step is idempotent-upsert, so
re-running after new material lands is normal and cheap.

## `cite` — the fast path

Most citation work is one URL, not a research project. Do not spin up the pipeline for it.

1. Resolve the license — SPDX identifier, or `LicenseRef-all-rights-reserved` /
   `LicenseRef-unknown`. Check the site's terms for a *grant* before defaulting;
   Stack Exchange answers are `CC-BY-SA-4.0`, not unlicensed. See the heuristics table
   in `capture.md`.
2. Archive it: `https://web.archive.org/save/<url>`. Record the snapshot URL, or
   `none  # save failed <date>, <reason>`.
3. Append a record to `SOURCES.md` in the format `index.md` specifies — url, archived,
   accessed, license, flags, plus the excerpt you actually care about and why.

That's the whole path. Fetching the full text is optional and goes to `_inspiration/`
if you do it.

## Pipeline

### 1 — Research

`references/research.md`. Three parallel Claude workers with different evidentiary
angles (theory / tooling / industry), each returning a Source ledger. Optional hosted
Deep Research pass for breadth; optional dispatch to any research CLI on `PATH` if you
want vendor diversity rather than perspective diversity.

Outputs land in `_docs/research/*.md` and are **quarantined** — they quote at length.

### 2 — Capture

`references/capture.md`. A Haiku sub-agent reads the ledgers and builds
`_docs/research/downloads.yaml`: dedupe, normalize, classify by `kind`, and record
`license` / `flags` per entry.

Licensing is captured here or not at all. Recovering it for 200 URLs a week later means
reopening 200 tabs.

### 3 — Download

`references/download.md`. `scripts/download.py` fetches every `pending` entry into
`_inspiration/`. Mechanical — no LLM dispatch. Handles rate limits, retries, atomic
yaml updates, and creates the two gitignore stubs.

```bash
python3 "$PROJECT_ROOT/.agents/skills/researcher/scripts/download.py" --project-root "$PROJECT_ROOT" --workers 5
```

A successful download is not permission to commit. `status: done` means the bytes are
on disk; `license` decides what may enter history.

### 4 — Index

`references/index.md`. MapReduce sub-agents summarize each source, then aggregate into
`by-topic`, `by-tag`, `clusters`, `top-N`, `cross-references`, and `open-questions` —
plus `SOURCES.md` at the project root, which is the only part a collaborator receives.

## Layout

```
.
├── SOURCES.md                      # [TRACKED] the citation record
├── _inspiration/                   # [ignored] sources in full
└── _docs/research/
    ├── .gitignore                  # `/*.md` + `!/.gitignore`
    ├── theory.md · tooling.md · …  # [ignored] raw reports, quote-dense
    ├── downloads.yaml              # [TRACKED] capture record
    └── index/                      # [TRACKED] your summaries
        └── _per_source/            # [ignored] working notes
```

Verify with `git check-ignore -v <path>`. The `_` prefix is a naming convention, **not**
an ignore rule — only paths carrying a stub are ignored.

## Pitfalls

- **The `_` prefix is not an ignore rule.** `_docs/research/index/` and
  `downloads.yaml` are tracked *by design*. Anything else dropped under `_docs/` is
  tracked too, including a PDF saved there by mistake.
- **Licensing is captured at step 2 or not at all.** `LicenseRef-unknown` is an honest
  answer and costs nothing. A confident guess costs later.
- **`SOURCES.md` is the only research artifact a collaborator receives.** `_inspiration/`
  and `_per_source/` are both ignored. Skip step 4 and the trail is invisible to
  everyone but the machine that ran it.
- **Don't read all of `_inspiration/` into one context.** MapReduce sub-agents are
  mandatory at step 4; serial reads will OOM.
- **Density-score inflation.** If every source scores 4–5 the score is useless. Force a
  distribution — max 20% can be a 5.
- **Hallucinated cross-references.** Workers invent citations between papers that don't
  cite each other. Verify against actual content before it lands in the index.
- **Fan-out is for diversity, not volume.** Three workers agreeing is signal; six
  workers agreeing is the same signal, slower and more expensive.
- **Anything dispatched outside this session leaves permanently.** Strip ticket IDs,
  incident IDs, customer names, and internal paths first — see `research.md`.

## Related

- `SOURCE-POLICY.md` (project root) — what may enter history, and why
- [SPDX identifiers](https://spdx.org/licenses/) · [REUSE](https://reuse.software/) —
  the conventions `downloads.yaml` and `SOURCES.md` wrap
