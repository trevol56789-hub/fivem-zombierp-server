local QBCore = exports['qb-core']:GetCoreObject()

local currentWave = 0
local waveActive = false
local waveStartTime = 0
local zombieCount = {}
local maxZombiesThisWave = 0

local function isInSafeZone(coords)
    for _, zone in ipairs(ZOMBIE_CONFIG.safeZones) do
        if #(coords - zone.coords) <= zone.radius then
            return true, zone.name
        end
    end
    return false, 'none'
end

local function getRandomSpawnCoords(centerCoords)
    local angle = math.rad(math.random(0, 360))
    local radius = math.random(30, ZOMBIE_CONFIG.spawnRadius)
    local x = centerCoords.x + (math.cos(angle) * radius)
    local y = centerCoords.y + (math.sin(angle) * radius)
    local z = centerCoords.z
    return vector3(x, y, z)
end

local function startWave()
    if waveActive then
        return
    end

    local players = QBCore.Functions.GetPlayers()
    if #players == 0 then
        return
    end

    -- Escoger jugador aleatorio para spawn cerca
    local randomPlayer = players[math.random(1, #players)]
    local ped = GetPlayerPed(randomPlayer)
    local coords = GetEntityCoords(ped)
    local safe, zoneName = isInSafeZone(coords)

    if safe then
        return
    end

    currentWave = currentWave + 1
    waveActive = true
    waveStartTime = GetGameTimer()
    zombieCount = {}

    -- Zombis aumentan con cada oleada
    local baseCount = ZOMBIE_CONFIG.maxZombiesPerWave
    maxZombiesThisWave = math.min(baseCount + currentWave, 30)
    
    TriggerClientEvent('qb-zombierp:client:spawnWave', -1, currentWave, coords, maxZombiesThisWave)
    
    for _, player in ipairs(players) do
        TriggerClientEvent('QBCore:Notify', player, ('🧟 Oleada #%s iniciada! Zombis: %s'):format(currentWave, maxZombiesThisWave), 'inform', 6000)
    end
    
    -- Log
    TriggerEvent('qb-log:server:CreateLog', 'zombierp', 'Wave ' .. currentWave .. ' started', 'warning')
end

local function completeWave()
    if not waveActive then return end
    
    waveActive = false
    local players = QBCore.Functions.GetPlayers()
    
    for _, player in ipairs(players) do
        TriggerServerEvent('qb-zombierp:server:waveCleared', currentWave)
    end
    
    for _, player in ipairs(players) do
        TriggerClientEvent('QBCore:Notify', player, ('✅ Oleada #%s completada!'):format(currentWave), 'success', 5000)
    end
end

RegisterNetEvent('qb-zombierp:server:zombieDeath', function()
    TriggerEvent('qb-zombierp:server:registerKill', currentWave)
end)

RegisterNetEvent('qb-zombierp:server:waveZombieKilled', function()
    local src = source
    if not src then return end
    
    TriggerServerEvent('qb-zombierp:server:registerKill', currentWave)
end)

RegisterNetEvent('qb-zombierp:server:checkWaveCompletion', function(zombiesRemaining)
    if zombiesRemaining <= 0 and waveActive then
        completeWave()
    end
end)

RegisterCommand('zombiewave', function(source, args, rawCommand)
    if source == 0 then
        startWave()
    end
end, false)

RegisterCommand('zombierestart', function(source, args, rawCommand)
    if source == 0 then
        waveActive = false
        currentWave = 0
        zombieCount = {}
        TriggerClientEvent('qb-zombierp:client:clearWave', -1)
    end
end, false)

RegisterCommand('zombiestat', function(source)
    if source == 0 then
        print('Console can\'t view stats')
        return
    end
    
    QBCore.Functions.TriggerCallback('qb-zombierp:server:getPlayerStats', source, function(stats)
        if stats then
            TriggerClientEvent('QBCore:Notify', source, ('Kills: %s | Waves: %s | Dinero: $%s'):format(
                stats.kills, stats.wavesCompleted, stats.totalMoneyEarned
            ), 'info', 5000)
        end
    end)
end, false)

CreateThread(function()
    while true do
        if not waveActive then
            startWave()
        end
        Wait(ZOMBIE_CONFIG.waveInterval or 30000)
    end
end)
