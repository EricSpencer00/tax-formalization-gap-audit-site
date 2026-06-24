export const taxCodeMap = [
  {
    id: "income-timing",
    label: "Income timing",
    sections: ["441", "442", "443", "446", "451", "461"],
    status: "Active gaps",
    posture: "when income, deductions, years, and method changes become locked",
    formalization:
      "Model taxable-year state, method-change consent, all-events tests, and recurring-item exceptions as one clock rather than isolated rules.",
    gapPattern:
      "A state machine can mark a return as filed or a method as effective before the approval, consistency, or timing predicate is true.",
    people: ["common filers", "small businesses", "realtors", "campaign committees"],
    source: "https://www.law.cornell.edu/uscode/text/26/446",
  },
  {
    id: "property-capital",
    label: "Property and capital gain",
    sections: ["121", "1031", "1221", "1231", "1245", "1250"],
    status: "Candidate gaps",
    posture: "basis, holding purpose, character conversion, and gain deferral",
    formalization:
      "Track property use, basis adjustments, replacement-property deadlines, depreciation recapture, and home-sale exclusions as dependent states.",
    gapPattern:
      "A taxpayer can appear to satisfy a deferral or exclusion rule while a buried basis, use, or recapture state is missing.",
    people: ["realtors", "landlords", "common filers", "family offices"],
    source: "https://www.irs.gov/publications/p544",
  },
  {
    id: "business-entity",
    label: "Business entity filters",
    sections: ["162", "163(j)", "199A", "267", "707", "1402"],
    status: "Candidate gaps",
    posture: "who is a business, employee, partner, related party, or self-employed taxpayer",
    formalization:
      "Represent entity classification, wage status, related-party disallowance, business-interest limits, QBI eligibility, and self-employment tax together.",
    gapPattern:
      "An entity can shift labels across rules: employee for one gate, owner for another, unrelated for timing, related for economics.",
    people: ["common filers", "consultants", "politicians", "closely held businesses"],
    source: "https://www.irs.gov/newsroom/qualified-business-income-deduction",
  },
  {
    id: "passive-loss",
    label: "Passive loss and real estate",
    sections: ["469", "465", "280A", "163(h)", "1411"],
    status: "Candidate gaps",
    posture: "material participation, rental status, at-risk basis, personal use, and NIIT",
    formalization:
      "Combine rental classification, participation hours, grouping elections, at-risk amounts, personal-use days, and investment-income tax.",
    gapPattern:
      "A rental activity can move between passive and non-passive treatment without preserving the facts that justified the move.",
    people: ["realtors", "landlords", "common filers", "high-income households"],
    source: "https://www.irs.gov/publications/p925",
  },
  {
    id: "international",
    label: "International and withholding",
    sections: ["871", "881", "1441", "1442", "482", "951A", "1291"],
    status: "Candidate gaps",
    posture: "source, residence, control, withholding, treaties, and anti-deferral regimes",
    formalization:
      "Model residency, source, beneficial ownership, withholding-agent knowledge, controlled-party pricing, GILTI, and PFIC transitions.",
    gapPattern:
      "Income can be routed through a status or treaty state before withholding, transfer-pricing, or anti-deferral checks fire.",
    people: ["foreign nationals", "multinationals", "platform workers", "politically connected entities"],
    source: "https://www.irs.gov/individuals/international-taxpayers/nra-withholding",
  },
  {
    id: "anti-abuse",
    label: "Anti-abuse overlays",
    sections: ["269", "482", "6662", "7701(o)", "7874"],
    status: "Candidate gaps",
    posture: "business purpose, economic substance, penalties, allocation power, and inversions",
    formalization:
      "Treat anti-abuse doctrines as global invariants that can veto otherwise literal rule satisfaction.",
    gapPattern:
      "A transaction can pass each local rule while failing a global purpose, control, or substance test.",
    people: ["politicians", "family offices", "foreign nationals", "multinationals"],
    source: "https://www.law.cornell.edu/uscode/text/26/7701",
  },
];

