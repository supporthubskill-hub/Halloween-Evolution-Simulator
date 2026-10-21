-- Neutral monsters: they only retaliate after taking damage.
-- Server-only prototype. Uses Roblox Humanoids and simple anchored roaming positions.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local world = Workspace:WaitForChild("PuebloMaldito", 30)
if not world then return end
local previous = world:FindFirstChild("NeutralMonsters")
if previous then previous:Destroy() end
local folder = Instance.new("Folder")
folder.Name = "NeutralMonsters"
folder.Parent = world

local definitions = {
    {name="Calabaza Salvaje", pos=Vector3.new(-115, 0, 105), color=Color3.fromRGB(245,139,42), hp=65},
    {name="Calabaza Salvaje", pos=Vector3.new(-145, 0, 140), color=Color3.fromRGB(245,139,42), hp=65},
    {name="Espíritu Errante", pos=Vector3.new(115, 0, 105), color=Color3.fromRGB(96,213,179), hp=80},
    {name="Espíritu Errante", pos=Vector3.new(165, 0, 160), color=Color3.fromRGB(96,213,179), hp=80},
    {name="Esqueleto Perdido", pos=Vector3.new(105, 0, -95), color=Color3.fromRGB(217,209,194), hp=100},
    {name="Esqueleto Perdido", pos=Vector3.new(180, 0, -105), color=Color3.fromRGB(217,209,194), hp=100},
}
local RETALIATE_SECONDS = 10
local LEASH_DISTANCE = 38
local ATTACK_DISTANCE = 5
local ATTACK_DAMAGE = 6
local ATTACK_COOLDOWN = 1.5
local states = {}

local function spawnMonster(def)
    local model = Instance.new("Model")
    model.Name = def.name
    model.Parent = folder
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(3, 3, 3)
    root.Shape = Enum.PartType.Ball
    root.Color = def.color
    root.Anchored = true
    root.CanCollide = false
    root.Position = def.pos + Vector3.new(0, 3, 0)
    root.Parent = model
    model.PrimaryPart = root
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = def.hp
    humanoid.Health = def.hp
    humanoid.Parent = model
    local state = {root=root, humanoid=humanoid, origin=root.Position, lastHealth=def.hp,
        attacker=nil, angerUntil=0, lastAttack=0, phase=math.random() * 6}
    states[model] = state
    humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < state.lastHealth and newHealth > 0 then
            -- The damage dealer must be attributed by trusted server combat code.
            -- Do not attack random nearby players when attribution is missing.
            local attackerId = model:GetAttribute("LastAttackerUserId")
            local attacker = typeof(attackerId) == "number" and Players:GetPlayerByUserId(attackerId) or nil
            if attacker then
                state.attacker = attacker
                state.angerUntil = os.clock() + RETALIATE_SECONDS
            end
        end
        state.lastHealth = newHealth
    end)
    humanoid.Died:Connect(function()
        states[model] = nil
        task.delay(5, function() if model.Parent then model:Destroy() end end)
        task.delay(20, function() if folder.Parent then spawnMonster(def) end end)
    end)
end

for _, def in ipairs(definitions) do spawnMonster(def) end

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.12 then return end
    local step = elapsed
    elapsed = 0
    local now = os.clock()
    for model, state in pairs(states) do
        if not model.Parent or state.humanoid.Health <= 0 then continue end
        local root = state.root
        local targetPlayer = state.attacker
        local character = targetPlayer and targetPlayer.Character
        local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
        local valid = now < state.angerUntil and targetRoot and targetHumanoid and targetHumanoid.Health > 0
        if valid and (targetRoot.Position - state.origin).Magnitude <= LEASH_DISTANCE then
            local delta = targetRoot.Position - root.Position
            local distance = delta.Magnitude
            if distance > ATTACK_DISTANCE and distance > 0.01 then
                local nextPosition = root.Position + delta.Unit * math.min(distance, 9 * step)
                root.Position = Vector3.new(nextPosition.X, state.origin.Y, nextPosition.Z)
            elseif now - state.lastAttack >= ATTACK_COOLDOWN then
                state.lastAttack = now
                targetHumanoid:TakeDamage(ATTACK_DAMAGE)
            end
        else
            state.attacker = nil
            local home = state.origin + Vector3.new(math.sin(now * 0.6 + state.phase) * 5, 0,
                math.cos(now * 0.6 + state.phase) * 5)
            root.Position = root.Position:Lerp(home, math.min(1, step * 1.5))
        end
    end
end)
