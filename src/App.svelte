<script>
  import { onMount } from "svelte";
  import { marked } from "marked";
  import { biggestFindings, codeSources, taxCodeMap } from "./taxMapData.js";

  const base = import.meta.env.BASE_URL || "/";
  const reportPath = `${base}outputs/tax-formalization-exploration.md`;
  const sourcePath = "outputs/tax-formalization-exploration.md";

  let markdown = "";
  let status = "loading";
  let error = "";
  let query = "";
  let sortMode = "newest";
  let selectedId = "";
  let selectedMapId = taxCodeMap[0]?.id ?? "";
  let selectedPersonaId = biggestFindings[0]?.id ?? "";
  let lastLoaded = "";
  let autoRefresh = true;

  const highestImpactFindingIds = [
    "2",
    "3",
    "6",
    "9",
    "12",
    "15",
    "18",
    "22",
    "29",
    "34",
    "41",
    "48",
    "53",
    "61",
    "67",
    "74",
    "86",
    "95",
    "106",
    "118",
    "129",
    "143",
    "158",
    "176",
    "201",
    "233",
    "287",
    "351",
    "479",
    "611",
  ];
  const highestImpactRank = new Map(highestImpactFindingIds.map((id, index) => [id, index]));

  marked.setOptions({
    gfm: true,
    breaks: false,
  });

  function parseFindings(text) {
    const matches = Array.from(text.matchAll(/^###\s+(\d+)\.\s+(.+)$/gm));
    return matches
      .map((match, index) => {
        const start = match.index ?? 0;
        const end = matches[index + 1]?.index ?? text.length;
        const block = text.slice(start, end).trim();
        const title = match[2].trim();
        const model = block.match(/Model:\s+`([^`]+)`/)?.[1] ?? "No model recorded";
        const invariant =
          block.match(/Expected invariant:\s*\n-\s+([^\n]+)/)?.[1] ??
          "Invariant not isolated";
        const observed = Array.from(block.matchAll(/-\s+`?([^`\n=]+)\s*=\s*([^`\n]+)`?/g))
          .slice(0, 3)
          .map((item) => `${item[1].trim()} = ${item[2].trim()}`);

        return {
          id: match[1],
          number: Number(match[1]),
          title,
          block,
          model,
          invariant,
          observed,
        };
      });
  }

  function sortFindings(list, mode) {
    const sorted = [...list];

    if (mode === "oldest") {
      return sorted.sort((a, b) => a.number - b.number);
    }

    if (mode === "highest-impact") {
      return sorted.sort((a, b) => {
        const rankA = highestImpactRank.get(a.id);
        const rankB = highestImpactRank.get(b.id);
        const hasRankA = rankA !== undefined;
        const hasRankB = rankB !== undefined;

        if (hasRankA && hasRankB) return rankA - rankB;
        if (hasRankA) return -1;
        if (hasRankB) return 1;
        return b.number - a.number;
      });
    }

    return sorted.sort((a, b) => b.number - a.number);
  }

  async function loadReport() {
    try {
      status = markdown ? "refreshing" : "loading";
      const response = await fetch(reportPath, {
        cache: "no-store",
      });

      if (!response.ok) {
        throw new Error(`Report request failed (${response.status})`);
      }

      markdown = await response.text();
      lastLoaded = new Date().toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
      });
      status = "ready";
      error = "";
    } catch (err) {
      status = "error";
      error = err instanceof Error ? err.message : "Unknown report load error";
    }
  }

  function sectionFamily(title) {
    if (/approval|consent|secretary/i.test(title)) return "Gate";
    if (/deadline|period|year|timing|annual/i.test(title)) return "Timing";
    if (/contribution|funding|limit|restriction/i.test(title)) return "Limits";
    return "Classification";
  }

  function countCoverage(sections, list) {
    return list.filter((finding) =>
      sections.some((section) => new RegExp(`\\b${section}\\b`).test(finding.title)),
    ).length;
  }

  $: findings = parseFindings(markdown);
  $: modelCount = (markdown.match(/^Model:/gm) ?? []).length;
  $: searchedFindings = findings.filter((finding) => {
    const haystack = `${finding.id} ${finding.title} ${finding.model}`.toLowerCase();
    return haystack.includes(query.trim().toLowerCase());
  });
  $: filteredFindings = sortFindings(searchedFindings, sortMode);
  $: if (findings.length && !findings.some((finding) => finding.id === selectedId)) {
    selectedId = findings[0].id;
  }
  $: selected =
    filteredFindings.find((finding) => finding.id === selectedId) ??
    filteredFindings[0] ??
    findings[0];
  $: selectedMap =
    taxCodeMap.find((item) => item.id === selectedMapId) ?? taxCodeMap[0];
  $: selectedPersona =
    biggestFindings.find((item) => item.id === selectedPersonaId) ?? biggestFindings[0];
  $: rendered = selected ? marked.parse(selected.block) : "";
  $: latest = sortFindings(findings, "newest").slice(0, 4);
  $: mappedActiveGaps = taxCodeMap.reduce(
    (total, item) => total + countCoverage(item.sections, findings),
    0,
  );

  onMount(() => {
    loadReport();
    const interval = window.setInterval(() => {
      if (autoRefresh) loadReport();
    }, 120000);
    return () => window.clearInterval(interval);
  });
</script>

<svelte:head>
  <title>Tax Gap Audit | Formalized Findings</title>
</svelte:head>

<a class="skip-link" href="#findings">Skip to findings</a>

<div class="usa-banner">
  <span class="flag-mark" aria-hidden="true"></span>
  <span>Public research site for model-checked tax-code findings</span>
  <a href={sourcePath}>Source markdown</a>
</div>

<header class="masthead">
  <nav aria-label="Primary">
    <a href="#findings">Findings</a>
    <a href="#tax-map">Tax code map</a>
    <a href="#biggest-findings">Biggest findings</a>
    <a href="#method">Method</a>
    <button type="button" on:click={loadReport}>Refresh</button>
  </nav>

  <section class="hero" aria-labelledby="page-title">
    <div>
      <p class="kicker">U.S. Tax Formalization</p>
      <h1 id="page-title">Tax Code Gaps</h1>
      <p class="lede">
        A formal audit of federal tax rules, mapped from raw counterexamples
        into practical exposure zones.
      </p>
    </div>

    <div class="casefile" aria-label="Report snapshot">
      <div class="casefile-top">
        <span>Report state</span>
        <strong>{status === "ready" ? "Manual" : status}</strong>
      </div>
      <div class="casefile-number">{findings.length.toLocaleString()}</div>
      <div class="casefile-label">parsed findings</div>
      <div class="casefile-grid">
        <span>{modelCount.toLocaleString()} models</span>
        <span>{mappedActiveGaps.toLocaleString()} mapped hits</span>
      </div>
    </div>
  </section>
</header>

<main id="findings">

  <section class="search-band" aria-label="Finding controls">
    <label class="search-control">
      <span>Search report</span>
      <input
        bind:value={query}
        type="search"
        placeholder="section, model, or gap name"
        autocomplete="off"
      />
    </label>
    <div class="finding-controls">
      <label class="sort-control">
        <span>Sort findings</span>
        <select bind:value={sortMode}>
          <option value="newest">Newest</option>
          <option value="oldest">Oldest</option>
          <option value="highest-impact">Highest impact</option>
        </select>
      </label>

      <label class="refresh-toggle">
        <input type="checkbox" bind:checked={autoRefresh} />
        <span>Auto refresh</span>
      </label>
    </div>
  </section>

  {#if status === "error"}
    <section class="error-panel" role="alert">
      <strong>Report unavailable.</strong>
      <span>{error}</span>
    </section>
  {/if}

  <section class="report-grid">
    <aside class="finding-list" aria-label="Parsed findings">
      <div class="list-heading">
        <span>Latest findings</span>
        <strong>{filteredFindings.length.toLocaleString()}</strong>
      </div>

      {#each filteredFindings as finding}
        <button
          type="button"
          class:selected={selected?.id === finding.id}
          on:click={() => (selectedId = finding.id)}
        >
          <span class="section-tag">#{finding.id}</span>
          <span>{finding.title}</span>
          <small>{sectionFamily(finding.title)} rule</small>
        </button>
      {/each}
    </aside>

    <article class="finding-detail" aria-live="polite">
      {#if selected}
        <div class="detail-toolbar">
          <span class="section-tag">Section {selected.id}</span>
          <span>{selected.model}</span>
        </div>

        <div class="finding-summary">
          <h2>{selected.title}</h2>
          <p>{selected.invariant}</p>
          <div class="observed-row">
            {#each selected.observed as item}
              <span>{item}</span>
            {/each}
          </div>
        </div>

        <div class="markdown-body">
          {@html rendered}
        </div>
      {:else}
        <div class="empty-state">No matching findings.</div>
      {/if}
    </article>
  </section>

  <section class="latest-strip" aria-label="Recent entries">
    {#each latest as finding}
      <a href="#findings" on:click={() => (selectedId = finding.id)}>
        <strong>{finding.id}</strong>
        <span>{finding.title}</span>
      </a>
    {/each}
  </section>

  <section class="tax-map" id="tax-map" aria-labelledby="tax-map-title">
    <div class="section-head">
      <p class="kicker">Tax code map</p>
      <h2 id="tax-map-title">Where the audit thinks the pressure lives.</h2>
      <p>
        Active gaps come from the parsed report. Candidate gaps are next-pass
        formalization targets pulled from statute and IRS guidance surfaces.
      </p>
    </div>

    <div class="map-layout">
      <div class="map-list" aria-label="Tax code regions">
        {#each taxCodeMap as item}
          <button
            type="button"
            class:selected={selectedMap?.id === item.id}
            on:click={() => (selectedMapId = item.id)}
          >
            <span>{item.label}</span>
            <strong>{countCoverage(item.sections, findings)}</strong>
            <small>{item.status}</small>
          </button>
        {/each}
      </div>

      <article class="map-detail">
        <div class="code-row" aria-label="Relevant code sections">
          {#each selectedMap.sections as section}
            <span>§ {section}</span>
          {/each}
        </div>
        <h3>{selectedMap.label}</h3>
        <p class="map-posture">{selectedMap.posture}</p>
        <dl>
          <div>
            <dt>Formalization target</dt>
            <dd>{selectedMap.formalization}</dd>
          </div>
          <div>
            <dt>Gap pattern</dt>
            <dd>{selectedMap.gapPattern}</dd>
          </div>
          <div>
            <dt>People affected</dt>
            <dd>{selectedMap.people.join(", ")}</dd>
          </div>
        </dl>
        <a class="source-link" href={selectedMap.source}>Primary reference</a>
      </article>
    </div>
  </section>

  <section
    class="biggest-findings"
    id="biggest-findings"
    aria-labelledby="biggest-title"
  >
    <div class="section-head">
      <p class="kicker">Biggest findings</p>
      <h2 id="biggest-title">Who could benefit, and where the model should bite.</h2>
      <p>
        These are compliance-framed readings of high-leverage loophole surfaces:
        what a taxpayer type might legally try, and what a formal checker should
        require before allowing the benefit.
      </p>
    </div>

    <div class="persona-layout">
      <div class="persona-tabs" aria-label="Taxpayer personas">
        {#each biggestFindings as finding}
          <button
            type="button"
            class:selected={selectedPersona?.id === finding.id}
            on:click={() => (selectedPersonaId = finding.id)}
          >
            {finding.persona}
          </button>
        {/each}
      </div>

      <article class="persona-detail">
        <div class="code-row">
          {#each selectedPersona.sections as section}
            <span>§ {section}</span>
          {/each}
        </div>
        <h3>{selectedPersona.persona}</h3>
        <p class="persona-hook">{selectedPersona.hook}</p>
        <div class="persona-grid">
          <section>
            <span>How it is used</span>
            <p>{selectedPersona.advantage}</p>
          </section>
          <section>
            <span>What to formalize</span>
            <p>{selectedPersona.formalizationTarget}</p>
          </section>
          <section>
            <span>Compliance tripwire</span>
            <p>{selectedPersona.guardrail}</p>
          </section>
        </div>
      </article>
    </div>
  </section>

  <section class="method-band" id="method">
    <div>
      <p class="kicker">Method</p>
      <h2>State machines first, prose second.</h2>
    </div>
    <p>
      Each verified entry names the statute, a minimal model, the invariant
      expected by the rule, and the counterexample state that violates it.
      Candidate entries are kept visibly separate until checked.
    </p>
  </section>

  <section class="sources-band" aria-label="Code references">
    <span>References used for the new map</span>
    <div>
      {#each codeSources as source}
        <a href={source.url}>{source.label}</a>
      {/each}
    </div>
  </section>
</main>

<footer>
  <span>Tax Formalization Gap Audit</span>
  <a href="https://github.com/EricSpencer00/tax-formalization-gap-audit-site">
    GitHub repository
  </a>
</footer>
