<script lang="ts">
  import type { HTMLAttributes } from "svelte/elements";
  import { cn } from "$lib/utils.js";

  type $$Props = {
    class?: string;
    inset?: boolean;
  } & HTMLAttributes<HTMLDivElement>;

  let className: $$Props["class"] = undefined;
  export let inset: $$Props["inset"] = undefined;
  export { className as class };
</script>

<div
  role="menuitem"
  class={cn("px-2 py-1.5 text-sm font-semibold", inset && "pl-8", className)}
  {...$$restProps}
>
  <slot />
</div>
