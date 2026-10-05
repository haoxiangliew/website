<script lang="ts">
  import MapPinIcon from "@lucide/svelte/icons/map-pin";
  import { siGithub, siX } from "simple-icons";

  import { Button } from "#lib/components/ui/button/index.js";

  // LinkedIn was removed in simple-icons v14; this path is from simple-icons@13.21.0
  const linkedinPath =
    "M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z";

  const socials = [
    { href: "https://github.com/haoxiangliew", label: "GitHub", path: siGithub.path },
    { href: "https://x.com/haoxiangliew", label: "X", path: siX.path },
    { href: "https://www.linkedin.com/in/haoxiangliew", label: "LinkedIn", path: linkedinPath },
  ] as const;
</script>

<section class="my-auto flex flex-col gap-6">
  <hgroup class="flex flex-col gap-2">
    <h1 class="text-2xl font-medium">
      Hi, I'm Hao Xiang Liew, an engineer at
      <a href="https://fluidstack.io" target="_blank" class="underline underline-offset-4"
        >Fluidstack</a
      >
    </h1>
    <p class="flex items-center gap-1 text-muted-foreground">
      <MapPinIcon class="size-4" />
      San Francisco
    </p>
  </hgroup>
  <div class="flex gap-2">
    {#each socials as social (social.href)}
      <Button
        href={social.href}
        target="_blank"
        rel="me"
        title={social.label}
        variant="outline"
        size="icon"
      >
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d={social.path} />
        </svg>
        <span class="sr-only">{social.label}</span>
      </Button>
    {/each}
  </div>
</section>
