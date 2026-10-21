-- Pueblo Maldito: lightweight procedural prototype for Roblox Studio.
-- Builds the level once on server startup; edit layout values here.
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local existing = Workspace:FindFirstChild("PuebloMaldito")
if existing then
    existing:Destroy()
end

local world = Instance.new("Folder")
world.Name = "PuebloMaldito"
world.Parent = Workspace

local function part(name, size, position, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

local night = Color3.fromRGB(36, 22, 50)
local stone = Color3.fromRGB(79, 73, 91)
local orange = Color3.fromRGB(245, 139, 42)
local purple = Color3.fromRGB(115, 57, 183)
local teal = Color3.fromRGB(96, 213, 179)

part("Ground", Vector3.new(500, 2, 500), Vector3.new(0, -1, 0), Color3.fromRGB(39, 62, 53), Enum.Material.Grass)
part("Plaza", Vector3.new(96, 1, 96), Vector3.new(0, 0.05, 0), stone, Enum.Material.Cobblestone)
for _, direction in {Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1)} do
    local road = part("Road", Vector3.new(18, 0.25, 160), Vector3.new(direction.X * 126, 0.15, direction.Z * 126), stone, Enum.Material.Cobblestone)
    if direction.X ~= 0 then
        road.Size = Vector3.new(160, 0.25, 18)
    end
end

local function pumpkin(position, scale)
    local body = part("Pumpkin", Vector3.new(5, 4, 5) * scale, position + Vector3.new(0, 2 * scale, 0), orange)
    body.Shape = Enum.PartType.Ball
    part("Stem", Vector3.new(0.8, 1.5, 0.8) * scale, position + Vector3.new(0, 4.7 * scale, 0), Color3.fromRGB(52, 106, 50))
end

local function house(name, center, wallColor)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = world
    part("Walls", Vector3.new(22, 19, 18), center + Vector3.new(0, 9.5, 0), wallColor, Enum.Material.WoodPlanks, folder)
    local roof = part("Roof", Vector3.new(26, 3, 22), center + Vector3.new(0, 20, 0), night, Enum.Material.Slate, folder)
    roof.Orientation = Vector3.new(0, 0, 10)
    part("Door", Vector3.new(5, 9, 0.5), center + Vector3.new(0, 4.5, -9.3), Color3.fromRGB(45, 31, 39), Enum.Material.Wood, folder)
    for _, x in {-6, 6} do
        local window = part("Window", Vector3.new(3, 4, 0.5), center + Vector3.new(x, 12, -9.4), orange, Enum.Material.Neon, folder)
        window.CanCollide = false
    end
end

local function tree(position)
    part("Trunk", Vector3.new(3, 14, 3), position + Vector3.new(0, 7, 0), Color3.fromRGB(63, 45, 60), Enum.Material.Wood)
    local crown = part("MagicLeaves", Vector3.new(14, 14, 14), position + Vector3.new(0, 17, 0), purple, Enum.Material.Grass)
    crown.Shape = Enum.PartType.Ball
end

local function grave(position)
    part("GraveBase", Vector3.new(4, 1, 3), position + Vector3.new(0, 0.5, 0), stone, Enum.Material.Slate)
    part("Headstone", Vector3.new(3, 5, 1), position + Vector3.new(0, 3, 0.5), Color3.fromRGB(125, 125, 141), Enum.Material.Slate)
end

-- Pumpkin fountain / central landmark
part("FountainBase", Vector3.new(20, 2, 20), Vector3.new(0, 1, 0), purple, Enum.Material.Slate)
part("FountainColumn", Vector3.new(6, 8, 6), Vector3.new(0, 6, 0), stone, Enum.Material.Slate)
pumpkin(Vector3.new(0, 10, 0), 1.4)
for _, x in {-37, 37} do
    for _, z in {-37, 37} do
        pumpkin(Vector3.new(x, 0, z), 0.7)
    end
end

-- Barrio Embrujado, west
for i = 1, 6 do
    local x = -90 - (i % 3) * 35
    local z = -55 + math.floor((i - 1) / 3) * 45
    house("HauntedHouse_" .. i, Vector3.new(x, 0, z), Color3.fromRGB(90, 73, 110))
end

-- Bosque Encantado, north
local rng = Random.new(2026)
for i = 1, 32 do
    local x = rng:NextNumber(55, 215)
    local z = rng:NextNumber(60, 215)
    tree(Vector3.new(x, 0, z))
end

-- Cemetery, east
part("CemeteryGround", Vector3.new(105, 0.3, 105), Vector3.new(145, 0.2, -135), Color3.fromRGB(51, 54, 65), Enum.Material.Slate)
for row = 0, 3 do
    for col = 0, 4 do
        grave(Vector3.new(105 + col * 18, 0.4, -175 + row * 24))
    end
end
part("Crypt", Vector3.new(24, 13, 20), Vector3.new(145, 6.5, -208), stone, Enum.Material.Slate)
part("CryptDoor", Vector3.new(7, 9, 0.6), Vector3.new(145, 4.5, -218.3), night, Enum.Material.Metal)

-- Distant sealed mansion, south
house("SealedMansion_Prototype", Vector3.new(0, 0, 188), Color3.fromRGB(66, 49, 85))

-- Lighting and mobile-friendly atmosphere
Lighting.ClockTime = 20
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(65, 46, 85)
Lighting.OutdoorAmbient = Color3.fromRGB(55, 51, 74)
local atmosphere = Lighting:FindFirstChild("HalloweenAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "HalloweenAtmosphere"
atmosphere.Density = 0.24
atmosphere.Color = Color3.fromRGB(159, 127, 185)
atmosphere.Parent = Lighting

local spawn = Instance.new("SpawnLocation")
spawn.Name = "PuebloMalditoSpawn"
spawn.Anchored = true
spawn.Neutral = true
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 0.7, -28)
spawn.Color = teal
spawn.Material = Enum.Material.Neon
spawn.Parent = world

print("Pueblo Maldito prototype generated")
