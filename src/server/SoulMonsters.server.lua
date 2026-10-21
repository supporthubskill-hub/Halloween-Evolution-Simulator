-- Soul Forest monsters, including a tougher altar guardian.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local world = workspace:WaitForChild("PuebloMaldito")
local forest = world:WaitForChild("BosqueDeLasAlmas")
local folder = Instance.new("Folder")
folder.Name = "SoulMonsters"
folder.Parent = forest
local definitions = {
    {name="Luciérnaga Oscura",pos=Vector3.new(-50,4,340),hp=220,damage=10,color=Color3.fromRGB(88,185,160)},
    {name="Luciérnaga Oscura",pos=Vector3.new(55,4,380),hp=220,damage=10,color=Color3.fromRGB(88,185,160)},
    {name="Árbol Poseído",pos=Vector3.new(-70,4,445),hp=360,damage=14,color=Color3.fromRGB(124,85,156)},
    {name="Árbol Poseído",pos=Vector3.new(75,4,480),hp=360,damage=14,color=Color3.fromRGB(124,85,156)},
    {name="Guardián de las Almas",pos=Vector3.new(0,5,520),hp=1800,damage=23,color=Color3.fromRGB(213,127,251),boss=true},
}
local states = {}
local function spawn(def)
    local model = Instance.new("Model")
    model.Name = def.name
    model:SetAttribute("Zone","SoulForest")
    model:SetAttribute("MinimumLevel",51)
    model:SetAttribute("XPReward",def.boss and 650 or 110)
    model.Parent = folder
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Shape = Enum.PartType.Ball
    root.Size = def.boss and Vector3.new(10,10,10) or Vector3.new(5,5,5)
    root.Position = def.pos
    root.Anchored = true
    root.CanCollide = false
    root.Color = def.color
    root.Material = Enum.Material.Neon
    root.Parent = model
    model.PrimaryPart = root
    local hum = Instance.new("Humanoid")
    hum.MaxHealth = def.hp
    hum.Health = def.hp
    hum.Parent = model
    local state = {root=root,hum=hum,origin=def.pos,attacker=nil,angerUntil=0,lastHealth=def.hp,lastHit=0}
    states[model] = state
    hum.HealthChanged:Connect(function(health)
        if health < state.lastHealth and health > 0 then
            local id = model:GetAttribute("LastAttackerUserId")
            local attacker = typeof(id) == "number" and Players:GetPlayerByUserId(id) or nil
            if attacker then state.attacker=attacker;state.angerUntil=os.clock()+12 end
        end
        state.lastHealth=health
    end)
    hum.Died:Connect(function()
        states[model]=nil
        task.delay(4,function() if model.Parent then model:Destroy() end end)
        task.delay(def.boss and 180 or 25,function() if folder.Parent then spawn(def) end end)
    end)
end
for _,def in ipairs(definitions) do spawn(def) end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
    elapsed+=dt
    if elapsed<0.15 then return end
    local step=elapsed
    elapsed=0
    local now=os.clock()
    for model,state in pairs(states) do
        if not model.Parent or state.hum.Health<=0 then continue end
        local target=state.attacker
        local character=target and target.Character
        local root=character and character:FindFirstChild("HumanoidRootPart")
        local hum=character and character:FindFirstChildOfClass("Humanoid")
        if now<state.angerUntil and root and hum and hum.Health>0 and (root.Position-state.origin).Magnitude<48 then
            local delta=root.Position-state.root.Position
            if delta.Magnitude>7 then
                local p=state.root.Position+delta.Unit*math.min(delta.Magnitude,11*step)
                state.root.Position=Vector3.new(p.X,state.origin.Y,p.Z)
            elseif now-state.lastHit>1.8 then
                state.lastHit=now
                hum:TakeDamage(definitions[1].damage)
                if model.Name=="Árbol Poseído" then hum:TakeDamage(4) end
                if model.Name=="Guardián de las Almas" then hum:TakeDamage(13) end
            end
        else
            state.attacker=nil
            state.root.Position=state.root.Position:Lerp(state.origin,math.min(1,step*1.5))
        end
    end
end)
