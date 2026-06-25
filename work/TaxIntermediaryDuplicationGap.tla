---- MODULE TaxIntermediaryDuplicationGap ----
EXTENDS TLC

VARIABLES
  paymentMade,
  firstWithholdingApplied,
  secondWithholdingApplied,
  firstCreditGranted,
  secondCreditGranted

Vars == <<paymentMade, firstWithholdingApplied, secondWithholdingApplied, firstCreditGranted, secondCreditGranted>>

Init ==
  /\ paymentMade = FALSE
  /\ firstWithholdingApplied = FALSE
  /\ secondWithholdingApplied = FALSE
  /\ firstCreditGranted = FALSE
  /\ secondCreditGranted = FALSE

MakePayment ==
  /\ ~paymentMade
  /\ paymentMade' = TRUE
  /\ UNCHANGED <<firstWithholdingApplied, secondWithholdingApplied, firstCreditGranted, secondCreditGranted>>

ApplyFirstWithholding ==
  /\ paymentMade
  /\ ~firstWithholdingApplied
  /\ firstWithholdingApplied' = TRUE
  /\ UNCHANGED <<paymentMade, secondWithholdingApplied, firstCreditGranted, secondCreditGranted>>

ApplySecondWithholding ==
  /\ paymentMade
  /\ ~secondWithholdingApplied
  /\ secondWithholdingApplied' = TRUE
  /\ UNCHANGED <<paymentMade, firstWithholdingApplied, firstCreditGranted, secondCreditGranted>>

GrantFirstCredit ==
  /\ firstWithholdingApplied
  /\ ~firstCreditGranted
  /\ firstCreditGranted' = TRUE
  /\ UNCHANGED <<paymentMade, firstWithholdingApplied, secondWithholdingApplied, secondCreditGranted>>

GrantSecondCredit ==
  /\ secondWithholdingApplied
  /\ ~secondCreditGranted
  /\ secondCreditGranted' = TRUE
  /\ UNCHANGED <<paymentMade, firstWithholdingApplied, secondWithholdingApplied, firstCreditGranted>>

Next ==
  MakePayment
  \/ ApplyFirstWithholding
  \/ ApplySecondWithholding
  \/ GrantFirstCredit
  \/ GrantSecondCredit

NoDuplicateWithholding ==
  ~(firstWithholdingApplied /\ secondWithholdingApplied)

NoDuplicateCredit ==
  ~(firstCreditGranted /\ secondCreditGranted)

Inv == NoDuplicateWithholding /\ NoDuplicateCredit

====
