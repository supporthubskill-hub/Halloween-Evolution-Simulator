-- Five collectable pumpkins for the starter quest; progress saved by GameServer.
local world = workspace:WaitForChild("PuebloMaldito")
local questProgress = script.Parent:WaitForChild("QuestProgress")
local folder = Instance.new("Folder")
folder.Name = "QuestPumpkins"
folder.Parent = world
local locations = {
    Vector3.new(-60, 2, -60), Vector3.new(-85, 2, 55),
    Vector3.new(75, 2, 55), Vector3.new(60, 2, -80),
    Vector3.new(-110, 2, 95),
}
for index, position in ipairs(locations) do
    local pumpkin = Instance.new("Part")
    pumpkin.Name = "QuestPumpkin_" .. index
    pumpkin.Shape = Enum.PartType.Ball
    pumpkin.Size = Vector3.new(4, 3, 4)
    pumpkin.Position = position
    pumpkin.Anchored = true
    pumpkin.CanCollide = false
    pumpkin.Material = Enum.Material.Neon
    pumpkin.Color = Color3.fromRGB(246, 139, 42)
    pumpkin.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Recoger"
    prompt.ObjectText = "Calabaza perdida"
    prompt.MaxActivationDistance = 9
    prompt.Parent = pumpkin
    local collected = {}
    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("ProgressReady") ~= true then return end
        if collected[player.UserId] then return end
        local stats = player:FindFirstChild("leaderstats")
        local level = stats and stats:FindFirstChild("Level")
        if not level or level.Value < 3 or (player:GetAttribute("Quest_PUMPKINS") or 0) >= 5 then return end
        collected[player.UserId] = true
        questProgress:Fire(player, "PUMPKINS", 1)
    end)
end
