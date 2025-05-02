<script lang="ts">
  import DataTable from "./data-table.svelte";
  import { columns } from "./column";
  import type { StockItem } from "$lib/types/product";
  import { getProducts } from "$lib/api/apiProducts";

  let loading = $state(true);
  let error = $state<string | null>(null);
  let products = $state<StockItem[]>([]);

  $effect(() => {
    loading = true;
    error = null;

    getProducts()
      .then((result) => {
        products = result;
        console.log(products);
      })
      .catch((e) => {
        error =
          e instanceof Error
            ? e.message
            : "An error occurred while fetching products";
      })
      .finally(() => {
        loading = false;
      });
  });
</script>

<main class="p-8 mx-auto">
  <h1 class="text-2xl font-bold mb-6 text-center">Stock Viewer</h1>

  <div>
    {#if error}
      <div class="p-4 text-red-500 bg-red-100 rounded-md">
        {error}
      </div>
    {:else if loading}
      <div class="flex justify-center items-center min-h-[200px]">
        <div
          class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"
        ></div>
      </div>
    {:else}
      <DataTable data={products} {columns} />
    {/if}
  </div>
</main>
