-- Mobile-friendly loot and pet progression notifications.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenNotifications"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 18)
frame.Size = UDim2.new(0.78, 0, 0, 46)
frame.BackgroundColor3 = Color3.fromRGB(54, 30, 76)
frame.Visible = false
frame.Parent = gui
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(410, 50)
sizeLimit.Parent = frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.TextWrapped = true
label.TextColor3 = Color3.fromRGB(255, 221, 137)
label.Parent = frame
local sequence = 0
local function show(message)
    sequence += 1
    local token = sequence
    label.Text = message
    frame.Visible = true
    frame.BackgroundTransparency = 0
    label.TextTransparency = 0
    task.delay(3, function()
        if token ~= sequence then return end
        TweenService:Create(frame, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
        local fade = TweenService:Create(label, TweenInfo.new(0.35), {TextTransparency = 1})
        fade:Play()
        fade.Completed:Wait()
        if token == sequence then frame.Visible = false end
    end)
end
local names = {
    MoonFox = "Zorro Lunar",
    PumpkinBat = "Murciélago Calabaza",
    HalloweenEssence = "Esencia de Halloween",
    MagicCrystal = "Cristal Mágico",
    GhostLantern = "Linterna Fantasmal",
}
ReplicatedStorage:WaitForChild("ItemObtained").OnClientEvent:Connect(function(template)
    if typeof(template) == "string" then
        show("🎁 Obtuviste: " .. (names[template] or template))
    end
end)
local previousStage = nil
player:GetAttributeChangedSignal("EquippedPetStage"):Connect(function()
    local stage = player:GetAttribute("EquippedPetStage")
    if typeof(stage) == "number" and previousStage and stage > previousStage then
        show("✨ ¡Tu mascota evolucionó a etapa " .. stage .. "!")
    end
    previousStage = stage
end)
