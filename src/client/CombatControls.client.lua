-- Touch-friendly combat button and desktop shortcut.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local attack = ReplicatedStorage:WaitForChild("BasicAttack")
local gui = Instance.new("ScreenGui")
gui.Name = "CombatGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local button = Instance.new("TextButton")
button.Name = "AttackButton"
button.Size = UDim2.fromOffset(88, 88)
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(1, -20, 1, -130)
button.BackgroundColor3 = Color3.fromRGB(245, 139, 42)
button.TextColor3 = Color3.fromRGB(36, 22, 50)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Text = "⚔"
button.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button
button.Activated:Connect(function() attack:FireServer() end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then attack:FireServer() end
end)
