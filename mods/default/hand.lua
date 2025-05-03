
print(dump(minetest.registered_items[""]))
cs_crafting.Tooldef:new_class(
    {
    itemname = "cs_default:hand",
    description = "",
    wearseconds = -1,
    wield_image = "blank.png",
    tool_capabilities = {
        groups = {
            barky         = {maxlevel=4,  maxtime=6,   factor=10, wear=1},
            brittle       = {maxlevel=20, maxtime=1.5, factor=12, wear=1.5},
            structureless = {maxlevel=8,  maxtime=8,   factor=6,  wear=2},
        }
    },
    groups = {not_in_creative_inventory=1}
})
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("hand", 1)
    local stack = ItemStack("cs_default:hand")
    inv:set_stack("hand", 1, stack)
    --local stack = inv:get_stack("hand", 1)
end)