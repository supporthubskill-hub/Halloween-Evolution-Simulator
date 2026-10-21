-- Prototype ally recruitment and following.
-- One ally per player, including free players. No paid combat advantages.
-- Session-only: DataStore persistence and real NPC combat come later.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("PuebloMaldito", 30)
if not world then warn("PuebloMaldito not found"); return end
local npcs = world:WaitForChild("NPCs", 30)
if not npcs then warn("NPCs not found"); return end

local companionsFolder = Instance.new("Folder")
companionsFolder.Name = "Companions"
companionsFolder.Parent = world
local equipped = {}
local validNames = {Luna=true, Bones=true, Boo=true}

local function removeCompanion(player)
    local current = equipped[player]
    if current then
        if current.Model then current.Model:Destroy() end
        equipped[player] = nil
    end
end

local function equip(player, allyName)
    if not validNames[allyName] then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local previousName = player:GetAttribute("EquippedAlly") or player:GetAttribute("SavedAllyName")
    local previousLevel = player:GetAttribute("AllyLevel") or 1
    local previousXP = player:GetAttribute("AllyXP") or 0
    removeCompanion(player)
    local template = npcs:FindFirstChild(allyName)
    if not template then return end
    local model = template:Clone()
    model.Name = tostring(player.UserId) .. "_" .. allyName
    for _, desc in model:GetDescendants() do
        if desc:IsA("ProximityPrompt") then desc:Destroy() end
        if desc:IsA("BasePart") then desc.CanCollide = false end
    end
    model.Parent = companionsFolder
    model:PivotTo(root.CFrame * CFrame.new(4, 0, 4))
    equipped[player] = {Name=allyName, Model=model, Level=1, XP=0}
    player:SetAttribute("EquippedAlly", allyName)
    player:SetAttribute("SavedAllyName", allyName)
    player:SetAttribute("AllyLevel", previousName == allyName and previousLevel or 1)
    player:SetAttribute("AllyXP", previousName == allyName and previousXP or 0)
end

-- Add a separate recruitment prompt to each village NPC.
for allyName in pairs(validNames) do
    local npc = npcs:WaitForChild(allyName, 10)
    local root = npc and npc:FindFirstChild("HumanoidRootPart")
    if root then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "RecruitPrompt"
        prompt.ActionText = "Reclutar aliado"
        prompt.ObjectText = allyName
        prompt.MaxActivationDistance = 12
        prompt.HoldDuration = 0.5
        prompt.RequiresLineOfSight = false
        prompt.Parent = root
        prompt.Triggered:Connect(function(player)
            equip(player, allyName)
        end)
    end
end

-- Move anchored placeholder models near the player at a throttled interval.
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < 0.1 then return end
    accumulator = 0
    for player, data in pairs(equipped) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local model = data.Model
        if root and model and model.Parent then
            local target = root.CFrame * CFrame.new(3.5, 0, 4)
            local current = model:GetPivot()
            local distance = (current.Position - target.Position).Magnitude
            if distance > 55 then
                model:PivotTo(target)
            elseif distance > 1.5 then
                model:PivotTo(current:Lerp(target, 0.2))
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeCompanion)
Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function()
        removeCompanion(player)
        player:SetAttribute("EquippedAlly", nil)
        -- SavedAllyName and progression persist through respawns.
    end)
end)

-- Restore the saved ally once progress and character are ready.
local function setupRestore(player)
    task.spawn(function()
        local deadline = os.clock() + 25
        while player.Parent and player:GetAttribute("ProgressReady") == nil and os.clock() < deadline do
            task.wait(0.2)
        end
        if player:GetAttribute("ProgressReady") ~= true then return end
        local saved = player:GetAttribute("SavedAllyName")
        if not validNames[saved] then return end
        local character = player.Character or player.CharacterAdded:Wait()
        character:WaitForChild("HumanoidRootPart", 10)
        if player.Parent and player:GetAttribute("EquippedAlly") == nil then
            equip(player, saved)
        end
    end)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if player.Parent and player:GetAttribute("ProgressReady") == true
            and not equipped[player] and validNames[player:GetAttribute("SavedAllyName")] then
            equip(player, player:GetAttribute("SavedAllyName"))
        end
    end)
end
Players.PlayerAdded:Connect(setupRestore)
for _, player in Players:GetPlayers() do setupRestore(player) end
