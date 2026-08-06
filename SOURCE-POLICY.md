# Source material policy

Rules for third-party material a project captures: research downloads, prior art,
quoted documentation, saved articles, cloned repos, vendored code.

A **version control** policy, governing one question: *what may enter this repository's
history.* Reading, saving, and annotating sources locally is unconstrained. Committing
them is not.

The model is the Zettelkasten. What goes in the box is a note in your own words with
the reference attached — not the source. Hand-copying used to be expensive enough to
enforce that by itself; copy-paste removed the cost and the thinking step with it. The
two pressures happily agree: **record-not-the-work is the literature note**, so the
safe move and the useful move are the same move.

> **Reasoning lives outside this file**, in
> [source-policy-notes](https://gist.github.com/alycda/5b357ba4a13e479a0d635d3c35ef6dbc)
> — case law, fair-use limits, public-domain traps, license wrinkles, and the
> Zettelkasten argument in full. Split because they rot at different rates: these rules
> follow from a mechanical fact about `.gitignore` ordering and don't change, while the
> reasoning is US law as of 2026-08-06 and a fork can't update a copy. Read the notes
> when a call is close. Not legal advice; conservative and US-centric.

Verify, don't recite: `./scripts/check-sources.sh`.

This repo takes its own medicine: it is [MIT](./LICENSE) licensed, `SPDX-License-Identifier: MIT`,
so a fork inherits an explicit grant rather than the all-rights-reserved default this
policy warns about. A policy telling you to record license status, in a repo with no
license, would be the exact defect it teaches you to spot. `check-sources.sh` asserts
the LICENSE is still there.

## The two rules everything else follows from

**1. Attribution is not permission.** Crediting an author cures plagiarism. It does
nothing for copyright, which governs the rights to reproduce and distribute
([17 U.S.C. § 106](https://www.law.cornell.edu/uscode/text/17/106)). A perfectly cited
full-text copy is still a reproduction; pushing it is still a distribution.

**2. Treat the commit as the publication event.** Legally the distribution happens at
the push. Operationally the commit is the point of no return, because history is what
gets pushed later and history is expensive to rewrite.

Under [Jujutsu](https://jj-vcs.github.io/jj/) rule 2 is sharper than it sounds: the
working copy auto-snapshots on every command, so a downloaded PDF is committed by the
next `jj` command — before you have decided anything. The ignore pattern must exist
*before* the file does. Same asymmetry [README.md](./README.md) describes for generated
files; here getting it wrong costs more than a rebuild.

## Where things live

Two directories carry a nested `.gitignore` stub. **Those two paths are the quarantine
— the `_` prefix is a naming convention, not an ignore rule.** Everything else under
`docs/` is tracked and will be pushed.

| Path | Tracked? | Holds |
| --- | --- | --- |
| `_inspiration/` | No — stubbed | Full text of captured sources |
| `docs/research/index/_per_source/` | No — stubbed | Per-source working notes |
| `docs/**` (everything else) | **Yes** | ⚠️ Putting captured full text here commits it |
| `SOURCES.md` (repo root) | **Yes** | Source records — what this policy produces |
| `third_party/<name>/` | **Yes** | Vendored code that must build; LICENSE intact |

- A full-text copy under `_inspiration/` is a private copy on your disk. Low-risk
  regardless of license; nothing here discourages it.
- **Nothing under either quarantine path may be cited by tracked files as a source of
  content** — a collaborator cloning the repo has neither directory.
- Vendored *code* is the exception: it must be tracked to build, so it goes to
  `third_party/<name>/` with its LICENSE intact, and its record notes the SPDX id.
  Check copyleft (GPL/AGPL/LGPL/MPL) compatibility against your own license first.

## What may be committed in full

| Category | Test |
| --- | --- |
| US federal government works | Authored by a federal **employee** on duty ([§ 105](https://www.law.cornell.edu/uscode/text/17/105)). Not contractors. A `.gov` domain is not evidence. |
| Public domain by age | US works **published more than 95 years ago** — compute it, don't read a year off this page. Excludes sound recordings and unpublished works. |
| Government edicts | Authored by a **judge or legislature** in official capacity. Not privately drafted standards incorporated into regulation. |
| Open-licensed | `CC-BY`, `CC-BY-SA`, `CC-BY-ND`, `CC0`, OSI licenses — plus `CC-BY-NC` for non-commercial repos only. Keep the license notice with the copy. |

Check the site's **terms of service for a grant** before defaulting to
all-rights-reserved — Stack Exchange answers are `CC-BY-SA-4.0`, not unlicensed. The
[notes](https://gist.github.com/alycda/5b357ba4a13e479a0d635d3c35ef6dbc) cover the
traps in every row above; read them before relying on one.

## What may not

Everything else: blog posts, news articles, papers without an open license, vendor
docs. **Absence of a license means all rights reserved**, not "unclear."

These get a **record**, not the work. Excerpt what you actually engage with, with your
commentary. Two limits: if the excerpt could substitute for reading the original it is
too long, *and* taking the qualitative heart of a work can fail at a few hundred words
— shorten or paraphrase when a source is unpublished or the passage is its central
claim. Fair use is a fact-specific defense, not a permission.

Both limits are per-excerpt, and **short works need a third: a running budget.** When
the whole work is a few hundred words, a quarter of it can be assembled one
individually-defensible excerpt at a time across different files. Track the total in
the source's record — count distinct words of the source quoted anywhere in tracked
files (re-quoting an already-tracked line adds nothing) — and judge the next excerpt
against that denominator, not in isolation. A fourth quote from a 230-word work is a
different act from a first.

## Source records

`SOURCES.md` at the repo root. Past ~30 entries, split into `docs/sources/<slug>.md`
(one per file) and reduce `SOURCES.md` to an index. (`docs/`, not `docs/` — records
are tracked by design.) One store, one format.

```markdown
## <Title>

- url: https://example.com/article
- archived: https://web.archive.org/web/20260101000000/https://example.com/article
- accessed: 2026-01-01
- license: LicenseRef-all-rights-reserved   # SPDX id
- flags: none            # noncommercial-only | sharealike-integrated | status-unverified
- local: _inspiration/articles/example-article/   # optional; not tracked
- sha256: <digest>                                # load-bearing sources only

> The excerpt worth arguing with.

What it changes for us, and where it is wrong.
```

Use [SPDX identifiers](https://spdx.org/licenses/) for `license:`, plus
`LicenseRef-all-rights-reserved` and `LicenseRef-unknown` for the two cases SPDX has no
id for. SPDX because it is what [REUSE](https://reuse.software/) and every license
scanner already validate against — this is a thin wrapper over existing conventions,
not a new standard. `LicenseRef-unknown` is honest, handled as all-rights-reserved, and
never a blocker on capture.

**Load-bearing** means: if the source turned out to say something different, a decision
in this repo would change. Those get `sha256:`.

Before publishing or any commercial use:

```sh
rg -n 'noncommercial-only|sharealike-integrated|status-unverified' SOURCES.md docs/sources/
```

## Capture protocol

At capture time — not later, when the tab is closed and the license footer is a memory:

1. **Determine status.** PD, open license (which SPDX id), or all rights reserved.
   Check ToS for a grant first. Record `LicenseRef-unknown` rather than guessing.
2. **Archive it.** Check for an existing snapshot first —
   `https://archive.org/wayback/available?url=<url>` — before attempting a save. An
   old capture satisfies this step, and the availability query is one request; a save
   is rate-limited and can 429 for days while a usable snapshot sits there the whole
   time. If none exists, save via `https://web.archive.org/save/<url>` (archive.today
   is manual-only, CAPTCHA-gated). The two ways to end up without a snapshot are
   different records — never omit the field:
   - `archived: none  # no snapshot exists (checked YYYY-MM-DD)` — availability
     checked and save failed. A finding.
   - `archived: none  # save failed YYYY-MM-DD, <reason>; availability not checked` —
     a retry hint, not a conclusion.
   Archiving relocates the copy to a third party rather than eliminating it.
3. **Record the access date.** ISO 8601.
4. **Fetch into the quarantine, never the repo root.** The command itself must target
   it: `curl -o _inspiration/<slug>/<file>`, `git clone <url> _inspiration/repos/<name>`.
   A bare `curl -O` lands in a tracked path and jj commits it on the next command.
   Required for load-bearing sources (step 6 hashes this copy).
5. **Excerpt into the record**, within the limits above — including the running
   budget for short works.
6. **Hash load-bearing sources.** `shasum -a 256 <file>`. Proves your copy is unchanged
   since you hashed it; the archive snapshot carries the third-party timestamp.

## Automated downloading

Retrieval tooling is what fills `_inspiration/`, and it does none of this for you:

- **robots.txt is usually not consulted.** ToS is a contract question independent of
  copyright — a permissively licensed work can still sit behind a ToS forbidding
  scraping.
- **Rate limits are a courtesy that becomes a ban.** arxiv.org asks 1 request / 3s.
- **401/403 is the system working.** Mark it skipped and cite without the copy; don't
  add credential handling to defeat it.

Tool output is raw input to this policy, never evidence a source was safe to take.

## If something already leaked into history

Ignoring it now does not remove it from earlier commits.

- **git**: add the pattern, `git rm --cached <path>`, then
  [`git filter-repo`](https://github.com/newren/git-filter-repo) if already pushed.
  Force-push, and assume anyone who fetched still has it.
- **jj**: add the pattern to `.gitignore` *first*, then `jj file untrack <path>`.
  Earlier commits need `jj squash`/rebase surgery — see
  [jj-vcs/jj#5225](https://github.com/jj-vcs/jj/issues/5225).

Both are unpleasant enough to justify the ignore-first discipline.
