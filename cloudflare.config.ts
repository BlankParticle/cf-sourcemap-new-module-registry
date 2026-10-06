import { defineConfig } from "cf/config";
import * as entrypoint from "./src/worker" with { type: "cf-worker" };

// `cf deploy --mode legacy` and `cf deploy --mode new` deploy the same code
// as two Workers that differ only in the module registry flag.
export default defineConfig((ctx) => {
  const registry = ctx.mode === "new" ? "new" : "legacy";
  return {
    worker: {
      name: `sourcemap-repro-${registry}-registry`,
      entrypoint,
      compatibilityDate: "2026-08-31",
      compatibilityFlags: registry === "new" ? ["new_module_registry"] : [],
      observability: { enabled: true },
    },
  };
});
