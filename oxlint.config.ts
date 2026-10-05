import { recommended as effectRecommended } from "@effect/tsgo/oxlint-presets";
import rsvelteRecommended from "@rsvelte/oxlint-plugin/recommended.json" with { type: "json" };
import { defineConfig } from "oxlint";
import tailwindcss from "oxlint-tailwindcss";

// eslint-plugin-svelte ports only; snake_case ids are compiler warnings, which svelte-check already reports
const svelteRules = Object.fromEntries(
  Object.entries(rsvelteRecommended.rules).filter(([id]) => !id.includes("_")),
);

// each rule carries its recommended severity, or false when it is opt-in
const tailwindRules = Object.fromEntries(
  Object.entries(tailwindcss.rules).map(([name, rule]) => [
    `tailwindcss/${name}`,
    rule.meta?.docs?.recommended || "off",
  ]),
);

export default defineConfig({
  ignorePatterns: ["src/lib/components/ui"],
  plugins: ["typescript", "unicorn", "oxc"],
  jsPlugins: ["@rsvelte/oxlint-plugin", "oxlint-tailwindcss"],
  settings: {
    tailwindcss: { entryPoint: "src/routes/layout.css" },
  },
  options: {
    typeAware: true,
    typeCheck: true,
  },
  categories: {
    correctness: "error",
  },
  extends: [effectRecommended],
  rules: {
    ...svelteRules,
    ...tailwindRules,
    "sort-imports": ["warn", { ignoreDeclarationSort: true }],
    "no-restricted-globals": [
      "error",
      {
        name: "$effect",
        message:
          "Use $derived, event handlers, {@attach}, or onMount. If $effect is truly needed, disable this rule with a comment explaining why.",
      },
    ],
  },
});
