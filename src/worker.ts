// Throws an uncaught error from a named function. With a working source map,
// Workers Logs / tail should show `src/worker.ts:<line>` instead of a
// minified `index.js:1:<col>` frame.
function explodeWithReadableName(): never {
  throw new Error("source-map-repro");
}

export default {
  async fetch(): Promise<Response> {
    explodeWithReadableName();
  },
} satisfies ExportedHandler;
