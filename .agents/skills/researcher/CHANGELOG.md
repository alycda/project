# Changelog

All notable changes to the `researcher` skill.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] — 2026-08-06


### Added
- **`/researcher cite <url>`** — the one-off path, which is the most common real use and
  previously did not exist. Resolve license, archive, append a `SOURCES.md` record.
  Nobody should invoke a five-step pipeline to cite one link.
- Source-ledger requirement stated explicitly for research workers; capture reads the
  ledger first and only falls back to scraping prose.

### Changed
- **Fan-out no longer names providers.** Was two hardcoded CLIs (`codex`, `gemini`) plus
  101 lines of install instructions for them. Now: the Claude multi-perspective default,
  and "dispatch to any research CLI on `PATH`" for vendor diversity. A provider list is
  the fastest-rotting thing in a skill file, and a CLI you have already authenticated
  needs no setup guide from a skill.
- **Hosted Deep Research is optional, not required**, and no longer ships a prompt
  template. DR products want a plain question; the meta-prompt mostly told the agent
  things it already does.
- Prompt files renamed to what they do — `prompt-1.5-execute-research` → `research`,
  `prompt-2-download-manifest` → `capture`, `prompt-3-download` → `download`,
  `prompt-4-semantic-index` → `index`. Step numbers encoded an order that no longer
  holds now that every entry point runs independently.

### Removed
- **Seed and research-brief generation** — `prompt-0-seed`, `prompt-1-research-brief`,
  `seed-skeleton`, `exemplar-seed`, `exemplar-research-brief`. Superseded in practice by
  compound-engineering's `/ce-brainstorm` and `/ce-plan`, which do the same job better
  and are already in the workflow. Recoverable from git history if that changes.
- **`cli-setup.md`** — install and auth instructions for two specific vendor CLIs.
- **`strongdm-{principles,techniques,products}.md`** — cached summaries of the Software
  Factory framing. The pattern is absorbed where it applies; the cached pages were an
  external dependency with no license grant, re-fetched on `--refresh`.
- **`templates/web-prompt.md`** — see hosted DR above.

### Kept deliberately
- **The full index tree** — `by-topic`, `by-tag`, `clusters`, `top-N`,
  `cross-references`, `open-questions`. Cross-source aggregation is where a pile of
  summaries becomes navigable; per-source files alone are just a flat directory.
- **`SOURCES.md`** — the tracked citation record, and the only research artifact a
  collaborator who clones the repo actually receives.
- **The external-dispatch sanitization rules**, folded into `research.md`. The brief
  step that used to carry them is gone, but the rules are why internal ticket IDs and
  incident IDs don't end up in a third party's logs — worth ~15 lines even with the
  default staying in-session.

