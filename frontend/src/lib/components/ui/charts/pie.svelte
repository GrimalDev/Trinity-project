<script lang="ts">
  import { pie, arc, type PieArcDatum } from "d3-shape";
  import { scaleOrdinal } from "d3-scale";

  interface PieDataItem {
    category: string;
    value: number;
  }

  const data: PieDataItem[] = [
    { category: "Fruits", value: 40 },
    { category: "Meat", value: 25 },
    { category: "Vegetables", value: 38 },
    { category: "Drinks", value: 65 },
    { category: "Snacks", value: 25 },
  ];

  // Pie generator with TypeScript types
  const pieGenerator = pie<PieDataItem>()
    .value((d) => d.value)
    .sort(null);

  // Arc generator with TypeScript types
  const arcGenerator = arc<PieArcDatum<PieDataItem>>()
    .innerRadius(0)
    .outerRadius(130);

  // Color scale with explicit types
  const colorScale = scaleOrdinal<string, string>()
    .domain(data.map((d) => d.category))
    .range(["#FFFFFF", "#D0D0D0", "#A0A0A0", "#707070", "#404040"]);

  $: pieData = pieGenerator(data);
</script>

<svg class="h-full w-full">
  <g class="translate-x-[50%] translate-y-[50%]">
    {#each pieData as slice}
      <path
        d={arcGenerator(slice) ?? undefined}
        fill={colorScale(slice.data.category)}
        stroke="#08090A"
        stroke-width="6"
      />
      <text
        transform={`translate(${arcGenerator.centroid(slice)})`}
        text-anchor="middle"
        font-size="13"
        font-weight="bold"
        fill="black"
      >
        {slice.data.category}
      </text>
    {/each}
  </g>
</svg>
