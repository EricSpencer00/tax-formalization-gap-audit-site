import { copyFileSync, mkdirSync, statSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

const source = "outputs/tax-formalization-exploration.md";
const target = "public/outputs/tax-formalization-exploration.md";
const manifest = "public/data/report-manifest.json";

mkdirSync(dirname(target), { recursive: true });
mkdirSync(dirname(manifest), { recursive: true });
copyFileSync(source, target);

const stats = statSync(source);
writeFileSync(
  manifest,
  JSON.stringify(
    {
      source,
      target,
      bytes: stats.size,
      syncedAt: new Date().toISOString(),
    },
    null,
    2,
  ),
);
