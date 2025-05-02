<script lang="ts">
  import { userStore } from "$lib/stores/userStore";
  import { cn } from "$lib/utils.js";

  let className: string | undefined | null = undefined;
  export { className as class };
</script>

<nav class={cn("flex items-center gap-[4vw]", className)}>
  {#if userStore.hasPermission("/stock", "*")}
    <a
      href="/stock"
      class="hover:text-primary text-sm font-medium transition-colors"
    >
      Stocks
    </a>
  {/if}

  {#if userStore.hasPermission("/product", "*")}
    <a
      href="/product"
      class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
    >
      Products
    </a>
  {/if}

  {#if !$userStore}
    <a
      href="/login"
      class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
    >
      Connexion
    </a>
  {/if}

  {#if userStore.hasPermission("/user", "*")}
    <a
      href="/usertable"
      class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
    >
      Users
    </a>
  {/if}

  {#if userStore.hasPermission("/kpi", "*")}
    <a
      href="/kpi"
      class="text-muted-foreground hover:text-primary text-sm font-medium transition-colors"
    >
      Kpi
    </a>
  {/if}
</nav>
