import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

export default defineConfig(({ command }) => ({
  base: command === "build" ? "/tax-formalization-gap-audit-site/" : "/",
  plugins: [svelte()],
}));
