# Source material policy

Rules for third-party material a project captures: research downloads, prior art,
quoted documentation, saved articles, cloned repos, vendored code.

This is a **version control** policy. It governs one question: *what may enter this
repository's history.* Reading, saving, and annotating sources locally is
unconstrained. Committing them is not.

Shipping this in the template is a deliberate widening of what the template is
opinionated about — it was gitignore mechanics, and now it is also copyright risk on
captured material. That is a decision, not drift: the two are the same discipline
(get the ignore rule right *before* the file exists), and only one of them costs
someone else's rights when you get it wrong. A fork that never captures third-party
material can ignore this file entirely; nothing else depends on it.

## The friction that used to do this work

The underlying model here is the Zettelkasten — Luhmann's slip-box, as popularized by
Ahrens's *How to Take Smart Notes*. What went into the box was never the source. It
was a card: the idea in your own words, with the reference attached, linked to other
cards. The full text stayed on the shelf.

That was not a rule anyone had to enforce. **Copying a text by hand was expensive
enough that nobody did it by accident**, and the expense was doing useful work —
transcription forced you to decide what mattered and restate it, which is the step
that makes a note usable later. Copy-paste removed the cost and the step with it. You
can now capture a thousand sources and understand none of them.

So the discipline has to be reimposed deliberately, and this is the happy case where
the two pressures agree: **the record-not-the-work rule is the literature note, and
excerpt-with-commentary is elaboration.** Doing the legally safe thing and doing the
epistemically useful thing are the same move. Nothing below asks you to trade rigor
for caution — a repo full of verbatim mirrors is worse notes *and* worse exposure.

