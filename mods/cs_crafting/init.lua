--initialize namespace
crafting = {
    on_craft_actions = {} --a list of functions to call on_craft
}
local mp = core.get_modpath("cs_crafting")
dofile(mp.."/inventory.lua")
dofile(mp.."/items.lua")
dofile(mp.."/crafting.lua")
dofile(mp.."/devmode.lua")

Craftdef = crafting.Craftdef
Itemdef  = crafting.Itemdef
Tooldef  = crafting.Tooldef
Fueldef  = crafting.Fueldef


function crafting.register_tool(def)
    Tooldef:new_class(def)
end
function crafting.register_craftrecipe(def)
    Craftdef:new_class(def)
end
function crafting.craft(player, recipe, count)
    local outstack
    for i, action in ipairs(crafting.on_craft_actions) do
        outstack = action(player, recipe, count, outstack)
    end
    return outstack
end
function crafting.register_on_craft(action)
    assert(type(action)=="function")
    table.insert(crafting.on_craft_actions, action)
end








