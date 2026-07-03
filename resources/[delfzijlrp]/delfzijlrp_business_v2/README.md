# Delfzijl RP Business v2

Bedrijvensysteem voor Delfzijl RP met KVK, personeel, voorraad, facturen en bedrijfsrekening.

## Features v0.2

- `/kvk`
- `/bedrijf2`
- Bedrijf inschrijven bij KVK
- Bedrijfstypes: winkel, transport, horeca, dienstverlening, havenbedrijf, vastgoed, media, overig
- KVK nummer automatisch genereren
- Werknemers beheren
- Rangen: eigenaar, directeur, manager, werknemer
- Salaris per werknemer
- Loon uitbetalen
- Bedrijfsrekening
- Geld storten/opnemen
- Bedrijfsvoorraad via ox_inventory stash
- Facturen maken
- Bedrijfslogs
- KVK balie en bedrijfspunten via ox_target

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_business_v2/sql/business_v2.sql
```

2. Voeg toe aan `server.cfg` na identity, banking2 en ox_inventory:

```cfg
ensure delfzijlrp_business_v2
```

## Commands

```text
/kvk
/bedrijf2
```

## Belangrijk

Deze resource kan naast oudere business resources draaien tijdens testen. Later kun je kiezen welke versie actief blijft.

## Volgende uitbreidingen

- Facturen betalen via banking2
- Telefoon bedrijfs-app
- Marktplaats bedrijfsadvertenties
- Havenbedrijven koppelen aan port
- Bedrijfspanden koppelen aan housing_v2
- Salaris automatisch per periode
- Voorraadcontracten en leveranciers
