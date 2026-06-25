---- MODULE TaxWashSaleGap ----
EXTENDS Naturals, TLC

CONSTANTS Basis0, LossAmt

VARIABLES
  soldAtLoss,
  repurchased,
  replacementBasis,
  deferredLoss

Vars == <<soldAtLoss, repurchased, replacementBasis, deferredLoss>>

Init ==
  /\ soldAtLoss = FALSE
  /\ repurchased = FALSE
  /\ replacementBasis = Basis0
  /\ deferredLoss = 0

SellAtLoss ==
  /\ ~soldAtLoss
  /\ soldAtLoss' = TRUE
  /\ deferredLoss' = LossAmt
  /\ replacementBasis' = replacementBasis
  /\ repurchased' = repurchased

BuyReplacement ==
  /\ soldAtLoss
  /\ ~repurchased
  /\ repurchased' = TRUE
  /\ replacementBasis' = replacementBasis
  /\ soldAtLoss' = soldAtLoss
  /\ deferredLoss' = deferredLoss

Next ==
  SellAtLoss \/ BuyReplacement

WashCarryoverOK ==
  repurchased => replacementBasis = Basis0 + deferredLoss

Inv == WashCarryoverOK

====
