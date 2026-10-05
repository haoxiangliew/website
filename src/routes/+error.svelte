<script lang="ts">
  import { page } from "$app/state";
  import HouseIcon from "@lucide/svelte/icons/house";

  import { Button } from "#lib/components/ui/button/index.js";
  import * as Empty from "#lib/components/ui/empty/index.js";
</script>

<svelte:head>
  <title>{page.status} · Hao Xiang Liew</title>
</svelte:head>

<Empty.Root>
  <Empty.Header>
    <Empty.Title class="text-4xl">{page.status}</Empty.Title>
    <Empty.Description>{page.error?.message}</Empty.Description>
  </Empty.Header>
  <Empty.Content>
    <Button href="/" variant="outline" size="lg">
      <HouseIcon data-icon="inline-start" />
      Go home
    </Button>
  </Empty.Content>
</Empty.Root>
