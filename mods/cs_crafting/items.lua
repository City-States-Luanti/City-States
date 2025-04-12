local Craftdef, Itemdef, Tooldef, Fueldef
local max_group_difficulty = 20

local default_def = minetest.registered_items[""]
Itemdef      = leef.class.new({
    quality_increments     = 4,                --maximum possible quality of the item
    quality_is_whole       = true,            --wether quality
    itemdef                = nil,               --engine definition, instantiated in construct_new_class.
    itemname               = nil, --[["modname:item"]]
    description            = "",
    inventory_image        = "",
    wield_image            = "",
    construct_new_class    = function(self)
        self.itemdef = {}
        if self.itemname then --make sure its a named item and not a template class
            for _, i in pairs({"inventory_image", "wield_image", "description", "short_description", "wield_scale"}) do
                self.itemdef[i] = self[i]
                print(i)
            end
        end
        print("construct1", "defclass", self)
        print(self.itemname, self.itemdef, Itemdef.itemdef)
    end,
    construct = error
})
--[[local function recursive_find_inheritance(class, i)
    return class[i] or ((not class.parent_class) and nil) or recursive_find_inheritance(class.parent_class, i)
end]]
Craftitemdef = Itemdef:new_class({
    construct_new_class    = function(self)
        local coreitemdef = self.itemdef
        core.register_craftitem(self.itemstring, coreitemdef)
    end
})

--[[
================== TOOLS ====================

]]
Tooldef      = Itemdef:new_class({
    quality_increments     = 100,
    quality_is_whole       = false,
    skill                  = nil,
    skill_factor           = 0,
    on_use                 = nil, --func
    update_skill_stats     = nil, --func
    construct_new_class    = function(self)
        print("construct2", "defclass", self)
        local old_on_use = self.itemdef.on_use
        --[[function self.itemdef.on_use(...)
            self:on_use(...)
            if old_on_use then
                old_on_use(...)
            end
        end]]

        function self.itemdef.after_use(...)
            local itemstack, user, node, digparams = ...
            local this_after_use = rawget(self, "after_use")
            if this_after_use then itemstack = this_after_use(...) end
            itemstack = self.parent_class:after_use(itemstack, user, node, digparams)
            return itemstack
        end
        self.itemdef.description = self.description

        self.itemdef                             = self.itemdef                             or {}
        self.itemdef.tool_capabilities           = self.itemdef.tool_capabilities           or {}
        self.itemdef.tool_capabilities.groupcaps = self.itemdef.tool_capabilities.groupcaps or {}
        local tool_cape = self.itemdef.tool_capabilities

        if self.max_capabilities and self.max_capabilities.groups then
            for i,v in pairs(self.max_capabilities.groups) do
                local groupcaps = self.itemdef.tool_capabilities.groupcaps[i]
                groupcaps = groupcaps or {}
                groupcaps.times = self:get_break_times(v.maxlevel or 20, v.maxtime or 5, v.factor or 100)
                --groupcaps.uses = 20

                self.itemdef.tool_capabilities.groupcaps[i] = groupcaps
            end
        end
        tool_cape.full_punch_interval = 1.2
        tool_cape.max_drop_level=0

        print(dump(self.itemdef))
        minetest.register_tool(self.itemname, self.itemdef)
    end
})

local e = 2.718281828459045235360287471352662497757247093699959574966967627724076630353

function Tooldef:after_use(itemstack, user, node, digparams)
    print(dump(digparams), dump(node))
end
function Tooldef:get_break_time(x,m,t,c)
    local time
    if m<x then
        time = false
    else
        local exp = -((x-m)^2/(2*c^2))
        time = t*e^exp
    end
    return time
end

function Tooldef:get_break_times(m,t,c)
    local times = {}
    for i=1, max_group_difficulty do
        local time = self:get_break_time(i,m,t,c)
        times[i]=time or nil --if it's false it'll just evaluate to nil
    end
    return times
end
function Tooldef:on_use()
    self:update_skill_stats()
end
function Tooldef:update_skill_stats(meta)
end

crafting.Craftdef, crafting.Itemdef, crafting.Tooldef, crafting.Fueldef = Craftdef, Itemdef, Tooldef, Fueldef

print("test", math.log(2))