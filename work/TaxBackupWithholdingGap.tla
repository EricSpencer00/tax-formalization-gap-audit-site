---- MODULE TaxBackupWithholdingGap ----
EXTENDS Naturals, TLC

CONSTANTS Taxpayers, IncomeEvents

VARIABLES
  tinValid,
  paymentMade,
  backupWithholdingApplied,
  paymentAmount,
  withheldAmount

Vars == <<tinValid, paymentMade, backupWithholdingApplied, paymentAmount, withheldAmount>>

Init ==
  /\ tinValid = FALSE
  /\ paymentMade = FALSE
  /\ backupWithholdingApplied = FALSE
  /\ paymentAmount = 0
  /\ withheldAmount = 0

MakePayment ==
  /\ ~paymentMade
  /\ paymentMade' = TRUE
  /\ paymentAmount' = 100
  /\ backupWithholdingApplied' = FALSE
  /\ withheldAmount' = 0
  /\ UNCHANGED tinValid

ApplyBackupWithholding ==
  /\ paymentMade
  /\ ~backupWithholdingApplied
  /\ backupWithholdingApplied' = TRUE
  /\ withheldAmount' = 24
  /\ UNCHANGED <<tinValid, paymentMade, paymentAmount>>

Next ==
  MakePayment \/ ApplyBackupWithholding

BackupWithholdingRequired ==
  paymentMade /\ ~tinValid => backupWithholdingApplied /\ withheldAmount > 0

Inv == BackupWithholdingRequired

====
