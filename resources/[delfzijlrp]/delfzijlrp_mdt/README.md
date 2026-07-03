# Delfzijl RP MDT

Basis MDT/tablet voor Politie, Ambulance en ANWB.

## Features v0.1

- Command `/mdt`
- Job-lock voor politie, ambulance en ANWB
- Persoon zoeken via naam of Delfzijl ID
- Kenteken/RDW zoeken
- Voertuigdata bekijken
- APK/verzekering/gestolen-status bekijken
- Notities op personen en voertuigen
- Boetes registreren
- Voertuig als gestolen markeren

## Installatie

1. Zorg dat deze resources eerder starten:

```cfg
ensure delfzijlrp_identity
ensure delfzijlrp_vehicles
```

2. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_mdt/sql/mdt.sql
```

3. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_mdt
```

## Rechten

Standaard toegang:

- `police`
- `ambulance`
- `mechanic`

Aanpassen kan in `config.lua`.

## Volgende stappen

- React/NUI tablet UI
- Dispatch meldingen
- Arrestatiehistorie
- Medisch dossier
- ANWB reparatiehistorie
- Boetes koppelen aan banking/billing
- Politie kenteken-scanner
