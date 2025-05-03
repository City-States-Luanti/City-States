

--[[
====================== DEV INVENTORY ========================
]]
local function auth(player)
    local haspriv, _ = core.check_player_privs(player, "devmode")
    if not haspriv then
        minetest.chat_send_all("player `"..player:get_player_name().."` attempted to access the devmode (creative) inventory without authorization and is likely cheating. Please notify administrators")
        return 0
    else
        return -1
    end
end
cs_default.devmode_inventory = core.create_detached_inventory("cs_default:devinv", {
    allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        auth(player)
        return 0
    end,
    allow_put = function(inv, listname, index, stack, player)
        auth(player)
        return 0
    end,
    allow_take = function(inv, listname, index, stack, player)
        return auth(player)
    end,
})

core.register_on_mods_loaded(function ()
    local invsize = 0
    local creativelist = {}
    local node_location = 1
    local tool_location = 1
    local citm_location = 1
    local frbd_location = 1

    for i, nodedef in pairs(minetest.registered_items) do
        --list built in order of node, tool, craftitem
        if not nodedef.groups.not_in_creative_inventory then

            if nodedef.type == "node" or (nodedef.type=="craft" and nodedef.groups.nodeitem) then
                tool_location = tool_location + 1
                citm_location = citm_location + 1
                frbd_location = frbd_location + 1
                table.insert(creativelist, node_location, i)

            elseif nodedef.type == "tool" then
                citm_location = citm_location + 1
                frbd_location = frbd_location + 1
                table.insert(creativelist, tool_location, i)

            elseif nodedef.type == "craft" then
                frbd_location = frbd_location + 1
                table.insert(creativelist, citm_location, i)

            end

            invsize = invsize + 1
        else
            --still make not_in_creative items accessible through a different tab.
            table.insert(creativelist, frbd_location, i)
        end
    end

    local inv = cs_default.devmode_inventory
    inv:set_size("all",       invsize                    )
    inv:set_size("nodes",     tool_location-1            )
    inv:set_size("tools",     citm_location-tool_location)
    inv:set_size("craftitems", frbd_location-citm_location)
    inv:set_size("forbidden", (#creativelist+1)-frbd_location)
    --print(dump(creativelist), #creativelist)
    assert((inv:get_size("nodes")+inv:get_size("tools")+inv:get_size("craftitems")+inv:get_size("forbidden"))  ==  #creativelist)
    --print(inv:get_size("nodes"), inv:get_size("tools"), inv:get_size("craftitem"), inv:get_size("forbidden"))
    --inv:set_size("forbidden", invsize) --(not in creative inventory)
    --[[for i, v in pairs({all=1, nodes=node_location, tools=tool_location, craftitem=citm_location, forbidden=frbd_location}) do
        for i = 1,
        inv:set_list(lists)
    end]]

    local function trim(val)
        for i = 1, val do
            table.remove(creativelist, 1)
        end
        return creativelist
    end

    inv:set_list("all"      , creativelist)
    inv:set_list("nodes"    , creativelist)
    inv:set_list("tools"    , trim(tool_location-1))
    inv:set_list("craftitems", trim(citm_location-tool_location))
    inv:set_list("forbidden", trim(frbd_location-citm_location))
end)

--[[
============================= DEV HAND =============================
]]
local function set_player_hand(player, haspriv)
    local inv = player:get_inventory()
    local stack = inv:get_stack("hand", 1)
    local caps
    if haspriv then
        local def = Tooldef:get_break_times(20,.175,2000)
        caps =  {
            groupcaps = {
                barky         = {times=def},
                brittle       = {times=def},
                structureless = {times=def},
            },
            full_punch_interval = 1
        }
    end
    cs_default.reset_player_inventory(player)
    stack:get_meta():set_tool_capabilities(caps)
    inv:set_stack("hand", 1, stack)
end

core.register_chatcommand("devmode", {
    params = "",
    description = "gives you devmode/creative privileges",
    privs = {privs=true},
    func = function(name, param)
        local haspriv, _ = core.check_player_privs(name, "devmode")
        core.change_player_privs(name, {devmode=not haspriv})

        local player = core.get_player_by_name(name)
        set_player_hand(player, not haspriv)
        core.chat_send_player(name, "dev set to "..tostring(not haspriv))
    end

})
minetest.register_on_joinplayer(function(player)
    local haspriv, _ = core.check_player_privs(player, "devmode")
    if haspriv then
        core.chat_send_player(player:get_player_name(), "dev set to true")
    end
    core.chat_send_player(player:get_player_name(), tostring(haspriv))
    set_player_hand(player, haspriv)
end)


