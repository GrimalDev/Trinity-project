<script lang="ts">
  import { goto } from "$app/navigation";
  import { loginUser } from "$lib/api/apiUser";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";

  let email = "";
  let password = "";
  let isLoading = false;
  let error: unknown = null;

  async function onSubmit() {
    isLoading = true;

    error = await loginUser(email, password);
    if (!error) {
      goto("/stock");
      console.log("User logged in successfully");
    } else {
      console.log("User login failed");
      isLoading = false;
    }

    setTimeout(() => {
      isLoading = false;
    }, 1000);
  }
</script>

<div class="flex flex-col justify-center space-y-6 px-8 sm:w-[400px] mx-auto">
  <div class="text-center">
    <h1 class="text-2xl font-semibold tracking-tight">Connexion</h1>
    <p class="text-muted-foreground text-sm">
      Entrez vos informations pour accéder à votre compte
    </p>
  </div>

  <form on:submit|preventDefault={onSubmit} class="space-y-4">
    <div class="grid gap-2">
      <Label for="email">Email</Label>
      <Input
        id="email"
        type="email"
        bind:value={email}
        placeholder="Email"
        autocomplete="email"
        disabled={isLoading}
      />
    </div>
    <div class="grid gap-2">
      <Label for="password">Mot de passe</Label>
      <Input
        id="password"
        type="password"
        bind:value={password}
        placeholder="Mot de passe"
        autocomplete="current-password"
        disabled={isLoading}
      />
    </div>
    <Button type="submit" disabled={isLoading} class="w-full">
      {#if isLoading}
        Chargement...
      {:else}
        Se connecter
      {/if}
    </Button>
    {#if error}
      <div class="text-center text-red-400">erreur de connexion</div>
    {/if}
  </form>
</div>
