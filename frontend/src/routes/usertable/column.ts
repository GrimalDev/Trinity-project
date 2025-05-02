import type { ColumnDef } from "@tanstack/table-core";
import { renderComponent } from "$lib/components/ui/data-table/index.js";
import DataTableActions from "./data-table-actions.svelte";
import StatusCheckbox from "./status-checkbox.svelte";

// Définition du type pour les utilisateurs
export type UserItem = {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  archived: boolean;
  spent: number;
  roles: [{ name: string }];
};

// Définition des colonnes du tableau de données
export const columns: ColumnDef<UserItem>[] = [
  {
    accessorFn: (row) => `${row.firstName} ${row.lastName}`,
    header: "Utilisateur",
  },
  {
    accessorKey: "email",
    header: "Email",
  },
  {
    accessorKey: "status",
    header: "Archivé",
    cell: ({ row }) =>
      renderComponent(StatusCheckbox, {
        email: row.original.email,
        status: row.original.archived,
      }), // 🔥 Utilisation du composant pour éviter le problème
    enableSorting: false,
  },
  {
    accessorFn: (row) => `${row.roles[0].name}`,
    header: "Role",
  },
  {
    id: "add",
    header: "Add",
    cell: ({ row }) =>
      renderComponent(DataTableActions, { id: row.original.id }),
  },
];
