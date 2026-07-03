# Delfzijl RP Housing

Woningensysteem voor Delfzijl RP.

## Features v0.1

- Koopwoningen
- Huurwoningen
- Woningtoegang via sleutels
- Sleutels delen met spelers
- Interieur teleport
- Opslag/stash via ox_inventory
- `/woning` voor overzicht van je woningen/sleutels
- ox_target interacties

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_housing/sql/housing.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_housing
```

## Command

```text
/woning
```

## Configuratie

Nieuwe woningen voeg je toe in `config.lua` onder `Config.Houses`.

Belangrijke velden:

- `id`: unieke woning-ID
- `label`: naam van de woning
- `price`: koopprijs
- `rent`: huurprijs
- `door`: ingang buiten
- `inside`: spawnplek binnen
- `exit`: uitgang binnen
- `stash`: opslaglocatie binnen

## Volgende uitbreidingen

- Makelaar job koppeling
- Bedrijfspanden
- Deurbellen
- CCTV
- Inbraak/alarmsysteem
- Meerdere interieurtypes
- Woningbelasting
- Huur automatisch verlengen
- Telefoon-app integratie
