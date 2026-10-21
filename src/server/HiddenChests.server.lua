-- Server-controlled hidden chests with per-player cooldowns.
-- Rewards use the same server-only grant event as combat and collectibles.
local Players = game:GetService("Players")
local world = workspace:WaitForChild("PuebloMaldito")
local grant = script.Parent:WaitForChild("GrantInventoryItem")
local folder = Instance.new("Folder")
folder.Name = "HiddenChests"
folder.Parent = world
local rng = Random.new()
local chests = {
    {name="Cofre del Bosque", position=Vector3.new(205, 2, 198)},
    {name="Cofre de la Cripta", position=Vector3.new(177, 2, -195)},
    {name="Cofre de la Casa Embrujada", position=Vector3.new(-194, 2, -70)},
    {name="Cofre de la Mansion", position=Vector3.new(-25, 2, 210)},
}
local cooldowns = {}
local COOLDOWN = 600 -- ten minutes per chest, per player
local function createChest(index, info)
    local chest = Instance.new("Part")
    chest.Name = "HiddenChest_" .. index
    chest.Size = Vector3.new(6, 4, 4)
    chest.Position = info.position
    chest.Anchored = true
    chest.Color = Color3.fromRGB(90, 52, 117)
    chest.Material = Enum.Material.WoodPlanks
    chest.Parent = folder
    local trim = Instance.new("Part")
    trim.Name = "GoldTrim"
    trim.Size = Vector3.new(6.2, 0.6, 4.2)
    trim.Position = info.position + Vector3.new(0, 1, 0)
    trim.Anchored = true
    trim.CanCollide = false
    trim.Color = Color3.fromRGB(247, 204, 105)
    trim.Material = Enum.Material.Metal
    trim.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Abrir cofre"
    prompt.ObjectText = info.name
    prompt.HoldDuration = 1
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = chest
    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("ProgressReady") ~= true then return end
        local userId = player.UserId
        cooldowns[userId] = cooldowns[userId] or {}
        local nextTime = cooldowns[userId][index] or 0
        if os.clock() < nextTime then return end
        cooldowns[userId][index] = os.clock() + COOLDOWN
        local roll = rng:NextInteger(1, 1000)
        if roll <= 20 then
            grant:Fire(player, "Pet", "MoonFox") -- 2% rare pet
        elseif roll <= 100 then
            grant:Fire(player, "Pet", "PumpkinBat") -- 8% uncommon pet
        elseif roll <= 350 then
            grant:Fire(player, "Cosmetic", "GhostLantern") -- 25%
        else
            grant:Fire(player, "Material", "HalloweenEssence") -- 65%
        end
    end)
end
for index, info in ipairs(chests) do createChest(index, info) end
Players.PlayerRemoving:Connect(function(player) cooldowns[player.UserId] = nil end)
