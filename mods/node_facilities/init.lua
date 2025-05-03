local server_step = tonumber(core.settings:get("dedicated_server_step"))
local default_rate = math.ceil(1/server_step)
if server_step <= 0 then
    default_rate = 60
end
print(default_rate)
Facility = {
    update_interval = default_rate, --roughly once a second by default
    is_active = false,
    instance_by_pos = {},
    manual_operation = false,

    --instances
    initial_dtime_s = nil, --initial instance construction param
    node_inactive_state = nil, --"modname:blank"
    node_active_state = nil, --"modname:blank"
    current_node = nil,
    param2 = nil,
    param1 = nil,
    tick = nil,
    inventory_lists = {
        tools = 3
    }
}
Facility.construct_new_class = function(new_class)

    if (new_class~=Facility) then
        minetest.register_lbm({
            label = "Create lua class instance of facility block",
            nodenames = {new_class.node_inactive_state, new_class.node_active_state},
            name = new_class.node_inactive_state.."_create_instance",
            run_at_every_load = true,
            action = function(pos, node, dtime_s)
                local self = new_class:load(pos, node, dtime_s)
                self:on_node_construct()
            end
        })
        minetest.register_globalstep(function(dt)
            for pos, inst in pairs(new_class.instance_by_pos) do
                if inst.is_active then
                    local tick = inst.tick
                    inst.time_since_update = inst.time_since_update + dt
                    tick = tick + 1
                    if tick > inst.update_interval then
                        tick = 0
                        inst:update(inst.time_since_update)
                        inst.time_since_update = 0
                    end
                    inst.tick = tick
                end
            end
        end)

        --has to be by indexname so that it's a lookup. Because at the time of this function's creation, the callback would be the Facility class's function.
        local function mdata_inv_hook(hookname)
            return function(...)
                local pos = ...
                local self = new_class:get_instance(pos)
                return new_class[hookname](self, ...)
            end
        end
        local function construct_hook(oldfunc)
            return function(...)
                if oldfunc then oldfunc(...) end
                local pos = ...
                local self = new_class:load(pos)
                self:on_node_construct(...)
            end
        end
        local function on_receive_fields_hook(oldfunc)
            return function(...)
                local rtn = (oldfunc and oldfunc(...)) or nil
                local pos = ...
                if rtn then return rtn end
                return new_class:get_instance(pos):recieve_fields(...)
            end
        end

        --not going to bother with this for now.
        local move = mdata_inv_hook("on_inv_move")
        local put  = mdata_inv_hook("on_inv_put")
        local take = mdata_inv_hook("on_inv_take")

        local olddef1 = core.registered_nodes[new_class.node_inactive_state]
        core.override_item(new_class.node_inactive_state, {
            on_metadata_inventory_move = move,
            on_metadata_inventory_put  = put,
            on_metadata_inventory_take = take,
            on_receive_fields          = on_receive_fields_hook(olddef1.on_receive_fields),
            on_construct               = construct_hook        (olddef1.on_construct)
        })

        local olddef2 = core.registered_nodes[new_class.node_active_state]
        if new_class.node_active_state then
            core.override_item(new_class.node_active_state, {
                on_metadata_inventory_move = move,
                on_metadata_inventory_put  = put,
                on_metadata_inventory_take = take,
                on_receive_fields          = on_receive_fields_hook(olddef2.on_receive_fields),
                on_construct               = construct_hook(olddef2.on_construct    )
            })
        end
        new_class.instance_by_pos = {}
    end
end

Facility.construct = function(self)

    assert(self.pos, "no pos?")
    minetest.chat_send_all("new inst")
    local meta = core.get_meta(self.pos)

    local nodeinfo = core.get_node(self.pos)
    self.tick = math.ceil(math.random()*10) --randomly offset the tick for better load distribution
    self.time_since_update = 0
    self.current_node = nodeinfo
    self.param1 = nodeinfo.param1
    self.param2 = nodeinfo.param2
    self.instance_by_pos[self.string_pos(self.pos)] = self
    self.meta = meta

    meta:set_string("formspec", self:get_rightclick_formspec())

    self.inv = core.get_inventory({pos=self.pos, type="node"})
    for i, v in pairs(self.inventory_lists) do
        self.inv:set_size(i, v)
    end

end

--hooks for mt node callbacks
function Facility:on_node_construct(pos) --initial node construction.
    assert(self.instance)
end
function Facility:on_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
    assert(self.instance)
end
function Facility:on_inv_put(pos, listname, index, stack, player)
    assert(self.instance)
end
function Facility:on_inv_take(pos, listname, index, stack, player)
    assert(self.instance)
end
function Facility:recieve_fields(pos, formname, fields, sender)
    assert(self.instance)
end


function Facility.string_pos(pos)
    return pos.x..":"..pos.y..":"..pos.z
end
function Facility:get_instance(pos)
    assert(not self.instance)
    return self.instance_by_pos[self.string_pos(pos)]
end
--called from the base class, not an instance method
function Facility:destroy_instance()
    self.base_class.instance_by_pos[self.string_pos(self.pos)]=nil
    minetest.chat_send_all("instance destroyed")
end
function Facility:load(pos, node, dtime_s)
    assert(not self.instance, "major class fault `"..self.node_inactive_state.."`")
    local existing_inst = self.instance_by_pos[pos.x..":"..pos.y..":"..pos.z]
    if not existing_inst then
        return self:new({
            pos = pos,
            is_active = core.get_node(pos).name==self.node_active_state
        })
    else
        return existing_inst
    end
end
function Facility:get_rightclick_formspec()
    local form = [[

    size[8,8.5]
    list[context;tools;.5,0.5;1,3]

    ]]
    return form
end
function Facility:update_block()
    assert(self.instance)
    local oldname = self.current_node
    self.current_node = (self.is_active and self.node_active_state) or self.node_inactive_state
    if self.current_node ~= oldname then
        core.swap_node(self.pos, {
            name = self.current_node,
            param1 = self.param1,
            param2 = self.param2
        })
    end
end
function Facility:update(dt)
    --update the block's state
    self:update_block()
end
Facility = leef.class.new(Facility)
