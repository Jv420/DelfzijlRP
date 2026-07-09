# Optimisation Guide

Deze guide helpt om het texture pack mooi én speelbaar te houden.

## Aanbevolen resoluties

| Onderdeel | Lite | Balanced | Ultra |
|---|---:|---:|---:|
| Wegen | 1024/2048 | 2048 | 2048/4096 |
| Billboards | 1024 | 2048 | 4096 |
| Kleine props | 512/1024 | 1024 | 1024/2048 |
| Voertuig liveries | 1024 | 2048 | 2048/4096 |
| Vegetatie | 1024 | 1024/2048 | 2048 |

## Performance tips

- Gebruik 4K alleen voor grote zichtbare oppervlakken.
- Vermijd veel losse kleine YTD-bestanden; bundel logisch per categorie.
- Test in drukke gebieden met veel spelers/voertuigen.
- Let op VRAM-gebruik bij spelers met 2GB/4GB videokaarten.
- Comprimeer textures correct in OpenIV/CodeWalker.

## Test checklist

- Server start zonder errors.
- Resource laadt met `ensure delfzijlrp_textures`.
- Geen missing textures.
- Geen roze/paarse textures.
- Geen grote FPS-drop bij spawn.
- Geen extreme texture pop-in.
- Werkt voor ESX Legacy én eventueel QBCore.

## Server.cfg advies

```cfg
# Delfzijl RP visual resources
ensure delfzijlrp_textures
```
