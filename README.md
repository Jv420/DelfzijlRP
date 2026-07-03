# Delfzijl RP

Professionele FiveM roleplayserver gebouwd op **ESX Legacy**.

## Basisstack

- ESX Legacy
- oxmysql
- ox_lib
- ox_inventory
- ox_target
- ox_doorlock
- MariaDB / MySQL

## Installatie

1. Kopieer `server.cfg.example` naar `server.cfg`.
2. Vul lokaal je FiveM license key, databasegegevens en admin identifier in.
3. Importeer `resources/[delfzijlrp]/delfzijlrp_core/sql/jobs.sql`.
4. Plaats de externe ESX- en ox-resources in de juiste resourcegroepen.
5. Start de server via txAdmin.

## Veiligheid

Commit nooit je echte `server.cfg`, databasewachtwoord, API-keys, Discord-webhooks of FiveM license key.

## Projectstructuur

```text
resources/
├── [core]/
├── [ox]/
├── [esx]/
├── [jobs]/
├── [gameplay]/
├── [phone]/
├── [maps]/
└── [delfzijlrp]/
    └── delfzijlrp_core/
```
