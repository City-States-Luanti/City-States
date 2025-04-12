core.register_alias("mapgen_stone", "cs_biomes:stone")
minetest.register_biome({
    name = "planes",

    depth_riverbed = 0,
    node_top = "cs_biomes:dirt_grassy",
    depth_top = 1,

    node_filler = "cs_biomes:dirt",
    depth_filler = 5,


    y_max = 20,
    y_min = -10,
    vertical_blend = 2,

    heat_point = 1,
    humidity_point = 10,
})