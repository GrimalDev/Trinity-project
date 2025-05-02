<script lang="ts">
  import Checkbox from "$lib/components/ui/checkbox/checkbox.svelte";

  export let email: string;
  export let status: boolean;

  function toggleStatus() {
    console.log(
      `Changement du statut pour : ${email}, nouveau statut : ${!status}`,
    );
  }
</script>

<label class="flex items-center gap-2 cursor-pointer justify-center">
  <Checkbox bind:checked={status} disabled onCheckedChange={toggleStatus} />
</label>
