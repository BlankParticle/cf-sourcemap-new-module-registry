#!/usr/bin/env bash
# Real-time tail is where Cloudflare applies uploaded source maps. cf has no
# Workers tail command yet, so this uses `wrangler tail` as the observer only.
set -euo pipefail
cd "$(dirname "$0")"
subdomain=${WORKERS_SUBDOMAIN:?set WORKERS_SUBDOMAIN to your <name>.workers.dev account subdomain}
for registry in legacy new; do
  (timeout 60 npx wrangler tail "sourcemap-repro-$registry-registry" --format json > "/tmp/tail-$registry.json" 2>/dev/null &)
done
for i in $(seq 1 25); do
  for registry in legacy new; do
    curl -s -o /dev/null "https://sourcemap-repro-$registry-registry.$subdomain.workers.dev/?cb=$i$RANDOM"
  done
  [ "$(grep -l '"stack"' /tmp/tail-legacy.json /tmp/tail-new.json 2>/dev/null | wc -l)" -eq 2 ] && break
  sleep 2
done
for registry in legacy new; do
  echo "=== $registry registry"
  node -e '
    const t = require("fs").readFileSync(process.argv[1], "utf8");
    const m = t.match(/"stack": "([^"]*)"/);
    console.log(m ? JSON.parse(`"${m[1]}"`) : "(no exception received)");' "/tmp/tail-$registry.json"
done
