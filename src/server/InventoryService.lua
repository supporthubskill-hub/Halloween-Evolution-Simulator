-- Server-only inventory utilities. No client may mint or transfer items.
local HttpService = game:GetService("HttpService")
local InventoryService = {}
InventoryService.MAX_ITEMS = 200
InventoryService.TYPES = {Pet=true, Ally=true, Cosmetic=true, Material=true}
function InventoryService.NewItem(itemType, templateId, level)
    assert(InventoryService.TYPES[itemType], "Unknown item type")
    assert(typeof(templateId) == "string" and #templateId > 0 and #templateId <= 64, "Invalid template")
    return {
        Id = HttpService:GenerateGUID(false),
        Type = itemType,
        TemplateId = templateId,
        Level = math.clamp(math.floor(level or 1), 1, 1000),
        XP = 0,
        Locked = false,
        Equipped = false,
        Tradable = true,
    }
end
function InventoryService.Sanitize(items)
    local clean, seen = {}, {}
    if typeof(items) ~= "table" then return clean end
    for _, item in ipairs(items) do
        if #clean >= InventoryService.MAX_ITEMS then break end
        if typeof(item) == "table" and typeof(item.Id) == "string"
            and #item.Id > 0 and #item.Id <= 100 and not seen[item.Id]
            and InventoryService.TYPES[item.Type]
            and typeof(item.TemplateId) == "string" and #item.TemplateId > 0 and #item.TemplateId <= 64 then
            seen[item.Id] = true
            table.insert(clean, {
                Id=item.Id, Type=item.Type, TemplateId=item.TemplateId,
                Level=math.clamp(math.floor(tonumber(item.Level) or 1), 1, 1000),
                XP=math.clamp(math.floor(tonumber(item.XP) or 0), 0, 2000000000),
                Locked=item.Locked == true,
                Equipped=item.Equipped == true,
                Tradable=item.Tradable ~= false,
            })
        end
    end
    return clean
end
function InventoryService.Find(items, itemId)
    for index, item in ipairs(items) do
        if item.Id == itemId then return item, index end
    end
    return nil
end
return InventoryService
