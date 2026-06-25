---- MODULE TaxTransferCreditGap ----
EXTENDS TLC

VARIABLES
  transferDone,
  withholdingApplied,
  creditGranted,
  creditUsed

Vars == <<transferDone, withholdingApplied, creditGranted, creditUsed>>

Init ==
  /\ transferDone = FALSE
  /\ withholdingApplied = FALSE
  /\ creditGranted = FALSE
  /\ creditUsed = FALSE

Transfer ==
  /\ ~transferDone
  /\ transferDone' = TRUE
  /\ withholdingApplied' = FALSE
  /\ creditGranted' = FALSE
  /\ creditUsed' = FALSE

ApplyWithholding ==
  /\ transferDone
  /\ ~withholdingApplied
  /\ withholdingApplied' = TRUE
  /\ UNCHANGED <<transferDone, creditGranted, creditUsed>>

GrantCredit ==
  /\ transferDone
  /\ ~creditGranted
  /\ creditGranted' = TRUE
  /\ UNCHANGED <<transferDone, withholdingApplied, creditUsed>>

UseCredit ==
  /\ creditGranted
  /\ ~creditUsed
  /\ creditUsed' = TRUE
  /\ UNCHANGED <<transferDone, withholdingApplied, creditGranted>>

Next ==
  Transfer \/ ApplyWithholding \/ GrantCredit \/ UseCredit

CreditMustBeBackedByWithholding ==
  creditGranted => withholdingApplied

CreditMustFollowTransfer ==
  creditUsed => transferDone

Inv == CreditMustBeBackedByWithholding /\ CreditMustFollowTransfer

====
