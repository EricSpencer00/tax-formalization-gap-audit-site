---- MODULE TaxCumExThreePartyGap ----
EXTENDS TLC

VARIABLES
  holder,
  recordHolder,
  beneficialOwner,
  dividendDeclared,
  dividendPaid,
  creditClaimed,
  creditedTo

Vars == <<holder, recordHolder, beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

Init ==
  /\ holder = "A"
  /\ recordHolder = "A"
  /\ beneficialOwner = "A"
  /\ dividendDeclared = FALSE
  /\ dividendPaid = FALSE
  /\ creditClaimed = FALSE
  /\ creditedTo = "A"

TransferToB ==
  /\ holder = "A"
  /\ ~dividendPaid
  /\ holder' = "B"
  /\ UNCHANGED <<recordHolder, beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

TransferToC ==
  /\ holder = "B"
  /\ ~dividendPaid
  /\ holder' = "C"
  /\ UNCHANGED <<recordHolder, beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

DeclareDividend ==
  /\ ~dividendDeclared
  /\ holder = "B"
  /\ dividendDeclared' = TRUE
  /\ recordHolder' = holder
  /\ UNCHANGED <<holder, beneficialOwner, dividendPaid, creditClaimed, creditedTo>>

PayDividend ==
  /\ dividendDeclared
  /\ ~dividendPaid
  /\ dividendPaid' = TRUE
  /\ UNCHANGED <<holder, recordHolder, beneficialOwner, dividendDeclared, creditClaimed, creditedTo>>

ClaimCredit ==
  /\ dividendPaid
  /\ ~creditClaimed
  /\ holder = "C"
  /\ creditClaimed' = TRUE
  /\ creditedTo' = holder
  /\ UNCHANGED <<holder, recordHolder, beneficialOwner, dividendDeclared, dividendPaid>>

Next ==
  TransferToB \/ TransferToC \/ DeclareDividend \/ PayDividend \/ ClaimCredit

CumExEntitlementFrozen ==
  creditClaimed => /\ creditedTo = recordHolder
                     /\ recordHolder = beneficialOwner

Inv == CumExEntitlementFrozen

====
