import { copyFileSync, existsSync, mkdirSync, statSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

const source = "outputs/tax-formalization-exploration.md";
const target = "public/outputs/tax-formalization-exploration.md";
const manifest = "public/data/report-manifest.json";
const featuredSource = "outputs/featured-formalizations.json";
const featuredTarget = "public/data/featured-formalizations.json";
const botPlanSource = "outputs/deepseek-bot/latest.json";
const botPlanTarget = "public/outputs/deepseek-bot/latest.json";

mkdirSync(dirname(target), { recursive: true });
mkdirSync(dirname(manifest), { recursive: true });
copyFileSync(source, target);

const featuredCopied = existsSync(featuredSource);
if (featuredCopied) {
  mkdirSync(dirname(featuredTarget), { recursive: true });
  copyFileSync(featuredSource, featuredTarget);
}

if (existsSync(botPlanSource)) {
  mkdirSync(dirname(botPlanTarget), { recursive: true });
  copyFileSync(botPlanSource, botPlanTarget);
}

const stats = statSync(source);
writeFileSync(
  manifest,
  JSON.stringify(
    {
      source,
      target,
      featuredCopied,
      featuredSource,
      featuredTarget,
      botPlanCopied: existsSync(botPlanSource),
      bytes: stats.size,
      syncedAt: new Date().toISOString(),
    },
    null,
    2,
  ),
);
