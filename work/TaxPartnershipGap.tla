---- MODULE TaxPartnershipGap ----
EXTENDS Naturals, TLC

VARIABLES
  contributionDone,
  distributionDone,
  considerationPaid,
  saleRecognized,
  insideBasis,
  outsideBasis

Vars == <<contributionDone, distributionDone, considerationPaid, saleRecognized, insideBasis, outsideBasis>>

Init ==
  /\ contributionDone = FALSE
  /\ distributionDone = FALSE
  /\ considerationPaid = FALSE
  /\ saleRecognized = FALSE
  /\ insideBasis = 100
  /\ outsideBasis = 100

Contribute ==
  /\ ~contributionDone
  /\ contributionDone' = TRUE
  /\ insideBasis' = insideBasis
  /\ outsideBasis' = outsideBasis
  /\ distributionDone' = distributionDone
  /\ considerationPaid' = considerationPaid
  /\ saleRecognized' = saleRecognized

Distribute ==
  /\ contributionDone
  /\ ~distributionDone
  /\ distributionDone' = TRUE
  /\ considerationPaid' = TRUE
  /\ insideBasis' = insideBasis
  /\ outsideBasis' = outsideBasis
  /\ contributionDone' = contributionDone
  /\ saleRecognized' = saleRecognized

Next ==
  Contribute \/ Distribute

DisguisedSaleMustRecognize ==
  contributionDone /\ distributionDone /\ considerationPaid => saleRecognized

Inv == DisguisedSaleMustRecognize

====
