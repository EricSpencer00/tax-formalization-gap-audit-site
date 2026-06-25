---- MODULE TaxTreatyGap ----
EXTENDS TLC

CONSTANTS Taxpayers, IncomeEvents

DocStates == {"pending", "valid"}
Statuses == {"earned", "documented", "reported"}

VARIABLES
  owner,
  foreignStatus,
  docStatus,
  treatyClaim,
  status

Vars == <<owner, foreignStatus, docStatus, treatyClaim, status>>

Init ==
  /\ owner \in [IncomeEvents -> Taxpayers]
  /\ foreignStatus = [t \in Taxpayers |-> FALSE]
  /\ docStatus = [e \in IncomeEvents |-> "pending"]
  /\ treatyClaim = [e \in IncomeEvents |-> FALSE]
  /\ status = [e \in IncomeEvents |-> "earned"]

CanDocument(e) == status[e] = "earned"
CanClaimTreaty(e) == docStatus[e] = "valid"

Document(e) ==
  /\ CanDocument(e)
  /\ docStatus' = [docStatus EXCEPT ![e] = "valid"]
  /\ status' = [status EXCEPT ![e] = "documented"]
  /\ UNCHANGED <<owner, foreignStatus, treatyClaim>>

ClaimTreaty(e) ==
  /\ CanClaimTreaty(e)
  /\ treatyClaim' = [treatyClaim EXCEPT ![e] = TRUE]
  /\ status' = [status EXCEPT ![e] = "reported"]
  /\ UNCHANGED <<owner, foreignStatus, docStatus>>

Next ==
  \E e \in IncomeEvents :
    Document(e) \/ ClaimTreaty(e)

NoIllegalTreatyClaim ==
  \A e \in IncomeEvents : treatyClaim[e] => foreignStatus[owner[e]]

Inv == NoIllegalTreatyClaim

====
