# Source maps are not applied under `new_module_registry`

Same code, same uploaded `index.js.map`, same compatibility date. The only
difference between the two Workers is `compatibility_flags: ["new_module_registry"]`.

## Run

```sh
npm install            # or vp install
export CLOUDFLARE_API_TOKEN=... CLOUDFLARE_ACCOUNT_ID=...

npx cf deploy --mode legacy   # sourcemap-repro-legacy-registry (no flag)
npx cf deploy --mode new      # sourcemap-repro-new-registry (new_module_registry)

WORKERS_SUBDOMAIN=<your-subdomain> ./tail.sh   # real-time tail (source maps applied here)
./query-logs.sh                                # persisted Workers Logs via `cf observability telemetry query`
./cleanup.sh
```

`vite.config.ts` sets `build.sourcemap: true`, so `@cloudflare/vite-plugin`
emits `index.js.map` into the Build Output and `cf deploy` uploads it as an
`application/source-map` part (partial manifests infer `.map` as `sourcemap`).

## Result

Real-time tail (`./tail.sh`):

```
=== legacy registry
    at e (../../../../../../src/worker.ts:5:13)
    at explodeWithReadableName (../../../../../../src/worker.ts:10:5)
=== new registry
    at e (file:///bundle/index.js:1:20)
    at Object.fetch (file:///bundle/index.js:1:67)
```

With `new_module_registry`, frames are reported as `file:///bundle/index.js`
and the uploaded `index.js.map` is never applied. Without the flag, frames are
`index.js` and are remapped to `src/worker.ts`.

Persisted Workers Logs (`./query-logs.sh`) show raw positions for both Workers
(`index.js:1:20` vs `file:///bundle/index.js:1:20`), consistent with the docs
listing only real-time logs, Tail Workers, and Workers Issues as remap targets.

Versions: cf 1.0.0-beta.12, @cloudflare/vite-plugin 2.0.0-beta.sha-52b0dc0e9,
vite 8.3.2, compatibility date 2026-08-31.
