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

The website fetches the built markdown with `cache: "no-store"` and refreshes
the page data every two minutes while the tab is open.

## Local development

```bash
npm ci
npm run dev
```

## Deploy

The repository includes a GitHub Pages workflow:

- `.github/workflows/gh-pages.yml`

Every push to `main` runs `npm ci`, `npm run build`, and deploys `dist/`.
