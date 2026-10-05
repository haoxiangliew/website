<script lang="ts">
  import "./layout.css";
  import { ModeWatcher } from "mode-watcher";

  // iOS needs a real URL, not the data: URL Vite uses for small files
  import appleTouchIcon from "#lib/assets/apple-touch-icon.png?no-inline";
  import faviconSvg from "#lib/assets/favicon.svg";
  import SiteHeader from "#lib/components/site-header.svelte";

  import type { LayoutProps } from "./$types";

  let { children }: LayoutProps = $props();
</script>

<svelte:head>
  <title>Hao Xiang Liew</title>
  <meta name="description" content="Hao Xiang Liew's personal website" />
  <link rel="icon" href="/favicon.ico" sizes="32x32" />
  <link rel="icon" href={faviconSvg} type="image/svg+xml" />
  <link rel="apple-touch-icon" href={appleTouchIcon} />
</svelte:head>

<!-- themeColors must match --background in layout.css -->
<ModeWatcher
  disableTransitions={false}
  defaultTheme="system"
  themeColors={{ dark: "#0a0a0a", light: "#ffffff" }}
/>

<div class="flex min-h-svh flex-col">
  <SiteHeader />
  <main class="mx-auto flex w-full max-w-3xl flex-1 flex-col px-4 py-8">
    {@render children()}
  </main>
</div>
