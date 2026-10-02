local QBCore = exports['qb-core']:GetCoreObject()

local mapOpen = false
local currentZones = {}
local activeEvents = {}

local function openMapUI()
    QBCore.Functions.TriggerCallback('qb-zombierp:server:getMapZones', function(zones)
        QBCore.Functions.TriggerCallback('qb-zombierp:server:getActiveEvents', function(events)
            currentZones = zones
            activeEvents = events

            local html = '<div class="map-container">'
            html = html .. '<div class="map-header"><h1>MAPA DE ZONAS - ZOMBIE RP</h1></div>'
            
            html = html .. '<div class="zones-grid">'
            for _, zone in ipairs(zones) do
                local isActive = activeEvents[zone.name] and activeEvents[zone.name].active or false
                local status = isActive and 'ACTIVO' or 'INACTIVO'
                local statusClass = isActive and 'active' or 'inactive'

                html = html .. '<div class="zone-card ' .. statusClass .. '">'
                html = html .. '<div class="zone-name">' .. zone.name .. '</div>'
                html = html .. '<div class="zone-info">'
                html = html .. '<p>Zombis: ' .. zone.zombies .. '</p>'
                html = html .. '<p>Radio: ' .. zone.radius .. 'm</p>'
                html = html .. '<p>Estado: <span class="status-badge">' .. status .. '</span></p>'
                html = html .. '</div>'
                html = html .. '<div class="zone-coords">X: ' .. math.floor(zone.coords.x) .. ' Y: ' .. math.floor(zone.coords.y) .. '</div>'
                html = html .. '<button onclick="teleportToZone(' .. zone.coords.x .. ', ' .. zone.coords.y .. ', ' .. zone.coords.z .. ')" class="btn-teleport">Teleportar</button>'
                html = html .. '<button onclick="setWaypoint(' .. zone.coords.x .. ', ' .. zone.coords.y .. ')" class="btn-waypoint">Ruta GPS</button>'
                html = html .. '</div>'
            end
            html = html .. '</div>'
            html = html .. '</div>'

            SendNUIMessage({
                action = 'openMap',
                data = html
            })

            mapOpen = true
        end)
    end)
end

local function closeMapUI()
    mapOpen = false
    SendNUIMessage({
        action = 'closeMap'
    })
end

RegisterCommand('mapa', function()
    openMapUI()
end, false)

RegisterCommand('map', function()
    openMapUI()
end, false)

RegisterNUICallback('teleportToZone', function(data, cb)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, data.x, data.y, data.z, false, false, false, false)
    TriggerEvent('QBCore:Notify', 'Te has teleportado a la zona', 'success', 3000)
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    local blip = AddBlipForCoord(data.x, data.y, 0.0)
    SetBlipRoute(blip, true)
    TriggerEvent('QBCore:Notify', 'Ruta GPS establecida', 'success', 3000)
    cb('ok')
end)

RegisterNUICallback('closeMap', function(data, cb)
    closeMapUI()
    cb('ok')
end)

CreateThread(function()
    while true do
        if mapOpen then
            if IsControlJustReleased(0, 322) then -- ESC
                closeMapUI()
            end
        end
        Wait(0)
    end
end)

-- Draw blips for zones on map
CreateThread(function()
    for _, zone in ipairs(MAP_CONFIG.zones) do
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, 303) -- Skull icon
        SetBlipColour(blip, 1) -- Red
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, false)
        AddTextComponentString(zone.name)
        AddBlipNameFromTextComponent(blip)
    end
end)
