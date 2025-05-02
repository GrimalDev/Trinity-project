import { defineConfig } from "vitest/config";
import { sveltekit } from "@sveltejs/kit/vite";

export default defineConfig({
  plugins: [sveltekit()],
  server: {
    proxy: {
      "/api": {
        target: "http://backend:8080", // your backend API URL
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ""), // Remove `/api` prefix from the request path
      },
    },
    watch: {
      usePolling: true,
    },
  },
  test: {
    include: ["src/**/*.{test,spec}.{js,ts}"],
  },
});
