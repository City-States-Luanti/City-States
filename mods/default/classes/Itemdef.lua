local Itemdef      = leef.class.new({
    quality_increments     = 5,                --maximum possible quality of the item
    quality_is_whole       = true,             --wether quality
    itemdef                = nil,              --engine definition, instantiated in construct_new_class.
    itemname               = nil, --[["modname:item"]]
    description            = "",
    inventory_image        = "",
    wield_image            = "",
    itemtype               = "",
    construct_new_class    = function(self)
        self.itemdef = {}
        if self.itemname then --make sure its a named item and not a template class
            for _, i in pairs({"inventory_image", "wield_image", "description", "short_description", "wield_scale", "groups"}) do
                self.itemdef[i] = self[i]
            end
        end
    end,
    construct = error
})
--[[local function recursive_find_inheritance(class, i)
    return class[i] or ((not class.parent_class) and nil) or recursive_find_inheritance(class.parent_class, i)
end]]


cs_crafting.Itemdef = Itemdef

print("test", math.log(2))