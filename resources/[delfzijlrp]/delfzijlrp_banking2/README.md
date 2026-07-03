# Delfzijl RP Banking 2.0

Bankingsysteem voor Delfzijl RP met IBAN, transacties en overschrijvingen.

## Features v0.1

- `/bank`
- `/atm`
- Automatisch IBAN aanmaken
- Banksaldo en contant geld bekijken
- Geld storten
- Geld opnemen
- Overschrijven naar IBAN
- Transactiekosten
- Transactielogboek
- Banklocaties met blips
- ATM targets via ox_target

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_banking2/sql/banking2.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_banking2
```

## Commands

```text
/bank
/atm
```

## Exports

```lua
exports['delfzijlrp_banking2']:GetBankAccount(source)
exports['delfzijlrp_banking2']:LogTransaction(identifier, iban, txType, amount, counterpartyIban, counterpartyName, description)
```

## Volgende uitbreidingen

- Telefoon bank-app
- Bedrijfsrekeningen koppelen
- Facturen native betalen
- Spaarrekeningen
- Leningen
- Crypto wallet
- Admin banklogs
