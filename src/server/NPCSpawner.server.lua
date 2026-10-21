-- Spawn lightweight NPC prototypes with proximity dialogues.
-- Models are placeholders; final art, quests and ally recruitment come later.
local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("PuebloMaldito", 30)
if not world then
    warn("PuebloMaldito missing: NPCs not spawned")
    return
end

local old = world:FindFirstChild("NPCs")
if old then old:Destroy() end
local npcs = Instance.new("Folder")
npcs.Name = "NPCs"
npcs.Parent = world

local entries = {
    {Name="Luna", Position=Vector3.new(-26, 0, -22), Color=Color3.fromRGB(115, 57, 183),
        Lines={"¡Bienvenido al Pueblo Maldito!", "Soy Luna, la bruja del pueblo.", "Pronto podrás aceptar misiones y descubrir magia."}},
    {Name="Bones", Position=Vector3.new(28, 0, 19), Color=Color3.fromRGB(247, 204, 105),
        Lines={"¡Alto ahí, viajero!", "Soy Bones, guardián del cementerio.", "Prepárate para explorar y enfrentar criaturas."}},
    {Name="Boo", Position=Vector3.new(17, 0, -25), Color=Color3.fromRGB(96, 213, 179),
        Lines={"¡Buuu! ¿Te asusté?", "Soy Boo, explorador de secretos.", "Busca rincones ocultos por todo el pueblo."}},
}

local function makePart(name, size, position, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = parent
    return p
end

for _, info in ipairs(entries) do
    local model = Instance.new("Model")
    model.Name = info.Name
    model.Parent = npcs

    local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1), info.Position + Vector3.new(0, 3, 0), info.Color, model)
    root.Transparency = 1
    root.CanCollide = false
    model.PrimaryPart = root

    local body = makePart("Body", Vector3.new(3, 3, 2), info.Position + Vector3.new(0, 2.6, 0), info.Color, model)
    local head = makePart("Head", Vector3.new(2.5, 2.5, 2.5), info.Position + Vector3.new(0, 5.3, 0), Color3.fromRGB(235, 223, 205), model)
    head.Shape = Enum.PartType.Ball

    local sign = Instance.new("BillboardGui")
    sign.Name = "Nameplate"
    sign.Size = UDim2.fromOffset(160, 38)
    sign.StudsOffset = Vector3.new(0, 2, 0)
    sign.AlwaysOnTop = true
    sign.MaxDistance = 40
    sign.Parent = head
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = info.Name
    label.TextColor3 = Color3.fromRGB(255, 229, 171)
    label.TextStrokeTransparency = 0.35
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = sign

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "TalkPrompt"
    prompt.ActionText = "Hablar"
    prompt.ObjectText = info.Name
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0
    prompt.Parent = root

    local messageIndex = 0
    prompt.Triggered:Connect(function(player)
        messageIndex = (messageIndex % #info.Lines) + 1
        -- Dialogue shown locally to the triggering player through a RemoteEvent.
        local replicated = game:GetService("ReplicatedStorage")
        local event = replicated:FindFirstChild("NPCDialogue")
        if event then
            event:FireClient(player, info.Name, info.Lines[messageIndex])
        end
    end)
end

local replicated = game:GetService("ReplicatedStorage")
if not replicated:FindFirstChild("NPCDialogue") then
    local event = Instance.new("RemoteEvent")
    event.Name = "NPCDialogue"
    event.Parent = replicated
end

print("Luna, Bones and Boo NPC prototypes spawned")
