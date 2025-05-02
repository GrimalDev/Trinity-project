<script lang="ts">
  import Ellipsis from "lucide-svelte/icons/ellipsis";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import { deleteUser } from "$lib/api/apiUser";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Button } from "$lib/components/ui/button";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";

  // Recevoir l'ID du user comme prop
  export let id: string;

  const handleDelete = async () => {
    console.log(`Supprimer ${id}`);
    let res = await deleteUser(id);
    if (res) {
      console.log("User supprimÃ©");
      location.reload();
    }
  };
</script>

<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    <Button variant="ghost" size="icon" class="relative size-8 p-0">
      <span class="sr-only">Ouvrir le menu</span>
      <Ellipsis />
    </Button>
  </DropdownMenu.Trigger>

  <DropdownMenu.Content>
    <div class="px-4 py-2 font-semibold">Actions</div>
    <DropdownMenu.Item onclick={() => console.log(`View Details ${id}`)}>
      Details
    </DropdownMenu.Item>

    <Dialog.Root>
      <Dialog.Trigger
        class="data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 hover:bg-accent w-full"
        >Modify</Dialog.Trigger
      >
      <Dialog.Content class="sm:max-w-[425px]">
        <Dialog.Header>
          <Dialog.Title>Edit profile</Dialog.Title>
          <Dialog.Description>
            Make changes to your profile here. Click save when you're done.
          </Dialog.Description>
        </Dialog.Header>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="name" class="text-right">Name</Label>
            <Input id="name" value="Pedro Duarte" class="col-span-3" />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="username" class="text-right">Username</Label>
            <Input id="username" value="@peduarte" class="col-span-3" />
          </div>
        </div>
        <Dialog.Footer>
          <Button type="submit">Save changes</Button>
        </Dialog.Footer>
      </Dialog.Content>
    </Dialog.Root>
    <DropdownMenu.Item onclick={() => handleDelete()}>Delete</DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>
