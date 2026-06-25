---- MODULE TaxSyntheticDividendGap ----
EXTENDS TLC

VARIABLES
  stockHolder,
  derivativeHolder,
  dividendDeclared,
  stockDividendPaid,
  syntheticDividendPaid,
  stockCreditClaimed,
  syntheticCreditClaimed

Vars == <<stockHolder, derivativeHolder, dividendDeclared, stockDividendPaid, syntheticDividendPaid, stockCreditClaimed, syntheticCreditClaimed>>

Init ==
  /\ stockHolder = "A"
  /\ derivativeHolder = "B"
  /\ dividendDeclared = FALSE
  /\ stockDividendPaid = FALSE
  /\ syntheticDividendPaid = FALSE
  /\ stockCreditClaimed = FALSE
  /\ syntheticCreditClaimed = FALSE

DeclareDividend ==
  /\ ~dividendDeclared
  /\ dividendDeclared' = TRUE
  /\ UNCHANGED <<stockHolder, derivativeHolder, stockDividendPaid, syntheticDividendPaid, stockCreditClaimed, syntheticCreditClaimed>>

PayStockDividend ==
  /\ dividendDeclared
  /\ ~stockDividendPaid
  /\ stockDividendPaid' = TRUE
  /\ UNCHANGED <<stockHolder, derivativeHolder, dividendDeclared, syntheticDividendPaid, stockCreditClaimed, syntheticCreditClaimed>>

PaySyntheticDividend ==
  /\ dividendDeclared
  /\ ~syntheticDividendPaid
  /\ syntheticDividendPaid' = TRUE
  /\ UNCHANGED <<stockHolder, derivativeHolder, dividendDeclared, stockDividendPaid, stockCreditClaimed, syntheticCreditClaimed>>

ClaimStockCredit ==
  /\ stockDividendPaid
  /\ ~stockCreditClaimed
  /\ stockCreditClaimed' = TRUE
  /\ UNCHANGED <<stockHolder, derivativeHolder, dividendDeclared, stockDividendPaid, syntheticDividendPaid, syntheticCreditClaimed>>

ClaimSyntheticCredit ==
  /\ syntheticDividendPaid
  /\ ~syntheticCreditClaimed
  /\ syntheticCreditClaimed' = TRUE
  /\ UNCHANGED <<stockHolder, derivativeHolder, dividendDeclared, stockDividendPaid, syntheticDividendPaid, stockCreditClaimed>>

Next ==
  DeclareDividend \/ PayStockDividend \/ PaySyntheticDividend \/ ClaimStockCredit \/ ClaimSyntheticCredit

OneDividendOneCredit ==
  ~(stockCreditClaimed /\ syntheticCreditClaimed)

Inv == OneDividendOneCredit

====
