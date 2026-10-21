-- Trade rules and item validation shared by future UI and server.
local TradeConfig = {}
TradeConfig.Enabled = false -- Enable only after persistent inventories and atomic saving exist.
TradeConfig.MaxDistance = 35
TradeConfig.MaxItemsPerSide = 6
TradeConfig.ConfirmationSeconds = 5
TradeConfig.RequestTimeoutSeconds = 30
TradeConfig.AllowedItemTypes = {Pet = true, Ally = true, Cosmetic = true, Material = true}
TradeConfig.ForbiddenItemTypes = {Level = true, XP = true, Robux = true, RealMoney = true}
function TradeConfig.IsTradable(item)
    if typeof(item) ~= "table" then return false end
    if typeof(item.Id) ~= "string" or item.Id == "" then return false end
    if not TradeConfig.AllowedItemTypes[item.Type] then return false end
    if item.Locked == true or item.Equipped == true or item.Tradable == false then return false end
    return true
end
return TradeConfig
