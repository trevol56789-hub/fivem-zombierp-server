local QBCore = exports['qb-core']:GetCoreObject()

local currentMap = nil
local mapZones = {}
local activeEvents = {}

local MAP_CONFIG = {
    zones = {
        { name = 'Downtown', coords = vector3(118.4, -1037.9, 29.3), radius = 150.0, zombies = 15 },
        { name = 'Hospital', coords = vector3(335.0, -583.0, 43.3), radius = 120.0, zombies = 12 },
        { name = 'Police Station', coords = vector3(440.0, -979.0, 30.0), radius = 100.0, zombies = 10 },
        { name = 'Pillbox Medical', coords = vector3(295.7, -1246.7, 29.4), radius = 110.0, zombies = 11 },
        { name = 'Port Authority', coords = vector3(478.8, -3370.5, 6.0), radius = 200.0, zombies = 20 },
        { name = 'Bolingbroke Prison', coords = vector3(1688.1, 2612.0, 45.5), radius = 180.0, zombies = 18 },
        { name = 'Fort Zancudo', coords = vector3(-2354.0, -370.0, 13.0), radius = 250.0, zombies = 25 },
        { name = 'Maze Bank', coords = vector3(-75.1, -1105.9, 26.4), radius = 90.0, zombies = 8 },
    },
    safeZones = {
        { name = 'Safehouse Downtown', coords = vector3(118.4, -1037.9, 29.3), radius = 70.0 },
        { name = 'Hospital Bunker', coords = vector3(335.0, -583.0, 43.3), radius = 65.0 },
        { name = 'Police Headquarters', coords = vector3(440.0, -979.0, 30.0), radius = 85.0 },
    }
}

local function initializeMap()
    mapZones = MAP_CONFIG.zones
    currentMap = 'Los Santos'
end

local function getZoneFromCoords(coords)
    for _, zone in ipairs(mapZones) do
        if #(coords - zone.coords) <= zone.radius then
            return zone
        end
    end
    return nil
end

local function createMapMarkers()
    for _, zone in ipairs(mapZones) do
        TriggerClientEvent('qb-map:client:addMarker', -1, {
            coords = zone.coords,
            name = zone.name,
            type = 'zombie',
            icon = 'fas fa-skull',
            color = 'red'
        })
    end
end

local function eventZoneSpawn(zoneName)
    local zone = nil
    for _, z in ipairs(mapZones) do
        if z.name == zoneName then
            zone = z
            break
        end
    end

    if not zone then return end

    local count = zone.zombies + math.random(-2, 5)
    TriggerClientEvent('qb-zombierp:client:spawnWave', -1, 1, zone.coords, count)
    
    activeEvents[zoneName] = {
        active = true,
        startTime = GetGameTimer(),
        zone = zone
    }

    TriggerClientEvent('QBCore:Notify', -1, ('Evento activo en: %s'):format(zoneName), 'warning', 5000)
end

local function clearZoneEvent(zoneName)
    if activeEvents[zoneName] then
        activeEvents[zoneName].active = false
        TriggerClientEvent('qb-zombierp:client:clearWave', -1)
    end
end

RegisterNetEvent('qb-zombierp:server:startMapEvent', function(zoneName)
    local src = source
    if not QBCore.Functions.HasPermission(src, 'admin') then
        return
    end
    eventZoneSpawn(zoneName)
end)

RegisterNetEvent('qb-zombierp:server:endMapEvent', function(zoneName)
    local src = source
    if not QBCore.Functions.HasPermission(src, 'admin') then
        return
    end
    clearZoneEvent(zoneName)
end)

QBCore.Functions.CreateCallback('qb-zombierp:server:getMapZones', function(source, cb)
    cb(mapZones)
end)

QBCore.Functions.CreateCallback('qb-zombierp:server:getActiveEvents', function(source, cb)
    cb(activeEvents)
end)

CreateThread(function()
    initializeMap()
    createMapMarkers()
    
    while true do
        for zoneName, event in pairs(activeEvents) do
            if event.active then
                local duration = (GetGameTimer() - event.startTime) / 1000
                if duration > 600 then -- 10 minutos
                    clearZoneEvent(zoneName)
                end
            end
        end
        Wait(5000)
    end
end)
