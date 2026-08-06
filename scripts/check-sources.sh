#!/usr/bin/env bash
# Assert that SOURCE-POLICY.md's factual claims about this repo are true.
#
# The policy's central claim is which paths are quarantined. That claim was wrong
# once already — it said every `_`-prefixed directory was ignored when only two
# carried stubs, which is the failure the policy exists to prevent, stated by the
# policy itself. A sentence in a markdown file cannot verify itself; this can.
#
# Run it in CI, or as a pre-commit hook. Exits non-zero on any mismatch.
#
#   ./scripts/check-sources.sh

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2

fail=0
pass() { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

# git check-ignore exits 0 when the path IS ignored, 1 when it is not.
is_ignored() { git check-ignore -q "$1"; }

want_ignored() {
  if is_ignored "$1"; then pass "ignored:     $1"
  else bad "expected IGNORED but tracked: $1${2:+  ($2)}"; fi
}
want_tracked() {
  if is_ignored "$1"; then bad "expected TRACKED but ignored: $1${2:+  ($2)}"
  else pass "tracked:     $1"; fi
}

echo "Quarantine (must be ignored — these hold other people's work):"
want_ignored "_inspiration/sample.pdf"                        "full-text captures"
want_ignored "_inspiration/repos/owner/repo/README.md"        "cloned repos"
want_ignored "_docs/research/index/_per_source/sample.md"     "per-source working notes"

echo
echo "Tracked (must NOT be ignored — these are your own work, or the record):"
want_tracked "SOURCES.md"                                     "the artifact the policy produces"
want_tracked "SOURCE-POLICY.md"
want_tracked "_docs/research/index/README.md"                 "the semantic index"
want_tracked "_docs/research/downloads.yaml"                  "the capture record"

echo
echo "The claim that bit us — the '_' prefix is NOT an ignore rule:"
want_tracked "_docs/notes.md"            "if this flips, the policy's wording is wrong"
want_tracked "_docs/research/scratch.md" "…and an agent will trust it and commit a PDF"

# Raw research reports are quarantined only in projects that ran the researcher
# skill, which writes _docs/research/.gitignore. Report, never fail, on a bare
# template — there is nothing to protect yet.
echo
echo "Research-report quarantine (present only after the researcher skill runs):"
if [ -f _docs/research/.gitignore ]; then
  want_ignored "_docs/research/claude-deep-research.md" "raw DR reports quote at length"
else
  printf '  \033[33mskip\033[0m _docs/research/.gitignore absent — skill has not run here\n'
fi

echo
echo "Pre-publication flag sweep:"
sweep=$(grep -rn -E 'noncommercial-only|sharealike-integrated|status-unverified' \
          SOURCES.md docs/sources/ 2>/dev/null)
if [ -n "$sweep" ]; then
  printf '  \033[33m%s\033[0m\n' "entries needing a decision before this repo goes public / commercial:"
  printf '%s\n' "$sweep" | sed 's/^/    /'
else
  pass "no flagged entries"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "FAILED — SOURCE-POLICY.md describes a repo layout that does not match reality."
  echo "Fix the .gitignore stubs, or fix the policy. Do not leave them disagreeing:"
  echo "an agent trusting the wrong one commits someone else's work."
  exit 1
fi
echo "All source-policy claims hold."
