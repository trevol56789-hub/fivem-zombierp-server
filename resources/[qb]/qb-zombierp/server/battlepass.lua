local QBCore = exports['qb-core']:GetCoreObject()

local battlePassData = {}
local playerBattlePasses = {}
local playerStats = {}

-- Inicializar datos del jugador
local function initPlayerData(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    
    -- Cargar del BP
    if not playerBattlePasses[citizenid] then
        playerBattlePasses[citizenid] = {
            level = 1,
            xp = 0,
            xpToNextLevel = 1000,
            season = 1,
            isPremium = false,
            rewards = {},
            lastUpdated = GetGameTimer()
        }
    end

    -- Cargar stats
    if not playerStats[citizenid] then
        playerStats[citizenid] = {
            kills = 0,
            wavesCompleted = 0,
            totalDamage = 0,
            totalMoneyEarned = 0,
            playtimeSeconds = 0
        }
    end
end

local function savePlayerData(citizenid)
    local bp = playerBattlePasses[citizenid]
    local stats = playerStats[citizenid]
    
    if not bp or not stats then return end
    
    -- Guardar en BD (implementar con MySQL si es necesario)
    -- Por ahora se guarda en memoria
    TriggerEvent('qb-log:server:CreateLog', 'battlepass', 'Player data saved', 'success')
end

-- Gestionar XP y niveles
local function addXPToBattlePass(citizenid, amount, source)
    if not playerBattlePasses[citizenid] then
        return
    end

    local bp = playerBattlePasses[citizenid]
    local xpGain = amount
    
    -- Aplicar multiplicador premium
    if bp.isPremium then
        xpGain = math.floor(xpGain * BATTLEPASS_CONFIG.premiumMultiplier or 1.25)
    end
    
    bp.xp = bp.xp + xpGain

    -- Subir de nivel
    while bp.xp >= bp.xpToNextLevel do
        bp.xp = bp.xp - bp.xpToNextLevel
        bp.level = bp.level + 1
        bp.xpToNextLevel = bp.xpToNextLevel + (bp.level * 100)
        
        if source then
            TriggerClientEvent('QBCore:Notify', source, ('🎉 Nivel %s alcanzado!'):format(bp.level), 'success', 5000)
        end
        
        -- Recompensa automática de nivel
        if BATTLEPASS_CONFIG.levelRewards[bp.level] then
            local reward = BATTLEPASS_CONFIG.levelRewards[bp.level]
            local Player = QBCore.Functions.GetPlayer(source)
            
            if Player then
                if reward.type == 'cash' then
                    Player.Functions.AddMoney('cash', reward.amount, 'battlepass_level_' .. bp.level)
                elseif reward.type == 'item' then
                    Player.Functions.AddItem(reward.item, reward.amount)
                elseif reward.type == 'weapon' then
                    Player.Functions.AddItem('weapon_' .. reward.weapon, 1)
                end
            end
        end
    end

    if source then
        TriggerClientEvent('qb-battlepass:client:updateBattlePass', source, bp)
    end
    
    savePlayerData(citizenid)
end

-- Eventos del servidor

RegisterNetEvent('qb-zombierp:server:registerKill', function(wave)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    initPlayerData(src)
    
    local xpReward = BATTLEPASS_CONFIG.xpSources.zombieKill or 50
    addXPToBattlePass(citizenid, xpReward, src)
    
    local moneyReward = math.random(25, 75)
    Player.Functions.AddMoney('cash', moneyReward, 'zombie_kill')
    
    playerStats[citizenid].kills = playerStats[citizenid].kills + 1
end)

RegisterNetEvent('qb-zombierp:server:waveCleared', function(wave)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    initPlayerData(src)
    
    local bp = playerBattlePasses[citizenid]
    local xpReward = BATTLEPASS_CONFIG.xpSources.waveComplete or 500
    local moneyReward = math.floor(BATTLEPASS_CONFIG.baseReward * (wave * (bp.isPremium and BATTLEPASS_CONFIG.premiumMultiplier or 1)))
    
    addXPToBattlePass(citizenid, xpReward, src)
    Player.Functions.AddMoney('cash', moneyReward, 'wave_complete')
    
    playerStats[citizenid].wavesCompleted = playerStats[citizenid].wavesCompleted + 1
    playerStats[citizenid].totalMoneyEarned = playerStats[citizenid].totalMoneyEarned + moneyReward
    
    TriggerClientEvent('QBCore:Notify', src, ('Oleada completada! +$%s'):format(moneyReward), 'success', 5000)
end)

RegisterNetEvent('qb-battlepass:server:claimReward', function(level)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local bp = playerBattlePasses[citizenid]

    if bp.level < level then
        TriggerClientEvent('QBCore:Notify', src, 'No has alcanzado este nivel', 'error', 5000)
        return
    end

    if bp.rewards[level] then
        TriggerClientEvent('QBCore:Notify', src, 'Ya has reclamado esta recompensa', 'error', 5000)
        return
    end

    local reward = BATTLEPASS_CONFIG.levelRewards[level]
    if not reward then return end

    if reward.type == 'cash' then
        Player.Functions.AddMoney('cash', reward.amount, 'battlepass_level_' .. level)
    elseif reward.type == 'item' then
        Player.Functions.AddItem(reward.item, reward.amount)
    elseif reward.type == 'weapon' then
        Player.Functions.AddItem('weapon_' .. reward.weapon, 1)
    end

    bp.rewards[level] = true
    TriggerClientEvent('QBCore:Notify', src, 'Recompensa reclamada!', 'success', 5000)
    TriggerClientEvent('qb-battlepass:client:updateBattlePass', src, bp)
    savePlayerData(citizenid)
end)

RegisterNetEvent('qb-battlepass:server:upgradeToPreemium', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cost = BATTLEPASS_CONFIG.premiumCost or 5000
    
    if Player.Functions.GetMoney('cash') < cost then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficiente dinero ($' .. cost .. ')', 'error', 5000)
        return
    end

    Player.Functions.RemoveMoney('cash', cost, 'battlepass_premium')
    
    local citizenid = Player.PlayerData.citizenid
    playerBattlePasses[citizenid].isPremium = true
    
    TriggerClientEvent('QBCore:Notify', src, 'Has pasado a Battle Pass Premium! x1.25 XP', 'success', 5000)
    TriggerClientEvent('qb-battlepass:client:updateBattlePass', src, playerBattlePasses[citizenid])
    savePlayerData(citizenid)
end)

RegisterNetEvent('qb-zombierp:server:buyItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local price = SHOP_PRICES[item] or 100
    local totalCost = price * amount
    
    if Player.Functions.GetMoney('cash') < totalCost then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficiente dinero', 'error', 5000)
        return
    end

    Player.Functions.RemoveMoney('cash', totalCost, 'safe_zone_shop')
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('QBCore:Notify', src, 'Compra realizada!', 'success', 3000)
end)

QBCore.Functions.CreateCallback('qb-battlepass:server:getBattlePassData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local citizenid = Player.PlayerData.citizenid
    initPlayerData(source)
    cb(playerBattlePasses[citizenid])
end)

QBCore.Functions.CreateCallback('qb-zombierp:server:getPlayerStats', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local citizenid = Player.PlayerData.citizenid
    initPlayerData(source)
    cb(playerStats[citizenid])
end)

-- Guardar datos al conectar/desconectar
AddEventHandler('playerJoining', function()
    local src = source
    TriggerEvent('qb-log:server:CreateLog', 'zombierp', 'Player joining', 'info')
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local citizenid = Player.PlayerData.citizenid
        savePlayerData(citizenid)
    end
    TriggerEvent('qb-log:server:CreateLog', 'zombierp', 'Player dropped: ' .. reason, 'info')
end)
