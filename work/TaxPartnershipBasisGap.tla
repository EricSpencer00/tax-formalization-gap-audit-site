---- MODULE TaxPartnershipBasisGap ----
EXTENDS Naturals, TLC

VARIABLES
  contributionDone,
  incomeAllocated,
  distributionDone,
  insideBasis,
  outsideBasis

Vars == <<contributionDone, incomeAllocated, distributionDone, insideBasis, outsideBasis>>

Init ==
  /\ contributionDone = FALSE
  /\ incomeAllocated = FALSE
  /\ distributionDone = FALSE
  /\ insideBasis = 100
  /\ outsideBasis = 100

Contribute ==
  /\ ~contributionDone
  /\ contributionDone' = TRUE
  /\ insideBasis' = insideBasis
  /\ outsideBasis' = outsideBasis
  /\ incomeAllocated' = incomeAllocated
  /\ distributionDone' = distributionDone

AllocateIncome ==
  /\ contributionDone
  /\ ~incomeAllocated
  /\ incomeAllocated' = TRUE
  /\ insideBasis' = insideBasis + 10
  /\ UNCHANGED <<contributionDone, distributionDone, outsideBasis>>

Distribute ==
  /\ contributionDone
  /\ ~distributionDone
  /\ distributionDone' = TRUE
  /\ outsideBasis' = outsideBasis - 5
  /\ UNCHANGED <<contributionDone, incomeAllocated, insideBasis>>

Next ==
  Contribute \/ AllocateIncome \/ Distribute

BasisReconciles ==
  insideBasis = outsideBasis

Inv == BasisReconciles

====
