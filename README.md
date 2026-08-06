# project

A starting template. What's established here is **version control hygiene** — what belongs
in history, and what must be ignored before it ever gets there. That covers generated
files (the `.gitignore` below) and source material you didn't write
([SOURCE-POLICY.md](./SOURCE-POLICY.md)). Both are the same rule with different stakes.

```sh
./scripts/check-sources.sh   # asserts the policy's claims about this repo are true
```

## Version control

### `.gitignore` structure

Sections are ordered top-to-bottom from most-likely-to-change (project-specific) to least-likely-to-change (operating system). Each upstream-sourced section carries its source URL and a `Last sync` date so drift against upstream is easy to spot.

If you're a human reader: just open `.gitignore` and you'll see the headers. If you're an agent editing this file, read **[AGENTS.md](./AGENTS.md)** first — it tells you to find the section and insert there, not blindly append, and it covers the special-character gotcha in the macOS section (the `Icon\r` line has a literal carriage return that web copy/paste destroys).

### Language-specific patterns (one-time)

A self-destructing init skill at `.agents/skills/setup/` handles language splicing at project bootstrap. Run it once, pass the language(s) you want, and it removes itself.

```sh
./.agents/skills/setup/scripts/init-gitignore.sh                # list available
./.agents/skills/setup/scripts/init-gitignore.sh rust c         # splice rust + c, then nuke
./.agents/skills/setup/scripts/init-gitignore.sh dart flutter   # Flutter app (pair dart + flutter)
./.agents/skills/setup/scripts/init-gitignore.sh --sync         # refresh upstream cache (no nuke)
```

Patterns are pulled fresh from a local clone of [github/gitignore](https://github.com/github/gitignore) (`~/.cache/github-gitignore`, cloned on first use). After a successful splice, `.agents/skills/setup/` (and `.agents/` if empty) is removed — the bootstrap surface area disappears once you've used it. If you need more language patterns later, edit `.gitignore` directly under the "Project-specific" section.

This sidesteps the branch-per-language explosion (rust × c, flutter × c, …) by composing additively at project-init time, using raw `head`/`tail`/`cat` operations so the macOS section's `\r` characters survive every splice.

### Why `.gitignore` discipline matters more under Jujutsu

There's no guarantee a project forked from this template uses [Jujutsu](https://jj-vcs.github.io/jj/) (jj) for version control, but it's worth knowing the asymmetry:

- **Under git**, `.gitignore` controls what `git add` picks up. Forgetting to ignore a generated file is recoverable — you notice during `git status` and add the pattern.
- **Under jj**, the working copy is auto-snapshotted on every command. A generated file in the tree is committed the next time any jj command runs. Once it's in a commit, the only way to truly untrack it is to add the pattern to `.gitignore` *and then* run `jj file untrack` — and even then it can persist in earlier commits, requiring history rewrites to fully remove.

So whether you adopt jj or not, having the `.gitignore` right *before* you start generating files is the cheapest intervention by orders of magnitude.

### Source material you didn't write

The same discipline, applied to the other thing that lands in a project tree uninvited: papers, saved articles, cloned repos, prior art. **[SOURCE-POLICY.md](./SOURCE-POLICY.md)** has the rules; the short version is that citing a source is not the same as being allowed to redistribute it.

The model is the Zettelkasten: what goes in the box is a note in your own words with the reference attached, not the source. Hand-copying used to be expensive enough to enforce that by itself — copy-paste removed the cost and the thinking step along with it. The legally safe move and the better-notes move turn out to be the same one.

So this template ships two directories that are ignored before anything has been put in them:

| Path | Holds |
| --- | --- |
| `_inspiration/` | Full text of captured sources — local only, never pushed |
| `_docs/research/index/_per_source/` | Per-source working notes |

Each carries a nested `.gitignore` stub (`*` + `!.gitignore`) that ignores the contents while keeping the directory trackable. **Those two paths are the quarantine — the `_` prefix is a naming convention, not an ignore rule**, so everything else under `_docs/` is tracked. Tracked files get a *record* of a source — citation, archive link, access date, SPDX license identifier, your excerpts — rather than the source itself, unless it's public domain or open-licensed.

Both directories are inert if you never capture third-party material; a fork that has no research workflow can delete them and ignore the policy.

The ordering is the whole point, and it's the jj asymmetry above with sharper consequences: a downloaded PDF in the tree is committed by the next `jj` command you run, before you've decided anything about it.

### References

- [jj working copy & `.gitignore` semantics](https://docs.jj-vcs.dev/latest/working-copy/) — auto-snapshot behavior, why pattern-before-generation matters
- [jj-vcs/jj#5225](https://github.com/jj-vcs/jj/issues/5225) — `jj file untrack` requires the path to already be in `.gitignore`
- [github/gitignore](https://github.com/github/gitignore) — upstream source for the macOS, Agents, and VS Code sections of this template's `.gitignore`
- [source-policy-notes](https://gist.github.com/alycda/5b357ba4a13e479a0d635d3c35ef6dbc) — the reasoning behind SOURCE-POLICY.md: *Hachette*, fair-use limits, public-domain traps, license wrinkles, and the Zettelkasten argument in full. Kept outside the repo because case law dates and a fork can't update a copy.
- [SPDX license identifiers](https://spdx.org/licenses/) and the [REUSE Specification](https://reuse.software/) — the existing conventions `SOURCES.md` records wrap, rather than reinventing
- Sönke Ahrens, *How to Take Smart Notes* — the slip-box argument that elaboration, not collection, is where notes become useful
