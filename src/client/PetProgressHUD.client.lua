-- Compact mobile pet progression HUD; reads server-owned replicated attributes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local PetConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PetConfig"))
local gui = Instance.new("ScreenGui")
gui.Name = "PetProgressHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Name = "PetProgress"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -12, 1, -78)
frame.Size = UDim2.new(0.42, 0, 0, 72)
frame.BackgroundColor3 = Color3.fromRGB(40, 25, 59)
frame.BackgroundTransparency = 0.12
frame.Visible = false
frame.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MinSize = Vector2.new(145, 72)
limit.MaxSize = Vector2.new(250, 72)
limit.Parent = frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -12, 0, 42)
label.Position = UDim2.fromOffset(6, 2)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 220, 148)
label.TextWrapped = true
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = frame
local track = Instance.new("Frame")
track.Position = UDim2.new(0, 8, 1, -20)
track.Size = UDim2.new(1, -16, 0, 12)
track.BackgroundColor3 = Color3.fromRGB(83, 62, 107)
track.Parent = frame
local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(174, 132, 255)
fill.Parent = track
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill
local function update()
    local template = player:GetAttribute("EquippedPetTemplate")
    if template ~= "MoonFox" and template ~= "PumpkinBat" then
        frame.Visible = false
        return
    end
    frame.Visible = true
    local level = math.clamp(tonumber(player:GetAttribute("EquippedPetLevel")) or 1, 1, PetConfig.MaxLevel)
    local stage = PetConfig.GetStage(level)
    local name = PetConfig.Pets[template].DisplayName
    label.Text = name .. " · Nv. " .. level .. " · Etapa " .. stage
    local xp = math.max(0, tonumber(player:GetAttribute("EquippedPetXP")) or 0)
    local required = PetConfig.RequiredXP(level)
    fill.Size = UDim2.fromScale(required > 0 and math.clamp(xp / required, 0, 1) or 1, 1)
end
for _, attr in ipairs({"EquippedPetTemplate", "EquippedPetLevel", "EquippedPetXP", "EquippedPetStage"}) do
    player:GetAttributeChangedSignal(attr):Connect(update)
end
update()
