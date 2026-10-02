local QBCore = exports['qb-core']:GetCoreObject()

local battlePassUI = false
local currentBattlePass = {}

local function openBattlePassMenu()
    QBCore.Functions.TriggerCallback('qb-battlepass:server:getBattlePassData', function(bp)
        currentBattlePass = bp
        
        local levelRewards = BATTLEPASS_CONFIG.levelRewards
        local html = '<div class="battlepass-container">'
        html = html .. '<div class="bp-header">'
        html = html .. '<h1>BATTLE PASS ZOMBIE</h1>'
        html = html .. '<div class="bp-info">'
        html = html .. '<span>Nivel: ' .. bp.level .. '</span>'
        html = html .. '<span>XP: ' .. bp.xp .. '/' .. bp.xpToNextLevel .. '</span>'
        html = html .. '</div>'
        html = html .. '</div>'
        
        html = html .. '<div class="bp-levels">'
        for level = 1, #levelRewards do
            local reward = levelRewards[level]
            local claimed = bp.rewards[level] or false
            local unlocked = bp.level >= level
            
            html = html .. '<div class="bp-level-card ' .. (unlocked and 'unlocked' or 'locked') .. ' ' .. (claimed and 'claimed' or '') .. '">'
            html = html .. '<div class="level-number">Lvl ' .. level .. '</div>'
            
            if reward.type == 'cash' then
                html = html .. '<div class="reward-info">💵 $' .. reward.amount .. '</div>'
            elseif reward.type == 'item' then
                html = html .. '<div class="reward-info">📦 ' .. reward.item .. ' x' .. reward.amount .. '</div>'
            elseif reward.type == 'weapon' then
                html = html .. '<div class="reward-info">🔫 ' .. reward.weapon .. '</div>'
            end
            
            if unlocked and not claimed then
                html = html .. '<button onclick="claimReward(' .. level .. ')">Reclamar</button>'
            elseif claimed then
                html = html .. '<span class="claimed-badge">✓ Reclamado</span>'
            end
            
            html = html .. '</div>'
        end
        html = html .. '</div>'
        
        if not bp.isPremium then
            html = html .. '<div class="bp-premium-offer">'
            html = html .. '<h3>Desbloquea Battle Pass Premium</h3>'
            html = html .. '<p>Costo: $' .. BATTLEPASS_CONFIG.premiumCost .. '</p>'
            html = html .. '<button onclick="upgradePremium()">Comprar Premium</button>'
            html = html .. '</div>'
        else
            html = html .. '<div class="bp-premium-status">✓ Premium Activo</div>'
        end
        
        html = html .. '</div>'
        
        SendNUIMessage({
            action = 'openBattlePass',
            data = html
        })
        
        battlePassUI = true
    end)
end

local function closeBattlePassMenu()
    battlePassUI = false
    SendNUIMessage({
        action = 'closeBattlePass'
    })
end

RegisterNetEvent('qb-battlepass:client:updateBattlePass', function(bp)
    currentBattlePass = bp
    if battlePassUI then
        openBattlePassMenu()
    end
end)

RegisterCommand('battlepass', function()
    openBattlePassMenu()
end, false)

RegisterCommand('closebattlepass', function()
    closeBattlePassMenu()
end, false)

RegisterNUICallback('claimReward', function(data, cb)
    TriggerServerEvent('qb-battlepass:server:claimReward', data.level)
    cb('ok')
end)

RegisterNUICallback('upgradePremium', function(data, cb)
    TriggerServerEvent('qb-battlepass:server:upgradeToPreemium')
    cb('ok')
end)

RegisterNUICallback('closeBattlePass', function(data, cb)
    closeBattlePassMenu()
    cb('ok')
end)

CreateThread(function()
    while true do
        if battlePassUI then
            if IsControlJustReleased(0, 322) then -- ESC
                closeBattlePassMenu()
            end
        end
        Wait(0)
    end
end)
