<script lang="ts">
  import { page } from "$app/state";
  import MenuIcon from "@lucide/svelte/icons/menu";

  import ModeToggle from "#lib/components/mode-toggle.svelte";
  import { Button, buttonVariants } from "#lib/components/ui/button/index.js";
  import * as Drawer from "#lib/components/ui/drawer/index.js";
  import * as NavigationMenu from "#lib/components/ui/navigation-menu/index.js";
  import { Separator } from "#lib/components/ui/separator/index.js";

  // svelte-check can't type named exports of a .svelte file imported through #lib
  import { navigationMenuTriggerStyle } from "./ui/navigation-menu/navigation-menu-trigger.svelte";

  const links = [
    { href: "/", label: "~/haoxiangliew" },
    // { href: "/thoughts", label: "thoughts" },
    // { href: "/about", label: "about" },
  ] as const;

  const drawerEnabled = false; // mobile menu disabled while there's only one page

  let open = $state(false);

  function isActive(href: string) {
    const { pathname } = page.url;
    return pathname === href || pathname.startsWith(`${href}/`);
  }
</script>

<!-- Mobile: bar at the bottom, line above it. Desktop: bar at the top, line below it. -->
<header class="sticky grid bg-background max-md:bottom-0 max-md:order-last md:top-0">
  <Separator class="md:order-last" />
  <div class="flex h-14 items-center justify-between px-4">
    <NavigationMenu.Root
      class={["font-mono", drawerEnabled ? "hidden md:flex" : "max-md:order-last"]}
    >
      <NavigationMenu.List class="gap-1">
        {#each links as link (link.href)}
          <NavigationMenu.Item>
            <NavigationMenu.Link
              href={link.href}
              active={isActive(link.href)}
              class={navigationMenuTriggerStyle()}
            >
              {link.label}
            </NavigationMenu.Link>
          </NavigationMenu.Item>
        {/each}
      </NavigationMenu.List>
    </NavigationMenu.Root>

    <ModeToggle />

    {#if drawerEnabled}
      <Drawer.Root bind:open>
        <Drawer.Trigger
          class={buttonVariants({ variant: "ghost", size: "icon", class: "md:hidden" })}
        >
          <MenuIcon />
          <span class="sr-only">Open navigation</span>
        </Drawer.Trigger>
        <Drawer.Content>
          <Drawer.Title class="sr-only">Navigation</Drawer.Title>
          <nav class="font-mono">
            <Drawer.Footer>
              {#each links as link (link.href)}
                {@const active = isActive(link.href)}
                <Button
                  href={link.href}
                  variant={active ? "secondary" : "ghost"}
                  size="lg"
                  aria-current={active ? "page" : undefined}
                  onclick={() => (open = false)}
                >
                  {link.label}
                </Button>
              {/each}
            </Drawer.Footer>
          </nav>
        </Drawer.Content>
      </Drawer.Root>
    {/if}
  </div>
</header>
