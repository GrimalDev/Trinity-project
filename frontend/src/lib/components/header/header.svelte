<script lang="ts">
  import Navbar from "./nav-bar.svelte";
  import UserNav from "./user-nav.svelte";
  import Sun from "lucide-svelte/icons/sun";
  import Moon from "lucide-svelte/icons/moon";
  import { Button } from "$lib/components/ui/button/index.js";
  import { browser } from "$app/environment";
  import { theme } from "$lib/stores/themeStore";

  function toggleMode() {
    if (browser) {
      theme.update((currentTheme) =>
        currentTheme === "dark" ? "light" : "dark",
      );
    }
  }
</script>

<header class="flex items-center justify-between p-4 border">
  <div class="flex items-center space-x-10">
    <a href="/stock" class="hover:opacity-80 transition-opacity">
      <img
        src="https://cdn-icons-png.flaticon.com/128/7481/7481013.png"
        alt="Logo"
        class="h-10 w-10"
      />
    </a>

    <div class="hidden sm:flex">
      <Navbar />
    </div>
  </div>

  <div class="flex items-center space-x-4">
    <Button onclick={toggleMode} variant="outline" class="h-9" size="icon">
      <Sun
        class="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0"
      />
      <Moon
        class="absolute h-[1.2rem] w-[1.2rem] rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100"
      />
      <span class="sr-only">Toggle theme</span>
    </Button>
    <UserNav />
  </div>
</header>
