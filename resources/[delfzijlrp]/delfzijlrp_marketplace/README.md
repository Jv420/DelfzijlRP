# Delfzijl RP Marketplace

Marktplaats-systeem voor Delfzijl RP.

## Features v0.1

- `/marktplaats`
- `/mp`
- Advertenties bekijken
- Categorieën: voertuigen, woningen, items, diensten, bedrijven, overig
- Advertentie plaatsen
- Advertentie beheren
- Status: actief, gereserveerd, verkocht, geannuleerd
- Interessebericht sturen
- Interesseberichten bekijken als verkoper
- Listing fee
- SQL-tabellen

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_marketplace/sql/marketplace.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_marketplace
```

## Commands

```text
/marktplaats
/mp
```

## Telefoon koppeling

In `delfzijlrp_phone` kun je later een native Marktplaats-app toevoegen die simpelweg `/mp` opent of direct de exports gebruikt zodra we die toevoegen.

## Volgende uitbreidingen

- Direct kopen via escrow
- Voertuig overschrijven via RDW
- Woning overschrijven via housing
- Items veilig verkopen via ox_inventory escrow
- Foto's/NUI interface
- Zoekfilters
- Favorieten
- Bedrijfsadvertenties
