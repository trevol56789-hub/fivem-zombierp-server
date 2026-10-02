# FiveM ZombieRP Server - Versión Mejorada

## 🧟 Características principales

✅ **Sistema de Zombis Avanzado**
- Oleadas progresivas de zombis
- IA mejorada con comportamientos realistas
- Daño dinámico y vida escalable
- Múltiples tipos de zombis
- Spawning automático por zonas

✅ **Battle Pass Completo**
- 50 niveles con recompensas escaladas
- Sistema de XP por kills, oleadas y eventos
- Premium vs Free pass
- Historial de recompensas reclamadas
- Progreso guardado en BD

✅ **Mapa Interactivo**
- 8 zonas de combate principales
- 3 zonas seguras
- Teleportación entre zonas
- Navegación GPS
- Marcadores en mapa
- Eventos zonales activos

✅ **Sistema de Loot**
- Loot por zombis muertos
- Probabilidades dinámicas
- Items escalables por nivel
- Armas progresivas
- Dinero y suministros médicos

✅ **Recompensas y Progresión**
- Sistema de puntos por acción
- Multiplicadores de recompensa
- Bonificaciones por oleada
- Rankings de jugadores
- Logros desbloqueables

✅ **Zonas Seguras**
- 3 localizaciones protegidas
- Recarga de munición
- Curación automática
- Comerciante NPC
- Respawn seguro

## 📋 Instalación

### Requisitos
- FiveM Server (build reciente)
- QBCore Framework
- oxmysql o mysql-async
- Node.js (opcional, para herramientas de desarrollo)

### Pasos de instalación

1. **Clona el repositorio**
```bash
cd resources
git clone https://github.com/trevol56789-hub/fivem-zombierp-server.git [qb]/qb-zombierp
```

2. **Asegúrate de tener QBCore**
```
ensure qb-core
ensure qb-menu
ensure qb-input
ensure qb-target
ensure qb-inventory
```

3. **Añade a server.cfg**
```cfg
ensure qb-zombierp
```

4. **Crea la base de datos** (si usas MySQL)
```sql
CREATE TABLE IF NOT EXISTS `battlepass_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL UNIQUE,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 0,
  `season` int(11) DEFAULT 1,
  `is_premium` tinyint(1) DEFAULT 0,
  `claimed_rewards` text,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `zombie_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `kills` int(11) DEFAULT 0,
  `waves_completed` int(11) DEFAULT 0,
  `total_damage` bigint DEFAULT 0,
  `total_money_earned` bigint DEFAULT 0,
  `playtime_seconds` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizen` (`citizenid`)
);
```

5. **Inicia el servidor**
```
start qb-zombierp
```

## 🎮 Comandos principales

| Comando | Descripción | Admin |
|---------|-------------|-------|
| `/battlepass` | Abre el menú de Battle Pass | ✓ |
| `/mapa` o `/map` | Abre el mapa de zonas | ✓ |
| `/zombiewave` | Inicia una oleada manual | ✗ |
| `/zombiestat` | Ver estadísticas personales | ✓ |
| `/zonaevent [nombre]` | Inicia evento en zona | ✗ (admin) |
| `/resetsalud` | Recarga salud en zona segura | ✓ |

## ⚙️ Configuración

Edita `config.lua` y `shared/battlepass_config.lua` para:

- Cantidad de zombis por oleada
- Daño y vida de zombis
- Intervalo de oleadas
- Zonas seguras y coordenadas
- Tabla de recompensas
- Costo de premium
- Items de loot y probabilidades

## 📊 Estructura de carpetas

```
qb-zombierp/
├── client/
│   ├── client.lua          # Lógica principal cliente
│   ├── battlepass.lua      # UI Battle Pass
│   ├── map_ui.lua          # UI Mapa interactivo
│   └── events.lua          # Eventos del cliente
├── server/
│   ├── server.lua          # Lógica principal servidor
│   ├── battlepass.lua      # Sistema BP
│   ├── map_zones.lua       # Gestión de zonas
│   ├── database.lua        # Conexión BD
│   └── rewards.lua         # Sistema de recompensas
├── shared/
│   ├── shared.lua          # Config compartida
│   └── battlepass_config.lua # Config BP
├── html/
│   ├── index.html          # Interfaz gráfica
│   └── css/
│       └── style.css       # Estilos mejorados
├── config.lua              # Configuración principal
├── fxmanifest.lua          # Manifest del recurso
└── README.md               # Este archivo
```

## 🔧 API y Eventos

### Eventos del servidor

```lua
-- Registrar una muerte de zombie
TriggerServerEvent('qb-zombierp:server:registerKill', waveNumber)

-- Completar oleada
TriggerServerEvent('qb-zombierp:server:waveCleared', waveNumber)

-- Añadir XP al Battle Pass
TriggerServerEvent('qb-battlepass:server:addXP', amount)

-- Reclamar recompensa del BP
TriggerServerEvent('qb-battlepass:server:claimReward', level)
```

### Callbacks

```lua
-- Obtener datos del Battle Pass
QBCore.Functions.TriggerCallback('qb-battlepass:server:getBattlePassData', function(bp)
    print("Nivel:", bp.level)
    print("XP:", bp.xp)
end)

-- Obtener zonas del mapa
QBCore.Functions.TriggerCallback('qb-zombierp:server:getMapZones', function(zones)
    for _, zone in ipairs(zones) do
        print(zone.name)
    end
end)
```

## 🎯 Sistema de puntuación

- **Matar un zombie**: 50 XP + $25-75
- **Completar oleada**: 500 XP + $150-300
- **Evento de zona**: 250 XP + $100-200
- **Logro especial**: 1000 XP + $500
- **Bono premium**: x1.25 multiplicador

## 💡 Personalización avanzada

### Añadir nuevas zonas

Edita `config.lua` en `ZOMBIE_CONFIG.safeZones` o `MAP_CONFIG.zones`:

```lua
{
    name = 'Mi Zona',
    coords = vector3(x, y, z),
    radius = 100.0,
    zombies = 15
}
```

### Añadir nuevos items de loot

Edita `ZOMBIE_CONFIG.lootTable`:

```lua
{
    item = 'tu_item',
    amount = 1,
    chance = 0.5 -- 50% de probabilidad
}
```

### Añadir recompensas al Battle Pass

Edita `BATTLEPASS_CONFIG.levelRewards`:

```lua
[51] = { type = 'weapon', weapon = 'minigun' }
[52] = { type = 'cash', amount = 5000 }
```

## 🐛 Solución de problemas

**Los zombis no spawnan**
- Verifica que los modelos estén disponibles
- Comprueba que `qb-core` está iniciado
- Revisa los logs del servidor

**El Battle Pass no actualiza**
- Verifica conexión a BD
- Comprueba que `citizenid` es correcto
- Reinicia el recurso

**Las zonas no aparecen en el mapa**
- Verifica coordenadas en `config.lua`
- Comprueba que los blips se cargan en cliente
- Reinicia y reconecta

## 📝 Notas de desarrollo

- El sistema está optimizado para 32-64 jugadores
- Usa eventos de red para sincronización
- La BD almacena progreso del BP automáticamente
- Compatible con `qb-core` v2.x y superior
- Soporta MySQL y SQLite (con adaptación)

## 📄 Licencia

Este proyecto es de código abierto. Siéntete libre de modificarlo.

## 👨‍💻 Créditos

Desarrollado con GitHub Copilot para un servidor de ZombieRP.

---

¿Necesitas ayuda? Abre un issue en el repositorio.
