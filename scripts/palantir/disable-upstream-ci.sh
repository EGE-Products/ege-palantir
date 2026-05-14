#!/usr/bin/env bash
#
# disable-upstream-ci.sh — EGE-additive.
#
# Disables the inherited upstream-Prefect GitHub Actions workflows that can
# never pass (or must never pass) on the Palantír fork.
#
# WHY A SCRIPT INSTEAD OF EDITING/DELETING THE WORKFLOW FILES:
#   `gh workflow disable` stores the disabled state in GitHub's backend, NOT
#   in any file. The .yml files stay byte-identical to upstream, so weekly
#   upstream merges have ZERO conflict surface and cannot revert the disable.
#   This script is the version-controlled *record* of what we turned off and
#   why — but it operates on out-of-repo state.
#
# IDEMPOTENT: re-running is safe — workflows already disabled are detected
#   from the fetched state and skipped.
#
# FAIL-FAST: this script hardens a fork, so a silent false success is the
#   worst outcome. It aborts (non-zero exit) on:
#     - any auth/network/API error (caught by the single `gh workflow list`)
#     - any target that fails to disable while reported active
#     - any target "missing" from .github/workflows/ — an upstream rebase may
#       have RENAMED it, leaving the renamed release/publish workflow silently
#       ACTIVE. That must be reconciled by a human, not shrugged off.
#
# Requires: gh CLI authenticated against EGE-Products/ege-palantir.

set -euo pipefail

# Workflows that publish AS PrefectHQ (PyPI / npm / DockerHub / Helm) — must
# never pass on the fork; "passing" would ship Prefect releases under our name.
RELEASE_WORKFLOWS=(
  nightly-release.yaml
  kickoff-release.yaml
  prefect-client-publish.yaml
  integration-package-release.yaml
  helm-chart-release.yaml
  npm_update_latest_prefect.yaml
  docker-images.yaml
  prefect-aws-docker-images.yaml
  prefect-azure-docker-images.yaml
  prefect-gcp-docker-images.yaml
  sqlite-builder.yaml
  python-package.yaml
)

# Workflows that need cloud credentials / clusters the fork doesn't have.
INFRA_WORKFLOWS=(
  prefect-aws-docker-test.yaml
  prefect-azure-docker-test.yaml
  prefect-gcp-docker-test.yaml
  k8s-integration-tests.yaml
)

# Benchmarking workflows that need CodSpeed tokens / benchmarking infra.
BENCHMARK_WORKFLOWS=(
  benchmarks.yaml
  codspeed-benchmarks.yaml
  dbt-benchmarks.yaml
  time-docker-build.yaml
)

# Bot integrations that need PrefectHQ's API keys.
BOT_WORKFLOWS=(
  claude.yml
  devin-fix-flaky-tests.yaml
)

ALL=(
  "${RELEASE_WORKFLOWS[@]}"
  "${INFRA_WORKFLOWS[@]}"
  "${BENCHMARK_WORKFLOWS[@]}"
  "${BOT_WORKFLOWS[@]}"
)

# ── Fetch current state in ONE call ───────────────────────────────────────
# This is also the auth/network canary: if gh can't reach the API we find
# out HERE and abort, instead of silently "skipping" every target in the loop.
echo "Fetching current workflow state..."
if ! state_table="$(gh workflow list --all --json path,state \
      --jq '.[] | "\(.path)\t\(.state)"')"; then
  echo "ERROR: 'gh workflow list' failed — check 'gh auth status' and network." >&2
  exit 1
fi

disabled=0
already=0
missing=0
missing_names=()

for wf in "${ALL[@]}"; do
  # Resolve this workflow's state by matching its full path. The
  # ".github/workflows/" prefix + trailing tab anchor the match so a short
  # name (release.yaml) can't accidentally match a longer one
  # (nightly-release.yaml).
  line="$(grep -F ".github/workflows/${wf}"$'\t' <<<"$state_table" || true)"
  state="${line##*$'\t'}"

  if [[ -z "$state" ]]; then
    echo "  MISSING:  $wf — not found in .github/workflows/" >&2
    missing=$((missing + 1))
    missing_names+=("$wf")
    continue
  fi

  if [[ "$state" == disabled_* ]]; then
    echo "  already:  $wf"
    already=$((already + 1))
    continue
  fi

  # state == "active" — disable it. A non-zero here is a REAL failure
  # (auth lost mid-run, API error); do NOT swallow it.
  if ! gh workflow disable "$wf"; then
    echo "ERROR: failed to disable active workflow '$wf'." >&2
    echo "       Re-run after resolving — already-disabled targets are skipped." >&2
    exit 1
  fi
  echo "  disabled: $wf"
  disabled=$((disabled + 1))
done

echo
echo "Summary: ${disabled} newly disabled, ${already} already disabled, ${missing} missing."

if (( missing > 0 )); then
  {
    echo
    echo "ERROR: ${missing} target(s) not found in .github/workflows/:"
    printf '  - %s\n' "${missing_names[@]}"
    echo
    echo "An upstream rebase likely RENAMED them — the renamed release/publish"
    echo "workflow could now be silently ACTIVE. Reconcile this script's lists"
    echo "against the current tree, then re-run. Current workflow files:"
    echo "  ls .github/workflows/*.y*ml | xargs -n1 basename | sort"
  } >&2
  exit 1
fi

echo "All ${#ALL[@]} target workflows are disabled."
