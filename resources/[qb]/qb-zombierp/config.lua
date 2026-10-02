-- Configuración mejorada del servidor zombie

ZOMBIE_CONFIG = {
    -- Configuración de oleadas
    debug = true,
    waveInterval = 40000, -- 40 segundos entre oleadas
    maxZombiesPerWave = 12,
    maxZombiesAbsolute = 30,
    spawnRadius = 60.0,
    
    -- Configuración de zombis
    zombieHealth = 300,
    zombieDamage = 15,
    zombieSpeed = 2.0,
    
    -- Configuración de recompensas
    baseReward = 200,
    rewardMultiplier = 1.3,
    
    -- Zonas seguras
    safeZones = {
        {
            name = '🏢 Centro Seguro - Downtown',
            coords = vector3(118.4, -1037.9, 29.3),
            radius = 80.0
        },
        {
            name = '🏥 Bunker Médico - Pillbox',
            coords = vector3(295.7, -1246.7, 29.4),
            radius = 75.0
        },
        {
            name = '🚓 Cuartel Policial',
            coords = vector3(440.0, -979.0, 30.0),
            radius = 90.0
        }
    },
    
    -- Modelos de zombis disponibles
    zombieModels = {
        'u_m_y_zombie_01',
        'a_m_m_og_boss_01',
        'g_m_y_famca_01',
        'a_m_o_acult_01',
        'a_f_y_business_04'
    },
    
    -- Tabla de loot
    lootTable = {
        { item = 'money', amount = 75, chance = 0.85 },
        { item = 'bandage', amount = 1, chance = 0.6 },
        { item = 'ammo-9', amount = 3, chance = 0.4 },
        { item = 'ammo-rifle', amount = 2, chance = 0.3 },
        { item = 'ammo-shotgun', amount = 2, chance = 0.25 },
        { item = 'lockpick', amount = 1, chance = 0.15 },
        { item = 'medikit', amount = 1, chance = 0.2 },
        { item = 'weapon_pistol', amount = 1, chance = 0.05 }
    }
}

BATTLEPASS_CONFIG = {
    premiumCost = 5000,
    premiumMultiplier = 1.25,
    baseReward = 200,
    
    xpSources = {
        zombieKill = 50,
        waveComplete = 500,
        safeZoneMinute = 5,
        dailyLogin = 100
    },
    
    levelRewards = {
        [1] = { type = 'cash', amount = 300 },
        [2] = { type = 'cash', amount = 400 },
        [3] = { type = 'item', item = 'bandage', amount = 5 },
        [4] = { type = 'cash', amount = 500 },
        [5] = { type = 'cash', amount = 600 },
        [6] = { type = 'item', item = 'ammo-9', amount = 30 },
        [7] = { type = 'cash', amount = 700 },
        [8] = { type = 'cash', amount = 800 },
        [9] = { type = 'item', item = 'medikit', amount = 2 },
        [10] = { type = 'cash', amount = 1000 },
        [11] = { type = 'cash', amount = 1100 },
        [12] = { type = 'item', item = 'bandage', amount = 10 },
        [13] = { type = 'cash', amount = 1300 },
        [14] = { type = 'item', item = 'ammo-rifle', amount = 50 },
        [15] = { type = 'cash', amount = 1500 },
        [16] = { type = 'cash', amount = 1600 },
        [17] = { type = 'item', item = 'medikit', amount = 3 },
        [18] = { type = 'cash', amount = 1800 },
        [19] = { type = 'item', item = 'ammo-9', amount = 60 },
        [20] = { type = 'cash', amount = 2000 }
    }
}

SHOP_PRICES = {
    ['bandage'] = 50,
    ['medikit'] = 150,
    ['ammo-9'] = 30,
    ['ammo-rifle'] = 40,
    ['ammo-shotgun'] = 50,
    ['lockpick'] = 100,
    ['water'] = 10,
    ['sandwich'] = 15
}
