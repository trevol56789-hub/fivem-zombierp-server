ZOMBIE_CONFIG = {
    debug = true,
    waveInterval = 30000,
    maxZombiesPerWave = 12,
    spawnRadius = 55.0,
    safeZoneRadius = 55.0,
    baseReward = 150,
    zombieHealth = 250,
    zombieDamage = 12,
    rewardMultiplier = 1.25,
    safeZones = {
        { name = 'Centro Seguro', coords = vector3(118.4, -1037.9, 29.3), radius = 70.0 },
        { name = 'Hospital', coords = vector3(335.0, -583.0, 43.3), radius = 65.0 },
        { name = 'Comisaría', coords = vector3(440.0, -979.0, 30.0), radius = 85.0 }
    },
    zombieModels = {
        'u_m_y_zombie_01',
        'a_m_m_og_boss_01',
        'g_m_y_famca_01',
        'a_m_o_acult_01'
    },
    lootTable = {
        { item = 'money', amount = 50, chance = 0.8 },
        { item = 'weapon_pistol', amount = 1, chance = 0.15 },
        { item = 'bandage', amount = 2, chance = 0.7 },
        { item = 'ammo-9', amount = 5, chance = 0.55 },
        { item = 'lockpick', amount = 1, chance = 0.2 }
    }
}
