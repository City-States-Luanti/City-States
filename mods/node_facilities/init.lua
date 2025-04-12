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
                print(pos)
                new_class:load(pos, node, dtime_s)
            end
        })
        minetest.register_globalstep(function(dt)
            for pos, inst in pairs(new_class.instance_by_pos) do
                if inst.is_active then
                    local tick = inst.tick
                    inst.time_since_update = inst.time_since_update + dt
                    tick = tick + 1
                    print(tick, inst.update_interval)
                    if tick > inst.update_interval then
                        tick = 0
                        inst:update(inst.time_since_tick)
                        inst.time_since_update = 0
                    end
                    inst.tick = tick
                end
            end
        end)
        new_class.instance_by_pos = {}
    end

end

Facility.construct = function(self)

    assert(self.pos, "no pos?")
    minetest.chat_send_all("new inst")

    local nodeinfo = core.get_node(self.pos)
    self.tick = math.ceil(math.random()*10) --randomly offset the tick for better load distribution
    self.time_since_update = 0
    self.current_node = nodeinfo
    self.param1 = nodeinfo.param1
    self.param2 = nodeinfo.param2
    self.instance_by_pos[self.string_pos(self.pos)] = self


    local meta = core.get_meta(self.pos)
    meta:set_string("formspec", self:get_rightclick_formspec())

    self.inv = core.get_inventory({pos=self.pos, type="node"})
    for i, v in pairs(self.inventory_lists) do
        self.inv:set_size(i, v)
    end

end

function Facility.string_pos(pos)
    return pos.x..":"..pos.y..":"..pos.z
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
        self:new({
            pos = pos,
            is_active = core.get_node(pos).name==self.node_active_state
        })
    else
        --do something?
        minetest.chat_send_all("existing instance found")
    end
end
function Facility:get_rightclick_formspec()
    local form = [[

    size[8,8.5]
    list[context;tools;.5,0.5;1,3]

    ]]
    return form
end
function Facility:update(dt)
    minetest.chat_send_all("updated")
    --check if the states match
    if self.is_active then
        --actually check if it should be active here... but since thats not ready...
        self.is_active = false
    end
    if self.current_node~=((self.is_active and self.node_active_state) or self.node_inactive_state) then
        core.swap_node(self.pos,
        {
            name = (self.is_active and self.node_active_state) or self.node_inactive_state,
            param1 = self.param1,
            param2 = self.param2
        })
    end
end
Facility = leef.class.new(Facility)
