# Delfzijl RP Business

Bedrijven- en economieplatform voor Delfzijl RP.

## Features v0.1

- Bedrijf registreren via KVK-loket
- Command `/bedrijf`
- Bedrijfstypes
- Medewerkers
- Rangen: Eigenaar, Manager, Medewerker
- Salarisveld per medewerker
- Bedrijfsrekening
- Geld storten/opnemen
- Facturen aan spelers maken
- Facturen betalen
- SQL-tabellen

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_business/sql/business.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_business
```

## Command

```text
/bedrijf
```

## Volgende uitbreidingen

- Telefoon-app voor bedrijven
- Facturen koppelen aan banking UI
- Bedrijfspanden/housing koppeling
- Voorraad en opslag via ox_inventory stashes
- Salaris automatisch uitbetalen
- Leveringsmissies
- Bedrijfsvoertuigen koppelen aan garages
- Web/admin panel
