-- Mobile starter quest tracker.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local quests = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("QuestConfig"))
local gui = Instance.new("ScreenGui")
gui.Name = "QuestTracker"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Position = UDim2.new(0, 12, 0, 80)
frame.Size = UDim2.new(0.46, 0, 0, 196)
frame.BackgroundColor3 = Color3.fromRGB(42, 27, 58)
frame.BackgroundTransparency = 0.14
frame.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(260, 196)
limit.MinSize = Vector2.new(155, 196)
limit.Parent = frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -14, 1, -12)
label.Position = UDim2.fromOffset(7, 6)
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.TextWrapped = true
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 224, 168)
label.Font = Enum.Font.Gotham
label.Parent = frame
local function refresh()
    if player:GetAttribute("ProgressReady") ~= true then
        label.Text = "🎃 Cargando misiones..."
        return
    end
    local lines = {"🎃 MISIONES"}
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    for _, quest in ipairs(quests) do
        local current = player:GetAttribute("Quest_" .. quest.Id) or 0
        local needed = quest.Objective.Count
        local status = current >= needed and "✓" or (level and level.Value < quest.MinLevel and "🔒" or (current .. "/" .. needed))
        table.insert(lines, quest.Name .. ": " .. status)
    end
    table.insert(lines, "🍬 Dulces: " .. (player:GetAttribute("Candy") or 0))
    label.Text = table.concat(lines, "\n")
end
for _, name in ipairs({"ProgressReady", "Quest_WELCOME", "Quest_PUMPKINS", "Quest_CEMETERY", "Quest_SOUL_ENTRY", "Quest_SOUL_HUNTER", "Quest_SOUL_BOSS", "Candy"}) do
    player:GetAttributeChangedSignal(name):Connect(refresh)
end
task.spawn(function()
    local stats = player:WaitForChild("leaderstats")
    stats:WaitForChild("Level").Changed:Connect(refresh)
    refresh()
end)
refresh()
