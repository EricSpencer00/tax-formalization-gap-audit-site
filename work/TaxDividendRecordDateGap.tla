---- MODULE TaxDividendRecordDateGap ----
EXTENDS TLC

VARIABLES
  holder,
  recordHolder,
  dividendDeclared,
  dividendPaid,
  creditClaimed,
  creditedTo

Vars == <<holder, recordHolder, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

Init ==
  /\ holder = "A"
  /\ recordHolder = "A"
  /\ dividendDeclared = FALSE
  /\ dividendPaid = FALSE
  /\ creditClaimed = FALSE
  /\ creditedTo = "A"

TransferToB ==
  /\ holder = "A"
  /\ ~dividendPaid
  /\ holder' = "B"
  /\ UNCHANGED <<recordHolder, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

TransferToC ==
  /\ holder = "B"
  /\ ~dividendPaid
  /\ holder' = "C"
  /\ UNCHANGED <<recordHolder, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

DeclareDividend ==
  /\ ~dividendDeclared
  /\ dividendDeclared' = TRUE
  /\ recordHolder' = holder
  /\ UNCHANGED <<holder, dividendPaid, creditClaimed, creditedTo>>

PayDividend ==
  /\ dividendDeclared
  /\ ~dividendPaid
  /\ dividendPaid' = TRUE
  /\ UNCHANGED <<holder, recordHolder, dividendDeclared, creditClaimed, creditedTo>>

ClaimCredit ==
  /\ dividendPaid
  /\ ~creditClaimed
  /\ holder = "C"
  /\ creditClaimed' = TRUE
  /\ creditedTo' = holder
  /\ UNCHANGED <<holder, recordHolder, dividendDeclared, dividendPaid>>

Next ==
  TransferToB \/ TransferToC \/ DeclareDividend \/ PayDividend \/ ClaimCredit

RecordDateEntitlementFrozen ==
  creditClaimed => creditedTo = recordHolder

Inv == RecordDateEntitlementFrozen

====
