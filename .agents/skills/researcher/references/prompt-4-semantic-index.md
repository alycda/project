# Step 4 — Semantic Index

Builds `_docs/research/index/` from `_inspiration/`.

## The Original Prompt (subject to user modifications)

> Construct a semantic index of our research materials. The _inspiration/ directory contains all known prior art for our project; however, the token volume is very large. Construct _docs/research/index/ as a semantic index: topics, citations, cross-references, bookmarks, tags, clusters, themes — anything which will aid a future coding agent in quickly locating the most dense and useful aspects of our prior art materials. Be sure to use sub-agents for each project — think MapReduce.

## Procedure

### 4.1 — Map: Per-Source Sub-Agents

Spawn one sub-agent per top-level item in `_inspiration/` (each repo, each paper, each article). Each sub-agent reads its assigned material and produces a structured summary at `_docs/research/index/_per_source/<source-id>.md` containing:

- Provenance header — `url`, `license`, `accessed`, `archived` copied from that source's `downloads.yaml` entry. One line, first thing in the file, so no summary is ever separated from the terms it was made under.
- 3-sentence elevator summary
- Tags (free-form, lowercase, hyphenated, ≤10)
- Topics covered (numbered list)
- Key citations (with page/line refs where available)
- Cross-references to other sources (by source-id) when explicit
- "Density" score 1–5 (5 = read this first; 1 = barely relevant)
- "What we'd take from this for our project" — 1–3 bullets

**Write summaries, not transcriptions.** The per-source file is a *literature note*: the idea restated in your own words with the reference attached. That is what makes it useful later — an extract you did not process is an extract you cannot use — and it is also what keeps it publishable. Quote only what you are actually commenting on. If a summary could substitute for reading the source, it stopped being a summary.

### 4.2 — Reduce: Cross-Source Aggregation

Once all per-source summaries exist, run aggregation (single sub-agent or inline) to produce:

| File | Contents |
|---|---|
| `_docs/research/index/by-topic.md` | Topics → list of sources covering them, sorted by density |
| `_docs/research/index/by-tag.md` | Tags → list of sources |
| `_docs/research/index/clusters.md` | Thematic clusters (e.g., "ABI diffing tools", "WASM browser test runners", "CRDT theory papers") |
| `_docs/research/index/top-N.md` | Top 10–20 must-read sources by density (deduplicated, ranked) |
| `_docs/research/index/cross-references.md` | Graph-shaped: source A cites source B with `<context>` |
| `_docs/research/index/open-questions.md` | Things prior art doesn't answer; gaps where the project will have to invent |
| `_docs/research/index/README.md` | Entry point for downstream agents; explains the index structure |

### 4.3 — Surface Open Questions

Aggregate "things the prior art doesn't answer" across all sources. Write `_docs/research/index/open-questions.md`.

### 4.4 — Emit `SOURCES.md`

Project root, tracked. This is the artifact that survives the quarantine: `_inspiration/` and `_per_source/` are both gitignored, so a collaborator who clones the repo gets neither. Without this step the entire research trail is invisible to everyone but the machine that ran it.

Generate one record per `status: done` entry in `downloads.yaml`, in the format `SOURCE-POLICY.md` specifies:

```markdown
## <title>

- url: <url>
- archived: <archived>
- accessed: <accessed>
- license: <license>
- flags: <flags>
- local: <path>          # not tracked — for the person who ran the pipeline
- sha256: <sha256>       # load-bearing sources only

> One excerpt worth commenting on.

Two sentences on why it matters here.
```

Two rules that make this step worth doing rather than ceremony:

- **`SOURCES.md` must stand alone.** It may not reference `_inspiration/` or `_per_source/` as a source of content, because a collaborator has neither. The `local:` field is a convenience for whoever ran the pipeline, not a citation.
- **Surface anything that needs a decision before publication.** End the file with a short section listing every entry carrying `noncommercial-only`, `sharealike-integrated`, or `status-unverified`. That list is the pre-publication checklist; it should be a `rg` away, not a re-read.

If `SOURCES.md` already exists, upsert by `url` and preserve hand-written excerpts and commentary — those are the parts a human added and the parts worth keeping.

## Inputs

- `_inspiration/` (everything)
- `_docs/research/<researcher-id>.md` (for high-level Top N hints from researchers)
- `_docs/research/downloads.yaml` (for source-id → path mapping)

## Output

```
_docs/research/index/
├── README.md                 # entry point
├── by-topic.md
├── by-tag.md
├── clusters.md
├── top-N.md
├── cross-references.md
├── open-questions.md
└── _per_source/
    ├── <source-id>.md
    └── ...
```

## Verification

- One `_per_source/<id>.md` per top-level item in `_inspiration/`, each opening with its provenance header
- `top-N.md` lists at least 10 sources with density scores
- `clusters.md` covers all sources (no "uncategorized" stragglers)
- `README.md` orients a downstream agent that has zero prior context
- `SOURCES.md` exists at the project root, has a record per `status: done` entry, and is **tracked** — confirm with `git check-ignore -v SOURCES.md` returning nothing
- No tracked file cites `_inspiration/` or `_per_source/` as a source of content — `rg -n '_inspiration/|_per_source/' SOURCES.md` should only match `local:` lines

## Pitfalls

- **Skipping the Reduce phase.** Per-source summaries alone are not an index — they're a flat directory. Cross-source aggregation is where the value comes from.
- **Token explosion in Reduce.** Don't read all per-source files into a single context. Pyramid Summary: read elevator summaries + tags + density scores; expand specific sources only when needed.
- **Density score inflation.** If every source scores 4–5, the score is useless. Force a distribution (e.g., max 20% can be 5).
- **Hallucinated cross-references.** Agents will invent citations between papers that don't actually cite each other. Verify against actual content.
- **Stale index after re-runs.** If new researchers stream in (and prompts 2–3 download new materials), the index needs to be regenerated. Use the `--rebuild` flag. Don't try to incrementally patch.
- **MapReduce parallelism.** Map phase is embarrassingly parallel; spawn one sub-agent per source. Reduce phase is serial by necessity. Don't try to parallelize Reduce.
