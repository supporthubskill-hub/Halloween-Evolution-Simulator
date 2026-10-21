-- Touch-friendly read-only inventory. Server controls all actual items.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local request = ReplicatedStorage:WaitForChild("GetInventory")
local gui = Instance.new("ScreenGui")
gui.Name = "InventoryGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end
local function makeButton(name, label, size, pos, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = label
    button.Size = size
    button.Position = pos
    button.BackgroundColor3 = Color3.fromRGB(115,57,183)
    button.TextColor3 = Color3.fromRGB(255,238,199)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    rounded(button, 10)
    return button
end
local open = makeButton("OpenInventory", "MOCHILA", UDim2.fromOffset(100,44), UDim2.new(0,12,1,-116), gui)
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0.88,0,0.70,0)
panel.Position = UDim2.fromScale(0.06,0.14)
panel.BackgroundColor3 = Color3.fromRGB(36,22,50)
panel.Visible = false
panel.Parent = gui
rounded(panel, 16)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(520,650)
limit.Parent = panel
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Text = "🎃 Mi inventario"
title.TextColor3 = Color3.fromRGB(247,204,105)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Size = UDim2.new(0.68,0,0,42)
title.Position = UDim2.fromOffset(12,8)
title.Parent = panel
local close = makeButton("Close", "X", UDim2.fromOffset(42,38), UDim2.new(1,-52,0,8), panel)
local categories = {"Todos","Pet","Ally","Cosmetic","Material"}
local currentCategory = "Todos"
local items = {}
local tabs = Instance.new("ScrollingFrame")
tabs.BackgroundTransparency = 1
tabs.Size = UDim2.new(1,-20,0,43)
tabs.Position = UDim2.fromOffset(10,58)
tabs.ScrollingDirection = Enum.ScrollingDirection.X
tabs.ScrollBarThickness = 3
tabs.CanvasSize = UDim2.fromOffset(475,0)
tabs.Parent = panel
local list = Instance.new("ScrollingFrame")
list.BackgroundTransparency = 1
list.Size = UDim2.new(1,-24,1,-120)
list.Position = UDim2.fromOffset(12,110)
list.ScrollBarThickness = 5
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.fromOffset(0,0)
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.Parent = list
local function render()
    for _, child in list:GetChildren() do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    local shown = 0
    for _, item in ipairs(items) do
        if currentCategory == "Todos" or item.Type == currentCategory then
            shown += 1
            local entry = Instance.new("TextLabel")
            entry.Name = "Item"
            entry.Size = UDim2.new(1,-6,0,54)
            entry.BackgroundColor3 = Color3.fromRGB(69,45,91)
            entry.TextColor3 = Color3.fromRGB(255,238,199)
            entry.TextWrapped = true
            entry.TextScaled = true
            entry.Font = Enum.Font.Gotham
            entry.Text = tostring(item.TemplateId) .. "  |  Nv. " .. tostring(item.Level or 1)
                .. (item.Locked and "  🔒" or "") .. (item.Equipped and "  ✓" or "")
            entry.Parent = list
            rounded(entry, 9)
        end
    end
    if shown == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1,-6,0,70)
        empty.BackgroundTransparency = 1
        empty.Text = "No tienes objetos en esta categoría todavía."
        empty.TextColor3 = Color3.fromRGB(247,204,105)
        empty.TextWrapped = true
        empty.TextScaled = true
        empty.Parent = list
    end
end
for index, category in ipairs(categories) do
    local tab = makeButton(category, category, UDim2.fromOffset(90,35), UDim2.fromOffset((index-1)*95,2), tabs)
    tab.Activated:Connect(function()
        currentCategory = category
        render()
    end)
end
local function refresh()
    local success, response = pcall(function() return request:InvokeServer() end)
    if not success or typeof(response) ~= "table" or response.Ready ~= true then
        items = {}
        render()
        return
    end
    items = typeof(response.Items) == "table" and response.Items or {}
    render()
end
open.Activated:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then refresh() end
end)
close.Activated:Connect(function() panel.Visible = false end)
