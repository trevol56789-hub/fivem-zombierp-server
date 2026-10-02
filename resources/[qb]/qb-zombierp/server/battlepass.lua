local QBCore = exports['qb-core']:GetCoreObject()

local battlePassData = {}
local playerBattlePasses = {}

local function initBattlePass(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    
    if not playerBattlePasses[citizenid] then
        playerBattlePasses[citizenid] = {
            level = 1,
            xp = 0,
            xpToNextLevel = 1000,
            season = 1,
            isPremium = false,
            rewards = {}
        }
    end

    TriggerClientEvent('qb-battlepass:client:updateBattlePass', src, playerBattlePasses[citizenid])
end

RegisterNetEvent('qb-battlepass:server:addXP', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    
    if not playerBattlePasses[citizenid] then
        initBattlePass(src)
    end

    local bp = playerBattlePasses[citizenid]
    bp.xp = bp.xp + amount

    if bp.xp >= bp.xpToNextLevel then
        bp.xp = bp.xp - bp.xpToNextLevel
        bp.level = bp.level + 1
        bp.xpToNextLevel = bp.xpToNextLevel + (bp.level * 100)
        
        TriggerClientEvent('QBCore:Notify', src, ('Nivel de Battle Pass alcanzado: %s'):format(bp.level), 'success', 5000)
        
        local reward = BATTLEPASS_CONFIG.levelRewards[bp.level]
        if reward then
            if reward.type == 'cash' then
                Player.Functions.AddMoney('cash', reward.amount, 'battlepass_reward')
            elseif reward.type == 'item' then
                Player.Functions.AddItem(reward.item, reward.amount)
            end
        end
    end

    TriggerClientEvent('qb-battlepass:client:updateBattlePass', src, bp)
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
end)

RegisterNetEvent('qb-battlepass:server:upgradeToPreemium', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.GetMoney('cash') < BATTLEPASS_CONFIG.premiumCost then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes suficiente dinero', 'error', 5000)
        return
    end

    Player.Functions.RemoveMoney('cash', BATTLEPASS_CONFIG.premiumCost, 'battlepass_premium')
    
    local citizenid = Player.PlayerData.citizenid
    playerBattlePasses[citizenid].isPremium = true
    
    TriggerClientEvent('QBCore:Notify', src, 'Has pasado a Battle Pass Premium!', 'success', 5000)
    TriggerClientEvent('qb-battlepass:client:updateBattlePass', src, playerBattlePasses[citizenid])
end)

QBCore.Functions.CreateCallback('qb-battlepass:server:getBattlePassData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    if not playerBattlePasses[citizenid] then
        initBattlePass(source)
    end

    cb(playerBattlePasses[citizenid])
end)
