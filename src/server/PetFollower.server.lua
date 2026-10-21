-- Lightweight visual pet follower, generated on server for all players.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local folder = Instance.new("Folder")
folder.Name = "EquippedPets"
folder.Parent = workspace
local pets = {}
local function clear(player)
    if pets[player] then pets[player]:Destroy() end
    pets[player] = nil
end
local function refresh(player)
    clear(player)
    local petId = player:GetAttribute("EquippedPetId")
    local template = player:GetAttribute("EquippedPetTemplate")
    if typeof(petId) ~= "string" or (template ~= "MoonFox" and template ~= "PumpkinBat") then return end
    local part = Instance.new("Part")
    part.Name = tostring(player.UserId) .. "_" .. template
    part.Shape = Enum.PartType.Ball
    part.Size = template == "MoonFox" and Vector3.new(2.6,2.6,2.6) or Vector3.new(2,2,2)
    part.Color = template == "MoonFox" and Color3.fromRGB(165,215,255) or Color3.fromRGB(245,139,42)
    part.Material = Enum.Material.Neon
    part.Anchored = true
    part.CanCollide = false
    part.Parent = folder
    pets[player] = part
end
local function connect(player)
    player:GetAttributeChangedSignal("EquippedPetId"):Connect(function() refresh(player) end)
    player:GetAttributeChangedSignal("EquippedPetTemplate"):Connect(function() refresh(player) end)
    refresh(player)
end
Players.PlayerAdded:Connect(connect)
Players.PlayerRemoving:Connect(clear)
for _, player in Players:GetPlayers() do connect(player) end
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.1 then return end
    local step = elapsed
    elapsed = 0
    for player, part in pairs(pets) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and part.Parent then
            local target = root.CFrame * CFrame.new(-3, 1.8, 3)
            local distance = (part.Position - target.Position).Magnitude
            if distance > 45 then
                part.Position = target.Position
            else
                part.Position = part.Position:Lerp(target.Position, math.min(1, step * 6))
            end
        end
    end
end)
