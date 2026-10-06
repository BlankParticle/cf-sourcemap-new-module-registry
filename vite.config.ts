import { cloudflare } from "@cloudflare/vite-plugin";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [cloudflare()],
  build: {
    // Emit `.map` files so they are uploaded alongside the Worker modules
    // (the Vite equivalent of wrangler's `upload_source_maps: true`).
    sourcemap: true,
    minify: true,
  },
});
