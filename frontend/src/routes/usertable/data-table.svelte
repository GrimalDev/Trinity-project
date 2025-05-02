<script lang="ts">
  import {
    type ColumnFiltersState,
    type SortingState,
    getCoreRowModel,
    getSortedRowModel,
    getFilteredRowModel,
  } from "@tanstack/table-core";
  import {
    createSvelteTable,
    FlexRender,
  } from "$lib/components/ui/data-table/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import type { User } from "$lib/types/auth";
  import { Button } from "$lib/components/ui/button";
  import { Label } from "$lib/components/ui/label";
  import { Input } from "$lib/components/ui/input";
  import * as Dialog from "$lib/components/ui/dialog";
  import { createUserAdmin } from "$lib/api/apiUser";
  import type { createUser } from "$lib/types/auth";

  type Props = {
    data: User[];
    columns: any;
  };
  let { columns, data }: Props = $props();
  // const { columns, data } = $props();

  // Gestion des états pour le tri et les filtres
  let sorting = $state<SortingState>([]);
  let columnFilters = $state<ColumnFiltersState>([]);

  // Création de la table
  const table = createSvelteTable({
    get data() {
      return data;
    },
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onSortingChange: (updater) => {
      sorting = typeof updater === "function" ? updater(sorting) : updater;
    },
    onColumnFiltersChange: (updater) => {
      columnFilters =
        typeof updater === "function" ? updater(columnFilters) : updater;
    },
    state: {
      get sorting() {
        return sorting;
      },
      get columnFilters() {
        return columnFilters;
      },
    },
  });

  // Initialize form data with writable stores
  const formData = {
    firstName: "user",
    lastname: "test",
    email: "",
    password: "",
    phoneNumber: "012349678",
    city: {
      id: 1,
      name: "Stras",
      postalCode: "67800",
      country: "Free",
    },
    address: "1234 rue des fesses",
  };

  // Function to handle form submission
  const handleSubmit = async () => {
    // Get the current value of formData
    // event.preventDefault();

    try {
      const response = await createUserAdmin(formData as createUser);
      if (response) {
        console.log("Profile created successfully");
        // Optionally, close the dialog or reset the form here
      } else {
        console.error("Failed to create profile");
      }
    } catch (error) {
      console.error("Error:", error);
    }
  };
</script>

<!-- <Header title="Stock" /> -->
<div class="rounded-md border">
  <Table.Root>
    <Table.Header>
      {#each table.getHeaderGroups() as headerGroup (headerGroup.id)}
        <Table.Row>
          {#each headerGroup.headers as header (header.id)}
            <Table.Head>
              {#if !header.isPlaceholder}
                <div class="flex flex-col items-center mb-3 mt-3">
                  <button
                    class="flex items-center"
                    onclick={() => header.column.toggleSorting()}
                  >
                    <FlexRender
                      content={header.column.columnDef.header}
                      context={header.getContext()}
                    />
                    {#if header.column.getIsSorted() === "asc"}
                      <span>🔼</span>
                    {:else if header.column.getIsSorted() === "desc"}
                      <span>🔽</span>
                    {/if}
                  </button>

                  {#if header.column.columnDef.header !== "Add"}
                    <Input
                      placeholder={`Filter ${header.column.columnDef.header ?? ""}...`}
                      value={(header.column.getFilterValue() as string) ?? ""}
                      oninput={(e) => {
                        header.column.setFilterValue(e.currentTarget.value);
                      }}
                      class="mt-1 w-full"
                    />
                  {:else}
                    <Dialog.Root>
                      <Dialog.Trigger class=""
                        ><Button>+</Button></Dialog.Trigger
                      >
                      <Dialog.Content class="sm:max-w-[425px]">
                        <Dialog.Header>
                          <Dialog.Title>Create profile</Dialog.Title>
                          <Dialog.Description>
                            Create your profile here. Click create when you're
                            done.
                          </Dialog.Description>
                        </Dialog.Header>
                        <form onsubmit={handleSubmit}>
                          <div class="grid gap-4 py-4">
                            <div class="grid grid-cols-4 items-center gap-4">
                              <Label for="email" class="text-right">Email</Label
                              >
                              <Input
                                bind:value={formData.email}
                                id="name"
                                class="col-span-3"
                                type="email"
                              />
                            </div>
                            <div class="grid grid-cols-4 items-center gap-4">
                              <Label for="password" class="text-right"
                                >Passsword</Label
                              >
                              <Input
                                id="password"
                                bind:value={formData.password}
                                class="col-span-3"
                                type="password"
                              />
                            </div>
                          </div>
                          <Dialog.Footer>
                            <Button type="submit">Create</Button>
                          </Dialog.Footer>
                        </form>
                      </Dialog.Content>
                    </Dialog.Root>
                  {/if}
                </div>
              {/if}
            </Table.Head>
          {/each}
        </Table.Row>
      {/each}
    </Table.Header>
    <Table.Body>
      {#each table.getRowModel().rows as row (row.id)}
        <Table.Row data-state={row.getIsSelected() && "selected"}>
          {#each row.getVisibleCells() as cell (cell.id)}
            <Table.Cell class="text-center">
              <FlexRender
                content={cell.column.columnDef.cell}
                context={cell.getContext()}
              />
            </Table.Cell>
          {/each}
        </Table.Row>
      {:else}
        <Table.Row>
          <Table.Cell colspan={columns.length} class="h-24 text-center">
            No results.
          </Table.Cell>
        </Table.Row>
      {/each}
    </Table.Body>
  </Table.Root>
</div>
