# Delfzijl RP Groups

Groepen- en organisatiesysteem voor Delfzijl RP.

## Features v0.1

- `/groep`
- Groep aanmaken via organisatiebalie
- Groepstypes: club, community, bedrijfsteam, crew, familie, overig
- Leden en rangen
- Rangen: eigenaar, leider, manager, lid
- Groepsrekening
- Geld storten/opnemen
- Groepsopslag via ox_inventory stash
- Groepslogs
- Groepspunten via ox_target

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_groups/sql/groups.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_groups
```

## Command

```text
/groep
```

## Volgende uitbreidingen

- Gangterritoria
- Groepsgarages
- Groepswoningen
- Groepsactiviteiten
- Telefoon groep-app
- Koppeling met business
- Koppeling met marketplace
- Koppeling met CrimePlus
