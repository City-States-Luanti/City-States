
crafting.register_tool({
    itemname = "cs_materials:steel_axe",
    description = "steel axe",
    wield_image = "default_tool_stoneaxe.png",
    inventory_image = "default_tool_stoneaxe.png",
    wearseconds = 800, --seconds of wear this tool can take
    max_capabilities = { --max capabilities before stats.
        groups = {
            barky         = {maxlevel=20, maxtime=2,   factor=16, wear=1},
            brittle       = {maxlevel=12, maxtime=7,   factor=8,  wear=1.5},
            structureless = {maxlevel=8,  maxtime=5,   factor=6,  wear=2},
        }
    }
})

crafting.register_tool({
    itemname = "cs_materials:steel_pickaxe",
    description = "steel pickaxe",
    wield_image = "default_tool_stonepick.png",
    inventory_image = "default_tool_stonepick.png",
    max_capabilities = {
        groups = {
            barky         = {maxlevel=8,  maxtime=6,   factor=10, wear=1},
            brittle       = {maxlevel=20, maxtime=1.5, factor=12, wear=1.5},
            structureless = {maxlevel=8,  maxtime=8,   factor=6,  wear=2},
        }
    }
})

--[[
    structureless
    barky
    metallic
    strong
    leaves
    fabic
    bricky
]]