-- Server-authoritative basic attack and XP rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local world = workspace:WaitForChild("PuebloMaldito")
local monsters = world:WaitForChild("NeutralMonsters")
local companions = world:WaitForChild("Companions")
local LevelService = require(script.Parent:WaitForChild("LevelService"))
local AllyConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AllyConfig"))
local attack = ReplicatedStorage:FindFirstChild("BasicAttack") or Instance.new("RemoteEvent")
attack.Name = "BasicAttack"
attack.Parent = ReplicatedStorage
local COOLDOWN, RANGE, DAMAGE, SAFE_RADIUS = 0.65, 13, 15, 50
local lastAttack = {}
local lastDamager = {}
local lastPetAbility = {}
local PET_ABILITY_COOLDOWN = 8
local grantItem = script.Parent:WaitForChild("GrantInventoryItem")
local awardPetXP = script.Parent:WaitForChild("AwardPetXP")

local function award(player, monster)
    if not player or not player.Parent then return end
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild("Level")
    local xp = player:FindFirstChild("XP")
    if level and xp then
        local newLevel, newXP = LevelService.AddXP(level.Value, xp.Value, 35)
        level.Value, xp.Value = newLevel, newXP
    end
    -- One server-generated material reward for every monster defeat.
    grantItem:Fire(player, "Material", "HalloweenEssence")
    awardPetXP:Fire(player, 25)
    local allyName = player:GetAttribute("EquippedAlly")
    if typeof(allyName) == "string" then
        local allyLevel = player:GetAttribute("AllyLevel") or 1
        local allyXP = player:GetAttribute("AllyXP") or 0
        if allyLevel < AllyConfig.MaxLevel then
            local required = math.floor(100 + 30 * (allyLevel - 1) + 0.5 * (allyLevel - 1)^2 + 0.5)
            allyXP += 20
            while allyLevel < AllyConfig.MaxLevel and allyXP >= required do
                allyXP -= required
                allyLevel += 1
                required = math.floor(100 + 30 * (allyLevel - 1) + 0.5 * (allyLevel - 1)^2 + 0.5)
            end
            player:SetAttribute("AllyLevel", allyLevel)
            player:SetAttribute("AllyXP", allyXP)
        end
    end
end

local function damageMonster(player, monster, damage)
    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    monster:SetAttribute("LastAttackerUserId", player.UserId)
    lastDamager[monster] = player
    humanoid:TakeDamage(damage)
    if humanoid.Health <= 0 then
        award(player, monster)
        lastDamager[monster] = nil
    end
end

attack.OnServerEvent:Connect(function(player)
    local now = os.clock()
    if now - (lastAttack[player] or -math.huge) < COOLDOWN then return end
    lastAttack[player] = now
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if Vector3.new(root.Position.X, 0, root.Position.Z).Magnitude < SAFE_RADIUS then return end
    local nearest, nearestDistance = nil, RANGE
    for _, monster in monsters:GetChildren() do
        local targetRoot = monster:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = monster:FindFirstChildOfClass("Humanoid")
        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
            local distance = (targetRoot.Position - root.Position).Magnitude
            if distance < nearestDistance then
                nearest, nearestDistance = monster, distance
            end
        end
    end
    if not nearest then return end
    damageMonster(player, nearest, DAMAGE)
    -- Same power at equal stage, regardless of pet rarity or VIP.
    local pet = player:GetAttribute("EquippedPetTemplate")
    local petId = player:GetAttribute("EquippedPetId")
    local stage = math.clamp(tonumber(player:GetAttribute("EquippedPetStage")) or 1, 1, 8)
    if typeof(petId) == "string" and (pet == "MoonFox" or pet == "PumpkinBat")
        and now - (lastPetAbility[player] or -math.huge) >= PET_ABILITY_COOLDOWN then
        lastPetAbility[player] = now
        damageMonster(player, nearest, 2 + stage * 2)
        player:SetAttribute("LastPetAbility", pet == "MoonFox" and "Luz Lunar" or "Eco Calabaza")
    end
    local allyName = player:GetAttribute("EquippedAlly")
    if typeof(allyName) == "string" and companions:FindFirstChild(tostring(player.UserId) .. "_" .. allyName) then
        -- Ally helps only when player attacks; same damage regardless of VIP status.
        damageMonster(player, nearest, 5)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    lastAttack[player] = nil
    lastPetAbility[player] = nil
end)
