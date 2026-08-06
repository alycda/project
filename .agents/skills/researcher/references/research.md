# Research — fan-out

Produces `_docs/research/*.md`, one file per perspective. These are **quarantined**
(`_docs/research/.gitignore` ignores `/*.md`) because they quote sources at length.
What survives into history is `SOURCES.md`, built in `index.md`.

## Default: Claude, multi-perspective

Three parallel Agent sub-agents on the parent's model, each given a different angle so
they don't converge on the same first-page results:

| Worker | Angle | Output |
|---|---|---|
| theory | Papers, formal results, why-it-works. Prefers arXiv/DOI, accepts older canon. | `_docs/research/theory.md` |
| tooling | What exists and runs. Repos, docs, release health, maintenance signals. | `_docs/research/tooling.md` |
| industry | Who shipped this, what broke. Postmortems, engineering blogs, conference talks. | `_docs/research/industry.md` |

Perspective diversity is the point. One worker with three prompts finds the same
sources three times; three workers with different evidentiary standards don't.

Each worker returns a **Source ledger** — a flat, deduplicated list of every URL it
cites. `capture.md` reads that ledger first and only falls back to scraping prose.
Ask for it explicitly; workers omit it otherwise.

## Optional: hosted Deep Research

Browser Deep Research still outruns `WebSearch` + `WebFetch` on breadth-of-citations
work. It is a **fourth pass**, not a replacement — run it when the long tail matters
and skip it when it doesn't.

Paste the research question into Claude.ai Deep Research (and any other DR product you
use), save what comes back to `_docs/research/<name>-deep-research.md`, and continue to
`capture.md`. No template needed: DR products want a plain question, and the meta-prompt
that used to live here mostly told the agent things it already does.

One known failure mode worth pre-empting: **hosted DR occasionally invents plausible
arXiv IDs.** Don't try to catch these by reading. `download.md` will 404 on them, which
is the natural check. Flag any arXiv ID dated after the current month in `notes`.

## Optional: other providers

If you want genuine vendor diversity rather than perspective diversity, dispatch the
same question to any research CLI on `PATH` via Bash and save its output alongside the
Claude workers. The skill deliberately does **not** name or configure providers — that
list goes stale faster than anything else here, and a CLI you have already authenticated
needs no instructions from a skill file.

Two rules if you do:

- Run it because you want a *different corpus or a different bias*, not for more volume.
  Three workers agreeing is signal; six workers agreeing is the same signal, more slowly.
- Everything under **External dispatch** below applies.

## External dispatch — what may leave

Anything sent to a provider outside this session should be assumed to leave the
building permanently. Before dispatching, strip:

- **Internal ticket IDs** (Linear, Jira) → generic descriptions: "an SDK integration
  ticket", not `ABC-1234`
- **Incident IDs** → the technical phenomenon: "an oversized-transaction disconnect
  loop", not `i-604`
- **Customer names**, deployment specifics, and internal repo or crate paths
- **Unreleased product names** and internal codenames

Reference internal context *by shape*, never by identifier. It tells the model what
kind of evidence to look for without putting a ticket number into someone else's logs.

If the question cannot be asked without internal anchors, don't dispatch it externally.
Run the Claude-only default, which stays in-session.

## Verification

- One `_docs/research/*.md` per worker, each ending in a Source ledger
- `git check-ignore -v _docs/research/theory.md` returns a match — the reports are
  quarantined, not tracked
- Ledgers contain URLs, not paraphrased citations ("the Raft paper" is not a source)
