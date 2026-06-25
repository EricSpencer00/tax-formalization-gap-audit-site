---- MODULE TaxCrossBorderCertGap ----
EXTENDS Naturals, TLC

VARIABLES
  paymentMade,
  foreignPayee,
  certificateFiled,
  certificateValid,
  withholdingRate

Vars == <<paymentMade, foreignPayee, certificateFiled, certificateValid, withholdingRate>>

Init ==
  /\ paymentMade = FALSE
  /\ foreignPayee = TRUE
  /\ certificateFiled = FALSE
  /\ certificateValid = FALSE
  /\ withholdingRate = 30

MakePayment ==
  /\ ~paymentMade
  /\ paymentMade' = TRUE
  /\ UNCHANGED <<foreignPayee, certificateFiled, certificateValid, withholdingRate>>

FileCertificate ==
  /\ paymentMade
  /\ ~certificateFiled
  /\ certificateFiled' = TRUE
  /\ certificateValid' = FALSE
  /\ UNCHANGED <<paymentMade, foreignPayee, withholdingRate>>

SetRate ==
  /\ paymentMade
  /\ withholdingRate' = IF certificateFiled THEN 0 ELSE 30
  /\ UNCHANGED <<paymentMade, foreignPayee, certificateFiled, certificateValid>>

Next ==
  MakePayment \/ FileCertificate \/ SetRate

CorrectRate ==
  foreignPayee /\ ~certificateValid => withholdingRate = 30

Inv == CorrectRate

====
