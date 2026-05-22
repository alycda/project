# project

A starting template. The only thing established here is **version control hygiene** 

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

### References

- [jj working copy & `.gitignore` semantics](https://docs.jj-vcs.dev/latest/working-copy/) — auto-snapshot behavior, why pattern-before-generation matters
- [jj-vcs/jj#5225](https://github.com/jj-vcs/jj/issues/5225) — `jj file untrack` requires the path to already be in `.gitignore`
- [github/gitignore](https://github.com/github/gitignore) — upstream source for the macOS, Agents, and VS Code sections of this template's `.gitignore`
