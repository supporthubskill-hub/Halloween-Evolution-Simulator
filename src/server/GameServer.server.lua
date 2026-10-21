-- Player progression persistence. Requires published Roblox experience and DataStore access.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("HalloweenEvolution_PlayerProgress_v1")
local MAX_LEVEL = 1000
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local inventories = {}
local loaded = {}
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
