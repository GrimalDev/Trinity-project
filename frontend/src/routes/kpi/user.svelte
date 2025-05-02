<script lang="ts">
  import * as Card from "$lib/components/ui/card/index.js";
  import * as Tabs from "$lib/components/ui/tabs/index.js";
  import Activity from "lucide-svelte/icons/activity";
  import Euro from "lucide-svelte/icons/euro";
  import CreditCard from "lucide-svelte/icons/credit-card";
  import User from "lucide-svelte/icons/user";
  import Overview from "./overview.svelte";
  import Pie from "$lib/components/ui/charts/pie.svelte";
  import {
    getAverageSpending,
    getEarnings,
    getTotalCommande,
    getTotalUser,
  } from "$lib/api/apiStats";
  import { Tween } from "svelte/motion";

  let progress_earnings = new Tween(0, { duration: 700 });
  let progress_total_user = new Tween(0, { duration: 700 });
  let progress_total_commande = new Tween(0, { duration: 700 });
  let progress_average_spending = new Tween(0, { duration: 700 });

  $effect(() => {
    getEarnings().then((data) => {
      progress_earnings.target = data;
    });

    getTotalUser().then((data) => {
      progress_total_user.target = data;
    });

    getTotalCommande().then((data) => {
      progress_total_commande.target = data;
    });

    getAverageSpending().then((data) => {
      progress_average_spending.target = data;
    });
  });
</script>

<Tabs.Content value="user" class="space-y-4">
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium">Earnings</Card.Title>
        <Euro class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {progress_earnings.current.toFixed(2)} €
        </div>
        <p class="text-muted-foreground text-xs">+20.1% from last month</p>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium">Total Users</Card.Title>
        <User class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          + {progress_total_user.current.toFixed(0)}
        </div>
        <p class="text-muted-foreground text-xs">180% from last month</p>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium">Sales</Card.Title>
        <CreditCard class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          +
          {progress_total_commande.current.toFixed(0)}
        </div>
        <p class="text-muted-foreground text-xs">+19% from last month</p>
      </Card.Content>
    </Card.Root>
    <Card.Root>
      <Card.Header
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <Card.Title class="text-sm font-medium"
          >Average spending per sales</Card.Title
        >
        <Activity class="text-muted-foreground h-4 w-4" />
      </Card.Header>
      <Card.Content>
        <div class="text-2xl font-bold">
          {progress_average_spending.current.toFixed(2)} €
        </div>
        <p class="text-muted-foreground text-xs">+1.7% since last week</p>
      </Card.Content>
    </Card.Root>
  </div>
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
    <Card.Root class="col-span-4">
      <Card.Header>
        <Card.Title>Sales Overview</Card.Title>
      </Card.Header>
      <Card.Content>
        <Overview />
      </Card.Content>
    </Card.Root>
    <Card.Root class="col-span-3 flex flex-col">
      <Card.Header>
        <Card.Title>Most sales per Categories</Card.Title>
        <Card.Description>65 Total categories</Card.Description>
      </Card.Header>
      <Card.Content class="flex-grow min-h-[320px]">
        <!-- <RecentSales /> -->
        <Pie />
      </Card.Content>
    </Card.Root>
  </div>
</Tabs.Content>
