
--defines a crafting recipe through any means.
crafting.Craftdef = leef.class.new({
    out                    = {"modname:item",  --[[...]]},
    type                   = "inventory",      --craftable from inventory menu
    unfinished_texture     = "unifinished.png",--for partially crafted items
    required_tools         = nil,              --list
    input_quality_matters  = false,            --whether the quality of inputs will actually effect the quality of the item
    inputs                 = nil,              --list of items and their weights. Weights default to one if entered in numeric indices.
    total_input_weight     = nil,              --generated in construct automatically
    max_quality            = 1,                --percentage of max quality of the item(s)
    quality_variation      = 0,                --random quality offset
    skill_factor           = 0,                --percentage of max quality which is determined by the player's percentage skill. max_quality - skill_factor*(skill/skill_max)*max_quality
    skill                  = nil,              --string skill which influences the quality
    construct_new_class    = function(self)
        assert(self.out~=self.base_class.out)
        for i, v in ipairs(self.inputs) do
            self.inputs[v] = 1
            self.inputs[i] = nil
        end
        local weight = 0
        for i, v in pairs(self.inputs) do
            weight = weight + v
        end
        self.total_input_weight = weight
    end,
    construct = error
})
local Craftdef = crafting.Craftdef
function Craftdef:inherit_quality(inputs)
end
