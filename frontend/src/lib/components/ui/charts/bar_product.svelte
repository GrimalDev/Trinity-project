<script lang="ts">
  import type { StatsProduct } from "$lib/types/product";
  import { scaleLinear } from "d3-scale";

  type Props = {
    data: StatsProduct[];
  };
  let { data }: Props = $props();

  let xTicks = data.map((d) => d.name);
  // const yTicks = [0, 200, 400, 600, 800];
  const yTicks = [0, 1, 2, 3];
  const padding = { top: 20, right: 15, bottom: 20, left: 45 };

  let chartContainer: HTMLDivElement;

  let width = 900; // Required for reactivity
  let height = 350;

  function formatMobile(tick: number | string) {
    return `'${tick.toString().slice(-2)}`;
  }

  // $: xScale = scaleLinear()
  //   .domain([0, xTicks.length])
  //   .range([padding.left, width - padding.right]);
  //
  // $: yScale = scaleLinear()
  //   .domain([0, Math.max.apply(null, yTicks)])
  //   .range([height - padding.bottom, padding.top]);
  //
  // $: innerWidth = width - (padding.left + padding.right);
  // $: barWidth = innerWidth / xTicks.length;

  let xScale = scaleLinear()
    .domain([0, xTicks.length])
    .range([padding.left, width - padding.right]);
  let yScale = scaleLinear()
    .domain([0, Math.max.apply(null, yTicks)])
    .range([height - padding.bottom, padding.top]);
  let innerWidth = width - (padding.left + padding.right);
  let barWidth = innerWidth / xTicks.length;

  // Tooltip state
  const tooltip = $state({
    visible: false,
    content: "",
    x: 0,
    y: 0,
  });

  const offsetX = -30;
  const offsetY = -35;

  // onMount(async () => {
  // await tick();
  // height = chartContainer.clientHeight;
  // width = chartContainer.clientWidth;
  // console.log("height:", height);
  // console.log("height:", chartContainer.clientHeight);
  // console.log("char:", chartContainer);
  // });

  // $effect(() => {
  //   // const test = $derived(chartContainer.clientWidth);
  //   console.log("height:", data);
  //   xTicks = data.map((d) => d.name);
  //
  //   xScale = scaleLinear()
  //     .domain([0, xTicks.length])
  //     .range([padding.left, width - padding.right]);
  //
  //   yScale = scaleLinear()
  //     .domain([0, Math.max.apply(null, yTicks)])
  //     .range([height - padding.bottom, padding.top]);
  //
  //   innerWidth = width - (padding.left + padding.right);
  //   barWidth = innerWidth / xTicks.length;
  //   console.log(
  //     "height:",
  //     barWidth,
  //     xTicks.length,
  //     innerWidth,
  //     width,
  //     padding.left + padding.right,
  //     xScale,
  //     yScale,
  //   );
  // });
</script>

<div class="chart block" bind:this={chartContainer}>
  <svg>
    <!-- y axis -->
    <g class="axis y-axis">
      {#each yTicks as tick}
        <g class="text-xs" transform="translate(0, {yScale(tick)})">
          <text
            stroke="none"
            font-size="12"
            orientation="left"
            width="60"
            height="310"
            x="57"
            y="-4"
            fill="#888888"
            text-anchor="end"><tspan x="36" dy="0.355em">${tick}</tspan></text
          >
        </g>
      {/each}
    </g>

    <!-- x axis -->
    <g class="axis x-axis">
      {#each data as point, i}
        <g class="text-xs" transform="translate({xScale(i)},{height})">
          <text
            stroke="none"
            font-size="12"
            orientation="bottom"
            width="531"
            height="30"
            x={barWidth / 2}
            y="-15"
            fill="#888888"
            text-anchor="middle"
            ><tspan x={barWidth / 2} dy="0.71em"
              >{data.length > 38
                ? point.name[0]
                : formatMobile(point.name)}</tspan
            ></text
          >
        </g>
      {/each}
    </g>

    <g>
      {#each data as point, i}
        <rect
          class="bg-primary-foreground"
          x={xScale(i) + 2}
          y={yScale(point.total)}
          width={barWidth - 8}
          height={yScale(0) - yScale(point.total)}
          fill="currentColor"
          rx="4"
          ry="4"
          onmouseenter={(e) => {
            tooltip.visible = true;
            tooltip.content = point.name + ": " + point.total;
            tooltip.x = 0;
            tooltip.y = e.clientY + offsetY;
          }}
          onmousemove={(e) => {
            tooltip.x = e.clientX + offsetX;
            tooltip.y = e.clientY + offsetY;
          }}
          onmouseleave={() => {
            tooltip.visible = false;
          }}
        />
      {/each}
    </g>
  </svg>

  {#if tooltip.visible}
    <div class="tooltip" style="left: {tooltip.x}px; top: {tooltip.y}px;">
      {tooltip.content}
    </div>
  {/if}
</div>

<style>
  .chart {
    width: 100%;
    margin: 0 auto;
  }

  svg {
    position: relative;
    width: 100%;
    height: 350px;
  }

  rect {
    max-width: 51px;
  }

  .tooltip {
    position: absolute;
    background-color: rgba(0, 0, 0, 0.75);
    color: #fff;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    pointer-events: none;
    white-space: nowrap;
    z-index: 10;
  }
</style>
