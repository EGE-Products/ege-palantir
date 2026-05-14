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
# IDEMPOTENT: re-running is safe. Run it again after any upstream rebase that
# introduces new workflows (see the "audit" hint at the bottom).
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

echo "Disabling ${#ALL[@]} inherited upstream workflows..."
for wf in "${ALL[@]}"; do
  if gh workflow disable "$wf" 2>/dev/null; then
    echo "  disabled: $wf"
  else
    # Already disabled, or the file no longer exists after an upstream rebase.
    echo "  skipped:  $wf (already disabled or not found)"
  fi
done

echo
echo "Done. To see the full current state:    gh workflow list --all"
echo "After an upstream rebase, audit for new workflows:"
echo "  comm -13 <(printf '%s\\n' \"\${ALL[@]}\" | sort) \\"
echo "           <(ls .github/workflows/*.y*ml | xargs -n1 basename | sort)"
