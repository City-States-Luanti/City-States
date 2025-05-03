
--defines a method of crafting something

--cs_crafting.recipes = {}
--cs_crafting.recipes_lookup = {}

cs_crafting.Craftdef = leef.class.new({
    out                    = {"modname:item",  --[[...]]},
    type                   = "inventory",      --this is essentiall the "name" if the recipe type. It cannot match the name of existing craftdefs. If it is
    unfinished_texture     = "unifinished.png",--for partially crafted items
    required_tools         = nil,              --list
    input_quality_matters  = false,            --whether the quality of inputs will actually effect the quality of the item
    total_input_weight     = nil,              --generated in construct automatically
    max_quality            = 1,                --percentage of max quality of the item(s)
    quality_variation      = 0,                --random quality offset
    skill_factor           = .5,               --percentage of max quality which is determined by the player's percentage skill. max_quality - skill_factor*(skill/skill_max)*max_quality
    skill                  = {},               --skills which influences the quality and their weights
    inputs                 = {},              --list of items and their weights. \
    construct_new_class    = function(self)

    end,
    construct = error
})
local Craftdef = cs_crafting.Craftdef
function Craftdef:craft(invtable)
    local outitems = {}

    return outitems
end