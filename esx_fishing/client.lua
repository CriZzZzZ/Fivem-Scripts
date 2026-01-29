ESX = exports['es_extended']:getSharedObject()
local fishing = false

-- BLIPS
CreateThread(function()
    -- Loja
    local shopBlip = AddBlipForCoord(Config.FishingShop.coords.x, Config.FishingShop.coords.y, Config.FishingShop.coords.z)
    SetBlipSprite(shopBlip, 68)
    SetBlipDisplay(shopBlip, 4)
    SetBlipScale(shopBlip, 0.8)
    SetBlipColour(shopBlip, 2)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Loja de Pesca")
    EndTextCommandSetBlipName(shopBlip)

    -- Vendedor de peixe
    local sellerBlip = AddBlipForCoord(Config.FishSeller.coords.x, Config.FishSeller.coords.y, Config.FishSeller.coords.z)
    SetBlipSprite(sellerBlip, 68)
    SetBlipDisplay(sellerBlip, 4)
    SetBlipScale(sellerBlip, 0.8)
    SetBlipColour(sellerBlip, 5)
    SetBlipAsShortRange(sellerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vendedor de Peixe")
    EndTextCommandSetBlipName(sellerBlip)

    -- Zonas de pesca
    for _, zone in pairs(Config.FishingZones) do
        local fishBlip = AddBlipForCoord(zone.x, zone.y, zone.z)
        SetBlipSprite(fishBlip, 68)
        SetBlipDisplay(fishBlip, 4)
        SetBlipScale(fishBlip, 0.7)
        SetBlipColour(fishBlip, 3)
        SetBlipAsShortRange(fishBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Zona de Pesca")
        EndTextCommandSetBlipName(fishBlip)
    end
end)

-- NPCs
CreateThread(function()
    local models = {`a_m_m_farmer_01`, `a_m_m_farmer_01`}
    local coords = {Config.FishingShop.coords, Config.FishSeller.coords}
    local heading = {Config.FishingShop.heading, Config.FishSeller.heading}

    for i=1, #models do
        RequestModel(models[i])
        while not HasModelLoaded(models[i]) do Wait(0) end

        local npc = CreatePed(0, models[i], coords[i].x, coords[i].y, coords[i].z - 1.0, heading[i], false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
    end
end)

-- Zonas de pesca
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, zone in pairs(Config.FishingZones) do
            if #(coords - zone) < 10.0 then
                sleep = 0
                DrawMarker(1, zone.x, zone.y, zone.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 150, 255, 150, false, true, 2)
                if #(coords - zone) < 2.0 then
                    ESX.ShowHelpNotification("Pressiona ~INPUT_CONTEXT~ para começar a pescar")
                    if IsControlJustPressed(0, 38) and not fishing then
                        StartFishing()
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Parar pesca manual (X)
CreateThread(function()
    while true do
        Wait(0)
        if fishing then
            if IsControlJustPressed(0, 73) then
                fishing = false
                ClearPedTasks(PlayerPedId())
                ESX.ShowNotification("Paraste de pescar")
            end
        end
    end
end)

-- Começar pesca
function StartFishing()
    local ped = PlayerPedId()
    fishing = true
    ESX.ShowNotification("Começaste a pescar 🎣")
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_FISHING", 0, true)

    CreateThread(function()
        while fishing do
            Wait(Config.FishingTime)
            local caught, fishName = CatchFishSync()
            if not caught then
                fishing = false
                ClearPedTasks(ped)
                ESX.ShowNotification("Ficaste sem isco 🪱")
                break
            end
            ESX.ShowNotification("Apanhaste um " .. fishName .. " 🐟")
        end
    end)
end

-- Trigger para o server
function CatchFishSync()
    local finished = false
    local fishName = ""
    local success = false

    ESX.TriggerServerCallback('esx_fishing:catchFishSync', function(result, name)
        success = result
        fishName = name or ""
        finished = true
    end)

    while not finished do Wait(0) end
    return success, fishName
end

-- Loja de pesca
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Loja
        if #(coords - Config.FishingShop.coords) < 2.0 then
            sleep = 0
            ESX.ShowHelpNotification("Pressiona ~INPUT_CONTEXT~ para comprar isco")
            if IsControlJustPressed(0, 38) then
                OpenFishingShop()
            end
        end

        -- Vendedor de peixe
        if #(coords - Config.FishSeller.coords) < 2.0 then
            sleep = 0
            ESX.ShowHelpNotification("Pressiona ~INPUT_CONTEXT~ para vender peixe")
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('esx_fishing:sellFish')
            end
        end

        Wait(sleep)
    end
end)

function OpenFishingShop()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fishing_shop', {
        title = 'Loja de Pesca',
        align = 'top-left',
        elements = {
            {label = 'Vara de Pesca - $250', value = 'rod'},
            {label = 'Isco (x10) - $50', value = 'bait'}
        }
    }, function(data, menu)
        if data.current.value == 'rod' then
            TriggerServerEvent('esx_fishing:buyItem', 'fishing_rod', 1)
        elseif data.current.value == 'bait' then
            TriggerServerEvent('esx_fishing:buyItem', 'bait', 10)
        end
    end, function(data, menu)
        menu.close()
    end)
end
