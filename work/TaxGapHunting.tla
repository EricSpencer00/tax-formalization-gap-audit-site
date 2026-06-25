---- MODULE TaxGapHunting ----
EXTENDS Naturals, TLC

CONSTANTS Taxpayers, IncomeEvents

DocStates == {"pending", "valid", "invalid"}
Statuses == {"earned", "documented", "withheld", "reported", "reconciled"}

VARIABLES
  owner,
  withholdingAgent,
  reportedPayee,
  foreignStatus,
  treatyClaim,
  withheld,
  reported,
  docStatus,
  status

Vars == <<owner, withholdingAgent, reportedPayee, foreignStatus, treatyClaim, withheld, reported, docStatus, status>>

Init ==
  /\ owner \in [IncomeEvents -> Taxpayers]
  /\ withholdingAgent \in [IncomeEvents -> Taxpayers]
  /\ reportedPayee \in [IncomeEvents -> Taxpayers]
  /\ foreignStatus = [t \in Taxpayers |-> FALSE]
  /\ treatyClaim = [e \in IncomeEvents |-> FALSE]
  /\ withheld \in [IncomeEvents -> BOOLEAN]
  /\ reported \in [IncomeEvents -> BOOLEAN]
  /\ docStatus \in [IncomeEvents -> DocStates]
  /\ status \in [IncomeEvents -> Statuses]
  /\ \A e \in IncomeEvents :
        /\ status[e] = "earned"
        /\ withheld[e] = FALSE
        /\ reported[e] = FALSE
        /\ docStatus[e] = "pending"
        /\ reportedPayee[e] = owner[e]

CanDocument(e) == status[e] = "earned"
CanWithhold(e) == status[e] \in {"earned", "documented"}
CanReport(e) == docStatus[e] = "valid"
CanReconcile(e) == withheld[e] /\ reported[e] /\ docStatus[e] = "valid"

Document(e) ==
  /\ CanDocument(e)
  /\ docStatus' = [docStatus EXCEPT ![e] = "valid"]
  /\ status' = [status EXCEPT ![e] = "documented"]
  /\ UNCHANGED <<owner, withholdingAgent, reportedPayee, foreignStatus, treatyClaim, withheld, reported>>

Withhold(e) ==
  /\ CanWithhold(e)
  /\ withheld' = [withheld EXCEPT ![e] = TRUE]
  /\ status' = [status EXCEPT ![e] = "withheld"]
  /\ UNCHANGED <<owner, withholdingAgent, reportedPayee, foreignStatus, treatyClaim, reported, docStatus>>

Report(e) ==
  /\ CanReport(e)
  /\ \E p \in Taxpayers :
       reportedPayee' = [reportedPayee EXCEPT ![e] = p]
  /\ reported' = [reported EXCEPT ![e] = TRUE]
  /\ status' = [status EXCEPT ![e] = "reported"]
  /\ UNCHANGED <<owner, withholdingAgent, foreignStatus, treatyClaim, withheld, docStatus>>

ClaimTreaty(e) ==
  /\ CanReport(e)
  /\ treatyClaim' = [treatyClaim EXCEPT ![e] = TRUE]
  /\ status' = [status EXCEPT ![e] = "reported"]
  /\ UNCHANGED <<owner, withholdingAgent, reportedPayee, foreignStatus, withheld, reported, docStatus>>

Reconcile(e) ==
  /\ CanReconcile(e)
  /\ status' = [status EXCEPT ![e] = "reconciled"]
  /\ UNCHANGED <<owner, withholdingAgent, reportedPayee, foreignStatus, treatyClaim, withheld, reported, docStatus>>

Next ==
  \E e \in IncomeEvents :
    Document(e) \/ Withhold(e) \/ Report(e) \/ ClaimTreaty(e) \/ Reconcile(e)

OwnerKnown ==
  \A e \in IncomeEvents : owner[e] \in Taxpayers

NoContradictoryIdentity ==
  \A e \in IncomeEvents : reportedPayee[e] = owner[e]

NoReportWithoutDocs ==
  \A e \in IncomeEvents : reported[e] => docStatus[e] = "valid"

NoReconcileWithoutTriplet ==
  \A e \in IncomeEvents : status[e] = "reconciled" => CanReconcile(e)

NoIllegalTreatyClaim ==
  \A e \in IncomeEvents : treatyClaim[e] => foreignStatus[owner[e]]

Inv == OwnerKnown /\ NoContradictoryIdentity /\ NoReportWithoutDocs /\ NoReconcileWithoutTriplet /\ NoIllegalTreatyClaim

==== 
