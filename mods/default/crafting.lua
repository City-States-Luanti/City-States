
--defines a crafting recipe through any means.
cs_crafting = {
    on_craft_actions = {}, --a list of functions to call on_craft
    registered = {},
    registered_craftdefs = {}
}

local mp = core.get_modpath("cs_default")
dofile(mp.."/classes/Itemdef.lua")
dofile(mp.."/classes/Craftitemdef.lua")
dofile(mp.."/classes/Tooldef.lua")

local Itemdef      = cs_crafting.Itemdef
local Tooldef      = cs_crafting.Tooldef
local Craftitemdef = cs_crafting.Craftitemdef
local Fueldef      = cs_crafting.Fueldef

function cs_crafting.register_crafting_action(func)
    local on_craft_actions = cs_crafting.on_craft_actions
    on_craft_actions[#on_craft_actions+1] =  func
end
function cs_crafting.register_fuel(def)
    Fueldef:new_class(def)
end
function cs_crafting.register_tool(def)
    Tooldef:new_class(def)
end
function cs_crafting.register_craftitem(def)
    Craftitemdef:new_class(def)
end

function cs_crafting.craft(player, recipe, count, quality_factor)
    local outstack
    for i, action in ipairs(cs_crafting.on_craft_actions) do
        outstack = action(player, recipe, count, outstack)
    end
    return outstack
end
function cs_crafting.register_on_craft(action)
    assert(type(action)=="function")
    table.insert(cs_crafting.on_craft_actions, action)
end