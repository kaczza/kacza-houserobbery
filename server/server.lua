ESX = exports['es_extended']:getSharedObject()
local Lastrob = 0
-- check item
RegisterServerEvent('kz_houserobery:checkitem')
AddEventHandler('kz_houserobery:checkitem', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not Config.RequiredItem then
        xPlayer.triggerEvent('kz_houserobery:startminigame')
        return
    end

    local itemCount = xPlayer.getInventoryItem(Config.ItemRequired).count
    if itemCount and itemCount > 0 then
        xPlayer.triggerEvent('kz_houserobery:startminigame')
    else
        xPlayer.showNotification(Config.Text.nolockpick)
    end
end)

-- give loot
RegisterServerEvent('kz_houserobery:giveloot')
AddEventHandler('kz_houserobery:giveloot', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local roll = math.random(1, 3)
    local lootTable, countRange

    if roll == 1 then
        lootTable, countRange = Config.Loot.badloot, Config.Cant.badloot
    elseif roll == 2 then
        lootTable, countRange = Config.Loot.mediumloot, Config.Cant.mediumloot
    else
        lootTable, countRange = Config.Loot.goodloot, Config.Cant.goodloot
    end

    local item = lootTable[math.random(#lootTable)]
    local amount = math.random(countRange[1], countRange[2])
    xPlayer.addInventoryItem(item, amount)
end)

-- count cops
ESX.RegisterServerCallback('kz_houserobery:countpolice', function(_, cb)
    local police = 0
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName then
            police = police + 1
        end
    end
    cb(police >= Config.CopsRequired)
end)

-- cooldown
ESX.RegisterServerCallback('kz_houserobery:house:cooldown', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    if Lastrob ~= 0 and (os.time() - Lastrob) < Config.Cooldown then
        xPlayer.showNotification(Config.Text.wait)
        cb(false)
    else
        cb(true)
    end
end)

-- set last rob time
RegisterServerEvent('kz_houserobery:time')
AddEventHandler('kz_houserobery:time', function()
    Lastrob = os.time()
end)
