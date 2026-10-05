import { defineConfig } from "oxfmt";

export default defineConfig({
  // vendored agent skills and subagents, kept byte-identical to upstream apart from npx -> bunx
  ignorePatterns: [".agents", ".pi"],
  svelte: true,
  sortImports: {
    groups: [
      "type-import",
      ["value-builtin", "value-external"],
      "type-internal",
      "value-internal",
      ["type-parent", "type-sibling", "type-index"],
      ["value-parent", "value-sibling", "value-index"],
      "unknown",
    ],
  },
  sortTailwindcss: {
    stylesheet: "src/routes/layout.css",
    functions: ["cn", "tv"],
  },
});