> **Not legal advice.** Defaults that keep a public repo out of obvious trouble,
> deliberately conservative. **Legal claims stated as of 2026-08-06** and not
> self-updating — a fork carrying this file in 2030 is carrying 2026 statements of
> law. Both the rules *and the reader* are assumed US-based; see
> [Non-US sources and non-US forkers](#non-us-sources-and-non-us-forkers) before
> applying the public-domain or excerpting rules anywhere else. A source important
> enough that the project fails without it is a source worth getting permission for.

## The two rules everything else follows from

**1. Attribution is not permission.** Crediting an author cures plagiarism. It does
nothing for copyright, which governs the exclusive rights to reproduce and distribute
([17 U.S.C. § 106](https://www.law.cornell.edu/uscode/text/17/106)). A perfectly cited
full-text copy is still a reproduction, and pushing it is still a distribution. "I'm
citing it, not claiming it" is the most common way this goes wrong.

**2. Treat the commit as the publication event.** Legally the distribution happens at
the push — a local commit is a reproduction, not a publication. Operationally the
commit is the point of no return, because history is what gets pushed later and
history is expensive to rewrite. Decide at commit time, not at push time.

Under [Jujutsu](https://jj-vcs.github.io/jj/) rule 2 is sharper than it sounds: the
working copy is auto-snapshotted on every command, so a downloaded PDF sitting in the
tree is committed by the next `jj` command you run — before you have decided anything
about it. The ignore pattern has to exist *before* the file does. This is the same
asymmetry [README.md](./README.md) describes for generated files; copyright is the
case where getting it wrong costs more than a rebuild.

---

# Operating rules

Everything from here to "Why these rules" is what you actually do. The legal
reasoning behind it comes after, for when a call is close.

## Where things live

Two directories carry a nested `.gitignore` stub (`*` + `!.gitignore`) that ignores
their contents while keeping the directory itself trackable. **Those two paths are
the quarantine — the `_` prefix is a naming convention, not an ignore rule.** Every
other path under `_docs/` is tracked and will be pushed.

| Path | Tracked? | Holds |
| --- | --- | --- |
| `_inspiration/` | No — stubbed | Full text of captured sources: PDFs, cloned repos, saved HTML |
| `_docs/research/index/_per_source/` | No — stubbed | Per-source working notes and summaries |
| `_docs/**` (everything else) | **Yes** | ⚠️ Tracked. Putting captured full text here commits it. |
| `SOURCES.md` (repo root) | **Yes** | Source records — the tracked artifact this policy produces |
| `third_party/<name>/` | **Yes** | Vendored code that must build; LICENSE file kept intact |

Verify rather than assume — `git check-ignore -v <path>` before writing a capture
anywhere new.

Three consequences to keep straight:

- A full-text copy under `_inspiration/` is a private copy on your own disk. That is
  low-risk regardless of license, and nothing here discourages it.
- **Nothing under `_inspiration/` or `_docs/research/index/_per_source/` may be cited
  by tracked files as a source of content** — a collaborator cloning the repo has
  neither directory. Tracked prose must stand on its records and excerpts.
- Vendored *code* is the exception to the quarantine: it has to be tracked to build.
  It goes to `third_party/<name>/` with its LICENSE file intact, never to
  `_inspiration/`, and its record notes the SPDX identifier.

### Source records

Records live in `SOURCES.md` at the repo root. Once it passes roughly 30 entries,
split it into `docs/sources/<slug>.md` — one record per file — and reduce `SOURCES.md`
to an index of links. One store, one format; two agents capturing into the same repo
must not build two.

```markdown
## <Title>

- url: https://example.com/article
- archived: https://web.archive.org/web/20260101000000/https://example.com/article
- accessed: 2026-01-01
- license: LicenseRef-all-rights-reserved   # SPDX identifier; see below
- flags: none            # or: noncommercial-only | sharealike-integrated | status-unverified
- local: _inspiration/articles/example-article/   # optional; not tracked
- sha256: <digest>                                # required for load-bearing sources

> Excerpt of the passage that matters.

Why it matters here, what it changes, what it gets wrong.
```

Use **[SPDX license identifiers](https://spdx.org/licenses/)** for `license:` —
`CC-BY-4.0`, `CC-BY-SA-4.0`, `CC-BY-NC-4.0`, `CC0-1.0`, `MIT`, `Apache-2.0`,
`GPL-3.0-or-later`. For the two cases SPDX has no identifier for, use
`LicenseRef-all-rights-reserved` and `LicenseRef-unknown`. SPDX rather than ad-hoc
words because it is the vocabulary [REUSE](https://reuse.software/) and every license
scanner already validate against — this format is deliberately a thin markdown
wrapper over conventions that have tooling, not a new standard.

`LicenseRef-unknown` is a valid, honest value. It is handled as all-rights-reserved
and is a prompt to check before the repo goes public — not a blocker on capture.

`flags:` exists so the pre-launch sweep is a grep, not a re-read: `noncommercial-only`
for BY-NC, `sharealike-integrated` for a BY-SA source woven into your own prose,
`status-unverified` when you recorded a license you did not confirm at the source.

## What may be committed in full

| Category | Test | Notes |
| --- | --- | --- |
| US federal government works | Authored by a **federal employee** in the course of their duties | [17 U.S.C. § 105](https://www.law.cornell.edu/uscode/text/17/105) — no copyright at all. Does **not** extend to contractor-authored works. § 105 bars *originally federal* authorship only — the government can hold copyrights assigned to it. A `.gov` domain is not evidence of federal authorship. |
| Public domain by age | **Textual/visual works published in the US** 1930 or earlier (as of 2026; the window advances every 1 January) | Excludes **sound recordings** — pre-1972 recordings run 95 years plus a transition period under the Music Modernization Act, so a 1930 recording is protected until 2031. Excludes **unpublished** works (letters, manuscripts, archival photos) — those run life+70, or 120 years from creation, regardless of age. New editions, translations, and restorations carry their own fresh copyright. |
| Government edicts | Authored by a **judge or legislature acting in official capacity** — statutes, judicial opinions, legislature-authored annotations | *Georgia v. Public.Resource.Org* (2020). The doctrine turns on **who authored** the text, not on whether it has legal force. Privately authored standards incorporated by reference into regulation (building codes, ASTM/NFPA) remain copyrighted — *ASTM v. Public.Resource.Org* (D.C. Cir. 2023) resolved public access on fair use, not on loss of copyright. Treat non-federal agency regulations as unresolved. |
| Open-licensed | `CC-BY`, `CC-BY-SA`, `CC-BY-ND`, `CC0`, or an OSI license — plus `CC-BY-NC` **for non-commercial repos only** | Verbatim redistribution is what these grant. Keep the attribution and license notice **with** the copy. Read the wrinkles below before relying on one. |

Open-license wrinkles worth reading before relying on one:

- **Site terms of service can be the license grant.** Stack Exchange contributions are
  `CC-BY-SA-4.0` (3.0 before 2018), so Stack Overflow answers are open-licensed, not
  all-rights-reserved. Many wikis and dataset portals are the same. Check the ToS for
  a *grant* before recording a source as all-rights-reserved — ToS cuts both ways, and
  this policy treats it as a restriction elsewhere only because that is the more common
  case, not the only one.
- **BY-SA** attaches share-alike only to *Adapted Material*. Filing an unmodified copy
  alongside your own work produces a *Collection*, which does not trigger it; weaving
  the text into your own prose likely produces Adapted Material, which does. (Those are
  the CC 4.0 terms — "mere aggregation" is GPL vocabulary and will not be found in the
  CC deed you open to check.) Flag integration as `sharealike-integrated`.
- **Copyleft code licenses** (`GPL`, `AGPL`, `LGPL`, `MPL`) are the code-side of
  share-alike and stricter than BY-SA. Vendoring copyleft source can impose obligations
  on the combined work and may be incompatible with the repo's own license. Keep it in
  `third_party/<name>/` with its LICENSE intact, record the SPDX identifier, and check
  compatibility against your own license *before* committing. AGPL's § 13 network
  clause reaches anything you expose as a service.
- **BY-NC** is fine for a personal or research repo and a problem the moment the repo
  feeds commercial work. Flag it `noncommercial-only` at capture time, not at launch.
- **BY-ND** still permits verbatim redistribution — it bars derivatives, not copies.
- **CC0 / public-domain dedications** still deserve attribution as practice, just not
  as license.

## What may not

Everything else: blog posts, news articles, papers without an open license, vendor
documentation, anything with no license grant at all. Absence of a license means
**all rights reserved**, not "unclear."

For these, the repo gets a **record**, not the work. Excerpting the passages you
actually engage with, surrounded by your commentary, sits squarely within the purposes
[§ 107](https://www.law.cornell.edu/uscode/text/17/107) enumerates — criticism,
comment, scholarship, research. But § 107 is a fact-specific four-factor *defense*
asserted after suit, not a permission granted in advance, so a favorable purpose is a
starting position and not a safe harbor.

Two limits on excerpt length, not one:

- If the excerpt could substitute for reading the original, it is too long.
- Quantity is not the only limit. Taking the qualitative *heart* of a work can fail at
  a few hundred words — *Harper & Row v. Nation Enterprises* (1985) found ~300 words
  from a 200,000-word memoir infringing — and excerpting an **unpublished** source
  weighs against you. When a source is unpublished or the passage is its central claim,
  shorten it or paraphrase.

## Capture protocol

For each source, at capture time — not later, when the tab is closed and the license
footer is a memory:

1. **Determine status.** Public domain, open license (which SPDX identifier), or all
   rights reserved. Check the ToS for a grant before defaulting. Record the answer even
   when it is `LicenseRef-unknown`, which is treated as all rights reserved.
2. **Archive it.** `https://web.archive.org/save/<url>` — archive.today is a
   manual-only fallback (CAPTCHA-gated, not automatable). Record the snapshot URL. If
   no snapshot can be obtained, the record carries
   `archived: none  # save failed YYYY-MM-DD, <reason>` rather than omitting the field.
   Note this relocates the full-text copy to a third party rather than eliminating it;
   it is the right operational move, not a legal transformation.
3. **Record the access date.** ISO 8601. What you read is what you cite.
4. **Fetch into the quarantine, never the repo root.** The fetch command itself must
   target it — `curl -o _inspiration/<slug>/<file>`,
   `git clone <url> _inspiration/repos/<name>`. A bare `curl -O` from the repo root
   writes to a tracked path, and under jj the next command commits it; treat that as
   already committed and handle it per
   [If something already leaked](#if-something-already-leaked-into-history). Required
   for load-bearing sources (step 6 hashes this copy), optional otherwise.
5. **Excerpt into the record** — the passages you engage with, with your notes, within
   both limits above.
6. **Hash load-bearing sources.** `shasum -a 256 <file>`, digest into the record. This
   proves your copy is unchanged since you hashed it; the *archive snapshot* is what
   carries third-party timestamp evidence. Dynamic pages will not reproduce their hash
   on re-fetch.

## Automated downloading

Scoped deliberately: this section is about retrieval conduct rather than commit
history, and it earns its place because retrieval tooling is what fills
`_inspiration/`, and because none of it does these three things for you.

- **robots.txt is usually not consulted.** Download scripts fetch what they are given.
  If a domain forbids crawling, that is on the operator to catch. Terms of service are
  a contract question independent of copyright — a permissively licensed work can still
  sit behind a ToS that forbids scraping it.
- **Rate limits are a courtesy that becomes a ban.** Per-domain throttling (arxiv.org
  asks 1 request per 3 seconds) is the difference between a tool and an incident.
- **Auth-gated and paywalled sources fail loudly, and that is correct.** A 401/403 is
  the system working. Do not add credential handling to make it go away; mark the entry
  skipped and cite it without the copy.

Treat tool output as raw input to this policy, never as evidence a source was safe to
take.

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

---

# Why these rules

## What the "keep a copy in case it disappears" instinct runs into

It is weaker than it feels. In [*Hachette Book Group v. Internet
Archive*](https://www.courtlistener.com/opinion/10104144/hachette-book-group-inc-v-internet-archive/)
(2d Cir. 2024) the court held that medium-shifting a full text for the same reading
purpose is not transformative, and that public redistribution substituting for the
licensed market defeats fair use.

The detail that matters here: the Second Circuit found the Internet Archive's use
**non-commercial**, reversing the district court on that point — and IA still lost. So
"it's only a personal repo" is not the shield it sounds like; commerciality and scale
were not the deciding axis. What distinguishes this policy is narrower and more
durable: **a tracked full-text copy is redistribution; a private copy on your own disk
is not.** That is the whole reason the quarantine directories exist.

(The case concerned a lending program, not preservation copying — § 108 library
preservation was never reached.)

## Prior art

The convention this format wraps already exists; what does not exist is a convention
for *research-capture* tooling.

**The class that commits third-party material has mature, machine-checkable
conventions**, and this policy borrows rather than invents:

| Convention | Solves | Adopted here? |
| --- | --- | --- |
| [SPDX identifiers](https://spdx.org/licenses/) | Naming a license unambiguously | **Yes** — the `license:` field |
| [REUSE Specification](https://reuse.software/) | Per-file license declaration, with a linter | Compatible by design; adopt `reuse lint` if the repo grows into it |
| Debian `debian/copyright` | Machine-readable per-source copyright for a whole package | Format is heavier than a template needs; the per-source-record idea is taken from it |
| `third_party/` + `THIRD_PARTY_NOTICES` | Vendored code with obligations intact | **Yes** — the `third_party/<name>/` row |

**The research-agent tools, by contrast, have nothing to inherit — structurally.**
Surveyed 2026-08-06: [gpt-researcher](https://github.com/assafelovic/gpt-researcher)
(Apache-2.0), [STORM](https://github.com/stanford-oval/storm) (MIT),
[open_deep_research](https://github.com/langchain-ai/open_deep_research) (MIT),
[doxa-research](https://github.com/smorinlabs/doxa-research) (AGPL-3.0). Every one
licenses its own code and says nothing about the material it collects — because they
are retrieval libraries that hand you results and never commit them. The question of
what may then be *committed* falls outside their scope and lands on whoever runs them.
That is this repository.

## Non-US sources and non-US forkers

**Non-US sources.** Berne means no formalities: no notice, no registration, still
protected. Terms vary — life + 70 in the US and EU, life + 50 in much of the world,
with country-specific extensions. "Public domain in the US" is not "public domain." EU
database rights and national press-publisher rights protect collections that carry no
US analogue. When a source is foreign and load-bearing, treat status as unknown until
checked.

**Non-US forkers.** This policy assumes a US-based *operator* as well as US sources.
If your jurisdiction is not the US, two rules do not transfer:

- The **publication-date public domain table** — most jurisdictions compute terms from
  the author's death, not publication, so "published 1930 or earlier" clears nothing.
- The **excerpt-with-commentary allowance** — civil-law systems grant enumerated
  quotation rights rather than a general fair-use test, and they are narrower and
  condition the quote on serving a purpose in an independent work (Germany's § 51 UrhG
  *Zitatrecht*, for example).

Substitute your jurisdiction's equivalents in those two places before relying on the
rest.
