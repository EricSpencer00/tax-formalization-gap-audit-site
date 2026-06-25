---- MODULE TaxTransferWithholdingGap ----
EXTENDS TLC

VARIABLES
  foreignPartner,
  transferDone,
  transferWithholdingApplied,
  creditGranted

Vars == <<foreignPartner, transferDone, transferWithholdingApplied, creditGranted>>

Init ==
  /\ foreignPartner = TRUE
  /\ transferDone = FALSE
  /\ transferWithholdingApplied = FALSE
  /\ creditGranted = FALSE

Transfer ==
  /\ ~transferDone
  /\ transferDone' = TRUE
  /\ transferWithholdingApplied' = FALSE
  /\ creditGranted' = FALSE
  /\ UNCHANGED foreignPartner

ApplyWithholding ==
  /\ transferDone
  /\ ~transferWithholdingApplied
  /\ transferWithholdingApplied' = TRUE
  /\ UNCHANGED <<foreignPartner, transferDone, creditGranted>>

GrantCredit ==
  /\ transferWithholdingApplied
  /\ ~creditGranted
  /\ creditGranted' = TRUE
  /\ UNCHANGED <<foreignPartner, transferDone, transferWithholdingApplied>>

Next ==
  Transfer \/ ApplyWithholding \/ GrantCredit

TransferRule ==
  transferDone /\ foreignPartner => transferWithholdingApplied

CreditRule ==
  creditGranted => transferWithholdingApplied

Inv == TransferRule /\ CreditRule

====
