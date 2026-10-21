local AllyConfig = {}
AllyConfig.MaxLevel = 1000
AllyConfig.EvolutionLevels = {1, 50, 100, 250, 500, 750, 1000}
AllyConfig.Allies = {
 Luna = {Role="Healer", DisplayName="Luna", Description="Bruja sanadora"},
 Bones = {Role="Guardian", DisplayName="Bones", Description="Caballero esqueleto"},
 Boo = {Role="Explorer", DisplayName="Boo", Description="Fantasma explorador"},
}
function AllyConfig.GetStats(level: number)
 assert(level >= 1 and level <= AllyConfig.MaxLevel, "Invalid level")
 return {Health=100+12*(level-1), Power=10+2*(level-1), Defense=5+(level-1)}
end
function AllyConfig.GetEvolutionStage(level: number): number
 local stage = 1
 for i, minimum in ipairs(AllyConfig.EvolutionLevels) do
  if level >= minimum then stage = i end
 end
 return stage
end
return AllyConfig
