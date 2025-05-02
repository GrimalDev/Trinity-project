<script lang="ts">
  import DataTable from "./data-table.svelte";
  import { columns } from "./column";
  import { userStore } from "$lib/stores/userStore";
  import { getAllUser } from "$lib/api/apiUser";
  import { goto } from "$app/navigation";
  import type { User } from "$lib/types/auth";

  let data = $state<User[]>([]);

  $effect(() => {
    if ($userStore) {
      if (!userStore.hasPermission("/user", "*")) {
        goto("/stock");
        return;
      }
      getAllUser().then((users) => {
        data = users;
        console.log(users);
      });
    }
  });
</script>

<main class="p-8 mx-auto">
  <h1 class="text-2xl font-bold mb-6 text-center">User management</h1>

  <!-- Composant DataTable -->
  <div class="">
    <DataTable {data} {columns} />
  </div>
</main>
