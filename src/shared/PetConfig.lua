-- Pet progression and fair, non-P2W evolution rules.
local PetConfig = {}
PetConfig.MaxLevel = 1000
PetConfig.EvolutionLevels = {1, 25, 75, 150, 300, 500, 750, 1000}
PetConfig.Pets = {
    MoonFox = {DisplayName="Zorro Lunar", Rarity="Legendary", Ability="Luz Lunar"},
    PumpkinBat = {DisplayName="Murciélago Calabaza", Rarity="Uncommon", Ability="Eco Calabaza"},
}
function PetConfig.GetStage(level)
    level = math.clamp(math.floor(level), 1, PetConfig.MaxLevel)
    local stage = 1
    for index, required in ipairs(PetConfig.EvolutionLevels) do
        if level >= required then stage = index end
    end
    return stage
end
function PetConfig.GetStats(level)
    level = math.clamp(math.floor(level), 1, PetConfig.MaxLevel)
    return {Power = 4 + 2 * (level - 1), Defense = 2 + (level - 1)}
end
function PetConfig.RequiredXP(level)
    if level >= PetConfig.MaxLevel then return 0 end
    local n = math.max(0, level - 1)
    return math.floor(70 + 22*n + 0.35*n*n + 0.5)
end
function PetConfig.AddXP(level, xp, amount)
    level = math.clamp(math.floor(level), 1, PetConfig.MaxLevel)
    xp = math.max(0, math.floor(xp))
    amount = math.clamp(math.floor(amount), 0, 100000)
    xp += amount
    while level < PetConfig.MaxLevel and xp >= PetConfig.RequiredXP(level) do
        xp -= PetConfig.RequiredXP(level)
        level += 1
    end
    if level == PetConfig.MaxLevel then xp = 0 end
    return level, xp, PetConfig.GetStage(level)
end
return PetConfig
