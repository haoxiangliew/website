import type { Handle } from "@sveltejs/kit/hooks";

// Preload CSS and the Latin fonts, the only subset our text uses.
// Skip JS. Lighthouse treats preloaded scripts as render-blocking, which doubled mobile FCP.
export const handle: Handle = ({ event, resolve }) =>
  resolve(event, {
    preload: ({ type, path }) =>
      type === "css" || (type === "font" && path.includes("-latin-wght-")),
  });
