#!/usr/bin/env bash
# Point the chezmoi source repository at its versioned git hooks (.githooks/).
# Runs once per machine via chezmoi; safe to re-run.
set -euo pipefail

# chezmoi exports CHEZMOI_SOURCE_DIR to scripts; avoid calling chezmoi recursively.
source_dir="${CHEZMOI_SOURCE_DIR:?CHEZMOI_SOURCE_DIR is not set; run via chezmoi apply}"
git -C "$source_dir" config core.hooksPath .githooks
echo "> core.hooksPath set to .githooks in $source_dir"
