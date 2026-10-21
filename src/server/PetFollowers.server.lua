-- Lightweight placeholder pets follow equipped owners.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local world = workspace:WaitForChild("PuebloMaldito")
local folder = Instance.new("Folder")
folder.Name = "PetFollowers"
folder.Parent = world
local models = {}
local function getStage(player)
    return math.clamp(tonumber(player:GetAttribute("EquippedPetStage")) or 1, 1, 8)
end
local function updateAppearance(player)
    local model = models[player]
    local body = model and model:FindFirstChild("Body")
    if not body then return end
    local stage = getStage(player)
    local template = player:GetAttribute("EquippedPetTemplate")
    local base = template == "MoonFox" and Vector3.new(2.5,2,3) or Vector3.new(2.5,2,2)
    body.Size = base * (1 + 0.09 * (stage - 1))
    body.Color = template == "MoonFox"
        and Color3.fromRGB(math.min(255, 135 + stage * 10), 196, 250)
        or Color3.fromRGB(245, math.min(255, 110 + stage * 12), 42)
    local light = body:FindFirstChildOfClass("PointLight")
    if light then light.Brightness = 0.3 + 0.18 * stage end
    local nameplate = body:FindFirstChildOfClass("BillboardGui")
    local label = nameplate and nameplate:FindFirstChildOfClass("TextLabel")
    if label then label.Text = (template == "MoonFox" and "Zorro Lunar" or "Murciélago Calabaza") .. " · E" .. stage end
end
local function clear(player)
    if models[player] then models[player]:Destroy(); models[player] = nil end
end
local function spawn(player)
    clear(player)
    local template = player:GetAttribute("EquippedPetTemplate")
    if template ~= "MoonFox" and template ~= "PumpkinBat" then return end
    local model = Instance.new("Model")
    model.Name = "Pet_" .. player.UserId
    model.Parent = folder
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Shape = Enum.PartType.Ball
    body.Size = template == "MoonFox" and Vector3.new(2.5,2,3) or Vector3.new(2.5,2,2)
    body.Anchored = true
    body.CanCollide = false
    body.Material = Enum.Material.Neon
    body.Color = template == "MoonFox" and Color3.fromRGB(135,196,250) or Color3.fromRGB(245,139,42)
    body.Parent = model
    model.PrimaryPart = body
    local light = Instance.new("PointLight")
    light.Range = 8
    light.Brightness = 0.5
    light.Parent = body
    local nameplate = Instance.new("BillboardGui")
    nameplate.Size = UDim2.fromOffset(130,30)
    nameplate.StudsOffset = Vector3.new(0,2,0)
    nameplate.AlwaysOnTop = true
    nameplate.MaxDistance = 35
    nameplate.Parent = body
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(247,204,105)
    label.TextScaled = true
    label.TextStrokeTransparency = 0.4
    label.Text = template == "MoonFox" and "Zorro Lunar" or "Murciélago Calabaza"
    label.Parent = nameplate
    models[player] = model
    updateAppearance(player)
end
local function watch(player)
    player:GetAttributeChangedSignal("EquippedPetTemplate"):Connect(function() spawn(player) end)
    player:GetAttributeChangedSignal("EquippedPetStage"):Connect(function() updateAppearance(player) end)
    player.CharacterAdded:Connect(function() task.wait(1); if player.Parent then spawn(player) end end)
    if player:GetAttribute("EquippedPetTemplate") then spawn(player) end
end
Players.PlayerAdded:Connect(watch)
for _, player in Players:GetPlayers() do watch(player) end
Players.PlayerRemoving:Connect(clear)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.12 then return end
    local step = elapsed
    elapsed = 0
    for player, model in pairs(models) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and model and model.Parent then
            local target = root.CFrame * CFrame.new(-3.5, 1.5 + math.sin(os.clock()*2)*0.3, 3.5)
            local current = model:GetPivot()
            if (current.Position-target.Position).Magnitude > 50 then
                model:PivotTo(target)
            else
                model:PivotTo(current:Lerp(target, math.min(1,step*5)))
            end
        end
    end
end)
