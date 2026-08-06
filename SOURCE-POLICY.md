# Source material policy

Rules for third-party material a project captures: research downloads, prior art,
quoted documentation, saved articles, cloned repos, vendored code.

This is a **version control** policy, not a research policy. It governs one question:
*what may enter this repository's history.* Reading, saving, and annotating sources
locally is unconstrained. Committing them is not.

> Not legal advice. This encodes defaults that keep a public repo out of obvious
> trouble; it is US-centric and deliberately conservative. A source important enough
> that the project fails without it is a source worth getting permission for.

## The two rules everything else follows from

**1. Attribution is not permission.** Crediting an author cures plagiarism. It does
nothing for copyright, which governs the exclusive rights to reproduce and distribute
([17 U.S.C. § 106](https://www.law.cornell.edu/uscode/text/17/106)). A perfectly cited
full-text copy is still a reproduction, and pushing it is still a distribution. "I'm
citing it, not claiming it" is the most common way this goes wrong.

**2. The commit is the publication event.** Not the push, not the repo going public —
the commit, because history is what gets pushed later and history is expensive to
rewrite. Treat every commit as already public.

Under [Jujutsu](https://jj-vcs.github.io/jj/) rule 2 is sharper than it sounds: the
working copy is auto-snapshotted on every command, so a downloaded PDF sitting in the
tree is committed by the next `jj` command you run — before you have decided anything
about it. The ignore pattern has to exist *before* the file does. This is the same
asymmetry [README.md](./README.md) describes for generated files; copyright is the
case where getting it wrong costs more than a rebuild.

## What may be committed in full

| Category | Test | Notes |
| --- | --- | --- |
| US federal government works | Authored by a federal employee in the course of their duties | [17 U.S.C. § 105](https://www.law.cornell.edu/uscode/text/17/105) — no copyright at all. Does **not** extend to contractor-authored works, which are routinely copyrighted. |
| Public domain by age | Published 1930 or earlier (as of 2026; the window advances every 1 January) | US terms only. A work in the US public domain may still be protected elsewhere. |
| Government edicts | Statutes, regulations, judicial opinions, official annotations | *Georgia v. Public.Resource.Org* (2020). State works generally are **not** automatically public domain — only the edicts are. |
| Open-licensed | CC BY / BY-SA / BY-ND / CC0, or an OSI license on docs and code | Verbatim redistribution is exactly what these grant. Keep the attribution and license notice **with** the copy. |

Open-license wrinkles worth reading before relying on one:

- **BY-SA** carries share-alike obligations on adaptations. Filing a copy alongside your
  own work is usually mere aggregation; weaving it into your text may not be. If a
  BY-SA source is going to be integrated rather than filed, say so in its record.
- **BY-NC** is fine for a personal or research repo and a problem the moment the repo
  feeds commercial work. Flag it at capture time, not at launch time.
- **BY-ND** still permits verbatim redistribution — it bars derivatives, not copies.
- **CC0 / public-domain dedications** still deserve attribution as a matter of practice,
  just not as a matter of license.

## What may not

Everything else: blog posts, news articles, papers without an open license, vendor
documentation, Stack Overflow answers beyond the snippet, anything with no license
grant at all. Absence of a license means **all rights reserved**, not "unclear."

For these, the repo gets a **record**, not the work: citation, canonical URL, archive
link, access date, and your own excerpts and notes. Excerpting the passages you actually
engage with, surrounded by your commentary, is the core of what
[§ 107](https://www.law.cornell.edu/uscode/text/17/107) fair use protects. Wholesale
copies are not, and the "but it might disappear" rationale specifically is the argument
the Second Circuit rejected in [*Hachette Book Group v. Internet
Archive*](https://www.courtlistener.com/opinion/10104144/hachette-book-group-inc-v-internet-archive/)
(2d Cir. 2024) — preservation and access did not make full-text copying transformative.
A personal repo is a far smaller act than the Internet Archive's lending program, but
it would be leaning on the theory that just lost.

This is not a hardship. For a prior-art repo, an annotated excerpt is more useful than a
raw mirror — it is the part you actually reread.

## Where things live

The `_`-prefixed directories are the quarantine. Their nested `.gitignore` stubs
(`*` + `!.gitignore`) ignore all contents while keeping the directory itself trackable.

| Path | Tracked? | Holds |
| --- | --- | --- |
| `_inspiration/` | No | Full text of captured sources — PDFs, cloned repos, saved HTML. Local only. |
| `_docs/research/index/_per_source/` | No | Per-source working notes and summaries. |
| `docs/sources/` or `SOURCES.md` | **Yes** | Source records: citation, URL, archive link, access date, license status, excerpts. |

Two consequences to keep straight:

- A full-text copy under `_inspiration/` is a private copy on your own disk. That is
  low-risk regardless of license, and nothing in this policy discourages it.
- Nothing under `_inspiration/` can be referenced by tracked files as a *source of
  content* — a collaborator cloning the repo does not have it. Tracked prose must stand
  on its records and excerpts.

## Capture protocol

For each source, at capture time — not later, when the tab is closed and the license
footer is a memory:

1. **Determine status.** Public domain, open license (which one), or all rights
   reserved. Record the answer even when it is "unknown", which is treated as all
   rights reserved.
2. **Archive it.** Trigger a save at the [Wayback Machine](https://web.archive.org/) or
   archive.today and record the resulting snapshot URL. This is the answer to link rot
   and to silently edited pages: the archive hosts the copy, you cite a stable
   timestamped reference.
3. **Record the access date.** ISO 8601. What you read is what you cite.
4. **Save full text to `_inspiration/`** if you want it locally.
5. **Excerpt into the tracked record** — the passages you engage with, with your notes.
   If the excerpt could substitute for reading the original, it is too long.
6. **Hash it, if the source is load-bearing.** `shasum -a 256 <file>` and commit the
   digest in the record. Costs one line and later proves your local copy matches what
   existed on the access date.

### Record format

```markdown
## <Title>

- url: https://example.com/article
- archived: https://web.archive.org/web/20260101000000/https://example.com/article
- accessed: 2026-01-01
- license: all-rights-reserved   # or: CC-BY-4.0 | CC0 | public-domain-us-federal | MIT | unknown
- local: _inspiration/articles/example-article/   # optional; not tracked
- sha256: <digest>                                # optional; for load-bearing sources

> Excerpt of the passage that matters.

Why it matters here, what it changes, what it gets wrong.
```

`license: unknown` is a valid, honest value. It is handled as all-rights-reserved and
is a prompt to check before the repo goes public — not a blocker on capture.

## Automated downloading

Anything that fetches sources in bulk needs three things stated, because tooling in this
space generally does not do them for you:

- **robots.txt is usually not consulted.** Download scripts fetch what they are given.
  If a domain forbids crawling, that is on the operator to catch. Terms of service are a
  contract question independent of copyright — a permissively licensed work can still
  sit behind a ToS that forbids scraping it.
- **Rate limits are a courtesy that becomes a ban.** Per-domain throttling (arxiv.org
  asks 1 request per 3 seconds) is the difference between a tool and an incident.
- **Auth-gated and paywalled sources fail loudly, and that is correct.** A 401/403 is
  the system working. Do not add credential handling to make it go away; mark the entry
  skipped and cite it without the copy.

Output of these tools lands in `_inspiration/`, which is why the ignore stub ships in
the template rather than being added when the first download runs.

## If something already leaked into history

Ignoring it now does not remove it from earlier commits.

- **git**: add the pattern, `git rm --cached <path>`, then rewrite history with
  [`git filter-repo`](https://github.com/newren/git-filter-repo) if the commits were
  pushed. Force-push, and assume anyone who fetched still has it.
- **jj**: add the pattern to `.gitignore` *first*, then `jj file untrack <path>`. That
  removes it going forward; earlier commits need `jj squash`/rebase surgery. See
  [jj-vcs/jj#5225](https://github.com/jj-vcs/jj/issues/5225).

Both are unpleasant enough to justify the ignore-first discipline this template is
built around.

## Prior art (surveyed 2026-08-06)

Worth stating plainly, because it explains why this file exists rather than pointing at
someone else's convention: **the popular research-agent repos license their own code and
say nothing about the material they collect.**

| Repo | What it licenses | Source-capture policy |
| --- | --- | --- |
| [assafelovic/gpt-researcher](https://github.com/assafelovic/gpt-researcher) | Apache-2.0, plus an "as-is / not academic advice" disclaimer | None. Ships a scraper family (`gpt_researcher/scraper/`) with no robots.txt or ToS handling. |
| [stanford-oval/storm](https://github.com/stanford-oval/storm) | MIT | None as policy. Does credit its FreshWiki dataset as CC BY-SA — dataset-level attribution, not a rule for what the agent retrieves. |
| [langchain-ai/open_deep_research](https://github.com/langchain-ai/open_deep_research) | MIT | None. |
| [smorinlabs/doxa-research](https://github.com/smorinlabs/doxa-research) | AGPL-3.0 | None. The skill covers provider orchestration and output format only. |

So there is no convention to inherit. The gap is consistent enough to be worth naming:
these tools optimize for retrieval breadth, and the question of what may then be
*committed* falls outside their scope — it lands on whoever runs them. That is this
repository. A template whose stated purpose is deciding what enters history is the right
place to answer it, and answering it before the first `_inspiration/` download is the
only time the answer is cheap.

Retrieval tooling should be assumed to fetch whatever it is pointed at. Treat its output
as raw input to this policy, never as evidence that a source was safe to take.

## Non-US sources

Berne means no formalities: no notice, no registration, still protected. Terms vary —
life + 70 in the US and EU, life + 50 in much of the world, with country-specific
extensions. "Public domain in the US" is not "public domain." EU database rights and
national press-publisher rights protect collections that carry no US analogue. When a
source is foreign and load-bearing, treat status as unknown until checked.
