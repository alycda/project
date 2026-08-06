# .claude/

Claude Code integration for this template.

## skills/ — a composition layer, not a mirror

Skills live in `.agents/skills/` so the directory stays vendor-neutral; Claude Code
only reads `.claude/skills/`. The bridge is **one symlink per skill**, not one symlink
for the whole directory:

```
.claude/skills/researcher -> ../../.agents/skills/researcher
.claude/skills/setup      -> ../../.agents/skills/setup
```

Per-skill links because a whole-directory symlink (`.claude/skills -> ../.agents/skills`)
makes `.claude/skills/` *be* `.agents/skills/` — a Claude-only skill would then have
nowhere to live. With per-skill links the directory can compose from more than one
source tree: shared skills as symlinks, Claude-specific skills as real directories
alongside them. (Layout after `joelhooks/aie-loopcraft-workshop-2026`, whose
`.claude/skills/` holds 36 per-skill symlinks over two source trees.)

The cost is one `ln -s` when a skill is added, and the failure mode is a visibly
missing skill rather than a silently wrong layout.

The `setup` link is removed by the skill's own self-destruct (`init-gitignore.sh`
cleans it up along with `.agents/skills/setup/`).

`settings.local.json` and `*.log` stay gitignored (see the Agents section of
`.gitignore`); the symlinks and this README are tracked.
