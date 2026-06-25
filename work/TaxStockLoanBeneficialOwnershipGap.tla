---- MODULE TaxStockLoanBeneficialOwnershipGap ----
EXTENDS TLC

VARIABLES
  holder,
  beneficialOwner,
  dividendDeclared,
  dividendPaid,
  creditClaimed,
  creditedTo

Vars == <<holder, beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

Init ==
  /\ holder = "A"
  /\ beneficialOwner = "A"
  /\ dividendDeclared = FALSE
  /\ dividendPaid = FALSE
  /\ creditClaimed = FALSE
  /\ creditedTo = "A"

LoanToB ==
  /\ holder = "A"
  /\ ~dividendPaid
  /\ holder' = "B"
  /\ UNCHANGED <<beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

LoanToC ==
  /\ holder = "B"
  /\ ~dividendPaid
  /\ holder' = "C"
  /\ UNCHANGED <<beneficialOwner, dividendDeclared, dividendPaid, creditClaimed, creditedTo>>

DeclareDividend ==
  /\ ~dividendDeclared
  /\ dividendDeclared' = TRUE
  /\ UNCHANGED <<holder, beneficialOwner, dividendPaid, creditClaimed, creditedTo>>

PayDividend ==
  /\ dividendDeclared
  /\ ~dividendPaid
  /\ dividendPaid' = TRUE
  /\ UNCHANGED <<holder, beneficialOwner, dividendDeclared, creditClaimed, creditedTo>>

ClaimCredit ==
  /\ dividendPaid
  /\ ~creditClaimed
  /\ holder = "C"
  /\ creditClaimed' = TRUE
  /\ creditedTo' = holder
  /\ UNCHANGED <<holder, beneficialOwner, dividendDeclared, dividendPaid>>

Next ==
  LoanToB \/ LoanToC \/ DeclareDividend \/ PayDividend \/ ClaimCredit

BeneficialOwnerFrozen ==
  creditClaimed => creditedTo = beneficialOwner

Inv == BeneficialOwnerFrozen

====
