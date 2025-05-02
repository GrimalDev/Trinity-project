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
  import { Input } from "$lib/components/ui/input/index.js";
  import * as Table from "$lib/components/ui/table/index.js";

  const { columns, data } = $props();

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
                    type="button"
                    class="flex items-center"
                    onclick={() => header.column.toggleSorting()}
                    onkeydown={(e) => {
                      if (e.key === "Enter" || e.key === " ") {
                        header.column.toggleSorting();
                      }
                    }}
                    aria-label={`Sort by ${header.column.columnDef.header}`}
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

                  <Input
                    placeholder={`Filter ${header.column.columnDef.header ?? ""}...`}
                    value={(header.column.getFilterValue() as string) ?? ""}
                    oninput={(e) => {
                      header.column.setFilterValue(e.currentTarget.value);
                    }}
                    class="mt-1 w-full"
                  />
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
