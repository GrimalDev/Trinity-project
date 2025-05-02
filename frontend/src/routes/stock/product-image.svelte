<script lang="ts">
  export let imageUrl: string | undefined;
</script>

{#if imageUrl}
  <img
    src={imageUrl}
    alt="Produit"
    class="w-full h-full object-contain rounded-sm"
  />
{:else}
  <span>No image</span>
{/if}
