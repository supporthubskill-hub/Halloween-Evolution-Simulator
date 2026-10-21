-- Server checks cemetery discovery; never trusts client quest completion.
local Players = game:GetService("Players")
local progress = script.Parent:WaitForChild("QuestProgress")
local cooldown = {}
while task.wait(2) do
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("ProgressReady") == true and (player:GetAttribute("Quest_CEMETERY") or 0) < 1 then
            local stats = player:FindFirstChild("leaderstats")
            local level = stats and stats:FindFirstChild("Level")
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and level and level.Value >= 25 then
                local p = root.Position
                if p.X >= 93 and p.X <= 198 and p.Z >= -188 and p.Z <= -82 then
                    progress:Fire(player, "CEMETERY", 1)
                end
            end
        end
    end
end