export const biggestFindings = [
  {
    id: "realtors",
    persona: "Realtors and landlords",
    hook: "The real estate stack has the most reusable timing machinery.",
    sections: ["1031", "121", "469", "280A", "1250"],
    advantage:
      "The legal planning surface is deferral and character management: exchange gain into qualifying replacement real property, separate rental from personal use, and prove participation where the passive-loss rules demand it.",
    formalizationTarget:
      "A single model should require property purpose, personal-use days, replacement deadlines, boot, depreciation recapture, activity grouping, and material participation to agree before a tax benefit becomes available.",
    guardrail:
      "This is not a free-money path. Missing a deadline, taking proceeds, overusing a vacation home, or failing participation proof should flip the benefit off.",
  },
  {
    id: "common-filers",
    persona: "Common filers",
    hook: "The ordinary-person gaps are usually classification gaps.",
    sections: ["121", "162", "199A", "280A", "461"],
    advantage:
      "The planning surface is whether an activity is personal, business, rental, or investment. Small changes in documentation and use can move deductions, exclusions, or timing between buckets.",
    formalizationTarget:
      "Model personal-use facts, business-purpose facts, substantiation, QBI trade-or-business status, and expense timing as shared predicates instead of isolated checklist items.",
    guardrail:
      "A formal model should refuse benefits when the same facts are personal for one rule and business for another without an explicit transition.",
  },
  {
    id: "politicians",
    persona: "Politicians and campaign-adjacent actors",
    hook: "The risk is not one magic deduction, it is boundary confusion.",
    sections: ["162", "274", "4958", "527", "7701(o)"],
    advantage:
      "The exposure surface is converting reputation, travel, events, media, or nonprofit/campaign adjacency into business-like expenses while the personal or political benefit remains unresolved.",
    formalizationTarget:
      "Represent payer, beneficiary, public office, campaign purpose, personal benefit, business purpose, and excess-benefit constraints in the same graph.",
    guardrail:
      "The site should describe where a reviewer would challenge the structure, not provide a recipe for disguising personal or campaign costs.",
  },
  {
    id: "foreign-nationals",
    persona: "Foreign nationals and cross-border owners",
    hook: "Residency and source rules create high-leverage routing states.",
    sections: ["871", "881", "1441", "1442", "482", "1291"],
    advantage:
      "The planning surface is treaty status, U.S.-source classification, effectively connected income, withholding certificates, controlled pricing, and anti-deferral classification.",
    formalizationTarget:
      "Model residence, beneficial ownership, source, treaty claim, withholding-agent knowledge, control, and entity classification before payment state changes.",
    guardrail:
      "The model should flag missing documentation and mismatched ownership, not suggest hiding source, residence, control, or beneficial ownership.",
  },
  {
    id: "founders",
    persona: "Founders and investors",
    hook: "QSBS is a giant benefit with a tiny eligibility doorway.",
    sections: ["1202", "1045", "368", "351", "83"],
    advantage:
      "The legal planning surface is stock issuance, holding period, eligible corporation status, active-business assets, rollover timing, and equity-compensation treatment.",
    formalizationTarget:
      "Track original issuance, holder type, gross assets, excluded businesses, redemption history, active-business percentage, and holding period as persistent states.",
    guardrail:
      "The benefit should fail closed when stock is not original issue, the business is excluded, redemptions taint issuance, or the holding-period state is broken.",
  },
  {
    id: "multinationals",
    persona: "Multinationals and family offices",
    hook: "The biggest gaps sit between local compliance and global economics.",
    sections: ["482", "951A", "59A", "163(j)", "7701(o)", "7874"],
    advantage:
      "The planning surface is where profits, debt, intangibles, services, and ownership are recognized versus where the economic activity actually sits.",
    formalizationTarget:
      "Connect controlled-party pricing, debt limits, anti-base-erosion rules, economic substance, and inversion tests so local passes cannot hide global failure.",
    guardrail:
      "The model should spotlight inconsistency between paper allocation and economic activity rather than describe concealment tactics.",
  },
];

export const codeSources = [
  {
    label: "IRC section 446",
    url: "https://www.law.cornell.edu/uscode/text/26/446",
  },
  {
    label: "IRS Publication 544",
    url: "https://www.irs.gov/publications/p544",
  },
  {
    label: "IRS Publication 925",
    url: "https://www.irs.gov/publications/p925",
  },
  {
    label: "IRS QBI overview",
    url: "https://www.irs.gov/newsroom/qualified-business-income-deduction",
  },
  {
    label: "IRS NRA withholding",
    url: "https://www.irs.gov/individuals/international-taxpayers/nra-withholding",
  },
  {
    label: "IRC section 7701(o)",
    url: "https://www.law.cornell.edu/uscode/text/26/7701",
  },
];
