local QBCore = exports['qb-core']:GetCoreObject()

local spawnedZombies = {}
local waveActive = false
local currentWave = 0
local totalZombiesThisWave = 0
local zombiesKilled = 0

local function requestModel(model)
    if not IsModelInCdimage(model) then
        return false
    end

    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 100 do
        Wait(10)
        tries = tries + 1
    end

    return HasModelLoaded(model)
end

local function getClosestPlayer(coords, maxDistance)
    local closestPlayer = nil
    local closestDistance = maxDistance or 100.0

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            local pCoords = GetEntityCoords(ped)
            local distance = #(coords - pCoords)

            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function spawnZombie(pos)
    if not pos then return nil end
    
    local modelName = ZOMBIE_CONFIG.zombieModels[math.random(1, #ZOMBIE_CONFIG.zombieModels)]
    local model = GetHashKey(modelName)

    if not requestModel(model) then
        return nil
    end

    local zombie = CreatePed(4, model, pos.x, pos.y, pos.z, math.random(0.0, 360.0), true, false)
    
    if not DoesEntityExist(zombie) then
        return nil
    end

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
    
    -- Hacerlo más agresivo
    TaskStartScenarioInPlace(zombie, 'WORLD_HUMAN_STUPOR', 0, true)
    
    table.insert(spawnedZombies, {
        ped = zombie,
        health = ZOMBIE_CONFIG.zombieHealth,
        spawnTime = GetGameTimer()
    })
    
    return zombie
end

local function handleZombieAI()
    while waveActive do
        for i = #spawnedZombies, 1, -1 do
            local zombieData = spawnedZombies[i]
            local zombie = zombieData.ped
            
            if DoesEntityExist(zombie) then
                local zombieHealth = GetEntityHealth(zombie)
                zombieData.health = zombieHealth
                
                if IsEntityDead(zombie) then
                    zombiesKilled = zombiesKilled + 1
                    TriggerServerEvent('qb-zombierp:server:registerKill', currentWave)
                    
                    -- Loot del zombie muerto
                    TriggerEvent('qb-zombierp:client:dropLoot', GetEntityCoords(zombie), currentWave)
                    
                    DeleteEntity(zombie)
                    table.remove(spawnedZombies, i)
                else
                    -- IA del zombie
                    local player, distance = getClosestPlayer(GetEntityCoords(zombie), 60.0)
                    if player then
                        local playerPed = GetPlayerPed(player)
                        if DoesEntityExist(playerPed) then
                            local playerCoords = GetEntityCoords(playerPed)
                            
                            if distance < 45.0 then
                                TaskGoToCoordAnyMeans(zombie, playerCoords.x, playerCoords.y, playerCoords.z, 2.0, 0, 0, 786603, 0)
                                TaskTurnPedToFaceEntity(zombie, playerPed, 100)
                            elseif distance < 10.0 then
                                TaskCombatPed(zombie, playerPed, 0, 16)
                            end
                        end
                    end
                end
            else
                table.remove(spawnedZombies, i)
            end
        end

        -- Verificar si se completó la oleada
        if #spawnedZombies == 0 and currentWave > 0 and zombiesKilled > 0 then
            waveActive = false
            TriggerServerEvent('qb-zombierp:server:waveCleared', currentWave)
            zombiesKilled = 0
            break
        end

        Wait(500)
    end
end

local function dropLoot(coords, wave)
    for _, loot in ipairs(ZOMBIE_CONFIG.lootTable) do
        if math.random() <= loot.chance then
            local text = ''
            if loot.item == 'money' then
                text = '$' .. loot.amount
            else
                text = loot.item .. ' x' .. loot.amount
            end
            
            -- Mostrar notificación de loot
            TriggerEvent('QBCore:Notify', text .. ' adquirido', 'success', 2000)
        end
    end
end

RegisterNetEvent('qb-zombierp:client:spawnWave', function(wave, center, count)
    currentWave = wave
    waveActive = true
    totalZombiesThisWave = count
    zombiesKilled = 0

    local spawnCoords = center
    
    for i = 1, count do
        local offsetX = math.random(-ZOMBIE_CONFIG.spawnRadius, ZOMBIE_CONFIG.spawnRadius)
        local offsetY = math.random(-ZOMBIE_CONFIG.spawnRadius, ZOMBIE_CONFIG.spawnRadius)
        local spawnPos = vector3(spawnCoords.x + offsetX, spawnCoords.y + offsetY, spawnCoords.z)
        
        -- Obtener altura correcta
        for attempt = 1, 5 do
            local found, groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z + 10.0, false)
            if found then
                spawnPos = vector3(spawnPos.x, spawnPos.y, groundZ + 1.0)
                break
            end
            Wait(10)
        end
        
        spawnZombie(spawnPos)
        Wait(50)
    end

    TriggerEvent('QBCore:Notify', ('Oleada zombie #%s activa!'):format(wave), 'warning', 6000)
    handleZombieAI()
end)

RegisterNetEvent('qb-zombierp:client:clearWave', function()
    waveActive = false
    for _, zombieData in ipairs(spawnedZombies) do
        if DoesEntityExist(zombieData.ped) then
            DeleteEntity(zombieData.ped)
        end
    end
    spawnedZombies = {}
    currentWave = 0
    zombiesKilled = 0
end)

RegisterNetEvent('qb-zombierp:client:dropLoot', function(coords, wave)
    dropLoot(coords, wave)
end)

RegisterCommand('zombietest', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    TriggerServerEvent('qb-zombierp:server:registerKill', currentWave)
end, false)

CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, zone in ipairs(ZOMBIE_CONFIG.safeZones) do
            if #(playerCoords - zone.coords) <= zone.radius then
                -- El jugador está en zona segura
                break
            end
        end
        Wait(10000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        waveActive = false
        for _, zombieData in ipairs(spawnedZombies) do
            if DoesEntityExist(zombieData.ped) then
                DeleteEntity(zombieData.ped)
            end
        end
    end
end)
