#!/usr/bin/env bash
# init-gitignore.sh — splice language-specific .gitignore patterns into
# .gitignore under the "Project-specific" section, then self-destruct.
#
# This script is intended to run ONCE at project-init time. After a
# successful splice, it removes itself and its containing skill directory
# (.agents/skills/setup) so the bootstrap surface area disappears.
#
# Usage (run from project root):
#   ./.agents/skills/setup/scripts/init-gitignore.sh                  List available upstream language files.
#   ./.agents/skills/setup/scripts/init-gitignore.sh <lang>...        Splice the named languages, then self-nuke.
#   ./.agents/skills/setup/scripts/init-gitignore.sh --sync           git pull the upstream cache (no nuke).
#
# Language names are mapped to github/gitignore filenames as:
#   <lang>                       -> capitalize first char + ".gitignore"
#   cpp, c++                     -> "C++.gitignore"
# Files are resolved from $CACHE root first, then $CACHE/Global/ (editor/IDE/OS
# patterns like JetBrains, VisualStudioCode, Vim, Linux, Windows, macOS).
# Resolution falls back to a case-insensitive match on both paths, so
# `jetbrains` finds `Global/JetBrains.gitignore`.
# Examples:
#   rust       -> Rust.gitignore
#   c          -> C.gitignore
#   cpp        -> C++.gitignore
#   dart       -> Dart.gitignore
#   flutter    -> Flutter.gitignore           (note: upstream is SDK-oriented; pair with dart for apps)
#   python     -> Python.gitignore
#   jetbrains  -> Global/JetBrains.gitignore  (pair with a language splice for IDE projects)
#
# Upstream is pulled from a local clone of github/gitignore at
# ~/.cache/github-gitignore (or $XDG_CACHE_HOME), cloned on first use.
# The cache survives self-destruct; only the in-repo skill goes.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # .agents/skills/setup
cd "$PROJECT_ROOT"

GITIGNORE=".gitignore"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/github-gitignore"

# --- helpers ----------------------------------------------------------

upstream_filename() {
  # Map a lowercased language name to the canonical github/gitignore filename.
  local lang="$1"
  case "$lang" in
    cpp|c++) echo "C++.gitignore" ;;
    *)
      local first=$(printf '%s' "${lang:0:1}" | tr '[:lower:]' '[:upper:]')
      echo "${first}${lang:1}.gitignore"
      ;;
  esac
}

ensure_cache() {
  if [[ ! -d "$CACHE/.git" ]]; then
    echo "Cloning github/gitignore to $CACHE (one-time)..." >&2
    mkdir -p "$(dirname "$CACHE")"
    gh repo clone github/gitignore "$CACHE" >&2
  fi
}

sync_cache() {
  ensure_cache
  echo "Updating $CACHE"
  git -C "$CACHE" pull --ff-only
}

list_languages() {
  ensure_cache
  echo "Available languages (use lowercase, e.g. 'rust', 'jetbrains'):"
  echo ""
  echo "Root (programming languages):"
  ls "$CACHE" | grep '\.gitignore$' | sed 's/\.gitignore$//' | sort | awk '{printf "  %s\n", tolower($0)}'
  echo ""
  echo "Global/ (editors, IDEs, OSes — typically paired with a root language):"
  ls "$CACHE/Global" 2>/dev/null | grep '\.gitignore$' | sed 's/\.gitignore$//' | sort | awk '{printf "  %s\n", tolower($0)}'
}

# Resolve an upstream filename (e.g. "Rust.gitignore", "JetBrains.gitignore")
# to a path relative to $CACHE. Tries: exact root, exact Global/, then
# case-insensitive fallback on both — which is how `jetbrains` finds the
# CamelCased `Global/JetBrains.gitignore` without callers having to know
# the upstream casing.
resolve_upstream() {
  local name="$1"
  [[ -f "$CACHE/$name" ]] && { echo "$name"; return 0; }
  [[ -f "$CACHE/Global/$name" ]] && { echo "Global/$name"; return 0; }
  local found
  found=$(find "$CACHE" -maxdepth 1 -type f -iname "$name" 2>/dev/null | head -1)
  [[ -n "$found" ]] && { basename "$found"; return 0; }
  found=$(find "$CACHE/Global" -maxdepth 1 -type f -iname "$name" 2>/dev/null | head -1)
  [[ -n "$found" ]] && { echo "Global/$(basename "$found")"; return 0; }
  return 1
}

splice_language() {
  local lang="$1"
  local upstream
  upstream=$(upstream_filename "$lang")
  ensure_cache
  local rel
  if ! rel=$(resolve_upstream "$upstream"); then
    echo "Error: $upstream not found in $CACHE (root or Global/); try ./init-gitignore.sh to list available" >&2
    return 1
  fi
  local src="$CACHE/$rel"
  local marker="# --- ${lang} ---"
  if grep -qF "$marker" "$GITIGNORE"; then
    echo "Skipping $lang (already spliced)"
    return 0
  fi
  # Find the "==" line that opens the Agents section (the line before "# Agents")
  local agents_line
  agents_line=$(grep -n '^# Agents$' "$GITIGNORE" | head -1 | cut -d: -f1)
  if [[ -z "$agents_line" ]]; then
    echo "Error: couldn't locate the Agents section boundary in $GITIGNORE" >&2
    return 1
  fi
  local insert_at=$((agents_line - 1))
  local today
  today=$(date +%Y-%m-%d)
  {
    head -n $((insert_at - 1)) "$GITIGNORE"
    echo ""
    echo "$marker"
    echo "# Source:    https://github.com/github/gitignore/blob/main/${rel}"
    echo "# Pulled:    ${today}"
    echo ""
    cat "$src"
    tail -n +$insert_at "$GITIGNORE"
  } > "${GITIGNORE}.new"
  mv "${GITIGNORE}.new" "$GITIGNORE"
  echo "Spliced $lang (from ${rel}) into $GITIGNORE"
}

self_destruct() {
  # Remove the entire setup skill and try to remove the .agents tree if empty.
  echo "Removing one-time bootstrap skill at $SKILL_DIR"
  rm -rf "$SKILL_DIR"
  rm -f "$PROJECT_ROOT/.claude/skills/setup"            # per-skill symlink, else it dangles
  rmdir "$(dirname "$SKILL_DIR")" 2>/dev/null || true   # .agents/skills if empty
  rmdir "$(dirname "$(dirname "$SKILL_DIR")")" 2>/dev/null || true  # .agents if empty
}

# --- entry point ------------------------------------------------------

case "${1:-}" in
  ""|--list|-l)
    list_languages
    exit 0
    ;;
  --sync)
    sync_cache
    exit 0
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
esac

# Splice all requested languages; only self-destruct if every splice succeeded.
ok=1
for lang in "$@"; do
  splice_language "$lang" || ok=0
done

if (( ok == 1 )); then
  self_destruct
else
  echo "One or more splices failed; leaving skill in place for retry." >&2
  exit 1
fi
