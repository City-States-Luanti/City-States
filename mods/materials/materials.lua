local modprefix = "cs_materials:"
local density_multiplier = 2
local materials_list = {
    iron = {
        oredef = {
            scarcity = 20^3,
            amount = 20,
            size = 5,
            mine_yield = 3
        },
        groups = {ore=1, ingot=1}
    },
    aluminum = {
        oredef = {
            scarcity = 60^3,
            amount = 20,
            size = 5,
            mine_yield = 4
        },
        groups = {ore=1, ingot=1}
    },
    lead = {
        oredef = {
            scarcity = 35^3,
            amount = 15,
            size = 3,
            mine_yield = 4
        },
        groups = {ore=1, ingot=1}
    },
    gold = {
        oredef = {
            scarcity = 35^3,
            amount = 4,
            size=3,
            mine_yield = 2
        },
        groups = {ore=1, ingot=1}
    },
    zinc = {
        oredef = {
            scarcity = 35^3,
            amount = 4,
            size=3,
            mine_yield = 3
        },
        groups = {ore=1, ingot=1}
    },
    uranium = {
        oredef = {
            scarcity = 35^3,
            amount = 4,
            size=3,
            mine_yield = 4
        },
        groups = {ore=1}
    },

    diamond = {
        description = "uncut diamond",
        groups = {ore=1},
        oredef = {
            scarcity = 35^3,
            amount = 4,
            size=3,
            mine_yield = 5
        }
    },
    coal = {
        description = "coal",
        groups = {fuel=1, carbon_monoxide=2, ore=1},
        oredef = {
            mine_yield = 6,
            amount = 5,
            size = 3,
            scarcity = 18^3,
        },
    },

    steel = {
        description = "mild steel",
        density = 8,
        groups = {ingot=1}
    },
    brass = {
        description = "brass",
        groups = {ingot=1}
    },
    hc_steel = {
        description = "high carbon steel",
        groups = {ingot=1}
    },
    pig_iron = {
        description = "unrefined pig iron"
    },
    iron_bloom = {
        description = "unrefined iron bloom",
        texture = "iron_bloom.png"
    },
    charcoal = {
        description = "charcoal",
        groups = {fuel=1, carbon_monoxide=3},
    },
    carbon_coke = {
        description = "carbon coke",
        groups = {fuel=1, carbon_monoxide=3},
    },
    chopped_wood = {
        description = "chopped_wood",
        groups = {fuel=1},
    },
    slag = {
        description = "slag biproduct"
    },
}

local function register_material(name, material)
    local groups = material.groups or {}
    if groups.ore then
        minetest.register_node(modprefix..name.."_ore_node", {
            tiles = {name.."_ore_node"},
            --groups = {not_in_creative_inventory=1}
        })
        minetest.register_ore({
            ore = modprefix..name.."_ore_node",
            ore_type = material.oredef.type or "blob",
            clust_size = material.oredef.size,
            clust_num_ores = material.oredef.amount,
            clust_scarcity = material.oredef.scarcity/density_multiplier,
            wherein = "cs_biomes:stone",
            y_min = -31000,
            y_max = 31000
        })
    end
    local ingot = groups.ingot
    cs_crafting.register_craftitem({
        itemname        = modprefix..name..((ingot and "_ingot") or ""),
        description     = material.description or (name.." ingot"),
        inventory_image = material.texture,
        wield_image     = material.texture,
        density         = 8
    })
end
for name, material in pairs(materials_list) do
    register_material(name, material)
end