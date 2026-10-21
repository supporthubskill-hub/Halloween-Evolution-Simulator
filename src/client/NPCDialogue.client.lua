-- Simple mobile-friendly NPC dialogue overlay.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("NPCDialogue")
local gui = Instance.new("ScreenGui")
gui.Name = "NPCDialogueGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Name = "Dialogue"
frame.Size = UDim2.fromScale(0.78, 0.17)
frame.Position = UDim2.fromScale(0.11, 0.75)
frame.BackgroundColor3 = Color3.fromRGB(36, 22, 50)
frame.BackgroundTransparency = 0.08
frame.Visible = false
frame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame
local text = Instance.new("TextLabel")
text.Size = UDim2.fromScale(0.94, 0.9)
text.Position = UDim2.fromScale(0.03, 0.05)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(247, 204, 105)
text.TextWrapped = true
text.TextScaled = true
text.Font = Enum.Font.Gotham
text.Parent = frame
local serial = 0
event.OnClientEvent:Connect(function(name, line)
    if typeof(name) ~= "string" or typeof(line) ~= "string" then return end
    serial += 1
    local current = serial
    text.Text = name .. ": " .. line
    frame.Visible = true
    task.delay(6, function()
        if serial == current then frame.Visible = false end
    end)
end)
