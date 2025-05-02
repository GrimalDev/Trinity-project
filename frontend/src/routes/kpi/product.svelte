<script lang="ts">
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Tabs from "$lib/components/ui/tabs/index.js";
  import ShoppingCart from "lucide-svelte/icons/shopping-cart";
  import CreditCard from "lucide-svelte/icons/credit-card";
  import ChartColumnStacked from "lucide-svelte/icons/chart-column-stacked";
  import BarProduct from "$lib/components/ui/charts/bar_product.svelte";
  import {
    getAverageProductCost,
    getProductPerCategory,
    getTotalCategories,
    getTotalProductSold,
    getTotalProductStock,
  } from "$lib/api/apiStats";

  // var total_product_sold = $state(0);
  // var total_categories = $state(0);
  // var total_product_stock = $state(0);
  // var average_product_cost = $state(0);
  // var product_per_category = $state([] as StatsProduct[]);

  // getProductPerCategory().then((data) => {
  //   product_per_category = data;
  //   // console.log("fetch", data);
  // });

  $effect(() => {
    // getTotalProductSold().then((data) => {
    //   total_product_sold = data;
    // });
    //
    // getTotalCategories().then((data) => {
    //   total_categories = data;
    // });
    //
    // getTotalProductStock().then((data) => {
    //   total_product_stock = data;
    // });
    //
    // getAverageProductCost().then((data) => {
    //   average_product_cost = data;
    // });
    // getProductPerCategory().then((data) => {
    //   product_per_category = data;
    //   // console.log("fetch", data);
    // });
  });

  // onMount(async () => {
  //   getProductPerCategory().then((data) => {
  //     product_per_category = data;
  //     // console.log("fetch", data);
  //   });
  // });
</script>

<Tabs.Content value="product" class="space-y-4">
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium">Total Product sold</Card.Title>
        <ShoppingCart class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {#await getTotalProductSold() then result}
            +{result.toFixed(0)}
          {/await}
        </div>
        <p class="text-muted-foreground text-xs">-10.3% from last month</p>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium">Total Categories</Card.Title>
        <ChartColumnStacked class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {#await getTotalCategories() then result}
            {result.toFixed(0)}
          {/await}
        </div>
        <!-- <p class="text-muted-foreground text-xs">+180.1% from last month</p> -->
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium"
          >Total product in stock</Card.Title
        >
        <!-- <Activity class="text-muted-foreground h-4 w-4" /> -->
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {#await getTotalProductStock() then result}
            {result.toFixed(0)}
          {/await}
        </div>
        <p class="text-muted-foreground text-xs">+201 since last hour</p>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium"
          >Average cost per product</Card.Title
        >
        <CreditCard class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {#await getAverageProductCost() then result}
            {result.toFixed(2)}
            €
          {/await}
        </div>
        <p class="text-muted-foreground text-xs">+19% from last month</p>
      </Card.Content>
    </Card.Root>
  </div>
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
    <Card.Root class="col-span-7">
      <Card.Header>
        <Card.Title>Product per categories</Card.Title>
      </Card.Header>
      <Card.Content>
        {#await getProductPerCategory() then result}
          <BarProduct data={result} />
        {/await}
      </Card.Content>
    </Card.Root>
    <!-- <Card.Root class="col-span-3"> -->
    <!--   <Card.Header> -->
    <!--     <Card.Title>Recent Sales</Card.Title> -->
    <!--     <Card.Description>You made 265 sales this month.</Card.Description> -->
    <!--   </Card.Header> -->
    <!--   <Card.Content> -->
    <!--     <!-- <RecentSales /> -->
    <!--   </Card.Content> -->
    <!-- </Card.Root> -->
  </div>
</Tabs.Content>
