-- Prototype only: progress is not persisted between sessions yet.
local Players = game:GetService("Players")
local LevelService = require(script.Parent.LevelService)

local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local levelValue = Instance.new("IntValue")
    levelValue.Name = "Level"
    levelValue.Value = 1
    levelValue.Parent = leaderstats

    local xpValue = Instance.new("IntValue")
    xpValue.Name = "XP"
    xpValue.Value = 0
    xpValue.Parent = player

    -- Rewarding XP from validated server events will be added later.
    -- Never trust arbitrary XP amounts submitted by the client.
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end
