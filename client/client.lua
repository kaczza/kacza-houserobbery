ESX = nil
local PlayerData = {}
local alllocations = {}
local randomlocation = 1
local PED = nil
local oxTargetAdded = false
local Blip = nil
local start, inside, revising, all_reviewed, can_review = false, false, false, false, true
local cont = 0
local collectedLoot = {}

-- ESX init
Citizen.CreateThread(function()
    ESX = exports['es_extended']:getSharedObject()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    Citizen.Wait(800)
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- load houses
Citizen.CreateThread(function()
    local idhouse = 1
    for k,v in pairs(Config.Houses) do
        table.insert(alllocations, {
            id = idhouse,
            door = vector3(v.Door.x, v.Door.y, v.Door.z),
            interior = vector3(v.Interior.x, v.Interior.y, v.Interior.z),
            hint = v.HeadingInt,
            loot = v.LootH
        })
        idhouse = idhouse + 1
    end
end)

-- ped spawn
Citizen.CreateThread(function()
    local pedh = GetHashKey(Config.Ped.Name)
    RequestModel(pedh)
    while not HasModelLoaded(pedh) do Citizen.Wait(1) end
    PED = CreatePed(1, pedh, Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z, Config.Ped.Pos.h, false, true)
    SetBlockingOfNonTemporaryEvents(PED, true)
    SetPedDiesWhenInjured(PED, false)
    SetPedCanPlayAmbientAnims(PED, true)
    SetPedCanRagdollFromPlayerImpact(PED, false)
    SetEntityInvincible(PED, true)
    FreezeEntityPosition(PED, true)

    if Config.OxTarget and not oxTargetAdded then
        exports.ox_target:addModel(pedh, {{
            name = 'steal:house',
            event = 'kz_houserobery:checkpolice',
            icon = 'fa-solid fa-house',
            label = Config.Text.acceptjob,
        }})
        oxTargetAdded = true
    else
        
        Citizen.CreateThread(function()
            while true do
                local s = 1000
                local coords = GetEntityCoords(PlayerPedId())
                if #(coords - vector3(Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z)) < 4
                    and PlayerData.job ~= nil
                    and PlayerData.job.name ~= Config.JobName then
                    s = 5
                    ESX.ShowFloatingHelpNotification(Config.Text.acceptjob, vector3(Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z+1.9))
                    if #(coords - vector3(Config.Ped.Pos.x, Config.Ped.Pos.y, Config.Ped.Pos.z)) < 2 then
                        if IsControlJustReleased(1, 51) then
                            TriggerEvent('kz_houserobery:checkpolice')
                        end
                    end
                end
                Citizen.Wait(s)
            end
        end)
    end
end)


RegisterNetEvent('kz_houserobery:checkpolice')
AddEventHandler('kz_houserobery:checkpolice', function()
    ESX.TriggerServerCallback('kz_houserobery:house:cooldown', function(can)
        if can then
            ESX.TriggerServerCallback('kz_houserobery:countpolice', function(cb)
                if cb then
                    TriggerServerEvent('kz_houserobery:time')
                    TriggerEvent('kz_houserobery:startrobbery')
                else
                    ESX.ShowNotification(Config.Text.notenoughcops)
                end
            end)
        end
    end)
end)

-- start robbery
RegisterNetEvent('kz_houserobery:startrobbery')
AddEventHandler('kz_houserobery:startrobbery', function()
    randomlocation = math.random(1, #alllocations)
    Blip = AddBlipForCoord(alllocations[randomlocation].door)
    SetBlipSprite(Blip, 1)
    SetBlipColour(Blip, 2)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("House")
    EndTextCommandSetBlipName(Blip)
    SetBlipAsMissionCreatorBlip(Blip, true)
    SetBlipRoute(Blip, true)
    ESX.ShowNotification(Config.Text.help)
    start = true

    if Config.OxTarget then
        exports.ox_target:addSphereZone({
            coords = alllocations[randomlocation].door,
            radius = 1,
            debug = false,
            options = {{
                name = 'opendoor',
                serverEvent = 'kz_houserobery:checkitem',
                icon = 'fa-solid fa-circle',
                label = Config.Text.lockpick,
                canInteract = function() return start end
            }}
        })
    else
        Citizen.CreateThread(function()
            while true do
                local s = 1000
                local coords = GetEntityCoords(PlayerPedId())
                if #(coords - alllocations[randomlocation].door) < 3 then
                    s = 5
                    ESX.ShowFloatingHelpNotification(Config.Text.lockpick, alllocations[randomlocation].door)
                    if #(coords - alllocations[randomlocation].door) < 2 then
                        if IsControlJustReleased(0,38) then
                            if start then
                                TriggerServerEvent('kz_houserobery:checkitem')
                            else
                                ESX.ShowNotification(Config.Text.reenter)
                            end
                        end
                    end
                end
                Citizen.Wait(s)
            end
        end)
    end

    Timetoarrive()
end)

-- DisplayLoot function
function DisplayLoot()
    if not alllocations[randomlocation] or not alllocations[randomlocation].loot then
        return
    end

    for i, lootPos in ipairs(alllocations[randomlocation].loot) do
        if not collectedLoot[i] then
            local lootCoords = vector3(lootPos.x, lootPos.y, lootPos.z)

            exports.ox_target:addSphereZone({
                coords = lootCoords,
                radius = 1.0,
                debug = false,
                options = {{
                    name = 'loot_'..i,
                    icon = 'fa-solid fa-box',
                    label = Config.Text.check,
                    canInteract = function()
                        return can_review and PlayerData.job ~= nil and PlayerData.job.name ~= Config.JobName
                    end,
                    onSelect = function()
                        animation()
                        collectedLoot[i] = true
                        revising = true
                        cont = cont + 1

                        if cont == 1 then
                
                        elseif cont >= 4 then
                            revising = false
                            can_review = false
                            all_reviewed = true
                        end
                    end
                }}
            })
        end
    end
end

RegisterNetEvent('kz_houserobery:startminigame')
AddEventHandler('kz_houserobery:startminigame', function()
    startAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer")
    local success = lib.skillCheck({ 'easy', 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'easy' })
    if success then
        inside = true
        RemoveBlip(Blip)
        ClearPedTasks(PlayerPedId())
        SetEntityCoords(PlayerPedId(), alllocations[randomlocation].interior, 0,0,0,0)
        SetEntityHeading(PlayerPedId(), alllocations[randomlocation].hint)
        DisplayLoot()
        Citizen.CreateThread(function()
            while true do
                local s = 1000
                local coords = GetEntityCoords(PlayerPedId())
                if #(coords - alllocations[randomlocation].interior) < 2 then
                    s = 5
                    if Config.OxTarget then
                        exports.ox_target:addSphereZone({
                            coords = alllocations[randomlocation].interior,
                            radius = 1,
                            debug = false,
                            options = {{
                                name = 'exithouse',
                                event = 'kz_houserobery:leavehouse',
                                icon = 'fa-solid fa-circle',
                                label = Config.Text.Leave
                            }}
                        })
                    else
                        ESX.ShowFloatingHelpNotification(Config.Text.Leave, alllocations[randomlocation].interior)
                        if IsControlJustReleased(0,38) then
                            SetEntityCoords(PlayerPedId(), alllocations[randomlocation].door,0,0,0,0)
                        end
                    end
                end
                Citizen.Wait(s)
            end
        end)
        timetocheck()
    else
        ClearPedTasks(PlayerPedId())
    end
end)

-- leave house
RegisterNetEvent('kz_houserobery:leavehouse')
AddEventHandler('kz_houserobery:leavehouse', function()
    start = false
    SetEntityCoords(PlayerPedId(), alllocations[randomlocation].door,0,0,0,0)
end)

-- police call

-- ped blip
Citizen.CreateThread(function()
    if Config.BlipEnabled then
        local blip = AddBlipForCoord(Config.Ped.Pos.x, Config.Ped.Pos.y)
        SetBlipSprite(blip, 280)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 24)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Text.robery)
        EndTextCommandSetBlipName(blip)
    end
end)

-- timers
function Timetoarrive()
    if start then
        Citizen.Wait(420000)
        if not inside then
            start = false
            RemoveBlip(Blip)
            ESX.ShowNotification(Config.Text.time)
        end
    end
end

function timetocheck()
    if inside then
        Citizen.Wait(300000)
        if not revising then
            if not all_reviewed then
                can_review = false
                ESX.ShowNotification(Config.Text.timeover)
                TriggerServerEvent('kz_houserobery_logsloot')
            else
                all_reviewed = false
            end
        end
    end
end

-- animation
function animation()
    startAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@", "player_search")
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(8000)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerServerEvent('kz_houserobery:giveloot')
end

function startAnim(ped, dictionary, anim)
    Citizen.CreateThread(function()
        RequestAnimDict(dictionary)
        while not HasAnimDictLoaded(dictionary) do Citizen.Wait(0) end
        TaskPlayAnim(ped, dictionary, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
    end)
end
