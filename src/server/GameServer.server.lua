-- Player progression persistence. Requires published Roblox experience and DataStore access.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("HalloweenEvolution_PlayerProgress_v1")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MAX_LEVEL = 1000
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local inventories = {}
local loaded = {}
-- Only trusted server scripts can request inventory grants.
local grantEvent = Instance.new("BindableEvent")
grantEvent.Name = "GrantInventoryItem"
grantEvent.Parent = script.Parent
grantEvent.Event:Connect(function(player, itemType, templateId)
    if not loaded[player] or player:GetAttribute("ProgressReady") ~= true then return end
    if not InventoryService.TYPES[itemType] or typeof(templateId) ~= "string" then return end
    if #templateId == 0 or #templateId > 64 then return end
    local inventory = inventories[player]
    if not inventory or #inventory >= InventoryService.MAX_ITEMS then return end
    local item = InventoryService.NewItem(itemType, templateId, 1)
    table.insert(inventory, item)
    local notification = ReplicatedStorage:FindFirstChild("ItemObtained")
    if notification then notification:FireClient(player, item.TemplateId) end
end)
local notification = Instance.new("RemoteEvent")
notification.Name = "ItemObtained"
notification.Parent = ReplicatedStorage
local inventoryRequest = Instance.new("RemoteFunction")
inventoryRequest.Name = "GetInventory"
inventoryRequest.Parent = ReplicatedStorage
inventoryRequest.OnServerInvoke = function(player)
    if not loaded[player] then return {Ready=false, Items={}} end
    return {Ready=true, Items=InventoryService.Sanitize(inventories[player])}
end
-- Equipment changes are validated against the server-owned inventory.
local equipRequest = Instance.new("RemoteFunction")
equipRequest.Name = "EquipPet"
equipRequest.Parent = ReplicatedStorage
equipRequest.OnServerInvoke = function(player, itemId)
    if not loaded[player] or player:GetAttribute("ProgressReady") ~= true then
        return {Success=false, Message="Inventario no disponible"}
    end
    if typeof(itemId) ~= "string" or #itemId > 100 then
        return {Success=false, Message="Objeto inválido"}
    end
    local inventory = inventories[player]
    local item = InventoryService.Find(inventory, itemId)
    if not item or item.Type ~= "Pet" then
        return {Success=false, Message="Mascota no encontrada"}
    end
    if item.Locked then
        return {Success=false, Message="Mascota bloqueada"}
    end
    local shouldEquip = not item.Equipped
    for _, entry in ipairs(inventory) do
        if entry.Type == "Pet" then entry.Equipped = false end
    end
    item.Equipped = shouldEquip
    player:SetAttribute("EquippedPetId", shouldEquip and item.Id or nil)
    player:SetAttribute("EquippedPetTemplate", shouldEquip and item.TemplateId or nil)
    return {Success=true, Items=InventoryService.Sanitize(inventory)}
end
-- Lock/unlock owned items; equipped items cannot be locked.
local lockRequest = Instance.new("RemoteFunction")
lockRequest.Name = "SetItemLocked"
lockRequest.Parent = ReplicatedStorage
lockRequest.OnServerInvoke = function(player, itemId, locked)
    if not loaded[player] or player:GetAttribute("ProgressReady") ~= true then
        return {Success=false, Message="Inventario no disponible"}
    end
    if typeof(itemId) ~= "string" or #itemId > 100 or typeof(locked) ~= "boolean" then
        return {Success=false, Message="Solicitud inválida"}
    end
    local inventory = inventories[player]
    if not inventory then return {Success=false, Message="Inventario no disponible"} end
    local item = InventoryService.Find(inventory, itemId)
    if not item then return {Success=false, Message="Objeto no encontrado"} end
    if locked and item.Equipped then return {Success=false, Message="Primero quita el objeto"} end
    item.Locked = locked
    return {Success=true, Items=InventoryService.Sanitize(inventory)}
end
local function clampInteger(value, min, max, fallback)
    if typeof(value) ~= "number" or value ~= value then return fallback end
    return math.clamp(math.floor(value), min, max)
end
local function loadPlayer(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = 1
    level.Parent = leaderstats
    local xp = Instance.new("IntValue")
    xp.Name = "XP"
    xp.Value = 0
    xp.Parent = player
    local ok, data = pcall(function()
        return store:GetAsync("player_" .. player.UserId)
    end)
    if not player.Parent then return end
    if not ok then
        warn("Progress load failed for", player.UserId, data)
        player:SetAttribute("ProgressReady", false)
        return -- Never overwrite existing saves when loading failed.
    end
    inventories[player] = InventoryService.Sanitize(typeof(data) == "table" and data.Inventory or nil)
    if typeof(data) == "table" then
        level.Value = clampInteger(data.Level, 1, MAX_LEVEL, 1)
        xp.Value = clampInteger(data.XP, 0, 2000000000, 0)
        local name = data.AllyName
        if name == "Luna" or name == "Bones" or name == "Boo" then
            player:SetAttribute("SavedAllyName", name)
            player:SetAttribute("AllyLevel", clampInteger(data.AllyLevel, 1, MAX_LEVEL, 1))
            player:SetAttribute("AllyXP", clampInteger(data.AllyXP, 0, 2000000000, 0))
        end
    end
    loaded[player] = true
    local equippedPet
    for _, entry in ipairs(inventories[player]) do
        if entry.Type == "Pet" and entry.Equipped and not equippedPet then
            equippedPet = entry
        elseif entry.Type == "Pet" then
            entry.Equipped = false
        end
    end
    if equippedPet then
        player:SetAttribute("EquippedPetId", equippedPet.Id)
        player:SetAttribute("EquippedPetTemplate", equippedPet.TemplateId)
    end
    player:SetAttribute("ProgressReady", true)
end
local function savePlayer(player)
    if not loaded[player] then return end
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    local xp = player:FindFirstChild("XP")
    if not level or not xp then return end
    local allyName = player:GetAttribute("EquippedAlly") or player:GetAttribute("SavedAllyName")
    local data = {
        Level = level.Value,
        XP = xp.Value,
        AllyName = allyName,
        AllyLevel = player:GetAttribute("AllyLevel") or 1,
        AllyXP = player:GetAttribute("AllyXP") or 0,
        Inventory = InventoryService.Sanitize(inventories[player]),
    }
    local ok, err = pcall(function()
        store:UpdateAsync("player_" .. player.UserId, function()
            return data
        end)
    end)
    if not ok then warn("Progress save failed for", player.UserId, err) end
end
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(player)
    savePlayer(player)
    loaded[player] = nil
    inventories[player] = nil
end)
game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        savePlayer(player)
    end
end)
for _, player in Players:GetPlayers() do task.spawn(loadPlayer, player) end
