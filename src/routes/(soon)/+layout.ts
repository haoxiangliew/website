import { error } from "@sveltejs/kit";

// Routes in (soon) 404 until they have content. A 404 fails prerendering, so skip it.
export const prerender = false;

export function load() {
  error(404, "Not Found");
}
