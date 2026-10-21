-- Halloween Evolution Simulator: progression module
local LevelService = {}
LevelService.MAX_LEVEL = 1000

function LevelService.XPForNextLevel(level: number): number
    assert(level >= 1 and level <= LevelService.MAX_LEVEL, "Invalid level")
    if level == LevelService.MAX_LEVEL then
        return 0
    end
    local n = level - 1
    return math.floor(100 + 30 * n + 0.5 * n * n + 0.5)
end

function LevelService.AddXP(level: number, xp: number, amount: number): (number, number, number)
    assert(amount >= 0, "XP reward must be nonnegative")
    local levelsGained = 0
    xp += amount
    while level < LevelService.MAX_LEVEL do
        local required = LevelService.XPForNextLevel(level)
        if xp < required then
            break
        end
        xp -= required
        level += 1
        levelsGained += 1
    end
    if level == LevelService.MAX_LEVEL then
        xp = 0
    end
    return level, xp, levelsGained
end

return LevelService
