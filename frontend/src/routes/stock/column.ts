import type { ColumnDef } from "@tanstack/table-core";
import { renderComponent } from "$lib/components/ui/data-table/index.js";
import DataTableActions from "./data-table-actions.svelte";
import ProductImage from "./product-image.svelte";
import type { StockItem } from "$lib/types/product";

// Définition des colonnes du tableau de données
export const columns: ColumnDef<StockItem>[] = [
  {
    accessorKey: "images",
    header: "Image",
    cell: ({ row }) => {
      return renderComponent(ProductImage, {
        imageUrl: row.original.images?.S,
      });
    },
    enableSorting: false,
  },
  {
    accessorKey: "name",
    header: "Nom",
    filterFn: (row, columnId, value) => {
      const rowValue = removeAccents(
        row.getValue(columnId) || "",
      ).toLowerCase();
      const filterValue = removeAccents(value || "").toLowerCase();
      return rowValue.includes(filterValue);
    },
  },
  //{
  //  accessorKey: "reference",
  //  header: "Référence",
  //},
  {
    accessorKey: "price_vat",
    header: "Prix (€)",
    cell: ({ getValue }) => `€${getValue<number>()?.toFixed(2)}`,
    filterFn: flexibleNumericFilterFn,
  },
  { accessorKey: "brand", header: "Marque" },
  { accessorKey: "category", header: "Catégorie" },
  {
    accessorKey: "nutritional_information",
    header: "Informations",
  },
  {
    accessorKey: "stock_quantity",
    header: "Quantité",
    filterFn: flexibleNumericFilterFn,
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => {
      return renderComponent(DataTableActions, {
        id: row.original.id,
        product: row.original,
      });
    },
  },
];

// Fonction pour supprimer les accents d'une chaîne de caractères
function removeAccents(str: string): string {
  return str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
}

// Fonction pour filtrer les données numériques
function flexibleNumericFilterFn(
  row: { getValue: (columnId: string) => number },
  columnId: string,
  filterValue: string,
): boolean {
  const value = row.getValue(columnId);
  const filter = filterValue.trim();

  return value.toString().includes(filter);
}
