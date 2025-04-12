local modprefix = "cs_materials:"
local density_multiplier = 2
local materials_list = {
    iron = {
        scarcity = 20^3,
        amount = 20,
        size = 5,
        mine_yield = 3
    },
    aluminum = {
        scarcity = 60^3,
        amount = 20,
        size = 5,
        mine_yield = 4
    },
    lead = {
        scarcity = 35^3,
        amount = 15,
        size = 3,
        mine_yield = 4
    },
    gold = {
        scarcity = 35^3,
        amount = 4,
        size=3,
        mine_yield = 2
    },
    zinc = {
        scarcity = 35^3,
        amount = 4,
        size=3,
        mine_yield = 3
    },
    uranium = {
        scarcity = 35^3,
        amount = 4,
        size=3,
        mine_yield = 4
    },

    diamond = {
        scarcity = 35^3,
        amount = 4,
        size=3,
        noningot = true,
        mine_yield = 5
    },
    coal = {
        scarcity = 18^3,
        amount = 5,
        size=3,
        noningot = true,
        mine_yield = 6
    },

    steel = {
        nonore=true,
    },
    brass = {
        nonore=true,
    },
    hc_steel = {
        nonore=true,
    },
    pig_iron = {
        nonore=true,
        noningot = true
    },
    carbon_coke = {
        nonore=true,
        noningot = true
    },
    slag = {
        nonore=true,
        noningot = true
    },
}

for name, material in pairs(materials_list) do
    minetest.register_node(modprefix..name.."_ore_node", {
        tiles = {name.."_ore_node"}
    })
    if not material.nonore then
        minetest.register_ore({
            ore = modprefix..name.."_ore_node",
            ore_type = material.type or "blob",
            clust_size = material.size,
            clust_num_ores = material.amount,
            clust_scarcity = material.scarcity/density_multiplier,
            wherein = "cs_biomes:stone",
            y_min = -31000,
            y_max = 31000
        })
    end
    minetest.register_craftitem(modprefix..name..((material.noningot and "") or "_ingot"), {
        inventory_image = name,
        wield_image = name,
        range = 0
    })
end