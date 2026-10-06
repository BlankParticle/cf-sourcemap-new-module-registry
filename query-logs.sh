#!/usr/bin/env bash
# Pull the latest exception stack for each Worker from Workers Logs via cf.
set -euo pipefail
cd "$(dirname "$0")"
now=$(date +%s%3N); from=$((now - 30 * 60 * 1000))
for registry in legacy new; do
  body=$(mktemp)
  cat > "$body" <<EOF
{"queryId":"sourcemap-repro","view":"events","limit":5,"timeframe":{"from":$from,"to":$now},
 "parameters":{"filters":[{"key":"\$workers.scriptName","operation":"eq","type":"string","value":"sourcemap-repro-$registry-registry"}]}}
EOF
  echo "=== $registry registry"
  npx cf observability telemetry query --body "@$body" \
    | node -e '
      let s = ""; process.stdin.on("data", (d) => (s += d)).on("end", () => {
        const stacks = new Set();
        JSON.stringify(JSON.parse(s), (k, v) => {
          if (k === "stack" && typeof v === "string") stacks.add(v);
          return v;
        });
        console.log(stacks.size ? [...stacks][0] : "(no exception stack found yet; Workers Logs can lag ~1 min)");
      });'
  rm -f "$body"
done
