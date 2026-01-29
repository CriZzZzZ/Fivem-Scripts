Config = {}

-- Zonas de pesca
Config.FishingZones = {
    vector3(-1845.9, -1250.6, 8.6)
}

Config.FishingTime = 5000 -- ms entre peixes

-- Itens
Config.Items = {
    rod = 'fishing_rod',
    bait = 'bait'
}

-- Tipos de peixes
Config.FishTypes = {
    {name = "Peixe Comum", item = "fish_common", price = {min = 20, max = 30}, chance = 60},
    {name = "Peixe Raro", item = "fish_rare", price = {min = 50, max = 70}, chance = 30},
    {name = "Peixe Épico", item = "fish_epic", price = {min = 100, max = 150}, chance = 10}
}

-- Loja de pesca
Config.FishingShop = {
    coords = vector3(-1593.6, 5192.9, 4.3),
    heading = 120.0
}

Config.ShopPrices = {
    fishing_rod = 250,
    bait = 5
}

-- NPC vendedor de peixe
Config.FishSeller = {
    coords = vector3(-1602.0, 5250.0, 4.0),
    heading = 90.0
}
