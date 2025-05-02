<script lang="ts">
  import Ellipsis from "lucide-svelte/icons/ellipsis";

  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import { deleteProduct, updateProduct } from "$lib/api/apiProducts";
  import * as Dialog from "$lib/components/ui/dialog";
  import { Button } from "$lib/components/ui/button";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";

  export let id: string;
  export let product: { name: string; price: number; quantity: number };

  let editedProduct = { ...product };

  const handleDelete = async () => {
    await deleteProduct(id);
    location.reload();
  };

  const handleUpdate = async () => {
    await updateProduct(id, editedProduct);
    location.reload();
  };
</script>

<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    <Button variant="ghost" size="icon" class="relative size-8 p-0">
      <span class="sr-only">Open menu</span>
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
      >
        Edit
      </Dialog.Trigger>
      <Dialog.Content class="sm:max-w-[425px]">
        <Dialog.Header>
          <Dialog.Title>Edit Product</Dialog.Title>
          <Dialog.Description>
            Make changes to your product here. Click save when you're done.
          </Dialog.Description>
        </Dialog.Header>
        <div class="grid gap-4 py-4">
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="name" class="text-right">Name</Label>
            <Input
              id="name"
              bind:value={editedProduct.name}
              class="col-span-3"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="price" class="text-right">Price</Label>
            <Input
              id="price"
              type="number"
              bind:value={editedProduct.price}
              class="col-span-3"
            />
          </div>
          <div class="grid grid-cols-4 items-center gap-4">
            <Label for="quantity" class="text-right">Quantity</Label>
            <Input
              id="quantity"
              type="number"
              bind:value={editedProduct.quantity}
              class="col-span-3"
            />
          </div>
        </div>
        <Dialog.Footer>
          <Button type="submit" onclick={handleUpdate}>Save changes</Button>
        </Dialog.Footer>
      </Dialog.Content>
    </Dialog.Root>
    <DropdownMenu.Item onclick={handleDelete}>Delete</DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>
