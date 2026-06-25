---- MODULE TaxConstructiveSaleGap ----
EXTENDS TLC

VARIABLES
  positionOpen,
  hedgeEntered,
  economicExit,
  gainRecognized

Vars == <<positionOpen, hedgeEntered, economicExit, gainRecognized>>

Init ==
  /\ positionOpen = TRUE
  /\ hedgeEntered = FALSE
  /\ economicExit = FALSE
  /\ gainRecognized = FALSE

EnterHedge ==
  /\ positionOpen
  /\ ~hedgeEntered
  /\ hedgeEntered' = TRUE
  /\ economicExit' = TRUE
  /\ gainRecognized' = FALSE
  /\ UNCHANGED positionOpen

RecognizeGain ==
  /\ economicExit
  /\ ~gainRecognized
  /\ gainRecognized' = TRUE
  /\ UNCHANGED <<positionOpen, hedgeEntered, economicExit>>

Next ==
  EnterHedge \/ RecognizeGain

ConstructiveSaleMustRecognize ==
  economicExit => gainRecognized

Inv == ConstructiveSaleMustRecognize

====
