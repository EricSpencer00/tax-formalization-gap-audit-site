---- MODULE TaxDividendDoubleClaimGap ----
EXTENDS TLC

VARIABLES
  holder,
  recordHolder,
  dividendDeclared,
  dividendPaid,
  recordCreditClaimed,
  currentCreditClaimed

Vars == <<holder, recordHolder, dividendDeclared, dividendPaid, recordCreditClaimed, currentCreditClaimed>>

Init ==
  /\ holder = "A"
  /\ recordHolder = "A"
  /\ dividendDeclared = FALSE
  /\ dividendPaid = FALSE
  /\ recordCreditClaimed = FALSE
  /\ currentCreditClaimed = FALSE

TransferToB ==
  /\ holder = "A"
  /\ ~dividendPaid
  /\ holder' = "B"
  /\ UNCHANGED <<recordHolder, dividendDeclared, dividendPaid, recordCreditClaimed, currentCreditClaimed>>

TransferToC ==
  /\ holder = "B"
  /\ ~dividendPaid
  /\ holder' = "C"
  /\ UNCHANGED <<recordHolder, dividendDeclared, dividendPaid, recordCreditClaimed, currentCreditClaimed>>

DeclareDividend ==
  /\ ~dividendDeclared
  /\ dividendDeclared' = TRUE
  /\ recordHolder' = holder
  /\ UNCHANGED <<holder, dividendPaid, recordCreditClaimed, currentCreditClaimed>>

PayDividend ==
  /\ dividendDeclared
  /\ ~dividendPaid
  /\ dividendPaid' = TRUE
  /\ UNCHANGED <<holder, recordHolder, dividendDeclared, recordCreditClaimed, currentCreditClaimed>>

ClaimRecordCredit ==
  /\ dividendPaid
  /\ ~recordCreditClaimed
  /\ recordHolder = "B"
  /\ recordCreditClaimed' = TRUE
  /\ UNCHANGED <<holder, recordHolder, dividendDeclared, dividendPaid, currentCreditClaimed>>

ClaimCurrentCredit ==
  /\ dividendPaid
  /\ ~currentCreditClaimed
  /\ holder = "C"
  /\ currentCreditClaimed' = TRUE
  /\ UNCHANGED <<holder, recordHolder, dividendDeclared, dividendPaid, recordCreditClaimed>>

Next ==
  TransferToB \/ TransferToC \/ DeclareDividend \/ PayDividend \/ ClaimRecordCredit \/ ClaimCurrentCredit

NoDoubleDividendClaim ==
  ~(recordCreditClaimed /\ currentCreditClaimed)

Inv == NoDoubleDividendClaim

====
