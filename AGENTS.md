# AGENTS.md

Operating instructions for agents (Claude Code, Codex, Gemini CLI, Cursor, etc.) in projects forked from this template. Claude Code agents will also read this as a fallback when no `CLAUDE.md` is present.

## Recommended plugins

Not installed by this template — plugins drift just like the gitignore entries do, and pinning a version in a starter repo guarantees staleness. The author commonly enables these per-project; install via your agent's plugin mechanism (e.g. Claude Code marketplace / `/plugin install`).

- **[Understand-Anything](https://github.com/Lum1104/Understand-Anything)** — produces an interactive knowledge graph + chat over the codebase. Useful for onboarding into an existing repo or generating architecture overviews from code-as-source-of-truth.
- **[compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin)** — the `/ce-*` family (planning, ideation, code review, sprint flow, learning capture). The author uses it as the default workflow scaffolding across most projects.

If a project depends on either of these (e.g. references `docs/solutions/` from compound-engineering, or expects `understand-anything/` artifacts to be ignored already), it should say so in its own `CLAUDE.md` rather than relying on this recommendation list.

## Third-party source material

Read **[SOURCE-POLICY.md](./SOURCE-POLICY.md)** before committing anything you did not
write (reasoning and case law live in [source-policy-notes](https://gist.github.com/alycda/5b357ba4a13e479a0d635d3c35ef6dbc), outside the repo) — downloaded papers, saved articles, cloned repos, quoted documentation, vendored
code. It is a version control rule, not a research rule: it governs what enters history,
not what you may read.

The three things that get this wrong most often:

1. **Attribution is not permission.** Citing an author cures plagiarism, not copyright.
   A correctly attributed full-text copy is still a reproduction, and committing it is
   still a distribution.
2. **No license means all rights reserved**, not "unclear, probably fine."
3. **The commit is the publication event** — under jj, the auto-snapshot makes that
   commit happen before you have decided anything. Ignore first, download second.

Operationally:

- **Only two paths are quarantined**: `_inspiration/` and
  `_docs/research/index/_per_source/`, each via a nested `.gitignore` stub. The `_`
  prefix is a naming convention, **not** an ignore rule — everything else under
  `_docs/` is tracked and will be pushed. Run `git check-ignore -v <path>` before
  writing a capture anywhere new; do not infer from the underscore.
- Point the fetch itself at the quarantine (`curl -o _inspiration/...`,
  `git clone <url> _inspiration/repos/<name>`). A bare `curl -O` from the repo root
  lands in a tracked path, and under jj the next command commits it.
- Tracked files get a **record**, not the work: citation, canonical URL, archive link,
  access date, SPDX license identifier, and your own excerpts. Records live in
  `SOURCES.md` at the repo root. Format in SOURCE-POLICY.md.
- Commit a source in full only when it is public domain or open-licensed, and record
  which, in the file itself, so the next reader knows why it is there. Check the site's
  terms of service for a *grant* before recording something as all-rights-reserved —
  Stack Exchange answers, for instance, are `CC-BY-SA-4.0`.
- Never cite `_inspiration/` or `_docs/research/index/_per_source/` from tracked prose.
  A collaborator cloning the repo has neither directory.
- Vendored **code** is the exception: it must be tracked to build, so it goes to
  `third_party/<name>/` with its LICENSE intact — never `_inspiration/`. Check copyleft
  (`GPL`/`AGPL`/`LGPL`/`MPL`) compatibility against the repo's own license first.

**Verify, don't recite.** `./scripts/check-sources.sh` asserts that the quarantine paths
are actually ignored and the tracked ones actually aren't. Run it after touching any
`.gitignore`, and after adding a capture directory. It exists because the prose version of
this claim was wrong once, and prose cannot check itself.

If you are adding tooling that downloads sources in bulk, the automated-downloading
section of SOURCE-POLICY.md is the checklist it has to satisfy.

## `.gitignore` structure

The `.gitignore` in this template is organized **top-to-bottom from most-likely-to-change to least-likely-to-change**, with explicit section headers. When you add a new ignore pattern, **find the section it belongs to and insert it there. Do NOT append blindly to the end of the file.**

Sections, top to bottom:

| Section | Volatility | Source |
| --- | --- | --- |
| Project-specific | High — edited often as the project evolves | Curated per project (no upstream) |
| Agents | Medium — re-sync occasionally | [github/gitignore Global/Agents.gitignore](https://github.com/github/gitignore/blob/main/Global/Agents.gitignore) |
| Agent plugins | Medium — plugin authors evolve their artifacts | Curated per-plugin; source URL noted inline (no aggregate upstream) |
| Shell | Low | Curated, no upstream |
| Editor | Low | [github/gitignore Global/VisualStudioCode.gitignore](https://github.com/github/gitignore/blob/main/Global/VisualStudioCode.gitignore) |
| Operating System (macOS) | Very low — re-sync rarely | [github/gitignore Global/macOS.gitignore](https://github.com/github/gitignore/blob/main/Global/macOS.gitignore) |

Each upstream-sourced section starts with a comment header recording the source URL and the last-sync date. Bump the sync date whenever you reconcile against upstream.

## Adding a new ignore pattern

1. Identify the category (project tooling? agent artifact? macOS thing?).
2. Locate the matching `# ====` section.
3. Insert the pattern under that section, preserving any sub-grouping comments.
4. If you add a pattern that doesn't match any existing section, create a new section header at the appropriate volatility level — not at the end.

## Adding a language (one-time, at project init)

This template ships with a self-destructing init skill at `.agents/skills/setup/`. Run it once after cloning the template; it splices language patterns from upstream and then removes itself.

```sh
./.agents/skills/setup/scripts/init-gitignore.sh                # list available upstream languages
./.agents/skills/setup/scripts/init-gitignore.sh rust c         # splice rust + c, then self-destruct
./.agents/skills/setup/scripts/init-gitignore.sh dart flutter   # Flutter app: pair dart with flutter
./.agents/skills/setup/scripts/init-gitignore.sh --sync         # refresh the upstream cache (no splice, no nuke)
```

Language names lowercase, title-cased to find the upstream filename (`rust` → `Rust.gitignore`); `cpp`/`c++` resolves to `C++.gitignore`. Patterns are pulled from `~/.cache/github-gitignore` (cloned on first use).

After it runs successfully, `.agents/skills/setup/` (and `.agents/` if empty) is removed. If you need to add language patterns later, edit `.gitignore` directly under the "Project-specific" section.

## Re-syncing an upstream section

```sh
# 1. Update the local mirror of github/gitignore (or clone if absent)
[ -d ~/.cache/github-gitignore/.git ] && git -C ~/.cache/github-gitignore pull --ff-only || gh repo clone github/gitignore ~/.cache/github-gitignore

# 2. Diff against the section in your project
diff ~/.cache/github-gitignore/Global/macOS.gitignore <(awk '/^# Operating System \(macOS\)/{f=1; next} f && /^# ====/{exit} f' .gitignore | sed '/^# /d;/^$/d')

# 3. Hand-merge any new patterns into the section (do not blow away local notes)
# 4. Bump the "Last sync" date in the section header
```

## Special-character warning (macOS section)

The macOS `.gitignore` contains literal `\r` (carriage return, 0x0D) characters on the `Icon\r` and `.HFS+ Private Directory Data\r` lines. These are real filenames macOS uses; the `\r` is part of the name.

**Web copy/paste destroys these characters.** `curl` of the raw URL also normalizes them. The only reliable way to bring them in is via `git clone` of the github/gitignore repo and `cat` (or another raw-byte tool) into place. Never paste this section from a browser.

To verify the CR survived in your local `.gitignore`:

```
grep -an '^Icon\|^\.HFS' .gitignore | cat -v
# Expect:
#   <line>:Icon[^M]
#   <line>:.HFS+ Private Directory Data[^M]
# where [^M] is cat -v's rendering of a literal \r
```

If you see `Icon` or `.HFS+ Private Directory Data` without the trailing `\r`, the macOS section is broken — those filenames will not match and the files will be tracked accidentally. Re-clone github/gitignore and reassemble.
