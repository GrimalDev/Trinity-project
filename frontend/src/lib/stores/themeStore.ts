import { writable } from "svelte/store";
import { browser } from "$app/environment";

const initialTheme = browser
  ? localStorage.getItem("theme-mode") || "dark"
  : "dark";
export const theme = writable(initialTheme);
