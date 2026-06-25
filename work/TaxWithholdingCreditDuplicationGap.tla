---- MODULE TaxWithholdingCreditDuplicationGap ----
EXTENDS TLC

VARIABLES
  paymentMade,
  withholdingApplied,
  creditOnFormA,
  creditOnFormB

Vars == <<paymentMade, withholdingApplied, creditOnFormA, creditOnFormB>>

Init ==
  /\ paymentMade = FALSE
  /\ withholdingApplied = FALSE
  /\ creditOnFormA = FALSE
  /\ creditOnFormB = FALSE

MakePayment ==
  /\ ~paymentMade
  /\ paymentMade' = TRUE
  /\ UNCHANGED <<withholdingApplied, creditOnFormA, creditOnFormB>>

ApplyWithholding ==
  /\ paymentMade
  /\ ~withholdingApplied
  /\ withholdingApplied' = TRUE
  /\ UNCHANGED <<paymentMade, creditOnFormA, creditOnFormB>>

ClaimCreditOnFormA ==
  /\ withholdingApplied
  /\ ~creditOnFormA
  /\ creditOnFormA' = TRUE
  /\ UNCHANGED <<paymentMade, withholdingApplied, creditOnFormB>>

ClaimCreditOnFormB ==
  /\ withholdingApplied
  /\ ~creditOnFormB
  /\ creditOnFormB' = TRUE
  /\ UNCHANGED <<paymentMade, withholdingApplied, creditOnFormA>>

Next ==
  MakePayment \/ ApplyWithholding \/ ClaimCreditOnFormA \/ ClaimCreditOnFormB

NoDuplicateCreditRecognition ==
  ~(creditOnFormA /\ creditOnFormB)

Inv == NoDuplicateCreditRecognition

====
