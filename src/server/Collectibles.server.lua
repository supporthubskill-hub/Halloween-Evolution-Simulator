-- Explore and collect respawning Halloween crystals.
local world = workspace:WaitForChild("PuebloMaldito")
local grant = script.Parent:WaitForChild("GrantInventoryItem")
local folder = Instance.new("Folder")
folder.Name = "Collectibles"
folder.Parent = world
local locations = {
    Vector3.new(-80, 2, 95),
    Vector3.new(-160, 2, 80),
    Vector3.new(85, 2, 180),
    Vector3.new(195, 2, 75),
    Vector3.new(95, 2, -65),
    Vector3.new(175, 2, -185),
}
for index, position in ipairs(locations) do
    local crystal = Instance.new("Part")
    crystal.Name = "MagicCrystal_" .. index
    crystal.Size = Vector3.new(3, 4, 3)
    crystal.Position = position
    crystal.Shape = Enum.PartType.Ball
    crystal.Material = Enum.Material.Neon
    crystal.Color = Color3.fromRGB(96, 213, 179)
    crystal.Anchored = true
    crystal.CanCollide = false
    crystal.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Recolectar"
    prompt.ObjectText = "Cristal mágico"
    prompt.MaxActivationDistance = 9
    prompt.HoldDuration = 0.5
    prompt.Parent = crystal
    local cooldown = {}
    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("ProgressReady") ~= true then return end
        local now = os.clock()
        if now - (cooldown[player.UserId] or -math.huge) < 90 then return end
        cooldown[player.UserId] = now
        grant:Fire(player, "Material", "MagicCrystal")
    end)
end
