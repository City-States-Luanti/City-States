--adds nodes that facilitate production of metals

local Bloomery_furnace = Facility:new_class({
    node_inactive_state = "cs_materials:bloomery_furnace",
    node_active_state = "cs_materials:bloomery_furnace_active",
    inventory_lists = {
        tools = 3,
        fuel = 1,
        out1=  2,
        out2 = 2,
        inp = 2
    },
    construct = function(self) --see LEEF docs for context.
        --[[if self.instance then
            local inv = self.inv
            inv:set_size("in", 1)
            inv:set_size("fuel", 1)
            inv:set_size("out", 1)
        end]]
    end
})
Bloomery_furnace.recipes = {}
Bloomery_furnace.recipes_lookup = {}
local recipes        = Bloomery_furnace.recipes
local recipes_lookup = Bloomery_furnace.recipes_lookup -- a list of recipes indexed by
cs_materials.Bloomery_furnace = Bloomery_furnace

function Bloomery_furnace.register_recipe(def)
    --output     = <item>
    --input      = {<item>, <fuel?>}
    local outputs = ((type(def.output)=="table") and def.output) or {def.output}
    for i, item in ipairs(outputs) do
        recipes[item] = recipes[item] or {}
        table.insert(recipes[item], def)
    end

    local inputs = ((type(def.input)=="table") and def.input) or {def.input}
    for i, inputitem in ipairs(inputs) do
        recipes[inputitem] = recipes[inputitem] or {}
        table.insert(recipes_lookup[inputitem], def)
    end
end


--[[
    image[2.75,1.5;1,1;default_furnace_fire_bg.png]
    image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]
]]
function Bloomery_furnace:get_rightclick_formspec()
    local form = self.parent_class:get_rightclick_formspec()
    form = form .. [[
    list[context;inp;2.75,0.5;2,1;]
    list[context;fuel;3.25,2.15;1,1;]
    list[context;out2;5,2.5  ; 1,1;]
    list[context;out1;5,1.25; 1,1;]

    list[current_player;main;0,4.25;8,1;]
    list[current_player;main;0,5.5;8,3;8]

    listring[context;out]
    listring[current_player;main]
    listring[context;in]
    listring[current_player;main]
    listring[context;fuel]
    listring[current_player;main]
    ]]
    return form
end

minetest.register_node("cs_materials:bloomery_furnace", {
    --drawtype = "mesh",
    --collisions_box = {},
    tiles = {"default_furnace_front.png"},
    on_construct = function(pos)
        Bloomery_furnace:load(pos)
    end
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
    on_construct = function(pos)
        Bloomery_furnace:load(pos)
    end,
})

