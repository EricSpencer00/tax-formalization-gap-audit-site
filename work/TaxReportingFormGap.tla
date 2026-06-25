---- MODULE TaxReportingFormGap ----
EXTENDS TLC

VARIABLES
  paymentMade,
  reportedOn1099,
  reportedOn1042S,
  formMismatch

Vars == <<paymentMade, reportedOn1099, reportedOn1042S, formMismatch>>

Init ==
  /\ paymentMade = FALSE
  /\ reportedOn1099 = FALSE
  /\ reportedOn1042S = FALSE
  /\ formMismatch = FALSE

MakePayment ==
  /\ ~paymentMade
  /\ paymentMade' = TRUE
  /\ UNCHANGED <<reportedOn1099, reportedOn1042S, formMismatch>>

Report1099 ==
  /\ paymentMade
  /\ ~reportedOn1099
  /\ reportedOn1099' = TRUE
  /\ formMismatch' = reportedOn1042S
  /\ UNCHANGED <<paymentMade, reportedOn1042S>>

Report1042S ==
  /\ paymentMade
  /\ ~reportedOn1042S
  /\ reportedOn1042S' = TRUE
  /\ formMismatch' = reportedOn1099
  /\ UNCHANGED <<paymentMade, reportedOn1099>>

Next ==
  MakePayment \/ Report1099 \/ Report1042S

NoConflictingForms ==
  ~(reportedOn1099 /\ reportedOn1042S)

Inv == NoConflictingForms

====
