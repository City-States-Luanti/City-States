
minetest.register_node("cs_biomes:dirt_grassy",{
    tiles = {"default_grass.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
	groups = {structureless = 6},
})
minetest.register_node("cs_biomes:dirt",{
    tiles = {"default_dirt.png"},
	groups = {structureless = 5},
})

minetest.register_node("cs_biomes:stone",{
    tiles = {"stone.png"},
    groups = {brittle=10}
})
