--adds nodes that facilitate production of metals

minetest.register_node("cs_materials:bloomery_furnace", {
    --drawtype = "mesh",
    --collisions_box = {},
    tiles = {"default_furnace_front.png"},
})
minetest.register_node("cs_materials:bloomery_furnace_active", {
    --drawtype = "mesh",
    --collisions_box = {},
    tiles = {
        {
            image="default_furnace_front_active.png",
            animation= {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 1.5
            },
        }
    },
})

local Bloomery_furnace = Facility:new_class({
    node_inactive_state = "cs_materials:bloomery_furnace",
    node_active_state = "cs_materials:bloomery_furnace_active",
    inventory_lists = {
        tools = 3,
        fuel = 1,
        out = 2,
        inp = 2
    },
    fuelitems = {
        --"wood"
        ["cs_materials:coal"]     = {
            name = "cs_materials:coal",
            quality         = 2,
            burnrate_factor = .6, --defines the logarithm subscript of the curve
            burnrate_offset = 680,
            stable_temp     = 2700
        },
        ["cs_materials:coke"]     = {
            name = "cs_materials:coke",
            quality         = 3,
            burnrate_factor = 1,
            burnrate_offset = 680,
            stable_temp     = 5000
        },
        ["cs_materials:charcoal"] = {
            name = "cs_materials:charcoal",
            quality         = 3,
            burnrate_factor = .6,
            burnrate_offset = 680,
            stable_temp     = 3000
        },
        ["cs_materials:chopped_wood"] = {
            name = "cs_materials:chopped_wood",
            quality         = -5,
            burnrate_factor = 1.5,
            burnrate_offset = -1,
            stable_temp     = 700
        },
        --["wood"]          = 3
    },
    heat_loss_rate = 30,
    construct = function(self) --see LEEF docs for context.
        self.progress = 0
        self.operator = self.meta:get_string("operator")
        self.heat = self.meta:get_int("furnace_heat")
    end
})

function Bloomery_furnace:check_inventory()
    assert(self.instance)
    print(self.pos)
    local inv = core.get_inventory({type="node", pos=self.pos})
    local item = inv:get_list("fuel")[1]
    local fuelitem = self.fuelitems[item:get_name()]
    minetest.chat_send_all(item:get_name())
    self.fuelitem = fuelitem
    if fuelitem then
        self.is_active = true
        self:update_block()
    elseif self.heat < 800 then
        self.is_active = false
    end
end

function Bloomery_furnace:set_operator(playername)
    self.operator = playername
    self.meta:set_string("operator", playername)
    self.meta:set_string("infotext", "Bloomery furnace +0°C")
end

local function do_inv_action(self, player)
    self:check_inventory(self)
    self:set_operator(player:get_player_name())
end
function Bloomery_furnace:on_inv_move(pos, from_list, from_index, to_list, to_index, count, player)
    do_inv_action(self, player)
end
function Bloomery_furnace:on_inv_put(pos, listname, index, stack, player)
    do_inv_action(self, player)
end
function Bloomery_furnace:on_inv_take(pos, listname, index, stack, player)
    do_inv_action(self, player)
end

local clamp = function(x,a,b)
    if a > b then
        local olda = a
        a=b
        b=olda
    end
    return ((x < a) and a) or ((x > b) and b) or x
end
function Bloomery_furnace:do_heat_sim(dt)
    local fuelitem = self.fuelitem
    local next_heat = self.heat - (dt * self.heat_loss_rate * (self.heat/1000)^2)
    print(next_heat)
    if fuelitem and ((self.heat>=fuelitem.burnrate_offset)) then
        local l = self.heat_loss_rate
        local b = fuelitem.burnrate_factor
        local o = fuelitem.burnrate_offset
        local s = fuelitem.stable_temp
        local x = self.heat

        local heatgain = ( math.log(x-o+1)/math.log(s-o) )*l
        --remember this is just an approximation. So it's technically not a real
        --"simulation" in the sense that the curve has to be designed so it's easily defined.
        local heatloss = ( ((x-o)^2)/((s-o)^2) )*l
        local deltaheat = (heatgain-heatloss)*b*dt*(1+(math.random()/100))
        --deltaheat = clamp(deltaheat, 0, 5000)
        self.heat = self.heat + deltaheat
    elseif next_heat >= 0 then
        self.heat = next_heat
    else
        self.heat = 0
    end
    self.meta:set_string("infotext", "Bloomery furnace +"..math.floor(self.heat).."°C")
end

function Bloomery_furnace:update(dt)
    self.parent_class.update(self, dt)
    self:do_heat_sim(dt)
end

--[[
    image[2.75,1.5;1,1;default_furnace_fire_bg.png]
    image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]
]]
function Bloomery_furnace:get_rightclick_formspec()
    local form = self.parent_class:get_rightclick_formspec()
    form = form .. [[
    list[context;inp;3.25,0.8 ;1,1;]
    list[context;fuel;3.25,2.7;1,1;]
    list[context;out;4.5,1.8; 1,1;]

    list[current_player;main;0,4.25;8,1;]
    list[current_player;main;0,5.5;8,3;8]

    listring[context;out]
    listring[context;fuel]
    listring[current_player;main]
    ]]
    return form
end