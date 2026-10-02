local SHOP_PRICES = {
    ['bandage'] = 50,
    ['medikit'] = 150,
    ['ammo-9'] = 30,
    ['ammo-rifle'] = 40,
    ['ammo-shotgun'] = 50,
    ['lockpick'] = 100,
    ['water'] = 10,
    ['sandwich'] = 15,
    ['coffee'] = 5
}

local safeZones = ZOMBIE_CONFIG.safeZones or {}

local function drawSafeZoneMarker(zone)
    DrawMarker(1, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, zone.radius, zone.radius, 50.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
end

local function drawSafeZoneBlip(zone)
    local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
    SetBlipSprite(blip, 227) -- Shield icon
    SetBlipColour(blip, 2) -- Green
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    AddTextComponentString(zone.name)
    AddBlipNameFromTextComponent(blip)
end

local function openSafeZoneShop(zone)
    local options = {}
    
    for item, price in pairs(SHOP_PRICES) do
        table.insert(options, {
            header = item,
            txt = 'Precio: $' .. price,
            params = {
                event = 'qb-zombierp:client:buyItem',
                args = { item = item, amount = 1, price = price }
            }
        })
    end
    
    table.insert(options, {
        header = 'Cerrar',
        txt = '',
        params = { event = 'qb-menu:closeMenu' }
    })
    
    exports['qb-menu']:openMenu(options)
end

local function handleSafeZoneInteraction(zone)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if #(playerCoords - zone.coords) <= zone.radius then
        -- Mostrar opción de tienda
        TriggerEvent('QBCore:Notify', 'Presiona [E] para acceder a la tienda segura', 'info', 5000)
        
        if IsControlJustReleased(0, 38) then -- E key
            openSafeZoneShop(zone)
        end
    end
end

CreateThread(function()
    for _, zone in ipairs(safeZones) do
        drawSafeZoneBlip(zone)
    end
end)

CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, zone in ipairs(safeZones) do
            if #(playerCoords - zone.coords) <= zone.radius then
                drawSafeZoneMarker(zone)
                handleSafeZoneInteraction(zone)
            end
        end
        
        Wait(0)
    end
end)
