<script lang="ts">
  import MoonIcon from "@lucide/svelte/icons/moon";
  import MoonStarIcon from "@lucide/svelte/icons/moon-star";
  import SunIcon from "@lucide/svelte/icons/sun";
  import SunDimIcon from "@lucide/svelte/icons/sun-dim";
  import { setMode, setTheme, userPrefersMode } from "mode-watcher";

  import { buttonVariants } from "#lib/components/ui/button/index.js";
  import * as Drawer from "#lib/components/ui/drawer/index.js";
  import * as DropdownMenu from "#lib/components/ui/dropdown-menu/index.js";
  import * as ToggleGroup from "#lib/components/ui/toggle-group/index.js";

  const modes = [
    { value: "light", label: "Light" },
    { value: "dark", label: "Dark" },
    { value: "system", label: "System" },
  ] as const;

  type Mode = (typeof modes)[number]["value"];

  let open = $state(false);

  // Also store "system" as the mode-watcher theme, so <html> gets data-theme="system".
  // Change modes only through select().
  function select(value: Mode) {
    setMode(value);
    setTheme(value === "system" ? "system" : "");
  }
</script>

<!-- sun or moon for light and dark, sun-dim or moon-star for system -->
{#snippet triggerIcon()}
  <SunIcon class="transition-transform dark:scale-0 dark:-rotate-90 system:scale-0" />
  <MoonIcon
    class="absolute scale-0 rotate-90 transition-transform dark:scale-100 dark:rotate-0 system:dark:scale-0"
  />
  <SunDimIcon class="absolute scale-0 transition-transform system:scale-100 system:dark:scale-0" />
  <MoonStarIcon class="absolute scale-0 transition-transform system:dark:scale-100" />
  <span class="sr-only">Toggle theme</span>
{/snippet}

{#snippet modeIcon(mode: Mode)}
  {#if mode === "light"}
    <SunIcon />
  {:else if mode === "dark"}
    <MoonIcon />
  {:else}
    <SunDimIcon class="os-dark:hidden" />
    <MoonStarIcon class="hidden os-dark:block" />
  {/if}
{/snippet}

<DropdownMenu.Root>
  <DropdownMenu.Trigger
    class={buttonVariants({ variant: "ghost", size: "icon", class: "max-md:hidden" })}
  >
    {@render triggerIcon()}
  </DropdownMenu.Trigger>
  <DropdownMenu.Content align="end">
    <DropdownMenu.RadioGroup value={userPrefersMode.current}>
      {#each modes as mode (mode.value)}
        <DropdownMenu.RadioItem value={mode.value} onSelect={() => select(mode.value)}>
          {@render modeIcon(mode.value)}
          {mode.label}
        </DropdownMenu.RadioItem>
      {/each}
    </DropdownMenu.RadioGroup>
  </DropdownMenu.Content>
</DropdownMenu.Root>

<Drawer.Root bind:open>
  <Drawer.Trigger class={buttonVariants({ variant: "ghost", size: "icon", class: "md:hidden" })}>
    {@render triggerIcon()}
  </Drawer.Trigger>
  <Drawer.Content>
    <Drawer.Title class="sr-only">Theme</Drawer.Title>
    <Drawer.Footer>
      <ToggleGroup.Root
        type="single"
        orientation="vertical"
        size="lg"
        spacing={1}
        class="w-full"
        bind:value={
          () => userPrefersMode.current,
          (value) => {
            // tapping the selected option sends ""; ignore it
            if (value) {
              select(value);
              open = false;
            }
          }
        }
      >
        {#each modes as mode (mode.value)}
          <ToggleGroup.Item value={mode.value}>
            {@render modeIcon(mode.value)}
            {mode.label}
          </ToggleGroup.Item>
        {/each}
      </ToggleGroup.Root>
    </Drawer.Footer>
  </Drawer.Content>
</Drawer.Root>
