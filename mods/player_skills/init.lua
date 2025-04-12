core.override_item("", {
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
		},
		damage_groups = {fleshy=1},
	}
})

cs_player_skills = {
	global_skills = {},
	players = {},
	global_classes = {},
	Skill_handler = nil
}
local modpath = core.get_modpath("cs_player_skills")
cs_player_skills.config = {
	acceptable_exp_loss = 100 --every 100 exp gains we will force push a change incase of crash
}
local conf = Settings(modpath.."/mod.conf"):to_table() or {}
local mt_conf = minetest.settings:to_table() --allow use of MT config for servers that regularly update 4dguns through it's development
for i, v in pairs(cs_player_skills.config) do
	local q = "cs_player_skills."..i
    if mt_conf[q] ~= nil then
        cs_player_skills.config[i] = mt_conf[q]
    elseif mt_conf[q] ~= nil then
        cs_player_skills.config[i] = conf[q]
    end
end
local config = cs_player_skills.config
--override the default hand. This is just from mtg default because i cant be fucked.

local default_skill_def = {
	name = nil,
	exp_per_level = 100,
	level_cap = 10,
	exp_gain_modifier = 1,
	tools = {}
}
function cs_player_skills.register_skill(name, def)
	for i, v in pairs(default_skill_def) do
		if not def[i] then def[i] = v end
	end
	def.name = name
	cs_player_skills.global_skills[name] = def
end

local default_class_def = {
	name = nil,
	skill_exp_gain_multipliers = {},
	skill_cap_overrides  = {},
}
function cs_player_skills.register_class(name, def)
	for i, v in pairs(default_class_def) do
		if not def[i] then def[i] = v end
	end
	def.name = name
	cs_player_skills.global_classes[name] = def
end

local Skill_handler = {
	exp_gain_counter = 0, --this is just a counter that lets us track how much xp has been gained since the last push.
	player_skills = nil, --{} Skill exp table
	player_class = nil --[[{
		skill_offsets = {},
		skill_level = 0
	}]]
}


function Skill_handler:push_meta()
	print("meta pushed")
	assert(self.instance)
	self.exp_gain_counter = 0
	local meta = self.player:get_meta()
	meta:set_string("player_skills:skills", minetest.serialize(self.skills))
	meta:set_string("player_skills:class" , self.class                     )
end
function Skill_handler:gain_experience(skill, exp)
	assert(self.instance)
	local skilldef = cs_player_skills.global_skills[skill]
	local currskill = self.player_skills[skill]
	--check if we actually bumped a level
	local levelbumped = math.floor((currskill+exp)/skilldef.exp_per_level) > math.floor(currskill/skilldef.exp_per_level)
	self.exp_gain_counter = self.exp_gain_counter + exp
	if levelbumped or (self.exp_gain_counter > config.acceptable_exp_loss) then
		Skill_handler:push_meta() --note push resets exp_gain_counter
	end
	error("incomplete")
end
function Skill_handler:get_skill(skill)
	assert(self.instance)
	return self.player_skills[skill]
end
function Skill_handler.construct(self)
	if self.instance then
		assert(self.player)
		for i, v in pairs(cs_player_skills.global_skills) do
			self.player_skills[i] = 0
		end
		local meta = self.player:get_meta()
		if meta:get_string("player_skills:class")=="" then
			meta:set_string("player_skills:skills", minetest.serialize({}))
			meta:set_string("player_skills:class",  "none")
			self.player_class = "none"
		else
			local skills = minetest.deserialize(meta:get_string("player_skills:skills"))
			for i,v in pairs(skills or {}) do
				self.player_skills[i]=v
			end
			self.player_class = meta:get_string("player_skills:class")
		end
	end
end
Skill_handler = leef.class.new(Skill_handler)
cs_player_skills.Skill_handler = Skill_handler

core.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	cs_player_skills.players[pname]:push_meta()
	cs_player_skills.players[pname]=nil
end)
core.register_on_shutdown(function()
	for _, player in pairs(core.get_connected_players()) do
		local pname = player:get_player_name()
		if cs_player_skills.players[pname] then
			cs_player_skills.players[pname]:push_meta()
		end
	end
end)

--setmetatable(cs_player_skills, {__mode="k"})
core.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	cs_player_skills.players[pname] = Skill_handler({
		player=player
	})
end)