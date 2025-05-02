<script lang="ts">
  import "../app.css";
  import { onMount } from "svelte";
  import Header from "$lib/components/header/header.svelte";
  import { browser } from "$app/environment";
  import { theme } from "$lib/stores/themeStore";

  import { getCurrentUser } from "$lib/api/apiUser";
  import { goto } from "$app/navigation";
  import { get } from "svelte/store";
  import { userStore } from "$lib/stores/userStore";
  import { page } from "$app/state";

  let { children } = $props();

  let loading = $state(false);

  onMount(async () => {
    try {
      loading = true;
      await getCurrentUser();
      // console.log(loading);
      loading = false;
    } catch (error) {
      loading = false;
      if (browser && page.url.pathname !== "/login") {
        goto("/login");
      }
    }
    // let user = get(userStore);
    // console.log(loading);
  });

  $effect(() => {
    if (browser) {
      let user = get(userStore);
      // console.log(loading);

      if ($theme === "light") {
        document.body.classList.remove("dark");
      } else {
        document.body.classList.add("dark");
      }
      localStorage.setItem("theme-mode", $theme);

      // console.log("user", user, loading, page.url.pathname);
      if (page.url.pathname !== "/login" && !loading && !user) {
        console.log("redirecting to login");
        goto("/login");
      }
    }
  });
</script>

{#if browser && !loading}
  {#if page.url.pathname !== "/login"}
    <Header />
  {/if}
  <main>
    {@render children?.()}
  </main>
{/if}
