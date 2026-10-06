#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
for registry in legacy new; do npx cf workers delete "sourcemap-repro-$registry-registry"; done
