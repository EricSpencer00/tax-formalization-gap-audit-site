# U.S. Tax Code Formalization Exploration

## What already exists

### Machine-readable source text

1. [OLRC / U.S. Code Title 26 downloads](https://uscode.house.gov/download/download.shtml)
   - Official-ish codified Title 26 in XML, XHTML, PDF, and PCC.
   - Best starting point for the statute itself.

2. [GovInfo U.S. Code collection](https://www.govinfo.gov/app/collection/uscode)
   - Official bulk/code access with historical editions and metadata.
   - Good for release-point tracking and archival comparison.

3. [eCFR Title 26](https://www.ecfr.gov/current/title-26)
   - Regulations matter a lot for tax semantics.
   - Useful if the model needs statute + regulation, not just the Code.

4. [IRS MeF schemas and business rules](https://www.irs.gov/e-file-providers/modernized-e-file-mef-schemas-and-business-rules)
   - Real XML schemas for actual filing rules.
   - This is structured return logic, not the law itself, but it is highly relevant for executable semantics.

5. [IRS Form 990 XML downloads](https://www.irs.gov/charities-non-profits/form-990-series-downloads)
   - A concrete structured tax dataset for nonprofit filings.
   - Narrower than the full tax code, but useful for data-flow and reporting-rule modeling.

6. [IRS instructions and publications XML source files](https://www.irs.gov/instructions-and-publications-xml-source-files)
   - IRS-provided XML/SGML source files for forms, instructions, and publications.
   - Useful as a machine-readable layer for interpretation and filing guidance.

7. [IRS tax statistics and data pages](https://www.irs.gov/statistics)
   - Official statistics and downloadable tables for parts of the U.S. tax system.
   - Not a law corpus, but useful for empirical sanity checks and scope selection.

### Reusable code / source models

1. [IRS-Public/fact-graph](https://github.com/IRS-Public/fact-graph)
   - Production-ready knowledge graph for modeling the Internal Revenue Code and related tax law.
   - This is the strongest reusable source model I found.

2. [IRS-Public/direct-file](https://github.com/IRS-Public/direct-file)
   - Real tax-filing application that incorporates the fact graph and tax-flow logic.
   - Good extraction target for state transitions and business rules.

3. [filedcom/opentax](https://github.com/filedcom/opentax)
   - Open-source U.S. federal tax engine.
   - Useful as an executable oracle for behavior comparisons.

4. Local `work/` + `states/` corpus
   - The repo already contains a large finite dataset of TLA+ models, TLC traces, and state snapshots for tax gaps.
   - This is the cheapest starting point for further exploration because it can be mined before adding new external sources or new models.

### Prior formalization / reasoning work

1. [Catala examples for U.S. tax code](https://github.com/CatalaLang/catala-examples)
   - Clear evidence that parts of the U.S. tax code have already been encoded in an executable legal DSL.
   - Strong reference point for translating law into a formal spec layer.

2. [Coding the Code: Catala and Computationally Accessible Tax Law](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4291177)
   - Tax-specific formalization, focused on executable and readable representations.

3. [A Dataset for Statutory Reasoning in Tax Law Entailment and Question Answering](https://ceur-ws.org/Vol-2645/paper5.pdf)
   - SARA is a tax-law reasoning dataset built from IRC sections and entailment cases.
   - Probably the closest public benchmark-style dataset for symbolic reasoning on U.S. tax law.

4. [Tax Code Analysis Tool 1.0](https://www.rand.org/pubs/tools/TLA4392-1.html)
   - Whole-code graph mapping of Title 26.
   - Very useful for dependency discovery and “what references what” analysis.

5. [Shelter Check / tax abuse dataset](https://ojs.aaai.org/index.php/AAAI/article/view/41165/45126)
   - A newer dataset centered on known tax-minimization strategies.
   - Particularly relevant for loophole hunting and counterexample generation.

6. [DeonticBench](https://github.com/guangyaodou/DeonticBench)
   - Multi-domain benchmark including U.S. federal tax.
   - Useful if we want to compare direct reasoning vs. executable logic encodings.

7. [SARA dataset landing page](https://nlp.jhu.edu/law/sara/)
   - Canonical project page for the tax-law entailment benchmark.
   - Better long-term anchor than the paper PDF alone.

## Best stack to start from

If the goal is “find gaps with TLA+/TLC/Apalache,” the most efficient stack looks like:

1. Title 26 XML from OLRC/GovInfo
2. eCFR Title 26 for regulatory overlays
3. IRS fact graph and Direct File for source semantics and business rules
4. SARA + Shelter Check for benchmarked reasoning failures
5. Catala examples and Catala papers for a pre-existing executable formalization style
6. RAND CAT for graph/dependency mapping

That gives us:
- source text
- regulatory context
- examples of already-formalized tax logic
- benchmark cases where reasoning fails
- a dependency graph for traversal

## Where the likely gaps are

These are the highest-value areas for semantic reasoning and model checking because they depend on identity, timing, or role boundaries:

1. Beneficial ownership and withholding chains
   - Gap type: who economically owns the income versus who the paperwork names.
   - Good invariant to test: one payment path should not produce two inconsistent ownership interpretations.

2. Dividend-like / derivative dividend treatment
   - Gap type: synthetic exposure vs. legal ownership.
   - Good invariant to test: one economic dividend event should not map to multiple contradictory withholding outcomes.

3. Wash sales / replacement positions
   - Gap type: temporal window plus semantic equivalence.
   - Good invariant to test: a disallowed loss stays consistently disallowed through basis adjustments.

4. Constructive sale / straddle rules
   - Gap type: legal title stays put while economic risk disappears.
   - Good invariant to test: hedging that functionally exits a position is detected.

5. Partnership basis / disguised-sale sequences
   - Gap type: multiple ledgers that must stay algebraically consistent.
   - Good invariant to test: inside basis, outside basis, and distributions reconcile across every transition.

6. Transfer withholding and foreign partner reporting
   - Gap type: layered withholding, certification, and later crediting.
   - Good invariant to test: withholding collected now matches tax liability later, with no stranded or duplicated credits.

7. Reporting mismatches
   - Gap type: payer, recipient, and withholding systems see different identity facts.
   - Good invariant to test: the same payment cannot be simultaneously classified inconsistently across the reporting stack.

8. Filing schemas vs statutory rules
   - Gap type: XML/business-rule validators capture filing shape, but not always the underlying legal semantics.
   - Good invariant to test: every reportable event has a legal basis and a valid filing representation, but the two layers can still disagree.

## First-pass conclusion

We do not need to start from scratch.

There is already enough machine-readable infrastructure to build a meaningful TLA+ layer:
- official text sources,
- regulatory text,
- source-model code,
- executable tax encodings,
- tax reasoning datasets,
- and a graph-based dependency tool.

The biggest gap is not “missing text.” It is the mismatch between:
- statutory language,
- regulatory overlays,
- reporting forms,
- and economic substance.

That mismatch is exactly where a TLA+ / TLC / Apalache layer could find counterexamples.

## Best next move

Model one narrow abuse-prone slice first, not the whole tax code.

My recommendation is:
1. **Beneficial ownership + withholding + reporting chain**
2. **Dividend / synthetic dividend treatment**
3. **Wash sale / basis preservation**

Those are compact enough to formalize, but rich enough to expose real semantic gaps.

## Current gap frontier

The live repo scan suggests the thinnest areas now are repair and reconciliation chains rather than first-filed return forms:

- `1099-DIV` nominee reporting is modeled, but the corrected-return / nominee-to-real-owner repair path still looks thin.
- `1042-S` and `1042-T` reporting are present, but the corrected / replace / reconcile chain is not as rich as payroll correction coverage.
- The broader `1099` correction cascade is under-modeled compared with the `W-2` / `W-3C` family.
- Beneficial ownership, withholding, and credit assignment are still split across separate models instead of one end-to-end entitlement freeze.
- Dividend-like corporate action flows still leave room for return-of-capital, patronage, and synthetic-equivalent edge cases to slip through.

The first concrete reproduction of that repair gap is now in `work/TaxForm1099DIVNomineeCorrectionGap.tla`, where TLC reaches a corrected filing while the actual owner's copy is still unfurnished.
The same pattern now appears in `work/Tax1042SCorrectionGap.tla`, where a corrected `1042-S` can be filed after the underlying payment changes but the annual `1042` still remains unamended.
The same pattern also appears in `work/TaxForm1099BCorrectionGap.tla`, where a corrected broker statement exists but the downstream `8949` reconciliation state never turns on.
The same pattern now also appears in `work/TaxForm1099DACorrectionGap.tla`, where a corrected digital-asset statement exists but the downstream `8949` reconciliation state never turns on.
The same pattern now also appears in `work/Tax1099MISCCorrectionGap.tla`, where a corrected `1099-MISC` exists but the recipient copy still never gets furnished.
The same pattern now also appears in `work/TaxForm1099NECCorrectionGap.tla`, where a corrected `1099-NEC` exists but the recipient copy still never gets furnished.
The same pattern now also appears in `work/TaxForm1099KCorrectionGap.tla`, where an incorrect `1099-K` can exist without either a corrected issuer form or a zero-out on the return.
The same pattern now also appears in `work/TaxForm1099RCorrectionGap.tla`, where a corrected `1099-R` can arrive after the original return is filed but the amended return still never gets filed.
The same pattern now also appears in `work/TaxForm1099GCorrectionGap.tla`, where a corrected `1099-G` can arrive after the original return is filed but the amended return still never gets filed.
The same pattern now also appears in `work/TaxForm1099SCorrectionGap.tla`, where a corrected `1099-S` can arrive after the original return is filed but the amended return still never gets filed.
The same pattern now also appears in `work/TaxForm1099CCorrectionGap.tla`, where a corrected `1099-C` can arrive after the original return is filed but the amended return still never gets filed.
The same pattern now also appears in `work/TaxForm1099ACorrectionGap.tla`, where a corrected `1099-A` can arrive after the original return is filed but the amended return still never gets filed.
The same pattern now also appears in `work/TaxForm1099QCorrectionGap.tla`, where a corrected `1099-Q` exists but the recipient copy still never gets furnished.
The same pattern now also appears in `work/TaxForm1099SACorrectionGap.tla`, where a corrected `1099-SA` exists but the beneficiary copy still never gets furnished.
The same pattern now also appears in `work/TaxForm1099SBCorrectionGap.tla`, where a rescission notice exists but neither the corrected `1099-SB` nor the corrected statement is forced on the path.
The same pattern now also appears in `work/TaxForm1099LSCorrectionGap.tla`, where a rescission notice exists but neither the corrected `1099-LS` nor the corrected statement is forced on the path.
The same pattern now also appears in `work/TaxForm1099LTCCorrectionGap.tla`, where an error is discovered after filing but the corrected `1099-LTC` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099INTCorrectionGap.tla`, where an interest-reporting error is discovered after filing but the corrected `1099-INT` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099OIDCorrectionGap.tla`, where an original-issue-discount error is discovered after filing but the corrected `1099-OID` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099CAPCorrectionGap.tla`, where a corporate control-change error is discovered after filing but the corrected `1099-CAP` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099DIVCorrectionGap.tla`, where a dividend reporting error is discovered after filing but the corrected `1099-DIV` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099PATRCorrectionGap.tla`, where a patronage-dividend reporting error is discovered after filing but the corrected `1099-PATR` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1099QACorrectionGap.tla`, where an ABLE distribution reporting error is discovered after filing but the corrected `1099-QA` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1095BCorrectionGap.tla`, where a minimum-essential-coverage error is discovered after filing but the corrected `1095-B` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1095CCorrectionGap.tla`, where an employer-coverage error is discovered after filing but the corrected `1095-C` path still does not force the employee copy.
The same pattern now also appears in `work/TaxForm1095ACorrectionGap.tla`, where a Marketplace statement error is discovered after furnishing but the corrected `1095-A` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1098TCorrectionGap.tla`, where a tuition-statement error is discovered after filing but the corrected `1098-T` path still does not force the student copy.
The same pattern now also appears in `work/TaxForm1098FCorrectionGap.tla`, where a fines-and-penalties reporting error is discovered after filing but the corrected `1098-F` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1098QCorrectionGap.tla`, where a QLAC reporting error is discovered after filing but the corrected `1098-Q` path still does not force the recipient copy.
The same pattern now also appears in `work/TaxForm1098CCorrectionGap.tla`, where a vehicle-donation acknowledgment error is discovered after filing but the corrected `1098-C` path still does not force the donor copy.
The same pattern now also appears in `work/TaxForm1098ECorrectionGap.tla`, where a student-loan-interest error is discovered after filing but the corrected `1098-E` path still does not force the borrower copy.
The same pattern now also appears in `work/TaxForm1098MACorrectionGap.tla`, where a mortgage-assistance error is discovered after filing but the corrected `1098-MA` path still does not force the homeowner copy.
The same pattern now also appears in `work/TaxForm1094BCorrectionGap.tla`, where a health-coverage transmittal error is discovered after filing but the corrected `1094-B` path still does not force the transmittal correction.
The same pattern now also appears in `work/TaxForm1094CCorrectionGap.tla`, where an employer-coverage transmittal error is discovered after filing but the corrected `1094-C` path still does not force the transmittal correction.
The same pattern now also appears in `work/TaxForm1098MortgageInterestCorrectionGap.tla`, where a mortgage-interest error is discovered after filing but the corrected `1098` path still does not force the borrower copy.
The same pattern now also appears in `work/TaxForm1098VLICorrectionGap.tla`, where a vehicle-loan-interest error is discovered after filing but the corrected `1098-VLI` path still does not force the borrower copy.
The same pattern now also appears in `work/TaxForm5498SACorrectionGap.tla`, where an HSA statement error is discovered after filing but the corrected `5498-SA` path still does not force the participant copy.
The same pattern now also appears in `work/TaxForm5498QACorrectionGap.tla`, where an ABLE contribution reporting error is discovered after filing but the corrected `5498-QA` path still does not force the beneficiary copy.
The same pattern now also appears in `work/TaxForm8937CorrectionGap.tla`, where a basis-affecting organizational-action notice error is discovered after filing but the corrected `8937` path still does not force the corrected issuer statement.
The same pattern now also appears in `work/TaxForm1042TCorrectionGap.tla`, where corrected paper `1042-S` forms are prepared after an error is discovered but the amended `1042-T` batch still does not become mandatory.
The same pattern now also appears in `work/TaxForm5471CorrectionGap.tla`, where a corrected foreign-corporation information return is prepared after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8865CorrectionGap.tla`, where a corrected foreign partnership information return is prepared after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8858CorrectionGap.tla`, where a corrected foreign branch or FDE information return is prepared after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm5472CorrectionGap.tla`, where a corrected related-party reporting attachment is prepared after an error is discovered but the amended corporate return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8938CorrectionGap.tla`, where a corrected foreign-asset disclosure is attached after an omission is discovered but the amended `1040-X` still does not become mandatory.
The same pattern now also appears in `work/TaxForm3520CorrectionGap.tla`, where a corrected foreign-gift or trust disclosure is prepared after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm3520ACorrectionGap.tla`, where a corrected foreign-trust annual return is prepared after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm926CorrectionGap.tla`, where a corrected foreign-transfer disclosure is attached after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8865K3CorrectionGap.tla`, where a corrected Schedule K-3 is delivered after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8982CorrectionGap.tla`, where a corrected partner-modification affidavit is filed after an error is discovered but the resolution statement still does not become mandatory.
The same pattern now also appears in `work/TaxForm1120SCorrectionGap.tla`, where a corrected S corporation return is filed after an error is discovered but the amended return still does not become mandatory.
The same pattern now also appears in `work/TaxForm8997CorrectionGap.tla`, where a corrected QOF investment statement is filed after an error is discovered but the amended return still does not become mandatory.
The foreign-beneficial-owner path still has a semantic hole: `W-8BEN` is modeled as a missing-document problem, but not yet as a wrong-party / nominee-certifier problem, even though the IRS guidance centers the form on the actual beneficial owner.
The FIRPTA certificate path has a similar request-versus-grant seam: `8288-B` is modeled as an application problem, but not yet as a grant-versus-use problem where reduced withholding is applied before the certificate is actually issued.
The 1446(f) partner-statement path still has a zero-withholding seam: `Form 8805` is modeled as a withholding-triggered statement, but not yet as a statement that must be delivered even when no withholding tax is actually paid.
The 8804-C path still has an effectiveness seam: `Form 8804-C` is modeled as a certificate-submission problem, but not yet as a requirement that the partnership actually reduce withholding once it has considered the certificate.
The 8804-C path also has a defect-knowledge seam: the IRS says a partnership cannot rely on a certificate it knows or has reason to know is incorrect or unreliable, but the local model set still does not force that knowledge to block reduced withholding.
The 8804-C path also has an updated-certificate seam: the IRS says an updated certificate is required when the facts or representations in the original certificate change, but the local model set still does not force an updated certificate before reduced withholding continues.
The 8804-C path also has a supersession seam: the IRS instructions say the most recently submitted certificate should control, but the local model set still does not force the partnership to prefer the updated certificate over the original one.
The 8804-C path also has a timeliness seam: the IRS instructions require updated certificates within 10 days of the change, but the local model set still does not force late certificates to stop driving reduced withholding.
The ITIN path still has a renewal seam: the local W-7 model captures only the initial application state, but not the case where an already-existing ITIN has expired and must be renewed before it can keep supporting returns and credits.
The ITIN path also has a renewal-name-change seam: the instructions require supporting documentation when a renewing applicant's legal name has changed, but the local model set still does not force that documentation to exist before renewal.
The ITIN path also has a renewal-package seam: the instructions say renewal applications must include a U.S. federal tax return unless an exception applies, but the local model set still does not force a return-or-exception state before the renewal form is filed.
The ITIN path also has an information-return-only exception seam: the IRS says an expired ITIN used only on third-party information returns does not need renewal yet, but the local model set still doesn’t distinguish that exception from a filing-required case.
The ITIN path also has a late-exception seam: if the information-return-only exception is recognized after a renewal requirement has already been set, the requirement should clear, but the local model set still does not force that reset.
The Form 5768 path still has a revocation-timing seam: the IRS says the revocation must be postmarked before the first day of the tax year to which it applies, but the local model set still does not force that deadline as a hard gate.

## Tool fit

TLA+ is a good fit here because the target problems are mostly about:
- state transitions,
- timing windows,
- role/identity distinctions,
- and invariants that should hold across all legal paths.

SANY is the front-end parser / semantic checker for TLA+ specs, so it is the right place to catch syntax and some semantic issues before model checking.

TLC is best when we can bound the world to finite domains. Lamport’s guidance is that TLC can check specs when the algorithm manipulates only finite objects in a sensible way, and it explores all reachable states of the finite model.

Apalache is a good companion when we want symbolic bounded checking. Its documented use is bounded model checking / inductive invariant checking over finite data structures, with TLA+ translated into SMT constraints.

That means the first model should use:
- a finite taxpayer set,
- a finite transaction history,
- bounded dates or day indices,
- and explicit flags for ownership, withholding, and reporting status.

## Current workspace status

- A draft TLA+ module and config now exist in `work/TaxGapHunting.tla` and `work/TaxGapHunting.cfg`.
- `java` is available in this environment.
- The TLA+ Toolbox jar is available at `/Applications/TLA+ Toolbox.app/Contents/Eclipse/tla2tools.jar`.
- TLC was run successfully against the draft model.
- TLC found a counterexample in three steps: initial state, `Document(E1)`, then `Report(E1)` choosing `reportedPayee[E1] = Bob` while `owner[E1] = Alice`.
- That is the first concrete semantic gap this loop surfaced: the reporting layer can diverge from ownership once the report action is allowed to pick a different payee.

## Concrete TLC findings

### 1. Reporting mismatch

Model: `work/TaxGapHunting.tla`

Trace:
1. initial state
2. `Document(E1)`
3. `Report(E1)` with `reportedPayee[E1] = Bob` and `owner[E1] = Alice`

Meaning:
- the model permits an inconsistent paper identity even though the economic owner is fixed
- this is the core “paper role vs economic substance” gap

### 2. Treaty claim mismatch

Model: `work/TaxTreatyGap.tla`

Trace:
1. initial state
2. `Document(E1)`
3. `ClaimTreaty(E1)` with `foreignStatus[Alice] = FALSE`

Meaning:
- the model permits a treaty claim even when the owner is domestic
- this is the core “status assertion vs entitlement” gap

The two traces are different enough to matter:
- one is an identity mismatch
- the other is an entitlement mismatch

### 3. Wash-sale basis carryover failure

Model: `work/TaxWashSaleGap.tla`

Trace:
1. initial state
2. `SellAtLoss`
3. `BuyReplacement`

Observed state:
- `soldAtLoss = TRUE`
- `repurchased = TRUE`
- `deferredLoss = 10`
- `replacementBasis = 100`

Expected invariant:
- `replacementBasis = Basis0 + deferredLoss`

Meaning:
- the model allows the replacement lot to keep the old basis even though a disallowed loss exists
- this is the core wash-sale semantic gap: the deferred loss should carry into basis, but the transition does not force it

### 4. Backup withholding failure

Model: `work/TaxBackupWithholdingGap.tla`

Trace:
1. initial state
2. `MakePayment`

Observed state:
- `tinValid = FALSE`
- `paymentMade = TRUE`
- `backupWithholdingApplied = FALSE`
- `withheldAmount = 0`

Expected invariant:
- `paymentMade /\ ~tinValid => backupWithholdingApplied /\ withheldAmount > 0`

Meaning:
- the model permits payment without backup withholding even when the taxpayer ID is invalid
- this is the core payment-level withholding gap

### 5. Constructive sale failure

Model: `work/TaxConstructiveSaleGap.tla`

Trace:
1. initial state
2. `EnterHedge`

Observed state:
- `positionOpen = TRUE`
- `hedgeEntered = TRUE`
- `economicExit = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `economicExit => gainRecognized`

Meaning:
- the model permits an economic exit from the position without gain recognition
- this is the core constructive-sale / straddle gap: the hedge recreates a sale-like outcome without the recognition step

### 6. Partnership disguised-sale failure

Model: `work/TaxPartnershipGap.tla`

Trace:
1. initial state
2. `Contribute`
3. `Distribute`

Observed state:
- `contributionDone = TRUE`
- `distributionDone = TRUE`
- `considerationPaid = TRUE`
- `saleRecognized = FALSE`

Expected invariant:
- `contributionDone /\ distributionDone /\ considerationPaid => saleRecognized`

Meaning:
- the model permits a contribution/distribution sequence with consideration that does not trigger sale recognition
- this is the core disguised-sale gap: the transaction shape can hide a sale-like outcome unless the model forces recognition

### 7. Transfer withholding failure

Model: `work/TaxTransferWithholdingGap.tla`

Trace:
1. initial state
2. `Transfer`

Observed state:
- `foreignPartner = TRUE`
- `transferDone = TRUE`
- `transferWithholdingApplied = FALSE`
- `creditGranted = FALSE`

Expected invariant:
- `transferDone /\ foreignPartner => transferWithholdingApplied`

Meaning:
- the model permits a foreign-partner transfer without forcing withholding
- this is the core transfer-withholding gap: the transfer can complete before withholding is made consistent

### 8. Transfer credit reconciliation failure

Model: `work/TaxTransferCreditGap.tla`

Trace:
1. initial state
2. `Transfer`
3. `GrantCredit`

Observed state:
- `transferDone = TRUE`
- `withholdingApplied = FALSE`
- `creditGranted = TRUE`
- `creditUsed = FALSE`

Expected invariant:
- `creditGranted => withholdingApplied`

Meaning:
- the model permits a tax credit to be granted without a withholding record behind it
- this is the core reconciliation gap: the credit layer can get ahead of the tax-payment layer

### 9. Partnership basis reconciliation failure

Model: `work/TaxPartnershipBasisGap.tla`

Trace:
1. initial state
2. `Contribute`
3. `AllocateIncome`

Observed state:
- `contributionDone = TRUE`
- `incomeAllocated = TRUE`
- `insideBasis = 110`
- `outsideBasis = 100`

Expected invariant:
- `insideBasis = outsideBasis`

Meaning:
- the model allows the inside basis ledger to move while the outside basis ledger stays behind
- this is the core reconciliation gap: partnership accounting can drift unless both sides are updated together

### 10. Intermediary duplication failure

Model: `work/TaxIntermediaryDuplicationGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `ApplyFirstWithholding`
4. `ApplySecondWithholding`

Observed state:
- `paymentMade = TRUE`
- `firstWithholdingApplied = TRUE`
- `secondWithholdingApplied = TRUE`
- `firstCreditGranted = FALSE`
- `secondCreditGranted = FALSE`

Expected invariant:
- `~(firstWithholdingApplied /\ secondWithholdingApplied)`

Meaning:
- the model permits two intermediaries to withhold on the same payment
- this is the core duplication gap: withholding responsibility is not uniquely assigned

### 11. Reporting-form consistency failure

Model: `work/TaxReportingFormGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `Report1099`
4. `Report1042S`

Observed state:
- `paymentMade = TRUE`
- `reportedOn1099 = TRUE`
- `reportedOn1042S = TRUE`
- `formMismatch = TRUE`

Expected invariant:
- `~(reportedOn1099 /\ reportedOn1042S)`

Meaning:
- the model permits the same payment to be reported on both channels
- this is the core reporting-form gap: the payment can appear in incompatible reporting systems at once

### 12. Cross-border certification rate failure

Model: `work/TaxCrossBorderCertGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `FileCertificate`
4. `SetRate`

Observed state:
- `paymentMade = TRUE`
- `foreignPayee = TRUE`
- `certificateFiled = TRUE`
- `certificateValid = FALSE`
- `withholdingRate = 0`

Expected invariant:
- `foreignPayee /\ ~certificateValid => withholdingRate = 30`

Meaning:
- the model permits a filed-but-invalid certificate to zero out withholding
- this is the core cross-border certification gap: rate-setting trusts filing status more than validity

### 13. Deadline penalty timing failure

Model: `work/TaxDeadlinePenaltyGap.tla`

Trace:
1. initial state
2. `FileReturn`
3. `ApplyPenalty`

Observed state:
- `filed = TRUE`
- `currentDay = 0`
- `penaltyApplied = TRUE`

Expected invariant:
- `currentDay <= DueDay => ~penaltyApplied`

Meaning:
- the model permits a penalty before the due day has passed
- this is the core deadline timing gap: an administrative sanction can be applied too early

### 14. Late assessment statute-of-limitations failure

Model: `work/TaxAssessmentSOLGap.tla`

Trace:
1. initial state
2. `AdvanceDay`
3. `AdvanceDay`
4. `Assess`

Observed state:
- `filedDay = 0`
- `currentDay = 2`
- `assessed = TRUE`

Expected invariant:
- `assessed => currentDay <= filedDay + SOLDays`

Meaning:
- the model permits assessment after the limitations window has elapsed
- this is the core SOL gap: the state still allows an action after the statutory clock should have shut it down

### 14.1. Form 872 assessment consent failure

Model: `work/TaxForm872AssessmentConsentGap.tla`

Trace:
1. initial state
2. `PassAssessmentDeadline`
3. `AssessTaxAfterDeadline`

Observed state:
- `statuteExpired = TRUE`
- `form872Signed = FALSE`
- `assessmentMade = TRUE`

Expected invariant:
- `assessmentMade => form872Signed`

Meaning:
- the model lets tax be assessed after the assessment period has expired without any signed Form 872 consent on file
- this is the Form 872 gap: IRS guidance says Form 872 is the consent to extend the time to assess tax, but the state machine allows the late-assessment state to exist without the consent state

### 14.2. Form 872-A improper termination failure

Model: `work/TaxForm872AImproperTerminationGap.tla`

Trace:
1. initial state
2. `TerminateByLetter`

Observed state:
- `openEndedConsentActive = FALSE`
- `form872TFiled = FALSE`
- `terminatedByLetter = TRUE`

Expected invariant:
- `terminatedByLetter => form872TFiled`

Meaning:
- the model lets an open-ended Form 872-A consent be terminated by letter instead of by Form 872-T
- this is the Form 872-A gap: IRS guidance says Form 872-T is the written notice used to terminate the open-ended consent, but the state machine allows an invalid termination path to shut the consent off without the termination form

### 14.3. Form 872-O partnership-item termination failure

Model: `work/TaxForm872OPartnershipTerminationGap.tla`

Trace:
1. initial state
2. `TerminateByLetter`

Observed state:
- `openEndedPartnershipConsentActive = FALSE`
- `form872NFiled = FALSE`
- `terminatedByLetter = TRUE`

Expected invariant:
- `terminatedByLetter => form872NFiled`

Meaning:
- the model lets an open-ended partnership-item consent be terminated by letter instead of by Form 872-N
- this is the Form 872-O gap: IRS guidance says Form 872-N is the written notice used to terminate the open-ended partnership-item consent, but the state machine allows the consent to be shut off without the termination form

### 15. Duplicate refund issuance failure

Model: `work/TaxRefundDuplicationGap.tla`

Trace:
1. initial state
2. `FileReturn`
3. `QueueRefundA`
4. `QueueRefundB`

Observed state:
- `returnFiled = TRUE`
- `refundPathA = TRUE`
- `refundPathB = TRUE`
- `refundPaid = FALSE`

Expected invariant:
- `~(refundPathA /\ refundPathB)`

Meaning:
- the model permits two refund paths to be queued for the same return
- this is the core duplicate-refund gap: one return can be routed into multiple payout channels

### 16. Late-payment interest timing failure

Model: `work/TaxInterestGap.tla`

Trace:
1. initial state
2. `ApplyInterest`

Observed state:
- `currentDay = 0`
- `paid = FALSE`
- `interestApplied = TRUE`

Expected invariant:
- `currentDay <= DueDay => ~interestApplied`

Meaning:
- the model permits interest to be applied immediately, before any due-day boundary has passed
- this is the core interest-accrual gap: the model allows time-based charges too early

### 17. Collection due-process timing failure

Model: `work/TaxCollectionDueProcessGap.tla`

Trace:
1. initial state
2. `SendNotice`
3. `StartCollection`

Observed state:
- `noticeSent = TRUE`
- `currentDay = 0`
- `collectionStarted = TRUE`

Expected invariant:
- `collectionStarted => currentDay >= WaitDays`

Meaning:
- the model permits collection to start before the waiting period has elapsed
- this is the core due-process gap: collection can begin too early relative to the notice gate

### 18. Grantor-trust attribution failure

Model: `work/TaxGrantorTrustGap.tla`

Trace:
1. initial state
2. `CreateReport`

Observed state:
- `trustExists = TRUE`
- `grantorIsOwner = FALSE`
- `trustReportedAsOwner = TRUE`
- `beneficiaryReported = TRUE`
- `attributionCorrect = FALSE`

Expected invariant:
- `trustReportedAsOwner => grantorIsOwner`

Meaning:
- the model permits the trust to be reported as owner even though the grantor is not the owner
- this is the core grantor-trust attribution gap: reported ownership and economic ownership diverge

### 19. Loss carryforward persistence failure

Model: `work/TaxCarryforwardGap.tla`

Trace:
1. initial state
2. `RealizeLoss`
3. `UseCarryforward`

Observed state:
- `lossRealized = TRUE`
- `carryforwardBalance = 0`
- `nextYearUsed = TRUE`
- `carryforwardPreserved = TRUE`

Expected invariant:
- `lossRealized => carryforwardBalance > 0`

Meaning:
- the model permits a realized loss to be consumed without preserving a remaining carryforward balance
- this is the core carryforward gap: the modeled loss disappears too quickly across years

### 20. Worker classification payroll withholding failure

Model: `work/TaxWorkerClassificationGap.tla`

Trace:
1. initial state
2. `PayWorker`
3. `DetermineEmployeeStatus`

Observed state:
- `workerPaid = TRUE`
- `actualEmployee = TRUE`
- `classifiedAsContractor = FALSE`
- `payrollWithholdingApplied = FALSE`

Expected invariant:
- `actualEmployee => payrollWithholdingApplied`

Meaning:
- the model permits a worker to be identified as an employee without payroll withholding
- this is the core worker-classification gap: the status determination arrives without the matching tax treatment

### 21. Duplicate dependent claim failure

Model: `work/TaxDependentClaimGap.tla`

Trace:
1. initial state
2. `ClaimByParentA`
3. `ClaimByParentB`

Observed state:
- `childExists = TRUE`
- `parentAClaims = TRUE`
- `parentBClaims = TRUE`
- `dependentDuplicated = TRUE`

Expected invariant:
- `~(parentAClaims /\ parentBClaims)`

Meaning:
- the model permits both parents to claim the same dependent
- this is the core dependent-claim gap: a single child can be double-claimed in the model

### 22. Payment allocation order failure

Model: `work/TaxPaymentAllocationGap.tla`

Trace:
1. initial state
2. `ApplyToPenalty`

Observed state:
- `taxDue = 10`
- `penaltyDue = 0`
- `interestDue = 5`
- `paymentAppliedToPenalty = TRUE`
- `paymentAppliedToTax = FALSE`

Expected invariant:
- `paymentAppliedToPenalty => paymentAppliedToTax`

Meaning:
- the model permits payment to reduce penalty before tax
- this is the core allocation-order gap: the wrong liability bucket gets paid first

### 23. Late refund claim statute-of-limitations failure

Model: `work/TaxRefundClaimSOLGap.tla`

Trace:
1. initial state
2. `AdvanceDay`
3. `AdvanceDay`
4. `ClaimRefund`

Observed state:
- `filedDay = 0`
- `currentDay = 2`
- `refundClaimed = TRUE`

Expected invariant:
- `refundClaimed => currentDay <= filedDay + SOLDays`

Meaning:
- the model permits a refund claim after the claim window has elapsed
- this is the core refund-SOL gap: the taxpayer-side limitations clock is not enforced in the model

### 24. Lien release timing failure

Model: `work/TaxLienReleaseGap.tla`

Trace:
1. initial state
2. `PayDown`

Observed state:
- `taxBalance = 0`
- `lienFiled = TRUE`
- `lienReleased = FALSE`

Expected invariant:
- `taxBalance = 0 => lienReleased`

Meaning:
- the model permits a lien to remain active after the balance is paid down to zero
- this is the core lien-release gap: enforcement remains attached after the debt is gone

### 25. Foreign account report timing failure

Model: `work/TaxForeignAccountReportGap.tla`

Trace:
1. initial state
2. `AdvanceDay`
3. `AdvanceDay`
4. `FileReport`

Observed state:
- `foreignAccountExists = TRUE`
- `currentDay = 2`
- `reportFiled = TRUE`
- `reportTimely = FALSE`

Expected invariant:
- `reportFiled => reportTimely`

Meaning:
- the model permits a foreign account report to be filed after the due day while still counting as filed
- this is the core foreign-reporting timing gap: the model doesn't force a hard cutoff on the filing window

### 26. Filing extension timing failure

Model: `work/TaxExtensionGap.tla`

Trace:
1. initial state
2. `AdvanceDay`
3. `AdvanceDay`
4. `FileReturn`

Observed state:
- `currentDay = 2`
- `extensionFiled = FALSE`
- `returnFiled = TRUE`
- `returnTimely = FALSE`

Expected invariant:
- `returnFiled => returnTimely`

Meaning:
- the model permits a return to be filed after the due day without a valid timing basis
- this is the core extension gap: filing status is not properly tied to the deadline logic

### 27. Deduction substantiation failure

Model: `work/TaxDeductionSubstantiationGap.tla`

Trace:
1. initial state
2. `PayExpense`
3. `ClaimDeduction`

Observed state:
- `expensePaid = TRUE`
- `receiptObtained = FALSE`
- `deductionClaimed = TRUE`

Expected invariant:
- `deductionClaimed => receiptObtained`

Meaning:
- the model permits a deduction to be claimed without substantiating receipt
- this is the core substantiation gap: the expense exists, but the proof requirement does not

### 28. Refund offset failure

Model: `work/TaxRefundOffsetGap.tla`

Trace:
1. initial state
2. `PayRefund`

Observed state:
- `refundDue = 10`
- `debtOutstanding = 5`
- `offsetApplied = FALSE`
- `refundPaid = TRUE`

Expected invariant:
- `refundPaid => offsetApplied \/ debtOutstanding = 0`

Meaning:
- the model permits a refund to be paid without first offsetting an outstanding debt
- this is the core refund-offset gap: the refund bypasses the intercept bucket

### 29. Joint return liability allocation failure

Model: `work/TaxJointReturnGap.tla`

Trace:
1. initial state
2. `FileJointReturn`

Observed state:
- `jointReturnFiled = TRUE`
- `jointLiabilityAllocated = FALSE`
- `liabilityShared = FALSE`

Expected invariant:
- `jointReturnFiled => jointLiabilityAllocated`

Meaning:
- the model permits a joint return to exist without the joint liability being allocated
- this is the core joint-return gap: the spouse-level liability attribution is incomplete

### 30. Installment agreement default failure

Model: `work/TaxInstallmentAgreementGap.tla`

Trace:
1. initial state
2. `MissPayment`

Observed state:
- `agreementActive = TRUE`
- `paymentMissed = TRUE`
- `agreementDefaulted = FALSE`

Expected invariant:
- `paymentMissed => agreementDefaulted`

Meaning:
- the model permits an installment agreement to remain active after a missed payment without defaulting
- this is the core installment-agreement gap: the debt-management status does not update when the payment is missed

### 31. Foreign tax credit entitlement failure

Model: `work/TaxForeignTaxCreditGap.tla`

Trace:
1. initial state
2. `ClaimCredit`

Observed state:
- `foreignTaxPaid = FALSE`
- `creditClaimed = TRUE`
- `creditAllowed = FALSE`

Expected invariant:
- `creditClaimed => foreignTaxPaid`

Meaning:
- the model permits a foreign tax credit to be claimed without any foreign tax paid
- this is the core foreign-credit entitlement gap: the credit exists without the foreign tax basis

### 32. Tax Court petition timing failure

Model: `work/TaxCourtPetitionGap.tla`

Trace:
1. initial state
2. `SendNotice`
3. `AdvanceDay`
4. `AdvanceDay`
5. `FilePetition`

Observed state:
- `noticeOfDeficiencySent = TRUE`
- `currentDay = 2`
- `petitionFiled = TRUE`
- `petitionTimely = FALSE`

Expected invariant:
- `petitionFiled => petitionTimely`

Meaning:
- the model permits a Tax Court petition to be filed after the deadline while still counting as filed
- this is the core Tax Court gap: the petition window is not enforced as a hard deadline

### 33. Amended return correction failure

Model: `work/TaxAmendedReturnGap.tla`

Trace:
1. initial state
2. `FileOriginal`
3. `FileAmended`

Observed state:
- `originalReturnFiled = TRUE`
- `amendedReturnFiled = TRUE`
- `corrected = FALSE`
- `contradiction = TRUE`

Expected invariant:
- `amendedReturnFiled => corrected`

Meaning:
- the model permits an amended return to be filed without the correction being applied
- this is the core amended-return gap: the correction path can exist without actually resolving the contradiction

### 34. Basis step-up at death failure

Model: `work/TaxBasisStepUpGap.tla`

Trace:
1. initial state
2. `OwnerDies`
3. `InheritAsset`

Observed state:
- `ownerAlive = FALSE`
- `inherited = TRUE`
- `assetBasis = 20`
- `fairMarketValue = 100`
- `steppedUp = TRUE`

Expected invariant:
- `inherited => assetBasis = fairMarketValue`

Meaning:
- the model permits inherited property to keep its old basis instead of stepping up to fair market value
- this is the core basis-step-up gap: inheritance does not reset basis in the model

### 35. Dividend record-date entitlement failure

Model: `work/TaxDividendRecordDateGap.tla`

Trace:
1. initial state
2. `TransferToB`
3. `DeclareDividend`
4. `TransferToC`
5. `PayDividend`
6. `ClaimCredit`

Observed state:
- `holder = "C"`
- `recordHolder = "B"`
- `dividendPaid = TRUE`
- `creditClaimed = TRUE`
- `creditedTo = "C"`

Expected invariant:
- `creditClaimed => creditedTo = recordHolder`

Meaning:
- the model allows the dividend credit to follow the latest holder instead of freezing at the record-date holder
- this is the cum-ex-style gap: the share can be moved around after record date, but the withholding credit or refund path is still collectible by the end holder

### 36. Qualified-dividend holding-period failure

Model: `work/TaxQualifiedDividendHoldingGap.tla`

Trace:
1. initial state
2. `BuyStock`
3. `DeclareDividend`
4. `ClaimQualifiedDividend`

Observed state:
- `stockOwned = TRUE`
- `dividendDeclared = TRUE`
- `daysHeld = 0`
- `qualifiedClaimed = TRUE`

Expected invariant:
- `qualifiedClaimed => daysHeld > RequiredDays`

Meaning:
- the model permits a dividend to be claimed as qualified without satisfying the minimum holding period
- this is the core qualified-dividend gap: the tax rate benefit can appear before the statutory holding-period gate is met

### 37. Dividend double-claim failure

Model: `work/TaxDividendDoubleClaimGap.tla`

Trace:
1. initial state
2. `TransferToB`
3. `DeclareDividend`
4. `TransferToC`
5. `PayDividend`
6. `ClaimRecordCredit`
7. `ClaimCurrentCredit`

Observed state:
- `holder = "C"`
- `recordHolder = "B"`
- `recordCreditClaimed = TRUE`
- `currentCreditClaimed = TRUE`

Expected invariant:
- `~(recordCreditClaimed /\ currentCreditClaimed)`

Meaning:
- the model allows both the record-date holder path and the final-holder path to claim a benefit from the same dividend event
- this is the explicit double-claim version of the cum-ex style gap: the entitlement layer is not exclusive, so one dividend can support two claims

### 38. Stock-loan beneficial-ownership failure

Model: `work/TaxStockLoanBeneficialOwnershipGap.tla`

Trace:
1. initial state
2. `LoanToB`
3. `LoanToC`
4. `DeclareDividend`
5. `PayDividend`
6. `ClaimCredit`

Observed state:
- `holder = "C"`
- `beneficialOwner = "A"`
- `dividendPaid = TRUE`
- `creditClaimed = TRUE`
- `creditedTo = "C"`

Expected invariant:
- `creditClaimed => creditedTo = beneficialOwner`

Meaning:
- the model permits the dividend credit to follow the last borrower in the chain rather than the true economic owner
- this is the stock-loan version of the cum-ex gap: beneficial ownership and paperwork ownership split, then the tax benefit is claimed by the end holder

### 39. Long-term capital-gain timing failure

Model: `work/TaxLongTermCapitalGainGap.tla`

Trace:
1. initial state
2. `BuyAsset`
3. `SellAsset`
4. `ClaimLongTermRate`

Observed state:
- `assetOwned = TRUE`
- `daysHeld = 0`
- `sold = TRUE`
- `longTermClaimed = TRUE`

Expected invariant:
- `longTermClaimed => daysHeld > RequiredDays`

Meaning:
- the model permits the long-term rate to be claimed before the one-year holding period is satisfied
- this is the capital-gains timing gap: the classification benefit appears even when the asset has not aged long enough

### 40. Installment-agreement penalty-rate failure

Model: `work/TaxInstallmentPenaltyRateGap.tla`

Trace:
1. initial state
2. `AssessPenalty`

Observed state:
- `agreementActive = TRUE`
- `penaltyAssessed = TRUE`
- `penaltyRate = 50`

Expected invariant:
- `agreementActive /\ penaltyAssessed => penaltyRate = ReducedRate`

Meaning:
- the model permits a full failure-to-pay penalty rate even while an installment agreement is active
- this is the penalty-rate gap: the plan status does not flow through to the assessed rate

### 41. Combined penalty reduction failure

Model: `work/TaxCombinedPenaltyReductionGap.tla`

Trace:
1. initial state
2. `MissFilingDeadline`
3. `MissPayment`
4. `AssessPenalties`

Observed state:
- `fileLate = TRUE`
- `payLate = TRUE`
- `filePenaltyRate = 5`
- `payPenaltyRate = 5`

Expected invariant:
- `fileLate /\ payLate => filePenaltyRate = ReducedFileRate`

Meaning:
- the model permits the failure-to-file penalty to stay at the full rate even when failure-to-pay also applies
- this is the overlap gap: the combined penalty logic double-counts instead of reducing the filing penalty by the pay penalty in the same month

### 42. Levy-notice escalation failure

Model: `work/TaxLevyEscalationGap.tla`

Trace:
1. initial state
2. `SendNotice`
3. `AdvanceDay`
4. `AdvanceDay`
5. `AdvanceDay`
6. `AdvanceDay`
7. `AdvanceDay`
8. `AdvanceDay`
9. `AdvanceDay`
10. `AdvanceDay`
11. `AdvanceDay`
12. `AdvanceDay`
13. `AssessPenalty`

Observed state:
- `noticeSent = TRUE`
- `daysSinceNotice = 10`
- `assessed = TRUE`
- `penaltyRate = 5`

Expected invariant:
- `assessed /\ daysSinceNotice >= NoticeDays => penaltyRate = HighRate`

Meaning:
- the model permits the post-notice penalty to remain at the lower rate even after the 10-day levy notice window has elapsed
- this is the escalation gap: the rate should sharpen after notice, but the model does not force that transition

### 43. Withholding-credit duplication failure

Model: `work/TaxWithholdingCreditDuplicationGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `ApplyWithholding`
4. `ClaimCreditOnFormA`
5. `ClaimCreditOnFormB`

Observed state:
- `paymentMade = TRUE`
- `withholdingApplied = TRUE`
- `creditOnFormA = TRUE`
- `creditOnFormB = TRUE`

Expected invariant:
- `~(creditOnFormA /\ creditOnFormB)`

Meaning:
- the model allows the same withheld payment to support two separate credit claims on different forms or layers
- this is the duplication gap: one withholding event can be recognized twice instead of being consumed once

### 44. Synthetic dividend duplication failure

Model: `work/TaxSyntheticDividendGap.tla`

Trace:
1. initial state
2. `DeclareDividend`
3. `PayStockDividend`
4. `PaySyntheticDividend`
5. `ClaimStockCredit`
6. `ClaimSyntheticCredit`

Observed state:
- `stockDividendPaid = TRUE`
- `syntheticDividendPaid = TRUE`
- `stockCreditClaimed = TRUE`
- `syntheticCreditClaimed = TRUE`

Expected invariant:
- `~(stockCreditClaimed /\ syntheticCreditClaimed)`

Meaning:
- the model allows the same underlying dividend event to generate both a direct stock-based credit and a synthetic dividend-equivalent credit
- this is the synthetic-exposure gap: economic payoff and share ownership can both claim tax treatment unless the entitlement layer is made exclusive

### 45. Short-sale recognition failure

Model: `work/TaxShortSaleRecognitionGap.tla`

Trace:
1. initial state
2. `OpenShort`
3. `CloseShort`

Observed state:
- `shortOpened = TRUE`
- `shortClosed = TRUE`
- `gainLossRecognized = FALSE`

Expected invariant:
- `shortClosed => gainLossRecognized`

Meaning:
- the model permits a short sale to be closed without any gain/loss recognition step
- this is the short-sale gap: the position lifecycle ends, but the tax result never gets forced into the state

### 46. Stock-split basis reallocation failure

Model: `work/TaxStockSplitBasisGap.tla`

Trace:
1. initial state
2. `SplitStock`

Observed state:
- `shares = 200`
- `totalBasis = 1500`
- `basisPerShare = 15`
- `splitDone = TRUE`

Expected invariant:
- `totalBasis = shares * basisPerShare`

Meaning:
- the model permits the share count to double while leaving per-share basis unchanged
- this is the stock-split basis gap: the economic basis is preserved in total, but not reallocated across the new share count

### 47. Stock-rights basis allocation failure

Model: `work/TaxStockRightsBasisGap.tla`

Trace:
1. initial state
2. `DistributeRights`

Observed state:
- `rightsDistributed = TRUE`
- `oldStockBasis = 2200`
- `rightsBasis = 0`
- `rightsExercised = FALSE`

Expected invariant:
- `rightsDistributed => rightsBasis > 0`

Meaning:
- the model permits stock rights to be distributed without any basis being allocated to them
- this is the stock-rights gap: the new rights exist, but the basis accounting never moves onto them

### 48. Return-of-capital basis reduction failure

Model: `work/TaxReturnOfCapitalGap.tla`

Trace:
1. initial state
2. `ReceiveDistribution`

Observed state:
- `distributionReceived = TRUE`
- `stockBasis = 1000`
- `gainRecognized = FALSE`

Expected invariant:
- `distributionReceived => stockBasis = Basis0 - DistAmt`

Meaning:
- the model permits a nondividend distribution to be received without reducing basis
- this is the return-of-capital gap: the cash comes out, but the basis account stays unchanged instead of stepping down

### 48.1. Form 1099-DIV mixed dividend and return-of-capital double counting failure

Model: `work/TaxForm1099DIVMixedDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveDistribution`
3. `ClassifyAsDividend`
4. `ClassifyAsReturnOfCapital`

Observed state:
- `distributionReceived = TRUE`
- `dividendPart = 1`
- `returnOfCapitalPart = 1`
- `stockBasis = 2`

Expected invariant:
- `dividendPart + returnOfCapitalPart <= DistAmt`

Meaning:
- the model lets one distribution be counted as a full dividend and a full return of capital at the same time
- this is the mixed-distribution gap: IRS guidance treats dividend income and return-of-capital treatment as separate classifications of the same distribution, but the state machine allows the same cash payout to be fully allocated to both buckets instead of being split once

### 49. Liquidation loss recognition failure

Model: `work/TaxLiquidationLossGap.tla`

Trace:
1. initial state
2. `StartLiquidation`
3. `ReceiveFinalDistribution`

Observed state:
- `liquidationStarted = TRUE`
- `finalDistributionReceived = TRUE`
- `stockBasis = 200`
- `lossClaimed = FALSE`

Expected invariant:
- `finalDistributionReceived => lossClaimed`

Meaning:
- the model permits the final liquidating distribution to be received without triggering the capital-loss recognition step
- this is the liquidation gap: the liquidation closes economically, but the loss claim never becomes mandatory in the state machine

### 50. Liquidation excess-gain recognition failure

Model: `work/TaxLiquidationExcessGainGap.tla`

Trace:
1. initial state
2. `StartLiquidation`
3. `ReceiveDistribution`

Observed state:
- `liquidationStarted = TRUE`
- `distributionReceived = TRUE`
- `stockBasis = -100`
- `gainRecognized = FALSE`

Expected invariant:
- `distributionReceived /\ stockBasis <= 0 => gainRecognized`

Meaning:
- the model permits liquidation proceeds to push basis below zero without forcing the excess into gain recognition
- this is the liquidation excess-gain gap: the state machine can finish the cash distribution path while suppressing the taxable excess

### 51. S-corp nondividend distribution gain failure

Model: `work/TaxSCorpDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveDistribution`

Observed state:
- `distributionReceived = TRUE`
- `stockBasis = -50`
- `gainRecognized = FALSE`

Expected invariant:
- `distributionReceived /\ stockBasis <= 0 => gainRecognized`

Meaning:
- the model permits an S-corp nondividend distribution to exceed stock basis without forcing the excess into capital gain
- this is the S-corp distribution gap: the basis is exhausted, but the taxable remainder never becomes mandatory in the state machine

### 52. Foreign intermediary withholding failure

Model: `work/TaxForeignIntermediaryWithholdingGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `SetRate`

Observed state:
- `paymentMade = TRUE`
- `intermediaryPresent = TRUE`
- `docsValid = FALSE`
- `beneficialOwnerForeign = TRUE`
- `withholdingRate = 0`

Expected invariant:
- `beneficialOwnerForeign /\ ~docsValid => withholdingRate = 30`

Meaning:
- the model permits a foreign beneficial owner behind an intermediary to receive a zero withholding rate even without valid documentation
- this is the foreign-intermediary gap: the intermediary layer hides the foreign ownership status, and the rate-setting logic fails to restore the statutory withholding

### 53. Partnership property distribution basis failure

Model: `work/TaxPartnershipPropertyDistributionGap.tla`

Trace:
1. initial state
2. `DistributeProperty`

Observed state:
- `propertyDistributed = TRUE`
- `distributedPropertyBasis = 0`
- `gainRecognized = FALSE`

Expected invariant:
- `propertyDistributed => distributedPropertyBasis = PartnershipPropertyBasis`

Meaning:
- the model permits a partnership to distribute property without carrying the partnership property basis onto the distributed asset
- this is the partnership property distribution gap: the asset leaves the partnership, but the basis accounting never follows the property out the door

### 54. Partnership liability decrease gain failure

Model: `work/TaxPartnershipLiabilityDecreaseGap.tla`

Trace:
1. initial state
2. `DecreaseLiabilityShare`

Observed state:
- `liabilityShare = 10`
- `partnerBasis = 100`
- `gainRecognized = FALSE`

Expected invariant:
- `liabilityShare < partnerBasis => gainRecognized`

Meaning:
- the model permits a decrease in the partner’s share of liabilities without forcing gain recognition when liabilities fall below basis
- this is the partnership liability gap: the liability shift behaves like a distribution of money, but the taxable excess never becomes mandatory in the state machine

### 54.1. Partnership liability decrease gain-recognition failure

Model: `work/TaxPartnershipLiabilityDecreaseGap.tla`

Trace:
1. initial state
2. `DecreaseLiabilityShare`

Observed state:
- `partnershipLiabilityExists = TRUE`
- `liabilityShare = 5`
- `partnerBasis = 100`
- `liabilityDecreased = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `liabilityDecreased /\ liabilityShare < partnerBasis => gainRecognized`

Meaning:
- the model lets a partnership liability decrease occur while gain recognition is still absent
- this is the section 752 liability-decrease gap: IRS guidance treats a partner’s share of partnership liabilities as money distribution when it falls, and any excess over basis should trigger gain, but the state machine allows the liability-drop state to exist without the gain-recognition state

### 55. Partnership interest sale withholding failure

Model: `work/TaxPartnershipInterestSaleWithholdingGap.tla`

Trace:
1. initial state
2. `SellInterest`

Observed state:
- `saleDone = TRUE`
- `foreignPartner = TRUE`
- `withholdingApplied = FALSE`
- `withholdingRate = 0`

Expected invariant:
- `saleDone /\ foreignPartner => withholdingRate = 10`

Meaning:
- the model permits a foreign partner to sell a partnership interest without triggering the 10% withholding rate
- this is the 1446(f) gap: the transfer closes, but the required withholding never appears in the state machine

### 56. Qualified intermediary assumption failure

Model: `work/TaxQualifiedIntermediaryAssumptionGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `SetRate`

Observed state:
- `paymentMade = TRUE`
- `qiPresent = TRUE`
- `qiAssumedPrimaryWithholding = FALSE`
- `withholdingRate = 0`

Expected invariant:
- `paymentMade /\ qiPresent /\ ~qiAssumedPrimaryWithholding => withholdingRate = 30`

Meaning:
- the model permits a qualified intermediary to sit in the payment chain without having assumed primary withholding responsibility, yet still zeroes the withholding rate
- this is the QI-assumption gap: the intermediary’s mere presence is treated like an exemption even though the primary withholding obligation was never accepted

### 57. Partnership ECI withholding failure

Model: `work/TaxPartnershipECIWithholdingGap.tla`

Trace:
1. initial state
2. `AllocateECI`

Observed state:
- `eciAllocated = TRUE`
- `foreignPartner = TRUE`
- `withholdingApplied = FALSE`
- `withholdingRate = 0`

Expected invariant:
- `eciAllocated /\ foreignPartner => withholdingRate = HighRate`

Meaning:
- the model permits effectively connected income to be allocated to a foreign partner without forcing the partnership withholding rate
- this is the 1446(a) gap: the income is allocated, but the statutory withholding never becomes mandatory in the state machine

### 58. Partnership ECI rate-classification failure

Model: `work/TaxPartnershipECIRateClassificationGap.tla`

Trace:
1. initial state
2. `AllocateECI`
3. `SetWrongRate`

Observed state:
- `eciAllocated = TRUE`
- `foreignPartner = TRUE`
- `isCorporate = TRUE`
- `withholdingRate = 37`

Expected invariant:
- `eciAllocated /\ foreignPartner /\ isCorporate => withholdingRate = 21`

Meaning:
- the model permits a corporate foreign partner’s ECI withholding rate to be set at the noncorporate rate
- this is the rate-classification gap: the partnership recognizes the foreign partner status, but still applies the wrong statutory bracket

### 58. Partnership loss limitation failure

Model: `work/TaxPartnershipLossLimitationGap.tla`

Trace:
1. initial state
2. `AllocateLoss`

Observed state:
- `lossAllocated = TRUE`
- `outsideBasis = -30`
- `lossSuspended = 0`

Expected invariant:
- `lossAllocated => outsideBasis >= 0`

Meaning:
- the model permits partnership losses to exceed outside basis and still be fully applied immediately
- this is the 704(d) gap: the loss is not limited to basis and the excess is not suspended for a later year

### 59. Marketable securities distribution gain failure

Model: `work/TaxMarketableSecuritiesDistributionGap.tla`

Trace:
1. initial state
2. `DistributeSecurity`

Observed state:
- `securityDistributed = TRUE`
- `partnerBasis = 100`
- `gainRecognized = FALSE`

Expected invariant:
- `securityDistributed /\ SecurityFMV > partnerBasis => gainRecognized`

Meaning:
- the model permits a marketable security distributed in liquidation to be treated as money for gain purposes without actually forcing the gain step
- this is the marketable-securities gap: the distribution is economically cash-like, but the state machine leaves the gain unrecognized

### 60. Partnership withholding report failure

Model: `work/TaxPartnershipWithholdingReportGap.tla`

Trace:
1. initial state
2. `AllocateECI`

Observed state:
- `eciAllocated = TRUE`
- `foreignPartner = TRUE`
- `reportFiled = FALSE`

Expected invariant:
- `eciAllocated /\ foreignPartner => reportFiled`

Meaning:
- the model permits ECI allocable to a foreign partner to exist without the partnership filing the required withholding report
- this is the reporting gap: the withholding facts exist, but the Form 8804/8805-style reporting obligation never becomes mandatory in the state machine

### 61. Section 754 basis adjustment failure

Model: `work/TaxSection754BasisAdjustmentGap.tla`

Trace:
1. initial state
2. `DistributeProperty`

Observed state:
- `distributionOccurred = TRUE`
- `section754Election = TRUE`
- `remainingPartnershipBasis = 1000`

Expected invariant:
- `distributionOccurred /\ section754Election => remainingPartnershipBasis # RemainingBasis0`

Meaning:
- the model permits a partnership with a valid section 754 election to distribute property without changing the basis of the remaining partnership property
- this is the 734/754 gap: the distribution happened, but the post-distribution basis adjustment never kicked in

### 62. Wash sale basis carryover failure

Model: `work/TaxWashSaleGap.tla`

Trace:
1. initial state
2. `SellAtLoss`
3. `BuyReplacement`

Observed state:
- `soldAtLoss = TRUE`
- `repurchased = TRUE`
- `replacementBasis = 100`
- `deferredLoss = 10`

Expected invariant:
- `repurchased => replacementBasis = Basis0 + deferredLoss`

Meaning:
- the model permits a wash-sale style replacement purchase to occur after a loss sale without carrying the deferred loss into the new basis
- this is the wash-sale gap: the loss is flagged as deferred, but the replacement position never inherits that deferred amount in basis

### 63. Related-party loss disallowance failure

Model: `work/TaxRelatedPartyLossGap.tla`

Trace:
1. initial state
2. `SellToRelatedParty`

Observed state:
- `saleToRelatedParty = TRUE`
- `lossRealized = TRUE`
- `lossDisallowed = FALSE`

Expected invariant:
- `saleToRelatedParty /\ lossRealized => lossDisallowed`

Meaning:
- the model permits a related-party sale to realize a loss without tagging that loss as disallowed
- this is the related-party gap: the sale happened inside the prohibited relationship, but the non-deductible character of the loss never becomes mandatory in the state machine

### 64. At-risk loss suspension failure

Model: `work/TaxAtRiskLossGap.tla`

Trace:
1. initial state
2. `ClaimLoss`

Observed state:
- `lossClaimed = TRUE`
- `atRiskAmount = 100`
- `lossSuspended = FALSE`

Expected invariant:
- `lossClaimed /\ LossAmt > atRiskAmount => lossSuspended`

Meaning:
- the model permits a loss larger than the at-risk amount to be claimed without forcing suspension of the excess
- this is the at-risk gap: the deduction is modeled as immediately available even though the statutory limit should hold part of it back

### 65. Related-party gain carryover failure

Model: `work/TaxRelatedPartyGainCarryoverGap.tla`

Trace:
1. initial state
2. `SellAtGain`

Observed state:
- `acquiredFromRelatedParty = TRUE`
- `originalTransferee = TRUE`
- `saleOccurred = TRUE`
- `recognizedGain = 0`

Expected invariant:
- `saleOccurred /\ acquiredFromRelatedParty /\ originalTransferee => recognizedGain = GainAmount - PriorDisallowedLoss`

Meaning:
- the model permits a later gain sale of related-party property to ignore the prior disallowed loss embedded in the property
- this is the carryover gap in the related-party rule: the earlier loss restriction is not preserved when the transferee eventually sells at a gain

### 66. Gift loss basis floor failure

Model: `work/TaxGiftBasisLossGap.tla`

Trace:
1. initial state
2. `ReceiveGift`
3. `SellAtLoss`

Observed state:
- `giftReceived = TRUE`
- `soldAtLoss = TRUE`
- `doneeLossBasis = 100`

Expected invariant:
- `soldAtLoss => doneeLossBasis = GiftFMV`

Meaning:
- the model permits a gifted asset to be sold at a loss while still carrying the donor's higher basis instead of the gift-date FMV floor
- this is the gift-basis gap: the loss-side basis rule does not switch to the lower FMV baseline when it should

### 67. Gift holding period carryover failure

Model: `work/TaxGiftHoldingPeriodGap.tla`

Trace:
1. initial state
2. `ReceiveGift`
3. `SellAsset`

Observed state:
- `giftReceived = TRUE`
- `sold = TRUE`
- `holdingPeriodInherited = FALSE`

Expected invariant:
- `sold => holdingPeriodInherited`

Meaning:
- the model permits gifted property to be sold without carrying over the donor's holding period
- this is the holding-period gap: the donee can sell the asset, but the donor's seasoning never becomes part of the state machine

### 68. Excess business loss carryover failure

Model: `work/TaxExcessBusinessLossGap.tla`

Trace:
1. initial state
2. `IncurBusinessLoss`

Observed state:
- `businessLossIncurred = 1000`
- `nolCarryoverCreated = FALSE`

Expected invariant:
- `businessLossIncurred > LossThreshold => nolCarryoverCreated`

Meaning:
- the model permits a business loss above the statutory threshold to be incurred without creating the required NOL carryover
- this is the excess-business-loss gap: the disallowed amount is modeled as staying inside the current year instead of moving forward to the next year

### 69. Business interest limitation failure

Model: `work/TaxBusinessInterestLimitGap.tla`

Trace:
1. initial state
2. `IncurInterest`

Observed state:
- `interestIncurred = 1000`
- `interestDeducted = 1000`
- `carryforwardCreated = FALSE`

Expected invariant:
- `interestIncurred > InterestLimit => /\ interestDeducted = InterestLimit /\ carryforwardCreated`

Meaning:
- the model permits business interest expense to be deducted in full even when it exceeds the 163(j) limitation
- this is the interest-limitation gap: the excess is not capped, and the required carryforward never appears in the state machine

### 70. Qualified dividend holding period failure

Model: `work/TaxQualifiedDividendPeriodGap.tla`

Trace:
1. initial state
2. `DeclareDividend`
3. `ClaimQualifiedDividend`

Observed state:
- `dividendDeclared = TRUE`
- `holdingDays = 0`
- `qualifiedClaimed = TRUE`

Expected invariant:
- `qualifiedClaimed => holdingDays >= RequiredDays`

Meaning:
- the model permits a dividend to be claimed as qualified without satisfying the 61-day holding period
- this is the qualified-dividend gap: the favorable rate is available even though the seasoning requirement never becomes true in the state machine

### 71. Investment interest limitation failure

Model: `work/TaxInvestmentInterestLimitGap.tla`

Trace:
1. initial state
2. `ClaimInterestDeduction`

Observed state:
- `interestDeducted = 1500`
- `carryforwardCreated = FALSE`
- `deductionClaimed = TRUE`

Expected invariant:
- `deductionClaimed /\ InterestExpense > NetInvestmentIncome => /\ interestDeducted = NetInvestmentIncome /\ carryforwardCreated`

Meaning:
- the model permits investment interest expense to be deducted in full even though it exceeds net investment income
- this is the investment-interest gap: the excess is not capped, and the disallowed amount never becomes a carryforward

### 72. Capital loss limit failure

Model: `work/TaxCapitalLossLimitGap.tla`

Trace:
1. initial state
2. `IncurCapitalLoss`

Observed state:
- `lossIncurred = 7000`
- `lossDeducted = 7000`
- `carryoverCreated = FALSE`

Expected invariant:
- `lossIncurred > LossLimit => /\ lossDeducted = LossLimit /\ carryoverCreated`

Meaning:
- the model permits a capital loss above the annual deduction cap to be fully deducted in the current year
- this is the capital-loss gap: the excess is not limited to $3,000, and the unused portion never becomes a carryover

### 73. QSBS exclusion qualification failure

Model: `work/TaxQSBSExclusionGap.tla`

Trace:
1. initial state
2. `SellStock`

Observed state:
- `stockSold = TRUE`
- `qualifiedClaimed = TRUE`
- `holdingYears = 0`
- `corporationQualified = FALSE`

Expected invariant:
- `qualifiedClaimed => /\ holdingYears >= RequiredYears /\ corporationQualified`

Meaning:
- the model permits a qualified small business stock exclusion to be claimed without meeting the five-year holding period or corporation-qualification conditions
- this is the QSBS gap: the favorable exclusion is available even though the eligibility gate never becomes true in the state machine

### 73.1. QSBS original-issue and active-business failure

Model: `work/TaxQSBSOriginalIssueActiveBusinessGap.tla`

Trace:
1. initial state
2. `SellStock`

Observed state:
- `stockSold = TRUE`
- `qualifiedClaimed = TRUE`
- `stockOriginallyIssued = FALSE`
- `corporationActiveBusiness = FALSE`

Expected invariant:
- `qualifiedClaimed => stockOriginallyIssued /\ corporationActiveBusiness`

Meaning:
- the model lets a qualified small business stock exclusion be claimed without the stock being originally issued or the corporation meeting the active-business test
- this is the QSBS original-issue gap: IRS guidance says QSBS must be original-issue stock in a qualified small business that satisfies the active-business requirements during substantially all of the holding period, but the state machine allows the exclusion state to exist without those predicates

### 74. Like-kind exchange basis adjustment failure

Model: `work/TaxLikeKindExchangeGap.tla`

Trace:
1. initial state
2. `DoExchange`

Observed state:
- `exchangedProperty = TRUE`
- `gainDeferred = TRUE`
- `newBasis = 100`

Expected invariant:
- `exchangedProperty => /\ gainDeferred /\ newBasis = OldBasis + BootReceived`

Meaning:
- the model permits a like-kind exchange to defer gain while still leaving the replacement basis unchanged
- this is the 1031 gap: the exchange is treated as tax-deferred, but the boot adjustment never gets folded into the new basis

### 75. Main home exclusion qualification failure

Model: `work/TaxMainHomeExclusionGap.tla`

Trace:
1. initial state
2. `SellHome`

Observed state:
- `homeSold = TRUE`
- `exclusionClaimed = TRUE`
- `ownedYears = 0`
- `usedYears = 0`

Expected invariant:
- `exclusionClaimed => /\ ownedYears >= RequiredYears /\ usedYears >= RequiredYears`

Meaning:
- the model permits the section 121 home-sale exclusion to be claimed without satisfying the ownership and use tests
- this is the main-home exclusion gap: the exclusion becomes available even though the qualification period never accumulates in the state machine

### 76. Charitable appraisal substantiation failure

Model: `work/TaxCharitableAppraisalGap.tla`

Trace:
1. initial state
2. `MakeDonation`

Observed state:
- `noncashGiftMade = TRUE`
- `appraisalObtained = FALSE`
- `form8283Filed = FALSE`

Expected invariant:
- `noncashGiftMade /\ DonationValue > AppraisalThreshold => /\ appraisalObtained /\ form8283Filed`

Meaning:
- the model permits a large noncash charitable donation to be made without the appraisal and Form 8283 substantiation that IRS rules require
- this is the charitable substantiation gap: the donation exists, but the proof layer never becomes mandatory in the state machine

### 77. Casualty loss disaster qualification failure

Model: `work/TaxCasualtyLossDisasterGap.tla`

Trace:
1. initial state
2. `SufferCasualty`

Observed state:
- `casualtyOccurred = TRUE`
- `federallyDeclaredDisaster = FALSE`
- `lossClaimed = TRUE`

Expected invariant:
- `lossClaimed => federallyDeclaredDisaster`

Meaning:
- the model permits a personal casualty loss to be claimed even when it is not attributable to a federally declared disaster
- this is the casualty-loss gap: the deduction is available without the disaster gate becoming true in the state machine

### 78. Student loan interest income-limit failure

Model: `work/TaxStudentLoanInterestGap.tla`

Trace:
1. initial state
2. `ClaimStudentLoanInterest`

Observed state:
- `studentLoanInterestClaimed = TRUE`
- `deductionAllowed = 2500`

Expected invariant:
- `studentLoanInterestClaimed /\ MAGI >= MAGILimit => deductionAllowed = 0`

Meaning:
- the model permits a student loan interest deduction to be claimed even when MAGI is above the statutory cutoff
- this is the student-loan gap: the deduction is modeled as fully available despite the income limit that should eliminate it

### 79. Mortgage interest limit failure

Model: `work/TaxMortgageInterestLimitGap.tla`

Trace:
1. initial state
2. `ClaimMortgageInterest`

Observed state:
- `mortgageInterestClaimed = TRUE`
- `interestDeducted = 900000`

Expected invariant:
- `mortgageInterestClaimed /\ MortgageBalance > MortgageLimit => interestDeducted = MortgageLimit`

Meaning:
- the model permits home mortgage interest to be claimed on debt above the statutory cap without limiting the deductible amount
- this is the mortgage-interest gap: the deduction is recorded at full balance rather than the allowed limit

### 80. Foreign earned income exclusion qualification failure

Model: `work/TaxForeignEarnedIncomeExclusionGap.tla`

Trace:
1. initial state
2. `ClaimForeignEarnedIncomeExclusion`

Observed state:
- `foreignIncomeClaimed = TRUE`
- `taxHomeForeign = FALSE`
- `daysAbroad = 0`
- `exclusionAllowed = TRUE`

Expected invariant:
- `foreignIncomeClaimed => /\ taxHomeForeign /\ daysAbroad >= RequiredDays`

Meaning:
- the model permits a foreign earned income exclusion to be claimed without a foreign tax home or the 330-day presence test
- this is the FEIE gap: the exclusion becomes available even though the foreign-presence gate never becomes true in the state machine

### 81. Adoption credit qualification failure

Model: `work/TaxAdoptionCreditGap.tla`

Trace:
1. initial state
2. `ClaimAdoptionCredit`

Observed state:
- `adoptionFinal = FALSE`
- `creditClaimed = TRUE`
- `magiHigh = TRUE`
- `creditAmount = 17280`

Expected invariant:
- `creditClaimed => /\ adoptionFinal /\ ~magiHigh`

Meaning:
- the model permits an adoption credit to be claimed without a final adoption and despite high MAGI
- this is the adoption-credit gap: the benefit is available without the finality and income gates becoming true in the state machine

### 82. Dependent care credit work-provider failure

Model: `work/TaxDependentCareCreditGap.tla`

Trace:
1. initial state
2. `ClaimDependentCareCredit`

Observed state:
- `workRelated = FALSE`
- `providerQualified = FALSE`
- `creditClaimed = TRUE`
- `expensesAllowed = 6000`

Expected invariant:
- `creditClaimed => /\ workRelated /\ providerQualified /\ expensesAllowed <= ExpenseCap`

Meaning:
- the model permits the child and dependent care credit to be claimed without work-related care and without a qualified provider
- this is the dependent-care gap: the credit appears even though the care and provider gates never become true in the state machine

### 83. Section 179 expensing cap failure

Model: `work/TaxSection179Gap.tla`

Trace:
1. initial state
2. `ClaimSection179`

Observed state:
- `expenseClaimed = TRUE`
- `section179Allowed = 3000000`

Expected invariant:
- `expenseClaimed /\ PropertyCost > Section179Cap => section179Allowed = Section179Cap`

Meaning:
- the model permits the section 179 election to expense the full property cost even when it exceeds the dollar cap
- this is the section 179 gap: the deduction is recorded above the statutory ceiling instead of being clipped to it

### 84. Medical expense floor failure

Model: `work/TaxMedicalExpenseFloorGap.tla`

Trace:
1. initial state
2. `ClaimMedicalExpenseDeduction`

Observed state:
- `medicalExpenseClaimed = TRUE`
- `deductionAllowed = 20000`

Expected invariant:
- `medicalExpenseClaimed => deductionAllowed = IF MedicalExpense > MedicalFloor THEN MedicalExpense - MedicalFloor ELSE 0`

Meaning:
- the model permits medical expenses to be deducted in full instead of only the amount above the 7.5% floor
- this is the medical-expense gap: the deduction is modeled without the statutory threshold being applied

### 85. Child tax credit qualifying-child failure

Model: `work/TaxChildTaxCreditGap.tla`

Trace:
1. initial state
2. `ClaimChildTaxCredit`

Observed state:
- `ctcClaimed = TRUE`
- `creditAllowed = 2000`
- `qualifyingChild = FALSE`
- `childAge = 17`

Expected invariant:
- `ctcClaimed => /\ qualifyingChild /\ childAge < ChildAgeLimit`

Meaning:
- the model permits the child tax credit to be claimed without a qualifying child and at the age cutoff
- this is the child-tax-credit gap: the benefit is available even though the qualifying-child gate never becomes true in the state machine

### 86. Qualified business income deduction failure

Model: `work/TaxQBIDeductionGap.tla`

Trace:
1. initial state
2. `ClaimQBIDeduction`

Observed state:
- `qbiClaimed = TRUE`
- `deductionAllowed = 40000`
- `businessQualified = FALSE`

Expected invariant:
- `qbiClaimed => /\ businessQualified /\ deductionAllowed <= DeductionCap`

Meaning:
- the model permits the QBI deduction to be claimed without a qualified business and above the cap
- this is the QBI gap: the deduction is modeled as available even though the eligibility gate never becomes true in the state machine

### 87. Home office principal-place failure

Model: `work/TaxHomeOfficeDeductionGap.tla`

Trace:
1. initial state
2. `ClaimHomeOfficeDeduction`

Observed state:
- `homeOfficeClaimed = TRUE`
- `deductionAllowed = 1500`
- `principalPlaceOfBusiness = FALSE`

Expected invariant:
- `homeOfficeClaimed => principalPlaceOfBusiness`

Meaning:
- the model permits a home office deduction to be claimed without the principal-place-of-business test
- this is the home-office gap: the deduction is available even though the qualifying-use gate never becomes true in the state machine

### 88. Passive activity loss suspension failure

Model: `work/TaxPassiveActivityLossGap.tla`

Trace:
1. initial state
2. `ClaimPassiveLoss`

Observed state:
- `passiveLossClaimed = TRUE`
- `passiveIncomeAvailable = 0`
- `lossSuspended = FALSE`

Expected invariant:
- `passiveLossClaimed => /\ passiveIncomeAvailable >= PassiveLoss /\ lossSuspended`

Meaning:
- the model permits a passive activity loss to be claimed without any passive income and without suspension
- this is the passive-loss gap: the deduction is modeled as immediately usable even though the passive-activity gate never becomes true in the state machine

### 89. Residential clean energy credit installation failure

Model: `work/TaxResidentialCleanEnergyCreditGap.tla`

Trace:
1. initial state
2. `ClaimResidentialCleanEnergyCredit`

Observed state:
- `creditClaimed = TRUE`
- `creditAllowed = 10000`
- `equipmentInstalled = FALSE`

Expected invariant:
- `creditClaimed => /\ equipmentInstalled /\ creditAllowed <= EquipmentCost * CreditRate`

Meaning:
- the model permits the residential clean energy credit to be claimed without installing qualifying equipment
- this is the residential-clean-energy gap: the credit is available even though the installation gate never becomes true in the state machine

### 90. Clean vehicle credit qualification failure

Model: `work/TaxCleanVehicleCreditGap.tla`

Trace:
1. initial state
2. `ClaimCleanVehicleCredit`

Observed state:
- `creditClaimed = TRUE`
- `creditAllowed = 42000`
- `qualifiedVehicle = FALSE`

Expected invariant:
- `creditClaimed => /\ qualifiedVehicle /\ creditAllowed <= VehicleCreditCap`

Meaning:
- the model permits the clean vehicle credit to be claimed on an unqualified vehicle and above the statutory cap
- this is the clean-vehicle gap: the credit is available even though the qualification gate never becomes true in the state machine

### 91. Earned income credit qualification failure

Model: `work/TaxEITCQualificationGap.tla`

Trace:
1. initial state
2. `ClaimEITC`

Observed state:
- `eitcClaimed = TRUE`
- `earnedIncome = 0`
- `qualifyingChild = FALSE`

Expected invariant:
- `eitcClaimed => /\ earnedIncome > EarnedIncomeThreshold /\ qualifyingChild`

Meaning:
- the model permits the earned income tax credit to be claimed without earned income and without a qualifying child
- this is the EITC gap: the refund credit is available even though the basic eligibility gate never becomes true in the state machine

### 92. Saver's credit eligibility failure

Model: `work/TaxSaversCreditGap.tla`

Trace:
1. initial state
2. `ClaimSaversCredit`

Observed state:
- `saverCreditClaimed = TRUE`
- `ageEligible = FALSE`
- `studentEligible = FALSE`
- `dependentEligible = FALSE`
- `creditAllowed = 2000`

Expected invariant:
- `saverCreditClaimed => /\ ageEligible /\ ~studentEligible /\ ~dependentEligible /\ creditAllowed <= AGICap`

Meaning:
- the model permits the saver’s credit to be claimed without the age, student, and dependent eligibility filters
- this is the saver’s-credit gap: the benefit is available even though the basic eligibility gate never becomes true in the state machine

### 93. Energy efficient home improvement qualification failure

Model: `work/TaxEnergyEfficientHomeImprovementGap.tla`

Trace:
1. initial state
2. `ClaimEnergyEfficientHomeImprovementCredit`

Observed state:
- `creditClaimed = TRUE`
- `creditAllowed = 10000`
- `qualifiedImprovement = FALSE`

Expected invariant:
- `creditClaimed => /\ qualifiedImprovement /\ creditAllowed <= CreditCap`

Meaning:
- the model permits the energy efficient home improvement credit to be claimed without a qualified improvement and above the annual cap
- this is the energy-improvement gap: the credit is available even though the qualification gate never becomes true in the state machine

### 94. Lifetime learning credit higher-education failure

Model: `work/TaxLifetimeLearningCreditGap.tla`

Trace:
1. initial state
2. `ClaimLifetimeLearningCredit`

Observed state:
- `llcClaimed = TRUE`
- `higherEducation = FALSE`
- `creditAllowed = 5000`

Expected invariant:
- `llcClaimed => /\ higherEducation /\ creditAllowed <= LLCap`

Meaning:
- the model permits the lifetime learning credit to be claimed without higher-education status and above the cap
- this is the lifetime-learning-credit gap: the credit is available even though the qualification gate never becomes true in the state machine

### 95. Net operating loss limit failure

Model: `work/TaxNetOperatingLossGap.tla`

Trace:
1. initial state
2. `ClaimNOL`

Observed state:
- `nolClaimed = TRUE`
- `taxableIncome = 10000`
- `nolAllowed = 20000`

Expected invariant:
- `nolClaimed => /\ Deductions > Income /\ nolAllowed <= NOLLimit`

Meaning:
- the model permits a net operating loss deduction to be claimed in full even when deductions exceed income and the limit should cap it
- this is the NOL gap: the deduction is modeled above the statutory ceiling instead of being clipped to it

### 96. Alimony deduction agreement failure

Model: `work/TaxAlimonyDeductionGap.tla`

Trace:
1. initial state
2. `PayAlimony`

Observed state:
- `alimonyPaid = TRUE`
- `recipientSSNProvided = FALSE`
- `deductionAllowed = 1`

Expected invariant:
- `alimonyPaid => /\ DivorceYear <= 2018 /\ recipientSSNProvided /\ deductionAllowed = 1`

Meaning:
- the model permits an alimony deduction to be taken for a post-2018 divorce without the recipient SSN/ITIN gate
- this is the alimony gap: the deduction is modeled as available even though the agreement-year and identification gates never become true in the state machine

### 97. American opportunity credit qualification failure

Model: `work/TaxAmericanOpportunityCreditGap.tla`

Trace:
1. initial state
2. `ClaimAOTC`

Observed state:
- `aotcClaimed = TRUE`
- `firstFourYearsEligible = FALSE`
- `form1098TReceived = FALSE`
- `creditAllowed = 6000`

Expected invariant:
- `aotcClaimed => /\ firstFourYearsEligible /\ form1098TReceived /\ creditAllowed <= CreditCap`

Meaning:
- the model permits the American opportunity credit to be claimed without first-four-years eligibility and without Form 1098-T
- this is the AOTC gap: the credit is available even though the higher-education gate never becomes true in the state machine

### 98. Unemployment compensation reporting failure

Model: `work/TaxUnemploymentCompensationGap.tla`

Trace:
1. initial state
2. `ReceiveUC`

Observed state:
- `ucReceived = TRUE`
- `form1099GReceived = FALSE`
- `incomeIncluded = TRUE`

Expected invariant:
- `ucReceived => /\ form1099GReceived /\ incomeIncluded`

Meaning:
- the model permits unemployment compensation to be included in income without the Form 1099-G reporting step
- this is the unemployment-compensation gap: the income is modeled as reported on the return without the information-return gate becoming true in the state machine

### 99. Bartering income inclusion failure

Model: `work/TaxBarterIncomeGap.tla`

Trace:
1. initial state
2. `ReceiveBarter`

Observed state:
- `barterReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `barterReceived => incomeIncluded`

Meaning:
- the model permits goods or services received in barter to exist in the state machine without being added to gross income
- this is the bartering-income gap: the IRS rule says the fair market value must be included in income at the time received, but the semantic gate never turns on

### 100. Prize and award income inclusion failure

Model: `work/TaxPrizeAwardGap.tla`

Trace:
1. initial state
2. `ReceivePrize`

Observed state:
- `prizeReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `prizeReceived => incomeIncluded`

Meaning:
- the model permits a prize or award to exist without being included in gross income
- this is the prize-and-award gap: the IRS rule says the cash value of most prizes and awards is taxable, but the semantic gate never turns on in the state machine

### 101. Gambling winnings income inclusion failure

Model: `work/TaxGamblingWinningsGap.tla`

Trace:
1. initial state
2. `ReceiveWinnings`

Observed state:
- `winningsReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `winningsReceived => incomeIncluded`

Meaning:
- the model permits gambling winnings to exist without being included in gross income
- this is the gambling-winnings gap: the IRS rule says winnings are fully taxable and must be reported, but the semantic gate never turns on in the state machine

### 102. Canceled debt income inclusion failure

Model: `work/TaxCanceledDebtGap.tla`

Trace:
1. initial state
2. `CancelDebt`

Observed state:
- `debtCanceled = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `debtCanceled => incomeIncluded`

Meaning:
- the model permits canceled debt to exist without being included in gross income
- this is the canceled-debt gap: the IRS rule says taxable cancellation of debt is ordinary income unless an exception applies, but the semantic gate never turns on in the state machine

### 103. Lottery installment income inclusion failure

Model: `work/TaxLotteryInstallmentGap.tla`

Trace:
1. initial state
2. `ReceiveInstallment`

Observed state:
- `installmentReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `installmentReceived => incomeIncluded`

Meaning:
- the model permits a lottery installment payment to exist without being included in gross income
- this is the lottery-installment gap: the IRS rule says annual payments from an installment prize belong in gross income when received, but the semantic gate never turns on in the state machine

### 104. Court award income inclusion failure

Model: `work/TaxCourtAwardGap.tla`

Trace:
1. initial state
2. `ReceiveAward`

Observed state:
- `awardReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `awardReceived => incomeIncluded`

Meaning:
- the model permits a court award or damages payment to exist without being included in gross income
- this is the court-award gap: the IRS rule says many settlement and judgment amounts are taxable depending on what they replace, but the semantic gate never turns on in the state machine

### 105. Cash rebate treatment failure

Model: `work/TaxCashRebateGap.tla`

Trace:
1. initial state
2. `ReceiveRebate`

Observed state:
- `rebateReceived = TRUE`
- `incomeIncluded = TRUE`
- `basisAdjusted = FALSE`

Expected invariant:
- `rebateReceived => /\ ~incomeIncluded /\ basisAdjusted`

Meaning:
- the model treats a dealer or manufacturer rebate as income instead of a basis reduction
- this is the cash-rebate gap: IRS Publication 525 says a cash rebate is not income, and the model violates that semantic split immediately

### 106. Child support income inclusion failure

Model: `work/TaxChildSupportGap.tla`

Trace:
1. initial state
2. `ReceiveChildSupport`

Observed state:
- `childSupportReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `childSupportReceived => ~incomeIncluded`

Meaning:
- the model treats child support as taxable income
- this is the child-support gap: the IRS says child support is neither deductible by the payer nor taxable to the recipient, but the state machine routes it into income anyway

### 107. Taxable scholarship inclusion failure

Model: `work/TaxScholarshipGap.tla`

Trace:
1. initial state
2. `ReceiveScholarship`

Observed state:
- `scholarshipReceived = TRUE`
- `qualifiedExpenseUsed = FALSE`
- `incomeIncluded = FALSE`

Expected invariant:
- `scholarshipReceived /\ ~qualifiedExpenseUsed => incomeIncluded`

Meaning:
- the model permits a scholarship to be received without including the taxable portion in income
- this is the scholarship gap: IRS guidance says amounts used for room and board or services are taxable, but the state machine leaves the taxable branch out

### 108. Qualified Medicaid waiver exclusion failure

Model: `work/TaxMedicaidWaiverGap.tla`

Trace:
1. initial state
2. `ReceivePayment`

Observed state:
- `paymentReceived = TRUE`
- `sharedHome = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `paymentReceived /\ sharedHome => ~incomeIncluded`

Meaning:
- the model treats a qualified Medicaid waiver payment as taxable income even when the care is furnished in the shared home
- this is the Medicaid-waiver gap: IRS Notice 2014-7 excludes the qualified payment from gross income, but the state machine routes it into income anyway

### 109. Punitive damages income inclusion failure

Model: `work/TaxPunitiveDamagesGap.tla`

Trace:
1. initial state
2. `ReceivePunitiveDamages`

Observed state:
- `punitiveDamagesReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `punitiveDamagesReceived => incomeIncluded`

Meaning:
- the model permits punitive damages to be received without being included in gross income
- this is the punitive-damages gap: IRS guidance treats punitive damages as taxable in most cases, but the semantic gate never turns on in the state machine

### 110. State tax refund inclusion failure

Model: `work/TaxStateTaxRefundGap.tla`

Trace:
1. initial state
2. `ReceiveRefund`

Observed state:
- `refundReceived = TRUE`
- `itemizedLastYear = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `refundReceived /\ itemizedLastYear => incomeIncluded`

Meaning:
- the model permits a state income tax refund to exist without being included in gross income even after a prior itemized deduction
- this is the state-tax-refund gap: IRS guidance says the refund can be taxable when the earlier deduction produced a tax benefit, but the state machine leaves that gate out

### 111. State tax refund tax-benefit gate failure

Model: `work/TaxStateTaxRefundGateGap.tla`

Trace:
1. initial state
2. `ReceiveRefund`

Observed state:
- `refundReceived = TRUE`
- `itemizedLastYear = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `refundReceived /\ itemizedLastYear => incomeIncluded`

Meaning:
- the model permits a state tax refund to be received without any taxable-income decision, even though the prior-year itemized deduction gate is true
- this is the refund-gate gap: the IRS tax-benefit rule is missing from the state machine

### 112. Qualified disaster relief exclusion failure

Model: `work/TaxDisasterReliefGap.tla`

Trace:
1. initial state
2. `ReceiveRelief`

Observed state:
- `reliefReceived = TRUE`
- `qualifiedDisaster = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `reliefReceived /\ qualifiedDisaster => ~incomeIncluded`

Meaning:
- the model treats qualified disaster relief payments as taxable income
- this is the disaster-relief gap: IRS guidance generally excludes qualified disaster relief payments, but the state machine routes them into income

### 113. Welfare benefit taxability failure

Model: `work/TaxWelfareBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveWelfare`

Observed state:
- `welfareReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `welfareReceived => ~incomeIncluded`

Meaning:
- the model treats need-based welfare benefits as taxable income
- this is the welfare-benefit gap: IRS guidance says public welfare benefits are not included in income, but the state machine routes them into income anyway

### 114. Workers' compensation exclusion failure

Model: `work/TaxWorkersCompGap.tla`

Trace:
1. initial state
2. `ReceiveWorkersComp`

Observed state:
- `workersCompReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `workersCompReceived => ~incomeIncluded`

Meaning:
- the model treats workers' compensation as taxable income
- this is the workers-comp gap: IRS Publication 525 says workers' compensation benefits are generally excluded, but the state machine routes them into income anyway

### 115. Life insurance death benefit exclusion failure

Model: `work/TaxLifeInsuranceGap.tla`

Trace:
1. initial state
2. `ReceiveDeathBenefit`

Observed state:
- `deathBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `deathBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats life insurance death benefits as taxable income
- this is the life-insurance gap: IRS Publication 525 says proceeds paid because of the insured person's death are generally not taxable, but the state machine routes them into income anyway

### 116. Gift and inheritance income exclusion failure

Model: `work/TaxGiftInheritanceIncomeGap.tla`

Trace:
1. initial state
2. `ReceiveGiftOrInheritance`

Observed state:
- `giftOrInheritanceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `giftOrInheritanceReceived => ~incomeIncluded`

Meaning:
- the model treats gifts and inheritances as taxable income
- this is the gift-and-inheritance gap: IRS Publication 525 says property received as a gift, bequest, or inheritance generally is not included in income, but the state machine routes it into income anyway

### 117. Found property income inclusion failure

Model: `work/TaxFoundPropertyGap.tla`

Trace:
1. initial state
2. `FindProperty`

Observed state:
- `propertyFound = TRUE`
- `undisputedPossession = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `propertyFound /\ undisputedPossession => incomeIncluded`

Meaning:
- the model permits found property to be held in undisputed possession without income inclusion
- this is the found-property gap: IRS Publication 525 says treasure trove is taxable at FMV in the first year of undisputed possession, but the state machine leaves that branch out

### 118. Bequest for services income inclusion failure

Model: `work/TaxBequestForServicesGap.tla`

Trace:
1. initial state
2. `ReceiveBequest`

Observed state:
- `bequestReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `bequestReceived => incomeIncluded`

Meaning:
- the model permits a bequest for services to exist without income inclusion
- this is the bequest-for-services gap: IRS Publication 525 says cash or other property received as a bequest for services is taxable compensation, but the state machine leaves that branch out

### 119. Expected inheritance sale income inclusion failure

Model: `work/TaxExpectedInheritanceSaleGap.tla`

Trace:
1. initial state
2. `SellExpectedInheritance`

Observed state:
- `expectedInheritanceSold = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `expectedInheritanceSold => incomeIncluded`

Meaning:
- the model permits the sale of an expected inheritance interest without income inclusion
- this is the expected-inheritance gap: IRS Publication 525 says you include the entire amount from selling an interest in an expected inheritance in gross income, but the state machine leaves that branch out

### 120. Gulf oil spill payment inclusion failure

Model: `work/TaxGulfOilSpillPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveGulfPayment`

Observed state:
- `gulfPaymentReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `gulfPaymentReceived => incomeIncluded`

Meaning:
- the model permits a Gulf oil spill payment to be received without income inclusion
- this is the Gulf-oil-spill gap: IRS Publication 525 says payments for lost wages or income may be taxable, but the state machine leaves the taxable branch out

### 121. Free tour income inclusion failure

Model: `work/TaxFreeTourGap.tla`

Trace:
1. initial state
2. `ReceiveFreeTour`

Observed state:
- `freeTourReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `freeTourReceived => incomeIncluded`

Meaning:
- the model permits a free tour reward to be received without income inclusion
- this is the free-tour gap: IRS Publication 525 says the value of a free tour from a travel agency for organizing tourists is taxable, but the state machine leaves that branch out

### 122. Employee achievement award exclusion failure

Model: `work/TaxEmployeeAchievementAwardGap.tla`

Trace:
1. initial state
2. `ReceiveAward`

Observed state:
- `awardReceived = TRUE`
- `qualifiedAward = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `awardReceived /\ qualifiedAward => ~incomeIncluded`

Meaning:
- the model treats a qualified employee achievement award as taxable income
- this is the employee-achievement-award gap: IRS guidance says qualifying tangible personal property awards for length of service or safety achievement are generally excludable, but the state machine routes them into income anyway

### 123. Qualified employee award exclusion failure

Model: `work/TaxQualifiedEmployeeAwardGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedAward`

Observed state:
- `awardReceived = TRUE`
- `qualifiedAward = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `awardReceived /\ qualifiedAward => ~incomeIncluded`

Meaning:
- the model treats a qualifying employee achievement award as taxable income
- this is the qualified-employee-award gap: IRS Publication 525 and Publication 15-B exclude qualifying tangible personal property awards, but the state machine routes them into income anyway

### 124. Tips income inclusion failure

Model: `work/TaxTipsGap.tla`

Trace:
1. initial state
2. `ReceiveTips`

Observed state:
- `tipsReceived = TRUE`
- `incomeIncluded = FALSE`

Expected invariant:
- `tipsReceived => incomeIncluded`

Meaning:
- the model permits tips to be received without being included in gross income
- this is the tips gap: IRS guidance treats tips as taxable income and requires reporting, but the state machine leaves that branch out

### 125. Frozen deposit interest exclusion failure

Model: `work/TaxFrozenDepositInterestGap.tla`

Trace:
1. initial state
2. `ReceiveInterest`

Observed state:
- `frozenDepositInterestReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `frozenDepositInterestReceived => ~incomeIncluded`

Meaning:
- the model treats interest on a frozen deposit as taxable income
- this is the frozen-deposit-interest gap: IRS Publication 525 says interest earned on a frozen deposit is generally excludable, but the state machine routes it into income anyway

### 126. FECA payment exclusion failure

Model: `work/TaxFECACompensationGap.tla`

Trace:
1. initial state
2. `ReceiveFECA`

Observed state:
- `fecaPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `fecaPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats FECA payments as taxable income
- this is the FECA gap: IRS Publication 525 says Federal Employees' Compensation Act payments for personal injury or sickness are generally not taxable, but the state machine routes them into income anyway

### 127. Black lung benefit exclusion failure

Model: `work/TaxBlackLungBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveBlackLungBenefit`

Observed state:
- `blackLungBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `blackLungBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats black lung benefit payments as taxable income
- this is the black-lung-benefit gap: IRS Publication 525 says black lung benefit payments are generally not taxable, but the state machine routes them into income anyway

### 128. VA disability benefit exclusion failure

Model: `work/TaxVADisabilityGap.tla`

Trace:
1. initial state
2. `ReceiveVABenefit`

Observed state:
- `vaBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `vaBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats VA disability benefits as taxable income
- this is the VA-disability gap: IRS guidance says VA disability benefits are excluded from gross income, but the state machine routes them into income anyway

### 129. Combat pay exclusion failure

Model: `work/TaxCombatPayGap.tla`

Trace:
1. initial state
2. `ReceiveCombatPay`

Observed state:
- `combatPayReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `combatPayReceived => ~incomeIncluded`

Meaning:
- the model treats combat pay as taxable income
- this is the combat-pay gap: IRS Publication 3 and IRS combat-zone guidance say qualifying combat pay is excludable, but the state machine routes it into income anyway

### 130. Military moving expense reimbursement exclusion failure

Model: `work/TaxMilitaryMovingExpenseGap.tla`

Trace:
1. initial state
2. `ReceiveMilitaryMoveReimbursement`

Observed state:
- `militaryMoveReimbursed = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `militaryMoveReimbursed => ~incomeIncluded`

Meaning:
- the model treats an active-duty military moving reimbursement as taxable income
- this is the military-moving gap: IRS Publication 15 and Publication 3 preserve the exclusion for qualifying active-duty PCS moves, but the state machine routes the reimbursement into income anyway

### 131. Group-term life insurance exclusion failure

Model: `work/TaxGroupTermLifeInsuranceGap.tla`

Trace:
1. initial state
2. `ReceiveGroupTermLifeCoverage`

Observed state:
- `groupTermLifeCovered = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `groupTermLifeCovered => ~incomeIncluded`

Meaning:
- the model treats qualifying employer-provided group-term life coverage as taxable income
- this is the group-term-life gap: IRS Publication 525 and Publication 15-B exclude the first $50,000 of qualifying coverage from income, but the state machine routes the coverage into income anyway

### 132. Retirement planning services exclusion failure

Model: `work/TaxRetirementPlanningServicesGap.tla`

Trace:
1. initial state
2. `ReceiveRetirementPlanningService`

Observed state:
- `retirementPlanningServiceProvided = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `retirementPlanningServiceProvided => ~incomeIncluded`

Meaning:
- the model treats qualified retirement planning services as taxable income
- this is the retirement-planning-services gap: IRS Publication 525 says qualified retirement planning services provided by an employer may be excluded from income, but the state machine routes the value into income anyway

### 133. Adoption assistance exclusion failure

Model: `work/TaxAdoptionAssistanceGap.tla`

Trace:
1. initial state
2. `ReceiveAdoptionAssistance`

Observed state:
- `adoptionAssistanceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `adoptionAssistanceReceived => ~incomeIncluded`

Meaning:
- the model treats employer-provided adoption assistance as taxable income
- this is the adoption-assistance gap: IRS Publication 525 and Publication 15-B say qualifying adoption benefits may be excluded from income, but the state machine routes the benefit into income anyway

### 134. Educational assistance exclusion failure

Model: `work/TaxEducationalAssistanceGap.tla`

Trace:
1. initial state
2. `ReceiveEducationalAssistance`

Observed state:
- `educationalAssistanceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `educationalAssistanceReceived => ~incomeIncluded`

Meaning:
- the model treats employer-provided educational assistance as taxable income
- this is the educational-assistance gap: IRS Publication 525 says qualified educational assistance under section 127 may be excluded from income, but the state machine routes the benefit into income anyway

### 135. Qualified transportation benefit exclusion failure

Model: `work/TaxQualifiedTransportationBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveTransportationBenefit`

Observed state:
- `transportationBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `transportationBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified transportation fringe as taxable income
- this is the transportation-benefit gap: IRS Publication 15-B says qualified parking and commuter transportation benefits are excludable up to the monthly limit, but the state machine routes the benefit into income anyway

### 136. Dependent care benefit exclusion failure

Model: `work/TaxDependentCareBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveDependentCareBenefit`

Observed state:
- `dependentCareBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `dependentCareBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats employer-provided dependent care benefits as taxable income
- this is the dependent-care-benefit gap: IRS Publication 503 and the Form 2441 instructions say you may exclude all or part of qualifying dependent care benefits, but the state machine routes the benefit into income anyway

### 137. No-additional-cost service exclusion failure

Model: `work/TaxNoAdditionalCostServiceGap.tla`

Trace:
1. initial state
2. `ReceiveNoAdditionalCostService`

Observed state:
- `noAdditionalCostServiceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `noAdditionalCostServiceReceived => ~incomeIncluded`

Meaning:
- the model treats a no-additional-cost service as taxable income
- this is the no-additional-cost-service gap: IRS Publication 15-B excludes qualifying services when they cost the employer nothing additional, but the state machine routes the value into income anyway

### 138. Employer-provided cell phone exclusion failure

Model: `work/TaxCellPhoneBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveCellPhone`

Observed state:
- `cellPhoneProvided = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `cellPhoneProvided => ~incomeIncluded`

Meaning:
- the model treats an employer-provided cell phone as taxable income
- this is the cell-phone gap: IRS Publication 15-B says business-use cell phones provided primarily for noncompensatory business reasons are excludable, but the state machine routes the benefit into income anyway

### 139. Qualified employee discount exclusion failure

Model: `work/TaxQualifiedEmployeeDiscountGap.tla`

Trace:
1. initial state
2. `ReceiveEmployeeDiscount`

Observed state:
- `employeeDiscountReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employeeDiscountReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified employee discount as taxable income
- this is the employee-discount gap: IRS Publication 15-B says qualified employee discounts are excludable, but the state machine routes the benefit into income anyway

### 140. Employer-operated eating facility meal exclusion failure

Model: `work/TaxEmployerMealFacilityGap.tla`

Trace:
1. initial state
2. `ReceiveEmployerMeal`

Observed state:
- `employerMealReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employerMealReceived => ~incomeIncluded`

Meaning:
- the model treats meals from an employer-operated eating facility as taxable income
- this is the employer-meal gap: IRS Publication 15-B and Publication 15 exclude qualifying meals furnished through an employer-operated eating facility, but the state machine routes the meal value into income anyway

### 141. Tuition reduction exclusion failure

Model: `work/TaxTuitionReductionGap.tla`

Trace:
1. initial state
2. `ReceiveTuitionReduction`

Observed state:
- `tuitionReductionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `tuitionReductionReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified tuition reduction as taxable income
- this is the tuition-reduction gap: IRS Publication 15-B and Publication 970 say qualifying tuition reductions can be excluded, but the state machine routes the reduction into income anyway

### 142. Working condition benefit exclusion failure

Model: `work/TaxWorkingConditionBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveWorkingConditionBenefit`

Observed state:
- `workingConditionBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `workingConditionBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats a working condition benefit as taxable income
- this is the working-condition gap: IRS Publication 15-B says property or services that would have been deductible as business expenses can be excluded, but the state machine routes the value into income anyway

### 143. De minimis benefit exclusion failure

Model: `work/TaxDeMinimisBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveDeMinimisBenefit`

Observed state:
- `deMinimisBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `deMinimisBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats a de minimis fringe benefit as taxable income
- this is the de minimis-benefit gap: IRS Publication 15-B excludes small occasional perks and other de minimis benefits, but the state machine routes the value into income anyway

### 147. De minimis transportation benefit exclusion failure

Model: `work/TaxDeMinimisTransportationGap.tla`

Trace:
1. initial state
2. `ReceiveDeMinimisTransportation`

Observed state:
- `deMinimisTransportationReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `deMinimisTransportationReceived => ~incomeIncluded`

Meaning:
- the model treats an occasional local transportation fare as taxable income
- this is the de minimis transportation gap: IRS de minimis guidance and Publication 15-B exclude occasional local transportation fare provided to enable overtime work, but the state machine routes the value into income anyway

### 145. Occasional snack benefit exclusion failure

Model: `work/TaxSnackBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveSnackBenefit`

Observed state:
- `snackBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `snackBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats occasional snacks or coffee as taxable income
- this is the snack-benefit gap: IRS de minimis guidance excludes occasional snacks, coffee, doughnuts, and similar small perks, but the state machine routes the value into income anyway

### 146. Athletic facility exclusion failure

Model: `work/TaxAthleticFacilityGap.tla`

Trace:
1. initial state
2. `ReceiveAthleticFacilityUse`

Observed state:
- `athleticFacilityUseReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `athleticFacilityUseReceived => ~incomeIncluded`

Meaning:
- the model treats use of an on-premises athletic facility as taxable income
- this is the athletic-facility gap: IRS Publication 15-B and Publication 525 exclude qualifying on-premises athletic facility use, but the state machine routes the value into income anyway

### 148. Work-life referral service exclusion failure

Model: `work/TaxWorkLifeReferralGap.tla`

Trace:
1. initial state
2. `ReceiveWorkLifeReferral`

Observed state:
- `workLifeReferralReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `workLifeReferralReceived => ~incomeIncluded`

Meaning:
- the model treats employer-provided work-life referral services as taxable income
- this is the work-life-referral gap: IRS FAQ guidance says such referral and information services are excludable as a de minimis fringe benefit, but the state machine routes the value into income anyway

### 149. Dependent group-term life insurance exclusion failure

Model: `work/TaxDependentLifeInsuranceGap.tla`

Trace:
1. initial state
2. `ReceiveDependentLifeInsurance`

Observed state:
- `dependentLifeInsuranceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `dependentLifeInsuranceReceived => ~incomeIncluded`

Meaning:
- the model treats employer-paid group-term life insurance on a spouse or dependent as taxable income
- this is the dependent-life-insurance gap: IRS Publication 15-B says the cost is excludable when the face amount is not more than $2,000, but the state machine routes the cost into income anyway

### 150. Employer convenience meal exclusion failure

Model: `work/TaxEmployerConvenienceMealGap.tla`

Trace:
1. initial state
2. `ReceiveEmployerConvenienceMeal`

Observed state:
- `employerConvenienceMealReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employerConvenienceMealReceived => ~incomeIncluded`

Meaning:
- the model treats meals furnished on the employer’s premises for the employer’s convenience as taxable income
- this is the employer-convenience-meal gap: IRS Publication 15 and Publication 15-B exclude qualifying meals, but the state machine routes the value into income anyway

### 152. Employer lodging exclusion failure

Model: `work/TaxEmployerLodgingGap.tla`

Trace:
1. initial state
2. `ReceiveEmployerLodging`

Observed state:
- `employerLodgingReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employerLodgingReceived => ~incomeIncluded`

Meaning:
- the model treats lodging furnished on the employer’s business premises as taxable income
- this is the employer-lodging gap: IRS Publication 15, Publication 15-B, and Publication 525 exclude qualifying lodging furnished for the employer’s convenience and as a condition of employment, but the state machine routes the value into income anyway

### 153. Employee picnic exclusion failure

Model: `work/TaxEmployeePicnicGap.tla`

Trace:
1. initial state
2. `ReceiveEmployeePicnic`

Observed state:
- `employeePicnicReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employeePicnicReceived => ~incomeIncluded`

Meaning:
- the model treats an occasional employee picnic or party as taxable income
- this is the employee-picnic gap: IRS de minimis guidance and Publication 15-B exclude occasional parties or picnics for employees and their guests, but the state machine routes the value into income anyway

### 154. Special circumstances gift exclusion failure

Model: `work/TaxSpecialCircumstancesGiftGap.tla`

Trace:
1. initial state
2. `ReceiveSpecialCircumstancesGift`

Observed state:
- `specialCircumstancesGiftReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `specialCircumstancesGiftReceived => ~incomeIncluded`

Meaning:
- the model treats flowers, fruit, books, or similar items given under special circumstances as taxable income
- this is the special-circumstances-gift gap: IRS de minimis guidance and Publication 15-B exclude those items when provided under special circumstances, but the state machine routes the value into income anyway

### 151. Qualified transportation fringe exclusion failure

Model: `work/TaxQualifiedTransportationFringeGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedTransportation`

Observed state:
- `qualifiedTransportationReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedTransportationReceived => ~incomeIncluded`

Meaning:
- the model treats qualified parking or transit pass benefits as taxable income
- this is the qualified-transportation-fringe gap: IRS Publication 15-B and IRC 132(a)(5) exclude qualifying transportation fringes up to the monthly limit, but the state machine routes the benefit into income anyway

### 144. Holiday gift exclusion failure

Model: `work/TaxHolidayGiftGap.tla`

Trace:
1. initial state
2. `ReceiveHolidayGift`

Observed state:
- `holidayGiftReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `holidayGiftReceived => ~incomeIncluded`

Meaning:
- the model treats a holiday gift as taxable income
- this is the holiday-gift gap: IRS de minimis guidance and Publication 15-B exclude low-value traditional holiday gifts, but the state machine routes the value into income anyway

### 155. Photocopier use exclusion failure

Model: `work/TaxPhotocopierUseGap.tla`

Trace:
1. initial state
2. `ReceivePhotocopierUse`

Observed state:
- `photocopierUseReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `photocopierUseReceived => ~incomeIncluded`

Meaning:
- the model treats controlled occasional photocopier use as taxable income
- this is the photocopier-use gap: IRS de minimis guidance and Publication 15-B exclude occasional employee photocopier use when accounting would be unreasonable, but the state machine routes the value into income anyway

### 156. Overtime meal money exclusion failure

Model: `work/TaxOvertimeMealMoneyGap.tla`

Trace:
1. initial state
2. `ReceiveOvertimeMealMoney`

Observed state:
- `overtimeMealMoneyReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `overtimeMealMoneyReceived => ~incomeIncluded`

Meaning:
- the model treats occasional meal money provided to enable overtime work as taxable income
- this is the overtime meal-money gap: the IRS de minimis fringe rules currently carve out occasional meal money for overtime, but the state machine routes the value into income anyway

### 157. Minister housing allowance exclusion failure

Model: `work/TaxMinisterHousingAllowanceGap.tla`

Trace:
1. initial state
2. `ReceiveMinisterHousingAllowance`

Observed state:
- `ministerHousingAllowanceReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `ministerHousingAllowanceReceived => ~incomeIncluded`

Meaning:
- the model treats a minister's housing allowance as taxable income
- this is the minister-housing-allowance gap: current IRS guidance says a properly designated housing or parsonage allowance can be excluded from gross income, but the state machine routes the value into income anyway

### 158. Qualified foster care payment exclusion failure

Model: `work/TaxQualifiedFosterCarePaymentGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedFosterCarePayment`

Observed state:
- `qualifiedFosterCarePaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedFosterCarePaymentReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified foster care payment as taxable income
- this is the qualified-foster-care gap: current IRS Publication 525 and section 131 exclude qualified foster care payments from gross income, but the state machine routes the value into income anyway

### 159. Qualified wildfire relief payment exclusion failure

Model: `work/TaxQualifiedWildfireReliefPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedWildfireReliefPayment`

Observed state:
- `qualifiedWildfireReliefPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedWildfireReliefPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified wildfire relief payment as taxable income
- this is the qualified-wildfire-relief gap: current IRS Publication 525 says qualified wildfire relief payments are not taxable, but the state machine routes the value into income anyway

### 160. Employer HSA contribution exclusion failure

Model: `work/TaxEmployerHSAContributionGap.tla`

Trace:
1. initial state
2. `ReceiveEmployerHSAContribution`

Observed state:
- `employerHSAContributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employerHSAContributionReceived => ~incomeIncluded`

Meaning:
- the model treats an employer HSA contribution as taxable income
- this is the employer-HSA gap: current IRS Publication 969 says employer contributions to an HSA are excluded from income, but the state machine routes the contribution into income anyway

### 161. Health FSA reimbursement exclusion failure

Model: `work/TaxHealthFSAReimbursementGap.tla`

Trace:
1. initial state
2. `ReceiveHealthFSAReimbursement`

Observed state:
- `healthFSAReimbursementReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `healthFSAReimbursementReceived => ~incomeIncluded`

Meaning:
- the model treats a health FSA reimbursement for qualified medical expenses as taxable income
- this is the health-FSA gap: current IRS Publication 969 says reimbursements from a health FSA that pay qualified medical expenses are not taxed, but the state machine routes the reimbursement into income anyway

### 162. HRA reimbursement exclusion failure

Model: `work/TaxHRAReimbursementGap.tla`

Trace:
1. initial state
2. `ReceiveHRAReimbursement`

Observed state:
- `hraReimbursementReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `hraReimbursementReceived => ~incomeIncluded`

Meaning:
- the model treats a health reimbursement arrangement reimbursement for qualified medical expenses as taxable income
- this is the HRA gap: current IRS Publication 969 says HRA reimbursements for qualified medical expenses are excluded from income, but the state machine routes the reimbursement into income anyway

### 163. Archer MSA distribution exclusion failure

Model: `work/TaxArcherMSADistributionGap.tla`

Trace:
1. initial state
2. `ReceiveArcherMSADistribution`

Observed state:
- `archerMSADistributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `archerMSADistributionReceived => ~incomeIncluded`

Meaning:
- the model treats an Archer MSA distribution used for qualified medical expenses as taxable income
- this is the Archer-MSA gap: current IRS Publication 969 says qualifying Archer MSA distributions are not taxed, but the state machine routes the distribution into income anyway

### 164. Medicare Advantage MSA contribution exclusion failure

Model: `work/TaxMedicareAdvantageMSAContributionGap.tla`

Trace:
1. initial state
2. `ReceiveMedicareAdvantageMSAContribution`

Observed state:
- `medicareAdvantageMSAContributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `medicareAdvantageMSAContributionReceived => ~incomeIncluded`

Meaning:
- the model treats a Medicare Advantage MSA contribution as taxable income
- this is the Medicare-Advantage-MSA gap: current IRS Publication 969 says Medicare Advantage MSA contributions are not included in income, but the state machine routes the contribution into income anyway

### 165. Long-term care coverage exclusion failure

Model: `work/TaxLongTermCareCoverageGap.tla`

Trace:
1. initial state
2. `ReceiveLongTermCareCoverage`

Observed state:
- `longTermCareCoverageReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `longTermCareCoverageReceived => ~incomeIncluded`

Meaning:
- the model treats employer-provided long-term care coverage as taxable income
- this is the long-term-care gap: current IRS Publication 525 says employer contributions to provide long-term care coverage generally aren’t included in income, but the state machine routes the coverage into income anyway

### 166. Retired public safety officer premium exclusion failure

Model: `work/TaxRetiredPublicSafetyOfficerPremiumGap.tla`

Trace:
1. initial state
2. `ReceiveRetiredPublicSafetyOfficerPremium`

Observed state:
- `retiredPublicSafetyOfficerPremiumReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `retiredPublicSafetyOfficerPremiumReceived => ~incomeIncluded`

Meaning:
- the model treats a retired public safety officer premium payment as taxable income
- this is the retired-public-safety-officer premium gap: current IRS Publication 575 says qualifying distributions used to pay those premiums can be excluded from gross income, but the state machine routes the payment into income anyway

### 167. Qualified long-term care insurance benefit exclusion failure

Model: `work/TaxQualifiedLongTermCareInsuranceBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedLongTermCareInsuranceBenefit`

Observed state:
- `qualifiedLongTermCareInsuranceBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedLongTermCareInsuranceBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats a benefit paid under a qualified long-term care insurance contract as taxable income
- this is the qualified-long-term-care-insurance gap: current IRS Publication 525 says amounts received under qualified long-term care insurance contracts are generally excludable, but the state machine routes the benefit into income anyway

### 168. Excludable restitution payment exclusion failure

Model: `work/TaxExcludableRestitutionPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveExcludableRestitutionPayment`

Observed state:
- `excludableRestitutionPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `excludableRestitutionPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats an excludable restitution payment as taxable income
- this is the excludable-restitution gap: current IRS Publication 525 says restitution payments made because of Nazi persecution are excludable, but the state machine routes the payment into income anyway

### 169. Combat-related special compensation exclusion failure

Model: `work/TaxCombatRelatedSpecialCompensationGap.tla`

Trace:
1. initial state
2. `ReceiveCombatRelatedSpecialCompensation`

Observed state:
- `combatRelatedSpecialCompensationReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `combatRelatedSpecialCompensationReceived => ~incomeIncluded`

Meaning:
- the model treats combat-related special compensation as taxable income
- this is the combat-related-special-compensation gap: current IRS Publication 525 says eligible combat-related special compensation can be excluded from income, but the state machine routes the compensation into income anyway

### 170. Terrorist attack disability payment exclusion failure

Model: `work/TaxTerroristAttackDisabilityPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveTerroristAttackDisabilityPayment`

Observed state:
- `terroristAttackDisabilityPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `terroristAttackDisabilityPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats a disability payment from a terrorist attack or military action as taxable income
- this is the terrorist-attack disability gap: current IRS Publication 525 says disability payments received for injuries incurred as a direct result of a terrorist attack or military action can be excluded from income, but the state machine routes the payment into income anyway

### 171. Service-connected disability pension exclusion failure

Model: `work/TaxServiceConnectedDisabilityPensionGap.tla`

Trace:
1. initial state
2. `ReceiveServiceConnectedDisabilityPension`

Observed state:
- `serviceConnectedDisabilityPensionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `serviceConnectedDisabilityPensionReceived => ~incomeIncluded`

Meaning:
- the model treats a service-connected disability pension as taxable income
- this is the service-connected-disability-pension gap: current IRS Publication 525 says certain military and government disability pensions for service-connected disability are not taxable, but the state machine routes the pension into income anyway

### 172. 529-to-Roth IRA rollover exclusion failure

Model: `work/Tax529ToRothRolloverGap.tla`

Trace:
1. initial state
2. `ReceiveQTPToRothRollover`

Observed state:
- `qtpToRothRolloverReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qtpToRothRolloverReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified tuition program rollover to a Roth IRA as taxable income
- this is the 529-to-Roth gap: current IRS guidance in Publication 525 and Publication 970 says certain direct trustee-to-trustee rollovers from long-term qualified tuition programs to Roth IRAs are not taxable, but the state machine routes the rollover into income anyway

### 173. East Palestine relief payment exclusion failure

Model: `work/TaxEastPalestineReliefPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveEastPalestineReliefPayment`

Observed state:
- `eastPalestineReliefPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `eastPalestineReliefPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats an East Palestine disaster relief payment as taxable income
- this is the East Palestine relief gap: current IRS Publication 525 and Publication 547 say certain relief payments related to the East Palestine train derailment are not taxable, but the state machine routes the payment into income anyway

### 174. Qualified equity grant deferral exclusion failure

Model: `work/TaxQualifiedEquityGrantDeferralGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedEquityGrantDeferral`

Observed state:
- `qualifiedEquityGrantDeferralReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedEquityGrantDeferralReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified equity grant deferral election as taxable income immediately
- this is the qualified-equity-grant gap: current IRS Publication 525 says eligible employees can elect to defer income taxation for certain qualified stock grants, but the state machine routes the grant into income anyway

### 175. SSI nontaxable exclusion failure

Model: `work/TaxSSINontaxableGap.tla`

Trace:
1. initial state
2. `ReceiveSSI`

Observed state:
- `ssiReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `ssiReceived => ~incomeIncluded`

Meaning:
- the model treats Supplemental Security Income as taxable income
- this is the SSI gap: current IRS Publication 525 says SSI benefits are not taxable, but the state machine routes the payment into income anyway

### 176. Lump-sum death benefit exclusion failure

Model: `work/TaxLumpSumDeathBenefitGap.tla`

Trace:
1. initial state
2. `ReceiveLumpSumDeathBenefit`

Observed state:
- `lumpSumDeathBenefitReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `lumpSumDeathBenefitReceived => ~incomeIncluded`

Meaning:
- the model treats a lump-sum death benefit as taxable income
- this is the lump-sum-death-benefit gap: current IRS Publication 525 says lump-sum death benefits paid to a spouse or children of the deceased aren’t subject to federal income tax, but the state machine routes the payment into income anyway

### 177. Terrorist attack survivor payment exclusion failure

Model: `work/TaxTerroristAttackSurvivorPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveTerroristAttackSurvivorPayment`

Observed state:
- `terroristAttackSurvivorPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `terroristAttackSurvivorPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats a survivor payment from a terrorist attack as taxable income
- this is the terrorist-attack survivor gap: current IRS Publication 3920 says payments to survivors of terrorist attacks are not included in income, but the state machine routes the payment into income anyway

### 178. Education savings bond interest exclusion failure

Model: `work/TaxEducationSavingsBondInterestGap.tla`

Trace:
1. initial state
2. `ReceiveEducationSavingsBondInterest`

Observed state:
- `educationSavingsBondInterestReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `educationSavingsBondInterestReceived => ~incomeIncluded`

Meaning:
- the model treats qualified U.S. savings bond interest used for higher education as taxable income
- this is the education-savings-bond gap: current IRS Publication 970 and Form 8815 say eligible Series EE and I bond interest may be excluded when used to pay qualified higher education expenses, but the state machine routes the interest into income anyway

### 179. Coverdell ESA distribution exclusion failure

Model: `work/TaxCoverdellESADistributionGap.tla`

Trace:
1. initial state
2. `ReceiveCoverdellESADistribution`

Observed state:
- `coverdellESADistributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `coverdellESADistributionReceived => ~incomeIncluded`

Meaning:
- the model treats a Coverdell ESA distribution for qualified education expenses as taxable income
- this is the Coverdell-ESA gap: current IRS Publication 970 says Coverdell ESA distributions are tax-free to the extent they don’t exceed qualified education expenses, but the state machine routes the distribution into income anyway

### 180. HSA qualified medical distribution exclusion failure

Model: `work/TaxHsaQualifiedMedicalDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveHsaQualifiedMedicalDistribution`

Observed state:
- `hsaQualifiedMedicalDistributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `hsaQualifiedMedicalDistributionReceived => ~incomeIncluded`

Meaning:
- the model treats an HSA distribution used for qualified medical expenses as taxable income
- this is the HSA-distribution gap: current IRS Publication 969 says HSA distributions used to pay qualified medical expenses aren’t taxed, but the state machine routes the distribution into income anyway

### 181. Emergency financial aid grant exclusion failure

Model: `work/TaxEmergencyFinancialAidGrantGap.tla`

Trace:
1. initial state
2. `ReceiveEmergencyFinancialAidGrant`

Observed state:
- `emergencyFinancialAidGrantReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `emergencyFinancialAidGrantReceived => ~incomeIncluded`

Meaning:
- the model treats an emergency financial aid grant as taxable income
- this is the emergency-financial-aid-grant gap: current IRS Publication 970 says higher education emergency grants under the CARES Act, CRRSAA, and ARP aren’t included in gross income, but the state machine routes the grant into income anyway

### 182. Disaster relief grant exclusion failure

Model: `work/TaxDisasterReliefGrantGap.tla`

Trace:
1. initial state
2. `ReceiveDisasterReliefGrant`

Observed state:
- `disasterReliefGrantReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `disasterReliefGrantReceived => ~incomeIncluded`

Meaning:
- the model treats a post-disaster grant as taxable income
- this is the disaster-relief-grant gap: current IRS Publication 525 and Publication 547 say post-disaster grants under the Disaster Relief and Emergency Assistance Act or Stafford Act can be excluded when they meet the expense and need rules, but the state machine routes the grant into income anyway

### 183. Qualified HSA funding distribution exclusion failure

Model: `work/TaxQualifiedHsaFundingDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedHsaFundingDistribution`

Observed state:
- `qualifiedHsaFundingDistributionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `qualifiedHsaFundingDistributionReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified HSA funding distribution as taxable income
- this is the qualified-HSA-funding gap: current IRS Publication 969 says a qualified HSA funding distribution from an IRA to an HSA isn’t included in income, but the state machine routes the distribution into income anyway

### 184. Employer student loan payment exclusion failure

Model: `work/TaxEmployerStudentLoanPaymentGap.tla`

Trace:
1. initial state
2. `ReceiveEmployerStudentLoanPayment`

Observed state:
- `employerStudentLoanPaymentReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `employerStudentLoanPaymentReceived => ~incomeIncluded`

Meaning:
- the model treats an employer-paid student loan principal or interest payment as taxable income
- this is the employer-student-loan gap: current IRS educational assistance guidance says qualified employer payments of employee student loan principal or interest can be excluded from gross income, but the state machine routes the payment into income anyway

### 185. Educator expense deduction exclusion failure

Model: `work/TaxEducatorExpenseDeductionGap.tla`

Trace:
1. initial state
2. `ReceiveEducatorExpenseDeduction`

Observed state:
- `educatorExpenseDeductionReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `educatorExpenseDeductionReceived => ~incomeIncluded`

Meaning:
- the model treats an eligible educator expense deduction as taxable income
- this is the educator-expense gap: current IRS guidance says eligible educators can deduct certain unreimbursed classroom expenses, but the state machine routes the amount into income anyway

### 186. Impairment-related work expense exclusion failure

Model: `work/TaxImpairmentRelatedWorkExpenseGap.tla`

Trace:
1. initial state
2. `ReceiveImpairmentRelatedWorkExpense`

Observed state:
- `impairmentRelatedWorkExpenseReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `impairmentRelatedWorkExpenseReceived => ~incomeIncluded`

Meaning:
- the model treats an impairment-related work expense as taxable income
- this is the impairment-related-work-expense gap: current IRS guidance says an individual with a disability can deduct impairment-related work expenses, but the state machine routes the amount into income anyway

### 187. Retired public safety officer health insurance premium exclusion failure

Model: `work/TaxRetiredPublicSafetyOfficerHealthInsuranceGap.tla`

Trace:
1. initial state
2. `ReceiveDirectPayment`

Observed state:
- `retiredPublicSafetyOfficerHealthInsurancePremiumReceived = TRUE`
- `premiumPaidDirectlyToInsurer = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `retiredPublicSafetyOfficerHealthInsurancePremiumReceived => ~incomeIncluded`

Meaning:
- the model treats a qualifying retired public safety officer health-insurance premium as taxable income
- this is the retired-public-safety-officer health-insurance gap: current IRS Pub. 575 and Form 7206 guidance allow an exclusion for qualifying distributions used to pay accident or health plan premiums, including both direct-to-insurer and reimbursed payment paths, but the state machine routes the distribution into income anyway

### 188. Public safety officer survivor annuity exclusion failure

Model: `work/TaxPublicSafetyOfficerSurvivorAnnuityGap.tla`

Trace:
1. initial state
2. `ReceiveSurvivorAnnuity`

Observed state:
- `survivorAnnuityReceived = TRUE`
- `officerKilledInLineOfDuty = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `officerKilledInLineOfDuty /\ survivorAnnuityReceived => ~incomeIncluded`

Meaning:
- the model treats a qualifying survivor annuity as taxable income
- this is the public-safety-officer survivor-annuity gap: current IRS Pub. 525, Pub. 721, and Pub. 559 guidance says a survivor annuity received by the spouse, former spouse, or child of a public safety officer killed in the line of duty can be excluded from income, but the state machine routes the annuity into income anyway

### 189. Fallen public safety officer dependent compensation exclusion failure

Model: `work/TaxFallenPublicSafetyOfficerDependentCompensationGap.tla`

Trace:
1. initial state
2. `ReceiveDependentCompensation`

Observed state:
- `dependentCompensationReceived = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `dependentCompensationReceived => ~incomeIncluded`

Meaning:
- the model treats compensation paid to dependents of a fallen public safety officer as taxable income
- this is the fallen-public-safety-officer dependent-compensation gap: current IRS guidance says certain DOJ payments and state-program benefits for surviving dependents of officers who died in the line of duty are excluded from gross income, but the state machine routes the compensation into income anyway

### 190. Emergency personal expense distribution penalty exception failure

Model: `work/TaxEmergencyPersonalExpenseDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveEmergencyPersonalExpenseDistribution`

Observed state:
- `emergencyPersonalExpenseDistributionReceived = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `emergencyPersonalExpenseDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a current SECURE 2.0 emergency personal expense distribution as subject to the 10% additional tax
- this is the emergency-personal-expense gap: current IRS retirement guidance says a qualifying distribution for personal or family emergency expenses is an exception to the early-distribution penalty, but the state machine applies the penalty anyway

### 191. Terminally ill individual distribution penalty exception failure

Model: `work/TaxTerminallyIllIndividualDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveTerminallyIllDistribution`

Observed state:
- `terminallyIllDistributionReceived = TRUE`
- `physicianCertificationPresent = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `physicianCertificationPresent /\ terminallyIllDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a terminally ill individual distribution as subject to the 10% additional tax
- this is the terminally-ill distribution gap: current IRS retirement guidance says a distribution made after physician certification of terminal illness is not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 192. Domestic abuse victim distribution penalty exception failure

Model: `work/TaxDomesticAbuseVictimDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveDomesticAbuseDistribution`

Observed state:
- `domesticAbuseVictimDistributionReceived = TRUE`
- `domesticAbuseEligibilityPresent = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `domesticAbuseEligibilityPresent /\ domesticAbuseVictimDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a domestic abuse victim distribution as subject to the 10% additional tax
- this is the domestic-abuse distribution gap: current IRS retirement guidance says an eligible distribution to a domestic abuse victim is not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 193. Qualified charitable distribution exclusion failure

Model: `work/TaxQualifiedCharitableDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQCD`

Observed state:
- `qcdReceived = TRUE`
- `ownerAge70HalfOrOlder = TRUE`
- `directToQualifiedCharity = TRUE`
- `incomeIncluded = TRUE`

Expected invariant:
- `ownerAge70HalfOrOlder /\ directToQualifiedCharity /\ qcdReceived => ~incomeIncluded`

Meaning:
- the model treats a qualified charitable distribution as taxable income
- this is the qualified-charitable-distribution gap: current IRS Publication 590-B and IRS IRA FAQ guidance says an otherwise taxable IRA distribution paid directly to a qualified charity by an owner age 70½ or older is generally nontaxable, but the state machine routes the distribution into income anyway

### 194. Qualified birth or adoption distribution penalty exception failure

Model: `work/TaxQualifiedBirthOrAdoptionDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedBirthOrAdoptionDistribution`

Observed state:
- `qualifiedBirthOrAdoptionDistributionReceived = TRUE`
- `ageUnder59Half = TRUE`
- `distributionWithinOneYearWindow = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `ageUnder59Half /\ distributionWithinOneYearWindow /\ qualifiedBirthOrAdoptionDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a qualified birth or adoption distribution as subject to the 10% additional tax
- this is the qualified-birth-or-adoption gap: current IRS Publication 590-B, Topic 558, and Form 5329 guidance says a qualifying distribution up to the statutory cap made within the one-year window is not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 195. Pension-linked emergency savings account distribution penalty exception failure

Model: `work/TaxPensionLinkedEmergencySavingsAccountGap.tla`

Trace:
1. initial state
2. `ReceivePLESADistribution`

Observed state:
- `plsAccountDistributionReceived = TRUE`
- `madeAfter2023 = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `madeAfter2023 /\ plsAccountDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a pension-linked emergency savings account distribution as subject to the 10% additional tax
- this is the PLESA gap: current IRS Topic 558 and related retirement guidance says distributions from a pension-linked emergency savings account made after 12/31/2023 are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 196. Automatic enrollment permissive withdrawal penalty exception failure

Model: `work/TaxAutomaticEnrollmentPermissiveWithdrawalGap.tla`

Trace:
1. initial state
2. `ReceiveAutoEnrollmentPermissiveWithdrawal`

Observed state:
- `autoEnrollmentPermissiveWithdrawalReceived = TRUE`
- `planHasAutoEnrollmentFeature = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `planHasAutoEnrollmentFeature /\ autoEnrollmentPermissiveWithdrawalReceived => ~additionalTaxApplied`

Meaning:
- the model treats an automatic-enrollment permissive withdrawal as subject to the 10% additional tax
- this is the automatic-enrollment gap: current IRS Topic 558 and automatic-enrollment guidance says qualifying permissive withdrawals from plans with automatic enrollment features are not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 197. Qualified reservist distribution penalty exception failure

Model: `work/TaxQualifiedReservistDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedReservistDistribution`

Observed state:
- `qualifiedReservistDistributionReceived = TRUE`
- `calledToActiveDutyOver179Days = TRUE`
- `withinActiveDutyWindow = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `calledToActiveDutyOver179Days /\ withinActiveDutyWindow /\ qualifiedReservistDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a qualified reservist distribution as subject to the 10% additional tax
- this is the qualified-reservist gap: current IRS Publication 560, Pub. 590-A, and Topic 558 guidance says a reservist distribution made during the active-duty window after a qualifying call-up is not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 198. Qualified reservist distribution active-duty exclusion failure

Model: `work/TaxQualifiedReservistDistributionRefinedGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedReservistDistribution`

Observed state:
- `qualifiedReservistDistributionReceived = TRUE`
- `isQualifiedReservistCalledToActiveDuty = TRUE`
- `isWithinActiveDutyPeriod = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `isQualifiedReservistCalledToActiveDuty /\ isWithinActiveDutyPeriod /\ qualifiedReservistDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a qualified reservist distribution as subject to the 10% additional tax even when the active-duty eligibility gates are satisfied
- this is the refined qualified-reservist gap: current IRS Publication 560, Publication 590-A, and Topic 558 say the exception should remove the early-distribution penalty for qualifying active-duty reservist distributions, but the state machine applies the penalty anyway

### 199. Unemployed health insurance premium distribution penalty exception failure

Model: `work/TaxUnemployedHealthInsurancePremiumDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveUnemployedHealthInsurancePremiumDistribution`

Observed state:
- `unemployedHealthInsurancePremiumDistributionReceived = TRUE`
- `received12WeeksOfUnemploymentCompensation = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `received12WeeksOfUnemploymentCompensation /\ unemployedHealthInsurancePremiumDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats an IRA distribution used to pay health insurance premiums during unemployment as subject to the 10% additional tax
- this is the unemployed-health-insurance-premium gap: current IRS Topic 557, Publication 590-B, and Form 5329 guidance says certain distributions used to pay medical insurance premiums while unemployed are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 200. Qualified first-time homebuyer distribution penalty exception failure

Model: `work/TaxQualifiedFirstTimeHomebuyerDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedFirstTimeHomebuyerDistribution`

Observed state:
- `qualifiedFirstTimeHomebuyerDistributionReceived = TRUE`
- `firstTimeHomebuyerQualified = TRUE`
- `withinTenThousandCap = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `firstTimeHomebuyerQualified /\ withinTenThousandCap /\ qualifiedFirstTimeHomebuyerDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a qualified first-time homebuyer distribution as subject to the 10% additional tax
- this is the qualified-first-time-homebuyer gap: current IRS Topic 558, Publication 590-B, and Form 5329 guidance says a qualifying distribution up to the statutory cap for a first-time home purchase is not subject to the early-withdrawal penalty, but the state machine applies the penalty anyway

### 201. Substantially equal periodic payments exception failure

Model: `work/TaxSubstantiallyEqualPeriodicPaymentsGap.tla`

Trace:
1. initial state
2. `ReceiveSEPPayment`

Observed state:
- `sepPaymentsReceived = TRUE`
- `paymentSeriesBegun = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `paymentSeriesBegun /\ sepPaymentsReceived => ~additionalTaxApplied`

Meaning:
- the model treats a series of substantially equal periodic payments as subject to the 10% additional tax
- this is the substantially-equal-periodic-payments gap: current IRS Topic 557, Topic 558, and Publication 590-B guidance says qualifying periodic payments can avoid the early-withdrawal penalty, but the state machine applies the penalty anyway

### 202. Qualified disaster recovery distribution penalty exception failure

Model: `work/TaxQualifiedDisasterRecoveryDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedDisasterRecoveryDistribution`

Observed state:
- `qualifiedDisasterRecoveryDistributionReceived = TRUE`
- `economicLossByQualifiedDisaster = TRUE`
- `amountWithinTwentyTwoThousandCap = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `economicLossByQualifiedDisaster /\ amountWithinTwentyTwoThousandCap /\ qualifiedDisasterRecoveryDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a qualified disaster recovery distribution as subject to the 10% additional tax
- this is the qualified-disaster-recovery gap: current IRS Publication 590-B, Topic 558, and Form 8915-F guidance says qualifying disaster recovery distributions up to the statutory cap are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 203. IRS levy distribution penalty exception failure

Model: `work/TaxIRSLevyDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveIRSLevyDistribution`

Observed state:
- `irsLevyDistributionReceived = TRUE`
- `levyIssuedAgainstPlan = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `levyIssuedAgainstPlan /\ irsLevyDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a distribution made because of an IRS levy of the plan as subject to the 10% additional tax
- this is the IRS-levy gap: current IRS Topic 558 says distributions made due to an IRS levy of the plan are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 204. IRA qualified higher education expenses penalty exception failure

Model: `work/TaxIRAQualifiedHigherEducationExpensesGap.tla`

Trace:
1. initial state
2. `ReceiveIRADistribution`

Observed state:
- `iraDistributionReceived = TRUE`
- `qualifiedHigherEducationExpensesPresent = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `qualifiedHigherEducationExpensesPresent /\ iraDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats an IRA distribution for qualified higher education expenses as subject to the 10% additional tax
- this is the IRA-qualified-higher-education-expenses gap: current IRS Publication 590-B, Topic 557, and Form 5329 guidance says IRA distributions used for qualified higher education expenses are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 205. Total and permanent disability distribution penalty exception failure

Model: `work/TaxTotalAndPermanentDisabilityDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveDisabilityDistribution`

Observed state:
- `disabilityDistributionReceived = TRUE`
- `totalAndPermanentDisabilityProved = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `totalAndPermanentDisabilityProved /\ disabilityDistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a distribution due to total and permanent disability as subject to the 10% additional tax
- this is the total-and-permanent-disability gap: current IRS Topic 558 and Form 5329 guidance says qualifying disability distributions are exempt from the early-withdrawal penalty, but the state machine applies the penalty anyway

### 206. Corrective IRA distribution penalty exception failure

Model: `work/TaxCorrectiveIRADistributionGap.tla`

Trace:
1. initial state
2. `ReceiveCorrectiveIRADistribution`

Observed state:
- `correctiveIRADistributionReceived = TRUE`
- `excessContributionCorrected = TRUE`
- `contributedOnOrAfter2022 = TRUE`
- `additionalTaxApplied = TRUE`

Expected invariant:
- `excessContributionCorrected /\ contributedOnOrAfter2022 /\ correctiveIRADistributionReceived => ~additionalTaxApplied`

Meaning:
- the model treats a corrective IRA distribution of excess contributions as subject to the 10% additional tax
- this is the corrective-IRA gap: current IRS Publication 590-A, Publication 590-B, and Form 5329 guidance says corrective IRA distributions of excess contributions made on or after December 29, 2022 are not subject to the 10% additional tax, but the state machine applies the penalty anyway

### 207. Digital asset broker basis reporting failure

Model: `work/TaxDigitalAssetBasisReportingGap.tla`

Trace:
1. initial state
2. `ReportBrokerSale`

Observed state:
- `saleDone = TRUE`
- `basisRequired = TRUE`
- `grossProceedsReported = TRUE`
- `basisReported = FALSE`

Expected invariant:
- `basisRequired /\ grossProceedsReported => basisReported`

Meaning:
- the model lets a brokered digital asset sale satisfy the proceeds-reporting path while omitting basis where basis is required
- this is the digital-asset basis-reporting gap: current IRS Form 1099-DA instructions say brokers report gross proceeds for digital asset sales and report basis for covered digital assets, but the state machine allows the sale to be reported without the basis layer that downstream gain calculation needs

### 208. Digital asset PDAP de minimis reporting failure

Model: `work/TaxDigitalAssetPDAPDeMinimisGap.tla`

Trace:
1. initial state
2. `RecordPDAPSale`

Observed state:
- `pdapSalesTotal = 700`
- `reportRequired = TRUE`
- `reportFiled = FALSE`

Expected invariant:
- `reportRequired => reportFiled`

Meaning:
- the model lets a processor-of-digital-asset-payments sale exceed the Form 1099-DA de minimis threshold while leaving the reporting obligation unmet
- this is the PDAP de minimis gap: current IRS Form 1099-DA instructions say PDAP sales above the $600 annual threshold must be reported, but the state machine allows the threshold-crossing sale to remain unreported

### 209. Clean vehicle transfer report acceptance failure

Model: `work/TaxCleanVehicleTransferReportGap.tla`

Trace:
1. initial state
2. `ElectTransfer`

Observed state:
- `transferElected = TRUE`
- `sellerReportAccepted = FALSE`
- `creditTransferred = TRUE`

Expected invariant:
- `creditTransferred => sellerReportAccepted`

Meaning:
- the model lets a clean-vehicle credit transfer be elected and applied even though the IRS seller report was never accepted
- this is the clean-vehicle transfer-report gap: current IRS clean vehicle guidance says the buyer needs an accepted time-of-sale seller report to claim the credit transfer, but the state machine allows the transfer path without that acceptance gate

### 210. Clean vehicle return credit consumption failure

Model: `work/TaxCleanVehicleReturnCreditGap.tla`

Trace:
1. initial state
2. `PlaceInService`
3. `ReturnVehicle`
4. `ClaimCredit`

Observed state:
- `vehiclePlacedInService = TRUE`
- `vehicleReturned = TRUE`
- `sellerReportAccepted = TRUE`
- `creditClaimed = TRUE`

Expected invariant:
- `vehicleReturned => ~creditClaimed`

Meaning:
- the model lets a clean vehicle be returned after being placed in service and still leaves the credit claimable
- this is the clean-vehicle return gap: current IRS clean vehicle return and cancellation guidance says a vehicle returned after being placed in service should not leave the credit available to either buyer, but the state machine still permits the credit claim after return

### 211. Commercial clean vehicle deadline failure

Model: `work/TaxCommercialCleanVehicleDeadlineGap.tla`

Trace:
1. initial state
2. `ClaimCommercialCleanVehicleCredit`

Observed state:
- `vehiclePlacedInService = TRUE`
- `vehicleAcquiredAfterDeadline = TRUE`
- `commercialCreditClaimed = TRUE`

Expected invariant:
- `vehicleAcquiredAfterDeadline => ~commercialCreditClaimed`

Meaning:
- the model lets a commercial clean vehicle credit be claimed even though the vehicle was acquired after the IRS deadline
- this is the commercial-clean-vehicle deadline gap: current IRS guidance says the qualified commercial clean vehicle credit is not available for vehicles acquired after September 30, 2025, but the state machine still permits the credit claim after that cutoff

### 212. Refueling property deadline failure

Model: `work/TaxRefuelingPropertyDeadlineGap.tla`

Trace:
1. initial state
2. `InstallProperty`

Observed state:
- `propertyInstalled = TRUE`
- `placedInServiceAfterDeadline = TRUE`
- `creditClaimed = TRUE`

Expected invariant:
- `placedInServiceAfterDeadline => ~creditClaimed`

Meaning:
- the model lets alternative fuel vehicle refueling property be placed in service after the current IRS cutoff and still claim the credit
- this is the refueling-property deadline gap: current IRS guidance says section 30C is not available for property placed in service after June 30, 2026, but the state machine still permits the credit claim after that deadline

### 213. Energy efficient commercial buildings certification failure

Model: `work/Tax179DCertificationGap.tla`

Trace:
1. initial state
2. `ClaimDeduction`

Observed state:
- `buildingPlacedInService = TRUE`
- `certificationReceived = FALSE`
- `deductionClaimed = TRUE`

Expected invariant:
- `deductionClaimed => certificationReceived`

Meaning:
- the model lets a section 179D deduction be claimed without the certification gate the IRS currently requires
- this is the 179D certification gap: current IRS guidance says the energy efficient commercial buildings deduction depends on a qualifying certification for the placed-in-service property, but the state machine allows the deduction anyway

### 214. New energy efficient home certification failure

Model: `work/Tax45LCertificationGap.tla`

Trace:
1. initial state
2. `AcquireHome`

Observed state:
- `homeAcquired = TRUE`
- `certifierIssuedCertification = FALSE`
- `creditClaimed = TRUE`

Expected invariant:
- `creditClaimed => certifierIssuedCertification`

Meaning:
- the model lets a builder claim the new energy efficient home credit without a certification of energy efficiency savings
- this is the 45L certification gap: current IRS Form 8908 guidance says the credit depends on the certifier-issued certification, but the state machine allows the credit claim anyway

### 215. Qualifying advanced energy project allocation failure

Model: `work/Tax48CAllocationGap.tla`

Trace:
1. initial state
2. `PlaceProjectInService`

Observed state:
- `projectPlacedInService = TRUE`
- `allocationAwarded = FALSE`
- `creditClaimed = TRUE`

Expected invariant:
- `creditClaimed => allocationAwarded`

Meaning:
- the model lets a qualifying advanced energy project be placed in service and the credit claimed without an allocation award
- this is the 48C allocation gap: current IRS guidance says the taxpayer must be awarded a section 48C allocation before placing eligible property in service and claiming the credit, but the state machine permits the claim without that gate

### 216. Refueling property location failure

Model: `work/Tax30CLocationGap.tla`

Trace:
1. initial state
2. `InstallProperty`

Observed state:
- `propertyPlacedInService = TRUE`
- `eligibleCensusTract = FALSE`
- `creditClaimed = TRUE`

Expected invariant:
- `creditClaimed => eligibleCensusTract`

Meaning:
- the model lets alternative fuel vehicle refueling property be placed in service outside an eligible census tract and still claim the credit
- this is the 30C location gap: current IRS guidance says the property must be installed in a low-income community census tract or non-urban census tract, but the state machine allows the credit claim without that location gate

### 217. Foreign tax credit carryover expiration failure

Model: `work/TaxForeignTaxCreditCarryoverGap.tla`

Trace:
1. initial state
2. `ClaimCredit`

Observed state:
- `carryoverExpired = TRUE`
- `creditClaimed = TRUE`
- `carryoverUsed = TRUE`

Expected invariant:
- `creditClaimed => ~carryoverExpired`

Meaning:
- the model lets an expired foreign tax carryover be used to claim a credit
- this is the foreign-tax-credit carryover gap: current IRS Form 1116 Schedule B guidance says carryovers from the 10th preceding tax year expire unused, but the state machine still permits the expired carryover to become a claimed credit

### 218. Form 8938 threshold reporting failure

Model: `work/Tax8938ThresholdGap.tla`

Trace:
1. initial state
2. `AcquireMoreAssets`

Observed state:
- `assetValue = 50001`
- `reportFiled = FALSE`

Expected invariant:
- `assetValue > Threshold => reportFiled`

Meaning:
- the model lets specified foreign financial assets cross the Form 8938 reporting threshold without filing the form
- this is the Form 8938 threshold gap: current IRS guidance says Form 8938 is required once the aggregate value of specified foreign financial assets exceeds the applicable threshold, but the state machine allows the threshold crossing to remain unreported

### 219. Substitute Form 3520-A penalty failure

Model: `work/Tax3520ASubstituteGap.tla`

Trace:
1. initial state
2. `ObserveFailure`

Observed state:
- `foreignTrustFailedToFile = TRUE`
- `substituteFormAttached = FALSE`
- `penaltyApplied = TRUE`

Expected invariant:
- `penaltyApplied => substituteFormAttached`

Meaning:
- the model lets the penalty path fire even when the required substitute Form 3520-A was never attached
- this is the substitute-3520-A gap: current IRS Form 3520-A guidance says a U.S. owner must attach a substitute Form 3520-A to avoid the penalty when the foreign trust fails to file, but the state machine applies the penalty anyway

### 220. Foreign gift threshold reporting failure

Model: `work/Tax3520ForeignGiftThresholdGap.tla`

Trace:
1. initial state
2. `ReceiveForeignGift`

Observed state:
- `foreignGiftAmount = 100001`
- `reportFiled = FALSE`

Expected invariant:
- `foreignGiftAmount > Threshold => reportFiled`

Meaning:
- the model lets a foreign gift cross the Form 3520 reporting threshold without filing the return
- this is the foreign-gift threshold gap: current IRS Form 3520 guidance says large foreign gifts or bequests must be reported once the aggregate threshold is exceeded, but the state machine allows the threshold crossing to remain unreported

### 221. Form 5471 foreign corporation ownership reporting failure

Model: `work/Tax5471OwnershipReportGap.tla`

Trace:
1. initial state
2. `AcquireForeignCorpOwnership`

Observed state:
- `usPersonOwnsForeignCorp = TRUE`
- `form5471Filed = FALSE`

Expected invariant:
- `usPersonOwnsForeignCorp => form5471Filed`

Meaning:
- the model lets a U.S. person acquire foreign-corporation ownership without filing Form 5471
- this is the Form 5471 ownership-reporting gap: current IRS guidance says U.S. persons with certain ownership interests in foreign corporations must file Form 5471, but the state machine allows the ownership state to exist without the filing state

### 222. Form 8621 PFIC ownership reporting failure

Model: `work/Tax8621OwnershipReportGap.tla`

Trace:
1. initial state
2. `AcquirePFICStock`

Observed state:
- `usPersonOwnsPFIC = TRUE`
- `form8621Filed = FALSE`

Expected invariant:
- `usPersonOwnsPFIC => form8621Filed`

Meaning:
- the model lets a U.S. person acquire PFIC stock without filing Form 8621
- this is the Form 8621 ownership-reporting gap: current IRS guidance says a U.S. person that is a direct or indirect shareholder of a PFIC must file Form 8621 in the listed filing circumstances, but the state machine allows the ownership state to exist without the filing state

### 223. Form 5472 foreign-owned corporation reporting failure

Model: `work/Tax5472OwnershipReportGap.tla`

Trace:
1. initial state
2. `ForeignOwnershipExists`

Observed state:
- `foreignOwnedUSCorp = TRUE`
- `reportableTransactionOccurred = TRUE`
- `form5472Filed = FALSE`

Expected invariant:
- `foreignOwnedUSCorp /\ reportableTransactionOccurred => form5472Filed`

Meaning:
- the model lets a 25% foreign-owned U.S. corporation with a reportable transaction exist without filing Form 5472
- this is the Form 5472 reporting gap: current IRS guidance says reporting corporations file Form 5472 when reportable transactions occur with a foreign or domestic related party, but the state machine allows the reporting state to be missing after the triggering ownership and transaction state exists

### 224. Form 8621-A late purging election filing failure

Model: `work/Tax8621ALatePurgingGap.tla`

Trace:
1. initial state
2. `MakeLatePurgingElection`

Observed state:
- `formerPFICExists = TRUE`
- `latePurgingElectionMade = TRUE`
- `form8621AFiled = FALSE`

Expected invariant:
- `latePurgingElectionMade => form8621AFiled`

Meaning:
- the model lets a late purging election be made without filing Form 8621-A
- this is the Form 8621-A filing gap: current IRS guidance says Form 8621-A is used to make certain late purging elections to end PFIC treatment, but the state machine allows the election to exist without the required filing state

### 225. PFIC excess distribution ordinary-income and interest-charge failure

Model: `work/Tax8621ExcessDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveExcessDistribution`

Observed state:
- `excessDistributionReceived = TRUE`
- `ordinaryIncomeIncluded = FALSE`
- `interestChargeApplied = FALSE`

Expected invariant:
- `excessDistributionReceived => /\ ordinaryIncomeIncluded /\ interestChargeApplied`

Meaning:
- the model lets a PFIC excess distribution be received without the ordinary-income inclusion and interest-charge treatment that current section 1291 guidance requires
- this is the PFIC excess-distribution gap: current IRS Instructions for Form 8621 say excess distributions and certain PFIC dispositions are subject to special ordinary-income treatment and an interest charge, but the state machine allows the distribution to occur without those consequences

### 226. PFIC QEF election ordinary-income inclusion failure

Model: `work/Tax8621QEFElectionGap.tla`

Trace:
1. initial state
2. `MakeQEFElection`

Observed state:
- `qefElectionMade = TRUE`
- `ordinaryEarningsIncluded = FALSE`

Expected invariant:
- `qefElectionMade => ordinaryEarningsIncluded`

Meaning:
- the model lets a PFIC QEF election be made without the ordinary-income inclusion that should follow from QEF treatment
- this is the PFIC QEF gap: current IRS Instructions for Form 8621 say a QEF shareholder must annually include its pro rata share of ordinary earnings, but the state machine allows the election to exist without the income inclusion state

### 227. PFIC mark-to-market election ordinary-income inclusion failure

Model: `work/Tax8621MarkToMarketGap.tla`

Trace:
1. initial state
2. `MakeMTMElection`

Observed state:
- `mtmElectionMade = TRUE`
- `ordinaryIncomeIncluded = FALSE`

Expected invariant:
- `mtmElectionMade => ordinaryIncomeIncluded`

Meaning:
- the model lets a PFIC mark-to-market election be made without the ordinary-income inclusion that should follow from section 1296 treatment
- this is the PFIC mark-to-market gap: current IRS Instructions for Form 8621 say a shareholder may elect to mark PFIC stock to market and include annual ordinary income from the election, but the state machine allows the election to exist without the income inclusion state

### 228. PFIC deemed sale election section 1291 treatment failure

Model: `work/Tax8621DeemedSaleGap.tla`

Trace:
1. initial state
2. `MakeDeemedSaleElection`

Observed state:
- `deemedSaleElectionMade = TRUE`
- `section1291Applied = FALSE`

Expected invariant:
- `deemedSaleElectionMade => section1291Applied`

Meaning:
- the model lets a PFIC deemed-sale election be made without applying section 1291 treatment
- this is the PFIC deemed-sale gap: current IRS Instructions for Form 8621 say the deemed-sale election treats the PFIC stock as sold for fair market value and the gain is taxed under section 1291, but the state machine allows the election to exist without that tax treatment state

### 229. PFIC deemed dividend election inclusion failure

Model: `work/Tax8621DeemedDividendGap.tla`

Trace:
1. initial state
2. `MakeDeemedDividendElection`

Observed state:
- `deemedDividendElectionMade = TRUE`
- `dividendIncluded = FALSE`

Expected invariant:
- `deemedDividendElectionMade => dividendIncluded`

Meaning:
- the model lets a PFIC deemed-dividend election be made without the dividend inclusion that should follow from that election
- this is the PFIC deemed-dividend gap: current IRS Instructions for Form 8621 say certain PFIC stockholder elections can create deemed dividend treatment, but the state machine allows the election to exist without the income inclusion state

### 230. Form 926 foreign transfer reporting failure

Model: `work/Tax926ForeignTransferGap.tla`

Trace:
1. initial state
2. `TransferToForeignCorp`

Observed state:
- `propertyTransferred = TRUE`
- `form926Filed = FALSE`

Expected invariant:
- `propertyTransferred => form926Filed`

Meaning:
- the model lets a transfer of property to a foreign corporation occur without filing Form 926
- this is the Form 926 reporting gap: current IRS guidance says U.S. transferors of property to a foreign corporation must report the transfer on Form 926 with the income tax return for the year of transfer, but the state machine allows the transfer to occur without the filing state

### 231. FBAR foreign account threshold reporting failure

Model: `work/TaxFBARThresholdGap.tla`

Trace:
1. initial state
2. `IncreaseForeignAccountValue`

Observed state:
- `foreignAccountValue = 10001`
- `fbarFiled = FALSE`

Expected invariant:
- `foreignAccountValue > Threshold => fbarFiled`

Meaning:
- the model lets a foreign financial account cross the FBAR threshold without filing FinCEN Form 114
- this is the FBAR threshold gap: current IRS guidance says a U.S. person must file an FBAR when the aggregate value of foreign financial accounts exceeds $10,000 at any time during the calendar year, but the state machine allows the threshold crossing to remain unreported

### 232. Form 8858 foreign branch reporting failure

Model: `work/Tax8858ForeignBranchGap.tla`

Trace:
1. initial state
2. `CreateForeignBranch`

Observed state:
- `foreignBranchExists = TRUE`
- `form8858Filed = FALSE`

Expected invariant:
- `foreignBranchExists => form8858Filed`

Meaning:
- the model lets a foreign branch exist without filing Form 8858
- this is the Form 8858 foreign-branch gap: current IRS guidance says U.S. persons with interests in foreign disregarded entities or foreign branches must file Form 8858 in the listed circumstances, but the state machine allows the foreign branch to exist without the filing state

### 233. Form 8865 foreign partnership reporting failure

Model: `work/Tax8865ForeignPartnershipGap.tla`

Trace:
1. initial state
2. `AcquireForeignPartnershipInterest`

Observed state:
- `foreignPartnershipInterestAcquired = TRUE`
- `form8865Filed = FALSE`

Expected invariant:
- `foreignPartnershipInterestAcquired => form8865Filed`

Meaning:
- the model lets a U.S. person acquire a foreign partnership interest without filing Form 8865
- this is the Form 8865 foreign-partnership gap: current IRS guidance says U.S. persons with certain foreign partnership interests or transfer events must file Form 8865, but the state machine allows the ownership state to exist without the filing state

### 234. Form 8865 foreign partnership transfer reporting failure

Model: `work/Tax8865TransferReportGap.tla`

Trace:
1. initial state
2. `TransferForeignPartnershipInterest`

Observed state:
- `foreignPartnershipInterestTransferred = TRUE`
- `form8865Filed = FALSE`

Expected invariant:
- `foreignPartnershipInterestTransferred => form8865Filed`

Meaning:
- the model lets a transfer of a foreign partnership interest occur without filing Form 8865
- this is the Form 8865 transfer-report gap: current IRS guidance says certain transfers, acquisitions, and dispositions of foreign partnership interests trigger Form 8865 reporting, but the state machine allows the transfer state to exist without the filing state

### 235. Form 8865 Schedule K-3 delivery failure

Model: `work/Tax8865K3DeliveryGap.tla`

Trace:
1. initial state
2. `ReceiveK3Request`

Observed state:
- `foreignPartnershipHasInternationalItems = TRUE`
- `partnerRequestedK3 = TRUE`
- `k3Delivered = FALSE`

Expected invariant:
- `foreignPartnershipHasInternationalItems /\ partnerRequestedK3 => k3Delivered`

Meaning:
- the model lets a foreign partnership have relevant international items and receive a partner request without delivering Schedule K-3
- this is the Schedule K-3 delivery gap: current IRS guidance says the partner should receive Schedule K-3 information when the partnership has items of international tax relevance and a request is made, but the state machine allows the request state to exist without the delivery state

### 236. Form 926 section 6038B attachment failure

Model: `work/Tax926Section6038BAttachmentGap.tla`

Trace:
1. initial state
2. `MakeOutboundTransfer`

Observed state:
- `transferMade = TRUE`
- `section6038BAttachmentIncluded = FALSE`

Expected invariant:
- `transferMade => section6038BAttachmentIncluded`

Meaning:
- the model lets an outbound transfer occur without including the required section 6038B attachment information with Form 926
- this is the Form 926 section 6038B attachment gap: current IRS guidance says the Form 926 filing must include the additional section 6038B information required by the regulations, but the state machine allows the transfer state to exist without the attachment state

### 237. Form 5471 Schedule M transaction reporting failure

Model: `work/Tax5471ScheduleMTransactionGap.tla`

Trace:
1. initial state
2. `RecordCFCTransaction`

Observed state:
- `cfcTransactionOccurred = TRUE`
- `scheduleMReported = FALSE`

Expected invariant:
- `cfcTransactionOccurred => scheduleMReported`

Meaning:
- the model lets a controlled foreign corporation transaction occur without reporting it on Schedule M
- this is the Schedule M reporting gap: current IRS guidance says Schedule M reports transactions between a controlled foreign corporation and shareholders or other related persons, but the state machine allows the transaction state to exist without the schedule state

### 238. Form 5471 Schedule O stock acquisition reporting failure

Model: `work/Tax5471ScheduleOGap.tla`

Trace:
1. initial state
2. `RecordStockAcquisition`

Observed state:
- `foreignCorpStockAcquired = TRUE`
- `scheduleOReported = FALSE`

Expected invariant:
- `foreignCorpStockAcquired => scheduleOReported`

Meaning:
- the model lets a foreign corporation stock acquisition occur without reporting it on Schedule O
- this is the Schedule O reporting gap: current IRS guidance says Schedule O reports the organization or reorganization of a foreign corporation and the acquisition or disposition of its stock, but the state machine allows the acquisition state to exist without the schedule state

### 239. Form 5471 Schedule R distribution reporting failure

Model: `work/Tax5471ScheduleRGap.tla`

Trace:
1. initial state
2. `RecordForeignCorpDistribution`

Observed state:
- `foreignCorpDistributionReceived = TRUE`
- `scheduleRReported = FALSE`

Expected invariant:
- `foreignCorpDistributionReceived => scheduleRReported`

Meaning:
- the model lets a foreign corporation distribution occur without reporting it on Schedule R
- this is the Schedule R reporting gap: current IRS guidance says Schedule R reports distributions from foreign corporations, but the state machine allows the distribution state to exist without the schedule state

### 240. Form 8992 GILTI inclusion and filing failure

Model: `work/Tax8992GILTIGap.tla`

Trace:
1. initial state
2. `GenerateCFCTestedIncome`

Observed state:
- `cfcTestedIncomeExists = TRUE`
- `form8992Filed = FALSE`
- `giltiIncluded = FALSE`

Expected invariant:
- `cfcTestedIncomeExists => /\ form8992Filed /\ giltiIncluded`

Meaning:
- the model lets a controlled foreign corporation have tested income without filing Form 8992 or including GILTI
- this is the Form 8992 GILTI gap: current IRS guidance says U.S. shareholders of controlled foreign corporations use Form 8992 and Schedule A to compute GILTI inclusions under section 951A, but the state machine allows the tested-income state to exist without the filing and inclusion states

### 241. Form 8992 Schedule A CFC information reporting failure

Model: `work/Tax8992ScheduleAGap.tla`

Trace:
1. initial state
2. `RecordCFCInfo`

Observed state:
- `cfcInfoExists = TRUE`
- `scheduleAFiled = FALSE`

Expected invariant:
- `cfcInfoExists => scheduleAFiled`

Meaning:
- the model lets CFC-level information exist without filing Schedule A for Form 8992
- this is the Form 8992 Schedule A gap: current IRS guidance says Schedule A (Form 8992) is used to report controlled foreign corporation information to compute GILTI, but the state machine allows the CFC-information state to exist without the schedule-filing state

### 242. Form 1042-S foreign payment reporting failure

Model: `work/Tax1042SForeignPaymentGap.tla`

Trace:
1. initial state
2. `MakeForeignReportablePayment`

Observed state:
- `foreignReportablePaymentExists = TRUE`
- `withholdingRequired = FALSE`
- `form1042SFiled = FALSE`

Expected invariant:
- `foreignReportablePaymentExists => form1042SFiled`

Meaning:
- the model lets a reportable payment to a foreign person exist without filing Form 1042-S
- this is the Form 1042-S reporting gap: current IRS guidance says withholding agents must file Form 1042-S for reportable foreign-person payments even when withholding is not required, but the state machine allows the reportable-payment state to exist without the information-return state

### 243. Form 1042 annual withholding return failure

Model: `work/Tax1042AnnualWithholdingGap.tla`

Trace:
1. initial state
2. `MakeWithholding`

Observed state:
- `withholdingOccurred = TRUE`
- `form1042Filed = FALSE`

Expected invariant:
- `withholdingOccurred => form1042Filed`

Meaning:
- the model lets withholding occur without filing the annual Form 1042 return
- this is the Form 1042 annual reporting gap: current IRS guidance says Form 1042 reports the tax withheld under chapter 3 and chapter 4, and the state machine allows the withholding state to exist without the annual return state

### 244. Form 1042-T paper transmittal failure

Model: `work/Tax1042TTransmittalGap.tla`

Trace:
1. initial state
2. `PreparePaper1042SForms`

Observed state:
- `paper1042SFormsExist = TRUE`
- `form1042TFiled = FALSE`

Expected invariant:
- `paper1042SFormsExist => form1042TFiled`

Meaning:
- the model lets paper Forms 1042-S exist without filing Form 1042-T to transmit them
- this is the Form 1042-T transmittal gap: current IRS guidance says Form 1042-T is used to transmit paper Forms 1042-S to the IRS, but the state machine allows the paper-form state to exist without the transmittal state

### 245. Form 1099-DIV nominee reporting failure

Model: `work/Tax1099DIVNomineeGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDividend`

Observed state:
- `nomineeReceivedDividend = TRUE`
- `dividendBelongsToAnother = TRUE`
- `form1099DIVFiled = FALSE`

Expected invariant:
- `dividendBelongsToAnother => form1099DIVFiled`

Meaning:
- the model lets a nominee receive dividend income belonging to another person without filing Form 1099-DIV for the other owner
- this is the Form 1099-DIV nominee gap: current IRS guidance says a nominee recipient must file Form 1099-DIV to show the other owner’s share of dividend income, but the state machine allows the nominee-income state to exist without the corrected-information-return state

### 246. Form 1042-S corrected return propagation failure

Model: `work/Tax1042SCorrectionGap.tla`

Trace:
1. initial state
2. `FileOriginal1042S`
3. `Correct1042S`

Observed state:
- `original1042SFiled = TRUE`
- `corrected1042SFiled = TRUE`
- `correctionChanges1042 = TRUE`
- `amended1042Filed = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `corrected1042SFiled /\ correctionChanges1042 => amended1042Filed`

Meaning:
- the model lets a corrected Form 1042-S change the reported withholding information without forcing the annual Form 1042 to be amended
- this is the Form 1042-S repair gap: IRS instructions say changes on an amended Form 1042-S that affect what was previously reported on Form 1042 must also trigger an amended Form 1042, but the state machine allows the correction to stop at the information-return layer

### 730. Form 1042-S corrected recipient-copy failure

Model: `work/Tax1042SRecipientCopyGap.tla`

Trace:
1. initial state
2. `FileOriginal1042S`
3. `FileCorrected1042S`

Observed state:
- `original1042SFiled = TRUE`
- `corrected1042SFiled = TRUE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `corrected1042SFiled => recipientCopyFurnished`

Meaning:
- the model lets a corrected Form 1042-S exist without furnishing the recipient copy
- this is the Form 1042-S recipient-copy gap: the correction path reaches the amended information return, but the statement delivery still never becomes mandatory

### 247. Form 1099-B corrected broker statement reconciliation failure

Model: `work/TaxForm1099BCorrectionGap.tla`

Trace:
1. initial state
2. `SellReportableSecurity`
3. `ReceiveIssuerCorrection`
4. `FileCorrected1099B`

Observed state:
- `reportableBrokerSale = TRUE`
- `issuerStatementReceived = TRUE`
- `corrected1099BFiled = TRUE`
- `basisInfoChanged = TRUE`
- `form8949Filed = FALSE`

Expected invariant:
- `corrected1099BFiled /\ basisInfoChanged => form8949Filed`

Meaning:
- the model lets a corrected Form 1099-B be filed after a later issuer statement changes basis information, but it never forces the downstream reconciliation form to appear
- this is the Form 1099-B correction gap: IRS instructions say Form 8949 reconciles amounts reported on Form 1099-B with the amounts on the return, but the state machine allows the correction chain to stop before reconciliation

### 731. Form 1099-B nominee correction failure

Model: `work/TaxForm1099BNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeBrokerProceeds`
3. `FileOriginal1099B`
4. `FileCorrected1099B`

Observed state:
- `nomineeReceivedBrokerProceeds = TRUE`
- `brokerProceedsBelongToAnother = TRUE`
- `original1099BFiled = TRUE`
- `corrected1099BFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099BFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-B without furnishing the other owner’s copy
- this is the Form 1099-B nominee-correction gap: the correction path reaches the corrected broker statement, but the recipient-side delivery still never becomes mandatory

### 248. Section 871(m) dividend-equivalent reporting failure

Model: `work/Tax871mDividendEquivalentGap.tla`

Trace:
1. initial state
2. `GenerateDividendEquivalent`

Observed state:
- `dividendEquivalentExists = TRUE`
- `form1042S871mReported = FALSE`

Expected invariant:
- `dividendEquivalentExists => form1042S871mReported`

Meaning:
- the model lets a section 871(m) dividend-equivalent payment exist without reporting it on Form 1042-S
- this is the 871(m) dividend-equivalent gap: current IRS guidance treats dividend equivalents as reportable under Form 1042-S income-code categories, but the state machine allows the dividend-equivalent state to exist without the reporting state

### 247. Form 1099-MISC substitute payment reporting failure

Model: `work/Tax1099MISCSubstitutePaymentGap.tla`

Trace:
1. initial state
2. `MakeSubstitutePayment`

Observed state:
- `substitutePaymentInLieuExists = TRUE`
- `amountAtLeast10 = TRUE`
- `form1099MISCFiled = FALSE`

Expected invariant:
- `(substitutePaymentInLieuExists /\ amountAtLeast10) => form1099MISCFiled`

Meaning:
- the model lets a broker substitute payment in lieu of dividends exist at reportable size without filing Form 1099-MISC
- this is the Form 1099-MISC substitute-payment gap: current IRS guidance says broker payments in lieu of dividends are reported in box 8 of Form 1099-MISC, but the state machine allows the substitute-payment state to exist without the information-return state

### 248. Short-sale substitute payment recognition failure

Model: `work/TaxShortSaleSubstitutePaymentGap.tla`

Trace:
1. initial state
2. `OpenShortSale`
3. `DividendWhileShortOpen`

Observed state:
- `shortSaleOpen = TRUE`
- `substitutePaymentInLieuExists = TRUE`
- `otherIncomeRecognized = FALSE`

Expected invariant:
- `substitutePaymentInLieuExists => otherIncomeRecognized`

Meaning:
- the model lets a short-sale substitute payment in lieu of dividends arise without recognizing it as other income
- this is the short-sale substitute-payment gap: current IRS guidance says certain substitute payments in lieu of dividends are not treated as dividends and instead are reported as other income, but the state machine allows the substitute-payment state to exist without the income-recognition state

### 249. Straddle loss deferral failure

Model: `work/TaxStraddleLossDeferralGap.tla`

Trace:
1. initial state
2. `OpenLossPosition`
3. `OpenOffsettingPosition`

Observed state:
- `lossPositionOpen = TRUE`
- `offsettingPositionOpen = TRUE`
- `lossDeferred = FALSE`

Expected invariant:
- `~(lossPositionOpen /\ offsettingPositionOpen /\ ~lossDeferred)`

Meaning:
- the model lets offsetting positions remain open without deferring the loss on the loss position
- this is the straddle-loss gap: current IRS guidance says losses on a position that is part of a straddle are deferred while offsetting positions remain open, but the state machine allows the overlapping-position state to exist without the loss-deferral state

### 250. Partnership disguised-sale disclosure failure

Model: `work/TaxPartnershipDisguisedSaleDisclosureGap.tla`

Trace:
1. initial state
2. `MakeContribution`
3. `MakeRelatedCashDistribution`

Observed state:
- `partnershipContributionMade = TRUE`
- `relatedCashDistributionMade = TRUE`
- `form8275Filed = FALSE`

Expected invariant:
- `(partnershipContributionMade /\ relatedCashDistributionMade) => form8275Filed`

Meaning:
- the model lets a partnership contribution and related cash distribution happen within the disguised-sale window without filing the disclosure
- this is the partnership disguised-sale gap: current IRS guidance says a contribution/distribution pair inside the 2-year window can require a section 707 disclosure, but the state machine allows the sale-like sequence to exist without the disclosure state

### 251. Partnership section 704(c) allocation failure

Model: `work/TaxPartnership704cAllocationGap.tla`

Trace:
1. initial state
2. `ContributeBuiltInGainProperty`

Observed state:
- `builtInGainPropertyContributed = TRUE`
- `partnershipHoldsProperty = TRUE`
- `section704cAllocated = FALSE`

Expected invariant:
- `partnershipHoldsProperty => section704cAllocated`

Meaning:
- the model lets a partnership hold built-in-gain contributed property without allocating the section 704(c) built-in gain or loss
- this is the section 704(c) gap: current IRS guidance says partners should be allocated unrecognized section 704(c) gain or loss when contributed property carries built-in gain or loss, but the state machine allows the contributed-property state to exist without the allocation state

### 252. Partnership section 737 precontribution gain failure

Model: `work/TaxPartnership737GainGap.tla`

Trace:
1. initial state
2. `ContributeProperty`
3. `MakeRelatedDistribution`

Observed state:
- `propertyContributed = TRUE`
- `relatedPropertyDistributed = TRUE`
- `section737GainRecognized = FALSE`

Expected invariant:
- `(propertyContributed /\ relatedPropertyDistributed) => section737GainRecognized`

Meaning:
- the model lets a partner contribute property and later receive a related distribution without recognizing section 737 gain
- this is the section 737 gap: current IRS guidance says a later distribution of property can trigger precontribution gain recognition, but the state machine allows the contribution/distribution pair to exist without the gain-recognition state

### 253. Partnership termination deemed-distribution failure

Model: `work/TaxPartnershipTerminationDeemedDistributionGap.tla`

Trace:
1. initial state
2. `TerminatePartnership`

Observed state:
- `partnershipTerminated = TRUE`
- `deemedDistributionOccurred = FALSE`
- `basisReset = FALSE`

Expected invariant:
- `partnershipTerminated => /\ deemedDistributionOccurred /\ basisReset`

Meaning:
- the model lets a partnership terminate without producing the deemed-distribution and basis-reset consequences
- this is the partnership termination gap: current IRS guidance says section 708 terminations can produce deemed distributions and related basis consequences, but the state machine allows the termination state to exist without those follow-on states

### 254. Partnership section 1446(f) reporting failure

Model: `work/TaxPartnership1446fReportingGap.tla`

Trace:
1. initial state
2. `SellInterest`

Observed state:
- `foreignPartnerSoldInterest = TRUE`
- `section1446fWithholdingApplied = TRUE`
- `form8805Issued = FALSE`

Expected invariant:
- `section1446fWithholdingApplied => form8805Issued`

Meaning:
- the model lets section 1446(f) withholding apply on a foreign partner's sale of a partnership interest without issuing the Form 8805-style reporting statement
- this is the partnership 1446(f) reporting gap: current IRS guidance says the withholding and reporting stack includes separate return/statement obligations, but the state machine allows the withholding state to exist without the statement state

### 255. Partnership Form 8805 credit statement failure

Model: `work/TaxPartnership8805CreditGap.tla`

Trace:
1. initial state
2. `AllocateECTI`

Observed state:
- `ectiAllocableToForeignPartner = TRUE`
- `taxCreditAllocableToForeignPartner = TRUE`
- `form8805Issued = FALSE`

Expected invariant:
- `ectiAllocableToForeignPartner => form8805Issued`

Meaning:
- the model lets effectively connected taxable income and its allocable credit exist without issuing Form 8805 to the foreign partner
- this is the Form 8805 credit gap: current IRS guidance says Form 8805 shows ECTI and the total tax credit allocable to the foreign partner, but the state machine allows the credit-allocation state to exist without the partner-statement state

### 726. Partnership Form 8805 corrected statement failure

Model: `work/TaxPartnership8805CorrectionGap.tla`

Trace:
1. initial state
2. `AllocateECTI`
3. `DeliverOriginal8805`
4. `DeliverCorrected8805`

Observed state:
- `foreignPartner = TRUE`
- `ectiAllocated = TRUE`
- `original8805Delivered = TRUE`
- `corrected8805Delivered = TRUE`
- `recipientCopyUpdated = FALSE`

Expected invariant:
- `corrected8805Delivered => recipientCopyUpdated`

Meaning:
- the model lets a corrected Form 8805 exist without updating the foreign partner’s recipient copy
- this is the Form 8805 correction gap: the partnership can reach the corrected statement path, but the recipient-side update still never becomes mandatory

### 256. Form 1116 passive-category selection failure

Model: `work/TaxForeignTaxCreditCategoryMismatchGap.tla`

Trace:
1. initial state
2. `CreatePassiveIncome`

Observed state:
- `passiveCategoryIncomeExists = TRUE`
- `form1116PassiveCategorySelected = FALSE`
- `creditClaimed = FALSE`

Expected invariant:
- `passiveCategoryIncomeExists => form1116PassiveCategorySelected`

Meaning:
- the model lets passive-category foreign income exist without selecting the passive-category Form 1116 bucket
- this is the Form 1116 category-mismatch gap: current IRS guidance says each category or basket of foreign source income requires a separate Form 1116 and separate limitation computation, but the state machine allows the income-category state to exist without the matching form-category state

### 256.1. Form 1116 treaty-resourced basket failure

Model: `work/TaxForm1116TreatyResourcedBasketGap.tla`

Trace:
1. initial state
2. `CreateTreatyResourcedIncome`

Observed state:
- `treatyResourcedIncomeExists = TRUE`
- `summaryForm1116Filed = FALSE`
- `separateTreatyForm1116Filed = FALSE`

Expected invariant:
- `treatyResourcedIncomeExists => separateTreatyForm1116Filed`

Meaning:
- the model lets treaty-resourced income exist without the separate Form 1116 basket the IRS requires for that income
- this is the treaty-resourced Form 1116 gap: IRS instructions say income re-sourced by treaty needs a separate Form 1116 and separate limitation computation, but the state machine allows the treaty-income state to exist without the treaty-specific basket state

### 256.2. Form 1116 foreign tax redetermination notification failure

Model: `work/TaxForm1116RedeterminationGap.tla`

Trace:
1. initial state
2. `RecordForeignTaxRedetermination`

Observed state:
- `foreignTaxRedeterminationOccurred = TRUE`
- `scheduleCFiled = FALSE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `foreignTaxRedeterminationOccurred => scheduleCFiled /\ amendedReturnFiled`

Meaning:
- the model lets a foreign tax redetermination occur without either the Schedule C notification or the amended return when U.S. liability changes
- this is the Form 1116 redetermination gap: IRS instructions say Schedule C reports current-year redeterminations that relate to prior tax years, and an amended return is also required when the U.S. tax liability changes, but the state machine allows the redetermination state to exist without either follow-on filing state

### 256.3. Form 7204 contested foreign tax provisional credit failure

Model: `work/TaxForm7204ContestedForeignTaxGap.tla`

Trace:
1. initial state
2. `CreateContestedForeignTax`
3. `ClaimProvisionalForeignTaxCredit`

Observed state:
- `contestedForeignTaxExists = TRUE`
- `provisionalForeignTaxCreditClaimed = TRUE`
- `form7204Filed = FALSE`
- `annualScheduleCFiled = FALSE`

Expected invariant:
- `provisionalForeignTaxCreditClaimed => form7204Filed /\ annualScheduleCFiled`

Meaning:
- the model lets a provisional foreign tax credit be claimed for contested foreign income taxes without the Form 7204 consent and without the annual Schedule C notice
- this is the Form 7204 gap: IRS guidance says taxpayers electing a provisional credit for contested foreign income taxes must use Form 7204 and then file Schedule C in subsequent years up to resolution, but the state machine allows the credit election state to exist without either follow-on filing state

### 256.4. Form 1118 contested foreign tax provisional credit failure

Model: `work/TaxForm1118ContestedForeignTaxGap.tla`

Trace:
1. initial state
2. `CreateContestedForeignTax`
3. `ClaimProvisionalForeignTaxCredit`

Observed state:
- `contestedForeignTaxExists = TRUE`
- `provisionalForeignTaxCreditClaimed = TRUE`
- `form7204Filed = FALSE`
- `scheduleLFiled = FALSE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `provisionalForeignTaxCreditClaimed => form7204Filed /\ scheduleLFiled /\ amendedReturnFiled`

Meaning:
- the model lets a corporation claim a provisional foreign tax credit for contested foreign taxes without the Form 7204 consent, the annual Schedule L notice, or the amended return that may be required when U.S. liability changes
- this is the corporate contested-tax gap: IRS instructions say corporations use Form 7204 to elect a provisional credit for contested foreign income taxes, then file Schedule L annually until resolution, with an amended return if the U.S. tax liability changes, but the state machine allows the credit-election state to exist without those follow-on filing states

### 256.5. Foreign tax credit and deduction double benefit failure

Model: `work/TaxForeignTaxCreditOrDeductionGap.tla`

Trace:
1. initial state
2. `PayQualifiedForeignTaxes`
3. `ClaimForeignTaxCredit`
4. `ClaimItemizedDeduction`

Observed state:
- `foreignTaxesPaid = TRUE`
- `foreignTaxCreditClaimed = TRUE`
- `itemizedDeductionClaimed = TRUE`

Expected invariant:
- `~(foreignTaxCreditClaimed /\ itemizedDeductionClaimed)`

Meaning:
- the model lets the same qualified foreign taxes be claimed both as a foreign tax credit and as an itemized deduction
- this is the foreign-tax double-benefit gap: IRS guidance says taxpayers must choose either the foreign tax credit or the itemized deduction for the same foreign taxes, but the state machine allows both tax treatments to exist at once

### 256.6. Section 962 deemed-paid foreign tax credit failure

Model: `work/TaxForm962DeemedPaidForeignTaxCreditGap.tla`

Trace:
1. initial state
2. `GenerateCFCInclusion`
3. `MakeSection962Election`

Observed state:
- `cfcInclusionExists = TRUE`
- `section962ElectionMade = TRUE`
- `form1118Filed = FALSE`
- `deemedPaidForeignTaxCreditClaimed = FALSE`

Expected invariant:
- `section962ElectionMade => form1118Filed`
- `deemedPaidForeignTaxCreditClaimed => form1118Filed`

Meaning:
- the model lets a section 962 election exist without the Form 1118 filing that the IRS ties to the election for a deemed-paid foreign tax credit
- this is the section 962 deemed-paid credit gap: IRS instructions say individuals electing corporate-rate treatment on CFC inclusions need to attach Form 1118 to claim the deemed-paid foreign tax credit, but the state machine allows the election state to exist without the filing state

### 257. Lifetime learning credit 1098-T documentary failure

Model: `work/TaxLifetimeLearningCredit1098TGap.tla`

Trace:
1. initial state
2. `ClaimLifetimeLearningCredit`

Observed state:
- `llcClaimed = TRUE`
- `higherEducation = TRUE`
- `form1098TReceived = FALSE`
- `creditAllowed = 5000`

Expected invariant:
- `llcClaimed => form1098TReceived`

Meaning:
- the model lets the lifetime learning credit be claimed without the required Form 1098-T documentary gate
- this is the lifetime-learning 1098-T gap: current IRS guidance says the taxpayer or dependent must have received Form 1098-T to be eligible for the credit, but the state machine allows the credit-claim state to exist without the documentary state

### 258. Saver's credit Form 8880 filing failure

Model: `work/TaxSaversCredit8880Gap.tla`

Trace:
1. initial state
2. `MakeSaverContribution`

Observed state:
- `saverContributionMade = TRUE`
- `form8880Filed = FALSE`
- `creditAllowed = 2000`

Expected invariant:
- `saverContributionMade => form8880Filed`

Meaning:
- the model lets a saver contribution exist without filing Form 8880 to figure the credit
- this is the saver’s credit Form 8880 gap: current IRS guidance says Form 8880 is used to figure the retirement savings contributions credit, but the state machine allows the contribution state to exist without the form-filing state

### 259. Student loan interest Form 1098-E documentary failure

Model: `work/TaxStudentLoanInterest1098EGap.tla`

Trace:
1. initial state
2. `ClaimStudentLoanInterest`

Observed state:
- `studentLoanInterestClaimed = TRUE`
- `form1098EReceived = FALSE`
- `deductionAllowed = 2500`

Expected invariant:
- `studentLoanInterestClaimed => form1098EReceived`

Meaning:
- the model lets a student-loan-interest deduction be claimed without the required Form 1098-E documentary gate
- this is the student-loan 1098-E gap: current IRS guidance says you should receive Form 1098-E to help figure the deduction, but the state machine allows the deduction-claim state to exist without the documentary state

### 260. Mortgage interest Form 1098 documentary failure

Model: `work/TaxMortgageInterest1098Gap.tla`

Trace:
1. initial state
2. `ClaimMortgageInterest`

Observed state:
- `mortgageInterestClaimed = TRUE`
- `interestDeducted = 900000`
- `form1098Received = FALSE`

Expected invariant:
- `mortgageInterestClaimed => form1098Received`

Meaning:
- the model lets a mortgage interest deduction be claimed without the required Form 1098 documentary gate
- this is the mortgage-interest 1098 gap: current IRS guidance says mortgage interest is generally reported on Form 1098 and used to figure the deduction, but the state machine allows the deduction-claim state to exist without the documentary state

### 261. Mortgage interest credit Form 8396 filing failure

Model: `work/TaxMortgageInterestCreditGap.tla`

Trace:
1. initial state
2. `PayQualifiedMortgageInterest`

Observed state:
- `qualifiedMCCIssued = TRUE`
- `mainHomeMortgagePaid = TRUE`
- `form8396Filed = FALSE`

Expected invariant:
- `mainHomeMortgagePaid /\ qualifiedMCCIssued => form8396Filed`

Meaning:
- the model lets qualified mortgage-interest-credit eligibility and payment exist without the Form 8396 filing gate
- this is the mortgage-interest credit gap: IRS Form 8396 is the mortgage interest credit form, and Publication 530 treats the credit as a separate yearly claim tied to a qualified Mortgage Credit Certificate, but the state machine allows the benefit state to exist without the filing state

### 262. FIRPTA withholding-certificate pending failure

Model: `work/TaxFIRPTAWithholdingCertificateGap.tla`

Trace:
1. initial state
2. `Submit8288B`
3. `DisposeUSTripleNet`

Observed state:
- `dispositionDone = TRUE`
- `withholdingCertificatePending = TRUE`
- `withholdingApplied = FALSE`

Expected invariant:
- `dispositionDone /\ withholdingCertificatePending => withholdingApplied`

Meaning:
- the model lets a foreign-person U.S. real-property disposition proceed with a pending withholding-certificate request but no withholding
- this is the FIRPTA certificate-pending gap: IRS guidance for Forms 8288/8288-A/8288-B says a pending withholding-certificate application does not erase the withholding obligation, but the state machine allows the disposition state to exist without the withholding state

### 263. Inherited IRA 10-year rule failure

Model: `work/TaxInheritedIRA10YearRuleGap.tla`

Trace:
1. initial state
2. `InheritanceStarts`
3. `AdvanceToYear10`

Observed state:
- `ownerDied = TRUE`
- `beneficiarySubjectTo10YearRule = TRUE`
- `year10Reached = TRUE`
- `fullBalanceDistributed = FALSE`

Expected invariant:
- `ownerDied /\ beneficiarySubjectTo10YearRule /\ year10Reached => fullBalanceDistributed`

Meaning:
- the model lets the inherited-IRA 10-year deadline arrive without forcing the full balance out
- this is the inherited-IRA 10-year-rule gap: IRS Publication 590-B says many designated beneficiaries must empty the account by the end of the 10th year after death, but the state machine allows the deadline state to exist without the distribution state

### 264. Premium tax credit Form 8962 reconciliation failure

Model: `work/TaxPremiumTaxCreditReconciliationGap.tla`

Trace:
1. initial state
2. `EnrollMarketplace`
3. `ReceiveAdvancePayments`

Observed state:
- `marketplaceCoverage = TRUE`
- `advancePaymentsReceived = TRUE`
- `form1095AReceived = TRUE`
- `form8962Filed = FALSE`

Expected invariant:
- `advancePaymentsReceived => form8962Filed`

Meaning:
- the model lets premium tax credit advance payments exist without the Form 8962 reconciliation gate
- this is the premium tax credit reconciliation gap: IRS guidance says Form 8962 is required to compute and reconcile the premium tax credit with advance payments, but the state machine allows the advance-payment state to exist without the reconciliation state

### 265. Kiddie tax Form 8615 failure

Model: `work/TaxKiddieTax8615Gap.tla`

Trace:
1. initial state
2. `BecomeEligibleForKiddieTax`
3. `PrepareReturnWithout8615`

Observed state:
- `childUnder18 = TRUE`
- `unearnedIncomeOverThreshold = TRUE`
- `returnRequired = TRUE`
- `form8615Filed = FALSE`
- `parentRateApplied = TRUE`

Expected invariant:
- `childUnder18 /\ unearnedIncomeOverThreshold /\ returnRequired => form8615Filed`

Meaning:
- the model lets a child who is in the kiddie-tax bucket prepare a return and apply the parent-rate computation without filing Form 8615
- this is the kiddie-tax Form 8615 gap: IRS instructions say children with unearned income over the threshold and a required return must use Form 8615, but the state machine allows the kiddie-tax state to exist without the form-filing state

### 266. Section 83(b) election deadline failure

Model: `work/TaxSection83bElectionDeadlineGap.tla`

Trace:
1. initial state
2. `TransferProperty`
3. `AdvanceDay` x30

Observed state:
- `propertyTransferred = TRUE`
- `daysSinceTransfer = 30`
- `electionFiled = FALSE`

Expected invariant:
- `propertyTransferred /\ daysSinceTransfer = 30 => electionFiled`

Meaning:
- the model lets the 30-day section 83(b) filing window expire without an election being filed
- this is the section 83(b) gap: IRS guidance says the election must be filed within 30 days after the property transfer, but the state machine allows the transfer-and-deadline state to exist without the filing state

### 267. Form 706 portability election failure

Model: `work/TaxForm706PortabilityGap.tla`

Trace:
1. initial state
2. `DeathWithSurvivingSpouse`
3. `AttemptPortabilityWithoutTimely706`

Observed state:
- `decedentDied = TRUE`
- `survivingSpouseExists = TRUE`
- `form706FiledTimely = FALSE`
- `portabilityElected = TRUE`

Expected invariant:
- `decedentDied /\ survivingSpouseExists /\ portabilityElected => form706FiledTimely`

Meaning:
- the model lets a surviving spouse portability election exist without a timely Form 706
- this is the Form 706 portability gap: IRS instructions say a timely filed and complete Form 706 is required to elect portability of DSUE, but the state machine allows the election state to exist without the timely filing state

### 268. Form 709 gift-splitting consent failure

Model: `work/TaxForm709GiftSplittingGap.tla`

Trace:
1. initial state
2. `MakeGift`
3. `ClaimSplitGiftWithoutConsent`

Observed state:
- `giftMade = TRUE`
- `spouseConsentFiled = FALSE`
- `form709FiledByBothSpouses = FALSE`
- `splitGiftTreatmentClaimed = TRUE`

Expected invariant:
- `splitGiftTreatmentClaimed => /\ spouseConsentFiled /\ form709FiledByBothSpouses`

Meaning:
- the model lets a split-gift treatment claim exist without the joint Form 709 consent filings
- this is the Form 709 gift-splitting gap: IRS instructions say spouses must file gift tax returns consenting to split gifts, but the state machine allows the split-gift state to exist without the consent-state pair

### 269. HSA excess contribution Form 5329 excise failure

Model: `work/TaxHSAExcessContributionGap.tla`

Trace:
1. initial state
2. `MakeExcessHSAContribution`

Observed state:
- `hsaContributionMade = TRUE`
- `excessContributionExists = TRUE`
- `form5329Filed = FALSE`
- `exciseTaxApplied = FALSE`

Expected invariant:
- `excessContributionExists => /\ form5329Filed /\ exciseTaxApplied`

Meaning:
- the model lets an HSA excess contribution exist without the Form 5329 excise-tax reporting layer
- this is the HSA excess-contribution gap: IRS Publication 969 and Form 5329 guidance say excess HSA contributions are subject to the 6% excise tax and reported through Form 5329, but the state machine allows the excess-contribution state to exist without the reporting and tax states

### 270. Form 2553 S corporation election failure

Model: `work/TaxForm2553ElectionGap.tla`

Trace:
1. initial state
2. `ClaimSCorpTreatmentWithoutForm2553`

Observed state:
- `sCorpTreatmentClaimed = TRUE`
- `form2553Filed = FALSE`
- `shareholderConsentFiled = FALSE`

Expected invariant:
- `sCorpTreatmentClaimed => /\ form2553Filed /\ shareholderConsentFiled`

Meaning:
- the model lets S corporation treatment be claimed without the Form 2553 election and shareholder consent
- this is the Form 2553 election gap: IRS instructions say a corporation elects S status by filing Form 2553 and getting shareholder consent, but the state machine allows the S-status state to exist without the election state

### 271. Form 706-QDT taxable distribution reporting failure

Model: `work/TaxForm706QDTGap.tla`

Trace:
1. initial state
2. `MakeTaxableQDOTDistribution`

Observed state:
- `qdotExists = TRUE`
- `taxableDistributionMade = TRUE`
- `form706QDTFiled = FALSE`

Expected invariant:
- `taxableDistributionMade => form706QDTFiled`

Meaning:
- the model lets a taxable QDOT distribution exist without filing Form 706-QDT
- this is the Form 706-QDT gap: IRS instructions say the trustee or designated filer uses Form 706-QDT to figure and report tax due on certain QDOT distributions, but the state machine allows the taxable-distribution state to exist without the filing state

### 702. Form 706-QDT timely payment failure

Model: `work/TaxForm706QDTTimelyPaymentGap.tla`

Trace:
1. initial state
2. `MakeTaxableQDOTDistribution`
3. `PassQDOTPaymentDeadline`
4. `FileAndPayForm706QDT`

Observed state:
- `qdotExists = TRUE`
- `taxableDistributionMade = TRUE`
- `form706QDTFiled = TRUE`
- `qdotTaxPaymentDeadlinePassed = TRUE`
- `qdotTaxPaidByDeadline = FALSE`

Expected invariant:
- `taxableDistributionMade /\ form706QDTFiled => qdotTaxPaidByDeadline`

Meaning:
- the model lets a QDOT make a taxable distribution and then file/pay Form 706-QDT after the payment deadline while still satisfying the taxable-distribution state
- this is a distinct Form 706-QDT timing gap: IRS instructions say the return and tax are generally due on or before April 15 of the year following the taxable event, but the state machine does not encode that payment deadline

### 272. Form 1041 trust filing threshold failure

Model: `work/TaxForm1041FilingThresholdGap.tla`

Trace:
1. initial state
2. `EarnIncome`

Observed state:
- `trustExists = TRUE`
- `grossIncomeAtLeast600 = TRUE`
- `nonresidentAlienBeneficiary = FALSE`
- `form1041Filed = FALSE`

Expected invariant:
- `trustExists /\ (grossIncomeAtLeast600 \/ nonresidentAlienBeneficiary) => form1041Filed`

Meaning:
- the model lets a trust cross the Form 1041 filing threshold without filing the return
- this is the Form 1041 filing-threshold gap: IRS guidance says a domestic trust or estate with the relevant gross-income threshold or nonresident-alien beneficiary must file Form 1041, but the state machine allows the filing-trigger state to exist without the return state

### 273. Form 1041-QFT qualified funeral trust filing failure

Model: `work/TaxForm1041QFTGap.tla`

Trace:
1. initial state
2. `EarnQFTIncome`

Observed state:
- `qftElected = TRUE`
- `taxableIncomeExists = TRUE`
- `form1041QFTFiled = FALSE`

Expected invariant:
- `qftElected /\ taxableIncomeExists => form1041QFTFiled`

Meaning:
- the model lets a qualified funeral trust have taxable income without filing Form 1041-QFT
- this is the Form 1041-QFT gap: IRS instructions say a trustee of a QFT uses Form 1041-QFT to report income, deductions, gains, losses, and tax liability, but the state machine allows the taxable-income state to exist without the QFT return state

### 274. Form 1041-N Alaska Native settlement trust election failure

Model: `work/TaxForm1041NElectionGap.tla`

Trace:
1. initial state
2. `MakeSection646ElectionWithoutForm1041N`

Observed state:
- `anstExists = TRUE`
- `section646ElectionMade = TRUE`
- `form1041NFiled = FALSE`

Expected invariant:
- `section646ElectionMade => form1041NFiled`

Meaning:
- the model lets an Alaska Native settlement trust make the section 646 election without filing Form 1041-N
- this is the Form 1041-N election gap: IRS guidance says the election is made by filing Form 1041-N and that the form also serves as the trust’s income tax return, but the state machine allows the election state to exist without the return state

### 275. Form 1041-T beneficiary allocation failure

Model: `work/TaxForm1041TAllocationGap.tla`

Trace:
1. initial state
2. `ClaimAllocationWithoutForm1041T`

Observed state:
- `estateOrTrustExists = TRUE`
- `beneficiaryAllocationClaimed = TRUE`
- `daysSinceTaxYearEnd = 0`
- `form1041TFiled = FALSE`

Expected invariant:
- `beneficiaryAllocationClaimed => form1041TFiled`

Meaning:
- the model lets a trust or estate allocate estimated tax payments to beneficiaries without filing Form 1041-T
- this is the Form 1041-T allocation gap: IRS guidance says the fiduciary uses Form 1041-T to elect beneficiary allocation of estimated tax payments, but the state machine allows the allocation state to exist without the election form

### 689. Form 1041-T timely beneficiary-allocation failure

Model: `work/TaxForm1041TTimelyAllocationGap.tla`

Trace:
1. initial state
2. `AdvanceTime`
3. `AdvanceTime`
4. `AdvanceTime`
5. `AdvanceTime`
6. `AdvanceTime`
7. `AdvanceTime`
8. `AdvanceTime`
9. `AdvanceTime`
10. `AdvanceTime`
11. `AdvanceTime`
12. `AdvanceTime`
13. `AdvanceTime`
14. `AdvanceTime`
15. `AdvanceTime`
16. `AdvanceTime`
17. `AdvanceTime`
18. `AdvanceTime`
19. `AdvanceTime`
20. `AdvanceTime`
21. `AdvanceTime`
22. `AdvanceTime`
23. `AdvanceTime`
24. `AdvanceTime`
25. `AdvanceTime`
26. `AdvanceTime`
27. `AdvanceTime`
28. `AdvanceTime`
29. `AdvanceTime`
30. `AdvanceTime`
31. `AdvanceTime`
32. `AdvanceTime`
33. `AdvanceTime`
34. `AdvanceTime`
35. `AdvanceTime`
36. `AdvanceTime`
37. `AdvanceTime`
38. `AdvanceTime`
39. `AdvanceTime`
40. `AdvanceTime`
41. `AdvanceTime`
42. `AdvanceTime`
43. `AdvanceTime`
44. `AdvanceTime`
45. `AdvanceTime`
46. `AdvanceTime`
47. `AdvanceTime`
48. `AdvanceTime`
49. `AdvanceTime`
50. `AdvanceTime`
51. `AdvanceTime`
52. `AdvanceTime`
53. `AdvanceTime`
54. `AdvanceTime`
55. `AdvanceTime`
56. `AdvanceTime`
57. `AdvanceTime`
58. `AdvanceTime`
59. `AdvanceTime`
60. `AdvanceTime`
61. `AdvanceTime`
62. `AdvanceTime`
63. `AdvanceTime`
64. `AdvanceTime`
65. `AdvanceTime`
66. `AdvanceTime`
67. `FileForm1041T`
68. `ClaimAllocation`

Observed state:
- `estateOrTrustExists = TRUE`
- `beneficiaryAllocationClaimed = TRUE`
- `daysSinceTaxYearEnd = 66`
- `form1041TFiled = TRUE`
- `allocationDeadlinePassed = TRUE`
- `form1041TFiledByDeadline = FALSE`

Expected invariant:
- `beneficiaryAllocationClaimed /\ form1041TFiled => form1041TFiledByDeadline`

Meaning:
- the model lets an estate or trust wait past the 65-day window, file Form 1041-T, and still claim beneficiary allocation
- this is a distinct Form 1041-T timing gap: IRS guidance ties the allocation election to a 65-day filing window after year-end, but the state machine does not encode that deadline

### 690. Form 1045 timely tentative-refund failure

Model: `work/TaxForm1045TimelyTentativeRefundGap.tla`

Trace:
1. initial state
2. `ClaimTentativeRefund`
3. `PassFilingDeadline`
4. `FileForm1045`

Observed state:
- `tentativeRefundClaimed = TRUE`
- `form1045Filed = TRUE`
- `filingDeadlinePassed = TRUE`
- `form1045FiledByDeadline = FALSE`

Expected invariant:
- `tentativeRefundClaimed /\ form1045Filed => form1045FiledByDeadline`

Meaning:
- the model lets a taxpayer claim a tentative refund and then file Form 1045 after the filing window has already closed
- this is a distinct Form 1045 timing gap: IRS instructions say Form 1045 generally must be filed within 1 year after the end of the year in which the carryback or adjustment arose, but the state machine does not encode that deadline

### 276. Form 1120-S S corporation filing failure

Model: `work/TaxForm1120SFilingGap.tla`

Trace:
1. initial state
2. `EndTaxYear`

Observed state:
- `sCorpStatus = TRUE`
- `taxYearEnded = TRUE`
- `form1120SFiled = FALSE`

Expected invariant:
- `sCorpStatus /\ taxYearEnded => form1120SFiled`

Meaning:
- the model lets an S corporation reach the end of its tax year without filing Form 1120-S
- this is the Form 1120-S filing gap: IRS guidance says an S corporation must file Form 1120-S by the 15th day of the 3rd month after its tax year ends, but the state machine allows the year-end state to exist without the return-filing state

### 277. Form 1066 REMIC filing failure

Model: `work/TaxForm1066FilingGap.tla`

Trace:
1. initial state
2. `GenerateTaxableActivity`

Observed state:
- `remicExists = TRUE`
- `taxableActivityExists = TRUE`
- `form1066Filed = FALSE`

Expected invariant:
- `remicExists /\ taxableActivityExists => form1066Filed`

Meaning:
- the model lets a REMIC generate taxable activity without filing Form 1066
- this is the Form 1066 filing gap: IRS guidance says a REMIC files Form 1066 to report income, deductions, gains, and losses from its operation, but the state machine allows the taxable-activity state to exist without the return state

### 278. Form 1041-A charitable accumulation reporting failure

Model: `work/TaxForm1041ACharitableAmountsGap.tla`

Trace:
1. initial state
2. `CreateCharitableAccumulationReportNeed`

Observed state:
- `trustClaimsCharitableAccumulation = TRUE`
- `form1041AFiled = FALSE`

Expected invariant:
- `trustClaimsCharitableAccumulation => form1041AFiled`

Meaning:
- the model lets a trust claim charitable accumulation reporting without filing Form 1041-A
- this is the Form 1041-A gap: IRS guidance says the trustee uses Form 1041-A to report charitable information required by section 6034, but the state machine allows the charitable-accumulation state to exist without the information-return state

### 279. Form 990-T unrelated business income filing failure

Model: `work/TaxForm990TUBIGap.tla`

Trace:
1. initial state
2. `GenerateUBI`

Observed state:
- `exemptOrgExists = TRUE`
- `unrelatedBusinessIncome = 1000`
- `form990TFiled = FALSE`

Expected invariant:
- `exemptOrgExists /\ unrelatedBusinessIncome >= UBITThreshold => form990TFiled`

Meaning:
- the model lets a tax-exempt organization reach the unrelated-business-income threshold without filing Form 990-T
- this is the Form 990-T gap: IRS guidance says an exempt organization with $1,000 or more of gross unrelated business income must file Form 990-T, but the state machine allows the threshold state to exist without the return state

### 280. Form 990-PF private foundation filing failure

Model: `work/TaxForm990PFFilingGap.tla`

Trace:
1. initial state
2. `EndAccountingPeriod`

Observed state:
- `privateFoundationExists = TRUE`
- `annualReturnDue = TRUE`
- `form990PFiled = FALSE`

Expected invariant:
- `privateFoundationExists /\ annualReturnDue => form990PFiled`

Meaning:
- the model lets a private foundation hit the annual filing requirement without filing Form 990-PF
- this is the Form 990-PF gap: IRS guidance says private foundations must file Form 990-PF annually, but the state machine allows the annual-due state to exist without the return state

### 281. Form 3115 accounting method change failure

Model: `work/TaxForm3115AccountingMethodGap.tla`

Trace:
1. initial state
2. `ChangeAccountingMethod`

Observed state:
- `accountingMethodChanged = TRUE`
- `form3115Filed = FALSE`

Expected invariant:
- `accountingMethodChanged => form3115Filed`

Meaning:
- the model lets an accounting method change occur without filing Form 3115
- this is the Form 3115 gap: IRS guidance says Form 3115 is used to request a change in accounting method, but the state machine allows the method-change state to exist without the form-filing state

### 281.1. Form 3115 section 481(a) adjustment failure

Model: `work/TaxForm3115Section481AdjustmentGap.tla`

Trace:
1. initial state
2. `ChangeAccountingMethod`

Observed state:
- `priorMethodItemsExist = TRUE`
- `accountingMethodChanged = TRUE`
- `section481AdjustmentApplied = FALSE`

Expected invariant:
- `accountingMethodChanged /\ priorMethodItemsExist => section481AdjustmentApplied`

Meaning:
- the model lets an accounting method change occur while the section 481(a) adjustment is still absent
- this is the section 481(a) gap: IRS instructions say accounting method changes ordinarily require a section 481(a) adjustment to prevent duplication or omission of income or deductions, but the state machine allows the changed-method state to exist without the adjustment state

### 282. Form 8986/8985 BBA pushout failure

Model: `work/TaxForm8986PushoutGap.tla`

Trace:
1. initial state
2. `MakeAdjustment`
3. `MakePushoutElectionWithoutForms`

Observed state:
- `partnershipAdjusted = TRUE`
- `pushoutElectionMade = TRUE`
- `forms8985And8986Filed = FALSE`

Expected invariant:
- `partnershipAdjusted /\ pushoutElectionMade => forms8985And8986Filed`

Meaning:
- the model lets a BBA partnership make the pushout election without filing Forms 8985 and 8986
- this is the Form 8986/8985 gap: IRS guidance says the partnership must furnish and submit Forms 8986 with Form 8985 when it pushes out adjustments, but the state machine allows the pushout-election state to exist without the transmittal/statement filing state

### 283. Form 5330 prohibited transaction excise failure

Model: `work/TaxForm5330ProhibitedTransactionGap.tla`

Trace:
1. initial state
2. `EngageProhibitedTransaction`

Observed state:
- `disqualifiedPerson = TRUE`
- `prohibitedTransactionOccurred = TRUE`
- `form5330Filed = FALSE`

Expected invariant:
- `disqualifiedPerson /\ prohibitedTransactionOccurred => form5330Filed`

Meaning:
- the model lets a prohibited transaction occur without filing Form 5330
- this is the Form 5330 gap: IRS guidance says a disqualified person who engages in a prohibited transaction must file Form 5330 to report and pay the excise tax, but the state machine allows the prohibited-transaction state to exist without the excise-return state

### 284. Form 5500-EZ one-participant plan filing failure

Model: `work/TaxForm5500EZFilingGap.tla`

Trace:
1. initial state
2. `GrowPlanAssets`

Observed state:
- `oneParticipantPlanExists = TRUE`
- `planAssets = 250000`
- `form5500EZFiled = FALSE`

Expected invariant:
- `oneParticipantPlanExists /\ planAssets >= AssetThreshold => form5500EZFiled`

Meaning:
- the model lets a one-participant plan hit the asset threshold without filing Form 5500-EZ
- this is the Form 5500-EZ gap: IRS guidance says a one-participant retirement plan or foreign plan must file Form 5500-EZ, and the state machine allows the threshold state to exist without the annual return state

### 285. Form 8955-SSA separated participant reporting failure

Model: `work/TaxForm8955SSAReportingGap.tla`

Trace:
1. initial state
2. `ParticipantSeparatesWithDeferredBenefit`

Observed state:
- `separatedParticipantExists = TRUE`
- `deferredVestedBenefitExists = TRUE`
- `form8955SSAFiled = FALSE`

Expected invariant:
- `separatedParticipantExists /\ deferredVestedBenefitExists => form8955SSAFiled`

Meaning:
- the model lets a separated participant with a deferred vested benefit exist without filing Form 8955-SSA
- this is the Form 8955-SSA gap: IRS guidance says plan administrators must report separated participants with deferred vested benefits on Form 8955-SSA, but the state machine allows the reporting-trigger state to exist without the annual registration statement

### 286. Form 5498-ESA Coverdell contribution reporting failure

Model: `work/TaxForm5498ESAReportingGap.tla`

Trace:
1. initial state
2. `MakeContribution`

Observed state:
- `coverdellESAExists = TRUE`
- `contributionMade = TRUE`
- `form5498ESAFiled = FALSE`

Expected invariant:
- `coverdellESAExists /\ contributionMade => form5498ESAFiled`

Meaning:
- the model lets a Coverdell ESA contribution exist without filing Form 5498-ESA
- this is the Form 5498-ESA gap: IRS guidance says trustees or issuers file Form 5498-ESA to report Coverdell ESA contributions and rollover contributions, but the state machine allows the contribution state to exist without the contribution-reporting statement

### 286.1. Form 5498-ESA corrected return furnishing failure

Model: `work/TaxForm5498ESACorrectionGap.tla`

Trace:
1. initial state
2. `FileOriginal5498ESA`
3. `DiscoverError`

Observed state:
- `coverdellESAExists = TRUE`
- `original5498ESAFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected5498ESAFiled = FALSE`
- `beneficiaryCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original5498ESAFiled) => corrected5498ESAFiled`
- `corrected5498ESAFiled => beneficiaryCopyFurnished`

Meaning:
- the model lets a Coverdell ESA filing error be discovered after the original Form 5498-ESA exists without forcing the corrected return or beneficiary copy
- this is the Form 5498-ESA correction gap: the information-return rules contemplate corrected returns and recipient statements, but the state machine allows the correction branch to stop before either the corrected filing or the beneficiary copy is made mandatory

### 287. Form 4720 private foundation self-dealing excise failure

Model: `work/TaxForm4720SelfDealingGap.tla`

Trace:
1. initial state
2. `EngageSelfDealing`

Observed state:
- `privateFoundationExists = TRUE`
- `selfDealingOccurred = TRUE`
- `form4720Filed = FALSE`

Expected invariant:
- `privateFoundationExists /\ selfDealingOccurred => form4720Filed`

Meaning:
- the model lets a private foundation engage in self-dealing without filing Form 4720
- this is the Form 4720 gap: IRS guidance says a private foundation that violates a chapter 41 or 42 rule must file Form 4720 to report and pay the excise tax, but the state machine allows the self-dealing state to exist without the excise-return state

### 288. Form 8868 extension request failure

Model: `work/TaxForm8868ExtensionGap.tla`

Trace:
1. initial state
2. `ReturnBecomesDue`
3. `RequestExtensionWithoutForm8868`

Observed state:
- `returnDue = TRUE`
- `extensionRequested = TRUE`
- `form8868Filed = FALSE`

Expected invariant:
- `extensionRequested => form8868Filed`

Meaning:
- the model lets an extension be requested without filing Form 8868
- this is the Form 8868 gap: IRS guidance says Form 8868 is used to request an automatic extension for exempt-organization, trust, and employee-plan returns, but the state machine allows the extension-request state to exist without the extension form state

### 289. Form 8978 partner reporting-year tax failure

Model: `work/TaxForm8978ReportingGap.tla`

Trace:
1. initial state
2. `Receive8986`
3. `FileReportingReturnWithout8978`

Observed state:
- `partnerReceived8986 = TRUE`
- `reportingYearReturnFiled = TRUE`
- `form8978Attached = FALSE`

Expected invariant:
- `partnerReceived8986 /\ reportingYearReturnFiled => form8978Attached`

Meaning:
- the model lets a partner receive a Form 8986 and file the reporting-year return without attaching Form 8978
- this is the Form 8978 gap: IRS guidance says a partner who receives Form 8986 must file Form 8978 with the reporting-year return to report the additional reporting year tax, but the state machine allows the reporting-return state to exist without the attachment state

### 290. Form 6069 black lung trust excess contribution failure

Model: `work/TaxForm6069BlackLungGap.tla`

Trace:
1. initial state
2. `MakeExcessContribution`

Observed state:
- `blackLungTrustExists = TRUE`
- `excessContributionMade = TRUE`
- `form6069Filed = FALSE`

Expected invariant:
- `blackLungTrustExists /\ excessContributionMade => form6069Filed`

Meaning:
- the model lets a black lung trust make an excess contribution without filing Form 6069
- this is the Form 6069 gap: IRS guidance says Form 6069 is used to report certain excise taxes on black lung trusts and excess contributions, but the state machine allows the excess-contribution state to exist without the excise-return state

### 291. Form 2290 heavy highway vehicle use tax failure

Model: `work/TaxForm2290HeavyVehicleGap.tla`

Trace:
1. initial state
2. `VehicleUsedOnHighway`

Observed state:
- `highwayVehicleUsed = TRUE`
- `taxableGrossWeight = 55000`
- `form2290Filed = FALSE`

Expected invariant:
- `highwayVehicleUsed /\ taxableGrossWeight >= WeightThreshold => form2290Filed`

Meaning:
- the model lets a heavy highway vehicle hit the taxable-weight threshold without filing Form 2290
- this is the Form 2290 gap: IRS guidance says owners of highway motor vehicles with taxable gross weight of 55,000 pounds or more must figure and pay the heavy highway vehicle use tax on Form 2290, but the state machine allows the threshold-vehicle state to exist without the return state

### 292. Form 5227 split-interest trust reporting failure

Model: `work/TaxForm5227SplitInterestGap.tla`

Trace:
1. initial state
2. `CreateFinancialActivity`

Observed state:
- `splitInterestTrustExists = TRUE`
- `financialActivityExists = TRUE`
- `form5227Filed = FALSE`

Expected invariant:
- `splitInterestTrustExists /\ financialActivityExists => form5227Filed`

Meaning:
- the model lets a split-interest trust have financial activity without filing Form 5227
- this is the Form 5227 gap: IRS guidance says split-interest trusts must annually file Form 5227 to report financial activity and determine whether they are treated as private foundations, but the state machine allows the financial-activity state to exist without the annual information-return state

### 293. Form 1120-POL political organization filing failure

Model: `work/TaxForm1120POLFilingGap.tla`

Trace:
1. initial state
2. `EarnTaxableIncome`

Observed state:
- `politicalOrganizationExists = TRUE`
- `politicalOrganizationTaxableIncome = 101`
- `form1120POLFiled = FALSE`

Expected invariant:
- `politicalOrganizationExists /\ politicalOrganizationTaxableIncome > 100 => form1120POLFiled`

Meaning:
- the model lets a political organization cross the Form 1120-POL filing threshold without filing
- this is the Form 1120-POL gap: IRS guidance says political organizations with taxable income after the $100 specific deduction must file Form 1120-POL, but the state machine allows the taxable-income state to exist without the return-filing state

### 294. Form 8871 initial notice failure

Model: `work/TaxForm8871InitialNoticeGap.tla`

Trace:
1. initial state
2. `ReceiveGrossReceipts`

Observed state:
- `politicalOrganizationExists = TRUE`
- `annualGrossReceipts = 25000`
- `form8871Filed = FALSE`

Expected invariant:
- `politicalOrganizationExists /\ annualGrossReceipts >= 25000 => form8871Filed`

Meaning:
- the model lets a political organization hit the Form 8871 gross-receipts threshold without filing the initial notice
- this is the Form 8871 gap: IRS guidance says an organization with annual gross receipts of $25,000 or more must file Form 8871 within 30 days to continue being tax-exempt, but the state machine allows the threshold state to exist without the notice state

### 295. Form 8872 periodic report failure

Model: `work/TaxForm8872PeriodicReportGap.tla`

Trace:
1. initial state
2. `AcceptReportableActivity`

Observed state:
- `politicalOrganizationExists = TRUE`
- `reportableContributionOrExpenditure = TRUE`
- `form8872Filed = FALSE`

Expected invariant:
- `politicalOrganizationExists /\ reportableContributionOrExpenditure => form8872Filed`

Meaning:
- the model lets a tax-exempt section 527 political organization accept reportable activity without filing Form 8872
- this is the Form 8872 gap: IRS guidance says section 527 political organizations that accept contributions or make expenditures for an exempt function must file Form 8872 unless an exception applies, but the state machine allows the reportable-activity state to exist without the periodic-report state

### 296. Form 990-N small exempt organization filing failure

Model: `work/TaxForm990NGap.tla`

Trace:
1. initial state
2. `ReceiveGrossReceipts`

Observed state:
- `smallTaxExemptOrgExists = TRUE`
- `annualGrossReceipts = 50000`
- `form990NFiled = FALSE`

Expected invariant:
- `smallTaxExemptOrgExists /\ annualGrossReceipts <= 50000 => form990NFiled`

Meaning:
- the model lets a small exempt organization stay at the Form 990-N gross-receipts threshold without filing the e-Postcard
- this is the Form 990-N gap: IRS guidance says most small tax-exempt organizations whose gross receipts are normally $50,000 or less must file Form 990-N annually, but the state machine allows the threshold state to exist without the annual notice

### 297. Form 990-BL black lung trust annual return failure

Model: `work/TaxForm990BLGap.tla`

Trace:
1. initial state
2. `CloseTaxYear`

Observed state:
- `blackLungBenefitTrustExists = TRUE`
- `annualReturnDue = TRUE`
- `form990BLFiled = FALSE`

Expected invariant:
- `blackLungBenefitTrustExists /\ annualReturnDue => form990BLFiled`

Meaning:
- the model lets a black lung benefit trust have an annual return due without filing Form 990-BL
- this is the Form 990-BL gap: IRS guidance says black lung benefit trusts use Form 990-BL to meet section 6033 reporting requirements, but the state machine allows the due state to exist without the return state

### 298. Form 990-BL Schedule A initial excise tax failure

Model: `work/TaxForm990BLScheduleAGap.tla`

Trace:
1. initial state
2. `ImposeInitialExciseTax`

Observed state:
- `blackLungBenefitTrustExists = TRUE`
- `initialExciseTaxImposed = TRUE`
- `scheduleAFiled = FALSE`

Expected invariant:
- `blackLungBenefitTrustExists /\ initialExciseTaxImposed => scheduleAFiled`

Meaning:
- the model lets a black lung benefit trust incur an initial excise tax without filing Schedule A to report it
- this is the Schedule A gap: IRS instructions say initial excise taxes on black lung benefit trusts and related persons are reported on Schedule A (Form 990-BL), but the state machine allows the excise-tax state to exist without the schedule-filing state

### 299. Form 8886 reportable transaction disclosure failure

Model: `work/TaxForm8886DisclosureGap.tla`

Trace:
1. initial state
2. `EnterReportableTransaction`

Observed state:
- `taxReturnRequired = TRUE`
- `participatedInReportableTransaction = TRUE`
- `form8886Attached = FALSE`

Expected invariant:
- `taxReturnRequired /\ participatedInReportableTransaction => form8886Attached`

Meaning:
- the model lets a taxpayer participate in a reportable transaction and owe a return without attaching Form 8886
- this is the Form 8886 gap: IRS guidance says taxpayers must disclose each reportable transaction on Form 8886 and generally attach it to the return, but the state machine allows the reportable-transaction state to exist without the disclosure attachment

### 300. Form 8886-T prohibited tax shelter disclosure failure

Model: `work/TaxForm8886TDisclosureGap.tla`

Trace:
1. initial state
2. `EnterProhibitedTaxShelterTransaction`

Observed state:
- `taxExemptEntityExists = TRUE`
- `prohibitedTaxShelterTransactionOccurred = TRUE`
- `form8886TFiled = FALSE`

Expected invariant:
- `taxExemptEntityExists /\ prohibitedTaxShelterTransactionOccurred => form8886TFiled`

Meaning:
- the model lets a tax-exempt entity enter a prohibited tax shelter transaction without filing Form 8886-T
- this is the Form 8886-T gap: IRS guidance says certain tax-exempt entities must disclose each prohibited tax shelter transaction on Form 8886-T, but the state machine allows the prohibited-transaction state to exist without the disclosure form

### 301. Form 8899 qualified intellectual property income failure

Model: `work/TaxForm8899IntellectualPropertyGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedIPIncome`

Observed state:
- `doneeOrganizationExists = TRUE`
- `qualifiedIntellectualPropertyContributionReceived = TRUE`
- `netIncomeAccrued = TRUE`
- `form8899Filed = FALSE`

Expected invariant:
- `doneeOrganizationExists /\ qualifiedIntellectualPropertyContributionReceived /\ netIncomeAccrued => form8899Filed`

Meaning:
- the model lets a donee organization receive net income from qualified intellectual property without filing Form 8899
- this is the Form 8899 gap: IRS guidance says certain donee organizations that receive or accrue net income from qualified intellectual property must file Form 8899, but the state machine allows the income state to exist without the notice state

### 302. Form 8282 charitable property disposition failure

Model: `work/TaxForm8282DispositionGap.tla`

Trace:
1. initial state
2. `DisposeOfCharitableDeductionProperty`

Observed state:
- `doneeOrganizationExists = TRUE`
- `charitableDeductionPropertyDisposed = TRUE`
- `form8282Filed = FALSE`

Expected invariant:
- `doneeOrganizationExists /\ charitableDeductionPropertyDisposed => form8282Filed`

Meaning:
- the model lets a donee organization dispose of charitable deduction property without filing Form 8282
- this is the Form 8282 gap: IRS guidance says donee organizations must report dispositions of certain charitable deduction property on Form 8282 within three years, but the state machine allows the disposition state to exist without the reporting form

### 303. Form 1098-C vehicle donation acknowledgment failure

Model: `work/TaxForm1098CVehicleGap.tla`

Trace:
1. initial state
2. `ReceiveQualifiedVehicleContribution`

Observed state:
- `doneeOrganizationExists = TRUE`
- `qualifiedVehicleClaimedValue = 501`
- `form1098CFiled = FALSE`

Expected invariant:
- `doneeOrganizationExists /\ qualifiedVehicleClaimedValue > 500 => form1098CFiled`

Meaning:
- the model lets a donee organization receive a qualified vehicle contribution over the Form 1098-C threshold without filing the acknowledgment
- this is the Form 1098-C gap: IRS guidance says donee organizations must file Form 1098-C for each contribution of a qualified vehicle with a claimed value over $500, but the state machine allows the vehicle-contribution state to exist without the acknowledgment form

### 304. Form 8925 employer-owned life insurance reporting failure

Model: `work/TaxForm8925LifeInsuranceGap.tla`

Trace:
1. initial state
2. `AcquireCoveredContract`

Observed state:
- `policyholderOwnsContract = TRUE`
- `contractIssuedAfter2006 = TRUE`
- `form8925Filed = FALSE`

Expected invariant:
- `policyholderOwnsContract /\ contractIssuedAfter2006 => form8925Filed`

Meaning:
- the model lets a policyholder own an employer-owned life insurance contract issued after August 17, 2006 without filing Form 8925
- this is the Form 8925 gap: IRS guidance says every policyholder owning one or more covered employer-owned life insurance contracts must file Form 8925, but the state machine allows the covered-contract state to exist without the reporting form

### 305. Form 8928 comparable HSA contribution failure

Model: `work/TaxForm8928HSAContributionGap.tla`

Trace:
1. initial state
2. `MakeNoncomparableHSAContributions`

Observed state:
- `employerExists = TRUE`
- `comparableHSAContributionsMade = FALSE`
- `form8928Filed = FALSE`

Expected invariant:
- `employerExists /\ ~comparableHSAContributionsMade => form8928Filed`

Meaning:
- the model lets an employer make noncomparable HSA contributions without filing Form 8928
- this is the Form 8928 gap: IRS guidance says group health plans or employers liable for chapter 43 excise tax failures file Form 8928, including failures to make comparable HSA contributions, but the state machine allows the failure state to exist without the excise return

### 306. Form 8918 material advisor disclosure failure

Model: `work/TaxForm8918MaterialAdvisorGap.tla`

Trace:
1. initial state
2. `EnterReportableTransaction`

Observed state:
- `materialAdvisorExists = TRUE`
- `reportableTransactionEntered = TRUE`
- `form8918Filed = FALSE`

Expected invariant:
- `materialAdvisorExists /\ reportableTransactionEntered => form8918Filed`

Meaning:
- the model lets a material advisor be connected to a reportable transaction without filing Form 8918
- this is the Form 8918 gap: IRS guidance says material advisors to reportable transactions generally must file Form 8918 to disclose the transaction, but the state machine allows the reportable-transaction state to exist without the disclosure form

### 307. Form 8941 small employer health insurance credit failure

Model: `work/TaxForm8941SmallEmployerCreditGap.tla`

Trace:
1. initial state
2. `PayHealthInsurancePremiums`

Observed state:
- `eligibleSmallEmployer = TRUE`
- `paidHealthInsurancePremiums = TRUE`
- `form8941Filed = FALSE`

Expected invariant:
- `eligibleSmallEmployer /\ paidHealthInsurancePremiums => form8941Filed`

Meaning:
- the model lets an eligible small employer pay qualifying health insurance premiums without filing Form 8941 to figure the credit
- this is the Form 8941 gap: IRS guidance says eligible small employers use Form 8941 to calculate the small employer health insurance premium credit, but the state machine allows the qualifying-premium state to exist without the credit-calculation form

### 308. Form 8924 geothermal or mineral transfer excise failure

Model: `work/TaxForm8924GeothermalTransferGap.tla`

Trace:
1. initial state
2. `MakeQualifyingTransfer`

Observed state:
- `eligibleEntity = TRUE`
- `qualifyingTransferOccurred = TRUE`
- `form8924Filed = FALSE`

Expected invariant:
- `eligibleEntity /\ qualifyingTransferOccurred => form8924Filed`

Meaning:
- the model lets an eligible entity make a qualifying geothermal or mineral transfer without filing Form 8924
- this is the Form 8924 gap: IRS guidance says eligible entities that later transfer qualifying mineral or geothermal interests must report and pay the excise tax on Form 8924, but the state machine allows the transfer state to exist without the excise return

### 309. Form 8300 cash transaction reporting failure

Model: `work/TaxForm8300CashTransactionGap.tla`

Trace:
1. initial state
2. `ReceiveCashTransaction`

Observed state:
- `businessExists = TRUE`
- `cashTransactionAmount = 10001`
- `form8300Filed = FALSE`

Expected invariant:
- `businessExists /\ cashTransactionAmount > 10000 => form8300Filed`

Meaning:
- the model lets a business receive more than $10,000 in cash without filing Form 8300
- this is the Form 8300 gap: IRS guidance says a person in a trade or business must report cash payments over $10,000 on Form 8300, but the state machine allows the reportable-cash state to exist without the reporting form

### 310. Form 8936 clean vehicle credit filing failure

Model: `work/TaxForm8936CleanVehicleGap.tla`

Trace:
1. initial state
2. `PlaceCleanVehicleInService`

Observed state:
- `vehiclePlacedInService = TRUE`
- `form8936Filed = FALSE`

Expected invariant:
- `vehiclePlacedInService => form8936Filed`

Meaning:
- the model lets a clean vehicle be placed in service without filing Form 8936
- this is the Form 8936 gap: IRS guidance says taxpayers must file Form 8936 and Schedule A to figure clean vehicle credits, but the state machine allows the vehicle-placed-in-service state to exist without the credit form

### 311. Form 8889 HSA reporting failure

Model: `work/TaxForm8889HSAReportingGap.tla`

Trace:
1. initial state
2. `TriggerHSAReporting`

Observed state:
- `hsaContributionOrDistributionOccurred = TRUE`
- `form8889Filed = FALSE`

Expected invariant:
- `hsaContributionOrDistributionOccurred => form8889Filed`

Meaning:
- the model lets an HSA contribution or distribution occur without filing Form 8889
- this is the Form 8889 gap: IRS guidance says Form 8889 must be filed to report HSA contributions and distributions, but the state machine allows the HSA-event state to exist without the reporting form

### 312. Form 1099-SA HSA distribution reporting failure

Related model: `work/TaxForm1099SAHsaDistributionGap.tla`

Trace:
1. initial state
2. `MakeHsaDistribution`

Observed state:
- `hsaDistributionOccurred = TRUE`
- `form1099SAFiled = FALSE`

Expected invariant:
- `hsaDistributionOccurred => form1099SAFiled`

Meaning:
- the model lets an HSA distribution occur without filing Form 1099-SA
- this is the Form 1099-SA gap: IRS guidance says custodians must file Form 1099-SA to report HSA distributions, but the state machine allows the distribution state to exist without the information return

### 313. Form 5498-SA HSA information reporting failure

Model: `work/TaxForm5498SAHsaInformationGap.tla`

Trace:
1. initial state
2. `MaintainHSA`

Observed state:
- `trusteeMaintainsHSA = TRUE`
- `form5498SAFiled = FALSE`

Expected invariant:
- `trusteeMaintainsHSA => form5498SAFiled`

Meaning:
- the model lets a trustee maintain an HSA without filing Form 5498-SA
- this is the Form 5498-SA gap: IRS guidance says trustees or custodians must file Form 5498-SA for each HSA they maintained, but the state machine allows the maintained-account state to exist without the information return

### 314. Form 8853 Archer MSA contribution reporting failure

Model: `work/TaxForm8853ArcherMSAGap.tla`

Trace:
1. initial state
2. `MakeArcherMSAContribution`

Observed state:
- `archerMSAContributionOccurred = TRUE`
- `form8853Filed = FALSE`

Expected invariant:
- `archerMSAContributionOccurred => form8853Filed`

Meaning:
- the model lets an Archer MSA contribution occur without filing Form 8853
- this is the Form 8853 gap: IRS guidance says Form 8853 is used to report Archer MSA contributions and related distributions, but the state machine allows the contribution state to exist without the reporting form

### 315. Form 3921 incentive stock option transfer failure

Model: `work/TaxForm3921IsoTransferGap.tla`

Trace:
1. initial state
2. `TransferStockUnderISO`

Observed state:
- `corporationTransferredStockUnderISO = TRUE`
- `form3921Filed = FALSE`

Expected invariant:
- `corporationTransferredStockUnderISO => form3921Filed`

Meaning:
- the model lets a corporation transfer stock under an ISO exercise without filing Form 3921
- this is the Form 3921 gap: IRS guidance says corporations must file Form 3921 for each ISO stock transfer, but the state machine allows the transfer state to exist without the information return

### 316. Form 3922 employee stock purchase plan transfer failure

Model: `work/TaxForm3922EspTransferGap.tla`

Trace:
1. initial state
2. `RecordEspTransfer`

Observed state:
- `corporationRecordedEspTransfer = TRUE`
- `form3922Filed = FALSE`

Expected invariant:
- `corporationRecordedEspTransfer => form3922Filed`

Meaning:
- the model lets a corporation record an employee stock purchase plan transfer without filing Form 3922
- this is the Form 3922 gap: IRS guidance says corporations must file Form 3922 for each ESPP stock transfer, but the state machine allows the transfer state to exist without the information return

### 317. Form 8919 worker misclassification failure

Model: `work/TaxForm8919MisclassificationGap.tla`

Trace:
1. initial state
2. `MisclassifyWorker`

Observed state:
- `workerPerformedServices = TRUE`
- `treatedAsIndependentContractor = TRUE`
- `form8919Filed = FALSE`

Expected invariant:
- `workerPerformedServices /\ treatedAsIndependentContractor => form8919Filed`

Meaning:
- the model lets a worker be treated as an independent contractor after performing services without filing Form 8919
- this is the Form 8919 gap: IRS guidance says workers who were employees but treated as independent contractors use Form 8919 to report uncollected Social Security and Medicare taxes, but the state machine allows the misclassification state to exist without the corrective filing

### 317.1. Form SS-8 worker status determination failure

Model: `work/TaxFormSS8WorkerStatusGap.tla`

Trace:
1. initial state
2. `RequestWorkerStatusDetermination`

Observed state:
- `workerStatusDeterminationRequested = TRUE`
- `formSS8Filed = FALSE`

Expected invariant:
- `workerStatusDeterminationRequested => formSS8Filed`

Meaning:
- the model lets a worker-status determination be requested without filing Form SS-8
- this is the Form SS-8 gap: IRS guidance says firms and workers file Form SS-8 to request a worker-status determination for employment tax and withholding purposes, but the state machine allows the determination-request state to exist without the form state

### 318. Form 4137 unreported tip income failure

Model: `work/TaxForm4137TipReportingGap.tla`

Trace:
1. initial state
2. `ReceiveUnreportedTips`

Observed state:
- `workerReceivedTips = TRUE`
- `monthlyUnreportedTips = 20`
- `form4137Filed = FALSE`

Expected invariant:
- `workerReceivedTips /\ monthlyUnreportedTips >= 20 => form4137Filed`

Meaning:
- the model lets a worker receive unreported tips at the IRS filing threshold without filing Form 4137
- this is the Form 4137 gap: IRS guidance says workers must file Form 4137 for unreported tip income at or above the threshold, but the state machine allows the tip-income state to exist without the reporting form

### 319. Form 1099-R pension distribution reporting failure

Model: `work/TaxForm1099RPensionDistributionGap.tla`

Trace:
1. initial state
2. `MakeDesignatedDistribution`

Observed state:
- `payerMadeDesignatedDistribution = TRUE`
- `distributionAmount = 10`
- `form1099RFiled = FALSE`

Expected invariant:
- `payerMadeDesignatedDistribution /\ distributionAmount >= 10 => form1099RFiled`

Meaning:
- the model lets a designated distribution of $10 or more occur without filing Form 1099-R
- this is the Form 1099-R gap: IRS guidance says payers must file Form 1099-R for each designated distribution of $10 or more, but the state machine allows the distribution state to exist without the information return

### 320. Form 1096 paper transmittal failure

Model: `work/TaxForm1096PaperTransmittalGap.tla`

Trace:
1. initial state
2. `FilePaperInformationReturn`

Observed state:
- `paperInformationReturnFiled = TRUE`
- `form1096Filed = FALSE`

Expected invariant:
- `paperInformationReturnFiled => form1096Filed`

Meaning:
- the model lets a paper information return be filed without the required Form 1096 transmittal
- this is the Form 1096 gap: IRS guidance says paper Forms 1097, 1098, 1099, 3921, 3922, 5498, and W-2G must be transmitted with Form 1096, but the state machine allows the return state to exist without the transmittal state

### 321. Form 8027 large food/beverage tip reporting failure

Model: `work/TaxForm8027TipReportingGap.tla`

Trace:
1. initial state
2. `OperateLargeFoodOrBeverageEstablishment`

Observed state:
- `largeFoodOrBeverageEstablishment = TRUE`
- `form8027Filed = FALSE`

Expected invariant:
- `largeFoodOrBeverageEstablishment => form8027Filed`

Meaning:
- the model lets a large food or beverage establishment exist without the annual Form 8027 filing
- this is the Form 8027 gap: IRS guidance says employers operating a large food or beverage establishment use Form 8027 to annually report receipts and tips and to determine allocated tips for tipped employees, but the state machine allows the qualifying establishment state without the return state

### 322. Form 1095-C applicable large employer coverage reporting failure

Model: `work/TaxForm1095CReportingGap.tla`

Trace:
1. initial state
2. `GainFullTimeEmployee`

Observed state:
- `aleMemberHasFullTimeEmployee = TRUE`
- `form1095CFiled = FALSE`

Expected invariant:
- `aleMemberHasFullTimeEmployee => form1095CFiled`

Meaning:
- the model lets an applicable large employer member with a full-time employee exist without filing Form 1095-C
- this is the Form 1095-C gap: IRS guidance says Form 1095-C is filed and furnished for full-time employees of applicable large employer members, but the state machine allows the reporting trigger state without the form state

### 323. Form 1095-B health coverage reporting failure

Model: `work/TaxForm1095BHealthCoverageGap.tla`

Trace:
1. initial state
2. `ProvideMinimumEssentialCoverage`

Observed state:
- `minimumEssentialCoverageProvided = TRUE`
- `form1095BFiled = FALSE`

Expected invariant:
- `minimumEssentialCoverageProvided => form1095BFiled`

Meaning:
- the model lets minimum essential coverage exist without the corresponding Form 1095-B reporting
- this is the Form 1095-B gap: IRS guidance says Form 1095-B reports individuals covered by minimum essential coverage, but the state machine allows the coverage state without the return state

### 324. Form 1094-B health coverage transmittal failure

Model: `work/TaxForm1094BTransmittalGap.tla`

Trace:
1. initial state
2. `FileHealthCoverageReturn`

Observed state:
- `healthCoverageInformationReturnFiled = TRUE`
- `form1094BFiled = FALSE`

Expected invariant:
- `healthCoverageInformationReturnFiled => form1094BFiled`

Meaning:
- the model lets a health coverage information return exist without the required Form 1094-B transmittal
- this is the Form 1094-B gap: IRS guidance says Form 1094-B is the transmittal form filed with Form 1095-B, but the state machine allows the return state without the transmittal state

### 325. Form 1094-C employer coverage transmittal failure

Model: `work/TaxForm1094CTransmittalGap.tla`

Trace:
1. initial state
2. `FileEmployerProvidedCoverageReturn`

Observed state:
- `employerProvidedCoverageReturnFiled = TRUE`
- `form1094CFiled = FALSE`

Expected invariant:
- `employerProvidedCoverageReturnFiled => form1094CFiled`

Meaning:
- the model lets an employer-provided coverage return exist without the required Form 1094-C transmittal
- this is the Form 1094-C gap: IRS guidance says Form 1094-C is the transmittal form filed with Form 1095-C, but the state machine allows the return state without the transmittal state

### 326. Form W-2G gambling winnings reporting failure

Model: `work/TaxFormW2GGamblingReportingGap.tla`

Trace:
1. initial state
2. `PayReportableGamblingWinnings`

Observed state:
- `reportableGamblingWinningsPaid = TRUE`
- `formW2GFiled = FALSE`

Expected invariant:
- `reportableGamblingWinningsPaid => formW2GFiled`

Meaning:
- the model lets reportable gambling winnings be paid without filing Form W-2G
- this is the Form W-2G gap: IRS guidance says Form W-2G reports gambling winnings and any federal income tax withheld on those winnings, but the state machine allows the reportable payment state without the return state

### 327. Form 1099-NEC nonemployee compensation reporting failure

Model: `work/TaxForm1099NECNonemployeeCompensationGap.tla`

Trace:
1. initial state
2. `PayNonemployeeCompensation`

Observed state:
- `nonemployeeCompensationPaid = TRUE`
- `form1099NECFiled = FALSE`

Expected invariant:
- `nonemployeeCompensationPaid => form1099NECFiled`

Meaning:
- the model lets nonemployee compensation be paid without filing Form 1099-NEC
- this is the Form 1099-NEC gap: IRS guidance says Form 1099-NEC is used to report nonemployee compensation, but the state machine allows the payment state without the return state

### 328. Form 1099-K reportable payment transaction reporting failure

Model: `work/TaxForm1099KReportablePaymentGap.tla`

Trace:
1. initial state
2. `SettleReportablePaymentTransaction`

Observed state:
- `reportablePaymentTransactionSettled = TRUE`
- `form1099KFiled = FALSE`

Expected invariant:
- `reportablePaymentTransactionSettled => form1099KFiled`

Meaning:
- the model lets a reportable payment transaction be settled without filing Form 1099-K
- this is the Form 1099-K gap: IRS guidance says payment settlement entities must file Form 1099-K for reportable payment transactions, but the state machine allows the settlement state without the return state

### 329. Form 1099-OID original issue discount reporting failure

Model: `work/TaxForm1099OIDOriginalIssueDiscountGap.tla`

Trace:
1. initial state
2. `AccrueOriginalIssueDiscount`

Observed state:
- `originalIssueDiscountIncludible = TRUE`
- `form1099OIDFiled = FALSE`

Expected invariant:
- `originalIssueDiscountIncludible => form1099OIDFiled`

Meaning:
- the model lets original issue discount accrue without filing Form 1099-OID
- this is the Form 1099-OID gap: IRS guidance says Form 1099-OID is filed when original issue discount is at least $10 or otherwise reportable, but the state machine allows the income state without the return state

### 330. Form 1099-INT interest income reporting failure

Model: `work/TaxForm1099INTInterestIncomeGap.tla`

Trace:
1. initial state
2. `PayReportableInterest`

Observed state:
- `reportableInterestPaid = TRUE`
- `form1099INTFiled = FALSE`

Expected invariant:
- `reportableInterestPaid => form1099INTFiled`

Meaning:
- the model lets reportable interest be paid without filing Form 1099-INT
- this is the Form 1099-INT gap: IRS guidance says Form 1099-INT reports interest income, but the state machine allows the reportable interest state without the form state

### 331. Form 1099-B broker sale reporting failure

Model: `work/TaxForm1099BBrokerSaleGap.tla`

Trace:
1. initial state
2. `SellReportableSecurity`

Observed state:
- `reportableBrokerSale = TRUE`
- `form1099BFiled = FALSE`

Expected invariant:
- `reportableBrokerSale => form1099BFiled`

Meaning:
- the model lets a reportable broker sale occur without filing Form 1099-B
- this is the Form 1099-B gap: IRS guidance says brokers and barter exchanges must file Form 1099-B for reportable sales and exchanges, but the state machine allows the sale state without the return state

### 332. Form 1099-S real estate transaction reporting failure

Model: `work/TaxForm1099SBrokerRealEstateGap.tla`

Trace:
1. initial state
2. `SellReportableRealEstate`

Observed state:
- `reportableRealEstateSale = TRUE`
- `form1099SFiled = FALSE`

Expected invariant:
- `reportableRealEstateSale => form1099SFiled`

Meaning:
- the model lets a reportable real-estate sale occur without filing Form 1099-S
- this is the Form 1099-S gap: IRS guidance says Form 1099-S reports the sale or exchange of real estate, but the state machine allows the reportable sale state without the return state

### 333. Form 1099-C canceled debt reporting failure

Model: `work/TaxForm1099CCanceledDebtGap.tla`

Trace:
1. initial state
2. `CancelDebt`

Observed state:
- `debtCanceled = TRUE`
- `form1099CFiled = FALSE`

Expected invariant:
- `debtCanceled => form1099CFiled`

Meaning:
- the model lets canceled debt exist without filing Form 1099-C
- this is the Form 1099-C gap: IRS guidance says creditors must file Form 1099-C for reportable canceled debt, but the state machine allows the cancellation state without the return state

### 334. Form 1099-A secured property reporting failure

Model: `work/TaxForm1099ASecuredPropertyGap.tla`

Trace:
1. initial state
2. `AcquireOrAbandonSecuredProperty`

Observed state:
- `securedPropertyAcquiredOrAbandoned = TRUE`
- `form1099AFiled = FALSE`

Expected invariant:
- `securedPropertyAcquiredOrAbandoned => form1099AFiled`

Meaning:
- the model lets secured property acquisition or abandonment occur without filing Form 1099-A
- this is the Form 1099-A gap: IRS guidance says lenders file Form 1099-A for acquisition or abandonment of secured property, but the state machine allows the triggering event state without the return state

### 335. Form 1099-LTC long-term care benefits reporting failure

Model: `work/TaxForm1099LTCLongTermCareGap.tla`

Trace:
1. initial state
2. `PayLongTermCareBenefits`

Observed state:
- `longTermCareBenefitsPaid = TRUE`
- `form1099LTCFiled = FALSE`

Expected invariant:
- `longTermCareBenefitsPaid => form1099LTCFiled`

Meaning:
- the model lets long-term care benefits be paid without filing Form 1099-LTC
- this is the Form 1099-LTC gap: IRS guidance says Form 1099-LTC reports long-term care and accelerated death benefits, but the state machine allows the payment state without the return state

### 336. Form 1098-F fines and penalties reporting failure

Model: `work/TaxForm1098FGovernmentPenaltyGap.tla`

Trace:
1. initial state
2. `ReceiveReportableAgreement`

Observed state:
- `reportableAgreementAmount = 50000`
- `form1098FFiled = FALSE`

Expected invariant:
- `reportableAgreementAmount >= 50000 => form1098FFiled`

Meaning:
- the model lets a reportable government agreement amount reach the filing threshold without filing Form 1098-F
- this is the Form 1098-F gap: IRS guidance says certain government and nongovernmental entities must file Form 1098-F for qualifying suits, orders, and agreements, but the state machine allows the threshold state without the return state

### 337. Form 1098-Q qualifying longevity annuity contract reporting failure

Related model: `work/TaxForm1098QQLACGap.tla`

Trace:
1. initial state
2. `IssueQLAC`

Observed state:
- `contractIntendedToBeQLAC = TRUE`
- `form1098QFiled = FALSE`

Expected invariant:
- `contractIntendedToBeQLAC => form1098QFiled`

Meaning:
- the model lets a qualifying longevity annuity contract be issued without filing Form 1098-Q
- this is the Form 1098-Q gap: IRS guidance says issuers file Form 1098-Q for contracts intended to be QLACs, but the state machine allows the contract state without the return state

### 338. Form 1099-H advance health coverage tax credit reporting failure

Model: `work/TaxForm1099HAdvancePaymentsGap.tla`

Trace:
1. initial state
2. `ReceiveAdvanceHealthCoveragePayments`

Observed state:
- `advanceHealthCoveragePaymentsReceived = TRUE`
- `form1099HFiled = FALSE`

Expected invariant:
- `advanceHealthCoveragePaymentsReceived => form1099HFiled`

Meaning:
- the model lets advance health coverage tax credit payments be received without filing Form 1099-H
- this is the Form 1099-H gap: IRS guidance says Form 1099-H reports advance payments of qualified health insurance premiums for eligible recipients, but the state machine allows the payment state without the return state

### 339. Form 1099-LS reportable policy sale reporting failure

Model: `work/TaxForm1099LSReportablePolicySaleGap.tla`

Trace:
1. initial state
2. `AcquireInterestInLifeInsuranceContract`

Observed state:
- `reportablePolicySale = TRUE`
- `form1099LSFiled = FALSE`

Expected invariant:
- `reportablePolicySale => form1099LSFiled`

Meaning:
- the model lets a reportable policy sale occur without filing Form 1099-LS
- this is the Form 1099-LS gap: IRS guidance says acquirers file Form 1099-LS for reportable policy sales, but the state machine allows the sale state without the return state

### 340. Form 1099-PATR patronage dividend reporting failure

Model: `work/TaxForm1099PATRPatronageDistributionGap.tla`

Trace:
1. initial state
2. `PayPatronageDividends`

Observed state:
- `patronageDividendsPaid = 10`
- `form1099PATRFiled = FALSE`

Expected invariant:
- `patronageDividendsPaid >= 10 => form1099PATRFiled`

Meaning:
- the model lets patronage dividends reach the reporting threshold without filing Form 1099-PATR
- this is the Form 1099-PATR gap: IRS guidance says cooperatives file Form 1099-PATR for patronage dividends of at least $10, but the state machine allows the threshold state without the return state

### 341. Form 1099-SB issuer statement reporting failure

Model: `work/TaxForm1099SBIssuerStatementGap.tla`

Trace:
1. initial state
2. `ReceiveAcquirerStatement`

Observed state:
- `acquirerStatementReceived = TRUE`
- `form1099SBFiled = FALSE`

Expected invariant:
- `acquirerStatementReceived => form1099SBFiled`

Meaning:
- the model lets an issuer receive the acquirer statement in a reportable policy sale without filing Form 1099-SB
- this is the Form 1099-SB gap: IRS guidance says the issuer of a life insurance contract must file Form 1099-SB when it receives the statement or notice that triggers the reporting duty, but the state machine allows the trigger state without the return state

### 342. Form 1099-G unemployment compensation reporting failure

Model: `work/TaxForm1099GUnemploymentGap.tla`

Trace:
1. initial state
2. `PayUnemploymentCompensation`

Observed state:
- `unemploymentCompensationPaid = TRUE`
- `form1099GFiled = FALSE`

Expected invariant:
- `unemploymentCompensationPaid => form1099GFiled`

Meaning:
- the model lets unemployment compensation be paid without filing Form 1099-G
- this is the Form 1099-G gap: IRS guidance says governments file Form 1099-G for unemployment compensation and certain other government payments, but the state machine allows the unemployment-payment state without the return state

### 343. Form 1099-Q qualified education program distribution reporting failure

Model: `work/TaxForm1099QQualifiedEducationDistributionGap.tla`

Trace:
1. initial state
2. `MakeQualifiedEducationDistribution`

Observed state:
- `qualifiedEducationDistributionMade = TRUE`
- `form1099QFiled = FALSE`

Expected invariant:
- `qualifiedEducationDistributionMade => form1099QFiled`

Meaning:
- the model lets a qualified education program distribution occur without filing Form 1099-Q
- this is the Form 1099-Q gap: IRS guidance says trustees and program officers file Form 1099-Q for qualified education program distributions, but the state machine allows the distribution state without the return state

### 344. Form 1099-QA ABLE account distribution reporting failure

Model: `work/TaxForm1099QAABLEDistributionGap.tla`

Trace:
1. initial state
2. `MakeABLEDistribution`

Observed state:
- `ableDistributionMade = TRUE`
- `form1099QAFiled = FALSE`

Expected invariant:
- `ableDistributionMade => form1099QAFiled`

Meaning:
- the model lets an ABLE account distribution occur without filing Form 1099-QA
- this is the Form 1099-QA gap: IRS guidance says qualified ABLE programs file Form 1099-QA for distributions from ABLE accounts, but the state machine allows the distribution state without the return state

### 345. Form 1099-CAP corporate control change reporting failure

Model: `work/TaxForm1099CAPControlChangeGap.tla`

Trace:
1. initial state
2. `AcquisitionOfControl`

Observed state:
- `corporationHadControlChange = TRUE`
- `form1099CAPFiled = FALSE`

Expected invariant:
- `corporationHadControlChange => form1099CAPFiled`

Meaning:
- the model lets a corporation undergo a control change without filing Form 1099-CAP
- this is the Form 1099-CAP gap: IRS guidance says corporations file Form 1099-CAP for acquisitions of control or substantial changes in capital structure, but the state machine allows the control-change state without the return state

### 346. Form 5498-QA ABLE account contribution reporting failure

Model: `work/TaxForm5498QABLEContributionGap.tla`

Trace:
1. initial state
2. `MakeABLEContribution`

Observed state:
- `ableContributionMade = TRUE`
- `form5498QAFiled = FALSE`

Expected invariant:
- `ableContributionMade => form5498QAFiled`

Meaning:
- the model lets an ABLE account contribution occur without filing Form 5498-QA
- this is the Form 5498-QA gap: IRS guidance says qualified ABLE programs file Form 5498-QA for ABLE account contributions and rollovers, but the state machine allows the contribution state without the annual information return state

### 347. Form 8806 acquisition of control reporting failure

Model: `work/TaxForm8806ControlChangeGap.tla`

Trace:
1. initial state
2. `AcquisitionOfControlOrCapitalStructureChange`

Observed state:
- `corporationHadControlChange = TRUE`
- `form8806Filed = FALSE`

Expected invariant:
- `corporationHadControlChange => form8806Filed`

Meaning:
- the model lets a corporation undergo an acquisition of control or capital-structure change without filing Form 8806
- this is the Form 8806 gap: IRS guidance says a reporting corporation files Form 8806 for acquisitions of control or substantial changes in capital structure, but the state machine allows the corporate-change state without the reporting form state

### 348. Form 1097-BTC tax credit bond reporting failure

Model: `work/TaxForm1097BTCTaxCreditBondGap.tla`

Trace:
1. initial state
2. `DistributeTaxCredit`

Observed state:
- `taxCreditDistributed = TRUE`
- `form1097BTCFiled = FALSE`

Expected invariant:
- `taxCreditDistributed => form1097BTCFiled`

Meaning:
- the model lets a tax credit be distributed from a tax credit bond without filing Form 1097-BTC
- this is the Form 1097-BTC gap: IRS guidance says issuers and certain recipients must file Form 1097-BTC for each tax credit distributed, but the state machine allows the distribution state without the annual information return state

### 349. Form 1098-VLI vehicle loan interest reporting failure

Model: `work/TaxForm1098VLIVehicleLoanInterestGap.tla`

Trace:
1. initial state
2. `ReceiveVehicleLoanInterest`

Observed state:
- `specifiedPassengerVehicleLoanInterestReceived = 600`
- `form1098VLIFiled = FALSE`

Expected invariant:
- `specifiedPassengerVehicleLoanInterestReceived >= 600 => form1098VLIFiled`

Meaning:
- the model lets specified passenger vehicle loan interest reach the reporting threshold without filing Form 1098-VLI
- this is the Form 1098-VLI gap: IRS guidance says lenders report interest of $600 or more on specified passenger vehicle loans, but the state machine allows the threshold state without the information return state

### 350. Form 1099-SA HSA distribution reporting failure

Model: `work/TaxForm1099SAHsaDistributionGap.tla`

Trace:
1. initial state
2. `MakeHsaDistribution`

Observed state:
- `hsaDistributionMade = TRUE`
- `form1099SAFiled = FALSE`

Expected invariant:
- `hsaDistributionMade => form1099SAFiled`

Meaning:
- the model lets an HSA distribution occur without filing Form 1099-SA
- this is the Form 1099-SA gap: IRS guidance says payers file Form 1099-SA for distributions from HSAs, Archer MSAs, and MA MSAs, but the state machine allows the distribution state without the return state

### 351. Form 7206 self-employed health insurance deduction failure

Model: `work/TaxForm7206SelfEmployedHealthInsuranceGap.tla`

Trace:
1. initial state
2. `BecomeEligibleForSelfEmployedDeduction`

Observed state:
- `selfEmployedHealthInsuranceDeductionEligible = TRUE`
- `form7206Filed = FALSE`

Expected invariant:
- `selfEmployedHealthInsuranceDeductionEligible => form7206Filed`

Meaning:
- the model lets a taxpayer become eligible for the self-employed health insurance deduction without filing Form 7206
- this is the Form 7206 gap: IRS instructions say Form 7206 is used to determine the self-employed health insurance deduction, but the state machine allows the deduction-eligibility state without the form-filing state

### 352. Form 941 quarterly payroll tax reporting failure

Model: `work/TaxForm941QuarterlyPayrollGap.tla`

Trace:
1. initial state
2. `PayWagesSubjectToWithholding`

Observed state:
- `wagesSubjectToWithholdingPaid = TRUE`
- `form941Filed = FALSE`

Expected invariant:
- `wagesSubjectToWithholdingPaid => form941Filed`

Meaning:
- the model lets wages subject to withholding be paid without filing Form 941
- this is the Form 941 gap: IRS guidance says employers use Form 941 to report wages subject to federal income tax withholding and the employer and employee portions of social security and Medicare taxes, but the state machine allows the wage-payment state without the quarterly return state

### 352.1. Form 940 FUTA filing deadline failure

Model: `work/TaxForm940FUTATimingGap.tla`

Trace:
1. initial state
2. `TaxAccrues`
3. `AdvanceDay` repeated until day 31

Observed state:
- `futaTaxDue = 501`
- `currentDay = 31`
- `form940Filed = FALSE`

Expected invariant:
- `futaTaxDue > DepositThreshold /\ currentDay >= DueDay => form940Filed`

Meaning:
- the model lets FUTA liability above the deposit threshold persist past the Form 940 deadline without filing the annual return
- this is the Form 940 timing gap: IRS guidance says Form 940 reports annual FUTA tax and is generally due by the end of January or early February depending on deposits, but the state machine allows the liability state to exist without the timely filing state

### 353. Form 945 nonpayroll withholding reporting failure

Model: `work/TaxForm945NonpayrollWithholdingGap.tla`

Trace:
1. initial state
2. `WithholdFromNonpayrollPayment`

Observed state:
- `nonpayrollWithholdingMade = TRUE`
- `form945Filed = FALSE`

Expected invariant:
- `nonpayrollWithholdingMade => form945Filed`

Meaning:
- the model lets federal income tax be withheld from nonpayroll payments without filing Form 945
- this is the Form 945 gap: IRS guidance says Form 945 reports withheld federal income tax from nonpayroll payments, but the state machine allows the withholding state without the annual return state

### 354. Form 944 annual payroll tax reporting failure

Model: `work/TaxForm944AnnualPayrollGap.tla`

Trace:
1. initial state
2. `DesignateForAnnualPayrollReturn`

Observed state:
- `smallEmployerDesignatedFor944 = TRUE`
- `form944Filed = FALSE`

Expected invariant:
- `smallEmployerDesignatedFor944 => form944Filed`

Meaning:
- the model lets a small employer be designated for annual payroll reporting without filing Form 944
- this is the Form 944 gap: IRS guidance says Form 944 is the annual federal tax return for the smallest employers when the IRS notifies them to file it, but the state machine allows the designated-employer state without the annual return state

### 355. Form 8508 electronic-filing waiver failure

Model: `work/TaxForm8508EFileWaiverGap.tla`

Trace:
1. initial state
2. `BecomeRequiredToEfile`

Observed state:
- `electronicFilingRequired = TRUE`
- `form8508Filed = FALSE`

Expected invariant:
- `electronicFilingRequired => form8508Filed`

Meaning:
- the model lets a filer become subject to an electronic-filing requirement without filing Form 8508 to request a waiver
- this is the Form 8508 gap: IRS guidance says Form 8508 is used to request a waiver from electronic filing of information returns, but the state machine allows the e-file-required state without the waiver-request state

### 356. Form 8809 information-return extension failure

Model: `work/TaxForm8809InformationReturnExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTime`

Observed state:
- `moreTimeNeededToFileInformationReturns = TRUE`
- `form8809Filed = FALSE`

Expected invariant:
- `moreTimeNeededToFileInformationReturns => form8809Filed`

Meaning:
- the model lets a filer need more time to file information returns without filing Form 8809
- this is the Form 8809 gap: IRS guidance says Form 8809 is used to request an extension of time to file information returns, but the state machine allows the extension-needed state without the waiver-request state

### 357. Form 15397 recipient-statement extension failure

Model: `work/TaxForm15397RecipientStatementExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFurnishStatements`

Observed state:
- `moreTimeNeededToFurnishRecipientStatements = TRUE`
- `form15397Filed = FALSE`

Expected invariant:
- `moreTimeNeededToFurnishRecipientStatements => form15397Filed`

Meaning:
- the model lets a filer need more time to furnish recipient statements without filing Form 15397
- this is the Form 15397 gap: IRS guidance says Form 15397 is used to request an extension of time to furnish recipient statements, but the state machine allows the extension-needed state without the request form state

### 358. Form 8966 FATCA report failure

Model: `work/TaxForm8966FATCAReportGap.tla`

Trace:
1. initial state
2. `CreateReportableFATCARecord`

Observed state:
- `reportableFATCARecordExists = TRUE`
- `form8966Filed = FALSE`

Expected invariant:
- `reportableFATCARecordExists => form8966Filed`

Meaning:
- the model lets a reportable FATCA record exist without filing Form 8966
- this is the Form 8966 gap: IRS guidance says Form 8966 is filed to report certain U.S. accounts and other FATCA-reportable information, but the state machine allows the reportable-record state without the FATCA report state

### 359. Form 8971 estate basis reporting failure

Model: `work/TaxForm8971EstateBasisReportGap.tla`

Trace:
1. initial state
2. `FileEstateTaxReturnAfterJuly2015`

Observed state:
- `estateTaxReturnFiledAfterJuly2015 = TRUE`
- `form8971Filed = FALSE`

Expected invariant:
- `estateTaxReturnFiledAfterJuly2015 => form8971Filed`

Meaning:
- the model lets an estate file a post-July-2015 estate tax return without filing Form 8971
- this is the Form 8971 gap: IRS guidance says executors file Form 8971 to report the estate-tax basis information for property passing to beneficiaries when the estate tax return is filed after July 2015, but the state machine allows the estate-return state without the basis-reporting form state

### 360. Form 8975 country-by-country reporting failure

Model: `work/TaxForm8975CountryByCountryGap.tla`

Trace:
1. initial state
2. `CreateReportingUMNEGroup`

Observed state:
- `reportingUMNEGroupExists = TRUE`
- `form8975Filed = FALSE`

Expected invariant:
- `reportingUMNEGroupExists => form8975Filed`

Meaning:
- the model lets a reporting U.S. multinational enterprise group exist without filing Form 8975
- this is the Form 8975 gap: IRS guidance says the ultimate parent entity of a U.S. MNE group files Form 8975 Country-by-Country Report with its income tax return, but the state machine allows the reporting-group state without the country-by-country report state

### 361. Form 8974 payroll credit failure

Model: `work/TaxForm8974PayrollCreditGap.tla`

Trace:
1. initial state
2. `MakePayrollResearchCreditElection`

Observed state:
- `payrollResearchCreditElectionMade = TRUE`
- `form8974Filed = FALSE`

Expected invariant:
- `payrollResearchCreditElectionMade => form8974Filed`

Meaning:
- the model lets a taxpayer make the research-credit election without filing Form 8974
- this is the Form 8974 gap: IRS guidance says the payroll tax credit election flows through Form 6765 and Form 8974 must be attached to the employment tax return to claim the credit, but the state machine allows the election state without the filing state

### 362. Form 1098-Q qualifying longevity annuity contract reporting failure

Model: `work/TaxForm1098QQLACGap.tla`

Trace:
1. initial state
2. `IssueQLAC`

Observed state:
- `contractIntendedToBeQLAC = TRUE`
- `form1098QFiled = FALSE`

Expected invariant:
- `contractIntendedToBeQLAC => form1098QFiled`

Meaning:
- the model lets a contract intended to be a QLAC exist without filing Form 1098-Q
- this is the Form 1098-Q gap: IRS guidance says issuers file Form 1098-Q for contracts intended to be qualifying longevity annuity contracts, but the state machine allows the QLAC-intent state without the information-return state

### 363. Form 1098-MA mortgage assistance reporting failure

Model: `work/TaxForm1098MAMortgageAssistanceGap.tla`

Trace:
1. initial state
2. `MakeMortgageAssistancePayment`

Observed state:
- `stateHFAMortgageAssistancePaymentMade = TRUE`
- `form1098MAFiled = FALSE`

Expected invariant:
- `stateHFAMortgageAssistancePaymentMade => form1098MAFiled`

Meaning:
- the model lets a state HFA make mortgage assistance payments without filing Form 1098-MA
- this is the Form 1098-MA gap: IRS guidance says state housing finance agencies use Form 1098-MA to report mortgage assistance payments, but the state machine allows the payment state without the information-return state

### 364. Form 7208 stock repurchase excise failure

Model: `work/TaxForm7208StockRepurchaseGap.tla`

Trace:
1. initial state
2. `RepurchaseStock`

Observed state:
- `stockRepurchased = TRUE`
- `form7208Attached = FALSE`

Expected invariant:
- `stockRepurchased => form7208Attached`

Meaning:
- the model lets a corporation repurchase stock without attaching Form 7208
- this is the Form 7208 gap: IRS guidance says covered corporations use Form 7208 to figure the stock repurchase excise tax and attach it to Form 720, but the state machine allows the repurchase state without the attached computation form

### 365. Form 8876 structured settlement factoring failure

Model: `work/TaxForm8876StructuredSettlementGap.tla`

Trace:
1. initial state
2. `ReceiveStructuredSettlementPaymentRights`

Observed state:
- `structuredSettlementPaymentRightsReceived = TRUE`
- `form8876Filed = FALSE`

Expected invariant:
- `structuredSettlementPaymentRightsReceived => form8876Filed`

Meaning:
- the model lets a structured settlement factoring transaction happen without filing Form 8876
- this is the Form 8876 gap: IRS guidance says parties use Form 8876 to report and pay the excise tax on structured settlement factoring transactions, but the state machine allows the rights-received state without the excise-return state

### 366. Form 8875 taxable REIT subsidiary election failure

Model: `work/TaxForm8875TRSElectionGap.tla`

Trace:
1. initial state
2. `MakeTRSElection`

Observed state:
- `reitAndCorporationWantTRS = TRUE`
- `form8875Filed = FALSE`

Expected invariant:
- `reitAndCorporationWantTRS => form8875Filed`

Meaning:
- the model lets a REIT and corporation make a taxable REIT subsidiary election without filing Form 8875
- this is the Form 8875 gap: IRS guidance says the corporation and REIT jointly elect TRS treatment on Form 8875, but the state machine allows the election state without the filing state

### 367. Form 8831 REMIC residual interest reporting failure

Model: `work/TaxForm8831REMICResidualInterestGap.tla`

Trace:
1. initial state
2. `TransferResidualInterest`

Observed state:
- `residualInterestTransferredToDisqualifiedOrganization = TRUE`
- `form8831Filed = FALSE`

Expected invariant:
- `residualInterestTransferredToDisqualifiedOrganization => form8831Filed`

Meaning:
- the model lets a REMIC residual interest be transferred to a disqualified organization without filing Form 8831
- this is the Form 8831 gap: IRS guidance says Form 8831 reports and pays excise tax on certain REMIC residual-interest transfers and related pass-through entity situations, but the state machine allows the transfer state without the excise-return state

### 368. Form 8027-T transmittal failure

Model: `work/TaxForm8027TTransmittalGap.tla`

Trace:
1. initial state
2. `RequireMultipleEstablishmentReporting`

Observed state:
- `moreThanOneEstablishmentRequiresForm8027 = TRUE`
- `form8027TFiled = FALSE`

Expected invariant:
- `moreThanOneEstablishmentRequiresForm8027 => form8027TFiled`

Meaning:
- the model lets a multiple-establishment 8027 reporting obligation arise without filing Form 8027-T
- this is the Form 8027-T gap: IRS guidance uses Form 8027-T to transmit multiple Forms 8027, but the state machine allows the multi-establishment reporting trigger without the transmittal form

### 369. Form 8874 New Markets Credit failure

Model: `work/TaxForm8874NewMarketsCreditGap.tla`

Trace:
1. initial state
2. `MakeQualifiedEquityInvestment`

Observed state:
- `qualifiedEquityInvestmentMade = TRUE`
- `form8874Filed = FALSE`

Expected invariant:
- `qualifiedEquityInvestmentMade => form8874Filed`

Meaning:
- the model lets a qualified equity investment in a CDE occur without filing Form 8874
- this is the Form 8874 gap: IRS guidance says Form 8874 is used to claim the New Markets Credit for qualified equity investments made in qualified community development entities, but the state machine allows the investment state without the credit-claim form

### 370. Form 8912 tax credit bond credit failure

Model: `work/TaxForm8912TaxCreditBondCreditGap.tla`

Trace:
1. initial state
2. `EntitleTaxCreditBondCredit`

Observed state:
- `taxCreditBondCreditEntitled = TRUE`
- `form8912Filed = FALSE`

Expected invariant:
- `taxCreditBondCreditEntitled => form8912Filed`

Meaning:
- the model lets a taxpayer become entitled to a tax credit bond credit without filing Form 8912
- this is the Form 8912 gap: IRS guidance says Form 8912 is used to claim the credit for tax credit bonds, but the state machine allows the entitlement state without the credit-claim form

### 371. Form 8902 qualifying shipping activities failure

Model: `work/TaxForm8902QualifyingShippingGap.tla`

Trace:
1. initial state
2. `MakeAlternativeTaxElection`

Observed state:
- `qualifyingVesselOperatorMadeElection = TRUE`
- `form8902Filed = FALSE`

Expected invariant:
- `qualifyingVesselOperatorMadeElection => form8902Filed`

Meaning:
- the model lets a qualifying vessel operator make the alternative-tax election without filing Form 8902
- this is the Form 8902 gap: IRS guidance says qualifying vessel operators file Form 8902 to make and compute the alternative tax election, but the state machine allows the election state without the form state

### 372. Form 8874-A New Markets Credit notice failure

Model: `work/TaxForm8874ANewMarketsNoticeGap.tla`

Trace:
1. initial state
2. `MakeQualifiedEquityInvestment`

Observed state:
- `qualifiedEquityInvestmentMade = TRUE`
- `form8874AFiled = FALSE`

Expected invariant:
- `qualifiedEquityInvestmentMade => form8874AFiled`

Meaning:
- the model lets a qualified equity investment occur without filing Form 8874-A
- this is the Form 8874-A gap: IRS guidance says Form 8874-A is the notice of qualified equity investment for New Markets Credit, but the state machine allows the investment state without the notice state

### 373. Form 8874-B New Markets Credit recapture notice failure

Model: `work/TaxForm8874BRecaptureNoticeGap.tla`

Trace:
1. initial state
2. `TriggerRecaptureEvent`

Observed state:
- `recaptureEventOccurred = TRUE`
- `form8874BFiled = FALSE`

Expected invariant:
- `recaptureEventOccurred => form8874BFiled`

Meaning:
- the model lets a New Markets Credit recapture event occur without filing Form 8874-B
- this is the Form 8874-B gap: IRS guidance says Form 8874-B notifies the IRS of a recapture event for New Markets Credit, but the state machine allows the recapture-event state without the notice state

### 374. Form 8879-CORP corporate e-file authorization failure

Model: `work/TaxForm8879CORPSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareCorporateEFile`

Observed state:
- `corporateOfficerWantsToEFile = TRUE`
- `form8879CorpFiled = FALSE`

Expected invariant:
- `corporateOfficerWantsToEFile => form8879CorpFiled`

Meaning:
- the model lets a corporation prepare to e-file without filing Form 8879-CORP
- this is the Form 8879-CORP gap: IRS guidance says corporate officers and EROs use Form 8879-CORP to authorize electronic signature for corporate e-file returns, but the state machine allows the e-file state without the authorization form

### 375. Form 8453-CORP corporate e-file declaration failure

Model: `work/TaxForm8453CORPDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareCorporateEFile`

Observed state:
- `corporateEFilePrepared = TRUE`
- `form8453CorpFiled = FALSE`

Expected invariant:
- `corporateEFilePrepared => form8453CorpFiled`

Meaning:
- the model lets a corporation prepare an electronic return without filing Form 8453-CORP
- this is the Form 8453-CORP gap: IRS guidance says Form 8453-CORP is used to authenticate corporation e-file returns, but the state machine allows the prepared-e-file state without the declaration form

### 376. Form 8834 qualified electric vehicle credit failure

Model: `work/TaxForm8834QualifiedElectricVehicleCreditGap.tla`

Trace:
1. initial state
2. `AllowQualifiedElectricVehicleCredit`

Observed state:
- `qualifiedElectricVehicleCreditAllowed = TRUE`
- `form8834Filed = FALSE`

Expected invariant:
- `qualifiedElectricVehicleCreditAllowed => form8834Filed`

Meaning:
- the model lets a qualified electric vehicle credit become available without filing Form 8834
- this is the Form 8834 gap: IRS guidance says Form 8834 is used to claim the qualified electric vehicle credit, but the state machine allows the credit-allowed state without the return state

### 377. Form 8878 e-file signature authorization failure

Model: `work/TaxForm8878EfileSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `AuthorizeExtensionFormEfileSignature`

Observed state:
- `extensionFormElectronicSignatureAuthorized = TRUE`
- `form8878Filed = FALSE`

Expected invariant:
- `extensionFormElectronicSignatureAuthorized => form8878Filed`

Meaning:
- the model lets a taxpayer authorize e-file signature for an extension form without filing Form 8878
- this is the Form 8878 gap: IRS guidance says Form 8878 is used when a taxpayer authorizes the ERO to sign Form 4868 or Form 2350 electronically, but the state machine allows the authorization state without the authorization form

### 378. Form 8878-A electronic funds withdrawal authorization failure

Model: `work/TaxForm8878AElectronicFundsWithdrawalGap.tla`

Trace:
1. initial state
2. `AuthorizeExtensionFormEfw`

Observed state:
- `extensionFormElectronicFundsWithdrawalAuthorized = TRUE`
- `form8878AFiled = FALSE`

Expected invariant:
- `extensionFormElectronicFundsWithdrawalAuthorized => form8878AFiled`

Meaning:
- the model lets a taxpayer authorize electronic funds withdrawal for an extension form without filing Form 8878-A
- this is the Form 8878-A gap: IRS guidance says Form 8878-A authorizes electronic funds withdrawal for Form 7004, but the state machine allows the authorization state without the authorization form

### 379. Form 8879-TE tax-exempt entity e-file authorization failure

Model: `work/TaxForm8879TESignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareTaxExemptEntityEFile`

Observed state:
- `taxExemptEntityWantsToEFile = TRUE`
- `form8879TEFiled = FALSE`

Expected invariant:
- `taxExemptEntityWantsToEFile => form8879TEFiled`

Meaning:
- the model lets a tax-exempt entity prepare to e-file without filing Form 8879-TE
- this is the Form 8879-TE gap: IRS guidance says Form 8879-TE authorizes e-file signature for a tax-exempt entity, but the state machine allows the e-file state without the authorization form

### 380. Form 8935-T airline payments transmittal failure

Model: `work/TaxForm8935TAirlinePaymentsTransmittalGap.tla`

Trace:
1. initial state
2. `MakeAirlinePaymentReportRequired`

Observed state:
- `airlinePaymentReportRequired = TRUE`
- `form8935TFiled = FALSE`

Expected invariant:
- `airlinePaymentReportRequired => form8935TFiled`

Meaning:
- the model lets an airline payment report obligation arise without filing Form 8935-T
- this is the Form 8935-T gap: IRS guidance says Form 8935-T transmits paper Forms 8935 airline payment reports, but the state machine allows the reporting trigger without the transmittal form

### 381. Form 8879-PE partnership e-file authorization failure

Model: `work/TaxForm8879PESignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PreparePartnershipEFile`

Observed state:
- `partnershipWantsToEFile = TRUE`
- `form8879PEFiled = FALSE`

Expected invariant:
- `partnershipWantsToEFile => form8879PEFiled`

Meaning:
- the model lets a partnership prepare to e-file without filing Form 8879-PE
- this is the Form 8879-PE gap: IRS guidance says Form 8879-PE authorizes e-file signature for Form 1065, but the state machine allows the e-file state without the authorization form

### 382. Form 8879-F estate or trust e-file authorization failure

Model: `work/TaxForm8879FSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareEstateOrTrustEFile`

Observed state:
- `estateOrTrustWantsToEFile = TRUE`
- `form8879FFiled = FALSE`

Expected invariant:
- `estateOrTrustWantsToEFile => form8879FFiled`

Meaning:
- the model lets an estate or trust prepare to e-file without filing Form 8879-F
- this is the Form 8879-F gap: IRS guidance says Form 8879-F authorizes e-file signature for Form 1041, but the state machine allows the e-file state without the authorization form

### 383. Form 8453-EMP employment tax declaration failure

Model: `work/TaxForm8453EMPDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareEmploymentTaxReturn`

Observed state:
- `employmentTaxReturnPrepared = TRUE`
- `form8453EMPFiled = FALSE`

Expected invariant:
- `employmentTaxReturnPrepared => form8453EMPFiled`

Meaning:
- the model lets an employment tax return be prepared for e-file without filing Form 8453-EMP
- this is the Form 8453-EMP gap: IRS guidance says Form 8453-EMP is the declaration for employment tax e-file returns, but the state machine allows the prepared-return state without the declaration form

### 384. Form 8453-PE partnership declaration failure

Model: `work/TaxForm8453PEDeclarationGap.tla`

Trace:
1. initial state
2. `PreparePartnershipReturn`

Observed state:
- `partnershipReturnPrepared = TRUE`
- `form8453PEFiled = FALSE`

Expected invariant:
- `partnershipReturnPrepared => form8453PEFiled`

Meaning:
- the model lets a partnership prepare an e-file return without filing Form 8453-PE
- this is the Form 8453-PE gap: IRS guidance says Form 8453-PE is the declaration for a partnership e-file return, but the state machine allows the prepared-return state without the declaration form

### 385. Form 8453-FE estate or trust declaration failure

Model: `work/TaxForm8453FEDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareEstateOrTrustReturn`

Observed state:
- `estateOrTrustReturnPrepared = TRUE`
- `form8453FEFiled = FALSE`

Expected invariant:
- `estateOrTrustReturnPrepared => form8453FEFiled`

Meaning:
- the model lets an estate or trust prepare an e-file return without filing Form 8453-FE
- this is the Form 8453-FE gap: IRS guidance says Form 8453-FE is the declaration for an estate or trust e-file return, but the state machine allows the prepared-return state without the declaration form

### 386. Form 4547 Trump Account election failure

Model: `work/TaxForm4547TrumpAccountElectionGap.tla`

Trace:
1. initial state
2. `MakeTrumpAccountElection`

Observed state:
- `trumpAccountElectionMade = TRUE`
- `form4547Filed = FALSE`

Expected invariant:
- `trumpAccountElectionMade => form4547Filed`

Meaning:
- the model lets a Trump Account election be made without filing Form 4547
- this is the Form 4547 gap: IRS guidance says Form 4547 is used to open a Trump Account and elect a pilot program contribution, but the state machine allows the election state without the election form

### 387. Form 8879-TA Trump Account e-file authorization failure

Model: `work/TaxForm8879TATrumpAccountAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareTrumpAccountEfile`

Observed state:
- `trumpAccountElectionEfiled = TRUE`
- `form8879TAFiled = FALSE`

Expected invariant:
- `trumpAccountElectionEfiled => form8879TAFiled`

Meaning:
- the model lets a Trump Account election be prepared for e-file without filing Form 8879-TA
- this is the Form 8879-TA gap: IRS guidance says Form 8879-TA is the e-file signature authorization for Form 4547, but the state machine allows the e-file state without the authorization form

### 388. Form 8879-WH withholding e-file authorization failure

Model: `work/TaxForm8879WHWithholdingAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareWithholdingReturnEFile`

Observed state:
- `withholdingAgentWantsToEFile = TRUE`
- `form8879WHFiled = FALSE`

Expected invariant:
- `withholdingAgentWantsToEFile => form8879WHFiled`

Meaning:
- the model lets a withholding agent prepare to e-file without filing Form 8879-WH
- this is the Form 8879-WH gap: IRS guidance says Form 8879-WH authorizes e-file signature for Form 1042, but the state machine allows the e-file state without the authorization form

### 389. Form 8453-WH withholding declaration failure

Model: `work/TaxForm8453WHDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareWithholdingReturn`

Observed state:
- `withholdingReturnPrepared = TRUE`
- `form8453WHFiled = FALSE`

Expected invariant:
- `withholdingReturnPrepared => form8453WHFiled`

Meaning:
- the model lets a withholding return be prepared for e-file without filing Form 8453-WH
- this is the Form 8453-WH gap: IRS guidance says Form 8453-WH is the declaration for Form 1042 e-file returns, but the state machine allows the prepared-return state without the declaration form

### 390. Form 8879-S S corporation e-file authorization failure

Model: `work/TaxForm8879SSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareSCorporationEFile`

Observed state:
- `sCorporationWantsToEFile = TRUE`
- `form8879SFiled = FALSE`

Expected invariant:
- `sCorporationWantsToEFile => form8879SFiled`

Meaning:
- the model lets an S corporation prepare to e-file without filing Form 8879-S
- this is the Form 8879-S gap: IRS guidance says Form 8879-S is the e-file signature authorization for Form 1120-S, but the state machine allows the e-file state without the authorization form

### 391. Form 8453-S S corporation declaration failure

Model: `work/TaxForm8453SDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareSCorporationReturn`

Observed state:
- `sCorporationReturnPrepared = TRUE`
- `form8453SFiled = FALSE`

Expected invariant:
- `sCorporationReturnPrepared => form8453SFiled`

Meaning:
- the model lets an S corporation return be prepared for e-file without filing Form 8453-S
- this is the Form 8453-S gap: IRS guidance says Form 8453-S is the declaration for an IRS e-file return for Form 1120-S, but the state machine allows the prepared-return state without the declaration form

### 392. Form 8879-EG gift tax e-file authorization failure

Model: `work/TaxForm8879EGSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareGiftReturnEFile`

Observed state:
- `giftReturnWantsToEFile = TRUE`
- `form8879EGFiled = FALSE`

Expected invariant:
- `giftReturnWantsToEFile => form8879EGFiled`

Meaning:
- the model lets a gift tax return prepare to e-file without filing Form 8879-EG
- this is the Form 8879-EG gap: IRS guidance says Form 8879-EG is the e-file signature authorization for Forms 709 and 709-NA, but the state machine allows the e-file state without the authorization form

### 393. Form 8453-EG gift tax declaration failure

Model: `work/TaxForm8453EGDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareGiftReturn`

Observed state:
- `giftReturnPrepared = TRUE`
- `form8453EGFiled = FALSE`

Expected invariant:
- `giftReturnPrepared => form8453EGFiled`

Meaning:
- the model lets a gift tax return be prepared for e-file without filing Form 8453-EG
- this is the Form 8453-EG gap: IRS guidance says Form 8453-EG is the declaration for Forms 709 and 709-NA, but the state machine allows the prepared-return state without the declaration form

### 394. Form 8453-EX excise tax declaration failure

Model: `work/TaxForm8453EXDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareExciseReturn`

Observed state:
- `exciseReturnPrepared = TRUE`
- `form8453EXFiled = FALSE`

Expected invariant:
- `exciseReturnPrepared => form8453EXFiled`

Meaning:
- the model lets an excise tax return be prepared for e-file without filing Form 8453-EX
- this is the Form 8453-EX gap: IRS guidance says Form 8453-EX is the declaration for electronic excise tax returns, but the state machine allows the prepared-return state without the declaration form

### 395. Form 8453-X political organization declaration failure

Model: `work/TaxForm8453XDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareSection527Notice`

Observed state:
- `section527NoticePrepared = TRUE`
- `form8453XFiled = FALSE`

Expected invariant:
- `section527NoticePrepared => form8453XFiled`

Meaning:
- the model lets a section 527 notice be prepared for e-file without filing Form 8453-X
- this is the Form 8453-X gap: IRS guidance says Form 8453-X is the declaration for political organization e-filed notice filings, but the state machine allows the prepared-notice state without the declaration form

### 396. Form 8453-TR tentative refund declaration failure

Model: `work/TaxForm8453TRDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareTentativeRefundApplication`

Observed state:
- `tentativeRefundApplicationPrepared = TRUE`
- `form8453TRFiled = FALSE`

Expected invariant:
- `tentativeRefundApplicationPrepared => form8453TRFiled`

Meaning:
- the model lets a tentative refund application be prepared for e-file without filing Form 8453-TR
- this is the Form 8453-TR gap: IRS guidance says Form 8453-TR authenticates and authorizes electronic Forms 1045 and 1139, but the state machine allows the prepared-application state without the declaration form

### 397. Form 8879-B electing large partnership e-file authorization failure

Model: `work/TaxForm8879BSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareElectingLargePartnershipEFile`

Observed state:
- `electingLargePartnershipWantsToEFile = TRUE`
- `form8879BFiled = FALSE`

Expected invariant:
- `electingLargePartnershipWantsToEFile => form8879BFiled`

Meaning:
- the model lets an electing large partnership prepare to e-file without filing Form 8879-B
- this is the Form 8879-B gap: IRS guidance says Form 8879-B is the e-file signature authorization for Form 1065-B, but the state machine allows the e-file state without the authorization form

### 398. Form 8453-B electing large partnership declaration failure

Model: `work/TaxForm8453BDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareElectingLargePartnershipReturn`

Observed state:
- `electingLargePartnershipReturnPrepared = TRUE`
- `form8453BFiled = FALSE`

Expected invariant:
- `electingLargePartnershipReturnPrepared => form8453BFiled`

Meaning:
- the model lets an electing large partnership return be prepared for e-file without filing Form 8453-B
- this is the Form 8453-B gap: IRS guidance says Form 8453-B is the declaration for an electing large partnership e-file return, but the state machine allows the prepared-return state without the declaration form

### 399. Form 8879-EO exempt organization e-file authorization failure

Model: `work/TaxForm8879EOSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareExemptOrgEFile`

Observed state:
- `exemptOrgWantsToEFile = TRUE`
- `form8879EOFiled = FALSE`

Expected invariant:
- `exemptOrgWantsToEFile => form8879EOFiled`

Meaning:
- the model lets an exempt organization prepare to e-file without filing Form 8879-EO
- this is the Form 8879-EO gap: IRS guidance says Form 8879-EO is the e-file signature authorization for exempt organizations, but the state machine allows the e-file state without the authorization form

### 400. Form 8453-EO exempt organization declaration failure

Model: `work/TaxForm8453EODeclarationGap.tla`

Trace:
1. initial state
2. `PrepareExemptOrgReturn`

Observed state:
- `exemptOrgReturnPrepared = TRUE`
- `form8453EOFiled = FALSE`

Expected invariant:
- `exemptOrgReturnPrepared => form8453EOFiled`

Meaning:
- the model lets an exempt organization return be prepared for e-file without filing Form 8453-EO
- this is the Form 8453-EO gap: IRS guidance says Form 8453-EO is the declaration for exempt organization e-file returns, but the state machine allows the prepared-return state without the declaration form

### 401. Form 8879-EX excise tax authorization failure

Model: `work/TaxForm8879EXSignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareExciseReturnEFile`

Observed state:
- `exciseReturnWantsToEFile = TRUE`
- `form8879EXFiled = FALSE`

Expected invariant:
- `exciseReturnWantsToEFile => form8879EXFiled`

Meaning:
- the model lets an excise tax return prepare to e-file without filing Form 8879-EX
- this is the Form 8879-EX gap: IRS guidance says Form 8879-EX is the signature authorization for electronic excise tax returns, but the state machine allows the e-file state without the authorization form

### 402. Form 8879-I foreign corporation e-file authorization failure

Model: `work/TaxForm8879ISignatureAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareForeignCorpEFile`

Observed state:
- `foreignCorpWantsToEFile = TRUE`
- `form8879IFiled = FALSE`

Expected invariant:
- `foreignCorpWantsToEFile => form8879IFiled`

Meaning:
- the model lets a foreign corporation prepare to e-file without filing Form 8879-I
- this is the Form 8879-I gap: IRS guidance says Form 8879-I is the e-file signature authorization for Form 1120-F, but the state machine allows the e-file state without the authorization form

### 403. Form 8453-I foreign corporation declaration failure

Model: `work/TaxForm8453IDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareForeignCorpReturn`

Observed state:
- `foreignCorpReturnPrepared = TRUE`
- `form8453IFiled = FALSE`

Expected invariant:
- `foreignCorpReturnPrepared => form8453IFiled`

Meaning:
- the model lets a foreign corporation return be prepared for e-file without filing Form 8453-I
- this is the Form 8453-I gap: IRS guidance says Form 8453-I is the declaration for Form 1120-F e-file returns, but the state machine allows the prepared-return state without the declaration form

### 404. Three-party cum-ex-style dividend entitlement failure

Model: `work/TaxCumExThreePartyGap.tla`

Trace:
1. initial state
2. `TransferToB`
3. `DeclareDividend`
4. `TransferToC`
5. `PayDividend`
6. `ClaimCredit`

Observed state:
- `holder = "C"`
- `recordHolder = "B"`
- `beneficialOwner = "A"`
- `creditClaimed = TRUE`
- `creditedTo = "C"`

Expected invariant:
- `creditClaimed => creditedTo = recordHolder /\ recordHolder = beneficialOwner`

Meaning:
- the model lets the share move from A to B to C around the dividend event, while the record-date holder and beneficial owner remain different
- this is the explicit cum-ex-style gap: the entitlement chain is not forced to stay aligned with beneficial ownership, so the end holder can still claim the tax credit after the record-date position has been washed through intermediate hands

### 405. Partnership termination basis-reset failure

Model: `work/TaxPartnershipTerminationBasisResetGap.tla`

Trace:
1. initial state
2. `TerminatePartnership`
3. `BookDeemedDistribution`

Observed state:
- `partnershipTerminated = TRUE`
- `deemedDistributionOccurred = TRUE`
- `basisReset = FALSE`
- `partnerBasis = 100`

Expected invariant:
- `deemedDistributionOccurred => basisReset /\ partnerBasis = 0`

Meaning:
- the model lets the partnership termination be booked as a deemed distribution without forcing the basis reset that should follow
- this is the partnership termination basis-reset gap: the accounting consequence is separated from the termination consequence, so the state machine can record the deemed distribution while leaving the partner basis untouched

### 406. QI chain double-credit failure

Model: `work/TaxQIChainDoubleCreditGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `ClaimQICredit`
4. `ClaimBeneficialOwnerCredit`

Observed state:
- `paymentMade = TRUE`
- `qiPresent = TRUE`
- `qiAssumedPrimaryWithholding = FALSE`
- `beneficialOwnerForeign = TRUE`
- `withholdingRate = 0`
- `qiCreditClaimed = TRUE`
- `beneficialOwnerCreditClaimed = TRUE`

Expected invariant:
- `~(qiCreditClaimed /\ beneficialOwnerCreditClaimed)`

Meaning:
- the model lets a payment move through a qualified intermediary chain and still be claimed on both the intermediary side and the beneficial-owner side
- this is the QI chain gap: the withholding/reporting responsibility split is not exclusive, so one payment can still support two credit claims even though no intermediary assumed primary withholding responsibility

### 407. Multiple withholding agent no-filing failure

Model: `work/Tax1042SMultipleWithholdingAgentGap.tla`

Trace:
1. initial state
2. `MakePayment`
3. `AgentAAssumeMultipleRule`
4. `AgentBAssumeMultipleRule`

Observed state:
- `paymentMade = TRUE`
- `agentAPresent = TRUE`
- `agentBPresent = TRUE`
- `agentAAssumesOtherFiled = TRUE`
- `agentBAssumesOtherFiled = TRUE`
- `agentAFiled1042S = FALSE`
- `agentBFiled1042S = FALSE`

Expected invariant:
- `paymentMade /\ agentAAssumesOtherFiled /\ agentBAssumesOtherFiled => agentAFiled1042S \/ agentBFiled1042S`

Meaning:
- the model lets two withholding agents both assume the other agent will file Form 1042-S and still leave the payment completely unreported
- this is the multiple-withholding-agent gap: the IRS rule only works if another agent actually files and withholds correctly, but the state machine allows mutual assumption to produce a no-filing outcome

### 408. Form 8288 / 8288-A attachment failure

Model: `work/Tax1446f8288AttachmentGap.tla`

Trace:
1. initial state
2. `TransferInterest`
3. `ApplyWithholding`
4. `FileForm8288`

Observed state:
- `foreignInterestTransferDone = TRUE`
- `withholdingApplied = TRUE`
- `form8288Filed = TRUE`
- `form8288AAttached = FALSE`

Expected invariant:
- `form8288Filed => form8288AAttached`

Meaning:
- the model lets a section 1446(f) transfer be withheld and filed on Form 8288 without attaching Form 8288-A for the person subject to withholding
- this is the Form 8288 / 8288-A gap: current IRS instructions say Form 8288-A must be attached for each foreign person subject to withholding, but the state machine allows the filing package to complete without the attachment state

### 409. Form 8288-C refund package failure

Model: `work/Tax1446f8288CRefundGap.tla`

Trace:
1. initial state
2. `ApplyPartnershipWithholding`
3. `RequestRefund`

Observed state:
- `partnership1446f4WithholdingApplied = TRUE`
- `refundRequested = TRUE`
- `form8288Filed = FALSE`
- `form8288CAttached = FALSE`

Expected invariant:
- `refundRequested => form8288CAttached`

Meaning:
- the model lets a 1446(f)(4) refund request exist without the Form 8288-C attachment that the IRS instructions use to evidence the withholding
- this is the Form 8288-C gap: current IRS instructions say Form 8288-C is the statement used for withholding under section 1446(f)(4) and can support a refund claim when attached to Form 8288, but the state machine allows the refund path to exist without the attachment state

### 729. Early FIRPTA refund approval failure

Model: `work/Tax1446fEarlyRefundApprovalGap.tla`

Trace:
1. initial state
2. `PayWithholding`
3. `RequestEarlyRefund`
4. `GrantEarlyRefund`

Observed state:
- `withholdingPaid = TRUE`
- `approvedWithholdingCertificateReceived = FALSE`
- `earlyRefundRequested = TRUE`
- `earlyRefundGranted = TRUE`

Expected invariant:
- `earlyRefundGranted => approvedWithholdingCertificateReceived`

Meaning:
- the model lets an early FIRPTA refund be granted without an approved withholding certificate
- this is the early-refund approval gap: the IRS says the transferor may request an early refund if it received an approved withholding certificate reducing or eliminating the withholding, but the state machine allows the refund state without the approval state

### 410. Form 8937 organizational-action notice failure

Model: `work/TaxForm8937BasisNoticeGap.tla`

Trace:
1. initial state
2. `TakeBasisAffectingOrganizationalAction`

Observed state:
- `specifiedSecurityIssuer = TRUE`
- `organizationalActionOccurred = TRUE`
- `basisAffected = TRUE`
- `form8937Filed = FALSE`

Expected invariant:
- `organizationalActionOccurred /\ basisAffected => form8937Filed`

Meaning:
- the model lets an issuer take a basis-affecting organizational action and still never file Form 8937
- this is the Form 8937 gap: current IRS instructions say an issuer of a specified security that takes an organizational action affecting basis must file Form 8937, but the state machine allows the basis-affecting action to exist without the notice state

### 411. Form 8949 reconciliation failure

Model: `work/TaxForm8949ReconciliationGap.tla`

Trace:
1. initial state
2. `SellBrokeredAssetWithoutReportedBasis`

Observed state:
- `reportableBrokerSale = TRUE`
- `basisNotReportedToIRS = TRUE`
- `form8949Filed = FALSE`

Expected invariant:
- `reportableBrokerSale /\ basisNotReportedToIRS => form8949Filed`

Meaning:
- the model lets a brokered asset sale with basis not reported to the IRS exist without any Form 8949 reconciliation filing
- this is the Form 8949 gap: current IRS instructions say Form 8949 is used to reconcile amounts reported on Form 1099-B, Form 1099-DA, or Form 1099-S with the amounts reported on the return, but the state machine allows the sale/reporting mismatch to persist without the reconciliation form state

### 412. Form 8853 Archer MSA distribution reporting failure

Model: `work/TaxForm8853DistributionGap.tla`

Trace:
1. initial state
2. `ReceiveArcherMSADistribution`

Observed state:
- `archerMSADistributionReceived = TRUE`
- `form8853Filed = FALSE`

Expected invariant:
- `archerMSADistributionReceived => form8853Filed`

Meaning:
- the model lets an Archer MSA distribution occur without filing Form 8853
- this is the Form 8853 distribution gap: IRS instructions say Form 8853 is used to report Archer MSA distributions and Medicare Advantage MSA distributions, but the state machine allows the distribution state to exist without the taxpayer reporting form

### 413. Form 8867 paid preparer due-diligence failure

Model: `work/TaxForm8867DueDiligenceGap.tla`

Trace:
1. initial state
2. `ClaimEITC`

Observed state:
- `eitcClaimed = TRUE`
- `form8867Filed = FALSE`

Expected invariant:
- `eitcClaimed => form8867Filed`

Meaning:
- the model lets an EITC claim exist without the preparer filing Form 8867
- this is the Form 8867 gap: current IRS guidance says paid preparers must complete and submit Form 8867 with returns or claims involving EITC and other listed benefits, but the state machine allows the credit-claim state to exist without the due-diligence checklist state

### 414. Form 1095-A Marketplace statement failure

Model: `work/TaxForm1095AMarketplaceStatementGap.tla`

Trace:
1. initial state
2. `EnrollMarketplaceCoverage`
3. `ReceiveAdvancePayments`

Observed state:
- `marketplaceCoverage = TRUE`
- `advancePaymentsReceived = TRUE`
- `form1095AReceived = FALSE`

Expected invariant:
- `marketplaceCoverage /\ advancePaymentsReceived => form1095AReceived`

Meaning:
- the model lets Marketplace coverage with advance premium tax credit payments exist without furnishing Form 1095-A
- this is the Form 1095-A gap: current IRS guidance says the Health Insurance Marketplace furnishes Form 1095-A so the taxpayer can complete Form 8962, but the state machine allows the coverage-and-advance-payment state to exist without the Marketplace statement state

### 415. Form 8862 after-disallowance failure

Model: `work/TaxForm8862AfterDisallowanceGap.tla`

Trace:
1. initial state
2. `ReceivePriorDisallowance`
3. `ClaimCreditAgain`

Observed state:
- `creditPreviouslyDisallowed = TRUE`
- `creditNowClaimed = TRUE`
- `form8862Attached = FALSE`

Expected invariant:
- `creditPreviouslyDisallowed /\ creditNowClaimed => form8862Attached`

Meaning:
- the model lets a taxpayer claim a previously disallowed credit again without attaching Form 8862
- this is the Form 8862 gap: current IRS guidance says taxpayers must complete and attach Form 8862 when claiming certain credits after disallowance, but the state machine allows the re-claim state to exist without the restoration form state

### 416. Form 8881 retirement startup credit failure

Model: `work/TaxForm8881RetirementStartupCreditGap.tla`

Trace:
1. initial state
2. `StartEligibleEmployerPlan`

Observed state:
- `eligibleSmallEmployer = TRUE`
- `eligibleEmployerPlanStarted = TRUE`
- `form8881Filed = FALSE`

Expected invariant:
- `eligibleSmallEmployer /\ eligibleEmployerPlanStarted => form8881Filed`

Meaning:
- the model lets an eligible small employer start a qualifying retirement plan without filing Form 8881
- this is the Form 8881 gap: current IRS instructions say eligible small employers use Form 8881 to claim the retirement plan startup and related credits, but the state machine allows the credit-eligible plan state to exist without the filing state

### 417. Form 8288-B withholding certificate application failure

Model: `work/TaxForm8288BWithholdingCertificateGap.tla`

Trace:
1. initial state
2. `PlanForeignUSRPITransfer`

Observed state:
- `foreignUSRPITransferPlanned = TRUE`
- `withholdingCertificateRequested = TRUE`
- `form8288BFiled = FALSE`

Expected invariant:
- `foreignUSRPITransferPlanned /\ withholdingCertificateRequested => form8288BFiled`

Meaning:
- the model lets a planned foreign USRPI transfer trigger a withholding-certificate request without filing Form 8288-B
- this is the Form 8288-B gap: current IRS guidance says foreign persons use Form 8288-B to apply for a withholding certificate to reduce or eliminate FIRPTA withholding, but the state machine allows the request state to exist without the application state

### 418. Form 3800 general business credit failure

Model: `work/TaxForm3800GeneralBusinessCreditGap.tla`

Trace:
1. initial state
2. `ClaimGeneralBusinessCredit`

Observed state:
- `generalBusinessCreditClaimed = TRUE`
- `form3800Filed = FALSE`

Expected invariant:
- `generalBusinessCreditClaimed => form3800Filed`

Meaning:
- the model lets a general business credit be claimed without filing Form 3800
- this is the Form 3800 gap: current IRS instructions say you must file Form 3800 to claim general business credits, but the state machine allows the credit-claim state to exist without the aggregator filing state

### 419. Form 8882 employer-provided child care credit failure

Model: `work/TaxForm8882ChildCareCreditGap.tla`

Trace:
1. initial state
2. `MakeQualifiedChildCareExpenditures`

Observed state:
- `qualifiedChildCareExpendituresMade = TRUE`
- `form8882Filed = FALSE`

Expected invariant:
- `qualifiedChildCareExpendituresMade => form8882Filed`

Meaning:
- the model lets an employer make qualifying child care expenditures without filing Form 8882
- this is the Form 8882 gap: current IRS guidance says employers use Form 8882 to claim the employer-provided child care credit, but the state machine allows the qualifying-expenditure state to exist without the credit form state

### 420. Form 8844 empowerment zone employment credit failure

Related model: `work/TaxForm8844EmpowermentZoneCreditGap.tla`

Trace:
1. initial state
2. `PayQualifiedEmpowermentZoneWages`

Observed state:
- `qualifiedEmpowermentZoneWagesPaid = TRUE`
- `form8844Filed = FALSE`

Expected invariant:
- `qualifiedEmpowermentZoneWagesPaid => form8844Filed`

Meaning:
- the model lets qualified empowerment zone wages be paid without filing Form 8844
- this is the Form 8844 gap: current IRS guidance says Form 8844 is used to claim the empowerment zone employment credit, but the state machine allows the qualifying-wage state to exist without the claim form

### 421. Form 8850 WOTC prescreen failure

Model: `work/TaxForm8850WOTCPrescreenGap.tla`

Trace:
1. initial state
2. `HireTargetedGroupEmployee`

Observed state:
- `targetedGroupEmployeeHired = TRUE`
- `form8850SubmittedToSWA = FALSE`

Expected invariant:
- `targetedGroupEmployeeHired => form8850SubmittedToSWA`

Meaning:
- the model lets a targeted-group employee be hired without submitting Form 8850 to the state workforce agency
- this is the Form 8850 gap: current IRS guidance says employers use Form 8850 to pre-screen and request certification for the Work Opportunity Credit, but the state machine allows the hire state to exist without the pre-screen submission state

### 422. Form 8846 FICA tip credit failure

Model: `work/TaxForm8846TipCreditGap.tla`

Trace:
1. initial state
2. `EmployTippedWorkers`

Observed state:
- `tippedEmployeesWorking = TRUE`
- `employerFicaTaxesOnTipsPaid = TRUE`
- `form8846Filed = FALSE`

Expected invariant:
- `tippedEmployeesWorking /\ employerFicaTaxesOnTipsPaid => form8846Filed`

Meaning:
- the model lets an employer with tipped employees who paid FICA taxes on tips exist without filing Form 8846
- this is the Form 8846 gap: current IRS guidance says employers use Form 8846 to claim the credit for employer Social Security and Medicare taxes paid on certain employee tips, but the state machine allows the credit-eligible tip state to exist without the credit form state

### 423. Form 8991 base erosion minimum tax failure

Model: `work/TaxForm8991BaseErosionGap.tla`

Trace:
1. initial state
2. `TriggerBaseErosionExposure`

Observed state:
- `substantialGrossReceiptsMet = TRUE`
- `baseErosionPaymentsExist = TRUE`
- `form8991Filed = FALSE`

Expected invariant:
- `substantialGrossReceiptsMet /\ baseErosionPaymentsExist => form8991Filed`

Meaning:
- the model lets a taxpayer with substantial gross receipts and base erosion payments exist without filing Form 8991
- this is the Form 8991 gap: current IRS instructions say Form 8991 is used to determine the base erosion minimum tax for taxpayers with substantial gross receipts, but the state machine allows the exposure state to exist without the filing state

### 424. Form 8940 miscellaneous determination failure

Model: `work/TaxForm8940MiscDeterminationGap.tla`

Trace:
1. initial state
2. `NeedMiscDetermination`

Observed state:
- `exemptOrganizationExists = TRUE`
- `miscellaneousDeterminationNeeded = TRUE`
- `form8940Submitted = FALSE`

Expected invariant:
- `exemptOrganizationExists /\ miscellaneousDeterminationNeeded => form8940Submitted`

Meaning:
- the model lets an exempt organization enter a miscellaneous-determination-needed state without submitting Form 8940
- this is the Form 8940 gap: IRS guidance says exempt organizations use Form 8940 to request miscellaneous determinations, but the state machine allows the request-eligible state to exist without the submission state

### 425. Form 8911 refueling property credit failure

Model: `work/TaxForm8911RefuelingPropertyGap.tla`

Trace:
1. initial state
2. `PlaceRefuelingProperty`

Observed state:
- `refuelingPropertyPlacedInService = TRUE`
- `scheduleACompleted = FALSE`
- `form8911Filed = FALSE`

Expected invariant:
- `refuelingPropertyPlacedInService => form8911Filed`

Meaning:
- the model lets alternative fuel vehicle refueling property be placed in service without filing Form 8911
- this is the Form 8911 gap: IRS guidance says taxpayers use Form 8911 and a separate Schedule A for each item of qualified refueling property, but the state machine allows the placed-in-service state to exist without the filing state

### 426. Form 8952 VCSP application failure

Model: `work/TaxForm8952VCSPGap.tla`

Trace:
1. initial state
2. `DiscoverMisclassification`

Observed state:
- `workerMisclassificationExists = TRUE`
- `vcspApplicationFiled = FALSE`

Expected invariant:
- `workerMisclassificationExists => vcspApplicationFiled`

Meaning:
- the model lets a worker-classification misclassification exist without filing Form 8952
- this is the Form 8952 gap: IRS guidance says employers use Form 8952 to apply for the Voluntary Classification Settlement Program, but the state machine allows the misclassification state to exist without the VCSP application state

### 427. Form 8933 carbon oxide sequestration credit failure

Model: `work/TaxForm8933CarbonSequestrationGap.tla`

Trace:
1. initial state
2. `CaptureCO2`

Observed state:
- `qualifiedFacilityCapturesCO2 = TRUE`
- `form8933Filed = FALSE`

Expected invariant:
- `qualifiedFacilityCapturesCO2 => form8933Filed`

Meaning:
- the model lets a qualified facility capture carbon dioxide without filing Form 8933
- this is the Form 8933 gap: IRS guidance says Form 8933 is used to claim the carbon oxide sequestration credit, but the state machine allows the qualifying-capture state to exist without the filing state

### 428. Form 8960 net investment income tax failure

Model: `work/TaxForm8960NIITGap.tla`

Trace:
1. initial state
2. `CrossNIITThreshold`

Observed state:
- `netInvestmentIncomeExists = TRUE`
- `niitThresholdExceeded = TRUE`
- `form8960Filed = FALSE`

Expected invariant:
- `niitThresholdExceeded /\ netInvestmentIncomeExists => form8960Filed`

Meaning:
- the model lets a taxpayer cross the NIIT threshold while having net investment income without filing Form 8960
- this is the Form 8960 gap: IRS guidance says Form 8960 computes net investment income tax for individuals, estates, and trusts, but the state machine allows the taxable-threshold state to exist without the filing state

### 429. Form 8904 marginal wells credit failure

Model: `work/TaxForm8904MarginalWellsGap.tla`

Trace:
1. initial state
2. `ProduceFromMarginalWell`

Observed state:
- `marginalWellProductionExists = TRUE`
- `form8904Filed = FALSE`

Expected invariant:
- `marginalWellProductionExists => form8904Filed`

Meaning:
- the model lets marginal-well production exist without filing Form 8904
- this is the Form 8904 gap: IRS guidance says Form 8904 is used to claim the credit for oil and gas production from marginal wells, but the state machine allows the qualifying-production state to exist without the filing state

### 430. Form 8959 additional Medicare tax failure

Model: `work/TaxForm8959AdditionalMedicareTaxGap.tla`

Trace:
1. initial state
2. `CrossAdditionalMedicareThreshold`

Observed state:
- `wagesSubjectToAdditionalMedicareTax = TRUE`
- `form8959Filed = FALSE`

Expected invariant:
- `wagesSubjectToAdditionalMedicareTax => form8959Filed`

Meaning:
- the model lets wages subject to additional Medicare tax exist without filing Form 8959
- this is the Form 8959 gap: IRS guidance says Form 8959 reports and computes additional Medicare tax, but the state machine allows the threshold-crossing wage state to exist without the filing state

### 431. Form 8990 business interest expense failure

Model: `work/TaxForm8990BusinessInterestExpenseGap.tla`

Trace:
1. initial state
2. `AccrueBusinessInterestExpense`
3. `ExceedGrossReceiptsThreshold`

Observed state:
- `businessInterestExpenseExists = TRUE`
- `grossReceiptsThresholdExceeded = TRUE`
- `form8990Filed = FALSE`

Expected invariant:
- `businessInterestExpenseExists /\ grossReceiptsThresholdExceeded => form8990Filed`

Meaning:
- the model lets a taxpayer have business interest expense and exceed the gross-receipts threshold without filing Form 8990
- this is the Form 8990 gap: IRS guidance says Form 8990 computes the business interest expense limitation under section 163(j), but the state machine allows the threshold-plus-expense state to exist without the filing state

### 432. Form 8963 health insurance provider fee reporting failure

Model: `work/TaxForm8963HealthInsuranceProviderFeeGap.tla`

Trace:
1. initial state
2. `BecomeHealthInsuranceProvider`
3. `WriteNetPremiumsForUSHealthRisks`

Observed state:
- `healthInsuranceProviderExists = TRUE`
- `netPremiumsWrittenForUSHrks = TRUE`
- `form8963Filed = FALSE`

Expected invariant:
- `healthInsuranceProviderExists /\ netPremiumsWrittenForUSHrks => form8963Filed`

Meaning:
- the model lets a health insurance provider with net premiums written for U.S. health risks exist without filing Form 8963
- this is the Form 8963 gap: IRS guidance says the form reports provider information used to calculate the annual fee on health insurance providers, but the state machine allows the reportable-provider state to exist without the filing state

### 433. Form 8993 FDII and GILTI deduction failure

Model: `work/TaxForm8993FDIIGILTIGap.tla`

Trace:
1. initial state
2. `BecomeDomesticCorporation`
3. `GenerateFDIIOrGILTIAmount`

Observed state:
- `domesticCorporationExists = TRUE`
- `fdiiOrGILTIAmountExists = TRUE`
- `form8993Filed = FALSE`

Expected invariant:
- `domesticCorporationExists /\ fdiiOrGILTIAmountExists => form8993Filed`

Meaning:
- the model lets a domestic corporation have an FDII/GILTI deduction amount without filing Form 8993
- this is the Form 8993 gap: IRS guidance says Form 8993 computes the section 250 deduction for FDII and GILTI, but the state machine allows the deduction-eligible state to exist without the filing state

### 434. Form 8994 paid family and medical leave credit failure

Model: `work/TaxForm8994PaidFamilyLeaveGap.tla`

Trace:
1. initial state
2. `BecomeEligibleEmployer`
3. `PayQualifiedFamilyLeaveWages`

Observed state:
- `eligibleEmployerExists = TRUE`
- `qualifiedFamilyLeaveWagesPaid = TRUE`
- `form8994Filed = FALSE`

Expected invariant:
- `eligibleEmployerExists /\ qualifiedFamilyLeaveWagesPaid => form8994Filed`

Meaning:
- the model lets an eligible employer pay qualified family and medical leave wages without filing Form 8994
- this is the Form 8994 gap: IRS guidance says eligible employers use Form 8994 to figure the paid family and medical leave credit, but the state machine allows the qualifying-wage state to exist without the filing state

### 435. Form 8932 differential wage payments credit failure

Model: `work/TaxForm8932DifferentialWageGap.tla`

Trace:
1. initial state
2. `PayEligibleDifferentialWagePayments`

Observed state:
- `eligibleDifferentialWagePaymentsExist = TRUE`
- `form8932Filed = FALSE`

Expected invariant:
- `eligibleDifferentialWagePaymentsExist => form8932Filed`

Meaning:
- the model lets eligible differential wage payments exist without filing Form 8932
- this is the Form 8932 gap: IRS guidance says Form 8932 is used to claim the employer differential wage payments credit, but the state machine allows the qualifying-payment state to exist without the filing state

### 436. Form 8981 waiver of modification period failure

Model: `work/TaxForm8981WaiverPeriodGap.tla`

Trace:
1. initial state
2. `EnterBBAAudit`
3. `RequestWaiver`

Observed state:
- `partnershipUnderBBAAudit = TRUE`
- `waiverRequested = TRUE`
- `form8981Signed = FALSE`

Expected invariant:
- `partnershipUnderBBAAudit /\ waiverRequested => form8981Signed`

Meaning:
- the model lets a partnership under BBA audit request a waiver without signing Form 8981
- this is the Form 8981 gap: IRS guidance says the form waives the remaining modification-submission period, but the state machine allows the waiver-request state to exist without the signed-form state

### 437. Form 8982 partner modification amended return failure

Model: `work/TaxForm8982PartnerModificationGap.tla`

Trace:
1. initial state
2. `ReceiveModification`
3. `FileAmendedReturn`

Observed state:
- `partnerModificationAllowed = TRUE`
- `amendedReturnFiled = TRUE`
- `form8982Filed = FALSE`

Expected invariant:
- `partnerModificationAllowed /\ amendedReturnFiled => form8982Filed`

Meaning:
- the model lets a partner file the amended return required for modification without filing Form 8982
- this is the Form 8982 gap: IRS guidance says Form 8982 is used for partner modification procedures, but the state machine allows the modification-eligible state to exist without the filing state

### 438. Form 8983 tax-exempt status certification failure

Model: `work/TaxForm8983TaxExemptStatusGap.tla`

Trace:
1. initial state
2. `BecomeTaxExemptPartner`
3. `RequestModification`

Observed state:
- `partnerIsTaxExempt = TRUE`
- `modificationRequested = TRUE`
- `form8983Filed = FALSE`

Expected invariant:
- `partnerIsTaxExempt /\ modificationRequested => form8983Filed`

Meaning:
- the model lets a tax-exempt partner request modification without filing Form 8983
- this is the Form 8983 gap: IRS guidance says the form certifies partner tax-exempt status for modification, but the state machine allows the certification-trigger state to exist without the filing state

### 439. Form 8984 extension of taxpayer modification submission period failure

Model: `work/TaxForm8984ExtensionGap.tla`

Trace:
1. initial state
2. `OpenModificationSubmissionPeriod`
3. `RequestExtension`

Observed state:
- `modificationSubmissionPeriodOpen = TRUE`
- `extensionRequested = TRUE`
- `form8984Filed = FALSE`

Expected invariant:
- `modificationSubmissionPeriodOpen /\ extensionRequested => form8984Filed`

Meaning:
- the model lets the modification-submission period be open and an extension be needed without filing Form 8984
- this is the Form 8984 gap: IRS guidance says Form 8984 requests an extension of the taxpayer modification submission period, but the state machine allows the extension-needed state to exist without the filing state

### 440. Form 8996 qualified opportunity fund failure

Model: `work/TaxForm8996OpportunityFundGap.tla`

Trace:
1. initial state
2. `BecomeQualifiedOpportunityFund`
3. `MeetInvestmentStandard`

Observed state:
- `qualifiedOpportunityFundExists = TRUE`
- `investmentStandardMet = TRUE`
- `form8996Filed = FALSE`

Expected invariant:
- `qualifiedOpportunityFundExists /\ investmentStandardMet => form8996Filed`

Meaning:
- the model lets a qualified opportunity fund meet the investment standard without filing Form 8996
- this is the Form 8996 gap: IRS guidance says Form 8996 certifies and annually reports QOF status, but the state machine allows the qualification state to exist without the filing state

### 441. Form 8997 QOF investment reporting failure

Model: `work/TaxForm8997QOFInvestmentGap.tla`

Trace:
1. initial state
2. `AcquireQOFInvestment`
3. `DeferGainIntoQOF`

Observed state:
- `qofInvestmentExists = TRUE`
- `deferredGainExists = TRUE`
- `form8997Filed = FALSE`

Expected invariant:
- `qofInvestmentExists /\ deferredGainExists => form8997Filed`

Meaning:
- the model lets a taxpayer hold QOF investments and deferred gains without filing Form 8997
- this is the Form 8997 gap: IRS guidance says Form 8997 reports QOF investments and deferred gains, but the state machine allows the investment-and-gain state to exist without the reporting state

### 442. Form 8995 qualified business income deduction simplified computation failure

Model: `work/TaxForm8995QBISimplifiedGap.tla`

Trace:
1. initial state
2. `BecomeQBIDeductionEligible`

Observed state:
- `qbiDeductionEligible = TRUE`
- `form8995Filed = FALSE`

Expected invariant:
- `qbiDeductionEligible => form8995Filed`

Meaning:
- the model lets a taxpayer become eligible for the simplified QBI deduction computation without filing Form 8995
- this is the Form 8995 gap: IRS guidance says Form 8995 figures the qualified business income deduction, but the state machine allows the deduction-eligible state to exist without the filing state

### 443. Form 8947 branded prescription drug information reporting failure

Model: `work/TaxForm8947BrandedDrugInfoGap.tla`

Trace:
1. initial state
2. `BecomeBrandedDrugReporter`

Observed state:
- `brandedPrescriptionDrugInfoExists = TRUE`
- `form8947Filed = FALSE`

Expected invariant:
- `brandedPrescriptionDrugInfoExists => form8947Filed`

Meaning:
- the model lets branded prescription drug information exist without filing Form 8947
- this is the Form 8947 gap: IRS guidance says Form 8947 reports branded prescription drug information, but the state machine allows the reportable-information state to exist without the filing state

### 444. Form 8951 VCP user fee failure

Model: `work/TaxForm8951VCPUserFeeGap.tla`

Trace:
1. initial state
2. `OpenVCPApplication`
3. `AssessAdditionalFee`

Observed state:
- `vcpApplicationOpen = TRUE`
- `additionalFeeDue = TRUE`
- `form8951Filed = FALSE`

Expected invariant:
- `vcpApplicationOpen /\ additionalFeeDue => form8951Filed`

Meaning:
- the model lets a VCP application be open and an additional user fee be due without filing Form 8951
- this is the Form 8951 gap: IRS guidance says Form 8951 is the VCP user-fee payment form, but the state machine allows the fee-due state to exist without the fee form state

### 445. Form 8948 preparer explanation for not filing electronically failure

Model: `work/TaxForm8948PreparerExplanationGap.tla`

Trace:
1. initial state
2. `ChooseNotToFileElectronically`

Observed state:
- `notFilingElectronically = TRUE`
- `form8948Filed = FALSE`

Expected invariant:
- `notFilingElectronically => form8948Filed`

Meaning:
- the model lets a preparer choose not to file electronically without filing Form 8948
- this is the Form 8948 gap: IRS guidance says the form explains why a return is not being filed electronically, but the state machine allows the non-e-file state to exist without the explanation form state

### 446. Form 8944 preparer e-file hardship waiver failure

Model: `work/TaxForm8944HardshipWaiverGap.tla`

Trace:
1. initial state
2. `DevelopHardship`

Observed state:
- `preparerHasHardship = TRUE`
- `form8944Filed = FALSE`

Expected invariant:
- `preparerHasHardship => form8944Filed`

Meaning:
- the model lets a preparer have a hardship condition without filing Form 8944
- this is the Form 8944 gap: IRS guidance says Form 8944 requests a hardship waiver from e-filing, but the state machine allows the hardship state to exist without the waiver-request state

### 447. Form 8946 PTIN supplemental application for foreign persons failure

Related model: `work/TaxForm8946PTINForeignPersonGap.tla`

Trace:
1. initial state
2. `BecomeForeignPersonWithoutSSN`

Observed state:
- `foreignPersonWithoutSSN = TRUE`
- `form8946Filed = FALSE`

Expected invariant:
- `foreignPersonWithoutSSN => form8946Filed`

Meaning:
- the model lets a foreign person without an SSN exist without filing Form 8946
- this is the Form 8946 gap: IRS guidance says foreign persons without an SSN use Form 8946 to establish identity and status, but the state machine allows the qualifying-person state to exist without the supplemental-application state

### 448. Form 8873 extraterritorial income exclusion failure

Model: `work/TaxForm8873ExtraterritorialIncomeGap.tla`

Trace:
1. initial state
2. `GenerateExtraterritorialIncome`

Observed state:
- `extraterritorialIncomeExists = TRUE`
- `form8873Attached = FALSE`

Expected invariant:
- `extraterritorialIncomeExists => form8873Attached`

Meaning:
- the model lets extraterritorial income exist without attaching Form 8873
- this is the Form 8873 gap: IRS guidance says Form 8873 figures the extraterritorial income exclusion and is attached to the income tax return, but the state machine allows the qualifying-income state to exist without the attachment state

### 449. Form 8869 qualified subchapter S subsidiary election failure

Model: `work/TaxForm8869QSubElectionGap.tla`

Trace:
1. initial state
2. `CreateEligibleSubsidiary`

Observed state:
- `eligibleSubsidiaryExists = TRUE`
- `form8869Filed = FALSE`

Expected invariant:
- `eligibleSubsidiaryExists => form8869Filed`

Meaning:
- the model lets an eligible subsidiary exist without filing Form 8869
- this is the Form 8869 gap: IRS guidance says a parent S corporation uses Form 8869 to elect QSub status, but the state machine allows the eligible-subsidiary state to exist without the election state

### 450. Form 8832 entity classification election failure

Model: `work/TaxForm8832EntityClassificationGap.tla`

Trace:
1. initial state
2. `CreateEligibleEntity`

Observed state:
- `eligibleEntityExists = TRUE`
- `form8832Filed = FALSE`

Expected invariant:
- `eligibleEntityExists => form8832Filed`

Meaning:
- the model lets an eligible entity exist without filing Form 8832
- this is the Form 8832 gap: IRS guidance says Form 8832 is used for entity classification elections, but the state machine allows the eligible-entity state to exist without the election form state

### 451. Form 8833 treaty-based return position disclosure failure

Model: `work/TaxForm8833TreatyDisclosureGap.tla`

Trace:
1. initial state
2. `TakeTreatyBasedReturnPosition`

Observed state:
- `treatyBasedReturnPositionExists = TRUE`
- `form8833Attached = FALSE`

Expected invariant:
- `treatyBasedReturnPositionExists => form8833Attached`

Meaning:
- the model lets a treaty-based return position exist without attaching Form 8833
- this is the Form 8833 gap: IRS guidance says Form 8833 discloses treaty-based return positions, but the state machine allows the treaty-position state to exist without the disclosure form state

### 452. Form 8854 expatriation statement failure

Model: `work/TaxForm8854ExpatriationGap.tla`

Trace:
1. initial state
2. `BecomeExpatriated`

Observed state:
- `expatriatedPersonExists = TRUE`
- `form8854Filed = FALSE`

Expected invariant:
- `expatriatedPersonExists => form8854Filed`

Meaning:
- the model lets an expatriated person exist without filing Form 8854
- this is the Form 8854 gap: IRS guidance says Form 8854 is used by expatriated individuals to report expatriation and certify compliance, but the state machine allows the expatriation state to exist without the statement form state

### 453. Form 8453-TE tax-exempt entity e-file declaration failure

Model: `work/TaxForm8453TEDeclarationGap.tla`

Trace:
1. initial state
2. `PrepareTaxExemptEntityEFile`

Observed state:
- `taxExemptEntityEFilePrepared = TRUE`
- `form8453TEAttached = FALSE`

Expected invariant:
- `taxExemptEntityEFilePrepared => form8453TEAttached`

Meaning:
- the model lets a tax-exempt entity prepare an e-filed return without attaching Form 8453-TE
- this is the Form 8453-TE gap: IRS guidance says Form 8453-TE is the attached declaration and signature document for tax-exempt entity e-filing, but the state machine allows the e-file state to exist without the attachment state

### 454. Form 8038-CP direct payment request failure

Model: `work/TaxForm8038CPDirectPaymentGap.tla`

Trace:
1. initial state
2. `RequestDirectPayment`

Observed state:
- `directPaymentRequested = TRUE`
- `form8038CPFiled = FALSE`

Expected invariant:
- `directPaymentRequested => form8038CPFiled`

Meaning:
- the model lets an issuer request a direct payment without filing Form 8038-CP
- this is the Form 8038-CP gap: IRS guidance says Form 8038-CP is the return used by eligible bond issuers to request direct payment, but the state machine allows the payment-request state to exist without the filing state

### 455. Form 8879-EMP employment tax authorization failure

Model: `work/TaxForm8879EMPAuthorizationGap.tla`

Trace:
1. initial state
2. `PrepareEmploymentTaxReturn`

Observed state:
- `employmentTaxReturnPrepared = TRUE`
- `form8879EMPFiled = FALSE`

Expected invariant:
- `employmentTaxReturnPrepared => form8879EMPFiled`

Meaning:
- the model lets an employment tax return be prepared without filing Form 8879-EMP
- this is the Form 8879-EMP gap: IRS guidance says Form 8879-EMP is the e-file authorization for employment tax returns, but the state machine allows the prepared-return state to exist without the authorization form

### 456. Form 8870 personal benefit contract reporting failure

Model: `work/TaxForm8870PersonalBenefitContractGap.tla`

Trace:
1. initial state
2. `PayPremiumOnPersonalBenefitContract`

Observed state:
- `organizationPaidPremiumOnPersonalBenefitContract = TRUE`
- `form8870Filed = FALSE`

Expected invariant:
- `organizationPaidPremiumOnPersonalBenefitContract => form8870Filed`

Meaning:
- the model lets an organization pay premiums on a personal benefit contract without filing Form 8870
- this is the Form 8870 gap: IRS guidance says Form 8870 reports transfers associated with certain personal benefit contracts, but the state machine allows the premium-payment state to exist without the reporting form state

### 457. Form 8804-C foreign partner certificate failure

Model: `work/TaxForm8804CCertificateGap.tla`

Trace:
1. initial state
2. `SeekReducedWithholding`

Observed state:
- `foreignPartnerSeeksReducedWithholding = TRUE`
- `form8804CFiled = FALSE`

Expected invariant:
- `foreignPartnerSeeksReducedWithholding => form8804CFiled`

Meaning:
- the model lets a foreign partner seek reduced section 1446 withholding without filing Form 8804-C
- this is the Form 8804-C gap: IRS guidance says Form 8804-C certifies partner-level items to reduce section 1446 withholding, but the state machine allows the reduced-withholding state to exist without the certificate form state

### 458. Form 8813 partnership withholding payment voucher failure

Model: `work/TaxForm8813PaymentVoucherGap.tla`

Trace:
1. initial state
2. `MakePartnershipWithholdingPayment`

Observed state:
- `partnershipWithholdingPaymentMade = TRUE`
- `form8813Filed = FALSE`

Expected invariant:
- `partnershipWithholdingPaymentMade => form8813Filed`

Meaning:
- the model lets a partnership make a section 1446 withholding payment without filing Form 8813
- this is the Form 8813 gap: IRS guidance says Form 8813 accompanies each section 1446 withholding payment, but the state machine allows the payment state to exist without the voucher form state

### 459. Form 7004 extension request failure

Model: `work/TaxForm7004ExtensionRequestGap.tla`

Trace:
1. initial state
2. `NeedExtension`

Observed state:
- `businessReturnNeedsExtension = TRUE`
- `form7004Filed = FALSE`

Expected invariant:
- `businessReturnNeedsExtension => form7004Filed`

Meaning:
- the model lets a business return need an extension without filing Form 7004
- this is the Form 7004 gap: IRS guidance says Form 7004 requests an automatic extension for certain business income tax, information, and other returns, but the state machine allows the extension-needed state to exist without the extension form state

### 460. Form 8842 annualization election failure

Model: `work/TaxForm8842AnnualizationElectionGap.tla`

Trace:
1. initial state
2. `ChooseAnnualizedInstallmentMethod`

Observed state:
- `corporationUsesAnnualizedInstallmentMethod = TRUE`
- `form8842Filed = FALSE`

Expected invariant:
- `corporationUsesAnnualizedInstallmentMethod => form8842Filed`

Meaning:
- the model lets a corporation choose the annualized installment method without filing Form 8842
- this is the Form 8842 gap: IRS guidance says Form 8842 elects different annualization periods for corporate estimated tax, but the state machine allows the election state to exist without the election form state

### 461. Form 8888 refund allocation failure

Model: `work/TaxForm8888RefundAllocationGap.tla`

Trace:
1. initial state
2. `RequestRefundAllocation`

Observed state:
- `refundAllocationRequested = TRUE`
- `form8888Attached = FALSE`

### 682. Form 8842 first-installment timing failure

Model: `work/TaxForm8842FirstInstallmentTimingGap.tla`

Trace:
1. initial state
2. `PassFirstRequiredInstallmentDueDate`
3. `FileForm8842`
4. `ChooseAnnualizedInstallmentMethod`

Observed state:
- `corporationUsesAnnualizedInstallmentMethod = TRUE`
- `form8842Filed = TRUE`
- `firstRequiredInstallmentDueDatePassed = TRUE`
- `form8842FiledByDeadline = FALSE`

Expected invariant:
- `corporationUsesAnnualizedInstallmentMethod => form8842FiledByDeadline`

Meaning:
- the model lets a corporation file Form 8842 after the first required installment due date and still switch onto the annualized installment method
- this is a distinct Form 8842 timing gap: IRS instructions say the election must be filed by the due date of the first required installment payment, but the state machine does not encode that deadline

### 683. Form 2553 timely S election failure

Model: `work/TaxForm2553TimelyElectionGap.tla`

Trace:
1. initial state
2. `PassElectionDeadline`
3. `FileForm2553`
4. `ClaimSCorpTreatment`

Observed state:
- `sCorpTreatmentClaimed = TRUE`
- `form2553Filed = TRUE`
- `electionDeadlinePassed = TRUE`
- `form2553FiledByDeadline = FALSE`

Expected invariant:
- `sCorpTreatmentClaimed => form2553FiledByDeadline`

Meaning:
- the model lets S corporation treatment be claimed after the Form 2553 election window has already closed
- this is a distinct Form 2553 timing gap: IRS instructions say the election must generally be filed no more than 2 months and 15 days after the beginning of the tax year, but the state machine does not enforce that filing window

### 684. Form 8832 retroactive effective-date failure

Model: `work/TaxForm8832RetroactiveEffectiveDateGap.tla`

Trace:
1. initial state
2. `CreateEligibleEntity`
3. `PassRetroactiveWindow`
4. `FileForm8832`

Observed state:
- `eligibleEntityExists = TRUE`
- `form8832Filed = TRUE`
- `retroactiveWindowPassed = TRUE`
- `classificationEffectiveByWindow = TRUE`

Expected invariant:
- `classificationEffectiveByWindow => form8832Filed /\ ~retroactiveWindowPassed`

Meaning:
- the model lets entity classification become effective even after the retroactive election window has already closed
- this is a distinct Form 8832 timing gap: IRS instructions say the election generally cannot take effect more than 75 days before the filing date and not more than 12 months after the filing date, but the state machine does not encode that filing/effective-date window

### 685. Form 7004 timely extension failure

Model: `work/TaxForm7004TimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedExtension`
3. `PassExtensionDeadline`
4. `FileForm7004`

Observed state:
- `businessReturnNeedsExtension = TRUE`
- `form7004Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form7004FiledByDeadline = FALSE`

Expected invariant:
- `businessReturnNeedsExtension => form7004FiledByDeadline`

Meaning:
- the model lets a business return need an extension and then file Form 7004 after the filing deadline while still satisfying the extension-needed state
- this is a distinct Form 7004 timing gap: IRS instructions say Form 7004 must be filed by the due date of the return to request the extension, but the state machine does not encode that deadline

### 686. Form 8868 timely extension failure

Model: `work/TaxForm8868TimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedExtension`
3. `PassExtensionDeadline`
4. `FileForm8868`

Observed state:
- `exemptOrganizationNeedsExtension = TRUE`
- `form8868Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form8868FiledByDeadline = FALSE`

Expected invariant:
- `exemptOrganizationNeedsExtension /\ form8868Filed => form8868FiledByDeadline`

Meaning:
- the model lets an exempt organization need an extension and then file Form 8868 after the filing deadline while still satisfying the extension-needed state
- this is a distinct Form 8868 timing gap: IRS instructions say Form 8868 must be filed by the return due date to request the extension, but the state machine does not encode that deadline

### 687. Form 1040-ES timely estimated-tax payment failure

Model: `work/TaxForm1040ESTimelyPaymentGap.tla`

Trace:
1. initial state
2. `BecomeLiableForEstimatedTax`
3. `PassEstimatedTaxDeadline`
4. `PayEstimatedTax`

Observed state:
- `individualOwesEstimatedTax = TRUE`
- `estimatedTaxPaid = TRUE`
- `estimatedTaxDeadlinePassed = TRUE`
- `estimatedTaxPaidByDeadline = FALSE`

Expected invariant:
- `individualOwesEstimatedTax /\ estimatedTaxPaid => estimatedTaxPaidByDeadline`

Meaning:
- the model lets an individual owe estimated tax and pay after the installment deadline while still satisfying the estimated-tax path
- this is a distinct Form 1040-ES timing gap: IRS guidance sets quarterly installment due dates, but the state machine does not encode those deadlines

### 688. Form 1041-ES timely estimated-tax payment failure

Model: `work/TaxForm1041ESTimelyPaymentGap.tla`

Trace:
1. initial state
2. `BecomeLiableForEstimatedTax`
3. `PassEstimatedTaxDeadline`
4. `PayEstimatedTax`

Observed state:
- `estateOrTrustOwesEstimatedTax = TRUE`
- `estimatedTaxPaid = TRUE`
- `estimatedTaxDeadlinePassed = TRUE`
- `estimatedTaxPaidByDeadline = FALSE`

Expected invariant:
- `estateOrTrustOwesEstimatedTax /\ estimatedTaxPaid => estimatedTaxPaidByDeadline`

Meaning:
- the model lets an estate or trust owe estimated tax and pay after the installment deadline while still satisfying the estimated-tax path
- this is a distinct Form 1041-ES timing gap: IRS guidance gives estates and trusts installment due dates, but the state machine does not encode those deadlines

Expected invariant:
- `refundAllocationRequested => form8888Attached`

Meaning:
- the model lets a taxpayer request refund allocation without attaching Form 8888
- this is the Form 8888 gap: IRS guidance says Form 8888 allocates a refund among accounts or savings bonds, but the state machine allows the refund-allocation state to exist without the attachment form state

### 462. Form 8379 injured spouse allocation failure

Model: `work/TaxForm8379InjuredSpouseGap.tla`

Trace:
1. initial state
2. `ApplyJointRefundOffset`

Observed state:
- `jointRefundOffsetApplied = TRUE`
- `form8379Filed = FALSE`

Expected invariant:
- `jointRefundOffsetApplied => form8379Filed`

Meaning:
- the model lets a joint refund offset be applied without filing Form 8379
- this is the Form 8379 gap: IRS guidance says the injured spouse files Form 8379 to recover their share when a joint refund is offset, but the state machine allows the offset state to exist without the injured-spouse form state

### 463. Form 8857 innocent spouse relief request failure

Model: `work/TaxForm8857InnocentSpouseGap.tla`

Trace:
1. initial state
2. `RequestInnocentSpouseRelief`

Observed state:
- `innocentSpouseReliefRequested = TRUE`
- `form8857Filed = FALSE`

Expected invariant:
- `innocentSpouseReliefRequested => form8857Filed`

Meaning:
- the model lets a taxpayer request innocent-spouse relief without filing Form 8857
- this is the Form 8857 gap: IRS guidance says taxpayers file Form 8857 to request innocent-spouse relief, but the state machine allows the relief-request state to exist without the form state

### 464. Form 8958 community property allocation failure

Model: `work/TaxForm8958CommunityPropertyAllocationGap.tla`

Trace:
1. initial state
2. `ChooseSeparateCommunityPropertyFiling`

Observed state:
- `marriedFilingSeparatelyInCommunityPropertyState = TRUE`
- `form8958Attached = FALSE`

Expected invariant:
- `marriedFilingSeparatelyInCommunityPropertyState => form8958Attached`

Meaning:
- the model lets spouses file separately in a community-property state without attaching Form 8958
- this is the Form 8958 gap: IRS guidance says Form 8958 allocates tax amounts between spouses or RDPs with community property rights, but the state machine allows the separate-filing state to exist without the allocation form state

### 465. Form 8814 child income reporting election failure

Model: `work/TaxForm8814ChildIncomeElectionGap.tla`

Trace:
1. initial state
2. `ElectChildIncomeReporting`

Observed state:
- `parentElectsChildIncomeReporting = TRUE`
- `form8814Filed = FALSE`

Expected invariant:
- `parentElectsChildIncomeReporting => form8814Filed`

Meaning:
- the model lets a parent elect to report a child’s interest and dividends without filing Form 8814
- this is the Form 8814 gap: IRS guidance says parents attach Form 8814 to report eligible child income on their return, but the state machine allows the election state to exist without the form state

### 466. Form 2441 child and dependent care credit failure

Model: `work/TaxForm2441DependentCareGap.tla`

Trace:
1. initial state
2. `ClaimChildAndDependentCareCredit`

Observed state:
- `childAndDependentCareCreditClaimed = TRUE`
- `form2441Attached = FALSE`

Expected invariant:
- `childAndDependentCareCreditClaimed => form2441Attached`

Meaning:
- the model lets a taxpayer claim the child and dependent care credit without attaching Form 2441
- this is the Form 2441 gap: IRS guidance says Form 2441 is used to figure and claim the child and dependent care credit, but the state machine allows the credit-claim state to exist without the form state

### 467. Form 5695 residential energy credit failure

Model: `work/TaxForm5695ResidentialEnergyGap.tla`

Trace:
1. initial state
2. `ClaimResidentialEnergyCredit`

Observed state:
- `residentialEnergyCreditClaimed = TRUE`
- `form5695Attached = FALSE`

Expected invariant:
- `residentialEnergyCreditClaimed => form5695Attached`

Meaning:
- the model lets a taxpayer claim residential energy credits without attaching Form 5695
- this is the Form 5695 gap: IRS guidance says Form 5695 is used to figure and take residential energy credits, but the state machine allows the credit-claim state to exist without the form state

### 468. Form 8863 education credit failure

Model: `work/TaxForm8863EducationCreditGap.tla`

Trace:
1. initial state
2. `ClaimEducationCredit`

Observed state:
- `educationCreditClaimed = TRUE`
- `form8863Attached = FALSE`

Expected invariant:
- `educationCreditClaimed => form8863Attached`

Meaning:
- the model lets a taxpayer claim an education credit without attaching Form 8863
- this is the Form 8863 gap: IRS guidance says Form 8863 is used to figure and claim education credits, but the state machine allows the credit-claim state to exist without the form state

### 469. Form 3911 refund trace failure

Model: `work/TaxForm3911RefundTraceGap.tla`

Trace:
1. initial state
2. `RequestRefundTrace`

Observed state:
- `refundTraceRequested = TRUE`
- `form3911Filed = FALSE`

Expected invariant:
- `refundTraceRequested => form3911Filed`

Meaning:
- the model lets a taxpayer request a refund trace without filing Form 3911
- this is the Form 3911 gap: IRS guidance says Form 3911 is the taxpayer statement regarding refund used to trace nonreceipt or loss of an already issued refund, but the state machine allows the refund-trace state to exist without the statement form state

### 470. Form 8606 nondeductible IRA reporting failure

Model: `work/TaxForm8606NondeductibleIRAGap.tla`

Trace:
1. initial state
2. `MakeNondeductibleIRAContribution`

Observed state:
- `nondeductibleIRAContributionMade = TRUE`
- `form8606Filed = FALSE`

Expected invariant:
- `nondeductibleIRAContributionMade => form8606Filed`

Meaning:
- the model lets a nondeductible IRA contribution be made without filing Form 8606
- this is the Form 8606 gap: IRS guidance says Form 8606 is used to report nondeductible IRAs, but the state machine allows the nondeductible-contribution state to exist without the reporting form state

### 471. Form 8859 DC first-time homebuyer carryforward failure

Model: `work/TaxForm8859DCHomebuyerCarryforwardGap.tla`

Trace:
1. initial state
2. `ClaimDCHomebuyerCarryforward`

Observed state:
- `dCHomebuyerCreditCarryforwardClaimed = TRUE`
- `form8859Attached = FALSE`

Expected invariant:
- `dCHomebuyerCreditCarryforwardClaimed => form8859Attached`

Meaning:
- the model lets a District of Columbia first-time homebuyer credit carryforward be claimed without attaching Form 8859
- this is the Form 8859 gap: IRS guidance says Form 8859 claims the carryforward of the DC first-time homebuyer credit, but the state machine allows the carryforward-claim state to exist without the form state

### 472. Form 8839 adoption credit failure

Model: `work/TaxForm8839AdoptionCreditGap.tla`

Trace:
1. initial state
2. `ClaimAdoptionCredit`

Observed state:
- `adoptionCreditClaimed = TRUE`
- `form8839Attached = FALSE`

Expected invariant:
- `adoptionCreditClaimed => form8839Attached`

Meaning:
- the model lets a taxpayer claim the adoption credit without attaching Form 8839
- this is the Form 8839 gap: IRS guidance says Form 8839 is used to figure and claim the adoption credit, but the state machine allows the credit-claim state to exist without the form state

### 473. Form 3903 moving expense deduction failure

Model: `work/TaxForm3903MovingExpenseGap.tla`

Trace:
1. initial state
2. `ClaimMovingExpenseDeduction`

Observed state:
- `movingExpenseDeductionClaimed = TRUE`
- `form3903Attached = FALSE`

Expected invariant:
- `movingExpenseDeductionClaimed => form3903Attached`

Meaning:
- the model lets a taxpayer claim a moving expense deduction without attaching Form 3903
- this is the Form 3903 gap: IRS guidance says Form 3903 is used to figure the moving expense deduction, but the state machine allows the deduction-claim state to exist without the form state

### 474. Form 8917 tuition and fees deduction failure

Model: `work/TaxForm8917TuitionFeesGap.tla`

Trace:
1. initial state
2. `ClaimTuitionAndFeesDeduction`

Observed state:
- `tuitionAndFeesDeductionClaimed = TRUE`
- `form8917Attached = FALSE`

Expected invariant:
- `tuitionAndFeesDeductionClaimed => form8917Attached`

Meaning:
- the model lets a taxpayer claim the tuition and fees deduction without attaching Form 8917
- this is the Form 8917 gap: IRS guidance says Form 8917 is used to figure the tuition and fees deduction, but the state machine allows the deduction-claim state to exist without the form state

### 475. Form 4136 fuel credit failure

Model: `work/TaxForm4136FuelCreditGap.tla`

Trace:
1. initial state
2. `ClaimFuelCredit`

Observed state:
- `fuelCreditClaimed = TRUE`
- `form4136Attached = FALSE`

Expected invariant:
- `fuelCreditClaimed => form4136Attached`

Meaning:
- the model lets a taxpayer claim the fuel credit without attaching Form 4136
- this is the Form 4136 gap: IRS guidance says Form 4136 is used to figure the credit for federal tax paid on fuels, but the state machine allows the credit-claim state to exist without the form state

### 476. Form 2106 employee business expense failure

Model: `work/TaxForm2106EmployeeExpenseGap.tla`

Trace:
1. initial state
2. `ClaimEmployeeBusinessExpense`

Observed state:
- `employeeBusinessExpenseClaimed = TRUE`
- `form2106Attached = FALSE`

Expected invariant:
- `employeeBusinessExpenseClaimed => form2106Attached`

Meaning:
- the model lets an employee business expense claim exist without attaching Form 2106
- this is the Form 2106 gap: IRS guidance says Form 2106 is used to deduct ordinary and necessary employee business expenses, but the state machine allows the expense-claim state to exist without the form state

### 477. Form 4972 lump-sum distribution failure

Model: `work/TaxForm4972LumpSumDistributionGap.tla`

Trace:
1. initial state
2. `ReceiveLumpSumDistribution`

Observed state:
- `lumpSumDistributionReceived = TRUE`
- `form4972Attached = FALSE`

Expected invariant:
- `lumpSumDistributionReceived => form4972Attached`

Meaning:
- the model lets a taxpayer receive a lump-sum distribution without attaching Form 4972
- this is the Form 4972 gap: IRS guidance says Form 4972 is used to figure the tax on qualified lump-sum distributions, but the state machine allows the distribution state to exist without the special-tax form state

### 478. Form 8864 fuel credit failure

Model: `work/TaxForm8864FuelCreditGap.tla`

Trace:
1. initial state
2. `ClaimFuelCredit`

Observed state:
- `fuelCreditClaimed = TRUE`
- `form8864Attached = FALSE`

Expected invariant:
- `fuelCreditClaimed => form8864Attached`

Meaning:
- the model lets a taxpayer claim the biodiesel / renewable diesel fuel credit without attaching Form 8864
- this is the Form 8864 gap: IRS guidance says Form 8864 is used to figure the biodiesel, renewable diesel, or sustainable aviation fuels credit, but the state machine allows the credit-claim state to exist without the form state

### 479. Form 5884 work opportunity credit failure

Model: `work/TaxForm5884WorkOpportunityCreditGap.tla`

Trace:
1. initial state
2. `ClaimWorkOpportunityCredit`

Observed state:
- `workOpportunityCreditClaimed = TRUE`
- `form5884Attached = FALSE`

Expected invariant:
- `workOpportunityCreditClaimed => form5884Attached`

Meaning:
- the model lets an employer claim the work opportunity credit without attaching Form 5884
- this is the Form 5884 gap: IRS guidance says Form 5884 is used to claim the work opportunity credit for qualified wages paid to targeted-group employees, but the state machine allows the credit-claim state to exist without the form state

### 480. Form 8844 empowerment zone employment credit failure

Model: `work/TaxForm8844EmpowermentZoneCreditGap.tla`

Trace:
1. initial state
2. `PayEmpowermentZoneWages`

Observed state:
- `empowermentZoneWagesPaid = TRUE`
- `form8844Attached = FALSE`

Expected invariant:
- `empowermentZoneWagesPaid => form8844Attached`

Meaning:
- the model lets qualified empowerment zone wages be paid without attaching Form 8844
- this is the Form 8844 gap: IRS guidance says Form 8844 is used to claim the empowerment zone employment credit, but the state machine allows the wage-payment state to exist without the credit form state

### 481. Form 8855 section 645 election failure

Model: `work/TaxForm8855Section645ElectionGap.tla`

Trace:
1. initial state
2. `ElectSection645Treatment`

Observed state:
- `qualifiedRevocableTrustElectsSection645 = TRUE`
- `form8855Filed = FALSE`

Expected invariant:
- `qualifiedRevocableTrustElectsSection645 => form8855Filed`

Meaning:
- the model lets a qualified revocable trust elect section 645 treatment without filing Form 8855
- this is the Form 8855 gap: IRS guidance says trustees use Form 8855 to make the section 645 election, but the state machine allows the election state to exist without the election form state

### 482. Form 8840 closer-connection statement failure

Model: `work/TaxForm8840CloserConnectionGap.tla`

Trace:
1. initial state
2. `ClaimCloserConnection`

Observed state:
- `closerConnectionClaimed = TRUE`
- `form8840Filed = FALSE`

Expected invariant:
- `closerConnectionClaimed => form8840Filed`

Meaning:
- the model lets a taxpayer claim the closer-connection exception without filing Form 8840
- this is the Form 8840 gap: IRS guidance says Form 8840 is used to claim the closer connection to a foreign country exception to the substantial presence test, but the state machine allows the exception-claim state to exist without the statement form state

### 483. Form 8843 exempt individual statement failure

Model: `work/TaxForm8843ExemptIndividualGap.tla`

Trace:
1. initial state
2. `ClaimExemptIndividualStatus`

Observed state:
- `exemptIndividualClaimed = TRUE`
- `form8843Filed = FALSE`

Expected invariant:
- `exemptIndividualClaimed => form8843Filed`

Meaning:
- the model lets an exempt individual claim status without filing Form 8843
- this is the Form 8843 gap: IRS guidance says Form 8843 is used by exempt individuals and individuals with a medical condition to claim the substantial-presence-test exclusion, but the state machine allows the exempt-status state to exist without the statement form state

### 484. Form 8900 railroad track maintenance credit failure

Model: `work/TaxForm8900RailMaintenanceGap.tla`

Trace:
1. initial state
2. `MakeRailroadTrackMaintenanceExpenditures`

Observed state:
- `railroadTrackMaintenanceExpendituresMade = TRUE`
- `form8900Attached = FALSE`

Expected invariant:
- `railroadTrackMaintenanceExpendituresMade => form8900Attached`

Meaning:
- the model lets railroad track maintenance expenditures be made without attaching Form 8900
- this is the Form 8900 gap: IRS guidance says Form 8900 is used to claim the railroad track maintenance credit, but the state machine allows the expenditure state to exist without the credit form state

### 485. Form 5768 section 501(h) election filing failure

Model: `work/TaxForm5768LobbyingElectionGap.tla`

Trace:
1. initial state
2. `Make501hElection`

Observed state:
- `section501hElectionMade = TRUE`
- `form5768Filed = FALSE`

Expected invariant:
- `section501hElectionMade => form5768Filed`

Meaning:
- the model lets a section 501(h) lobbying election exist without filing Form 5768
- this is the Form 5768 gap: IRS guidance says Form 5768 is the election/revocation form for the section 501(h) expenditure test, but the state machine allows the election state to exist without the filing state

### 486. Form 7207 advanced manufacturing production credit filing failure

Model: `work/TaxForm7207AdvancedManufacturingGap.tla`

Trace:
1. initial state
2. `MakeAdvancedManufacturingClaim`

Observed state:
- `eligibleComponentsProducedAndSold = TRUE`
- `form7207Filed = FALSE`

Expected invariant:
- `eligibleComponentsProducedAndSold => form7207Filed`

Meaning:
- the model lets eligible components be produced and sold without filing Form 7207
- this is the Form 7207 gap: IRS guidance says Form 7207 is used to claim the advanced manufacturing production credit, but the state machine allows the eligible-production state to exist without the credit-form state

### 487. Form 7210 clean hydrogen production credit filing failure

Model: `work/TaxForm7210CleanHydrogenGap.tla`

Trace:
1. initial state
2. `ProduceCleanHydrogen`

Observed state:
- `qualifiedCleanHydrogenProduced = TRUE`
- `form7210Filed = FALSE`

Expected invariant:
- `qualifiedCleanHydrogenProduced => form7210Filed`

Meaning:
- the model lets qualified clean hydrogen be produced without filing Form 7210
- this is the Form 7210 gap: IRS guidance says Form 7210 is used to claim the clean hydrogen production credit, but the state machine allows the qualified-production state to exist without the credit-form state

### 488. Form 7211 clean electricity production credit filing failure

Model: `work/TaxForm7211CleanElectricityGap.tla`

Trace:
1. initial state
2. `ProduceCleanElectricity`

Observed state:
- `qualifiedCleanElectricityProduced = TRUE`
- `form7211Filed = FALSE`

Expected invariant:
- `qualifiedCleanElectricityProduced => form7211Filed`

Meaning:
- the model lets qualified clean electricity be produced without filing Form 7211
- this is the Form 7211 gap: IRS guidance says Form 7211 is used to claim the clean electricity production credit, but the state machine allows the qualified-production state to exist without the credit-form state

### 489. Form 7213 nuclear power production credit filing failure

Model: `work/TaxForm7213NuclearPowerGap.tla`

Trace:
1. initial state
2. `ProduceNuclearPower`

Observed state:
- `qualifiedNuclearPowerProduced = TRUE`
- `form7213Filed = FALSE`

Expected invariant:
- `qualifiedNuclearPowerProduced => form7213Filed`

Meaning:
- the model lets qualified nuclear power be produced without filing Form 7213
- this is the Form 7213 gap: IRS guidance says Form 7213 is used to claim the nuclear power production credit, but the state machine allows the qualified-production state to exist without the form state

### 490. Form 7218 clean fuel production credit filing failure

Model: `work/TaxForm7218CleanFuelGap.tla`

Trace:
1. initial state
2. `ProduceCleanFuel`

Observed state:
- `qualifiedCleanFuelProduced = TRUE`
- `form7218Filed = FALSE`

Expected invariant:
- `qualifiedCleanFuelProduced => form7218Filed`

Meaning:
- the model lets qualified clean fuel be produced without filing Form 7218
- this is the Form 7218 gap: IRS guidance says Form 7218 is used to claim the clean fuel production credit, but the state machine allows the qualified-production state to exist without the form state

### 491. Form 8835 renewable electricity production credit filing failure

Model: `work/TaxForm8835RenewableElectricityGap.tla`

Trace:
1. initial state
2. `ProduceRenewableElectricity`

Observed state:
- `renewableElectricityProduced = TRUE`
- `form8835Filed = FALSE`

Expected invariant:
- `renewableElectricityProduced => form8835Filed`

Meaning:
- the model lets renewable electricity be produced without filing Form 8835
- this is the Form 8835 gap: IRS guidance says Form 8835 is used to claim the renewable electricity production credit, but the state machine allows the production state to exist without the form state

### 492. Form 7220 prevailing wage and apprenticeship verification failure

Model: `work/TaxForm7220PwaVerificationGap.tla`

Trace:
1. initial state
2. `ClaimPwaBonusCredit`

Observed state:
- `bonusCreditClaimedForPwa = TRUE`
- `form7220Filed = FALSE`

Expected invariant:
- `bonusCreditClaimedForPwa => form7220Filed`

Meaning:
- the model lets a PWA bonus credit be claimed without filing Form 7220
- this is the Form 7220 gap: IRS guidance says Form 7220 is used to demonstrate compliance with prevailing wage and apprenticeship requirements for increased credit amounts, but the state machine allows the bonus-credit state to exist without the verification form state

### 493. Form 3468 investment credit filing failure

Model: `work/TaxForm3468InvestmentCreditGap.tla`

Trace:
1. initial state
2. `ClaimInvestmentCredit`

Observed state:
- `qualifiedInvestmentClaimed = TRUE`
- `form3468Attached = FALSE`

Expected invariant:
- `qualifiedInvestmentClaimed => form3468Attached`

Meaning:
- the model lets an investment credit be claimed without attaching Form 3468
- this is the Form 3468 gap: IRS guidance says Form 3468 is used to claim the investment credit, but the state machine allows the credit-claim state to exist without the form state

### 494. Form 1041-ES estimated tax payment failure

Model: `work/TaxForm1041ESEstimatedTaxGap.tla`

Trace:
1. initial state
2. `BecomeLiableForEstimatedTax`

Observed state:
- `estateOrTrustOwesEstimatedTax = TRUE`
- `estimatedTaxPaid = FALSE`

Expected invariant:
- `estateOrTrustOwesEstimatedTax => estimatedTaxPaid`

Meaning:
- the model lets an estate or trust become liable for estimated tax without paying via the 1041-ES path
- this is the Form 1041-ES gap: IRS guidance says Form 1041-ES is used to figure and pay estimated tax for estates and trusts, but the state machine allows the liability state to exist without the payment state

### 495. Form 1040-ES estimated tax payment failure

Model: `work/TaxForm1040ESEstimatedTaxGap.tla`

Trace:
1. initial state
2. `BecomeLiableForEstimatedTax`

Observed state:
- `individualOwesEstimatedTax = TRUE`
- `estimatedTaxPaid = FALSE`

Expected invariant:
- `individualOwesEstimatedTax => estimatedTaxPaid`

Meaning:
- the model lets an individual become liable for estimated tax without paying via the 1040-ES path
- this is the Form 1040-ES gap: IRS guidance says Form 1040-ES is used to figure and pay estimated tax for individuals, but the state machine allows the liability state to exist without the payment state

### 496. Form 8919 uncollected social security and medicare tax reporting failure

Model: `work/TaxForm8919UncollectedSocialSecurityGap.tla`

Trace:
1. initial state
2. `BecomeMisclassified`

Observed state:
- `employeeMisclassifiedAsContractor = TRUE`
- `form8919Filed = FALSE`

Expected invariant:
- `employeeMisclassifiedAsContractor => form8919Filed`

Meaning:
- the model lets an employee be misclassified as a contractor without filing Form 8919
- this is the Form 8919 gap: IRS guidance says Form 8919 is used to figure and report uncollected social security and Medicare taxes when an employee was treated as an independent contractor, but the state machine allows the misclassification state to exist without the corrective filing state

### 497. Form 1099-DA digital asset broker reporting failure

Model: `work/TaxForm1099DABrokerReportingGap.tla`

Trace:
1. initial state
2. `BrokerReportsDigitalAssetSale`

Observed state:
- `digitalAssetBrokerSaleOccurred = TRUE`
- `form1099DAFiled = FALSE`

Expected invariant:
- `digitalAssetBrokerSaleOccurred => form1099DAFiled`

Meaning:
- the model lets a brokered digital asset sale occur without filing Form 1099-DA
- this is the Form 1099-DA gap: IRS guidance says Form 1099-DA is used to report digital asset proceeds from broker transactions, but the state machine allows the broker-sale state to exist without the reporting form state

### 498. Form 4029 religious exemption filing failure

Model: `work/TaxForm4029ReligiousExemptionGap.tla`

Trace:
1. initial state
2. `JoinReligiousGroup`

Observed state:
- `recognizedReligiousGroupMember = TRUE`
- `form4029Filed = FALSE`

Expected invariant:
- `recognizedReligiousGroupMember => form4029Filed`

Meaning:
- the model lets a recognized religious group member exist without filing Form 4029
- this is the Form 4029 gap: IRS guidance says Form 4029 is used to apply for exemption from Social Security and Medicare taxes and waive benefits, but the state machine allows the exemption-eligible state to exist without the filing state

### 499. Form 4361 minister self-employment tax exemption filing failure

Model: `work/TaxForm4361MinisterExemptionGap.tla`

Trace:
1. initial state
2. `ReceiveMinisterialEarnings`

Observed state:
- `ministerHasEarnings = TRUE`
- `form4361Filed = FALSE`

Expected invariant:
- `ministerHasEarnings => form4361Filed`

Meaning:
- the model lets ministerial earnings exist without filing Form 4361
- this is the Form 4361 gap: IRS guidance says Form 4361 is used by ministers and certain religious workers to apply for exemption from self-employment tax, but the state machine allows the earnings state to exist without the exemption filing state

### 500. Form 1040-SS self-employment tax return failure

Model: `work/TaxForm1040SSSelfEmploymentTaxGap.tla`

Trace:
1. initial state
2. `EarnSelfEmploymentIncome`

Observed state:
- `netSelfEmploymentIncome = 400`
- `form1040SSFiled = FALSE`

Expected invariant:
- `netSelfEmploymentIncome = 400 => form1040SSFiled`

Meaning:
- the model lets a U.S. territory/self-employment taxpayer hit the SE-tax threshold without filing Form 1040-SS
- this is the Form 1040-SS gap: IRS guidance says Form 1040-SS is used to report net self-employment earnings and pay self-employment tax for certain territorial residents, but the state machine allows the liability state to exist without the return state

### 501. Form 8946 PTIN supplemental application for foreign persons failure

Model: `work/TaxForm8946PTINForeignPersonGap.tla`

Trace:
1. initial state
2. `BecomeForeignPreparerWithoutSSN`

Observed state:
- `foreignPersonWithoutSSN = TRUE`
- `form8946Filed = FALSE`

Expected invariant:
- `foreignPersonWithoutSSN => form8946Filed`

Meaning:
- the model lets a foreign person without an SSN become a PTIN applicant without filing Form 8946
- this is the Form 8946 gap: IRS guidance says Form 8946 is used by foreign persons without a Social Security number to establish identity and status for PTIN purposes, but the state machine allows the identity-state to exist without the supplemental application state

### 502. Form 8945 PTIN supplemental application for U.S. citizens failure

Model: `work/TaxForm8945PTINUScitizenGap.tla`

Trace:
1. initial state
2. `BecomePTINApplicantWithoutSSN`

Observed state:
- `usCitizenReligiousObjectorWithoutSSN = TRUE`
- `form8945Filed = FALSE`

Expected invariant:
- `usCitizenReligiousObjectorWithoutSSN => form8945Filed`

Meaning:
- the model lets a U.S. citizen religious objector without an SSN become a PTIN applicant without filing Form 8945
- this is the Form 8945 gap: IRS guidance says Form 8945 is used by certain U.S. citizens without an SSN to establish identity and religious-objector status for PTIN purposes, but the state machine allows the identity-state to exist without the supplemental application state

### 503. Form 945 nonpayroll withholding reporting failure

Related model: `work/TaxForm945NonpayrollWithholdingGap.tla`

Trace:
1. initial state
2. `MakeNonpayrollWithholding`

Observed state:
- `nonpayrollWithholdingMade = TRUE`
- `form945Filed = FALSE`

Expected invariant:
- `nonpayrollWithholdingMade => form945Filed`

Meaning:
- the model lets nonpayroll withholding happen without filing Form 945
- this is the Form 945 gap: IRS guidance says Form 945 reports withheld federal income tax from nonpayroll payments, but the state machine allows the withholding state to exist without the annual return state

### 504. Form 8829 home office deduction failure

Model: `work/TaxForm8829HomeOfficeGap.tla`

Trace:
1. initial state
2. `UseHomeOfficeForBusiness`

Observed state:
- `homeOfficeUsedExclusivelyForBusiness = TRUE`
- `form8829Filed = FALSE`

Expected invariant:
- `homeOfficeUsedExclusivelyForBusiness => form8829Filed`

Meaning:
- the model lets a taxpayer use a home office for business without filing Form 8829
- this is the Form 8829 gap: IRS guidance says Form 8829 is used to figure the home office deduction, but the state machine allows the business-use state to exist without the deduction form state

### 505. Form 1099-INT interest income reporting failure

Model: `work/TaxForm1099INTInterestGap.tla`

Trace:
1. initial state
2. `PayReportableInterest`

Observed state:
- `reportableInterestPaid = TRUE`
- `form1099INTFiled = FALSE`

Expected invariant:
- `reportableInterestPaid => form1099INTFiled`

Meaning:
- the model lets reportable interest be paid without filing Form 1099-INT
- this is the Form 1099-INT gap: IRS guidance says Form 1099-INT reports interest income, but the state machine allows the reportable-interest state to exist without the information return state

### 506. Form 1098 mortgage interest reporting failure

Model: `work/TaxForm1098MortgageInterestGap.tla`

Trace:
1. initial state
2. `ReceiveMortgageInterest`

Observed state:
- `mortgageInterestReceived = TRUE`
- `form1098Filed = FALSE`

Expected invariant:
- `mortgageInterestReceived => form1098Filed`

Meaning:
- the model lets mortgage interest be received without filing Form 1098
- this is the Form 1098 gap: IRS guidance says Form 1098 reports mortgage interest of $600 or more, but the state machine allows the mortgage-interest state to exist without the information return state

### 507. Schedule 8812 child tax credit failure

Model: `work/TaxSchedule8812ChildTaxCreditGap.tla`

Trace:
1. initial state
2. `ClaimChildTaxCredit`

Observed state:
- `childTaxCreditClaimed = TRUE`
- `schedule8812Completed = FALSE`

Expected invariant:
- `childTaxCreditClaimed => schedule8812Completed`

Meaning:
- the model lets a child tax credit be claimed without completing Schedule 8812
- this is the Schedule 8812 gap: IRS guidance says Schedule 8812 is used to figure the child tax credit, credit for other dependents, and additional child tax credit, but the state machine allows the claim state to exist without the schedule state

### 508. Form 8283 noncash charitable contribution failure

Model: `work/TaxForm8283NoncashCharitableGap.tla`

Trace:
1. initial state
2. `DonateNoncashProperty`

Observed state:
- `noncashContributionDeduction = 600`
- `form8283Attached = FALSE`

Expected invariant:
- `noncashContributionDeduction > 500 => form8283Attached`

Meaning:
- the model lets a noncash charitable deduction over $500 exist without Form 8283 attached
- this is the Form 8283 gap: IRS guidance says Form 8283 is required for noncash charitable deductions over $500, but the state machine allows the deduction state to exist without the attachment state

### 509. Form 8889 HSA reporting failure

Related model: `work/TaxForm8889HSAReportingGap.tla`

Trace:
1. initial state
2. `MakeHSAContribution`

Observed state:
- `hsaContributionMade = TRUE`
- `form8889Filed = FALSE`

Expected invariant:
- `hsaContributionMade => form8889Filed`

Meaning:
- the model lets HSA contribution activity exist without filing Form 8889
- this is the Form 8889 gap: IRS guidance says Form 8889 reports HSA contributions and distributions, but the state machine allows the HSA activity state to exist without the reporting form state

### 510. Form 5329 early distribution failure

Model: `work/TaxForm5329EarlyDistributionGap.tla`

Trace:
1. initial state
2. `TakeEarlyRetirementDistribution`

Observed state:
- `earlyRetirementDistribution = TRUE`
- `form5329Filed = FALSE`

Expected invariant:
- `earlyRetirementDistribution => form5329Filed`

Meaning:
- the model lets an early retirement distribution exist without filing Form 5329
- this is the Form 5329 gap: IRS guidance says Form 5329 reports additional taxes on early distributions and related tax-favored account events, but the state machine allows the distribution state to exist without the additional-tax filing state

### 511. Form 8962 premium tax credit failure

Model: `work/TaxForm8962PremiumTaxCreditGap.tla`

Trace:
1. initial state
2. `ClaimPremiumTaxCredit`

Observed state:
- `premiumTaxCreditClaimed = TRUE`
- `form8962Filed = FALSE`

Expected invariant:
- `premiumTaxCreditClaimed => form8962Filed`

Meaning:
- the model lets the premium tax credit be claimed without filing Form 8962
- this is the Form 8962 gap: IRS guidance says Form 8962 is required to compute and take the Premium Tax Credit and reconcile advance payments, but the state machine allows the credit state to exist without the form state

### 512. Form 8822-B responsible party change failure

Model: `work/TaxForm8822BResponsiblePartyGap.tla`

Trace:
1. initial state
2. `ChangeResponsibleParty`

Observed state:
- `responsiblePartyChanged = TRUE`
- `form8822BFiled = FALSE`

Expected invariant:
- `responsiblePartyChanged => form8822BFiled`

Meaning:
- the model lets a business responsible-party change occur without filing Form 8822-B
- this is the Form 8822-B gap: IRS guidance says business address or responsible-party changes should be reported on Form 8822-B, but the state machine allows the identity-change state to exist without the notification state

### 513. Form 8821 tax information authorization failure

Model: `work/TaxForm8821TaxInformationAuthorizationGap.tla`

Trace:
1. initial state
2. `InspectConfidentialTaxInfo`

Observed state:
- `taxInfoAccessed = TRUE`
- `form8821Filed = FALSE`

Expected invariant:
- `taxInfoAccessed => form8821Filed`

Meaning:
- the model lets confidential IRS tax information be inspected without filing Form 8821
- this is the Form 8821 gap: IRS guidance says Form 8821 authorizes a designee to inspect or receive confidential tax information, but the state machine allows the access state to exist without the authorization state

### 514. Form 2555 foreign earned income exclusion failure

Model: `work/TaxForm2555ForeignEarnedIncomeGap.tla`

Trace:
1. initial state
2. `ClaimForeignEarnedIncomeExclusion`

Observed state:
- `foreignEarnedIncomeExcluded = TRUE`
- `form2555Filed = FALSE`

Expected invariant:
- `foreignEarnedIncomeExcluded => form2555Filed`

Meaning:
- the model lets a foreign earned income exclusion be claimed without filing Form 2555
- this is the Form 2555 gap: IRS guidance says Form 2555 is used to figure the foreign earned income exclusion and housing exclusion or deduction, but the state machine allows the exclusion state to exist without the form state

### 514.1. Form 2555 excluded-income foreign tax benefit failure

Model: `work/TaxForm2555ExcludedIncomeForeignTaxBenefitGap.tla`

Trace:
1. initial state
2. `EarnForeignIncome`
3. `ClaimExclusion`
4. `PayTaxesOnExcludedIncome`
5. `ClaimForeignTaxCredit`

Observed state:
- `foreignEarnedIncomeExists = TRUE`
- `foreignEarnedIncomeExcluded = TRUE`
- `foreignTaxesPaidOnExcludedIncome = TRUE`
- `foreignTaxCreditClaimed = TRUE`
- `itemizedDeductionClaimed = FALSE`

Expected invariant:
- `foreignEarnedIncomeExcluded /\ foreignTaxesPaidOnExcludedIncome => ~foreignTaxCreditClaimed /\ ~itemizedDeductionClaimed`

Meaning:
- the model lets taxes on excluded foreign earned income still generate a foreign tax credit
- this is the excluded-income benefit gap: IRS guidance says you can’t take a credit or deduction for foreign income taxes paid or accrued on income excluded under the foreign earned income exclusion, but the state machine allows the excluded-income tax state to exist with the tax-benefit state

### 514.2. Form 2555 foreign earned income qualification failure

Model: `work/TaxForm2555QualificationGap.tla`

Trace:
1. initial state
2. `EarnForeignIncome`
3. `ClaimForeignEarnedIncomeExclusion`

Observed state:
- `foreignEarnedIncomeExists = TRUE`
- `foreignEarnedIncomeExcluded = TRUE`
- `taxHomeForeign = FALSE`
- `bonaFideResidenceMet = FALSE`
- `daysAbroad = 0`

Expected invariant:
- `foreignEarnedIncomeExcluded => taxHomeForeign /\ (bonaFideResidenceMet \/ daysAbroad >= RequiredDays)`

Meaning:
- the model lets the foreign earned income exclusion be claimed even though the tax-home and foreign-presence tests never become true
- this is the Form 2555 qualification gap: IRS instructions say the exclusion requires a foreign tax home and either the bona fide residence test or the physical presence test, but the state machine allows the exclusion state to exist without the qualification state

### 514.3. Foreign housing deduction self-employment eligibility failure

Model: `work/TaxForeignHousingDeductionEligibilityGap.tla`

Trace:
1. initial state
2. `ClaimForeignHousingDeduction`

Observed state:
- `selfEmploymentIncomeExists = FALSE`
- `foreignHousingDeductionClaimed = TRUE`

Expected invariant:
- `foreignHousingDeductionClaimed => selfEmploymentIncomeExists`

Meaning:
- the model lets a foreign housing deduction be claimed without any self-employment income
- this is the foreign housing deduction gap: IRS guidance says the housing deduction applies only to amounts paid for with self-employment income, but the state machine allows the deduction state to exist without the self-employment-income state

### 514.4. Form 2555 foreign earned income exclusion revokes EITC/ACTC failure

Model: `work/TaxForm2555ForeignEarnedIncomeRevokesCreditsGap.tla`

Trace:
1. initial state
2. `ClaimForeignEarnedIncomeExclusion`
3. `ClaimEarnedIncomeCredit`

Observed state:
- `foreignEarnedIncomeExcluded = TRUE`
- `earnedIncomeCreditClaimed = TRUE`
- `additionalChildTaxCreditClaimed = FALSE`

Expected invariant:
- `foreignEarnedIncomeExcluded => ~earnedIncomeCreditClaimed /\ ~additionalChildTaxCreditClaimed`

Meaning:
- the model lets a taxpayer claim the foreign earned income exclusion and still claim the earned income credit
- this is the FEIE revocation gap: IRS guidance says claiming the foreign earned income exclusion or foreign housing exclusion can revoke the ability to claim the earned income credit and the additional child tax credit, but the state machine allows the exclusion state to coexist with those credit states

### 514.5. Form 2555 foreign earned income exclusion revokes child credits failure

Model: `work/TaxForm2555ForeignEarnedIncomeRevokesChildCreditsGap.tla`

Trace:
1. initial state
2. `ClaimForeignEarnedIncomeExclusion`
3. `ClaimChildTaxCredit`

Observed state:
- `foreignEarnedIncomeExcluded = TRUE`
- `childTaxCreditClaimed = TRUE`
- `additionalChildTaxCreditClaimed = FALSE`

Expected invariant:
- `foreignEarnedIncomeExcluded => ~childTaxCreditClaimed /\ ~additionalChildTaxCreditClaimed`

Meaning:
- the model lets a taxpayer claim the foreign earned income exclusion and still claim the child tax credit
- this is the FEIE child-credit revocation gap: IRS guidance says claiming the foreign earned income exclusion or foreign housing exclusion can revoke the additional child tax credit, and the report now captures the separate child-credit revocation branch alongside the earned-income-credit branch

### 514.6. Foreign housing deduction carryover next-year-only failure

Model: `work/TaxForeignHousingDeductionCarryoverGap.tla`

Trace:
1. initial state
2. `CreateExcessHousingDeductionCarryover`
3. `AdvanceToNextYear`
4. `AdvanceToNextYear`

Observed state:
- `taxYear = 3`
- `excessHousingDeductionCarryoverExists = TRUE`

Expected invariant:
- `excessHousingDeductionCarryoverExists => taxYear <= 2`

Meaning:
- the model lets a foreign housing deduction carryover survive into year 3 after being created in year 1
- this is the foreign housing carryover gap: IRS guidance limits the housing deduction carryover to the next tax year, but the state machine allows the carryover state to persist after two year advances

### 515. Form 673 foreign-earned-income withholding failure

Model: `work/TaxForm673ForeignEarnedIncomeWithholdingGap.tla`

Trace:
1. initial state
2. `ReduceWithholdingOnForeignWages`

Observed state:
- `withholdingReduced = TRUE`
- `form673GivenToEmployer = FALSE`

Expected invariant:
- `withholdingReduced => form673GivenToEmployer`

Meaning:
- the model lets U.S. withholding be reduced on foreign-earned wages without giving Form 673 to the employer
- this is the Form 673 gap: IRS guidance says Form 673 is given to the employer to claim exemption from withholding on foreign-earned wages to the extent of the exclusion, but the state machine allows the withholding-reduction state to exist without the statement state

### 516. Form 56 fiduciary relationship notice failure

Model: `work/TaxForm56FiduciaryRelationshipGap.tla`

Trace:
1. initial state
2. `ActAsFiduciaryBeforeIRS`

Observed state:
- `fiduciaryActsForTaxpayer = TRUE`
- `form56Filed = FALSE`

Expected invariant:
- `fiduciaryActsForTaxpayer => form56Filed`

Meaning:
- the model lets a fiduciary act for a taxpayer before the IRS without filing Form 56
- this is the Form 56 gap: IRS guidance says Form 56 notifies the IRS of the creation or termination of a fiduciary relationship, but the state machine allows the fiduciary-action state to exist without the notice state

### 517. Form 2350 foreign-earned-income extension failure

Model: `work/TaxForm2350ForeignEarnedIncomeExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToQualifyForFEIE`

Observed state:
- `extensionNeededForFEIE = TRUE`
- `form2350Filed = FALSE`

Expected invariant:
- `extensionNeededForFEIE => form2350Filed`

Meaning:
- the model lets a taxpayer need extra time to qualify for the foreign earned income exclusion without filing Form 2350
- this is the Form 2350 gap: IRS guidance says Form 2350 is used to request more time to meet the bona fide residence or physical presence test, but the state machine allows the extension-needed state to exist without the extension form state

### 693. Form 2350 timely foreign-earned-income extension failure

Model: `work/TaxForm2350TimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToQualifyForFEIE`
3. `PassExtensionDeadline`
4. `FileForm2350`

Observed state:
- `extensionNeededForFEIE = TRUE`
- `form2350Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form2350FiledByDeadline = FALSE`

Expected invariant:
- `extensionNeededForFEIE /\ form2350Filed => form2350FiledByDeadline`

Meaning:
- the model lets a taxpayer need extra time to qualify for the foreign earned income exclusion and then file Form 2350 after the filing deadline while still satisfying the extension-needed state
- this is a distinct Form 2350 timing gap: IRS instructions say Form 2350 must be filed on or before the due date of the return, but the state machine does not encode that deadline

### 518. Form 2848 power of attorney representation failure

Model: `work/TaxForm2848PowerOfAttorneyGap.tla`

Trace:
1. initial state
2. `RepresentBeforeIRS`

Observed state:
- `representativeActsBeforeIRS = TRUE`
- `form2848Filed = FALSE`

Expected invariant:
- `representativeActsBeforeIRS => form2848Filed`

Meaning:
- the model lets a representative act before the IRS without filing Form 2848
- this is the Form 2848 gap: IRS guidance says Form 2848 authorizes an individual to represent you before the IRS, but the state machine allows the representation state to exist without the power-of-attorney form state

### 519. Form 56-F fiduciary relationship of financial institution failure

Model: `work/TaxForm56FFiduciaryRelationshipOfFinancialInstitutionGap.tla`

Trace:
1. initial state
2. `ActAsFinancialInstitutionFiduciary`

Observed state:
- `financialInstitutionActsAsFiduciary = TRUE`
- `form56FFiled = FALSE`

Expected invariant:
- `financialInstitutionActsAsFiduciary => form56FFiled`

Meaning:
- the model lets a financial institution act as a fiduciary without filing Form 56-F
- this is the Form 56-F gap: IRS guidance says Form 56-F notifies the IRS of a fiduciary relationship for a financial institution, but the state machine allows the fiduciary-relationship state to exist without the notice form state

### 520. Form 8332 child exemption release failure

Model: `work/TaxForm8332ChildExemptionGap.tla`

Trace:
1. initial state
2. `ClaimChildAsDependent`

Observed state:
- `noncustodialParentClaimsChild = TRUE`
- `form8332Attached = FALSE`

Expected invariant:
- `noncustodialParentClaimsChild => form8332Attached`

Meaning:
- the model lets a noncustodial parent claim a child as a dependent without attaching Form 8332
- this is the Form 8332 gap: IRS guidance says the noncustodial parent must attach Form 8332 or a similar statement to claim the child, but the state machine allows the claim state to exist without the release form state

### 521. Form 4868 individual extension failure

Model: `work/TaxForm4868ExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFileReturn`

Observed state:
- `extensionNeeded = TRUE`
- `form4868Filed = FALSE`

Expected invariant:
- `extensionNeeded => form4868Filed`

Meaning:
- the model lets a taxpayer need more time to file a return without filing Form 4868
- this is the Form 4868 gap: IRS guidance says Form 4868 requests an automatic extension of time to file a U.S. individual income tax return, but the state machine allows the extension-needed state to exist without the extension-request form state

### 692. Form 4868 timely extension failure

Model: `work/TaxForm4868TimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFileReturn`
3. `PassExtensionDeadline`
4. `FileForm4868`

Observed state:
- `extensionNeeded = TRUE`
- `form4868Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form4868FiledByDeadline = FALSE`

Expected invariant:
- `extensionNeeded /\ form4868Filed => form4868FiledByDeadline`

Meaning:
- the model lets a taxpayer ask for more time to file and then file Form 4868 after the filing deadline while still satisfying the extension-needed state
- this is a distinct Form 4868 timing gap: IRS instructions say Form 4868 must be filed by the original due date of the return, but the state machine does not encode that deadline

### 522. Form 709 gift tax return failure

Model: `work/TaxForm709GiftTaxReturnGap.tla`

Trace:
1. initial state
2. `MakeTaxableGift`

Observed state:
- `taxableGiftMade = TRUE`
- `form709Filed = FALSE`

Expected invariant:
- `taxableGiftMade => form709Filed`

Meaning:
- the model lets a taxable gift exist without filing Form 709
- this is the Form 709 gap: IRS guidance says Form 709 reports transfers subject to gift tax and GST tax, but the state machine allows the taxable-gift state to exist without the gift-tax return state

### 697. Form 709 timely gift-tax return failure

Model: `work/TaxForm709TimelyGiftTaxReturnGap.tla`

Trace:
1. initial state
2. `MakeTaxableGift`
3. `PassGiftTaxReturnDeadline`
4. `FileForm709`

Observed state:
- `taxableGiftMade = TRUE`
- `form709Filed = TRUE`
- `giftTaxReturnDeadlinePassed = TRUE`
- `form709FiledByDeadline = FALSE`

Expected invariant:
- `taxableGiftMade /\ form709Filed => form709FiledByDeadline`

Meaning:
- the model lets a donor make a taxable gift and then file Form 709 after the annual gift-tax deadline while still satisfying the taxable-gift state
- this is a distinct Form 709 timing gap: IRS instructions say Form 709 generally must be filed no later than April 15 of the year after the gift was made, but the state machine does not encode that filing window

### 523. Form 8892 gift-tax payment failure

Model: `work/TaxForm8892GiftTaxPaymentGap.tla`

Trace:
1. initial state
2. `NeedToPayGiftTax`

Observed state:
- `giftTaxPaymentNeeded = TRUE`
- `form8892Used = FALSE`

Expected invariant:
- `giftTaxPaymentNeeded => form8892Used`

Meaning:
- the model lets gift tax payment become due without using Form 8892
- this is the Form 8892 gap: IRS guidance says Form 8892 is used to request a Form 709 extension and/or make gift-tax or GST-tax payment, but the state machine allows the payment-needed state to exist without the Form 8892 state

### 695. Form 8892 timely gift-tax payment failure

Model: `work/TaxForm8892TimelyGiftTaxPaymentGap.tla`

Trace:
1. initial state
2. `NeedToPayGiftTax`
3. `PassGiftTaxDeadline`
4. `UseForm8892`

Observed state:
- `giftTaxPaymentNeeded = TRUE`
- `form8892Used = TRUE`
- `giftTaxPaymentDeadlinePassed = TRUE`
- `form8892UsedByDeadline = FALSE`

Expected invariant:
- `giftTaxPaymentNeeded /\ form8892Used => form8892UsedByDeadline`

Meaning:
- the model lets a taxpayer owe gift tax and then use Form 8892 after the filing deadline while still satisfying the payment-needed state
- this is a distinct Form 8892 timing gap: IRS instructions say gift-tax payment on Form 8892 should be filed by the Form 709 due date, but the state machine does not encode that deadline

### 699. Form 8892 timely gift-tax extension failure

Model: `work/TaxForm8892TimelyGiftTaxExtensionGap.tla`

Trace:
1. initial state
2. `NeedGiftTaxExtension`
3. `PassGiftTaxExtensionDeadline`
4. `UseForm8892`

Observed state:
- `giftTaxExtensionNeeded = TRUE`
- `form8892Used = TRUE`
- `giftTaxExtensionDeadlinePassed = TRUE`
- `form8892UsedByDeadline = FALSE`

Expected invariant:
- `giftTaxExtensionNeeded /\ form8892Used => form8892UsedByDeadline`

Meaning:
- the model lets a taxpayer need a gift-tax filing extension and then use Form 8892 after the filing deadline while still satisfying the extension-needed state
- this is a distinct Form 8892 timing gap: IRS instructions say Form 8892 must be filed by the Form 709 or 709-NA due date to request the automatic extension, but the state machine does not encode that deadline

### 524. Form 2120 multiple support declaration failure

Model: `work/TaxForm2120MultipleSupportGap.tla`

Trace:
1. initial state
2. `ClaimMultipleSupportDependent`

Observed state:
- `multipleSupportClaimed = TRUE`
- `form2120Attached = FALSE`

Expected invariant:
- `multipleSupportClaimed => form2120Attached`

Meaning:
- the model lets a multiple-support dependent claim exist without Form 2120 attached
- this is the Form 2120 gap: IRS guidance says Form 2120 is used to identify other eligible supporters and show waivers for the multiple-support agreement, but the state machine allows the claim state to exist without the declaration form state

### 525. Form 8233 treaty withholding exemption failure

Model: `work/TaxForm8233TreatyWithholdingGap.tla`

Trace:
1. initial state
2. `ClaimTreatyWithholdingExemption`

Observed state:
- `treatyWithholdingExemptionClaimed = TRUE`
- `form8233Provided = FALSE`

Expected invariant:
- `treatyWithholdingExemptionClaimed => form8233Provided`

Meaning:
- the model lets a treaty withholding exemption be claimed without providing Form 8233
- this is the Form 8233 gap: IRS guidance says nonresident aliens use Form 8233 to claim treaty exemptions from withholding on personal services compensation, but the state machine allows the exemption state to exist without the withholding form state

### 526. Form 706-NA nonresident estate tax return failure

Model: `work/TaxForm706NANonresidentEstateGap.tla`

Trace:
1. initial state
2. `NRNCEstateHasTaxableUSAssets`

Observed state:
- `usSituatedAssetsValue = 60001`
- `form706NAFiled = FALSE`

Expected invariant:
- `usSituatedAssetsValue >= 60000 => form706NAFiled`

Meaning:
- the model lets a nonresident not-a-citizen estate exceed the filing threshold without filing Form 706-NA
- this is the Form 706-NA gap: IRS guidance says executors must file Form 706-NA when U.S.-situated assets exceed the threshold, but the state machine allows the taxable-estate state to exist without the estate-tax return state

### 701. Form 706-NA timely extension failure

Model: `work/TaxForm706NATimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFile706NA`
3. `Pass706NAExtensionDeadline`
4. `FileForm4768`

Observed state:
- `nonresidentEstateNeedsExtension = TRUE`
- `form4768Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form4768FiledByDeadline = FALSE`

Expected invariant:
- `nonresidentEstateNeedsExtension /\ form4768Filed => form4768FiledByDeadline`

Meaning:
- the model lets a nonresident not-citizen estate need more time to file and then file Form 4768 after the original due date while still satisfying the extension-needed state
- this is a distinct Form 706-NA timing gap: IRS instructions say Form 4768 must be filed by the original due date for the applicable return, but the state machine does not encode that filing window

### 527. Form 709-NA nonresident gift tax return failure

Model: `work/TaxForm709NANonresidentGiftGap.tla`

Trace:
1. initial state
2. `MakeTaxableNRNCGift`

Observed state:
- `nrncGiftSubjectToUSGiftTax = TRUE`
- `form709NAFiled = FALSE`

Expected invariant:
- `nrncGiftSubjectToUSGiftTax => form709NAFiled`

Meaning:
- the model lets a nonresident not-a-citizen gift subject to U.S. gift tax exist without filing Form 709-NA
- this is the Form 709-NA gap: IRS guidance says NRNC donors must file Form 709-NA for gifts subject to U.S. gift tax, but the state machine allows the taxable-gift state to exist without the gift-tax-return state

### 698. Form 709-NA timely gift-tax return failure

Model: `work/TaxForm709NATimelyGiftTaxReturnGap.tla`

Trace:
1. initial state
2. `MakeTaxableNRNCGift`
3. `PassGiftTaxReturnDeadline`
4. `FileForm709NA`

Observed state:
- `nrncGiftSubjectToUSGiftTax = TRUE`
- `form709NAFiled = TRUE`
- `giftTaxReturnDeadlinePassed = TRUE`
- `form709NAFiledByDeadline = FALSE`

Expected invariant:
- `nrncGiftSubjectToUSGiftTax /\ form709NAFiled => form709NAFiledByDeadline`

Meaning:
- the model lets a nonresident not-citizen make a taxable gift and then file Form 709-NA after the annual gift-tax deadline while still satisfying the taxable-gift state
- this is a distinct Form 709-NA timing gap: IRS instructions say Form 709-NA is generally due on April 15 of the year after the gift was made, but the state machine does not encode that filing window

### 528. Form 1310 deceased taxpayer refund claim failure

Model: `work/TaxForm1310DeceasedTaxpayerRefundGap.tla`

Trace:
1. initial state
2. `ClaimRefundForDeceasedTaxpayer`

Observed state:
- `refundClaimedForDeceasedTaxpayer = TRUE`
- `form1310Filed = FALSE`

Expected invariant:
- `refundClaimedForDeceasedTaxpayer => form1310Filed`

Meaning:
- the model lets someone claim a refund for a deceased taxpayer without filing Form 1310
- this is the Form 1310 gap: IRS guidance says Form 1310 is used to claim a refund on behalf of a deceased taxpayer when the exception cases do not apply, but the state machine allows the refund-claim state to exist without the statement form state

### 529. Form 4768 section 6161 payment extension failure

Model: `work/TaxForm4768Section6161PaymentExtensionGap.tla`

Trace:
1. initial state
2. `RequestSection6161PaymentExtension`

Observed state:
- `paymentExtensionRequested = TRUE`
- `form4768Filed = FALSE`

Expected invariant:
- `paymentExtensionRequested => form4768Filed`

Meaning:
- the model lets an extension-to-pay state for estate or GST tax exist without filing Form 4768

### 703. Form 4768 timely estate-tax payment-extension failure

Model: `work/TaxForm4768TimelyEstatePaymentExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToPayEstateTax`
3. `PassPaymentExtensionDeadline`
4. `FileForm4768`

Observed state:
- `estateTaxPaymentNeedsExtension = TRUE`
- `form4768Filed = TRUE`
- `paymentExtensionDeadlinePassed = TRUE`
- `form4768FiledByDeadline = FALSE`

Expected invariant:
- `estateTaxPaymentNeedsExtension /\ form4768Filed => form4768FiledByDeadline`

Meaning:
- the model lets an estate tax payment-extension request be filed after the due date while still satisfying the payment-extension-needed state
- this is a distinct Form 4768 payment-extension gap: IRS instructions say a request for extension of time to pay must be received no later than the due date of the return, but the state machine does not encode that deadline

### 700. Form 706-A timely extension failure

Model: `work/TaxForm706ATimelyExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFile706A`
3. `Pass706AExtensionDeadline`
4. `FileForm4768`

Observed state:
- `qualifiedHeirTaxDue = TRUE`
- `form4768Filed = TRUE`
- `extensionDeadlinePassed = TRUE`
- `form4768FiledByDeadline = FALSE`

Expected invariant:
- `qualifiedHeirTaxDue /\ form4768Filed => form4768FiledByDeadline`

Meaning:
- the model lets a qualified heir owe the Form 706-A tax and then file Form 4768 after the filing deadline while still satisfying the tax-due state
- this is a distinct Form 706-A timing gap: IRS instructions say Form 4768 must be filed by the original due date for the applicable return, but the state machine does not encode that filing window

### 704. Form 706-A timely payment failure

Model: `work/TaxForm706ATimelyPaymentGap.tla`

Trace:
1. initial state
2. `NeedToPay706A`
3. `Pass706APaymentDeadline`
4. `FileAndPayForm706A`

Observed state:
- `qualifiedHeirTaxDue = TRUE`
- `form706AFiled = TRUE`
- `paymentDeadlinePassed = TRUE`
- `form706AFiledByDeadline = FALSE`

Expected invariant:
- `qualifiedHeirTaxDue /\ form706AFiled => form706AFiledByDeadline`

Meaning:
- the model lets a qualified heir owe Form 706-A tax and then file and pay after the 6-month payment deadline while still satisfying the tax-due state
- this is a distinct Form 706-A timing gap: IRS instructions say Form 706-A and the additional tax due are filed and paid within 6 months after the taxable disposition or cessation of qualified use, but the state machine does not encode that deadline

### 705. Form W-8IMY withholding-statement failure

Model: `work/TaxFormW8IMYWithholdingStatementGap.tla`

Trace:
1. initial state
2. `ReceiveIntermediaryPayment`
3. `ProvideW8IMY`
4. `ApplyReducedWithholding`

Observed state:
- `intermediaryPaymentReceived = TRUE`
- `formW8IMYProvided = TRUE`
- `reducedWithholdingApplied = TRUE`
- `withholdingStatementProvided = FALSE`

Expected invariant:
- `reducedWithholdingApplied => withholdingStatementProvided`

Meaning:
- the model lets an intermediary provide Form W-8IMY and still trigger reduced withholding without any withholding statement in place
- this is the Form W-8IMY withholding-statement gap: IRS instructions say the form is used with a required withholding statement for the payment chain, but the state machine allows reduced withholding to proceed without that statement layer

### 706. Form W-8IMY alternative-statement certificate failure

Model: `work/TaxFormW8IMYAlternativeStatementGap.tla`

Trace:
1. initial state
2. `ReceiveIntermediaryPayment`
3. `ProvideW8IMY`
4. `UseAlternativeWithholdingStatement`
5. `ApplyReducedWithholding`

Observed state:
- `intermediaryPaymentReceived = TRUE`
- `formW8IMYProvided = TRUE`
- `alternativeWithholdingStatementUsed = TRUE`
- `beneficialOwnerCertificatesProvided = FALSE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `reducedWithholdingApplied => beneficialOwnerCertificatesProvided`

Meaning:
- the model lets an intermediary use the alternative `W-8IMY` path and still trigger reduced withholding without any beneficial-owner certificates attached
- this is the Form W-8IMY alternative-statement gap: IRS instructions allow the alternate statement only when the intermediary is actually transmitting withholding certificates or other documentation for the beneficial owners, but the state machine lets the reduced-withholding path proceed with no such backing evidence

### 707. Form W-8IMY ownership-allocation failure

Model: `work/TaxFormW8IMYOwnershipAllocationGap.tla`

Trace:
1. initial state
2. `ReceiveIntermediaryPayment`
3. `ProvideW8IMY`
4. `UseAlternativeWithholdingStatement`
5. `SetMismatchedOwnershipAllocation`
6. `ApplyReducedWithholding`

Observed state:
- `intermediaryPaymentReceived = TRUE`
- `formW8IMYProvided = TRUE`
- `alternativeWithholdingStatementUsed = TRUE`
- `ownershipPercentTotal = 0`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `reducedWithholdingApplied => ownershipPercentTotal = 100`

Meaning:
- the model lets an intermediary move through the alternative `W-8IMY` path and apply reduced withholding without any consistent ownership allocation behind it
- this is the Form W-8IMY ownership-allocation gap: IRS instructions require the withholding statement to identify the persons and their ownership percentages, but the state machine allows the withholding benefit to proceed without a coherent split

### 708. Form 1099-DIV nominee allocation failure

Model: `work/TaxForm1099DIVNomineeAllocationGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDividend`
3. `FileOriginal1099DIV`
4. `FileCorrected1099DIV`

Observed state:
- `nomineeReceivedDividend = TRUE`
- `dividendBelongsToAnother = TRUE`
- `original1099DIVFiled = TRUE`
- `corrected1099DIVFiled = TRUE`
- `otherOwnerShareAllocated = FALSE`

Expected invariant:
- `corrected1099DIVFiled => otherOwnerShareAllocated`

Meaning:
- the model lets a nominee file and correct Form 1099-DIV without ever entering the allocable-share state for the actual owner
- this is the Form 1099-DIV nominee-allocation gap: IRS instructions say nominee recipients must file a Form 1099-DIV for each other owner showing the amount allocable to that owner, but the state machine allows the corrected-return path to stop before the allocation is made explicit

### 709. Form 1042-S U.S. nonexempt recipient classification failure

Model: `work/Tax1042SUSNonexemptRecipientClassificationGap.tla`

Trace:
1. initial state
2. `MakePaymentThroughNQI`

Observed state:
- `paymentRoutedThroughNQI = TRUE`
- `recipientIsUSNonexempt = TRUE`
- `form1042SFiled = FALSE`
- `form1099Filed = FALSE`

Expected invariant:
- `recipientIsUSNonexempt => form1099Filed`

Meaning:
- the model lets a payment routed through an intermediary become a U.S. nonexempt-recipient case without forcing the Form 1099 path
- this is the Form 1042-S classification gap: IRS instructions say income allocable to a U.S. nonexempt recipient should be reported on the appropriate Form 1099 rather than Form 1042-S, but the state machine still allows the intermediary-routed payment state to remain unclassified on the 1099 side

### 710. Form 1099-INT nominee allocation failure

Model: `work/TaxForm1099INTNomineeAllocationGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeInterest`
3. `FileOriginal1099INT`
4. `FileCorrected1099INT`

Observed state:
- `nomineeReceivedInterest = TRUE`
- `interestBelongsToAnother = TRUE`
- `original1099INTFiled = TRUE`
- `corrected1099INTFiled = TRUE`
- `otherOwnerInterestAllocated = FALSE`

Expected invariant:
- `corrected1099INTFiled => otherOwnerInterestAllocated`

Meaning:
- the model lets a nominee file and correct Form 1099-INT without ever entering the allocable-interest state for the actual owner
- this is the Form 1099-INT nominee-allocation gap: IRS nominee rules require the recipient to file a Form 1099-INT for each other owner showing the amounts allocable to that owner, but the state machine allows the corrected-return path to stop before the allocable-share split is explicit

### 723. Form 1099-INT nominee correction failure

Model: `work/TaxForm1099INTNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeInterest`
3. `FileOriginal1099INT`
4. `FileCorrected1099INT`

Observed state:
- `nomineeReceivedInterest = TRUE`
- `interestBelongsToAnother = TRUE`
- `original1099INTFiled = TRUE`
- `corrected1099INTFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099INTFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-INT without furnishing the other owner’s copy
- this is the Form 1099-INT nominee-correction gap: the repair path reaches the corrected filing, but the recipient-side delivery still never becomes mandatory

### 711. Form W-7 late information-return exception failure

Model: `work/TaxFormW7ITINLateExceptionGap.tla`

Trace:
1. initial state
2. `ExpireITIN`
3. `NeedFederalReturn`
4. `UseOnlyOnInfoReturns`

Observed state:
- `itinExpired = TRUE`
- `usedOnlyOnInfoReturns = TRUE`
- `federalReturnRequired = TRUE`
- `exceptionClearedRenewal = FALSE`

Expected invariant:
- `usedOnlyOnInfoReturns => ~federalReturnRequired`

Meaning:
- the model lets the information-return-only exception arrive after a renewal requirement has already been set, but it never forces the renewal requirement to clear
- this is the Form W-7 late-exception gap: IRS guidance says an expired ITIN used only on third-party information returns does not need renewal yet, and that exception should reset the renewal path even if it is recognized after the requirement was already active

### 712. Form W-8ECI non-ECI claim failure

Model: `work/TaxFormW8ECINonECIClaimGap.tla`

Trace:
1. initial state
2. `ProvideW8ECI`

Observed state:
- `incomeEffectivelyConnected = FALSE`
- `formW8ECIProvided = TRUE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `formW8ECIProvided => incomeEffectivelyConnected`

Meaning:
- the model lets a foreign person provide Form W-8ECI even though the underlying income is not effectively connected with a U.S. trade or business
- this is the Form W-8ECI non-ECI claim gap: IRS instructions say Form W-8ECI is only for income that is, or is deemed to be, effectively connected with a U.S. trade or business, but the state machine allows the claim form to exist without that predicate

### 713. Form W-8BEN change-in-circumstances failure

Model: `work/TaxFormW8BENChangeInCircumstancesGap.tla`

Trace:
1. initial state
2. `ProvideW8BEN`
3. `IncomeBecomesEffectivelyConnected`

Observed state:
- `incomeEffectivelyConnected = TRUE`
- `formW8BENProvided = TRUE`
- `formW8ECIProvided = FALSE`

Expected invariant:
- `incomeEffectivelyConnected => ~formW8BENProvided`

Meaning:
- the model lets a Form W-8BEN remain in force after the income becomes effectively connected
- this is the Form W-8BEN change-in-circumstances gap: IRS instructions say the form is no longer valid for income that becomes effectively connected, but the state machine lets the old certificate persist after the predicate changes

### 714. Form W-8IMY separate-withholding-agent failure

Model: `work/TaxFormW8IMYSeparateAgentGap.tla`

Trace:
1. initial state
2. `PayAgentA`

Observed state:
- `agentAReceivedPayment = TRUE`
- `agentBReceivedPayment = FALSE`
- `formW8IMYToAgentA = FALSE`
- `formW8IMYToAgentB = FALSE`

Expected invariant:
- `agentAReceivedPayment => formW8IMYToAgentA`

Meaning:
- the model lets a payment received by one withholding agent exist without a separate `W-8IMY` to that agent
- this is the Form W-8IMY separate-agent gap: IRS instructions say a separate Form W-8IMY must generally be submitted to each withholding agent from whom a payment is received, but the state machine allows the payment to land at one agent while the dedicated form for that agent is still absent

### 715. Form W-8BEN-E change-in-circumstances failure

Model: `work/TaxFormW8BENEChangeInCircumstancesGap.tla`

Trace:
1. initial state
2. `ProvideW8BENE`
3. `IncomeBecomesEffectivelyConnected`

Observed state:
- `incomeEffectivelyConnected = TRUE`
- `formW8BENEProvided = TRUE`
- `formW8ECIProvided = FALSE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `incomeEffectivelyConnected => ~formW8BENEProvided`

Meaning:
- the model lets a Form W-8BEN-E remain in force after the income becomes effectively connected
- this is the Form W-8BEN-E change-in-circumstances gap: IRS instructions say the form is no longer valid once the underlying income becomes effectively connected, but the state machine allows the original entity certificate to persist after the predicate change

### 716. Form W-8EXP change-in-circumstances failure

Model: `work/TaxFormW8EXPChangeInCircumstancesGap.tla`

Trace:
1. initial state
2. `ProvideW8EXP`
3. `StatusBecomesInvalid`

Observed state:
- `foreignOrganizationStatusValid = FALSE`
- `formW8EXPProvided = TRUE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `foreignOrganizationStatusValid = FALSE => ~formW8EXPProvided`

Meaning:
- the model lets a Form W-8EXP remain effective after the foreign-organization status it depended on becomes invalid
- this is the Form W-8EXP change-in-circumstances gap: IRS instructions say the form is no longer valid when a change in circumstances makes the information incorrect, but the state machine allows the stale certificate to persist after the status flips

### 717. Form W-8ECI partnership-allocable exception failure

Model: `work/TaxFormW8ECIPartnershipAllocableGap.tla`

Trace:
1. initial state
2. `ReceiveECIIncome`
3. `MarkAllocableThroughPartnership`
4. `ProvideW8ECI`

Observed state:
- `incomeEffectivelyConnected = TRUE`
- `allocableThroughPartnership = TRUE`
- `formW8ECIProvided = TRUE`
- `formW8BENProvided = FALSE`

Expected invariant:
- `allocableThroughPartnership => ~formW8ECIProvided`

Meaning:
- the model lets effectively connected income that is allocable through a partnership still flow into the `W-8ECI` certificate path
- this is the Form W-8ECI partnership-allocable exception gap: IRS instructions say the default `W-8ECI` rule does not apply when the income is allocable through a partnership, but the state machine still allows the `W-8ECI` path to be taken anyway

### 718. Form 8288-B transfer-notice failure

Model: `work/TaxForm8288BTransferNoticeGap.tla`

Trace:
1. initial state
2. `ApplyForWithholdingCertificate`
3. `TransferUSRPI`

Observed state:
- `withholdingCertificateAppliedFor = TRUE`
- `usrpiTransferred = TRUE`
- `transfereeNotified = FALSE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `usrpiTransferred /\ withholdingCertificateAppliedFor => transfereeNotified`

Meaning:
- the model lets a foreign USRPI transfer close after a withholding-certificate application has been filed, but it never forces the transferee-notification state
- this is the Form 8288-B transfer-notice gap: IRS instructions say the transferor must notify the transferee in writing that the certificate has been applied for on the day of or before the transfer, but the state machine allows the transfer to complete without that notice step

### 719. Form W-8BEN expiration failure

Model: `work/TaxFormW8BENExpirationGap.tla`

Trace:
1. initial state
2. `ProvideW8BEN`
3. `AdvanceTime` repeated until day 1095
4. `ApplyReducedWithholding`

Observed state:
- `daysSinceSignature = 1095`
- `formW8BENProvided = TRUE`
- `formW8BENExpired = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `formW8BENExpired => ~reducedWithholdingApplied`

Meaning:
- the model lets a W-8BEN remain usable for reduced withholding after the form’s general three-year validity window has expired
- this is the Form W-8BEN expiration gap: IRS instructions say the form generally expires at the end of the third succeeding calendar year unless a change in circumstances occurs earlier, but the state machine allows the stale form to keep driving withholding relief

### 720. Form W-8ECI expiration failure

Model: `work/TaxFormW8ECIExpirationGap.tla`

Trace:
1. initial state
2. `ProvideW8ECI`
3. `AdvanceTime` repeated until day 1095
4. `ApplyReducedWithholding`

Observed state:
- `daysSinceSignature = 1095`
- `formW8ECIProvided = TRUE`
- `formW8ECIExpired = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `formW8ECIExpired => ~reducedWithholdingApplied`

Meaning:
- the model lets a W-8ECI remain usable for reduced withholding after the form’s general three-year validity window has expired
- this is the Form W-8ECI expiration gap: IRS instructions say the form generally expires at the end of the third succeeding calendar year unless a change in circumstances occurs earlier, but the state machine allows the stale form to keep driving withholding relief

### 721. Form W-8IMY expiration failure

Model: `work/TaxFormW8IMYExpirationGap.tla`

Trace:
1. initial state
2. `ProvideW8IMY`
3. `AdvanceTime` repeated until day 1095
4. `ApplyReducedWithholding`

Observed state:
- `daysSinceSignature = 1095`
- `formW8IMYProvided = TRUE`
- `formW8IMYExpired = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `formW8IMYExpired => ~reducedWithholdingApplied`

Meaning:
- the model lets a W-8IMY remain usable for reduced withholding after the form’s general three-year validity window has expired
- this is the Form W-8IMY expiration gap: IRS instructions say the form generally expires at the end of the third succeeding calendar year unless a change in circumstances occurs earlier, but the state machine allows the stale intermediary certificate to keep driving withholding relief

### 722. Three-party cum-ex-style triple-claim failure

Model: `work/TaxCumExTripleClaimGap.tla`

Trace:
1. initial state
2. `TransferToB`
3. `DeclareDividend`
4. `TransferToC`
5. `PayDividend`
6. `ClaimRecordCredit`
7. `ClaimBeneficialOwnerCredit`
8. `ClaimCurrentCredit`

Observed state:
- `holder = "C"`
- `recordHolder = "B"`
- `beneficialOwner = "A"`
- `dividendPaid = TRUE`
- `recordCreditClaimed = TRUE`
- `beneficialOwnerCreditClaimed = TRUE`
- `currentCreditClaimed = TRUE`

Expected invariant:
- `~(recordCreditClaimed /\ beneficialOwnerCreditClaimed /\ currentCreditClaimed)`

Meaning:
- the model allows one dividend to support three distinct entitlement claims across the record-date holder, the beneficial owner, and the current holder
- this is the cum-ex-style triple-claim gap: the entitlement chain is not exclusive, so the same dividend event can be monetized by all three parties as the share moves through the chain

### 696. Form 4768 timely estate-tax extension failure

Model: `work/TaxForm4768TimelyEstateExtensionGap.tla`

Trace:
1. initial state
2. `NeedMoreTimeToFileEstateReturn`
3. `PassEstateExtensionDeadline`
4. `FileForm4768`

Observed state:
- `estateTaxReturnNeedsExtension = TRUE`
- `form4768Filed = TRUE`
- `estateTaxExtensionDeadlinePassed = TRUE`
- `form4768FiledByDeadline = FALSE`

Expected invariant:
- `estateTaxReturnNeedsExtension /\ form4768Filed => form4768FiledByDeadline`

Meaning:
- the model lets an estate-tax return need more time and then file Form 4768 after the original due date while still satisfying the extension-needed state
- this is a distinct Form 4768 timing gap: IRS instructions say the automatic 6-month estate-tax extension must be filed by the original due date of the applicable return, but the state machine does not encode that filing window
- this is the Form 4768 gap: IRS guidance says Form 4768 can be used to apply for an extension of time to pay estate or generation-skipping transfer tax under section 6161, but the state machine allows the payment-extension state to exist without the application form state

### 530. Form 8804 section 1446 return failure

Model: `work/TaxForm8804Section1446ReturnGap.tla`

Trace:
1. initial state
2. `AccrueSection1446Liability`

Observed state:
- `section1446LiabilityAccrued = TRUE`
- `form8804Filed = FALSE`

Expected invariant:
- `section1446LiabilityAccrued => form8804Filed`

Meaning:
- the model lets a partnership accrue section 1446 liability without filing Form 8804
- this is the Form 8804 gap: IRS guidance says Form 8804 reports the partnership's section 1446 liability and serves as the transmittal for Form(s) 8805, but the state machine allows the liability state to exist without the return state

### 531. Form 8804-W installment worksheet failure

Model: `work/TaxForm8804WInstallmentWorksheetGap.tla`

Trace:
1. initial state
2. `AccrueEstimatedSection1446TaxDue`

Observed state:
- `estimatedSection1446TaxDue = 500`
- `form8804WCompleted = FALSE`

Expected invariant:
- `estimatedSection1446TaxDue >= 500 => form8804WCompleted`

Meaning:
- the model lets a partnership reach the estimated section 1446 tax threshold without completing the Form 8804-W worksheet
- this is the Form 8804-W gap: IRS guidance says the worksheet is used to determine proper estimated section 1446 tax payments, but the state machine allows the threshold state to exist without the worksheet state

### 532. Form 8801 prior-year minimum tax credit failure

Model: `work/TaxForm8801MinimumTaxCreditGap.tla`

Trace:
1. initial state
2. `IncurPriorYearAMT`

Observed state:
- `priorYearAMTIncurred = TRUE`
- `form8801Attached = FALSE`

Expected invariant:
- `priorYearAMTIncurred => form8801Attached`

Meaning:
- the model lets a taxpayer have prior-year AMT without attaching Form 8801
- this is the Form 8801 gap: IRS guidance says eligible taxpayers should complete and attach Form 8801 to claim the minimum tax credit, but the state machine allows the credit-entitlement state to exist without the attachment state

### 533. Form 8802 residency certification failure

Model: `work/TaxForm8802ResidencyCertificationGap.tla`

Trace:
1. initial state
2. `RequestTreatyBenefitCertification`

Observed state:
- `treatyBenefitRequested = TRUE`
- `form8802Filed = FALSE`

Expected invariant:
- `treatyBenefitRequested => form8802Filed`

Meaning:
- the model lets a taxpayer seek residency certification for treaty benefits without filing Form 8802
- this is the Form 8802 gap: IRS guidance says Form 8802 is the request for Form 6166 residency certification, but the state machine allows the treaty-benefit request state to exist without the application state

### 534. Form 8858 Schedule M attachment failure

Model: `work/TaxForm8858ScheduleMAttachmentGap.tla`

Trace:
1. initial state
2. `CreateForeignBranchTransactions`

Observed state:
- `foreignBranchTransactionsExist = TRUE`
- `scheduleMAttached = FALSE`

Expected invariant:
- `foreignBranchTransactionsExist => scheduleMAttached`

Meaning:
- the model lets foreign branch or FDE transactions exist without attaching Schedule M to Form 8858
- this is the Form 8858 Schedule M gap: IRS instructions say Schedule M is used for transactions between the FDE/FB and related entities and is attached to Form 8858, but the state machine allows the transaction state to exist without the schedule state

### 535. Form 8838-P gain deferral contribution failure

Model: `work/TaxForm8838PGainDeferralGap.tla`

Trace:
1. initial state
2. `MakeSection721CGainDeferralContribution`

Observed state:
- `gainDeferralContributionMade = TRUE`
- `form8838PFiled = FALSE`

Expected invariant:
- `gainDeferralContributionMade => form8838PFiled`

Meaning:
- the model lets a section 721(c) gain deferral contribution exist without filing Form 8838-P
- this is the Form 8838-P gap: IRS guidance says a U.S. transferor must file Form 8838-P to apply the gain deferral method for section 721(c) property, but the state machine allows the gain-deferral state to exist without the filing state

### 536. Form 8851 Archer MSA reporting failure

Model: `work/TaxForm8851ArcherMSAReportingGap.tla`

Trace:
1. initial state
2. `CreateArcherMSATrusteeOrCustodian`

Observed state:
- `archerMsaTrusteeOrCustodianExists = TRUE`
- `form8851Filed = FALSE`

Expected invariant:
- `archerMsaTrusteeOrCustodianExists => form8851Filed`

Meaning:
- the model lets an Archer MSA trustee or custodian exist without filing Form 8851
- this is the Form 8851 gap: IRS guidance says trustees and custodians of Archer MSAs use Form 8851 to report account counts, but the state machine allows the trustee/custodian state to exist without the filing state

### 537. Form 8838 gain recognition agreement failure

Model: `work/TaxForm8838GainRecognitionAgreementGap.tla`

Trace:
1. initial state
2. `EnterGainRecognitionAgreement`

Observed state:
- `gainRecognitionAgreementEntered = TRUE`
- `form8838Filed = FALSE`

Expected invariant:
- `gainRecognitionAgreementEntered => form8838Filed`

Meaning:
- the model lets a section 367 gain recognition agreement exist without filing Form 8838
- this is the Form 8838 gap: IRS guidance says Form 8838 is used for gain recognition agreements under sections 367(a) and 367(e)(2), but the state machine allows the agreement state to exist without the filing state

### 538. Form 8883 section 338 asset allocation failure

Model: `work/TaxForm8883Section338AssetAllocationGap.tla`

Trace:
1. initial state
2. `MakeSection338Election`

Observed state:
- `section338ElectionMade = TRUE`
- `form8883Filed = FALSE`

Expected invariant:
- `section338ElectionMade => form8883Filed`

Meaning:
- the model lets a section 338 election exist without filing Form 8883
- this is the Form 8883 gap: IRS guidance says Form 8883 reports asset allocation information for section 338 transactions, but the state machine allows the election state to exist without the attached reporting state

### 539. Form 8910 alternative motor vehicle credit failure

Model: `work/TaxForm8910AlternativeMotorVehicleGap.tla`

Trace:
1. initial state
2. `PlaceAlternativeMotorVehicleInService`

Observed state:
- `alternativeMotorVehiclePlacedInService = TRUE`
- `form8910Filed = FALSE`

Expected invariant:
- `alternativeMotorVehiclePlacedInService => form8910Filed`

Meaning:
- the model lets a taxpayer place an alternative motor vehicle in service without filing Form 8910
- this is the Form 8910 gap: IRS guidance says Form 8910 is used to figure the alternative motor vehicle credit, but the state machine allows the qualifying-vehicle state to exist without the filing state

### 540. Form 8894 partnership election revocation failure

Model: `work/TaxForm8894PartnershipElectionRevocationGap.tla`

Trace:
1. initial state
2. `RequestPartnershipElectionRevocation`

Observed state:
- `partnershipRevocationRequested = TRUE`
- `form8894Filed = FALSE`

Expected invariant:
- `partnershipRevocationRequested => form8894Filed`

Meaning:
- the model lets a partnership request revocation of its election without filing Form 8894
- this is the Form 8894 gap: IRS guidance says Form 8894 was used to request revocation of the old partnership-level tax treatment election, but the state machine allows the revocation-request state to exist without the filing state

### 541. Form 8908 energy efficient home credit failure

Model: `work/TaxForm8908EnergyEfficientHomeGap.tla`

Trace:
1. initial state
2. `SellQualifiedNewEnergyEfficientHome`

Observed state:
- `qualifiedNewEnergyEfficientHomeSold = TRUE`
- `form8908Filed = FALSE`

Expected invariant:
- `qualifiedNewEnergyEfficientHomeSold => form8908Filed`

Meaning:
- the model lets a qualified new energy efficient home be sold or leased without filing Form 8908
- this is the Form 8908 gap: IRS guidance says eligible contractors use Form 8908 to claim the energy efficient home credit, but the state machine allows the qualifying-home state to exist without the filing state

### 542. Form 8906 distilled spirits credit failure

Model: `work/TaxForm8906DistilledSpiritsCreditGap.tla`

Trace:
1. initial state
2. `ClaimDistilledSpiritsCredit`

Observed state:
- `distilledSpiritsCreditClaimed = TRUE`
- `form8906Filed = FALSE`

Expected invariant:
- `distilledSpiritsCreditClaimed => form8906Filed`

Meaning:
- the model lets a taxpayer claim the distilled spirits credit without filing Form 8906
- this is the Form 8906 gap: IRS guidance says Form 8906 is used to claim the distilled spirits credit, but the state machine allows the credit-claim state to exist without the filing state

### 543. Form 8923 mine rescue training credit failure

Model: `work/TaxForm8923MineRescueTrainingGap.tla`

Trace:
1. initial state
2. `IncurMineRescueTrainingCosts`

Observed state:
- `mineRescueTrainingCostsIncurred = TRUE`
- `form8923Filed = FALSE`

Expected invariant:
- `mineRescueTrainingCostsIncurred => form8923Filed`

Meaning:
- the model lets mine rescue team training costs exist without filing Form 8923
- this is the Form 8923 gap: IRS guidance says taxpayers use Form 8923 to claim the mine rescue team training credit, but the state machine allows the credit-cost state to exist without the filing state

### 544. Form 8922 third-party sick pay recap failure

Model: `work/TaxForm8922ThirdPartySickPayRecapGap.tla`

Trace:
1. initial state
2. `PayThirdPartySickPay`

Observed state:
- `thirdPartySickPayPaid = TRUE`
- `form8922Filed = FALSE`

Expected invariant:
- `thirdPartySickPayPaid => form8922Filed`

Meaning:
- the model lets third-party sick pay exist without filing Form 8922
- this is the Form 8922 gap: IRS guidance says Form 8922 is filed to reconcile employment tax returns with Forms W-2 when third-party sick pay is paid, but the state machine allows the sick-pay state to exist without the recap form state

### 545. Form 8926 disqualified interest deduction failure

Model: `work/TaxForm8926DisqualifiedInterestGap.tla`

Trace:
1. initial state
2. `PayDisqualifiedInterest`

Observed state:
- `disqualifiedInterestPaid = TRUE`
- `form8926Filed = FALSE`

Expected invariant:
- `disqualifiedInterestPaid => form8926Filed`

Meaning:
- the model lets a corporation pay disqualified interest without filing Form 8926
- this is the Form 8926 gap: IRS instructions say corporations must file Form 8926 if they paid or accrued disqualified interest subject to the section 163(j) limitation, but the state machine allows the interest state to exist without the filing state

### 546. Form 8927 qualified investment entity determination failure

Model: `work/TaxForm8927QualifiedInvestmentEntityGap.tla`

Trace:
1. initial state
2. `RequestQIESection860e4Determination`

Observed state:
- `qieSection860e4DeterminationRequested = TRUE`
- `form8927Filed = FALSE`

Expected invariant:
- `qieSection860e4DeterminationRequested => form8927Filed`

Meaning:
- the model lets a qualified investment entity seek a section 860(e)(4) determination without filing Form 8927
- this is the Form 8927 gap: IRS guidance says Form 8927 is filed to make the determination and establish the determination date, but the state machine allows the determination-request state to exist without the filing state

### 547. Form 8931 agricultural chemicals security credit failure

Model: `work/TaxForm8931AgriculturalChemicalsSecurityGap.tla`

Trace:
1. initial state
2. `IncurAgriculturalChemicalsSecurityCosts`

Observed state:
- `agriculturalChemicalsSecurityCostsIncurred = TRUE`
- `form8931Filed = FALSE`

Expected invariant:
- `agriculturalChemicalsSecurityCostsIncurred => form8931Filed`

Meaning:
- the model lets qualified agricultural chemicals security costs exist without filing Form 8931
- this is the Form 8931 gap: IRS guidance says eligible agricultural businesses use Form 8931 to claim the credit for qualified agricultural chemicals security costs, but the state machine allows the cost state to exist without the filing state

### 548. Form 8942 qualified therapeutic discovery project certification failure

Model: `work/TaxForm8942QualifiedTherapeuticDiscoveryProjectGap.tla`

Trace:
1. initial state
2. `RequestQTDPCertification`

Observed state:
- `qtdpCertificationRequested = TRUE`
- `form8942Filed = FALSE`

Expected invariant:
- `qtdpCertificationRequested => form8942Filed`

Meaning:
- the model lets a taxpayer request QTDP certification without filing Form 8942
- this is the Form 8942 gap: IRS guidance says Form 8942 is the application for certification of qualified investments under the QTDP program, but the state machine allows the certification-request state to exist without the application state

### 549. Form 8930 disaster recovery distribution repayment failure

Model: `work/TaxForm8930DisasterRecoveryDistributionRepaymentGap.tla`

Trace:
1. initial state
2. `MakeDisasterRecoveryDistributionRepayment`

Observed state:
- `disasterRecoveryDistributionRepaymentMade = TRUE`
- `form8930Filed = FALSE`

Expected invariant:
- `disasterRecoveryDistributionRepaymentMade => form8930Filed`

Meaning:
- the model lets a qualified disaster recovery assistance repayment exist without filing Form 8930
- this is the Form 8930 gap: IRS guidance says Form 8930 is used to report repayments of qualified disaster recovery assistance distributions, but the state machine allows the repayment state to exist without the filing state

### 550. Form 8932 differential wage payment credit failure

Model: `work/TaxForm8932DifferentialWageCreditGap.tla`

Trace:
1. initial state
2. `MakeDifferentialWagePayments`

Observed state:
- `differentialWagePaymentsMade = TRUE`
- `form8932Filed = FALSE`

Expected invariant:
- `differentialWagePaymentsMade => form8932Filed`

Meaning:
- the model lets an employer make differential wage payments without filing Form 8932
- this is the Form 8932 gap: IRS guidance says Form 8932 is used to claim the credit for employer differential wage payments, but the state machine allows the payment state to exist without the filing state

### 551. Form 8957 FATCA registration failure

Model: `work/TaxForm8957FATCARegistrationGap.tla`

Trace:
1. initial state
2. `RequireFATCARegistration`

Observed state:
- `fatcaRegistrationRequired = TRUE`
- `form8957Filed = FALSE`

Expected invariant:
- `fatcaRegistrationRequired => form8957Filed`

Meaning:
- the model lets a financial institution or direct-reporting NFFE require FATCA registration without filing Form 8957
- this is the Form 8957 gap: IRS guidance says Form 8957 is used by FIs and direct-reporting NFFEs to register themselves and branches, but the state machine allows the registration-required state to exist without the filing state

### 552. Form 8950 voluntary correction program submission failure

Model: `work/TaxForm8950VCPSubmissionGap.tla`

Trace:
1. initial state
2. `RequestVCPSubmission`

Observed state:
- `vcpSubmissionRequested = TRUE`
- `form8950Filed = FALSE`

Expected invariant:
- `vcpSubmissionRequested => form8950Filed`

Meaning:
- the model lets a voluntary correction program submission be requested without filing Form 8950
- this is the Form 8950 gap: IRS guidance says Form 8950 is part of a VCP submission for correcting retirement plan failures, but the state machine allows the submission-request state to exist without the filing state

### 553. Form 8964-TRA section 987 transition information failure

Model: `work/TaxForm8964TRASection987TransitionGap.tla`

Trace:
1. initial state
2. `RequireSection987TransitionInformation`

Observed state:
- `section987TransitionInfoRequired = TRUE`
- `form8964TRAFiled = FALSE`

Expected invariant:
- `section987TransitionInfoRequired => form8964TRAFiled`

Meaning:
- the model lets section 987 transition information be required without filing Form 8964-TRA
- this is the Form 8964-TRA gap: IRS guidance says Form 8964-TRA is used to report section 987 transition information, but the state machine allows the transition-information state to exist without the filing state

### 554. Form 8964-ELE section 987 election failure

Model: `work/TaxForm8964ELESection987ElectionGap.tla`

Trace:
1. initial state
2. `MakeSection987Election`

Observed state:
- `section987ElectionMade = TRUE`
- `form8964ELEFiled = FALSE`

Expected invariant:
- `section987ElectionMade => form8964ELEFiled`

Meaning:
- the model lets a section 987 election be made without filing Form 8964-ELE
- this is the Form 8964-ELE gap: IRS guidance says Form 8964-ELE is used to make or revoke elections under the section 987 regulations, but the state machine allows the election state to exist without the filing state

### 555. Form 8953 IRA contribution documentation failure

Model: `work/TaxForm8953DocumentTypeIRAContributionGap.tla`

Trace:
1. initial state
2. `ReportIRAContribution`

Observed state:
- `iraContributionReported = TRUE`
- `form8953Filed = FALSE`

Expected invariant:
- `iraContributionReported => form8953Filed`

Meaning:
- the model lets an IRA contribution be reported without filing Form 8953
- this is the Form 8953 gap: IRS guidance says Form 8953 is used by specific taxpayers making certain IRA-related elections/reportings, but the state machine allows the reporting state to exist without the filing state

### 556. Form 8950 VCP correction request failure

Model: `work/TaxForm8950VCPRequestGap.tla`

Trace:
1. initial state
2. `RequestVCPCorrection`

Observed state:
- `vcpCorrectionRequested = TRUE`
- `form8950Filed = FALSE`

Expected invariant:
- `vcpCorrectionRequested => form8950Filed`

Meaning:
- the model lets a voluntary correction program correction be requested without filing Form 8950
- this is the Form 8950 gap: IRS guidance says Form 8950 is filed as part of a VCP submission, but the state machine allows the correction-request state to exist without the filing state

### 557. Form 8697 look-back interest filing failure

Model: `work/TaxForm8697LookbackInterestGap.tla`

Trace:
1. initial state
2. `CompleteContractWithLookbackAdjustment`

Observed state:
- `lookbackAdjustmentNeeded = TRUE`
- `form8697Filed = FALSE`

Expected invariant:
- `lookbackAdjustmentNeeded => form8697Filed`

Meaning:
- the model lets a completed long-term contract create a look-back adjustment without filing Form 8697
- this is the Form 8697 gap: IRS guidance says the form is used to figure interest due or to be refunded under the look-back method for completed long-term contracts, but the state machine allows the adjustment state to exist without the filing state

### 558. Form 8976 section 501(c)(4) notice fee failure

Model: `work/TaxForm8976C4NoticeFeeGap.tla`

Trace:
1. initial state
2. `SubmitForm8976WithoutFee`

Observed state:
- `form8976Submitted = TRUE`
- `feeSubmitted = FALSE`

Expected invariant:
- `form8976Submitted => feeSubmitted`

Meaning:
- the model lets a section 501(c)(4) notice be submitted without the required fee
- this is the Form 8976 gap: IRS guidance says the notice must be submitted electronically and the $50 fee must accompany the registration, but the state machine allows the submission state to exist without the fee state

### 559. Form 8980 partnership modification request failure

Model: `work/TaxForm8980BbaModificationGap.tla`

Trace:
1. initial state
2. `RequestModification`

Observed state:
- `modificationRequested = TRUE`
- `form8980Filed = FALSE`

Expected invariant:
- `modificationRequested => form8980Filed`

Meaning:
- the model lets a partnership request a modification of an imputed underpayment without filing Form 8980
- this is the Form 8980 gap: IRS guidance says Form 8980 is used by partnerships to request an adjustment under section 6225(c), but the state machine allows the request state to exist without the filing state

### 560. Form 8995-A QBI deduction filing failure

Model: `work/TaxForm8995AQBIDeductionGap.tla`

Trace:
1. initial state
2. `ComputeQBIDeduction`

Observed state:
- `qbiDeductionComputed = TRUE`
- `form8995AFiled = FALSE`

Expected invariant:
- `qbiDeductionComputed => form8995AFiled`

Meaning:
- the model lets a taxpayer compute the qualified business income deduction without filing Form 8995-A
- this is the Form 8995-A gap: IRS guidance says Form 8995-A is used to figure the deduction, but the state machine allows the deduction-computation state to exist without the filing state

### 561. Form 8898 territorial residence notice failure

Model: `work/TaxForm8898TerritoryResidenceGap.tla`

Trace:
1. initial state
2. `ChangeTerritoryResidence`

Observed state:
- `territoryResidenceChanged = TRUE`
- `incomeOverThreshold = TRUE`
- `form8898Filed = FALSE`

Expected invariant:
- `(territoryResidenceChanged /\ incomeOverThreshold) => form8898Filed`

Meaning:
- the model lets a taxpayer become or cease to be a bona fide resident of a U.S. territory without filing Form 8898
- this is the Form 8898 gap: IRS guidance says the form is used to notify the IRS of that residence change when the gross-income threshold is met, but the state machine allows the residence-change state to exist without the filing state

### 562. Form 8979 partnership representative designation failure

Model: `work/TaxForm8979PartnershipRepresentativeGap.tla`

Trace:
1. initial state
2. `DesignatePartnershipRepresentative`

Observed state:
- `partnershipRepresentativeDesignated = TRUE`
- `form8979Filed = FALSE`

Expected invariant:
- `partnershipRepresentativeDesignated => form8979Filed`

Meaning:
- the model lets a partnership designate a partnership representative without filing Form 8979
- this is the Form 8979 gap: IRS guidance says Form 8979 is used to designate or resign a partnership representative, but the state machine allows the designation state to exist without the filing state

### 563. Form 9000 alternative media election failure

Model: `work/TaxForm9000AlternativeMediaGap.tla`

Trace:
1. initial state
2. `MakeAlternativeMediaElection`

Observed state:
- `alternativeMediaElectionMade = TRUE`
- `form9000Filed = FALSE`

Expected invariant:
- `alternativeMediaElectionMade => form9000Filed`

Meaning:
- the model lets a taxpayer elect alternative media for IRS communications without filing Form 9000
- this is the Form 9000 gap: IRS guidance says Form 9000 is used to elect accessible communications formats, but the state machine allows the election state to exist without the filing state

### 564. Form 911 TAS assistance request failure

Model: `work/TaxForm911TASAssistanceGap.tla`

Trace:
1. initial state
2. `RequestTASAssistance`

Observed state:
- `tasAssistanceRequested = TRUE`
- `form911Filed = FALSE`

Expected invariant:
- `tasAssistanceRequested => form911Filed`

Meaning:
- the model lets a taxpayer request Taxpayer Advocate Service assistance without filing Form 911
- this is the Form 911 gap: IRS guidance says taxpayers can submit Form 911 to request TAS help, but the state machine allows the request state to exist without the filing state

### 565. Form 843 refund or abatement claim failure

Model: `work/TaxForm843RefundAbatementGap.tla`

Trace:
1. initial state
2. `ClaimRefundOrAbatement`

Observed state:
- `refundOrAbatementClaimed = TRUE`
- `form843Filed = FALSE`

Expected invariant:
- `refundOrAbatementClaimed => form843Filed`

Meaning:
- the model lets a taxpayer claim a refund or request an abatement without filing Form 843
- this is the Form 843 gap: IRS guidance says Form 843 is used to claim a refund or request an abatement of certain taxes, interest, penalties, fees, and additions to tax, but the state machine allows the claim state to exist without the filing state

### 566. Form 1045 tentative refund claim failure

Model: `work/TaxForm1045TentativeRefundGap.tla`

Trace:
1. initial state
2. `ClaimTentativeRefund`

Observed state:
- `tentativeRefundClaimed = TRUE`
- `form1045Filed = FALSE`

Expected invariant:
- `tentativeRefundClaimed => form1045Filed`

Meaning:
- the model lets a taxpayer claim a tentative refund without filing Form 1045
- this is the Form 1045 gap: IRS guidance says Form 1045 is used for an application for tentative refund for individuals, estates, or trusts, but the state machine allows the claim state to exist without the filing state

### 567. Form 1139 corporate tentative refund claim failure

Model: `work/TaxForm1139CorporateTentativeRefundGap.tla`

Trace:
1. initial state
2. `ClaimCorporateTentativeRefund`

Observed state:
- `corporateTentativeRefundClaimed = TRUE`
- `form1139Filed = FALSE`

Expected invariant:
- `corporateTentativeRefundClaimed => form1139Filed`

Meaning:
- the model lets a corporation claim a tentative refund without filing Form 1139
- this is the Form 1139 gap: IRS guidance says Form 1139 is used by corporations to apply for a quick/tentative refund, but the state machine allows the claim state to exist without the filing state

### 568. Form 4506-T transcript request failure

Model: `work/TaxForm4506TTranscriptRequestGap.tla`

Trace:
1. initial state
2. `RequestTranscript`

Observed state:
- `transcriptRequested = TRUE`
- `form4506TFiled = FALSE`

Expected invariant:
- `transcriptRequested => form4506TFiled`

Meaning:
- the model lets a taxpayer request a transcript without filing Form 4506-T
- this is the Form 4506-T gap: IRS guidance says Form 4506-T is used to request transcripts and related return information, but the state machine allows the request state to exist without the filing state

### 569. Form 8275 disclosure statement failure

Model: `work/TaxForm8275DisclosureGap.tla`

Trace:
1. initial state
2. `DisclosePosition`

Observed state:
- `positionDisclosed = TRUE`
- `form8275Filed = FALSE`

Expected invariant:
- `positionDisclosed => form8275Filed`

Meaning:
- the model lets a taxpayer disclose a tax position without filing Form 8275
- this is the Form 8275 gap: IRS guidance says Form 8275 is used to disclose items or positions taken on a return, but the state machine allows the disclosure state to exist without the filing state

### 570. Form 8275-R regulation disclosure failure

Model: `work/TaxForm8275RRegulationDisclosureGap.tla`

Trace:
1. initial state
2. `DiscloseRegulationPosition`

Observed state:
- `regulationPositionDisclosed = TRUE`
- `form8275RFiled = FALSE`

Expected invariant:
- `regulationPositionDisclosed => form8275RFiled`

Meaning:
- the model lets a taxpayer disclose a position contrary to a regulation without filing Form 8275-R
- this is the Form 8275-R gap: IRS guidance says the form is used to disclose positions contrary to regulations, but the state machine allows the disclosure state to exist without the filing state

### 571. Form 4852 substitute statement failure

Model: `work/TaxForm4852SubstituteStatementGap.tla`

Trace:
1. initial state
2. `LackOriginalStatement`

Observed state:
- `originalStatementMissing = TRUE`
- `form4852Filed = FALSE`

Expected invariant:
- `originalStatementMissing => form4852Filed`

Meaning:
- the model lets a taxpayer lack a required W-2 or 1099-R statement without filing Form 4852
- this is the Form 4852 gap: IRS guidance says Form 4852 is a substitute when the original wage or distribution statement is missing or incorrect, but the state machine allows the missing-statement state to exist without the filing state

### 572. Form 4506-B exempt organization copy request failure

Model: `work/TaxForm4506BExemptOrgCopyGap.tla`

Trace:
1. initial state
2. `RequestExemptOrgCopy`

Observed state:
- `exemptOrgCopyRequested = TRUE`
- `form4506BFiled = FALSE`

Expected invariant:
- `exemptOrgCopyRequested => form4506BFiled`

Meaning:
- the model lets a requester ask for an exempt organization application or letter copy without filing Form 4506-B
- this is the Form 4506-B gap: IRS guidance says Form 4506-B is used to request copies of exempt organization applications or letters, but the state machine allows the request state to exist without the filing state

### 573. Form 4506-A exempt or political organization copy request failure

Model: `work/TaxForm4506AExemptPoliticalCopyGap.tla`

Trace:
1. initial state
2. `RequestExemptPoliticalCopy`

Observed state:
- `exemptPoliticalCopyRequested = TRUE`
- `form4506AFiled = FALSE`

Expected invariant:
- `exemptPoliticalCopyRequested => form4506AFiled`

Meaning:
- the model lets a requester ask for a copy of an exempt or political organization form without filing Form 4506-A
- this is the Form 4506-A gap: IRS guidance says Form 4506-A is used to request public inspection or copies of exempt or political organization IRS forms, but the state machine allows the request state to exist without the filing state

### 574. Form 4506-F fraudulent return copy request failure

Model: `work/TaxForm4506FFraudulentReturnCopyGap.tla`

Trace:
1. initial state
2. `NeedFraudulentReturnCopy`

Observed state:
- `fraudulentReturnRequestNeeded = TRUE`
- `form4506FFiled = FALSE`

Expected invariant:
- `fraudulentReturnRequestNeeded => form4506FFiled`

Meaning:
- the model lets an identity-theft victim need a copy of a fraudulent return without filing Form 4506-F
- this is the Form 4506-F gap: IRS guidance says Form 4506-F is used to request copies of fraudulent tax returns, but the state machine allows the request state to exist without the filing state

### 575. Form 4506-C IVES transcript request failure

Model: `work/TaxForm4506CIVESRequestGap.tla`

Trace:
1. initial state
2. `RequestIVESTranscript`

Observed state:
- `ivesTranscriptRequested = TRUE`
- `form4506CFiled = FALSE`

Expected invariant:
- `ivesTranscriptRequested => form4506CFiled`

Meaning:
- the model lets an IVES transcript request exist without filing Form 4506-C
- this is the Form 4506-C gap: IRS guidance says Form 4506-C is used to request transcript information through an authorized IVES participant, but the state machine allows the request state to exist without the filing state

### 576. Form 4506-T-EZ short transcript request failure

Model: `work/TaxForm4506TEZTranscriptRequestGap.tla`

Trace:
1. initial state
2. `RequestShortTranscript`

Observed state:
- `shortTranscriptRequested = TRUE`
- `form4506TEZFiled = FALSE`

Expected invariant:
- `shortTranscriptRequested => form4506TEZFiled`

Meaning:
- the model lets a taxpayer request a short transcript without filing Form 4506-T-EZ
- this is the Form 4506-T-EZ gap: IRS guidance says Form 4506-T-EZ is used to request a short transcript, but the state machine allows the request state to exist without the filing state

### 577. Form 1040-C departing alien clearance failure

Model: `work/TaxForm1040CDepartingAlienGap.tla`

Trace:
1. initial state
2. `NeedDepartureClearance`

Observed state:
- `departureClearanceNeeded = TRUE`
- `form1040CFiled = FALSE`

Expected invariant:
- `departureClearanceNeeded => form1040CFiled`

Meaning:
- the model lets a departing alien need clearance to leave the United States without filing Form 1040-C
- this is the Form 1040-C gap: IRS guidance says Form 1040-C is used to report expected income and pay the tax before departure, but the state machine allows the clearance-needed state to exist without the filing state

### 578. Form 2063 departing alien statement failure

Model: `work/TaxForm2063DepartingAlienStatementGap.tla`

Trace:
1. initial state
2. `NeedDepartureCertification`

Observed state:
- `departureCertificationNeeded = TRUE`
- `form2063Filed = FALSE`

Expected invariant:
- `departureCertificationNeeded => form2063Filed`

Meaning:
- the model lets a departing alien need certification that U.S. income tax obligations are satisfied without filing Form 2063
- this is the Form 2063 gap: IRS guidance says Form 2063 is used to request IRS certification for certain departing aliens, but the state machine allows the certification-needed state to exist without the filing state

### 579. Form 1040-X amended return failure

Model: `work/TaxForm1040XAmendedReturnGap.tla`

Trace:
1. initial state
2. `DiscoverReturnError`

Observed state:
- `returnErrorDiscovered = TRUE`
- `form1040XFiled = FALSE`

Expected invariant:
- `returnErrorDiscovered => form1040XFiled`

Meaning:
- the model lets a taxpayer discover an error on a filed return without filing Form 1040-X
- this is the Form 1040-X gap: IRS guidance says Form 1040-X is used to amend a tax return when you need to correct income, deductions, credits, or filing status, but the state machine allows the error-discovered state to exist without the filing state

### 691. Form 1040-X timely amended-return failure

Model: `work/TaxForm1040XTimelyAmendedReturnGap.tla`

Trace:
1. initial state
2. `DiscoverReturnError`
3. `PassAmendmentDeadline`
4. `FileForm1040X`

Observed state:
- `returnErrorDiscovered = TRUE`
- `form1040XFiled = TRUE`
- `amendmentDeadlinePassed = TRUE`
- `form1040XFiledByDeadline = FALSE`

Expected invariant:
- `returnErrorDiscovered /\ form1040XFiled => form1040XFiledByDeadline`

Meaning:
- the model lets a taxpayer discover a return error and file Form 1040-X after the amendment window has already closed
- this is a distinct Form 1040-X timing gap: IRS instructions generally require filing within 3 years of the original return or 2 years after tax payment, whichever is later, but the state machine does not encode that filing window

### 580. Form 1040-NR nonresident return failure

Model: `work/TaxForm1040NRNonresidentReturnGap.tla`

Trace:
1. initial state
2. `EngageUSTradeOrBusiness`

Observed state:
- `nonresidentUSTradeOrBusiness = TRUE`
- `form1040NRFiled = FALSE`

Expected invariant:
- `nonresidentUSTradeOrBusiness => form1040NRFiled`

Meaning:
- the model lets a nonresident alien engage in a U.S. trade or business without filing Form 1040-NR
- this is the Form 1040-NR gap: IRS guidance says Form 1040-NR is used by nonresident aliens engaged in a U.S. trade or business, but the state machine allows the engagement state to exist without the filing state

### 581. Form 1040-ES (NR) estimated tax failure

Model: `work/TaxForm1040ESNREstimatedTaxGap.tla`

Trace:
1. initial state
2. `NeedEstimatedTaxPayment`

Observed state:
- `estimatedTaxDue = TRUE`
- `form1040ESNRFiled = FALSE`

Expected invariant:
- `estimatedTaxDue => form1040ESNRFiled`

Meaning:
- the model lets a nonresident alien owe estimated tax without filing Form 1040-ES (NR)
- this is the Form 1040-ES (NR) gap: IRS guidance says the form is used for estimated tax by nonresident alien individuals, but the state machine allows the estimated-tax state to exist without the filing state

### 694. Form 1040-ES (NR) timely estimated-tax payment failure

Model: `work/TaxForm1040ESNRTimelyPaymentGap.tla`

Trace:
1. initial state
2. `NeedEstimatedTaxPayment`
3. `PassEstimatedTaxDeadline`
4. `FileForm1040ESNR`

Observed state:
- `estimatedTaxDue = TRUE`
- `form1040ESNRFiled = TRUE`
- `estimatedTaxDeadlinePassed = TRUE`
- `form1040ESNRFiledByDeadline = FALSE`

Expected invariant:
- `estimatedTaxDue /\ form1040ESNRFiled => form1040ESNRFiledByDeadline`

Meaning:
- the model lets a nonresident alien owe estimated tax and file Form 1040-ES(NR) after the payment deadline while still satisfying the estimated-tax path
- this is a distinct Form 1040-ES(NR) timing gap: IRS guidance sets quarterly due dates for estimated-tax payments, but the state machine does not encode those deadlines

### 582. Form 1120-F foreign corporation return failure

Model: `work/TaxForm1120FForeignCorporationGap.tla`

Trace:
1. initial state
2. `HaveUSTaxableIncome`

Observed state:
- `foreignCorporationHasUSTaxableIncome = TRUE`
- `form1120FFiled = FALSE`

Expected invariant:
- `foreignCorporationHasUSTaxableIncome => form1120FFiled`

Meaning:
- the model lets a foreign corporation have U.S. taxable income without filing Form 1120-F
- this is the Form 1120-F gap: IRS guidance says foreign corporations with U.S.-connected income use Form 1120-F, but the state machine allows the income state to exist without the filing state

### 583. Form 1040-V payment voucher failure

Model: `work/TaxForm1040VPaymentVoucherGap.tla`

Trace:
1. initial state
2. `NeedPaymentVoucher`

Observed state:
- `returnPaymentDue = TRUE`
- `form1040VFiled = FALSE`

Expected invariant:
- `returnPaymentDue => form1040VFiled`

Meaning:
- the model lets a taxpayer owe a payment with a Form 1040 return without filing Form 1040-V
- this is the Form 1040-V gap: IRS guidance says Form 1040-V is used as a payment voucher for individuals, but the state machine allows the payment-due state to exist without the voucher state

### 584. Form 2210-F farmer and fisherman underpayment failure

Model: `work/TaxForm2210FFarmerFishermanGap.tla`

Trace:
1. initial state
2. `NeedForm2210F`

Observed state:
- `farmerOrFishermanUnderpaymentRuleApplies = TRUE`
- `form2210FFiled = FALSE`

Expected invariant:
- `farmerOrFishermanUnderpaymentRuleApplies => form2210FFiled`

Meaning:
- the model lets a farmer or fisherman underpayment exception apply without filing Form 2210-F
- this is the Form 2210-F gap: IRS guidance says Form 2210-F is used by farmers and fishermen for estimated-tax underpayment calculations, but the state machine allows the rule-applicable state to exist without the filing state

### 585. Form 4562 depreciation and amortization failure

Model: `work/TaxForm4562DepreciationGap.tla`

Trace:
1. initial state
2. `PlacePropertyInService`

Observed state:
- `propertyPlacedInService = TRUE`
- `form4562Filed = FALSE`

Expected invariant:
- `propertyPlacedInService => form4562Filed`

Meaning:
- the model lets a taxpayer place property in service without filing Form 4562
- this is the Form 4562 gap: IRS guidance says Form 4562 is used to elect section 179 expensing and report depreciation/amortization, but the state machine allows the property-in-service state to exist without the form state

### 586. Form 6252 installment sale reporting failure

Model: `work/TaxForm6252InstallmentSaleGap.tla`

Trace:
1. initial state
2. `CreateInstallmentSale`

Observed state:
- `installmentSaleExists = TRUE`
- `form6252Filed = FALSE`

Expected invariant:
- `installmentSaleExists => form6252Filed`

Meaning:
- the model lets an installment sale exist without filing Form 6252
- this is the Form 6252 gap: IRS guidance says Form 6252 is used to report installment sale income, but the state machine allows the installment-sale state to exist without the filing state

### 587. Form 4684 casualty and theft reporting failure

Model: `work/TaxForm4684CasualtyAndTheftGap.tla`

Trace:
1. initial state
2. `OccurCasualtyOrTheft`

Observed state:
- `casualtyOrTheftOccurred = TRUE`
- `form4684Filed = FALSE`

Expected invariant:
- `casualtyOrTheftOccurred => form4684Filed`

Meaning:
- the model lets a casualty or theft occur without filing Form 4684
- this is the Form 4684 gap: IRS guidance says Form 4684 reports casualty and theft losses, but the state machine allows the casualty/theft state to exist without the filing state

### 588. Form 4797 business property sale reporting failure

Model: `work/TaxForm4797BusinessPropertySaleGap.tla`

Trace:
1. initial state
2. `OccurBusinessPropertySaleOrConversion`

Observed state:
- `businessPropertySaleOrConversionOccurred = TRUE`
- `form4797Filed = FALSE`

Expected invariant:
- `businessPropertySaleOrConversionOccurred => form4797Filed`

Meaning:
- the model lets a sale or involuntary conversion of business property occur without filing Form 4797
- this is the Form 4797 gap: IRS guidance says Form 4797 reports sales of business property and related conversions, but the state machine allows the transaction state to exist without the filing state

### 589. Form 5498 IRA maintenance reporting failure

Model: `work/TaxForm5498IRAMaintenanceGap.tla`

Trace:
1. initial state
2. `MaintainIRA`

Observed state:
- `iraMaintained = TRUE`
- `form5498Filed = FALSE`

Expected invariant:
- `iraMaintained => form5498Filed`

Meaning:
- the model lets an IRA be maintained without filing Form 5498
- this is the Form 5498 gap: IRS guidance says Form 5498 is filed for each person for whom an IRA is maintained, including a deemed IRA, but the state machine allows the maintained-account state to exist without the information return

### 590. Form 1098-T tuition statement reporting failure

Model: `work/TaxForm1098TTuitionStatementGap.tla`

Trace:
1. initial state
2. `MakeReportableTuitionTransaction`

Observed state:
- `reportableTuitionTransactionOccurred = TRUE`
- `form1098TFiled = FALSE`

Expected invariant:
- `reportableTuitionTransactionOccurred => form1098TFiled`

Meaning:
- the model lets a reportable tuition transaction occur without filing Form 1098-T
- this is the Form 1098-T gap: IRS guidance says eligible educational institutions file Form 1098-T for each student with a reportable transaction, but the state machine allows the reportable-transaction state to exist without the information return

### 591. Form W-9S student or borrower TIN certification failure

Model: `work/TaxFormW9SStudentBorrowerGap.tla`

Trace:
1. initial state
2. `TriggerW9SNeed`

Observed state:
- `w9sNeeded = TRUE`
- `formW9SProvided = FALSE`

Expected invariant:
- `w9sNeeded => formW9SProvided`

Meaning:
- the model lets a student or borrower need to provide taxpayer identification information without giving Form W-9S
- this is the Form W-9S gap: IRS guidance says students use Form W-9S to give their SSN or ITIN to an educational institution or a student-loan lender, but the state machine allows the need state to exist without the certification form

### 592. Form W-8BEN foreign beneficial owner withholding failure

Model: `work/TaxFormW8BENForeignBeneficialOwnerGap.tla`

Trace:
1. initial state
2. `ReceiveWithholdablePayment`

Observed state:
- `withholdablePaymentReceived = TRUE`
- `formW8BENProvided = FALSE`

Expected invariant:
- `withholdablePaymentReceived => formW8BENProvided`

Meaning:
- the model lets a foreign beneficial-owner payment be received without providing Form W-8BEN
- this is the Form W-8BEN gap: IRS guidance says foreign individuals give Form W-8BEN to the withholding agent or payer when they are the beneficial owner of an amount subject to withholding, but the state machine allows the payment state to exist without the foreign-status certification form

### 593. Form W-8ECI effectively connected income certification failure

Model: `work/TaxFormW8ECIEffectivelyConnectedIncomeGap.tla`

Trace:
1. initial state
2. `ReceiveEffectivelyConnectedIncome`

Observed state:
- `effectivelyConnectedIncomeReceived = TRUE`
- `formW8ECIProvided = FALSE`

Expected invariant:
- `effectivelyConnectedIncomeReceived => formW8ECIProvided`

Meaning:
- the model lets effectively connected income be received without providing Form W-8ECI
- this is the Form W-8ECI gap: IRS guidance says a foreign person gives Form W-8ECI to the withholding agent or payer for U.S.-source income that is effectively connected with a U.S. trade or business, but the state machine allows the ECI state to exist without the certification form

### 594. Form W-8IMY intermediary withholding statement failure

Model: `work/TaxFormW8IMYIntermediaryGap.tla`

Trace:
1. initial state
2. `ReceiveIntermediaryPayment`

Observed state:
- `intermediaryPaymentReceived = TRUE`
- `formW8IMYProvided = FALSE`

Expected invariant:
- `intermediaryPaymentReceived => formW8IMYProvided`

Meaning:
- the model lets an intermediary payment be received without providing Form W-8IMY
- this is the Form W-8IMY gap: IRS guidance says Form W-8IMY is used by foreign intermediaries, foreign flow-through entities, and certain U.S. branches to establish status for withholding/reporting purposes, but the state machine allows the intermediary-payment state to exist without the withholding statement

### 595. Form W-8EXP foreign organization withholding statement failure

Model: `work/TaxFormW8EXPForeignOrganizationGap.tla`

Trace:
1. initial state
2. `ReceiveExemptForeignOrganizationPayment`

Observed state:
- `exemptForeignOrganizationPaymentReceived = TRUE`
- `formW8EXPProvided = FALSE`

Expected invariant:
- `exemptForeignOrganizationPaymentReceived => formW8EXPProvided`

Meaning:
- the model lets an exempt foreign-organization payment be received without providing Form W-8EXP
- this is the Form W-8EXP gap: IRS guidance says foreign governments and certain foreign organizations use Form W-8EXP to establish non-U.S. status and claim withholding exemptions, but the state machine allows the exempt-payment state to exist without the certification form

### 596. Form W-8 CE expatriation notice failure

Model: `work/TaxFormW8CEExpatriationNoticeGap.tla`

Trace:
1. initial state
2. `ReceiveCoveredExpatriatePayment`

Observed state:
- `coveredExpatriatePaymentReceived = TRUE`
- `formW8CEProvided = FALSE`

Expected invariant:
- `coveredExpatriatePaymentReceived => formW8CEProvided`

Meaning:
- the model lets a covered expatriate payment be received without providing Form W-8 CE
- this is the Form W-8 CE gap: IRS guidance says covered expatriates use Form W-8 CE to notify the payer and trigger the special expatriation rules, but the state machine allows the payment state to exist without the notice form

### 597. Form W-8 BEN-E foreign entity status failure

Model: `work/TaxFormW8BENEForeignEntityGap.tla`

Trace:
1. initial state
2. `ReceiveForeignEntityPayment`

Observed state:
- `foreignEntityPaymentReceived = TRUE`
- `formW8BENEProvided = FALSE`

Expected invariant:
- `foreignEntityPaymentReceived => formW8BENEProvided`

Meaning:
- the model lets a foreign entity payment be received without providing Form W-8 BEN-E
- this is the Form W-8 BEN-E gap: IRS guidance says foreign entities use Form W-8 BEN-E to document their status for withholding and reporting purposes, but the state machine allows the foreign-entity-payment state to exist without the certification form

### 598. Form W-9 taxpayer identification certification failure

Model: `work/TaxFormW9TINCertificationGap.tla`

Trace:
1. initial state
2. `PayReportableIncome`

Observed state:
- `reportableIncomePaid = TRUE`
- `formW9Provided = FALSE`

Expected invariant:
- `reportableIncomePaid => formW9Provided`

Meaning:
- the model lets reportable income be paid without providing Form W-9
- this is the Form W-9 gap: IRS guidance says Form W-9 provides a correct TIN to the person required to file an information return, but the state machine allows the reportable-income state to exist without the certification form

### 599. Form W-7 ITIN application failure

Model: `work/TaxFormW7ITINApplicationGap.tla`

Trace:
1. initial state
2. `NeedITIN`

Observed state:
- `itinNeeded = TRUE`
- `formW7Filed = FALSE`

Expected invariant:
- `itinNeeded => formW7Filed`

Meaning:
- the model lets an ITIN need arise without filing Form W-7
- this is the Form W-7 gap: IRS guidance says Form W-7 is used to apply for an ITIN or renew an expiring one, but the state machine allows the ITIN-needed state to exist without the application form

### 600. Form W-4 withholding certificate failure

Model: `work/TaxFormW4WithholdingCertificateGap.tla`

Trace:
1. initial state
2. `ReceiveWagePayment`

Observed state:
- `wagePaymentReceived = TRUE`
- `formW4Provided = FALSE`

Expected invariant:
- `wagePaymentReceived => formW4Provided`

Meaning:
- the model lets a wage payment be received without providing Form W-4
- this is the Form W-4 gap: IRS guidance says Form W-4 tells an employer how much federal income tax to withhold from wages, but the state machine allows the wage-payment state to exist without the withholding certificate

### 600.1. Form W-4 revised withholding timing failure

Model: `work/TaxFormW4RevisedWithholdingTimingGap.tla`

Trace:
1. initial state
2. `ReceiveRevisedW4`
3. `AdvanceDay` repeated until day 30

Observed state:
- `revisedW4Received = TRUE`
- `daysSinceReceipt = 30`
- `withholdingUpdated = FALSE`

Expected invariant:
- `revisedW4Received /\ daysSinceReceipt >= 30 => withholdingUpdated`

Meaning:
- the model lets a revised Form W-4 sit on the books for 30 days without updating withholding
- this is the Form W-4 revised-timing gap: IRS guidance says a revised Form W-4 must be put into effect by the first payroll period ending on or after the 30th day after receipt, but the state machine allows the stale withholding state to persist past that deadline

### 601. Form W-4R withholding certificate failure

Model: `work/TaxFormW4RWithholdingCertificateGap.tla`

Trace:
1. initial state
2. `ReceiveNonperiodicPayment`

Observed state:
- `nonperiodicPaymentReceived = TRUE`
- `formW4RProvided = FALSE`

Expected invariant:
- `nonperiodicPaymentReceived => formW4RProvided`

Meaning:
- the model lets a nonperiodic payment be received without providing Form W-4R
- this is the Form W-4R gap: IRS guidance says Form W-4R tells a payer how much federal income tax to withhold from nonperiodic or rollover distributions, but the state machine allows the payment state to exist without the withholding certificate

### 602. Form W-10 dependent care provider identification failure

Model: `work/TaxFormW10DependentCareProviderGap.tla`

Trace:
1. initial state
2. `ClaimDependentCareExpenses`

Observed state:
- `dependentCareExpensesClaimed = TRUE`
- `formW10Requested = FALSE`

Expected invariant:
- `dependentCareExpensesClaimed => formW10Requested`

Meaning:
- the model lets dependent care expenses be claimed without requesting Form W-10
- this is the Form W-10 gap: IRS guidance says Form W-10 gets the correct name, address, and TIN from dependent-care providers for the child and dependent care credit or employer dependent-care benefits, but the state machine allows the expense-claim state to exist without the provider identification form

### 603. Form W-4V voluntary withholding failure

Model: `work/TaxFormW4VVoluntaryWithholdingGap.tla`

Trace:
1. initial state
2. `ReceiveGovernmentPayment`

Observed state:
- `governmentPaymentReceived = TRUE`
- `formW4VProvided = FALSE`

Expected invariant:
- `governmentPaymentReceived => formW4VProvided`

Meaning:
- the model lets a qualifying government payment be received without providing Form W-4V
- this is the Form W-4V gap: IRS guidance says Form W-4V is used to request voluntary withholding on certain government payments, but the state machine allows the payment state to exist without the withholding request

### 604. Form W-4S sick pay withholding failure

Model: `work/TaxFormW4SSickPayWithholdingGap.tla`

Trace:
1. initial state
2. `ReceiveSickPay`

Observed state:
- `sickPayReceived = TRUE`
- `formW4SProvided = FALSE`

Expected invariant:
- `sickPayReceived => formW4SProvided`

Meaning:
- the model lets sick pay be received without providing Form W-4S
- this is the Form W-4S gap: IRS guidance says Form W-4S requests federal income tax withholding from sick pay, but the state machine allows the sick-pay state to exist without the withholding request form

### 605. Form W-2 wage statement reporting failure

Model: `work/TaxFormW2WageStatementGap.tla`

Trace:
1. initial state
2. `PayWage`

Observed state:
- `wagePaid = TRUE`
- `formW2Filed = FALSE`

Expected invariant:
- `wagePaid => formW2Filed`

Meaning:
- the model lets wages be paid without filing Form W-2
- this is the Form W-2 gap: IRS guidance says employers must file Form W-2 for employees with reportable wages and withholding facts, but the state machine allows the wage-payment state to exist without the wage statement

### 606. Form W-3 wage statement transmittal failure

Model: `work/TaxFormW3WageStatementTransmittalGap.tla`

Trace:
1. initial state
2. `FileWageStatement`

Observed state:
- `wageStatementFiled = TRUE`
- `formW3Filed = FALSE`

Expected invariant:
- `wageStatementFiled => formW3Filed`

Meaning:
- the model lets a wage statement be filed without transmitting it on Form W-3
- this is the Form W-3 gap: IRS guidance says Form W-3 transmits Copy A of Forms W-2, but the state machine allows the wage-statement state to exist without the transmittal form

### 607. Form W-2C corrected wage statement failure

Model: `work/TaxFormW2CWageCorrectionGap.tla`

Trace:
1. initial state
2. `DetectWageStatementError`

Observed state:
- `wageStatementErrorDetected = TRUE`
- `formW2CFiled = FALSE`

Expected invariant:
- `wageStatementErrorDetected => formW2CFiled`

Meaning:
- the model lets a wage-statement error exist without filing Form W-2C
- this is the Form W-2C gap: IRS guidance says Form W-2C corrects errors on Forms W-2 and related wage statements, but the state machine allows the error state to exist without the corrected wage statement

### 608. Form W-3C corrected wage statement transmittal failure

Model: `work/TaxFormW3CWageCorrectionTransmittalGap.tla`

Trace:
1. initial state
2. `FileCorrectedWageStatement`

Observed state:
- `correctedWageStatementFiled = TRUE`
- `formW3CFiled = FALSE`

Expected invariant:
- `correctedWageStatementFiled => formW3CFiled`

Meaning:
- the model lets a corrected wage statement be filed without transmitting it on Form W-3C
- this is the Form W-3C gap: IRS guidance says Form W-3C transmits Copy A of Form(s) W-2c, but the state machine allows the corrected-statement state to exist without the transmittal form

### 609. Form W-3(SS) territorial wage statement transmittal failure

Model: `work/TaxFormW3SSTerritorialTransmittalGap.tla`

Trace:
1. initial state
2. `FileTerritorialWageStatement`

Observed state:
- `territorialWageStatementFiled = TRUE`
- `formW3SSFiled = FALSE`

Expected invariant:
- `territorialWageStatementFiled => formW3SSFiled`

Meaning:
- the model lets a territorial wage statement be filed without transmitting it on Form W-3(SS)
- this is the Form W-3(SS) gap: IRS guidance says Form W-3(SS) transmits Copy A of Forms W-2 for territorial wage statements, but the state machine allows the wage-statement state to exist without the transmittal form

### 610. Form W-3(PR) withholding statement transmittal failure

Model: `work/TaxFormW3PRWithholdingTransmittalGap.tla`

Trace:
1. initial state
2. `FilePRWithholdingStatement`

Observed state:
- `prWithholdingStatementFiled = TRUE`
- `formW3PRFiled = FALSE`

Expected invariant:
- `prWithholdingStatementFiled => formW3PRFiled`

Meaning:
- the model lets a Puerto Rico withholding statement be filed without transmitting it on Form W-3(PR)
- this is the Form W-3(PR) gap: IRS guidance says Form W-3(PR) transmits Form(s) 499R-2/W-2PR, but the state machine allows the withholding-statement state to exist without the transmittal form

### 611. Form W-2(AS) American Samoa wage statement failure

Model: `work/TaxFormW2ASWageStatementGap.tla`

Trace:
1. initial state
2. `PayWage`

Observed state:
- `wagePaid = TRUE`
- `formW2ASFiled = FALSE`

Expected invariant:
- `wagePaid => formW2ASFiled`

Meaning:
- the model lets American Samoa wages be paid without filing Form W-2(AS)
- this is the Form W-2(AS) gap: IRS guidance says Form W-2(AS) reports American Samoa wages, but the state machine allows the wage-payment state to exist without the territorial wage statement

### 612. Form W-2(GU) Guam wage statement failure

Model: `work/TaxFormW2GUWageStatementGap.tla`

Trace:
1. initial state
2. `PayWage`

Observed state:
- `wagePaid = TRUE`
- `formW2GUFiled = FALSE`

Expected invariant:
- `wagePaid => formW2GUFiled`

Meaning:
- the model lets Guam wages be paid without filing Form W-2(GU)
- this is the Form W-2(GU) gap: IRS guidance says Form W-2(GU) reports Guam wages, but the state machine allows the wage-payment state to exist without the territorial wage statement

### 613. Form W-2(VI) U.S. Virgin Islands wage statement failure

Model: `work/TaxFormW2VIWageStatementGap.tla`

Trace:
1. initial state
2. `PayWage`

Observed state:
- `wagePaid = TRUE`
- `formW2VIFiled = FALSE`

Expected invariant:
- `wagePaid => formW2VIFiled`

Meaning:
- the model lets U.S. Virgin Islands wages be paid without filing Form W-2(VI)
- this is the Form W-2(VI) gap: IRS guidance says Form W-2(VI) reports U.S. Virgin Islands wages, but the state machine allows the wage-payment state to exist without the territorial wage statement

### 614. Form 499R-2/W-2PR Puerto Rico wage statement failure

Model: `work/TaxForm499R2W2PRWageStatementGap.tla`

Trace:
1. initial state
2. `PayPRWage`

Observed state:
- `prWagePaid = TRUE`
- `form499R2W2PRFiled = FALSE`

Expected invariant:
- `prWagePaid => form499R2W2PRFiled`

Meaning:
- the model lets Puerto Rico wages be paid without filing Form 499R-2/W-2PR
- this is the Form 499R-2/W-2PR gap: IRS guidance says the Puerto Rico wage statement reports wage and withholding information for the territory, but the state machine allows the wage-payment state to exist without the statement

### 615. Form 499R-2c/W-2PR corrected Puerto Rico wage statement failure

Model: `work/TaxForm499R2cW2PRWageCorrectionGap.tla`

Trace:
1. initial state
2. `DetectPRWageStatementError`

Observed state:
- `prWageStatementErrorDetected = TRUE`
- `form499R2cW2PRFiled = FALSE`

Expected invariant:
- `prWageStatementErrorDetected => form499R2cW2PRFiled`

Meaning:
- the model lets a Puerto Rico wage-statement error exist without filing Form 499R-2c/W-2PR
- this is the Form 499R-2c/W-2PR gap: IRS guidance says the corrected Puerto Rico statement fixes errors in the original wage statement, but the state machine allows the error state to exist without the corrected statement

### 616. Form W-3C(PR) corrected Puerto Rico transmittal failure

Model: `work/TaxFormW3CPRCorrectedTransmittalGap.tla`

Trace:
1. initial state
2. `FileCorrectedPRWageStatement`

Observed state:
- `correctedPRWageStatementFiled = TRUE`
- `formW3CPRFiled = FALSE`

Expected invariant:
- `correctedPRWageStatementFiled => formW3CPRFiled`

Meaning:
- the model lets a corrected Puerto Rico wage statement be filed without transmitting it on Form W-3C(PR)
- this is the Form W-3C(PR) gap: IRS guidance says Form W-3C(PR) transmits Form(s) 499R-2c/W-2cPR, but the state machine allows the corrected-statement state to exist without the transmittal form

### 617. Form W-2(CM) CNMI wage statement failure

Model: `work/TaxFormW2CMWageStatementGap.tla`

Trace:
1. initial state
2. `PayWage`

Observed state:
- `wagePaid = TRUE`
- `formW2CMFiled = FALSE`

Expected invariant:
- `wagePaid => formW2CMFiled`

Meaning:
- the model lets CNMI wages be paid without filing Form W-2(CM)
- this is the Form W-2(CM) gap: IRS guidance includes W-2(CM) in the wage-statement family for CNMI wages, but the state machine allows the wage-payment state to exist without the territorial wage statement

### 618. Form W-2c(CM) corrected CNMI wage statement failure

Model: `work/TaxFormW2CMCWageCorrectionGap.tla`

Trace:
1. initial state
2. `DetectWageStatementError`

Observed state:
- `wageStatementErrorDetected = TRUE`
- `formW2CMCFiled = FALSE`

Expected invariant:
- `wageStatementErrorDetected => formW2CMCFiled`

Meaning:
- the model lets a CNMI wage-statement error exist without filing Form W-2c(CM)
- this is the Form W-2c(CM) gap: IRS guidance says corrected wage statements cover W-2CM errors, but the state machine allows the error state to exist without the corrected statement

### 619. Form 1099-DIV nominee correction repair failure

Model: `work/TaxForm1099DIVNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDividend`
3. `FileOriginal1099DIV`
4. `FileCorrected1099DIV`

Observed state:
- `nomineeReceivedDividend = TRUE`
- `dividendBelongsToAnother = TRUE`
- `original1099DIVFiled = TRUE`
- `corrected1099DIVFiled = TRUE`
- `ownerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099DIVFiled => ownerCopyFurnished`

Meaning:
- the model lets the correction be filed for a dividend that belongs to another owner while the actual owner still never receives the repaired copy
- this is the Form 1099-DIV nominee-repair gap: IRS instructions say nominees must file a 1099-DIV for the other owner, but the repair path can still stop at filing and never fully reattach the dividend to the real owner

### 620. Form 1099-DA corrected digital asset statement reconciliation failure

Model: `work/TaxForm1099DACorrectionGap.tla`

Trace:
1. initial state
2. `BrokerReportsDigitalAssetSale`
3. `FileOriginal1099DA`
4. `FileCorrected1099DA`

Observed state:
- `digitalAssetBrokerSaleOccurred = TRUE`
- `original1099DAFiled = TRUE`
- `corrected1099DAFiled = TRUE`
- `basisInfoChanged = TRUE`
- `form8949Filed = FALSE`

Expected invariant:
- `corrected1099DAFiled /\ basisInfoChanged => form8949Filed`

Meaning:
- the model lets a corrected Form 1099-DA reflect updated basis information while the downstream reconciliation form still never appears
- this is the Form 1099-DA correction gap: IRS instructions explicitly include corrected and void returns, and Form 8949 is the return-level reconciliation layer, but the state machine allows the correction chain to stop before reconciliation

### 734. Form 1099-R nominee correction failure

Model: `work/TaxForm1099RNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDistribution`
3. `FileOriginal1099R`
4. `FileCorrected1099R`

Observed state:
- `nomineeReceivedDistribution = TRUE`
- `distributionBelongsToAnother = TRUE`
- `original1099RFiled = TRUE`
- `corrected1099RFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099RFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-R without furnishing the other owner’s copy
- this is the Form 1099-R nominee-correction gap: the correction path reaches the corrected distribution statement, but the recipient-side delivery still never becomes mandatory

### 733. Form 1099-DA nominee correction failure

Model: `work/TaxForm1099DANomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDigitalAssetProceeds`
3. `FileOriginal1099DA`
4. `FileCorrected1099DA`

Observed state:
- `nomineeReceivedDigitalAssetProceeds = TRUE`
- `digitalAssetProceedsBelongToAnother = TRUE`
- `original1099DAFiled = TRUE`
- `corrected1099DAFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099DAFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-DA without furnishing the other owner’s copy
- this is the Form 1099-DA nominee-correction gap: the correction path reaches the corrected digital-asset statement, but the recipient-side delivery still never becomes mandatory

### 621. Form 1099-MISC corrected substitute payment furnishing failure

Model: `work/Tax1099MISCCorrectionGap.tla`

Trace:
1. initial state
2. `MakeSubstitutePayment`
3. `FileOriginal1099MISC`
4. `FileCorrected1099MISC`

Observed state:
- `substitutePaymentInLieuExists = TRUE`
- `amountAtLeast10 = TRUE`
- `original1099MISCFiled = TRUE`
- `corrected1099MISCFiled = TRUE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `corrected1099MISCFiled => recipientCopyFurnished`

Meaning:
- the model lets a corrected Form 1099-MISC for broker substitute payments be filed without furnishing the corrected copy to the recipient
- this is the Form 1099-MISC repair gap: IRS instructions and general information-return rules require statements to recipients for corrected returns, but the state machine lets the filing repair stop before the recipient-furnishing step

### 727. Form 1099-MISC nominee correction failure

Model: `work/TaxForm1099MISCNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineePayment`
3. `FileOriginal1099MISC`
4. `FileCorrected1099MISC`

Observed state:
- `nomineeReceivedPayment = TRUE`
- `paymentBelongsToAnother = TRUE`
- `original1099MISCFiled = TRUE`
- `corrected1099MISCFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099MISCFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-MISC without furnishing the other owner’s copy
- this is the Form 1099-MISC nominee-correction gap: the repair path reaches the corrected filing, but the other-owner furnishing step still never becomes mandatory

### 622. Form 1099-NEC corrected nonemployee compensation furnishing failure

Model: `work/TaxForm1099NECCorrectionGap.tla`

Trace:
1. initial state
2. `PayNonemployeeCompensation`
3. `FileOriginal1099NEC`
4. `FileCorrected1099NEC`

Observed state:
- `nonemployeeCompensationPaid = TRUE`
- `original1099NECFiled = TRUE`
- `corrected1099NECFiled = TRUE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `corrected1099NECFiled => recipientCopyFurnished`

Meaning:
- the model lets a corrected Form 1099-NEC exist without furnishing the corrected copy to the worker/recipient
- this is the Form 1099-NEC repair gap: IRS instructions say corrected and void returns are part of the information-return system, but the state machine allows the correction to stop at filing and never reach the recipient-statement layer

### 728. Form 1099-NEC nominee correction failure

Model: `work/TaxForm1099NECNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeComp`
3. `FileOriginal1099NEC`
4. `FileCorrected1099NEC`

Observed state:
- `nomineeReceivedComp = TRUE`
- `compensationBelongsToAnother = TRUE`
- `original1099NECFiled = TRUE`
- `corrected1099NECFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099NECFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-NEC without furnishing the other owner’s copy
- this is the Form 1099-NEC nominee-correction gap: the repair path reaches the corrected filing, but the recipient-side delivery still never becomes mandatory

### 623. Form 1099-K incorrect receipt correction failure

Model: `work/TaxForm1099KCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveIncorrect1099K`

Observed state:
- `incorrect1099KReceived = TRUE`
- `correctionRequested = FALSE`
- `corrected1099KReceived = FALSE`
- `returnZeroedOut = FALSE`

Expected invariant:
- `incorrect1099KReceived => corrected1099KReceived \/ returnZeroedOut`

Meaning:
- the model lets an incorrect Form 1099-K be received without either obtaining a corrected form or zeroing out the error on the return
- this is the Form 1099-K repair gap: IRS guidance says taxpayers should request a corrected Form 1099-K if necessary, and if they cannot get one they should adjust the return, but the state machine allows the incorrect-form state to exist with neither repair path activated

### 732. Form 1099-S nominee correction failure

Model: `work/TaxForm1099SNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeRealEstateProceeds`
3. `FileOriginal1099S`
4. `FileCorrected1099S`

Observed state:
- `nomineeReceivedRealEstateProceeds = TRUE`
- `realEstateProceedsBelongToAnother = TRUE`
- `original1099SFiled = TRUE`
- `corrected1099SFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099SFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-S without furnishing the other owner’s copy
- this is the Form 1099-S nominee-correction gap: the correction path reaches the corrected real-estate statement, but the recipient-side delivery still never becomes mandatory

### 624. Form 1099-R corrected distribution amendment failure

Model: `work/TaxForm1099RCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveOriginal1099R`
3. `FileOriginalReturn`
4. `ReceiveCorrected1099R`

Observed state:
- `original1099RReceived = TRUE`
- `corrected1099RReceived = TRUE`
- `originalReturnFiled = TRUE`
- `form1040XFiled = FALSE`

Expected invariant:
- `corrected1099RReceived /\ originalReturnFiled => form1040XFiled`

Meaning:
- the model lets a corrected Form 1099-R arrive after the original return has already been filed without forcing an amended return
- this is the Form 1099-R repair gap: IRS guidance says taxpayers may need to file Form 1040-X when a corrected Form 1099-R changes the amounts they reported, but the state machine allows the correction to stop at the form-receipt layer

### 736. Form 1099-LS nominee correction failure

Model: `work/TaxForm1099LSNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineePolicySale`
3. `FileOriginal1099LS`
4. `FileCorrected1099LS`

Observed state:
- `nomineeReceivedPolicySale = TRUE`
- `policySaleBelongsToAnother = TRUE`
- `original1099LSFiled = TRUE`
- `corrected1099LSFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099LSFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-LS without furnishing the other owner’s copy
- this is the Form 1099-LS nominee-correction gap: the correction path reaches the corrected policy-sale statement, but the recipient-side delivery still never becomes mandatory

### 625. Form 1099-G corrected government payment amendment failure

Model: `work/TaxForm1099GCorrectionGap.tla`

Trace:
1. initial state
2. `PayUnemploymentCompensation`
3. `FileOriginal1099G`
4. `FileOriginalReturn`
5. `ReceiveCorrected1099G`

Observed state:
- `unemploymentCompensationPaid = TRUE`
- `original1099GFiled = TRUE`
- `corrected1099GReceived = TRUE`
- `originalReturnFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected1099GReceived /\ originalReturnFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 1099-G arrive after the original return is filed without forcing an amended return
- this is the Form 1099-G repair gap: IRS guidance says taxpayers who receive an inaccurate or corrected Form 1099-G should use the corrected information in filing or amending their return, but the state machine allows the correction to stop at the receipt layer

### 735. Form 1099-G nominee correction failure

Model: `work/TaxForm1099GNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeGovPayment`
3. `FileOriginal1099G`
4. `ReceiveCorrected1099G`

Observed state:
- `nomineeReceivedGovPayment = TRUE`
- `govPaymentBelongsToAnother = TRUE`
- `original1099GFiled = TRUE`
- `corrected1099GReceived = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099GReceived => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee receive a corrected Form 1099-G without furnishing the other owner’s copy
- this is the Form 1099-G nominee-correction gap: the correction path reaches the corrected government-payment statement, but the recipient-side delivery still never becomes mandatory

### 626. Form 1099-S corrected real estate transaction amendment failure

Model: `work/TaxForm1099SCorrectionGap.tla`

Trace:
1. initial state
2. `SellReportableRealEstate`
3. `FileOriginal1099S`
4. `FileOriginalReturn`
5. `ReceiveCorrected1099S`

Observed state:
- `reportableRealEstateSale = TRUE`
- `original1099SFiled = TRUE`
- `corrected1099SReceived = TRUE`
- `originalReturnFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected1099SReceived /\ originalReturnFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 1099-S arrive after the original return is filed without forcing an amended return
- this is the Form 1099-S repair gap: IRS guidance says corrected and void returns are part of the information-return system, but the state machine allows the correction to stop before the taxpayer-side amendment step

### 627. Form 1099-C corrected cancellation of debt amendment failure

Model: `work/TaxForm1099CCorrectionGap.tla`

Trace:
1. initial state
2. `CancelDebt`
3. `FileOriginal1099C`
4. `FileOriginalReturn`
5. `ReceiveCorrected1099C`

Observed state:
- `debtCanceled = TRUE`
- `original1099CFiled = TRUE`
- `corrected1099CReceived = TRUE`
- `originalReturnFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected1099CReceived /\ originalReturnFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 1099-C arrive after the original return is filed without forcing an amended return
- this is the Form 1099-C repair gap: IRS guidance and the general information-return rules recognize corrected and void returns, but the state machine allows the correction to stop at the form-receipt layer

### 739. Form 1099-C nominee correction failure

Model: `work/TaxForm1099CNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeDischarge`
3. `FileOriginal1099C`
4. `ReceiveCorrected1099C`

Observed state:
- `nomineeReceivedDischarge = TRUE`
- `debtDischargeBelongsToAnother = TRUE`
- `original1099CFiled = TRUE`
- `corrected1099CReceived = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099CReceived => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee receive a corrected Form 1099-C without furnishing the other owner’s copy
- this is the Form 1099-C nominee-correction gap: the correction path reaches the corrected discharge statement, but the recipient-side delivery still never becomes mandatory

### 628. Form 1099-A corrected secured property amendment failure

Model: `work/TaxForm1099ACorrectionGap.tla`

Trace:
1. initial state
2. `Trigger1099A`
3. `FileOriginal1099A`
4. `FileOriginalReturn`
5. `ReceiveCorrected1099A`

Observed state:
- `securedPropertyAcquiredOrAbandoned = TRUE`
- `original1099AFiled = TRUE`
- `corrected1099AReceived = TRUE`
- `originalReturnFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected1099AReceived /\ originalReturnFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 1099-A arrive after the original return is filed without forcing an amended return
- this is the Form 1099-A repair gap: IRS guidance includes corrected and void returns in the information-return rules, but the state machine allows the correction to stop before the taxpayer-side amendment step

### 741. Form 1099-A nominee correction failure

Model: `work/TaxForm1099ANomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeSecuredPropertyProceeds`
3. `FileOriginal1099A`
4. `ReceiveCorrected1099A`

Observed state:
- `nomineeReceivedSecuredPropertyProceeds = TRUE`
- `securedPropertyProceedsBelongToAnother = TRUE`
- `original1099AFiled = TRUE`
- `corrected1099AReceived = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099AReceived => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee receive a corrected Form 1099-A without furnishing the other owner’s copy
- this is the Form 1099-A nominee-correction gap: the correction path reaches the corrected secured-property statement, but the recipient-side delivery still never becomes mandatory

### 629. Form 1099-Q corrected qualified education distribution furnishing failure

Model: `work/TaxForm1099QCorrectionGap.tla`

Trace:
1. initial state
2. `MakeQualifiedEducationDistribution`
3. `FileOriginal1099Q`
4. `FileCorrected1099Q`

Observed state:
- `qualifiedEducationDistributionMade = TRUE`
- `original1099QFiled = TRUE`
- `corrected1099QFiled = TRUE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `corrected1099QFiled => recipientCopyFurnished`

Meaning:
- the model lets a corrected Form 1099-Q be filed without furnishing the corrected copy to the recipient
- this is the Form 1099-Q repair gap: IRS instructions explicitly call out corrected and void returns and statement-to-recipient requirements, but the state machine allows the correction to stop at filing and never reach the recipient-statement layer

### 630. Form 1099-SA corrected HSA distribution furnishing failure

Model: `work/TaxForm1099SACorrectionGap.tla`

Trace:
1. initial state
2. `MakeHsaDistribution`
3. `FileOriginal1099SA`
4. `FileCorrected1099SA`

Observed state:
- `hsaDistributionMade = TRUE`
- `original1099SAFiled = TRUE`
- `corrected1099SAFiled = TRUE`
- `beneficiaryCopyFurnished = FALSE`

Expected invariant:
- `corrected1099SAFiled => beneficiaryCopyFurnished`

Meaning:
- the model lets a corrected Form 1099-SA be filed without furnishing the corrected copy to the account beneficiary
- this is the Form 1099-SA repair gap: IRS instructions say filed Form 1099-SA should be corrected with the IRS and the account beneficiary when an error is found, but the state machine allows the correction to stop at filing and never reach the beneficiary-statement layer

### 737. Form 1099-SA nominee correction failure

Model: `work/TaxForm1099SANomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeHsaDistribution`
3. `FileOriginal1099SA`
4. `FileCorrected1099SA`

Observed state:
- `nomineeReceivedHsaDistribution = TRUE`
- `hsaDistributionBelongsToAnother = TRUE`
- `original1099SAFiled = TRUE`
- `corrected1099SAFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099SAFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-SA without furnishing the other owner’s copy
- this is the Form 1099-SA nominee-correction gap: the correction path reaches the corrected HSA statement, but the recipient-side delivery still never becomes mandatory

### 631. Form 1099-SB rescission correction failure

Model: `work/TaxForm1099SBCorrectionGap.tla`

Trace:
1. initial state
2. `SellReportablePolicy`
3. `FileOriginal1099SB`
4. `FurnishOriginalStatement`
5. `ReceiveRescissionNotice`

Observed state:
- `reportablePolicySale = TRUE`
- `original1099SBFiled = TRUE`
- `originalStatementFurnished = TRUE`
- `rescissionNoticeReceived = TRUE`
- `corrected1099SBFiled = FALSE`
- `correctedStatementFurnished = FALSE`

Expected invariant:
- `rescissionNoticeReceived /\ original1099SBFiled => corrected1099SBFiled`
- `rescissionNoticeReceived /\ originalStatementFurnished => correctedStatementFurnished`

Meaning:
- the model lets a reportable policy sale be rescinded after both the original Form 1099-SB and the original statement have gone out, but it never forces either correction to happen
- this is the Form 1099-SB repair gap: IRS instructions require a corrected Form 1099-SB and a corrected recipient statement within 15 calendar days after notice of rescission, but the state machine allows the rescission path to stop before either corrected filing or corrected furnishing occurs

### 743. Form 1099-SB nominee correction failure

Model: `work/TaxForm1099SBNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeLifeInsuranceValue`
3. `FileOriginal1099SB`
4. `FileCorrected1099SB`

Observed state:
- `nomineeReceivedLifeInsuranceValue = TRUE`
- `lifeInsuranceValueBelongsToAnother = TRUE`
- `original1099SBFiled = TRUE`
- `corrected1099SBFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099SBFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-SB without furnishing the other owner’s copy
- this is the Form 1099-SB nominee-correction gap: the correction path reaches the corrected life-insurance statement, but the recipient-side delivery still never becomes mandatory

### 632. Form 1099-LS rescission correction failure

Model: `work/TaxForm1099LSCorrectionGap.tla`

Trace:
1. initial state
2. `AcquireReportablePolicyInterest`
3. `FileOriginal1099LS`
4. `FurnishOriginalStatement`
5. `ReceiveRescissionNotice`

Observed state:
- `reportablePolicySale = TRUE`
- `original1099LSFiled = TRUE`
- `originalStatementFurnished = TRUE`
- `rescissionNoticeReceived = TRUE`
- `corrected1099LSFiled = FALSE`
- `correctedStatementFurnished = FALSE`

Expected invariant:
- `rescissionNoticeReceived /\ original1099LSFiled => corrected1099LSFiled`
- `rescissionNoticeReceived /\ originalStatementFurnished => correctedStatementFurnished`

Meaning:
- the model lets a reportable life-insurance sale be rescinded after both the original Form 1099-LS and the original statement have gone out, but it never forces either correction to happen
- this is the Form 1099-LS repair gap: IRS instructions require a corrected Form 1099-LS and a corrected recipient statement within 15 calendar days after notice of rescission, but the state machine allows the rescission path to stop before either corrected filing or corrected furnishing occurs

### 633. Form 1099-LTC corrected long-term care reporting failure

Model: `work/TaxForm1099LTCCorrectionGap.tla`

Trace:
1. initial state
2. `PayLongTermCareBenefits`
3. `FileOriginal1099LTC`
4. `DiscoverError`

Observed state:
- `longTermCareBenefitsPaid = TRUE`
- `original1099LTCFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099LTCFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099LTCFiled) => corrected1099LTCFiled`
- `corrected1099LTCFiled => recipientCopyFurnished`

Meaning:
- the model lets a long-term care benefits reporting error be discovered after filing without forcing either a corrected return or the recipient statement update
- this is the Form 1099-LTC repair gap: IRS instructions explicitly include corrected and void returns plus statements to recipients, but the state machine allows the error path to stop before the repair chain completes

### 742. Form 1099-LTC nominee correction failure

Model: `work/TaxForm1099LTCNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeLongTermCareBenefit`
3. `FileOriginal1099LTC`
4. `FileCorrected1099LTC`

Observed state:
- `nomineeReceivedLongTermCareBenefit = TRUE`
- `longTermCareBenefitBelongsToAnother = TRUE`
- `original1099LTCFiled = TRUE`
- `corrected1099LTCFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099LTCFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-LTC without furnishing the other owner’s copy
- this is the Form 1099-LTC nominee-correction gap: the correction path reaches the corrected long-term-care statement, but the recipient-side delivery still never becomes mandatory

### 634. Form 1099-INT corrected interest reporting failure

Model: `work/TaxForm1099INTCorrectionGap.tla`

Trace:
1. initial state
2. `PayInterest`
3. `FileOriginal1099INT`
4. `DiscoverError`

Observed state:
- `interestPaid = TRUE`
- `original1099INTFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099INTFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099INTFiled) => corrected1099INTFiled`
- `corrected1099INTFiled => recipientCopyFurnished`

Meaning:
- the model lets an interest-reporting error be discovered after filing without forcing either a corrected Form 1099-INT or the recipient statement update
- this is the Form 1099-INT repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 635. Form 1099-OID corrected original issue discount reporting failure

Model: `work/TaxForm1099OIDCorrectionGap.tla`

Trace:
1. initial state
2. `AccrueOriginalIssueDiscount`
3. `FileOriginal1099OID`
4. `DiscoverError`

Observed state:
- `originalIssueDiscountIncludible = TRUE`
- `original1099OIDFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099OIDFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099OIDFiled) => corrected1099OIDFiled`
- `corrected1099OIDFiled => recipientCopyFurnished`

Meaning:
- the model lets an original-issue-discount reporting error be discovered after filing without forcing either a corrected Form 1099-OID or the recipient statement update
- this is the Form 1099-OID repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 724. Form 1099-OID nominee correction failure

Model: `work/TaxForm1099OIDNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeOID`
3. `FileOriginal1099OID`
4. `FileCorrected1099OID`

Observed state:
- `nomineeReceivedOID = TRUE`
- `oidBelongsToAnother = TRUE`
- `original1099OIDFiled = TRUE`
- `corrected1099OIDFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099OIDFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-OID without furnishing the other owner’s copy
- this is the Form 1099-OID nominee-correction gap: the nominee repair path reaches the corrected filing but still fails to force the recipient-side delivery

### 636. Form 1099-CAP corrected corporate control change reporting failure

Model: `work/TaxForm1099CAPCorrectionGap.tla`

Trace:
1. initial state
2. `AcquisitionOfControl`
3. `FileOriginal1099CAP`
4. `DiscoverError`

Observed state:
- `corporationHadControlChange = TRUE`
- `original1099CAPFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099CAPFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099CAPFiled) => corrected1099CAPFiled`
- `corrected1099CAPFiled => recipientCopyFurnished`

Meaning:
- the model lets a control-change reporting error be discovered after filing without forcing either a corrected Form 1099-CAP or the recipient statement update
- this is the Form 1099-CAP repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 740. Form 1099-CAP nominee correction failure

Model: `work/TaxForm1099CAPNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeControlChangeProceeds`
3. `FileOriginal1099CAP`
4. `FileCorrected1099CAP`

Observed state:
- `nomineeReceivedControlChangeProceeds = TRUE`
- `controlChangeBelongsToAnother = TRUE`
- `original1099CAPFiled = TRUE`
- `corrected1099CAPFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099CAPFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-CAP without furnishing the other owner’s copy
- this is the Form 1099-CAP nominee-correction gap: the correction path reaches the corrected corporate-control statement, but the recipient-side delivery still never becomes mandatory

### 637. Form 1099-DIV corrected dividend reporting failure

Model: `work/TaxForm1099DIVCorrectionGap.tla`

Trace:
1. initial state
2. `PayDividend`
3. `FileOriginal1099DIV`
4. `DiscoverError`

Observed state:
- `dividendPaid = TRUE`
- `original1099DIVFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099DIVFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099DIVFiled) => corrected1099DIVFiled`
- `corrected1099DIVFiled => recipientCopyFurnished`

Meaning:
- the model lets a dividend-reporting error be discovered after filing without forcing either a corrected Form 1099-DIV or the recipient statement update
- this is the Form 1099-DIV repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 638. Form 1099-PATR corrected patronage dividend reporting failure

Model: `work/TaxForm1099PATRCorrectionGap.tla`

Trace:
1. initial state
2. `PayPatronageDividend`
3. `FileOriginal1099PATR`
4. `DiscoverError`

Observed state:
- `patronageDividendPaid = TRUE`
- `original1099PATRFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099PATRFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099PATRFiled) => corrected1099PATRFiled`
- `corrected1099PATRFiled => recipientCopyFurnished`

Meaning:
- the model lets a patronage-dividend reporting error be discovered after filing without forcing either a corrected Form 1099-PATR or the recipient statement update
- this is the Form 1099-PATR repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 725. Form 1099-PATR nominee correction failure

Model: `work/TaxForm1099PATRNomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineePATR`
3. `FileOriginal1099PATR`
4. `FileCorrected1099PATR`

Observed state:
- `nomineeReceivedPATR = TRUE`
- `patrBelongsToAnother = TRUE`
- `original1099PATRFiled = TRUE`
- `corrected1099PATRFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099PATRFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-PATR without furnishing the other owner’s copy
- this is the Form 1099-PATR nominee-correction gap: the repair path reaches the corrected filing, but the recipient-side delivery still never becomes mandatory

### 725.1. Form 1099-PATR nominee allocation failure

Model: `work/TaxForm1099PATRNomineeAllocationGap.tla`

Trace:
1. initial state
2. `ReceivePatronageDividend`
3. `IdentifyBelongsToOtherOwner`

Observed state:
- `nomineeReceivedPATR = TRUE`
- `patronageDividendBelongsToAnother = TRUE`
- `original1099PATRFiled = FALSE`
- `allocableShareReported = FALSE`

Expected invariant:
- `patronageDividendBelongsToAnother => allocableShareReported`

Meaning:
- the model lets a nominee identify that a patronage dividend belongs to another owner without forcing the allocable-share report
- this is the Form 1099-PATR nominee-allocation gap: IRS general information-return instructions say the nominee, not the original payer, is responsible for filing subsequent Forms 1099 to show the amount allocable to each owner, but the state machine allows the other-owner state to exist without the allocable-share reporting state

### 639. Form 1099-QA corrected ABLE distribution reporting failure

Model: `work/TaxForm1099QACorrectionGap.tla`

Trace:
1. initial state
2. `MakeABLEDistribution`
3. `FileOriginal1099QA`
4. `DiscoverError`

Observed state:
- `ableDistributionMade = TRUE`
- `original1099QAFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1099QAFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1099QAFiled) => corrected1099QAFiled`
- `corrected1099QAFiled => recipientCopyFurnished`

Meaning:
- the model lets an ABLE distribution reporting error be discovered after filing without forcing either a corrected Form 1099-QA or the recipient statement update
- this is the Form 1099-QA repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 738. Form 1099-QA nominee correction failure

Model: `work/TaxForm1099QANomineeCorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveNomineeAbleDistribution`
3. `FileOriginal1099QA`
4. `FileCorrected1099QA`

Observed state:
- `nomineeReceivedAbleDistribution = TRUE`
- `ableDistributionBelongsToAnother = TRUE`
- `original1099QAFiled = TRUE`
- `corrected1099QAFiled = TRUE`
- `otherOwnerCopyFurnished = FALSE`

Expected invariant:
- `corrected1099QAFiled => otherOwnerCopyFurnished`

Meaning:
- the model lets a nominee file a corrected Form 1099-QA without furnishing the other owner’s copy
- this is the Form 1099-QA nominee-correction gap: the correction path reaches the corrected ABLE statement, but the recipient-side delivery still never becomes mandatory

### 640. Form 1095-B corrected health coverage reporting failure

Model: `work/TaxForm1095BCorrectionGap.tla`

Trace:
1. initial state
2. `ProvideCoverage`
3. `FileOriginal1095B`
4. `DiscoverError`

Observed state:
- `minimumEssentialCoverageProvided = TRUE`
- `original1095BFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1095BFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1095BFiled) => corrected1095BFiled`
- `corrected1095BFiled => recipientCopyFurnished`

Meaning:
- the model lets a minimum-essential-coverage reporting error be discovered after filing without forcing either a corrected Form 1095-B or the recipient statement update
- this is the Form 1095-B repair gap: IRS instructions require a corrected Form 1095-B and a corrected recipient statement after an error is discovered, but the state machine allows the error path to stop before the correction chain completes

### 641. Form 1095-C corrected employer coverage reporting failure

Model: `work/TaxForm1095CCorrectionGap.tla`

Trace:
1. initial state
2. `GainFullTimeEmployee`
3. `FileOriginal1095C`
4. `DiscoverError`

Observed state:
- `aleMemberHasFullTimeEmployee = TRUE`
- `original1095CFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1095CFiled = FALSE`
- `employeeCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1095CFiled) => corrected1095CFiled`
- `corrected1095CFiled => employeeCopyFurnished`

Meaning:
- the model lets an employer-coverage reporting error be discovered after filing without forcing either a corrected Form 1095-C or the employee statement update
- this is the Form 1095-C repair gap: IRS instructions and ACA information-return guidance cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 642. Form 1095-A corrected Marketplace statement failure

Model: `work/TaxForm1095ACorrectionGap.tla`

Trace:
1. initial state
2. `ReportMarketplaceCoverage`
3. `ProvideOriginal1095A`
4. `DiscoverError`

Observed state:
- `marketplaceCoverageReported = TRUE`
- `original1095AProvided = TRUE`
- `errorDiscovered = TRUE`
- `corrected1095AProvided = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1095AProvided) => corrected1095AProvided`
- `corrected1095AProvided => recipientCopyFurnished`

Meaning:
- the model lets a Marketplace statement error be discovered after furnishing without forcing either a corrected Form 1095-A or the recipient statement update
- this is the Form 1095-A repair gap: IRS instructions explicitly say corrected information should be reported to the IRS and recipient, but the state machine allows the error path to stop before the correction chain completes

### 643. Form 1098-T corrected tuition statement failure

Model: `work/TaxForm1098TCorrectionGap.tla`

Trace:
1. initial state
2. `MakeReportableTuitionTransaction`
3. `FileOriginal1098T`
4. `DiscoverError`

Observed state:
- `reportableTuitionTransactionOccurred = TRUE`
- `original1098TFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098TFiled = FALSE`
- `studentCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098TFiled) => corrected1098TFiled`
- `corrected1098TFiled => studentCopyFurnished`

Meaning:
- the model lets a tuition-statement error be discovered after filing without forcing either a corrected Form 1098-T or the student copy update
- this is the Form 1098-T repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 644. Form 1098-F corrected fines and penalties reporting failure

Model: `work/TaxForm1098FCorrectionGap.tla`

Trace:
1. initial state
2. `MakeReportablePenaltyOrAmountDue`
3. `FileOriginal1098F`
4. `DiscoverError`

Observed state:
- `reportablePenaltyOrAmountDue = TRUE`
- `original1098FFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098FFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098FFiled) => corrected1098FFiled`
- `corrected1098FFiled => recipientCopyFurnished`

Meaning:
- the model lets a fines-and-penalties reporting error be discovered after filing without forcing either a corrected Form 1098-F or the recipient statement update
- this is the Form 1098-F repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 645. Form 1098-Q corrected QLAC reporting failure

Model: `work/TaxForm1098QCorrectionGap.tla`

Trace:
1. initial state
2. `IssueQLAC`
3. `FileOriginal1098Q`
4. `DiscoverError`

Observed state:
- `qlacContractIssued = TRUE`
- `original1098QFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098QFiled = FALSE`
- `recipientCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098QFiled) => corrected1098QFiled`
- `corrected1098QFiled => recipientCopyFurnished`

Meaning:
- the model lets a QLAC reporting error be discovered after filing without forcing either a corrected Form 1098-Q or the recipient statement update
- this is the Form 1098-Q repair gap: IRS instructions and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 646. Form 1098-C corrected vehicle acknowledgment failure

Model: `work/TaxForm1098CCorrectionGap.tla`

Trace:
1. initial state
2. `MakeQualifiedVehicleContribution`
3. `FileOriginal1098C`
4. `DiscoverError`

Observed state:
- `qualifiedVehicleContributed = TRUE`
- `original1098CFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098CFiled = FALSE`
- `donorCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098CFiled) => corrected1098CFiled`
- `corrected1098CFiled => donorCopyFurnished`

Meaning:
- the model lets a vehicle-donation acknowledgment error be discovered after filing without forcing either a corrected Form 1098-C or the donor copy update
- this is the Form 1098-C repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 647. Form 1098-E corrected student loan interest statement failure

Model: `work/TaxForm1098ECorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveStudentLoanInterest`
3. `FileOriginal1098E`
4. `DiscoverError`

Observed state:
- `studentLoanInterestReceived = TRUE`
- `original1098EFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098EFiled = FALSE`
- `borrowerCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098EFiled) => corrected1098EFiled`
- `corrected1098EFiled => borrowerCopyFurnished`

Meaning:
- the model lets a student-loan-interest statement error be discovered after filing without forcing either a corrected Form 1098-E or the borrower copy update
- this is the Form 1098-E repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 648. Form 1098-MA corrected mortgage assistance reporting failure

Model: `work/TaxForm1098MACorrectionGap.tla`

Trace:
1. initial state
2. `MakeMortgageAssistancePayment`
3. `FileOriginal1098MA`
4. `DiscoverError`

Observed state:
- `mortgageAssistancePaymentMade = TRUE`
- `original1098MAFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098MAFiled = FALSE`
- `homeownerCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098MAFiled) => corrected1098MAFiled`
- `corrected1098MAFiled => homeownerCopyFurnished`

Meaning:
- the model lets a mortgage-assistance reporting error be discovered after filing without forcing either a corrected Form 1098-MA or the homeowner copy update
- this is the Form 1098-MA repair gap: IRS guidance and the general information-return rules cover corrected returns and recipient statements, but the state machine allows the error path to stop before the correction chain completes

### 649. Form 1094-B corrected health coverage transmittal failure

Model: `work/TaxForm1094BCorrectionGap.tla`

Trace:
1. initial state
2. `FileHealthCoverageReturn`
3. `FileOriginal1094B`
4. `DiscoverError`

Observed state:
- `healthCoverageInformationReturnFiled = TRUE`
- `original1094BFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1094BFiled = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1094BFiled) => corrected1094BFiled`

Meaning:
- the model lets a health-coverage transmittal error be discovered after filing without forcing a corrected Form 1094-B
- this is the Form 1094-B repair gap: IRS guidance treats corrected returns as part of the information-return regime, but the state machine allows the error path to stop before the transmittal correction is filed

### 650. Form 1094-C corrected employer coverage transmittal failure

Model: `work/TaxForm1094CCorrectionGap.tla`

Trace:
1. initial state
2. `FileEmployerProvidedCoverageReturn`
3. `FileOriginal1094C`
4. `DiscoverError`

Observed state:
- `employerProvidedCoverageReturnFiled = TRUE`
- `original1094CFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1094CFiled = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1094CFiled) => corrected1094CFiled`

Meaning:
- the model lets an employer-coverage transmittal error be discovered after filing without forcing a corrected Form 1094-C
- this is the Form 1094-C repair gap: IRS guidance treats corrected returns as part of the information-return regime, but the state machine allows the error path to stop before the transmittal correction is filed

### 651. Form 1098 corrected mortgage interest statement failure

Model: `work/TaxForm1098MortgageInterestCorrectionGap.tla`

Trace:
1. initial state
2. `PayMortgageInterest`
3. `FileOriginal1098`
4. `DiscoverError`

Observed state:
- `mortgageInterestPaid = TRUE`
- `original1098Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098Filed = FALSE`
- `borrowerCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098Filed) => corrected1098Filed`
- `corrected1098Filed => borrowerCopyFurnished`

Meaning:
- the model lets a mortgage-interest statement error be discovered after filing without forcing either a corrected Form 1098 or the borrower copy update
- this is the Form 1098 repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 652. Form 1098-VLI corrected vehicle loan interest statement failure

Model: `work/TaxForm1098VLICorrectionGap.tla`

Trace:
1. initial state
2. `PaySpecifiedPassengerVehicleLoanInterest`
3. `FileOriginal1098VLI`
4. `DiscoverError`

Observed state:
- `specifiedPassengerVehicleLoanInterestPaid = TRUE`
- `original1098VLIFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1098VLIFiled = FALSE`
- `borrowerCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original1098VLIFiled) => corrected1098VLIFiled`
- `corrected1098VLIFiled => borrowerCopyFurnished`

Meaning:
- the model lets a vehicle-loan-interest statement error be discovered after filing without forcing either a corrected Form 1098-VLI or the borrower copy update
- this is the Form 1098-VLI repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 653. Form 5498-SA corrected HSA statement failure

Model: `work/TaxForm5498SACorrectionGap.tla`

Trace:
1. initial state
2. `MaintainHSA`
3. `FileOriginal5498SA`
4. `DiscoverError`

Observed state:
- `hsaMaintained = TRUE`
- `original5498SAFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected5498SAFiled = FALSE`
- `participantCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original5498SAFiled) => corrected5498SAFiled`
- `corrected5498SAFiled => participantCopyFurnished`

Meaning:
- the model lets an HSA statement error be discovered after filing without forcing either a corrected Form 5498-SA or the participant copy update
- this is the Form 5498-SA repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 654. Form 5498-QA corrected ABLE contribution reporting failure

Model: `work/TaxForm5498QACorrectionGap.tla`

Trace:
1. initial state
2. `MakeABLEAccountContribution`
3. `FileOriginal5498QA`
4. `DiscoverError`

Observed state:
- `ableAccountContributionMade = TRUE`
- `original5498QAFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected5498QAFiled = FALSE`
- `beneficiaryCopyFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original5498QAFiled) => corrected5498QAFiled`
- `corrected5498QAFiled => beneficiaryCopyFurnished`

Meaning:
- the model lets an ABLE contribution reporting error be discovered after filing without forcing either a corrected Form 5498-QA or the beneficiary copy update
- this is the Form 5498-QA repair gap: IRS instructions and the general information-return rules cover corrected returns and statements to recipients, but the state machine allows the error path to stop before the correction chain completes

### 655. Form 8937 corrected basis notice failure

Model: `work/TaxForm8937CorrectionGap.tla`

Trace:
1. initial state
2. `TakeBasisAffectingOrganizationalAction`
3. `FileOriginal8937`
4. `DiscoverError`

Observed state:
- `specifiedSecurityIssuer = TRUE`
- `organizationalActionOccurred = TRUE`
- `basisAffected = TRUE`
- `original8937Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected8937Filed = FALSE`
- `correctedIssuerStatementFurnished = FALSE`

Expected invariant:
- `(errorDiscovered /\ original8937Filed) => corrected8937Filed`
- `corrected8937Filed => correctedIssuerStatementFurnished`

Meaning:
- the model lets a basis-affecting organizational-action error be discovered after filing without forcing either a corrected Form 8937 or the corrected issuer-statement update
- this is the Form 8937 repair gap: IRS instructions say a corrected Form 8937 requires a corrected issuer statement within the correction window, but the state machine allows the error path to stop before the correction chain completes

### 656. Form 1042-T corrected transmittal failure

Model: `work/TaxForm1042TCorrectionGap.tla`

Trace:
1. initial state
2. `PrepareOriginalPaper1042S`
3. `FileOriginal1042T`
4. `DiscoverError`
5. `PrepareCorrectedPaper1042S`

Observed state:
- `originalPaper1042SSubmitted = TRUE`
- `original1042TFiled = TRUE`
- `errorDiscovered = TRUE`
- `correctedPaper1042SSubmitted = TRUE`
- `amended1042TFiled = FALSE`

Expected invariant:
- `correctedPaper1042SSubmitted => amended1042TFiled`

Meaning:
- the model lets corrected paper `1042-S` forms be prepared after an error is discovered without forcing the amended `1042-T` transmittal batch
- this is the Form 1042-T repair gap: IRS instructions say corrected paper `1042-S` forms are transmitted with a separate `1042-T`, but the state machine allows the corrected information-return batch to exist without the matching amended transmittal

### 657. Form 5471 corrected foreign corporation reporting failure

Model: `work/TaxForm5471CorrectionGap.tla`

Trace:
1. initial state
2. `AcquireForeignCorpOwnership`
3. `FileOriginal5471`
4. `DiscoverError`
5. `FileCorrected5471`

Observed state:
- `usPersonOwnsForeignCorp = TRUE`
- `original5471Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected5471Filed = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected5471Filed => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 5471 exist after an error is discovered without forcing the amended return that the IRS instructions require
- this is the Form 5471 repair gap: IRS guidance says a corrected Form 5471 must be filed with an amended tax return, but the state machine allows the corrected information-return path to stop before the amended return is filed

### 658. Form 8865 corrected foreign partnership reporting failure

Model: `work/TaxForm8865CorrectionGap.tla`

Trace:
1. initial state
2. `AcquireForeignPartnershipInterest`
3. `FileOriginal8865`
4. `DiscoverError`
5. `FileCorrected8865`

Observed state:
- `foreignPartnershipInterestHeld = TRUE`
- `original8865Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected8865Filed = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected8865Filed => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 8865 exist after an error is discovered without forcing the amended return that the IRS instructions require
- this is the Form 8865 repair gap: IRS instructions say a corrected Form 8865 must be filed with an amended tax return, but the state machine allows the corrected information-return path to stop before the amended return is filed

### 659. Form 8858 corrected foreign branch / FDE reporting failure

Model: `work/TaxForm8858CorrectionGap.tla`

Trace:
1. initial state
2. `CreateForeignBranchOrFDE`
3. `FileOriginal8858`
4. `DiscoverError`
5. `FileCorrected8858`

Observed state:
- `foreignBranchOrFDEExists = TRUE`
- `original8858Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected8858Filed = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected8858Filed => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 8858 exist after an error is discovered without forcing the amended return that the IRS examples and filing structure imply
- this is the Form 8858 repair gap: IRS instructions show amended Form 8858 reporting in corrected scenarios, but the state machine allows the corrected information-return path to stop before the amended return is filed

### 660. Form 5472 corrected related-party reporting failure

Model: `work/TaxForm5472CorrectionGap.tla`

Trace:
1. initial state
2. `CreateForeignOwnedUSCorp`
3. `AttachOriginal5472`
4. `DiscoverError`
5. `AttachCorrected5472`

Observed state:
- `foreignOwnedUSCorp = TRUE`
- `original5472Attached = TRUE`
- `errorDiscovered = TRUE`
- `corrected5472Attached = TRUE`
- `amended1120Filed = FALSE`

Expected invariant:
- `corrected5472Attached => amended1120Filed`

Meaning:
- the model lets a corrected Form 5472 attachment exist after an error is discovered without forcing the amended corporate return that carries the attachment
- this is the Form 5472 repair gap: IRS guidance treats Form 5472 as an attachment to the reporting corporation’s return, so a corrected Form 5472 path should not stop before the amended 1120 is filed

### 661. Form 8938 corrected foreign-asset disclosure failure

Model: `work/TaxForm8938CorrectionGap.tla`

Trace:
1. initial state
2. `AcquireSpecifiedForeignAssets`
3. `FileOriginal1040`
4. `DiscoverOmission`
5. `AttachCorrected8938`

Observed state:
- `specifiedForeignAssetsHeld = TRUE`
- `original1040Filed = TRUE`
- `omissionDiscovered = TRUE`
- `corrected8938Attached = TRUE`
- `amended1040XFiled = FALSE`

Expected invariant:
- `corrected8938Attached => amended1040XFiled`

Meaning:
- the model lets a corrected Form 8938 exist after an omission is discovered without forcing the amended return that the IRS says to file with the form attached
- this is the Form 8938 repair gap: IRS guidance says taxpayers who omitted Form 8938 should file Form 1040-X with Form 8938 attached, but the state machine allows the corrected disclosure path to stop before the amended return is filed

### 662. Form 3520 corrected foreign gift / trust disclosure failure

Model: `work/TaxForm3520CorrectionGap.tla`

Trace:
1. initial state
2. `TriggerReportableEvent`
3. `FileOriginal3520`
4. `DiscoverError`
5. `FileCorrected3520`

Observed state:
- `foreignGiftOrTrustTransactionOccurred = TRUE`
- `original3520Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected3520Filed = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected3520Filed => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 3520 exist after an error is discovered without forcing the amended return that the IRS correction procedures require
- this is the Form 3520 repair gap: IRS IRM guidance explicitly describes amended/corrected Forms 3520, but the state machine allows the corrected disclosure path to stop before the amended return is filed

### 663. Form 3520-A corrected foreign trust annual return failure

Model: `work/TaxForm3520ACorrectionGap.tla`

Trace:
1. initial state
2. `CreateForeignTrust`
3. `FileOriginal3520A`
4. `DiscoverError`
5. `FileCorrected3520A`

Observed state:
- `foreignTrustWithUSOwnerExists = TRUE`
- `original3520AFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected3520AFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected3520AFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 3520-A exist after an error is discovered without forcing the amended return that the IRS instructions require
- this is the Form 3520-A repair gap: IRS instructions explicitly permit amended Form 3520-A filings, but the state machine allows the corrected annual-return path to stop before the amended return is filed

### 664. Form 926 corrected foreign transfer disclosure failure

Model: `work/TaxForm926CorrectionGap.tla`

Trace:
1. initial state
2. `MakeForeignTransfer`
3. `AttachOriginal926`
4. `DiscoverError`
5. `AttachCorrected926`

Observed state:
- `foreignTransferOccurred = TRUE`
- `original926Attached = TRUE`
- `errorDiscovered = TRUE`
- `corrected926Attached = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected926Attached => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 926 attachment exist after an error is discovered without forcing the amended return that carries the filing
- this is the Form 926 repair gap: Form 926 is attached to the transferor’s return for the year of transfer, so a corrected Form 926 path should not stop before the amended return is filed

### 665. Form 8865 Schedule K-3 corrected delivery failure

Model: `work/TaxForm8865K3CorrectionGap.tla`

Trace:
1. initial state
2. `AcquireForeignPartnershipInterest`
3. `DeliverOriginalK3`
4. `DiscoverError`
5. `DeliverCorrectedK3`

Observed state:
- `foreignPartnershipInterestHeld = TRUE`
- `originalK3Delivered = TRUE`
- `errorDiscovered = TRUE`
- `correctedK3Delivered = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `correctedK3Delivered => amendedReturnFiled`

Meaning:
- the model lets a corrected Schedule K-3 exist after an error is discovered without forcing the amended return that the IRS instructions require
- this is the Schedule K-3 repair gap: IRS instructions for Schedules K-2 and K-3 say a corrected schedule should be filed with an amended tax return, but the state machine allows the corrected delivery path to stop before the amended return is filed

### 666. Form 8982 corrected partner modification affidavit failure

Model: `work/TaxForm8982CorrectionGap.tla`

Trace:
1. initial state
2. `ReceiveModification`
3. `FileOriginalAmendedReturn`
4. `DiscoverError`
5. `FileCorrectedForm8982`

Observed state:
- `partnerModificationAllowed = TRUE`
- `originalAmendedReturnFiled = TRUE`
- `errorDiscovered = TRUE`
- `correctedForm8982Filed = TRUE`
- `partnerModificationStatementResolved = FALSE`

Expected invariant:
- `correctedForm8982Filed => partnerModificationStatementResolved`

Meaning:
- the model lets a corrected Form 8982 exist after an error is discovered without forcing the statement-resolution step that the partner-modification instructions require
- this is the Form 8982 repair gap: IRS guidance ties Form 8982 to the partner modification amended-return process, but the state machine allows the corrected affidavit path to stop before the resolution state is reached

### 667. Form 1120-S corrected S corporation return failure

Model: `work/TaxForm1120SCorrectionGap.tla`

Trace:
1. initial state
2. `EndTaxYear`
3. `DiscoverError`
4. `FileCorrected1120S`

Observed state:
- `sCorpStatus = TRUE`
- `original1120SFiled = TRUE`
- `errorDiscovered = TRUE`
- `corrected1120SFiled = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected1120SFiled => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 1120-S exist after an error is discovered without forcing the amended return that the IRS instructions require
- this is the Form 1120-S repair gap: IRS instructions say to file an amended Form 1120-S to correct a previously filed return, but the state machine allows the corrected corporate return path to stop before the amended return is filed

### 668. Form 8997 corrected QOF investment statement failure

Model: `work/TaxForm8997CorrectionGap.tla`

Trace:
1. initial state
2. `AcquireQOFInvestment`
3. `FileOriginal8997`
4. `DiscoverError`
5. `FileCorrected8997`

Observed state:
- `qofInvestmentHeld = TRUE`
- `original8997Filed = TRUE`
- `errorDiscovered = TRUE`
- `corrected8997Filed = TRUE`
- `amendedReturnFiled = FALSE`

Expected invariant:
- `corrected8997Filed => amendedReturnFiled`

Meaning:
- the model lets a corrected Form 8997 exist after an error is discovered without forcing the amended return that carries the updated QOF statement
- this is the Form 8997 repair gap: IRS guidance ties Form 8997 to the amended-return chain for qualified opportunity fund reporting, but the state machine allows the corrected statement path to stop before the amended return is filed

### 669. Form W-8BEN beneficial-owner certification mismatch failure

Model: `work/TaxFormW8BENBeneficialOwnerMismatchGap.tla`

Trace:
1. initial state
2. `ReceiveWithholdablePayment`
3. `InsertNominee`
4. `ProvideFormW8BEN`
5. `ApplyReducedWithholding`

Observed state:
- `withholdablePaymentReceived = TRUE`
- `beneficialOwner = "A"`
- `certifier = "B"`
- `formW8BENProvided = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `reducedWithholdingApplied => certifier = beneficialOwner`

Meaning:
- the model lets a nominee or intermediary stand in for the beneficial owner, provide the W-8BEN path, and still trigger reduced withholding
- this is the W-8BEN beneficial-owner mismatch gap: IRS guidance centers Form W-8BEN on the foreign person who is the beneficial owner of the payment, but the state machine allows the paperwork layer to be accepted from a different party while the withholding outcome still changes

### 670. Form 8288-B withholding-certificate grant failure

Model: `work/TaxForm8288BCertificateDecisionGap.tla`

Trace:
1. initial state
2. `PlanForeignUSRPITransfer`
3. `RequestWithholdingCertificate`
4. `ApplyReducedWithholding`

Observed state:
- `foreignUSRPITransferPlanned = TRUE`
- `withholdingCertificateRequested = TRUE`
- `withholdingCertificateGranted = FALSE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `reducedWithholdingApplied => withholdingCertificateGranted`

Meaning:
- the model lets a planned foreign USRPI transfer request a withholding certificate and then apply reduced withholding before the certificate is granted
- this is the Form 8288-B grant gap: IRS instructions say the application is for a withholding certificate that may reduce or eliminate FIRPTA withholding, but the state machine allows the relief to take effect after request alone instead of waiting for the grant decision

### 671. Partnership Form 8805 zero-withholding delivery failure

Model: `work/TaxPartnership8805ZeroWithholdingGap.tla`

Trace:
1. initial state
2. `SellInterestWithoutWithholding`

Observed state:
- `foreignPartnerSoldInterest = TRUE`
- `section1446fWithholdingApplied = FALSE`
- `form8805Delivered = FALSE`

Expected invariant:
- `foreignPartnerSoldInterest => form8805Delivered`

Meaning:
- the model lets a foreign partner sell a partnership interest without ever receiving Form 8805, even though the statement obligation is not supposed to depend on actual tax withheld
- this is the Form 8805 zero-withholding gap: IRS guidance says the partnership must provide Form 8805 to the foreign partner even if no section 1446 tax is paid, but the state machine still ties the statement duty to a narrower withholding path

### 672. Form 8804-C certificate effectiveness failure

Model: `work/TaxForm8804CEffectivenessGap.tla`

Trace:
1. initial state
2. `ProvideCertificate`
3. `ConsiderCertificate`

Observed state:
- `foreignPartnerProvidedCertificate = TRUE`
- `partnershipConsideredCertificate = TRUE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `partnershipConsideredCertificate => reducedWithholdingApplied`

Meaning:
- the model lets the partnership consider a foreign partner’s Form 8804-C certification without forcing withholding reduction to follow
- this is the Form 8804-C effectiveness gap: IRS guidance says the certificate is used to reduce or eliminate section 1446 withholding when the partnership relies on the certified partner-level items, but the state machine allows the consideration state to exist without the withholding-effect state

### 673. Form 8804-C known-defect reliance failure

Model: `work/TaxForm8804CKnownDefectGap.tla`

Trace:
1. initial state
2. `ProvideCertificate`
3. `LearnCertificateDefective`
4. `ApplyReducedWithholding`

Observed state:
- `foreignPartnerProvidedCertificate = TRUE`
- `partnershipKnowsDefective = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `reducedWithholdingApplied => ~partnershipKnowsDefective`

Meaning:
- the model lets the partnership apply reduced withholding after it has learned the certificate is defective
- this is the Form 8804-C known-defect gap: IRS instructions say the partnership cannot rely on a withholding certificate if it knows or has reason to know the information is incorrect or unreliable, but the state machine still allows reliance after defect knowledge is present

### 674. Form 8804-C updated certificate failure

Model: `work/TaxForm8804CUpdatedCertificateGap.tla`

Trace:
1. initial state
2. `ProvideOriginalCertificate`
3. `ChangeFacts`
4. `ApplyReducedWithholding`

Observed state:
- `originalCertificateProvided = TRUE`
- `factsChanged = TRUE`
- `updatedCertificateProvided = FALSE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `factsChanged /\ reducedWithholdingApplied => updatedCertificateProvided`

Meaning:
- the model lets the partnership keep applying reduced withholding after the facts supporting the original certificate have changed, without any updated certificate appearing
- this is the Form 8804-C updated-certificate gap: IRS guidance says an updated certificate is required when the facts or representations in the original certificate change, but the state machine allows the stale certificate path to keep driving reduced withholding

### 675. Form 8804-C certificate supersession failure

Model: `work/TaxForm8804CCertificateSupersessionGap.tla`

Trace:
1. initial state
2. `ProvideOriginalCertificate`
3. `ProvideUpdatedCertificate`

Observed state:
- `originalCertificateProvided = TRUE`
- `updatedCertificateProvided = TRUE`
- `partnershipUsesMostRecentCertificate = FALSE`
- `reducedWithholdingApplied = FALSE`

Expected invariant:
- `updatedCertificateProvided => partnershipUsesMostRecentCertificate`

Meaning:
- the model lets the updated certificate exist while the partnership still selects the older certificate path instead of the most recent one
- this is the Form 8804-C certificate-supersession gap: IRS instructions say the most recently submitted certificate controls the calculation path, but the state machine allows the old certificate to keep shadowing the newer one

### 676. Form 8804-C late updated-certificate failure

Model: `work/TaxForm8804CLateUpdateGap.tla`

Trace:
1. initial state
2. `ChangeFacts`
3. `WaitPastDeadline`
4. `SubmitLateUpdatedCertificate`
5. `ApplyReducedWithholding`

Observed state:
- `factsChanged = TRUE`
- `daysSinceChange = 11`
- `updatedCertificateSubmitted = TRUE`
- `reducedWithholdingApplied = TRUE`

Expected invariant:
- `factsChanged /\ daysSinceChange > 10 => ~reducedWithholdingApplied`

Meaning:
- the model lets the partnership keep applying reduced withholding after the 10-day update window has already expired and the updated certificate arrives late
- this is the Form 8804-C late-update gap: IRS instructions say an updated certificate is required within 10 days of the change, but the state machine allows the late certificate path to keep affecting withholding anyway

### 677. Form W-7 ITIN renewal failure

Model: `work/TaxFormW7ITINRenewalGap.tla`

Trace:
1. initial state
2. `ExpireITIN`

Observed state:
- `itinExists = TRUE`
- `itinExpired = TRUE`
- `formW7Filed = FALSE`

Expected invariant:
- `itinExpired => formW7Filed`

Meaning:
- the model lets an already-issued ITIN expire without forcing a renewal filing
- this is the Form W-7 renewal gap: IRS guidance says Form W-7 is used to renew an existing ITIN that is expiring or has already expired, but the state machine allows the expired-ITIN state to exist without the renewal form state

### 678. Form W-7 renewal legal-name-change documentation failure

Model: `work/TaxFormW7ITINRenewalNameChangeGap.tla`

Trace:
1. initial state
2. `ExpireITIN`
3. `ChangeLegalName`

Observed state:
- `itinExists = TRUE`
- `itinExpired = TRUE`
- `legalNameChanged = TRUE`
- `renewalDocsAttached = FALSE`

Expected invariant:
- `itinExpired /\ legalNameChanged => renewalDocsAttached`

Meaning:
- the model lets an expired ITIN coexist with a legal name change without any supporting name-change documentation attached
- this is the Form W-7 renewal name-change gap: IRS instructions say renewing applicants whose legal names have changed must submit documentation supporting the change, but the state machine allows the changed-name state to exist without the docs state

### 679. Form W-7 renewal return-or-exception failure

Model: `work/TaxFormW7ITINRenewalReturnGap.tla`

Trace:
1. initial state
2. `ExpireITIN`
3. `FileRenewalW7`

Observed state:
- `itinExists = TRUE`
- `itinExpired = TRUE`
- `taxReturnAttached = FALSE`
- `exceptionClaimed = FALSE`
- `formW7Filed = TRUE`

Expected invariant:
- `formW7Filed => taxReturnAttached \/ exceptionClaimed`

Meaning:
- the model lets a taxpayer file a renewal Form W-7 without either attaching a federal tax return or claiming a documented exception
- this is the Form W-7 renewal package gap: IRS instructions say all renewal applications must include a U.S. federal tax return unless an exception applies, but the state machine allows the renewal filing to exist without either package condition

### 680. Form W-7 information-return-only exception failure

Model: `work/TaxFormW7ITINInfoReturnExceptionGap.tla`

Trace:
1. initial state
2. `ExpireITIN`
3. `UseOnlyOnInfoReturns`
4. `NeedFederalReturn`

Observed state:
- `itinExpired = TRUE`
- `usedOnlyOnInfoReturns = TRUE`
- `federalReturnRequired = TRUE`
- `formW7Filed = FALSE`

Expected invariant:
- `usedOnlyOnInfoReturns => ~federalReturnRequired`

Meaning:
- the model lets a renewal requirement be set and then lets the information-return-only exception appear without clearing that requirement
- this is the Form W-7 information-return-only exception gap: IRS guidance says an expired ITIN used only on information returns does not need renewal yet, but the state machine can still leave the renewal requirement active after the exception branch is entered

### 681. Form 5768 revocation timing failure

Model: `work/TaxForm5768RevocationTimingGap.tla`

Trace:
1. initial state
2. `MakeElection`
3. `PassFirstDayOfTaxYear`
4. `RequestRevocation`

Observed state:
- `section501hElectionMade = TRUE`
- `firstDayOfTaxYearPassed = TRUE`
- `revocationRequested = TRUE`
- `form5768Filed = FALSE`

Expected invariant:
- `revocationRequested => ~firstDayOfTaxYearPassed`

Meaning:
- the model lets a section 501(h) revocation be requested after the first day of the tax year has already passed
- this is the Form 5768 revocation-timing gap: IRS instructions say the revocation must be signed and postmarked before the first day of the tax year to which it applies, but the state machine allows the revocation path to open after the deadline

### 744. Section 1059 extraordinary dividend basis-adjustment failure

Model: `work/TaxSection1059ExtraordinaryDividendGap.tla`

Trace:
1. initial state
2. `AcquireStock`
3. `AnnounceDividend`
4. `ReceiveDividend`

Observed state:
- `stockHeld = TRUE`
- `dividendAnnounced = TRUE`
- `dividendReceived = TRUE`
- `section1059Triggered = TRUE`
- `basisReduced = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `section1059Triggered => basisReduced \/ gainRecognized`

Meaning:
- the model lets a corporation receive an extraordinary dividend within the section 1059 window without forcing any basis reduction or gain recognition
- this is the section 1059 gap: IRC section 1059 reduces corporate shareholder basis by the nontaxed portion of an extraordinary dividend, and any excess over basis becomes gain, but the state machine allows the triggered dividend path to exist while the stock basis stays unchanged

### 745. Section 302 complete-redemption characterization failure

Model: `work/TaxSection302RedemptionGap.tla`

Trace:
1. initial state
2. `RedeemAllShares`

Observed state:
- `sharesOwned = 0`
- `redemptionOccurred = TRUE`
- `completeTermination = TRUE`
- `exchangeTreatment = FALSE`

Expected invariant:
- `completeTermination => exchangeTreatment`

Meaning:
- the model lets a complete stock redemption terminate the shareholder’s interest without forcing exchange treatment
- this is the section 302 gap: IRC section 302 treats a complete redemption as an exchange, but the state machine allows the termination path to complete while the dividend-versus-exchange characterization stays unresolved

### 746. Section 306 tainted-stock disposition failure

Model: `work/TaxSection306TaintedStockDispositionGap.tla`

Trace:
1. initial state
2. `IssueTaintedStock`
3. `DisposeTaintedStock`

Observed state:
- `taintedStockIssued = TRUE`
- `disposed = TRUE`
- `ordinaryIncomeRecognized = FALSE`

Expected invariant:
- `disposed => ordinaryIncomeRecognized`

Meaning:
- the model lets section 306 tainted stock be disposed of without forcing ordinary-income treatment
- this is the section 306 gap: IRC section 306 generally treats dispositions of tainted stock as ordinary income or section 301 distributions, but the state machine allows the disposition path to complete while the tax-characterization step stays off

### 747. Section 307 stock-dividend basis allocation failure

Model: `work/TaxSection307StockDividendBasisGap.tla`

Trace:
1. initial state
2. `DistributeStockDividend`

Observed state:
- `stockHeld = TRUE`
- `stockDividendDistributed = TRUE`
- `oldStockBasis = 100`
- `newStockBasis = 0`

Expected invariant:
- `stockDividendDistributed => newStockBasis > 0`

Meaning:
- the model lets a nontaxable stock dividend be distributed without allocating any basis to the new stock
- this is the section 307 gap: IRC section 307 allocates the old stock basis between old and new stock or rights when a nontaxable stock distribution occurs, but the state machine allows the distribution path to complete while the new stock basis stays at zero

### 748. Section 304 related-corporation redemption failure

Model: `work/TaxSection304RelatedCorpRedemptionGap.tla`

Trace:
1. initial state
2. `AcquireRelatedCorpStock`

Observed state:
- `relatedCorpControl = TRUE`
- `stockAcquired = TRUE`
- `deemedRedemption = FALSE`
- `section301Treatment = FALSE`

Expected invariant:
- `stockAcquired => deemedRedemption`

Meaning:
- the model lets a related-corporation stock purchase complete without forcing the section 304 deemed-redemption step
- this is the section 304 gap: IRC section 304 recharacterizes certain related-corporation stock acquisitions as redemption transactions, but the state machine allows the acquisition path to complete while the deemed-redemption state stays off

### 749. Section 318 corporate reattribution failure

Model: `work/TaxSection318CorporateReattributionGap.tla`

Trace:
1. initial state
2. `AttributeToCorp`
3. `AttributeToPartnerViaCorp`

Observed state:
- `shareholderOwnsStock = TRUE`
- `corpConstructiveOwner = TRUE`
- `corpOwnershipConstructive = TRUE`
- `partnerConstructiveOwner = TRUE`

Expected invariant:
- `corpOwnershipConstructive => ~partnerConstructiveOwner`

Meaning:
- the model lets stock constructively owned by a corporation be reused to make a partner a constructive owner too
- this is the section 318 gap: IRC section 318 says stock constructively owned by a corporation by reason of paragraph (3) should not be re-used under paragraph (2) to make another constructive owner, but the state machine allows the reattribution hop anyway

### 750. Section 305 election-in-lieu-of-money property-treatment failure

Model: `work/TaxSection305ElectionPropertyGap.tla`

Trace:
1. initial state
2. `OfferElectionOrStock`

Observed state:
- `electionRightExists = TRUE`
- `stockDistributionMade = TRUE`
- `propertyTreatment = FALSE`

Expected invariant:
- `electionRightExists => propertyTreatment`

Meaning:
- the model lets a shareholder election to take stock instead of money exist without forcing property treatment for the stock distribution
- this is the section 305(b)(1) gap: IRC section 305 says a stock distribution with a money-or-stock election is treated as property to which section 301 applies, but the state machine allows the election path to complete while property treatment stays off

### 751. Section 305(b)(2) disproportionate-distribution property-treatment failure

Model: `work/TaxSection305DisproportionateDistributionGap.tla`

Trace:
1. initial state
2. `MakeDisproportionateDistribution`

Observed state:
- `propertyReceivedBySome = TRUE`
- `proportionateInterestIncreasedForOthers = TRUE`
- `stockDistributionMade = TRUE`
- `propertyTreatment = FALSE`

Expected invariant:
- `(propertyReceivedBySome /\ proportionateInterestIncreasedForOthers) => propertyTreatment`

Meaning:
- the model lets a stock distribution create both a property receipt for some shareholders and an increased proportionate interest for others without forcing section 301 treatment
- this is the section 305(b)(2) gap: IRC section 305 treats disproportionate distributions as property distributions, but the state machine allows the result to exist while property treatment stays off

### 752. Section 305(b)(3) common/preferred stock property-treatment failure

Model: `work/TaxSection305CommonPreferredDistributionGap.tla`

Trace:
1. initial state
2. `MakeCommonPreferredDistribution`

Observed state:
- `preferredStockIssuedToSome = TRUE`
- `commonStockIssuedToOthers = TRUE`
- `stockDistributionMade = TRUE`
- `propertyTreatment = FALSE`

Expected invariant:
- `(preferredStockIssuedToSome /\ commonStockIssuedToOthers) => propertyTreatment`

Meaning:
- the model lets a mixed common/preferred stock distribution complete without forcing section 301 property treatment
- this is the section 305(b)(3) gap: IRC section 305 treats that distribution pattern as a property distribution, but the state machine allows the stock-exchange path to complete while property treatment stays off

### 753. Section 305(b)(4) preferred-stock distribution property-treatment failure

Model: `work/TaxSection305PreferredStockDistributionGap.tla`

Trace:
1. initial state
2. `DistributePreferredOnPreferred`

Observed state:
- `preferredStockHeld = TRUE`
- `preferredStockDistributed = TRUE`
- `stockDistributionMade = TRUE`
- `propertyTreatment = FALSE`

Expected invariant:
- `preferredStockDistributed => propertyTreatment`

Meaning:
- the model lets a distribution with respect to preferred stock complete without forcing section 301 property treatment
- this is the section 305(b)(4) gap: IRC section 305 treats distributions on preferred stock as property distributions, but the state machine allows the preferred-stock distribution path to complete while property treatment stays off

### 754. Section 305(c) convertible-ratio deemed-distribution failure

Model: `work/TaxSection305CConvertibleRatioGap.tla`

Trace:
1. initial state
2. `IncreaseConversionRatio`

Observed state:
- `convertibleSecurityHeld = TRUE`
- `conversionRatioIncreased = TRUE`
- `deemedDistribution = FALSE`
- `ordinaryIncomeRecognized = FALSE`

Expected invariant:
- `conversionRatioIncreased => deemedDistribution /\ ordinaryIncomeRecognized`

Meaning:
- the model lets a convertible-security conversion ratio increase without forcing the section 305(c) deemed-distribution consequence
- this is the section 305(c) gap: IRC section 305 and its regulations treat certain conversion-ratio adjustments as deemed distributions, but the state machine allows the adjustment path to complete while the deemed distribution stays off

### 755. Section 318 option-attribution failure

Model: `work/TaxSection318OptionAttributionGap.tla`

Trace:
1. initial state
2. `GrantOption`

Observed state:
- `optionToAcquireStock = TRUE`
- `constructiveOwnership = FALSE`

Expected invariant:
- `optionToAcquireStock => constructiveOwnership`

Meaning:
- the model lets a person hold an option to acquire stock without treating the stock as constructively owned
- this is the section 318 option gap: IRC section 318 says an option to acquire stock is treated as stock ownership, but the state machine allows the option path to exist while constructive ownership stays off

### 756. Section 351 control-requirement failure

Model: `work/TaxSection351ControlRequirementGap.tla`

Trace:
1. initial state
2. `TransferPropertyForStock`

Observed state:
- `propertyTransferred = TRUE`
- `stockReceived = TRUE`
- `controlAchieved = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `(propertyTransferred /\ stockReceived /\ controlAchieved) => ~gainRecognized`

Meaning:
- the model lets a property-for-stock transfer complete without ever satisfying the section 351 control requirement
- this is the section 351 gap: IRC section 351 defers gain only if the transferor is in control immediately after the exchange, but the state machine allows the transfer path to complete while control never turns on

### 757. Section 351 boot gain-recognition failure

Model: `work/TaxSection351BootGainGap.tla`

Trace:
1. initial state
2. `TransferForStockAndBoot`

Observed state:
- `propertyTransferred = TRUE`
- `stockReceived = TRUE`
- `bootReceived = TRUE`
- `controlAchieved = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(propertyTransferred /\ stockReceived /\ bootReceived) => gainRecognized`

Meaning:
- the model lets a section 351 exchange include boot without forcing gain recognition
- this is the section 351 boot gap: IRC section 351(b) recognizes gain to the extent of boot received, but the state machine allows the stock-and-boot exchange path to complete while gain recognition stays off

### 758. Section 357(c) excess-liability gain failure

Model: `work/TaxSection357ExcessLiabilityGainGap.tla`

Trace:
1. initial state
2. `TransferPropertyWithLiabilities`

Observed state:
- `propertyTransferred = TRUE`
- `liabilitiesAssumed = 150`
- `gainRecognized = FALSE`

Expected invariant:
- `propertyTransferred /\ liabilitiesAssumed > Basis0 => gainRecognized`

Meaning:
- the model lets a section 351 transfer with liabilities in excess of basis complete without recognizing the excess as gain
- this is the section 357(c) gap: IRC section 357(c) treats excess liabilities over basis as gain, but the state machine allows the liability-assumption path to complete while gain recognition stays off

### 759. Section 357(b) tax-avoidance-purpose money-received failure

Model: `work/TaxSection357TaxAvoidancePurposeGap.tla`

Trace:
1. initial state
2. `AssumeLiabilityForStock`

Observed state:
- `propertyTransferred = TRUE`
- `liabilitiesAssumed = TRUE`
- `taxAvoidancePurpose = TRUE`
- `moneyReceived = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `taxAvoidancePurpose /\ liabilitiesAssumed => moneyReceived /\ gainRecognized`

Meaning:
- the model lets a liability assumption with tax-avoidance purpose complete without treating the assumed liability as money received
- this is the section 357(b) gap: IRC section 357(b) reclassifies tax-avoidance-purpose liability assumptions as money received on the exchange, but the state machine allows the assumption path to complete while the money-and-gain consequence stays off

### 760. Section 357(c)(3) deductible-liability exclusion failure

Model: `work/TaxSection357DeductibleLiabilityExclusionGap.tla`

Trace:
1. initial state
2. `AssumeDeductibleLiability`

Observed state:
- `propertyTransferred = TRUE`
- `deductibleLiabilityAssumed = TRUE`
- `liabilityCountedAsMoney = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `deductibleLiabilityAssumed => ~liabilityCountedAsMoney /\ ~gainRecognized`

Meaning:
- the model lets a deductible liability be assumed without carrying the section 357(c)(3) exclusion through to the money and gain calculations
- this is the section 357(c)(3) gap: IRC section 357(c)(3) excludes certain deductible liabilities from the excess-liability computation, but the state machine allows the deductible-liability path to complete without the exclusion state taking effect

### 761. Section 357(c)(3)(B) basis-created liability exclusion failure

Model: `work/TaxSection357CreatedBasisExclusionGap.tla`

Trace:
1. initial state
2. `AssumeLiabilityCreatedBasis`

Observed state:
- `propertyTransferred = TRUE`
- `liabilityCreatedBasis = TRUE`
- `liabilityCountedAsMoney = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `liabilityCreatedBasis => ~liabilityCountedAsMoney /\ ~gainRecognized`

Meaning:
- the model lets a liability that created basis be assumed without carrying the section 357(c)(3)(B) exclusion through to the money and gain calculations
- this is the section 357(c)(3)(B) gap: IRC section 357(c)(3)(B) keeps basis-created liabilities from being excluded from the excess-liability computation, but the state machine allows the basis-created-liability path to complete while the exclusion state stays off

### 762. Section 361 reorganization exchange nonrecognition failure

Model: `work/TaxSection361ReorganizationExchangeGap.tla`

Trace:
1. initial state
2. `ExchangePropertyForReorgStock`

Observed state:
- `reorganizationParty = TRUE`
- `propertyExchanged = TRUE`
- `stockReceived = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `reorganizationParty /\ propertyExchanged /\ stockReceived => ~gainRecognized`

Meaning:
- the model lets a corporation exchange property for reorganization stock without forcing the section 361 nonrecognition condition to hold
- this is the section 361 gap: IRC section 361(a) defers gain for a party to a reorganization exchanging property for stock or securities, but the state machine allows the reorganization exchange path to complete while the nonrecognition state is not enforced

### 763. Section 361(c)(2) appreciated-property distribution failure

Model: `work/TaxSection361AppreciatedPropertyDistributionGap.tla`

Trace:
1. initial state
2. `DistributeAppreciatedProperty`

Observed state:
- `reorganizationParty = TRUE`
- `propertyDistributed = TRUE`
- `appreciatedProperty = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `reorganizationParty /\ propertyDistributed /\ appreciatedProperty => gainRecognized`

Meaning:
- the model lets appreciated property be distributed in a reorganization without forcing gain recognition
- this is the section 361(c)(2) gap: IRC section 361(c)(2) recognizes gain when appreciated property other than qualified property is distributed, but the state machine allows the appreciated-property distribution path to complete while gain recognition stays off

### 764. Section 368(c) control-threshold failure

Model: `work/TaxSection368ControlThresholdGap.tla`

Trace:
1. initial state
2. `ClaimControl`

Observed state:
- `controlClaimed = TRUE`
- `votingPowerPct = 79`
- `valuePct = 80`
- `controlSatisfied = TRUE`

Expected invariant:
- `controlClaimed => (votingPowerPct >= 80 /\ valuePct >= 80)`

Meaning:
- the model lets a corporation claim section 368(c) control even though voting power is still below the 80-percent threshold
- this is the section 368(c) gap: IRC section 368(c) defines control as at least 80 percent of voting power and 80 percent of the shares of all other classes, but the state machine allows the control claim to complete while one side of the threshold still fails

### 765. Section 355(d) disqualified-stock window failure

Model: `work/TaxSection355DisqualifiedStockWindowGap.tla`

Trace:
1. initial state
2. `DistributeWithPurchasedStock`

Observed state:
- `stockPurchasedWithinFiveYearWindow = TRUE`
- `distributionOccurred = TRUE`
- `section355Qualified = TRUE`

Expected invariant:
- `stockPurchasedWithinFiveYearWindow => ~section355Qualified`

Meaning:
- the model lets a section 355 distribution proceed while stock acquired in the 5-year window is still present
- this is the section 355(d) gap: IRC section 355(d) treats purchase-acquired stock in the five-year period ending on distribution as disqualified stock, but the state machine allows the distribution path to complete while qualification remains on

### 766. Section 355(e) fifty-percent change failure

Model: `work/TaxSection355FiftyPercentChangeGap.tla`

Trace:
1. initial state
2. `DistributeAndTriggerChange`

Observed state:
- `distributionOccurred = TRUE`
- `fiftyPercentChangeOccurred = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(distributionOccurred /\ fiftyPercentChangeOccurred) => gainRecognized`

Meaning:
- the model lets a section 355 distribution and a 50-percent ownership change coexist without forcing gain recognition
- this is the section 355(e) gap: IRC section 355(e) can trigger gain when a distribution is part of a plan involving a 50-percent or greater ownership change, but the state machine allows the post-distribution change to complete while gain recognition stays off

### 767. Section 355(b) active-business-history failure

Model: `work/TaxSection355ActiveBusinessGap.tla`

Trace:
1. initial state
2. `DistributeWithoutActiveBusiness`

Observed state:
- `distributionOccurred = TRUE`
- `activeBusinessConductedThroughoutFiveYears = FALSE`
- `section355Qualified = TRUE`

Expected invariant:
- `(distributionOccurred /\ ~activeBusinessConductedThroughoutFiveYears) => ~section355Qualified`

Meaning:
- the model lets a section 355 distribution qualify even though the trade or business was not active throughout the required 5-year period
- this is the section 355(b) gap: IRC section 355(b) requires the active-business history to be satisfied, but the state machine allows the distribution path to complete while that history remains false

### 768. Section 356 boot-recognition failure

Model: `work/TaxSection356BootRecognitionGap.tla`

Trace:
1. initial state
2. `DistributeWithBoot`

Observed state:
- `distributionOccurred = TRUE`
- `bootReceived = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(distributionOccurred /\ bootReceived) => gainRecognized`

Meaning:
- the model lets a section 355-style distribution with boot complete without recognizing the boot gain
- this is the section 356 gap: IRC section 356 recognizes gain when money or other property is received in the exchange, but the state machine allows the boot path to complete while gain recognition stays off

### 769. Section 354 solely-stock-or-securities failure

Model: `work/TaxSection354SolelyStockOrSecuritiesGap.tla`

Trace:
1. initial state
2. `ExchangeWithOtherProperty`

Observed state:
- `exchangeOccurred = TRUE`
- `otherPropertyReceived = TRUE`
- `section354Nonrecognition = TRUE`

Expected invariant:
- `otherPropertyReceived => ~section354Nonrecognition`

Meaning:
- the model lets a reorganization exchange include other property while section 354 nonrecognition still remains on
- this is the section 354 gap: IRC section 354 applies only when the exchange is solely for stock or securities, but the state machine allows the exchange path to complete even though other property was received

### 770. Section 358 basis-allocation failure

Model: `work/TaxSection358BasisAllocationGap.tla`

Trace:
1. initial state
2. `DistributeWithoutAllocatingBasis`

Observed state:
- `section355DistributionOccurred = TRUE`
- `retainedStockExists = TRUE`
- `basisAllocated = FALSE`

Expected invariant:
- `(section355DistributionOccurred /\ retainedStockExists) => basisAllocated`

Meaning:
- the model lets a section 355 distribution complete while basis is not allocated across the retained and distributed stock
- this is the section 358 gap: IRC section 358 requires basis allocation among the properties received in a nonrecognition exchange, and for section 355 distributions it also takes retained stock into account, but the state machine allows the distribution path to complete while allocation never happens

### 771. Section 362 carryover-basis failure

Model: `work/TaxSection362CarryoverBasisGap.tla`

Trace:
1. initial state
2. `AcquireProperty`

Observed state:
- `propertyAcquiredByCorporation = TRUE`
- `corporateBasis = 0`
- `gainRecognizedToTransferor = 0`

Expected invariant:
- `propertyAcquiredByCorporation => corporateBasis = TransferorBasis0 + gainRecognizedToTransferor`

Meaning:
- the model lets a corporation acquire property in a reorganization or section 351 transfer without carrying over the transferor’s basis
- this is the section 362 gap: IRC section 362 requires carryover basis with a gain adjustment, but the state machine allows the acquisition path to complete while corporate basis stays at zero

### 772. Section 362(e) built-in-loss limitation failure

Model: `work/TaxSection362BuiltInLossLimitGap.tla`

Trace:
1. initial state
2. `ImportLossProperty`

Observed state:
- `lossImportationOccurred = TRUE`
- `corporateBasis = 120`

Expected invariant:
- `lossImportationOccurred => corporateBasis = FairMarketValue0`

Meaning:
- the model lets a corporation import built-in-loss property without writing the basis down to fair market value
- this is the section 362(e) gap: IRC section 362(e)(1) limits imported built-in losses by resetting basis to FMV, but the state machine allows the loss-importation path to complete while basis remains above FMV

### 773. Section 362(e)(2) section 351 loss-duplication failure

Model: `work/TaxSection362Section351LossDuplicationGap.tla`

Trace:
1. initial state
2. `TransferWithBuiltInLoss`

Observed state:
- `section351TransferOccurred = TRUE`
- `netBuiltInLoss = TRUE`
- `corporateBasis = 120`

Expected invariant:
- `(section351TransferOccurred /\ netBuiltInLoss) => corporateBasis = FairMarketValue0`

Meaning:
- the model lets a section 351 transfer with built-in loss complete while the corporation keeps the pre-transfer basis
- this is the section 362(e)(2) gap: IRC section 362(e)(2) limits transfer-side built-in loss duplication in section 351 transactions, but the state machine allows the transfer path to complete while basis remains unadjusted

### 774. Section 381 NOL carryover failure

Model: `work/TaxSection381NOLCarryoverGap.tla`

Trace:
1. initial state
2. `AcquireWithNOLCarryover`

Observed state:
- `section381AcquisitionOccurred = TRUE`
- `acquiringNOLCarryover = 0`

Expected invariant:
- `section381AcquisitionOccurred => acquiringNOLCarryover = NOLCarryover0`

Meaning:
- the model lets a section 381 acquisition complete without carrying over the transferor’s net operating loss
- this is the section 381 gap: IRC section 381 carries specified tax items, including NOL carryovers, into the acquiring corporation, but the state machine allows the acquisition path to complete while the carryover stays at zero

### 775. Section 382 ownership-change limitation failure

Model: `work/TaxSection382OwnershipChangeLimitGap.tla`

Trace:
1. initial state
2. `UsePreChangeLossAfterOwnershipChange`

Observed state:
- `ownershipChangeOccurred = TRUE`
- `preChangeLossUsed = 100`

Expected invariant:
- `ownershipChangeOccurred => preChangeLossUsed <= Section382Limit0`

Meaning:
- the model lets a post-change corporation use more pre-change loss than the section 382 cap allows
- this is the section 382 gap: IRC section 382 limits the amount of pre-change losses usable after an ownership change, but the state machine allows the ownership-change path to complete while the full loss is still used

### 776. Section 383 excess-credit limitation failure

Model: `work/TaxSection383ExcessCreditLimitGap.tla`

Trace:
1. initial state
2. `UseExcessCreditAfterOwnershipChange`

Observed state:
- `ownershipChangeOccurred = TRUE`
- `excessCreditUsed = 50`

Expected invariant:
- `ownershipChangeOccurred => excessCreditUsed <= Section383Cap0`

Meaning:
- the model lets a post-change corporation use more excess credit than section 383 allows
- this is the section 383 gap: IRC section 383 limits excess credits after an ownership change, but the state machine allows the ownership-change path to complete while the full excess credit is still used

### 777. Section 384 preacquisition-loss offset failure

Model: `work/TaxSection384PreacquisitionLossOffsetGap.tla`

Trace:
1. initial state
2. `OffsetBuiltInGainWithPreacquisitionLoss`

Observed state:
- `acquisitionOccurred = TRUE`
- `preacquisitionLossUsed = 40`

Expected invariant:
- `acquisitionOccurred => preacquisitionLossUsed <= BuiltInGain0`

Meaning:
- the model lets preacquisition loss offset more built-in gain than section 384 permits
- this is the section 384 gap: IRC section 384 limits preacquisition losses from offsetting built-in gains after certain acquisitions, but the state machine allows the acquisition path to complete while the full preacquisition loss is still used

### 778. Section 367(a) foreign-transfer gain-recognition failure

Model: `work/TaxSection367ForeignTransferGainRecognitionGap.tla`

Trace:
1. initial state
2. `TransferToForeignCorp`

Observed state:
- `transferToForeignCorpOccurred = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `transferToForeignCorpOccurred => gainRecognized`

Meaning:
- the model lets a U.S. person transfer property to a foreign corporation without forcing gain recognition
- this is the section 367(a) gap: IRC section 367(a) treats the foreign corporation as outside the usual nonrecognition rule for these transfers, but the state machine allows the foreign-transfer path to complete while gain recognition stays off

### 779. Section 367(e)(2) foreign-liquidation gain-recognition failure

Model: `work/TaxSection367LiquidationToForeignCorpGainGap.tla`

Trace:
1. initial state
2. `LiquidateToForeignCorp`

Observed state:
- `domesticLiquidationOccurred = TRUE`
- `foreignCorpDistributee = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(domesticLiquidationOccurred /\ foreignCorpDistributee) => gainRecognized`

Meaning:
- the model lets a domestic corporation distribute property to a foreign corporation in liquidation without forcing gain recognition
- this is the section 367(e)(2) gap: the liquidation-to-foreign-corporation rule requires gain recognition, but the state machine allows the liquidation path to complete while gain recognition stays off

### 780. Section 337 liquidating-subsidiary nonrecognition failure

Model: `work/TaxSection337LiquidatingSubsidiaryNonrecognitionGap.tla`

Trace:
1. initial state
2. `LiquidateTo80PercentParent`

Observed state:
- `completeLiquidationOccurred = TRUE`
- `eightyPercentDistributee = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(completeLiquidationOccurred /\ eightyPercentDistributee) => gainRecognized`

Meaning:
- the model lets a complete liquidation to an 80-percent parent proceed without forcing gain recognition in the liquidating subsidiary layer
- this is the section 337 gap: IRC section 337 coordinates nonrecognition for liquidating subsidiaries distributed to an 80-percent distributee, but the state machine allows the liquidation path to complete while gain recognition stays off

### 781. Section 336 complete-liquidation gain-recognition failure

Model: `work/TaxSection336LiquidationGainRecognitionGap.tla`

Trace:
1. initial state
2. `LiquidateProperty`

Observed state:
- `completeLiquidationOccurred = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `completeLiquidationOccurred => gainRecognized`

Meaning:
- the model lets a complete liquidation close without recognizing the liquidating corporation’s gain or loss
- this is the section 336 gap: IRC section 336 generally recognizes gain or loss on property distributed in complete liquidation, except where section 337 applies, but the state machine allows the liquidation path to complete while gain recognition stays off

### 782. Section 332 complete-liquidation receipt failure

Model: `work/TaxSection332CompleteLiquidationReceiptGap.tla`

Trace:
1. initial state
2. `ReceiveLiquidationProperty`

Observed state:
- `completeLiquidationReceiptOccurred = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `completeLiquidationReceiptOccurred => gainRecognized`

Meaning:
- the model lets a corporation receive property in complete liquidation without forcing the receipt-side recognition outcome
- this is the section 332 gap: IRC section 332 generally gives nonrecognition to a corporate shareholder on receipt of property in complete liquidation, but the state machine allows the receipt path to complete while the recognition state remains unset

### 783. Section 334 liquidation-basis failure

Model: `work/TaxSection334LiquidationBasisGap.tla`

Trace:
1. initial state
2. `ReceiveLiquidationPropertyWithGain`

Observed state:
- `liquidationReceiptOccurred = TRUE`
- `gainRecognizedOnReceipt = TRUE`
- `distributeeBasis = 15`

Expected invariant:
- `(liquidationReceiptOccurred /\ gainRecognizedOnReceipt) => distributeeBasis = FairMarketValue0`

Meaning:
- the model lets a corporate distributee recognize gain on a liquidation receipt without stepping basis up to fair market value
- this is the section 334 gap: IRC section 334 sets FMV basis when gain or loss is recognized on liquidation receipt, but the state machine allows the receipt path to complete while basis stays at the transferor amount

### 784. Section 311 appreciated-property distribution failure

Model: `work/TaxSection311AppreciatedPropertyDistributionGap.tla`

Trace:
1. initial state
2. `DistributeAppreciatedProperty`

Observed state:
- `nonLiquidatingDistributionOccurred = TRUE`
- `appreciatedPropertyDistributed = TRUE`
- `gainRecognized = FALSE`

Expected invariant:
- `(nonLiquidatingDistributionOccurred /\ appreciatedPropertyDistributed) => gainRecognized`

Meaning:
- the model lets a corporation make a non-liquidating distribution of appreciated property without recognizing gain
- this is the section 311(b) gap: IRC section 311 requires gain recognition on distributions of appreciated property, but the state machine allows the distribution path to complete while gain recognition stays off

### 785. Section 312 earnings-and-profits adjustment failure

Model: `work/TaxSection312EarningsAndProfitsAdjustmentGap.tla`

Trace:
1. initial state
2. `DistributeAppreciatedProperty`

Observed state:
- `appreciatedPropertyDistributed = TRUE`
- `earningsAndProfits = 100`

Expected invariant:
- `appreciatedPropertyDistributed => earningsAndProfits = InitialEandP0 + GainRecognized0`

Meaning:
- the model lets a corporation distribute appreciated property without increasing earnings and profits by the recognized gain
- this is the section 312 gap: IRC section 312 requires E&P adjustments for appreciated-property distributions, but the state machine allows the distribution path to complete while E&P stays unchanged

### 786. Section 361(c)(1) property-not-distributed gain failure

Model: `work/TaxSection361PropertyNotDistributedGainGap.tla`

Trace:
1. initial state
2. `ReceiveButDoNotDistributeBoot`

Observed state:
- `bootReceivedInReorg = TRUE`
- `bootDistributed = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `(bootReceivedInReorg /\ ~bootDistributed) => gainRecognized`

Meaning:
- the model lets a corporation receive boot in a reorganization and keep it without forcing recognition of the retained gain
- this is the section 361(c)(1) gap: IRC section 361 requires gain recognition when money or other property is not distributed in pursuance of the plan, but the state machine allows the boot-retention path to complete while gain recognition stays off

### 787. Section 361(b) boot-not-distributed gain failure

Model: `work/TaxSection361BootNotDistributedGainGap.tla`

Trace:
1. initial state
2. `ExchangeAndRetainBoot`

Observed state:
- `exchangeOccurred = TRUE`
- `otherPropertyOrMoneyReceived = TRUE`
- `bootDistributedInPlan = FALSE`
- `gainRecognized = FALSE`

Expected invariant:
- `(exchangeOccurred /\ otherPropertyOrMoneyReceived /\ ~bootDistributedInPlan) => gainRecognized`

Meaning:
- the model lets a reorganization exchange receive boot and then retain it without forcing gain recognition
- this is the section 361(b) gap: IRC section 361(b) recognizes gain when other property or money is received and not distributed in pursuance of the plan, but the state machine allows the exchange path to complete while gain recognition stays off

### 788. Section 301 distribution-liability reduction failure

Model: `work/TaxSection301DistributionLiabilityReductionGap.tla`

Trace:
1. initial state
2. `DistributePropertyWithLiability`

Observed state:
- `distributionOccurred = TRUE`
- `amountDistributed = 100`

Expected invariant:
- `distributionOccurred => amountDistributed = MoneyReceived0 + OtherPropertyFMV0 - LiabilityAssumed0`

Meaning:
- the model lets a property distribution ignore the reduction for liabilities assumed on the property
- this is the section 301 gap: IRC section 301 measures the distribution amount as money plus property FMV, reduced by liabilities assumed, but the state machine allows the distribution path to complete with the unreduced amount

### 789. Section 316 year-end earnings-and-profits dividend failure

Model: `work/TaxSection316DividendYearEndEandPGap.tla`

Trace:
1. initial state
2. `MakeDistribution`

Observed state:
- `distributionOccurred = TRUE`
- `dividendClassified = FALSE`

Expected invariant:
- `distributionOccurred => (YearEndEandP0 > 0 => dividendClassified)`

Meaning:
- the model lets a corporation make a distribution during the year and leave it unclassified as a dividend even when the year-end earnings-and-profits bucket is positive
- this is the section 316 gap: IRC section 316 treats a distribution as a dividend when it comes out of current-year earnings and profits computed at year end, even if there was not enough E&P at the moment of the distribution, but the state machine only looks at the immediate distribution step

### 790. Section 317 redemption-definition failure

Model: `work/TaxSection317RedemptionDefinitionGap.tla`

Trace:
1. initial state
2. `AcquireOwnStockWithoutCancellation`

Observed state:
- `corporationAcquiredOwnStock = TRUE`
- `stockCancelledOrRetired = FALSE`
- `redemptionRecognized = FALSE`

Expected invariant:
- `corporationAcquiredOwnStock => redemptionRecognized`

Meaning:
- the model lets a corporation acquire its own stock from a shareholder without classifying the event as a redemption until some later cancellation step happens
- this is the section 317 gap: IRC section 317(b) treats the acquisition itself as a redemption whether or not the stock is later cancelled, retired, or held as treasury stock, but the state machine waits for a later status change

### 791. Section 331 complete-liquidation exchange failure

Model: `work/TaxSection331CompleteLiquidationExchangeGap.tla`

Trace:
1. initial state
2. `ReceiveCompleteLiquidationDistribution`

Observed state:
- `completeLiquidationDistributionOccurred = TRUE`
- `exchangeTreatment = FALSE`
- `section301Applied = TRUE`

Expected invariant:
- `completeLiquidationDistributionOccurred => /\ exchangeTreatment /\ ~section301Applied`

Meaning:
- the model lets a complete-liquidation distribution remain on the ordinary dividend path instead of forcing exchange treatment and shutting off section 301
- this is the section 331 gap: IRC section 331 treats amounts received in a complete liquidation as full payment in exchange for the stock and specifically removes section 301 from the path, but the state machine keeps the section 301 treatment alive

### 792. Section 338 asset-acquisition election failure

Model: `work/TaxSection338AssetAcquisitionElectionGap.tla`

Trace:
1. initial state
2. `MakeQualifiedStockPurchaseAndElection`

Observed state:
- `qualifiedStockPurchaseOccurred = TRUE`
- `section338ElectionMade = TRUE`
- `targetTreatedAsAssetAcquisition = FALSE`

Expected invariant:
- `(qualifiedStockPurchaseOccurred /\ section338ElectionMade) => targetTreatedAsAssetAcquisition`

Meaning:
- the model lets a qualified stock purchase plus section 338 election happen without forcing the target into asset-acquisition treatment
- this is the section 338 gap: IRC section 338 turns a qualified stock purchase with election into a deemed asset sale at FMV, but the state machine leaves the stock-purchase path active without the asset-sale rewrite

### 793. Section 3402 wage-withholding failure

Model: `work/TaxSection3402WageWithholdingGap.tla`

Trace:
1. initial state
2. `PayWagesWithoutWithholding`

Observed state:
- `wagePaymentMade = TRUE`
- `withholdingDeducted = FALSE`

Expected invariant:
- `wagePaymentMade => withholdingDeducted`

Meaning:
- the model lets an employer pay wages without deducting and withholding income tax at source
- this is the section 3402 gap: IRC section 3402 requires employers to withhold on wages, but the state machine allows the payment step to complete with no withholding state attached

### 794. Section 3405 deferred-income withholding failure

Model: `work/TaxSection3405DeferredIncomeWithholdingGap.tla`

Trace:
1. initial state
2. `MakePeriodicPaymentWithoutWithholding`

Observed state:
- `periodicPaymentOccurred = TRUE`
- `noWithholdingElectionMade = FALSE`
- `withholdingDeducted = FALSE`

Expected invariant:
- `(periodicPaymentOccurred /\ ~noWithholdingElectionMade) => withholdingDeducted`

Meaning:
- the model lets a periodic pension, annuity, or similar deferred-income payment go out without withholding when no opt-out election exists
- this is the section 3405 gap: IRC section 3405 requires withholding on periodic deferred-income payments unless the recipient elects otherwise, but the state machine allows the payment step to complete with neither withholding nor an election

### 795. Section 3505 third-party wage-liability failure

Model: `work/TaxSection3505ThirdPartyLiabilityGap.tla`

Trace:
1. initial state
2. `SupplyFundsWithNotice`

Observed state:
- `fundsSuppliedForWages = TRUE`
- `actualNoticeOfNonpayment = TRUE`
- `thirdPartyLiable = FALSE`

Expected invariant:
- `(fundsSuppliedForWages /\ actualNoticeOfNonpayment) => thirdPartyLiable`

Meaning:
- the model lets a lender or other third party supply wages with notice that the employer will not pay over withholding, while never attaching the statute’s personal liability to that third party
- this is the section 3505 gap: IRC section 3505 can make the third party liable in its own estate for the unpaid withholding, but the state machine allows the funding path to complete with no liability state

### 796. Section 3504 agent-designation failure

Model: `work/TaxSection3504AgentDesignationGap.tla`

Trace:
1. initial state
2. `DesignateAndPerformActs`

Observed state:
- `agentDesignated = TRUE`
- `agentPerformsEmployerActs = TRUE`
- `agentLiable = FALSE`

Expected invariant:
- `(agentDesignated /\ agentPerformsEmployerActs) => agentLiable`

Meaning:
- the model lets a designated agent perform employer acts under chapter 24 without inheriting the employer-style liability that section 3504 attaches
- this is the section 3504 gap: IRC section 3504 says the designated fiduciary, agent, or other person should be treated like the employer for applicable provisions, but the state machine leaves the agent performing the acts while liability stays off

### 797. Section 3501 collection-by-Secretary failure

Model: `work/TaxSection3501CollectionBySecretaryGap.tla`

Trace:
1. initial state
2. `ImposeTaxWithoutSecretaryCollection`

Observed state:
- `employmentTaxImposed = TRUE`
- `collectedBySecretary = FALSE`

Expected invariant:
- `employmentTaxImposed => collectedBySecretary`

Meaning:
- the model lets an employment tax be imposed without the Secretary collecting it as internal-revenue collections
- this is the section 3501 gap: IRC section 3501 makes subtitle C taxes collectible by the Secretary and payable into the Treasury, but the state machine allows the tax-imposed path to complete without any Secretary-collection state

### 798. Section 3502 nondeductibility failure

Model: `work/TaxSection3502NondeductibilityGap.tla`

Trace:
1. initial state
2. `PayAndDeductPayrollTax`

Observed state:
- `payrollTaxPaid = TRUE`
- `taxDeductedAsExpense = TRUE`

Expected invariant:
- `payrollTaxPaid => ~taxDeductedAsExpense`

Meaning:
- the model lets payroll tax payments get treated as deductible expenses
- this is the section 3502 gap: IRC section 3502 disallows deductions for the listed employment taxes and for chapter 24 withholding, but the state machine allows the payment path to complete while still marking the tax as deducted

### 799. Section 3511 certified-PEO employer-classification failure

Model: `work/TaxSection3511CertifiedPEOEmployerGap.tla`

Trace:
1. initial state
2. `EnterCPEORelationship`

Observed state:
- `cpeoCertified = TRUE`
- `workSiteEmployeeCovered = TRUE`
- `cpeoTreatedAsEmployer = FALSE`
- `customerTreatedAsEmployer = TRUE`

Expected invariant:
- `(cpeoCertified /\ workSiteEmployeeCovered) => /\ cpeoTreatedAsEmployer /\ ~customerTreatedAsEmployer`

Meaning:
- the model lets a certified PEO relationship exist while leaving both employer statuses in the wrong place
- this is the section 3511 gap: IRC section 3511 treats the certified professional employer organization as the employer for covered work-site employees and excludes the customer from that employer slot, but the state machine leaves the old customer-employer classification alive and never promotes the PEO

### 800. Section 3512 motion-picture-project employer-classification failure

Model: `work/TaxSection3512MotionPictureEmployerGap.tla`

Trace:
1. initial state
2. `StartMotionPictureProjectRelationship`

Observed state:
- `motionPictureProjectEmployer = TRUE`
- `motionPictureProjectWorker = TRUE`
- `treatedAsEmployee = FALSE`

Expected invariant:
- `(motionPictureProjectEmployer /\ motionPictureProjectWorker) => treatedAsEmployee`

Meaning:
- the model lets a motion-picture-project employer relationship exist while the worker is still left outside employee treatment
- this is the section 3512 gap: IRC section 3512 says remuneration paid by a motion-picture-project employer to a motion-picture-project worker is treated as wages from employment, but the state machine leaves the relationship labeled while the employee classification stays off

### 801. Section 3503 erroneous-payment refund failure

Model: `work/TaxSection3503ErroneousPaymentRefundGap.tla`

Trace:
1. initial state
2. `PayErroneousTaxWithoutRefund`

Observed state:
- `wrongChapterTaxPaid = TRUE`
- `liableUnderThatChapter = FALSE`
- `creditedOrRefunded = FALSE`

Expected invariant:
- `(wrongChapterTaxPaid /\ ~liableUnderThatChapter) => creditedOrRefunded`

Meaning:
- the model lets a taxpayer pay employment tax under a chapter where they are not actually liable, without forcing a credit or refund path
- this is the section 3503 gap: IRC section 3503 requires erroneous chapter 21/22 payments to be credited against the proper tax and refunded if needed, but the state machine allows the erroneous-payment path to complete with no credit or refund state

### 802. Section 3510 domestic-service deposit-coordination failure

Model: `work/TaxSection3510DomesticServiceCoordinationGap.tla`

Trace:
1. initial state
2. `AssessDomesticServiceTaxWithDeposits`

Observed state:
- `domesticServiceEmploymentTaxDue = TRUE`
- `depositRequirementApplies = TRUE`

Expected invariant:
- `domesticServiceEmploymentTaxDue => ~depositRequirementApplies`

Meaning:
- the model lets domestic-service employment taxes be assessed while still subjecting them to the ordinary deposit regime
- this is the section 3510 gap: IRC section 3510 coordinates domestic-service employment tax collection with income-tax collection and turns off ordinary deposits/installments for those taxes, but the state machine leaves the deposit requirement in place

### 803. Section 3509 misclassification-liability failure

Model: `work/TaxSection3509MisclassificationLiabilityGap.tla`

Trace:
1. initial state
2. `MisclassifyEmployeeWithoutReducedLiability`

Observed state:
- `employeeMisclassified = TRUE`
- `reducedWithholdingLiability = 0`
- `reducedSocialSecurityLiability = 0`

Expected invariant:
- `employeeMisclassified => /\ reducedWithholdingLiability > 0 /\ reducedSocialSecurityLiability > 0`

Meaning:
- the model lets an employer misclassify an employee without applying the reduced-liability regime section 3509 prescribes
- this is the section 3509 gap: IRC section 3509 adjusts the employer’s liability when withholding was missed because the worker was treated as not being an employee, but the state machine leaves the misclassification path with zero liability instead of reduced liability

### 804. Section 3506 companion-sitter employer-exception failure

Model: `work/TaxSection3506CompanionSitterEmployerGap.tla`

Trace:
1. initial state
2. `PlaceSittersWithoutEmployerTreatment`

Observed state:
- `sitterPlacementBusiness = TRUE`
- `paysOrReceivesWages = FALSE`
- `feeBasisOnly = TRUE`
- `treatedAsEmployer = TRUE`

Expected invariant:
- `(sitterPlacementBusiness /\ ~paysOrReceivesWages /\ feeBasisOnly) => ~treatedAsEmployer`

Meaning:
- the model lets a companion-sitter placement business satisfy the statutory fee-basis exception conditions and still remain treated as the employer
- this is the section 3506 gap: IRC section 3506 says a qualifying sitter-placement business is not the employer if it does not pay or receive the wages and is compensated on a fee basis, but the state machine leaves employer status turned on anyway

### 805. Section 3508 real-estate-agent/direct-seller classification failure

Model: `work/TaxSection3508RealEstateDirectSellerGap.tla`

Trace:
1. initial state
2. `ClassifyAsQualifiedAgentOrDirectSeller`

Observed state:
- `qualifiedRealEstateAgent = TRUE`
- `directSeller = TRUE`
- `treatedAsEmployee = TRUE`
- `treatedAsEmployer = TRUE`

Expected invariant:
- `(qualifiedRealEstateAgent \/ directSeller) => /\ ~treatedAsEmployee /\ ~treatedAsEmployer`

Meaning:
- the model lets a qualified real estate agent or direct seller remain in an employee/employer relationship even after the statutory exception applies
- this is the section 3508 gap: IRC section 3508 says these services are outside employee/employer treatment for title 26 purposes, but the state machine keeps both role labels on after classification

### 806. Section 385 debt-equity classification failure

Model: `work/TaxSection385DebtEquityClassificationGap.tla`

Trace:
1. initial state
2. `IssueHybridInstrument`

Observed state:
- `corporateInterestIssued = TRUE`
- `classifiedAsStock = FALSE`
- `classifiedAsDebt = FALSE`

Expected invariant:
- `corporateInterestIssued => (classifiedAsStock \/ classifiedAsDebt)`

Meaning:
- the model lets a corporate interest be issued without classifying it as either stock or debt
- this is the section 385 gap: IRC section 385 exists to determine whether corporate interests should be treated as stock or indebtedness, but the state machine leaves the hybrid instrument unresolved after issuance

### 807. Section 404A foreign deferred compensation timing failure

Model: `work/TaxSection404AForeignDeferredCompTimingGap.tla`

Trace:
1. initial state
2. `MakeForeignPlanPayment`

Observed state:
- `foreignPlanPaymentMade = TRUE`
- `properYearArrived = FALSE`
- `deductionTaken = TRUE`

Expected invariant:
- `deductionTaken => properYearArrived`

Meaning:
- the model lets an employer take a deduction for a foreign deferred compensation payment before the year in which the amount is properly taken into account
- this is the section 404A gap: IRC section 404A allows deduction only for the taxable year in which the amount is properly taken into account under the section, but the state machine permits the deduction path to fire in the same step as payment with no proper-year state yet reached

### 808. Section 403 employee annuity taxability failure

Model: `work/TaxSection403EmployeeAnnuityTaxabilityGap.tla`

Trace:
1. initial state
2. `PurchaseAndDistributeAnnuity`

Observed state:
- `employerPurchasedAnnuity = TRUE`
- `distributionOccurred = TRUE`
- `taxableToDistributee = FALSE`

Expected invariant:
- `(employerPurchasedAnnuity /\ distributionOccurred) => taxableToDistributee`

Meaning:
- the model lets an employer-purchased annuity be distributed without making the amount taxable to the distributee under the annuity rule
- this is the section 403 gap: IRC section 403 says the distribution is taxable to the distributee under section 72, but the state machine allows the distribution step with no taxable-to-distributee state

### 809. Section 402 employees' trust taxability failure

Model: `work/TaxSection402EmployeesTrustTaxabilityGap.tla`

Trace:
1. initial state
2. `DistributeFromExemptTrust`

Observed state:
- `exemptEmployeesTrust = TRUE`
- `distributionOccurred = TRUE`
- `taxableToDistributee = FALSE`

Expected invariant:
- `(exemptEmployeesTrust /\ distributionOccurred) => taxableToDistributee`

Meaning:
- the model lets an exempt employees' trust make a distribution without making that amount taxable to the distributee under the trust-distribution rule
- this is the section 402 gap: IRC section 402 says the amount actually distributed is taxable to the distributee in the year distributed under section 72, but the state machine allows the distribution path to complete with no taxable-to-distributee state

### 810. Section 415 defined-contribution limit failure

Model: `work/TaxSection415DefinedContributionLimitGap.tla`

Trace:
1. initial state
2. `MakeExcessContribution`

Observed state:
- `definedContributionPlan = TRUE`
- `contributionMade = 150`
- `qualifiedTrustMaintained = TRUE`

Expected invariant:
- `(definedContributionPlan /\ contributionMade > Limit0) => ~qualifiedTrustMaintained`

Meaning:
- the model lets a defined contribution plan accept a contribution above the statutory limit while still remaining a qualified trust
- this is the section 415 gap: IRC section 415 disqualifies or limits qualified-plan status when contributions exceed the applicable ceiling, but the state machine allows the excess-contribution path to complete with qualification still on

### 811. Section 416 top-heavy-plan compliance failure

Model: `work/TaxSection416TopHeavyPlanComplianceGap.tla`

Trace:
1. initial state
2. `AdoptTopHeavyPlanWithoutCompliance`

Observed state:
- `topHeavyPlan = TRUE`
- `vestingRequirementsMet = FALSE`
- `minimumBenefitRequirementsMet = FALSE`
- `qualifiedTrustMaintained = TRUE`

Expected invariant:
- `topHeavyPlan => /\ vestingRequirementsMet /\ minimumBenefitRequirementsMet /\ ~qualifiedTrustMaintained`

Meaning:
- the model lets a top-heavy plan exist without the mandatory vesting and minimum-benefit rules and still treats the trust as qualified
- this is the section 416 gap: IRC section 416 denies qualified-trust status unless the top-heavy plan satisfies both the vesting and minimum-benefit requirements, but the state machine allows the plan to enter top-heavy status with neither compliance branch turned on

### 812. Section 417 QJSA waiver-consent failure

Model: `work/TaxSection417QJSAWaiverConsentGap.tla`

Trace:
1. initial state
2. `WaiveQJSAWithoutConsent`

Observed state:
- `qjsaRequired = TRUE`
- `waiverElectionMade = TRUE`
- `spousalConsentGiven = FALSE`

Expected invariant:
- `(qjsaRequired /\ waiverElectionMade) => spousalConsentGiven`

Meaning:
- the model lets a qualified joint and survivor annuity be waived without spousal consent
- this is the section 417 gap: IRC section 417 conditions the waiver of the QJSA on informed election and spousal consent, but the state machine allows the waiver path to complete with no consent state

### 813. Section 419A qualified asset account limit failure

Model: `work/TaxSection419AQualifiedAssetAccountLimitGap.tla`

Trace:
1. initial state
2. `AddFundingWithoutLimitCheck`

Observed state:
- `qualifiedAssetAccount = TRUE`
- `accountBalance = 150`
- `qualifiedStatusMaintained = TRUE`

Expected invariant:
- `(qualifiedAssetAccount /\ accountBalance > Limit0) => ~qualifiedStatusMaintained`

Meaning:
- the model lets a qualified asset account exceed its actuarial and statutory limit while keeping the account qualified
- this is the section 419A gap: IRC section 419A caps the qualified asset account and ties qualification to those limits, but the state machine allows funding above the cap with qualified status still on

### 814. Section 422 incentive stock option holding-period failure

Model: `work/TaxSection422IncentiveStockOptionHoldingGap.tla`

Trace:
1. initial state
2. `ExerciseAndDisposeTooEarly`

Observed state:
- `isoGranted = TRUE`
- `stockTransferred = TRUE`
- `holdingPeriodSatisfied = FALSE`

Expected invariant:
- `(isoGranted /\ stockTransferred) => holdingPeriodSatisfied`

Meaning:
- the model lets an incentive stock option be exercised and the stock transferred before the statutory holding period is satisfied
- this is the section 422 gap: IRC section 422 conditions favorable ISO treatment on the holding period, but the state machine allows the exercise/disposition path to complete while the holding-period state remains false

### 815. Section 423 employee stock purchase plan requirements failure

Model: `work/TaxSection423EmployeeStockPurchasePlanGap.tla`

Trace:
1. initial state
2. `ExerciseAndTransferTooEarly`

Observed state:
- `esppGranted = TRUE`
- `employeeStillEmployed = FALSE`
- `holdingPeriodSatisfied = FALSE`
- `favorableTreatmentAvailable = TRUE`

Expected invariant:
- `esppGranted => /\ employeeStillEmployed /\ holdingPeriodSatisfied /\ favorableTreatmentAvailable`

Meaning:
- the model lets an employee stock purchase plan option be exercised and transferred without the employment and holding-period gates that preserve favorable treatment
- this is the section 423 gap: IRC section 423 conditions favorable ESPP treatment on employment and holding period requirements, but the state machine allows the option path to complete with those gates still closed

### 816. Section 424 option-substitution extra-benefits failure

Model: `work/TaxSection424OptionSubstitutionExtraBenefitsGap.tla`

Trace:
1. initial state
2. `SubstituteOptionWithExtraBenefits`

Observed state:
- `optionSubstitutedOrAssumed = TRUE`
- `additionalEmployeeBenefitsGiven = TRUE`
- `qualifyingSection424Treatment = TRUE`

Expected invariant:
- `optionSubstitutedOrAssumed => /\ ~additionalEmployeeBenefitsGiven /\ qualifyingSection424Treatment`

Meaning:
- the model lets an option substitution or assumption happen while still giving the employee extra benefits the statute says must not be present
- this is the section 424 gap: IRC section 424’s substitution rule preserves tax treatment only when the new option does not confer additional benefits, but the state machine allows the substitution path to complete with extra benefits turned on

### 817. Section 430 minimum required contribution failure

Model: `work/TaxSection430MinimumRequiredContributionGap.tla`

Trace:
1. initial state
2. `EndPlanYearWithoutPayingContribution`

Observed state:
- `planYearEnded = TRUE`
- `minimumRequiredContributionDue = TRUE`
- `minimumRequiredContributionPaid = FALSE`

Expected invariant:
- `minimumRequiredContributionDue => minimumRequiredContributionPaid`

Meaning:
- the model lets a plan year close with a minimum required contribution due but unpaid
- this is the section 430 gap: IRC section 430 requires the plan’s minimum required contribution to be satisfied, but the state machine allows the year-end path to complete with the due contribution still unpaid

### 818. Section 432 rehabilitation-plan deadline failure

Model: `work/TaxSection432CriticalStatusRehabilitationGap.tla`

Trace:
1. initial state
2. `EnterCriticalStatusWithoutRehabPlan`

Observed state:
- `criticalStatus = TRUE`
- `rehabPlanAdopted = FALSE`
- `deadlinePassed = TRUE`

Expected invariant:
- `(criticalStatus /\ deadlinePassed) => rehabPlanAdopted`

Meaning:
- the model lets a multiemployer plan enter critical status and pass the statutory adoption deadline without adopting a rehabilitation plan
- this is the section 432 gap: IRC section 432 requires a rehabilitation plan after critical status is certified, but the state machine allows the deadline path to complete with no rehab plan state at all

### 819. Section 433 funding-restoration-plan deadline failure

Model: `work/TaxSection433FundingRestorationPlanGap.tla`

Trace:
1. initial state
2. `EnterFundingRestorationWithoutPlan`

Observed state:
- `fundingRestorationStatus = TRUE`
- `fundingRestorationPlanAdopted = FALSE`
- `deadlinePassed = TRUE`

Expected invariant:
- `(fundingRestorationStatus /\ deadlinePassed) => fundingRestorationPlanAdopted`

Meaning:
- the model lets a CSEC plan enter funding restoration status and pass the deadline without adopting a funding restoration plan
- this is the section 433 gap: IRC section 433 requires a written funding restoration plan within the deadline, but the state machine allows the deadline path to complete with no funding-restoration plan state present

### 820. Section 436 funding-based benefit restriction failure

Model: `work/TaxSection436FundingBasedBenefitRestrictionGap.tla`

Trace:
1. initial state
2. `PayShutdownBenefitWhileUnderfunded`

Observed state:
- `fundingPercentage = 55`
- `shutdownBenefitPaid = TRUE`
- `benefitRestrictionApplies = FALSE`

Expected invariant:
- `(fundingPercentage < 60 /\ shutdownBenefitPaid) => benefitRestrictionApplies`

Meaning:
- the model lets a single-employer plan pay a shutdown benefit while the plan is below the funding threshold that should trigger benefit restrictions
- this is the section 436 gap: IRC section 436 restricts benefits and accruals at low funding percentages, but the state machine allows the benefit payment path to complete with no restriction state active

### 821. Section 441 no-books calendar-year failure

Model: `work/TaxSection441NoBooksCalendarYearGap.tla`

Trace:
1. initial state
2. `UseNonqualifyingAnnualPeriodWithoutCalendarYear`

Observed state:
- `booksKept = FALSE`
- `annualAccountingPeriodQualifies = FALSE`
- `taxableYearIsCalendarYear = FALSE`

Expected invariant:
- `(~booksKept \/ ~annualAccountingPeriodQualifies) => taxableYearIsCalendarYear`

Meaning:
- the model lets a taxpayer with no books and no qualifying annual accounting period use something other than the calendar year as the taxable year
- this is the section 441 gap: IRC section 441 defaults the taxable year to the calendar year when the taxpayer keeps no books or has no qualifying annual accounting period, but the state machine allows the nonqualifying period path to complete without forcing the calendar-year fallback

### 822. Section 443 short-period annualization failure

Model: `work/TaxSection443ShortPeriodAnnualizationGap.tla`

Trace:
1. initial state
2. `FileShortPeriodReturnWithoutAnnualization`

Observed state:
- `shortPeriodReturnFiled = TRUE`
- `annualizationApplied = FALSE`
- `taxComputedOnShortPeriod = FALSE`

Expected invariant:
- `shortPeriodReturnFiled => annualizationApplied`

Meaning:
- the model lets a short-period return be filed without applying the annualization rule that section 443 requires for the tax computation
- this is the section 443 gap: IRC section 443 requires special annualization treatment for certain short-period returns, but the state machine allows the filing path to complete with no annualization state present

### 823. Section 442 annual accounting period approval failure

Model: `work/TaxSection442AnnualAccountingPeriodApprovalGap.tla`

Trace:
1. initial state
2. `ChangeAccountingPeriodWithoutApproval`

Observed state:
- `accountingPeriodChanged = TRUE`
- `secretaryApprovedChange = FALSE`
- `newAccountingPeriodBecomesTaxableYear = TRUE`

Expected invariant:
- `accountingPeriodChanged => (secretaryApprovedChange /\ newAccountingPeriodBecomesTaxableYear)`

Meaning:
- the model lets a taxpayer change the annual accounting period without Secretary approval and still make the new period the taxable year
- this is the section 442 gap: IRC section 442 requires Secretary approval for an annual accounting-period change to become effective, but the state machine allows the change path to complete with no approval state present
