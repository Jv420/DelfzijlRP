# Delfzijl RP Court

Rechtbank- en dossiersysteem voor Delfzijl RP.

## Features v0.1

- `/rechtbank`
- Rechtbank blip en ox_target balie
- Toegang voor jobs: judge, lawyer, police
- Rechtbankdossiers aanmaken
- Zaaktypes: strafzaak, civiel, verkeer, bezwaar/beroep, overig
- Dossierstatussen
- Betrokkene/verdachte koppelen via speler-ID
- Notities toevoegen
- Zittingen plannen
- Uitspraak/vonnis/status bijwerken
- Boetebedrag registreren
- MDT shortcut
- SQL-tabellen

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_court/sql/court.sql
```

2. Voeg toe aan `server.cfg` na identity en MDT:

```cfg
ensure delfzijlrp_court
```

## Command

```text
/rechtbank
```

## Jobs

Standaard toegang:

```text
judge
lawyer
police
```

Aanpassen kan in `config.lua`.

## Volgende uitbreidingen

- Advocatenkantoor job
- Gevangenis/prison koppeling
- Boetes direct naar banking/facturen
- Kalenderkoppeling voor zittingen
- Publieke rechtbankagenda
- Bewijsstukken uploaden/koppelen
- NUI rechtbanktablet
