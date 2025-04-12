
core.remove_detached_inventory("cs_crafting:craftinv")
local crafting_inventory = core.create_detached_inventory("cs_craft:craftinv", {
    allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
    -- Called when a player wants to move items inside the inventory.
    -- Return value: number of items allowed to move.
        return 0
    end,

    allow_put = function(inv, listname, index, stack, player)
    -- Called when a player wants to put something into the inventory.
    -- Return value: number of items allowed to put.
    -- Return value -1: Allow and don't modify item count in inventory.
        return 0
    end,

    allow_take = function(inv, listname, index, stack, player)
    -- Called when a player wants to take something out of the inventory.
    -- Return value: number of items allowed to take.
    -- Return value -1: Allow and don't modify item count in inventory.
        return 0
    end,

    --[[on_move = function(inv, from_list, from_index, to_list, to_index, count, player)

    end,

    on_put = function(inv, listname, index, stack, player)

    end,

    on_take = function(inv, listname, index, stack, player)

    end,]]

    -- Called after the actual action has happened, according to wh
})
core.register_on_mods_loaded(function()
    local c = 0
    --[[for i, v in pairs(cs_crafting.registered_recipes) do
        if v.type=="inventory" then
            c = c + 1
        end
    end]]
    crafting_inventory:set_size("main", 1000)
end)


local form_pc = [[

    formspec_version[8]
    size[20,11]

    scroll_container[.75,.25;5,7.25;scrollbar_craft;vertical;.17;0]
        list[detached:cs_crafting:craftinv;main;0,0;4,30;0]
    scroll_container_end[]
    button[1.75,8;3.75,1;inventory_confirm_craft;craft]

    list[current_player;main;6,4.75;8,1;0]
    list[current_player;main;6,6;10,4;8]


    scrollbar[.25,.25;.35,7.25;vertical;scrollbar_craft;.5]
    scrollbaroptions[]
]]

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname=="" then --inventory name (stupid that luanti hardcodes that)
        if fields.inventory_confirm_craft then

        end
    end
end)

core.register_on_joinplayer(function(player)
    player:set_inventory_formspec(form_pc)
    local inv = player:get_inventory()
    inv:set_size("craft", 0)
    inv:set_size("craftresult", 0)
    inv:set_size("craftpreview", 1)
    inv:set_size("main", 8+20)
end)