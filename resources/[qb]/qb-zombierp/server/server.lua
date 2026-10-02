local QBCore = exports['qb-core']:GetCoreObject()

local currentWave = 0
local waveActive = false
local waveWinners = {}

local function isInSafeZone(coords)
    for _, zone in ipairs(ZOMBIE_CONFIG.safeZones) do
        if #(coords - zone.coords) <= zone.radius then
            return true, zone.name
        end
    end
    return false, 'none'
end

local function startWave()
    if waveActive then
        return
    end

    local players = QBCore.Functions.GetPlayers()
    if #players == 0 then
        return
    end

    local randomPlayer = players[math.random(1, #players)]
    local ped = GetPlayerPed(randomPlayer)
    local coords = GetEntityCoords(ped)
    local safe, zoneName = isInSafeZone(coords)

    if safe then
        return
    end

    currentWave = currentWave + 1
    waveActive = true

    local count = math.min(ZOMBIE_CONFIG.maxZombiesPerWave + currentWave, 20)
    TriggerClientEvent('qb-zombierp:client:spawnWave', -1, currentWave, coords, count)
    TriggerClientEvent('QBCore:Notify', randomPlayer, ('Oleada zombie iniciada: # %s'):format(currentWave), 'inform', 5000)
end

local function completeWave(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    local reward = math.floor(ZOMBIE_CONFIG.baseReward * (currentWave * ZOMBIE_CONFIG.rewardMultiplier))
    Player.Functions.AddMoney('cash', reward, 'zombie_wave_clear')

    TriggerClientEvent('QBCore:Notify', src, ('Oleada completada! +$%s'):format(reward), 'success', 5000)
end

local function awardLoot(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    for _, entry in ipairs(ZOMBIE_CONFIG.lootTable) do
        if math.random() <= entry.chance then
            if entry.item == 'money' then
                Player.Functions.AddMoney('cash', entry.amount, 'zombie_loot')
            else
                Player.Functions.AddItem(entry.item, entry.amount)
            end
        end
    end
end

RegisterNetEvent('qb-zombierp:server:registerKill', function(wave)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    local reward = math.random(25, 75)
    Player.Functions.AddMoney('cash', reward, 'zombie_kill')
end)

RegisterNetEvent('qb-zombierp:server:waveCleared', function(wave)
    local src = source
    completeWave(src)
    awardLoot(src)
end)

CreateThread(function()
    while true do
        if not waveActive then
            startWave()
        end
        Wait(ZOMBIE_CONFIG.waveInterval)
    end
end)

RegisterCommand('zombiewave', function(source)
    if source == 0 then
        currentWave = currentWave + 1
        local players = QBCore.Functions.GetPlayers()
        if #players == 0 then
            return
        end
        local ped = GetPlayerPed(players[1])
        local coords = GetEntityCoords(ped)
        local count = math.min(ZOMBIE_CONFIG.maxZombiesPerWave + currentWave, 20)
        TriggerClientEvent('qb-zombierp:client:spawnWave', -1, currentWave, coords, count)
        waveActive = true
    end
end, false)

RegisterCommand('zombirestart', function(source)
    if source == 0 then
        waveActive = false
        currentWave = 0
        TriggerClientEvent('qb-zombierp:client:clearWave', -1)
    end
end, false)

QBCore.Functions.CreateCallback('qb-zombierp:server:getWaveState', function(source, cb)
    cb({
        active = waveActive,
        wave = currentWave
    })
end)
