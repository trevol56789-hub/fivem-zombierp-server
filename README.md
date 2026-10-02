# FiveM ZombieRP Server (QBCore)

Este repositorio contiene una base modular lista para un servidor FiveM zombie con QBCore, diseñada para arrancar con:

- Aparición automática de zombis
- Sistema de vida y daño
- Zombis atacando a jugadores
- Oleadas de zombis progresivas
- Sistema de recompensas y botín
- Zonas seguras
- Respawn de jugadores
- Lista para integrarse con QB-Core

## Requisitos

- FiveM Server Artifact reciente
- QBCore Framework instalado
- OxMysql o MySQL compatible con QBCore
- Git para clonar este repositorio

## Estructura principal

```text
resources/
  [qb]/
    qb-zombierp/
      client/
      server/
      shared/
      config.lua
      fxmanifest.lua
server.cfg
README.md
```

## Instalación rápida

1. Clona este repositorio dentro de tu carpeta `resources` del servidor FiveM.
2. Asegúrate de que `qb-core` esté instalado y arrancando en tu servidor.
3. Abre tu `server.cfg` y confirma que `ensure qb-zombierp` esté presente.
4. Inicia el servidor.

## Configuración

Edita el archivo:

- `resources/[qb]/qb-zombierp/config.lua`

Aquí puedes modificar:

- cantidad de zombis por oleada
- radio de spawn
- zonas seguras
- recompensas por oleada
- botín y items

## Archivos clave

- `server/server.lua` — lógica del servidor, oleadas, recompensas, loot
- `client/client.lua` — spawning y IA local del zombie
- `shared/shared.lua` — configuración compartida
- `config.lua` — constantes principales del sistema

## Nota

Este proyecto es una base funcional modular y está listo para ser extendida con:

- inventario QB
- misiones de supervivencia
- eventos por zonas
- recompensas por nivel
- más tipos de zombis
- sistemas de boss zombie

## Créditos

Proyecto base generado para un servidor QBCore ZombieRP.
