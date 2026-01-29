ESX = exports['es_extended']:getSharedObject()

-- Pesca automática
ESX.RegisterServerCallback('esx_fishing:catchFishSync', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bait = xPlayer.getInventoryItem('bait')

    if bait.count <= 0 then
        cb(false)
        return
    end

    xPlayer.removeInventoryItem('bait', 1)

    local rand = math.random(1, 100)
    local cumulative = 0
    local caughtFish = Config.FishTypes[1]

    for _, fish in pairs(Config.FishTypes) do
        cumulative = cumulative + fish.chance
        if rand <= cumulative then
            caughtFish = fish
            break
        end
    end

    xPlayer.addInventoryItem(caughtFish.item, 1)
    cb(true, caughtFish.name)
end)

-- Comprar itens
RegisterNetEvent('esx_fishing:buyItem', function(item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.ShopPrices[item] * count

    if xPlayer.getMoney() < price then
        TriggerClientEvent('esx:showNotification', source, "Dinheiro insuficiente")
        return
    end

    xPlayer.removeMoney(price)
    xPlayer.addInventoryItem(item, count)
    TriggerClientEvent('esx:showNotification', source, "Compraste " .. count .. "x " .. item)
end)

-- Vender peixe
RegisterNetEvent('esx_fishing:sellFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalPrice = 0

    for _, fish in pairs(Config.FishTypes) do
        local fishItem = xPlayer.getInventoryItem(fish.item)
        if fishItem.count > 0 then
            xPlayer.removeInventoryItem(fish.item, fishItem.count)
            totalPrice = totalPrice + math.random(fish.price.min, fish.price.max) * fishItem.count
        end
    end

    if totalPrice > 0 then
        xPlayer.addMoney(totalPrice)
        TriggerClientEvent('esx:showNotification', source, "Vendeste todos os peixes por $" .. totalPrice)
    else
        TriggerClientEvent('esx:showNotification', source, "Não tens peixes para vender")
    end
end)
