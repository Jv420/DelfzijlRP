# Fanta Control API

Deze resource koppelt `fanta.delfzijlrp.nl` met je FiveM server.

## Installatie

1. Zet de resource in je server:

```cfg
ensure delfzijlrp_v3_controlapi
```

2. Pas `config.lua` aan:

```lua
Config.ApiKey = 'maak-hier-een-lange-geheime-key'
```

3. Herstart:

```cfg
restart delfzijlrp_v3_controlapi
```

4. Vul in het webpanel:

```txt
API URL: http://JOUW-IP:30120/drcc
API Key: dezelfde key uit config.lua
```

## Huidige endpoints

- `GET /drcc/status`
- `POST /drcc/announce`

## Volgende veilige uitbreidingen

- rewards queue
- RDW beheer
- KVK beheer
- Kadaster beheer
- logs ophalen

Voor echte geld/items/voertuig acties is het veiliger om met een queue en server-side bevestiging te werken, niet direct open endpoints.
