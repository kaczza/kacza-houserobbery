ESX = nil
ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('kz_houserobery:checkitem')
AddEventHandler('kz_houserobery:checkitem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = exports.ox_inventory:GetItem(source, Config.ItemRequired, nil, 1)
    if Config.RequiredItem then
        if xPlayer.getInventoryItem(Config.ItemRequired).count >= 1 then 
            xPlayer.triggerEvent('kz_houserobery:startminigame')
        else
            xPlayer.showNotification(Config.Text.nolockpick)
        end
    else
        xPlayer.triggerEvent('kz_houserobery:startminigame')
        print('mono')
    end
end)


RegisterServerEvent('kz_houserobery:giveloot')
AddEventHandler('kz_houserobery:giveloot', function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    local random = math.random(1,3) 
    if random == 1 then
        xPlayer.addInventoryItem(Config.Loot.badloot[math.random(#Config.Loot.badloot)], math.random(Config.Cant.badloot[1], Config.Cant.badloot[2]))
    elseif random == 2 then
        xPlayer.addInventoryItem(Config.Loot.mediumloot[math.random(#Config.Loot.mediumloot)], math.random(Config.Cant.mediumloot[1], Config.Cant.mediumloot[2]))
    elseif random == 3 then
        xPlayer.addInventoryItem(Config.Loot.goodloot[math.random(#Config.Loot.goodloot)], tonumber(math.random(Config.Cant.goodloot[1], Config.Cant.goodloot[2])))
    end
end)


ESX.RegisterServerCallback('kz_houserobery:countpolice', function(source, cb)
    local police = 0
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.job.name == Config.JobName then
            police = police + 1
        end
    end
    if police >= Config.CopsRequired then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('kz_houserobery:house:cooldown', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	if (os.time() - Config.Lastrob) < Config.Cooldown and Config.Lastrob ~= 0 then
		cb(false)
        xPlayer.showNotification(Config.Text.wait)
	else
		cb(true)
	end
end)

RegisterServerEvent('kz_houserobery:time')
AddEventHandler('kz_houserobery:time', function()
    Config.Lastrob = os.time()
end)


