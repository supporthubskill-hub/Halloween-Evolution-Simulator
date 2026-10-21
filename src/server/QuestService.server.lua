-- Server-authoritative starter quests with one-time rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LevelService = require(script.Parent:WaitForChild("LevelService"))
local QuestConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("QuestConfig"))
local definitions = {}
for _, quest in ipairs(QuestConfig) do definitions[quest.Id] = quest end
local progressEvent = Instance.new("BindableEvent")
progressEvent.Name = "QuestProgress"
progressEvent.Parent = script.Parent
local toast = Instance.new("RemoteEvent")
toast.Name = "QuestToast"
toast.Parent = ReplicatedStorage
local function advance(player, id, amount)
    if player:GetAttribute("ProgressReady") ~= true then return end
    local quest = definitions[id]
    if not quest then return end
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    local xp = player:FindFirstChild("XP")
    if not level or not xp or level.Value < quest.MinLevel then return end
    local attribute = "Quest_" .. id
    local previous = player:GetAttribute(attribute)
    if typeof(previous) ~= "number" then return end
    local required = quest.Objective.Count
    if previous >= required then return end
    local nextValue = math.min(required, previous + math.clamp(amount, 1, required))
    player:SetAttribute(attribute, nextValue)
    if nextValue >= required then
        level.Value, xp.Value = LevelService.AddXP(level.Value, xp.Value, quest.Reward.XP)
        player:SetAttribute("Candy", math.min(2000000000, (player:GetAttribute("Candy") or 0) + quest.Reward.Candy))
        toast:FireClient(player, "🎃 Misión completada: " .. quest.Name .. "  +" .. quest.Reward.XP .. " XP  +" .. quest.Reward.Candy .. " dulces")
    else
        toast:FireClient(player, quest.Name .. "  " .. nextValue .. "/" .. required)
    end
end
progressEvent.Event:Connect(function(player, id, amount)
    if typeof(player) ~= "Instance" or not player:IsA("Player") then return end
    if typeof(id) ~= "string" or typeof(amount) ~= "number" then return end
    advance(player, id, amount)
end)
