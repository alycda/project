---
name: setup
description: >
  One-time project-init skill. Splices language-specific `.gitignore` patterns
  from `github/gitignore` into this project's `.gitignore` under "Project-specific",
  then **removes itself**. Use this exactly once after creating a new project from
  the `alycda/project` template. After it runs, the `.agents/skills/setup/`
  directory should no longer exist — if you (an agent) see it still present after
  a project has clearly moved past bootstrap, treat it as a leftover and either
  re-run it or remove it manually. Triggers on phrases like "set up gitignore",
  "init this project", "splice rust", or any direct invocation of
  `./.agents/skills/setup/scripts/init-gitignore.sh`.
---

# setup

One-time bootstrap skill for projects forked from `alycda/project`.

## What it does

Pulls language-specific patterns from a local mirror of [github/gitignore](https://github.com/github/gitignore) (`~/.cache/github-gitignore`, cloned on first use) and splices them into this project's `.gitignore` under the "Project-specific" section. After every requested language splices successfully, the script removes its own containing skill directory.

The cache survives — it's shared across all projects on this machine.

## Invocation (from project root)

```sh
# List what's available in upstream
./.agents/skills/setup/scripts/init-gitignore.sh

# Splice one or more languages, then self-destruct
./.agents/skills/setup/scripts/init-gitignore.sh rust c

# Just refresh the upstream cache (no splice, no nuke)
./.agents/skills/setup/scripts/init-gitignore.sh --sync
```

Language names are lowercase. The script title-cases them to find the upstream filename (`rust` → `Rust.gitignore`), with one special case: `cpp` and `c++` both resolve to `C++.gitignore`. Languages that don't title-case obviously (e.g. `python`, `kotlin`, `swift`) just work.

## After successful splice

`.agents/skills/setup/` is removed. If `.agents/skills/` and `.agents/` become empty, they're removed too. The project is left with:

- `.gitignore` containing the spliced sections with `# Source:` and `# Pulled:` headers
- No `setup.sh`, no `gitignore.d/`, no skill — the bootstrap surface area is gone

## Notes

- **Flutter:** the upstream `Flutter.gitignore` is oriented toward the Flutter SDK source tree, not app projects. It still works for apps — the SDK-specific paths (`/bin/cache/`, `/dev/`, `/packages/flutter/`) just won't match anything. For best results, run `./init-gitignore.sh dart flutter` and hand-trim the SDK paths after if they bother you.
- **macOS section preservation:** the script uses raw `head`/`tail`/`cat` only. The literal `\r` characters in the `Icon\r` and `.HFS+ Private Directory Data\r` lines of the macOS section are not touched.
- **Re-running after self-destruct:** by design, you can't. If you need to splice more languages after the skill is gone, either (a) hand-add the patterns to `.gitignore` directly, or (b) re-clone the template and merge the splice manually.

## For agents

If you're an agent reading this in a project where setup already happened (no `.agents/skills/setup/` directory visible), do not recreate this skill. The patterns it would add are already in `.gitignore`. If new language patterns are needed, edit `.gitignore` directly under the "Project-specific" section (see project root `AGENTS.md` for structure rules).

If you're an agent reading this in a freshly-templated project (this skill is present), you may run the script on the user's behalf when they ask to "set up gitignore for X" or similar. Confirm the language list before running, since the script will self-destruct after.
