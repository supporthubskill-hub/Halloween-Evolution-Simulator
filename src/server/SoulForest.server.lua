-- Bosque de las Almas: compact, mobile-friendly level 51-150 region.
local world = workspace:WaitForChild("PuebloMaldito")
local forest = Instance.new("Folder")
forest.Name = "BosqueDeLasAlmas"
forest.Parent = world
local function part(name, size, pos, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Parent = forest
    return p
end
part("ForestGround", Vector3.new(280, 2, 280), Vector3.new(0, -1, 420), Color3.fromRGB(26, 52, 55), Enum.Material.Grass)
part("ForestPath", Vector3.new(18, 0.3, 290), Vector3.new(0, 0.2, 292), Color3.fromRGB(77, 70, 90), Enum.Material.Cobblestone)
local rng = Random.new(510150)
for i = 1, 36 do
    local x = rng:NextNumber(-125, 125)
    local z = rng:NextNumber(295, 540)
    if math.abs(x) > 18 then
        part("AncientTrunk", Vector3.new(4, 18, 4), Vector3.new(x, 9, z), Color3.fromRGB(54, 39, 64), Enum.Material.Wood)
        local crown = part("SpiritLeaves", Vector3.new(17, 16, 17), Vector3.new(x, 22, z), Color3.fromRGB(64, 113, 115), Enum.Material.Grass)
        crown.Shape = Enum.PartType.Ball
    end
end
local gate = part("SoulForestGate", Vector3.new(20, 18, 3), Vector3.new(0, 9, 250), Color3.fromRGB(88, 54, 132), Enum.Material.Neon)
gate.CanCollide = false
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Entrar (Nv. 51)"
prompt.ObjectText = "Bosque de las Almas"
prompt.MaxActivationDistance = 14
prompt.Parent = gate
prompt.Triggered:Connect(function(player)
    if player:GetAttribute("ProgressReady") ~= true then return end
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not level or level.Value < 51 or not root then return end
    root.CFrame = CFrame.new(0, 5, 310)
    local progress = script.Parent:FindFirstChild("QuestProgress")
    if progress then progress:Fire(player, "SOUL_ENTRY", 1) end
end)
local returnGate = part("ReturnGate", Vector3.new(15, 14, 3), Vector3.new(0, 7, 285), Color3.fromRGB(96, 213, 179), Enum.Material.Neon)
returnGate.CanCollide = false
local back = Instance.new("ProximityPrompt")
back.ActionText = "Volver al pueblo"
back.ObjectText = "Portal de regreso"
back.MaxActivationDistance = 12
back.Parent = returnGate
back.Triggered:Connect(function(player)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(0, 5, 210) end
end)
part("SoulAltar", Vector3.new(20, 4, 20), Vector3.new(0, 2, 495), Color3.fromRGB(115, 57, 183), Enum.Material.Slate)
