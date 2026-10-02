local spawnedZombies = {}
local waveActive = false
local currentWave = 0
local waveCooldown = 0

local function isValidZombieModel(model)
    for _, v in ipairs(ZOMBIE_CONFIG.zombieModels) do
        if GetHashKey(v) == model then
            return true
        end
    end
    return true
end

local function getClosestPlayer(coords)
    local closestPlayer = nil
    local closestDistance = nil

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        local pCoords = GetEntityCoords(ped)
        local distance = #(coords - pCoords)

        if closestDistance == nil or distance < closestDistance then
            closestPlayer = player
            closestDistance = distance
        end
    end

    return closestPlayer, closestDistance
end

local function requestModel(model)
    if not IsModelInCdimage(model) then
        return false
    end

    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 100 do
        Wait(20)
        tries = tries + 1
    end

    return HasModelLoaded(model)
end

local function clearCurrentWave()
    for _, zombie in ipairs(spawnedZombies) do
        if DoesEntityExist(zombie) then
            DeleteEntity(zombie)
        end
    end
    spawnedZombies = {}
    currentWave = 0
    waveActive = false
    TriggerServerEvent('qb-zombierp:server:waveCleared', 0)
end

local function spawnZombie(pos)
    local modelName = ZOMBIE_CONFIG.zombieModels[math.random(1, #ZOMBIE_CONFIG.zombieModels)]
    local model = GetHashKey(modelName)

    if not requestModel(model) then
        return nil
    end

    local zombie = CreatePed(4, model, pos.x, pos.y, pos.z, math.random(0.0, 360.0), true, false)
    SetEntityHealth(zombie, ZOMBIE_CONFIG.zombieHealth)
    SetPedCanRagdoll(zombie, true)
    SetPedCombatMovement(zombie, 2)
    SetPedCombatRange(zombie, 2)
    SetPedAccuracy(zombie, 30)
    SetPedFleeAttributes(zombie, 0, 0)
    SetPedConfigFlag(zombie, 16, false)
    SetPedConfigFlag(zombie, 42, true)
    SetPedConfigFlag(zombie, 52, true)
    SetPedAsEnemy(zombie, true)

    table.insert(spawnedZombies, zombie)
    return zombie
end

local function chaseNearestPlayer(zombie)
    local player, distance = getClosestPlayer(GetEntityCoords(zombie))
    if not player then
        return
    end

    local ped = GetPlayerPed(player)
    if not DoesEntityExist(ped) then
        return
    end

    local pCoords = GetEntityCoords(ped)
    if distance < 45.0 then
        TaskGoToCoordAnyMeans(zombie, pCoords.x, pCoords.y, pCoords.z, 1.5, 0, 0, 786603, 0)
    end
end

local function handleZombieAI()
    while waveActive do
        for i = #spawnedZombies, 1, -1 do
            local zombie = spawnedZombies[i]
            if DoesEntityExist(zombie) then
                if IsEntityDead(zombie) then
                    TriggerServerEvent('qb-zombierp:server:registerKill', currentWave)
                    DeleteEntity(zombie)
                    table.remove(spawnedZombies, i)
                else
                    chaseNearestPlayer(zombie)
                end
            else
                table.remove(spawnedZombies, i)
            end
        end

        if #spawnedZombies == 0 and currentWave > 0 then
            waveActive = false
            TriggerServerEvent('qb-zombierp:server:waveCleared', currentWave)
            currentWave = 0
            break
        end

        Wait(1000)
    end
end

RegisterNetEvent('qb-zombierp:client:spawnWave', function(wave, center, count)
    currentWave = wave
    waveActive = true

    local spawnCoords = center
    for i = 1, count do
        local offsetX = math.random(-ZOMBIE_CONFIG.spawnRadius, ZOMBIE_CONFIG.spawnRadius)
        local offsetY = math.random(-ZOMBIE_CONFIG.spawnRadius, ZOMBIE_CONFIG.spawnRadius)
        local spawnPos = vector3(spawnCoords.x + offsetX, spawnCoords.y + offsetY, spawnCoords.z)
        local groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z, false)
        spawnPos = vector3(spawnPos.x, spawnPos.y, groundZ + 1.0)
        spawnZombie(spawnPos)
    end

    TriggerEvent('QBCore:Notify', ('Oleada zombie # %s activa!'):format(wave), 'warning', 6000)
    handleZombieAI()
end)

RegisterNetEvent('qb-zombierp:client:clearWave', function()
    clearCurrentWave()
end)

RegisterCommand('zombietest', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent('qb-zombierp:server:spawnLocalWave', coords)
end, false)

RegisterNetEvent('qb-zombierp:client:notifySafeZone', function(zoneName)
    TriggerEvent('QBCore:Notify', ('Estás en zona segura: %s'):format(zoneName), 'success', 3000)
end)

CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, zone in ipairs(ZOMBIE_CONFIG.safeZones) do
            if #(playerCoords - zone.coords) <= zone.radius then
                TriggerEvent('qb-zombierp:client:notifySafeZone', zone.name)
                break
            end
        end
        Wait(12000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        clearCurrentWave()
    end
end)

