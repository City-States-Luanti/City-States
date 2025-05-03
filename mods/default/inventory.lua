
core.remove_detached_inventory("cs_default:craftinv")
cs_default.crafting_inventory = core.create_detached_inventory("cs_default:craftinv", {
    allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        return 0
    end,

    allow_put = function(inv, listname, index, stack, player)
        return 0
    end,

    allow_take = function(inv, listname, index, stack, player)
        return 0
    end,
    --[[
    on_move = function(inv, from_list, from_index, to_list, to_index, count, player) end,
    on_put = function(inv, listname, index, stack, player) end,
    on_take = function(inv, listname, index, stack, player) end,
    ]]
})
core.register_on_mods_loaded(function()
    local c = 0
    --[[for i, v in pairs(cs_cs_crafting.registered_recipes) do
        if v.type=="inventory" then
            c = c + 1
        end
    end]]
    cs_default.crafting_inventory:set_size("main", 1000)
end)


local craft_listnames = {"all", "nodes", "tools", "craftitems", "forbidden"}
local function get_form_pc(player, craft_tab_index)


    local craft_tab = craft_listnames[craft_tab_index]
    assert(type(craft_tab)=="string", "bad tab name")

     local haspriv, _ = core.check_player_privs(player, "devmode")

    --craftmenu
    local craft_invname, inv = "cs_default:craftinv", cs_default.crafting_inventory
    if haspriv then
        craft_invname = "cs_default:devinv"
        inv = cs_default.devmode_inventory
    end

    local craft_y_offset = 1
    local outval =
    "formspec_version[8] size[20,11]"..
    "scroll_container[.75,"..(craft_y_offset+.25)..";5,7.25;scrollbar_craft;vertical;.17;0]"..
        "list[detached:"..craft_invname..";"..craft_tab..";0,0;4,"..math.ceil(inv:get_size(craft_tab)/4)..";0]"..
    "scroll_container_end[]"..
    "button[1.75,"..(craft_y_offset+8)..";3.75,1;inventory_confirm_craft;craft]"..
    "scrollbar[.25,"..(craft_y_offset+.25)..";.35,7.25;vertical;scrollbar_craft;.5]"..
    "scrollbaroptions[]"

    --craftmenu tabs
    local tabslist = craft_listnames[1]
    for i=2, (haspriv and 5) or 4 do
        tabslist=tabslist..","..craft_listnames[i]
    end
    outval=outval.."tabheader[-.01,0;7.25,.5;craftmenutabs;"..tabslist..";"..craft_tab_index..";true;false]"

    --player inventory
    outval = outval..
    "list[current_player;main;6,4.75;8,1;0]"..
    "list[current_player;main;6,6;10,4;8]"

    return outval
end


function cs_default.reset_player_inventory(player)
    player:set_inventory_formspec(get_form_pc(player, 1))
    local inv = player:get_inventory()
    inv:set_size("craft", 0)
    inv:set_size("craftresult", 0)
    inv:set_size("craftpreview", 1)
    inv:set_size("main", 8+20)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname=="" then --inventory name (stupid that luanti hardcodes that)

    end
    if fields.craftmenutabs then
        print(fields.craftmenutabs, craft_listnames[tonumber(fields.craftmenutabs)])
        core.show_formspec(player:get_player_name(), "", get_form_pc(player, tonumber(fields.craftmenutabs)))
    end
end)

core.register_on_joinplayer(function(player)
    cs_default.reset_player_inventory(player)
end)