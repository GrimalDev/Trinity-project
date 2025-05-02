<script lang="ts">
  import * as Tabs from "$lib/components/ui/tabs/index.js";
  import Product from "./product.svelte";
  import User from "./user.svelte";
</script>

<div class="hidden flex-col md:flex">
  <div class="flex-1 space-y-4 p-8 pt-3 pb-0">
    <!-- <div class="flex items-center justify-between space-y-2"> -->
    <!--   <h2 class="text-3xl font-bold tracking-tight">Dashboard</h2> -->
    <!--   <div class="flex items-center space-x-2"> -->
    <!--     <Button size="sm"> -->
    <!--       <Download class="mr-2 h-4 w-4" /> -->
    <!--       Download -->
    <!--     </Button> -->
    <!--   </div> -->
    <!-- </div> -->
    <Tabs.Root value="user" class="space-y-4">
      <Tabs.List>
        <Tabs.Trigger value="user">User</Tabs.Trigger>
        <Tabs.Trigger value="product">Product</Tabs.Trigger>
      </Tabs.List>

      <User />
      <Product />
    </Tabs.Root>
  </div>
</div>
