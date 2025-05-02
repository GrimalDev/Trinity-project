<script lang="ts">
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu";
  import * as Avatar from "$lib/components/ui/avatar";
  import { Button } from "$lib/components/ui/button";
  import { userStore } from "$lib/stores/userStore";
  import { goto } from "$app/navigation";
</script>

<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    <Button variant="ghost" class="relative h-8 w-8 rounded-full">
      <Avatar.Root class="h-8 w-8">
        <Avatar.Image src="" alt="@shadcn" />
        {#if $userStore}
          <Avatar.Fallback>
            {$userStore?.firstName[0] + $userStore?.lastName[0]}
          </Avatar.Fallback>
        {/if}
      </Avatar.Root>
    </Button>
  </DropdownMenu.Trigger>
  <DropdownMenu.Content class="w-56" align="end">
    <DropdownMenu.Label class="font-normal">
      <div class="flex flex-col space-y-1">
        {#if $userStore}
          <p class="text-sm font-medium leading-none">
            {$userStore?.firstName + " " + $userStore?.lastName}
          </p>
          <p class="text-muted-foreground text-xs leading-none">
            {$userStore.email}
          </p>
        {/if}
      </div>
    </DropdownMenu.Label>
    <DropdownMenu.Separator />
    <DropdownMenu.Group>
      <DropdownMenu.Item onSelect={() => goto("/user")}>
        Settings
        <!-- <DropdownMenu.Shortcut>⇧⌘P</DropdownMenu.Shortcut> -->
      </DropdownMenu.Item>
    </DropdownMenu.Group>
    <DropdownMenu.Separator />
    <DropdownMenu.Item
      onSelect={async () => {
        userStore.clearUser();
        await goto("/login");
      }}
    >
      Log out
      <!-- <DropdownMenu.Shortcut>⇧⌘Q</DropdownMenu.Shortcut> -->
    </DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>
