# Tax Formalization Gap Audit

This repository publishes a public Vite/Svelte site for a formal audit of U.S.
tax-code rules.

## Live doc

The main page renders:

- `src/App.svelte` for the searchable findings interface
- `src/taxMapData.js` for the tax-code map and persona impact summaries
- `outputs/tax-formalization-exploration.md` for verified findings

## Editorial stance

Verified findings and candidate targets are intentionally separate.

- Verified findings come from the Markdown report and include model names,
  expected invariants, and counterexample states.
- Candidate map entries identify high-leverage parts of the code that should be
  formalized next.
- Persona summaries explain the legal planning surface and the compliance
  tripwire a checker should enforce. They are not tax advice or instructions to
  evade tax.

## How the report updates

`outputs/tax-formalization-exploration.md` is the canonical verified report.
Update it only when a model/check result is accepted.

During `npm run build`, `scripts/sync-report.mjs` copies the current report into
`public/outputs/`, and Vite publishes that copy into `dist/`.

The website fetches the built markdown with `cache: "no-store"`, applies the
curated manifest from `outputs/featured-formalizations.json`, and refreshes the
page data every two minutes while the tab is open.

## Local development

```bash
npm ci
npm run dev
```

## Autonomous DeepSeek loop

`.github/workflows/deepseek-loop.yml` runs every hour and can also be
started manually from the Actions tab. It requires a repository secret named
`DEEPSEEK_API_KEY`.

Each run writes tracked bot state:

- `outputs/deepseek-bot/latest.json`
- `outputs/deepseek-bot/autonomous-loop.log.jsonl`
- `outputs/loop-checkpoint.md`

The workflow commits those files as `DeepSeek Loop Bot`, builds the Svelte site,
and deploys GitHub Pages from the same workflow run.

Each scheduled wake runs a five-step planner burst by default. The loop keeps a
planning cursor from the report, latest bot state, and append-only bot log so it
does not keep rediscovering the same next section. It also passes recent planned
gap titles into each model turn so a burst does not spend every turn on the same
statute pattern.

The repo also publishes a smaller TLA+ surface area by default:

- `outputs/featured-formalizations.json` defines the curated model set.
- Only those `work/*.tla` and matching `work/*.cfg` files are staged for
  publish.
- The public site filters the report to that set, which keeps the displayed data
  points focused on the strongest formalizations.

## OpenClaw loop formalization

The reusable product contract is captured in:

- `outputs/openclaw-loop-formalization.md`
- `outputs/openclaw-loop-contract.json`

The current repo is `PlanOnlyBurst`; the OpenClaw target loop is
`Plan -> Generate -> Verify -> Commit -> Publish -> Watch`.

## Deploy

The repository includes a GitHub Pages workflow:

- `.github/workflows/gh-pages.yml`

Every push to `main` runs `npm ci`, `npm run build`, and deploys `dist/`.
