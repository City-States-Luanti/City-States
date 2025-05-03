local Craftitemdef = cs_crafting.Itemdef:new_class({
    density = 10, --10 gram per cubic cm. Or 10 kg/liter. Determines the max stack
    construct_new_class    = function(self)
        local coreitemdef = self.itemdef
        --[[if self.density then
            self.itemdef.stack_max = math.ceil(self.density*10) --each slot is 10 liters,
        end]]
        self.description = self.description or ""
        self.itemdef.stack_max = 20
        self.itemdef.range = 0
        self.itemdef.short_description = self.description
        self.itemdef.description = self.description.."\n     density: ".. self.density.."kg/L \n     stacksize: "..self.itemdef.stack_max
        core.register_craftitem(self.itemname, coreitemdef)
    end
})
cs_crafting.Craftitemdef = Craftitemdef