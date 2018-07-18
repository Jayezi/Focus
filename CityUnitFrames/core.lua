local addon, ns = ...
local cfg = ns.config
local lib = ns.lib
local CityUi = CityUi

local function create_player_style(base)
	
	local anchor, parent = unpack(cfg.frame_anchors["player"])
	lib.common_init(base, anchor, anchor, 0, 0, cfg.primary_health_w, parent)
	parent.child = base
	
	lib.gen_hp_bar(base, cfg.primary_health_w, cfg.primary_health_h, true, true)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.HealthPrediction.frequentUpdates = true
	lib.push_bar(base, base.Health)
	
	local hp_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 1, 2)
	base:Tag(hp_string, "[city:color][city:hplong]")
	
	lib.gen_cast_bar(base, cfg.player_cast_w, cfg.player_cast_h, CityUi.config.font_size_med, true, false, cfg.player_color)
	base.Castbar:SetPoint("TOP", UIParent, "BOTTOM", cfg.player_cast_x, cfg.player_cast_y)
	
	local power_center, power_h, power_flip, power_tag = unpack(cfg.player_power_config)
	local power_w = power_center and cfg.player_cast_w or cfg.primary_health_w
	
	lib.gen_power_bar(base, power_w, power_h, power_flip)
	base.Power.frequentUpdates = true
	base.Power.colorClass = true

	if (lib.resource_gens[CityUi.player.class]) then
		local resource_bar = lib.resource_gens[CityUi.player.class](base, power_w, power_h)
		if (power_center) then
			resource_bar:SetPoint("TOP", base.Castbar, "BOTTOM", 0, 1)
			base.Power:SetPoint("TOP", resource_bar, "BOTTOM", 0, 1)
		else
			lib.push_bar(base, resource_bar)
			lib.push_bar(base, base.Power)
		end
	else
		if (power_center) then
			base.Power:SetPoint("TOP", base.Castbar, "BOTTOM", 0, -1)
		else
			lib.push_bar(base, base.Power)
		end
	end

	lib.gen_addp_bar(base, cfg.primary_health_w / 2, cfg.power_h)
	base.AdditionalPower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AdditionalPower:SetPoint("CENTER", base.Health, "BOTTOM")
	base.AdditionalPower.colorPower = true

	lib.gen_altp_bar(base, cfg.xp_w, cfg.xp_h)
	base.AlternativePower:SetPoint("TOP", UIParent, "TOP", cfg.xp_x, cfg.xp_y - cfg.xp_h - 5)

	local altp_string = CityUi.util.gen_string(base.AlternativePower, CityUi.config.font_size_med, nil, nil, "BOTTOM", "CENTER")
	altp_string:SetPoint("BOTTOM", 0, 1)
	base:Tag(altp_string, "[city:color][city:altpower]")
	
	local power_string
	if (power_center) then
		power_string = CityUi.util.gen_string(base.Power, CityUi.config.font_size_med, nil, nil, "CENTER", "BOTTOM")
		power_string:SetPoint("BOTTOM", 0, 1)
	else
		power_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
		power_string:SetPoint("BOTTOMRIGHT", base.Health, "TOPRIGHT", 1, 2)
	end
	base:Tag(power_string, power_tag)
	base:SetHeight(0 - base.stack_bottom)
	
	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(name_string, "[city:color][city:info][name]")
	
	lib.gen_xp_bar(base, cfg.xp_w, cfg.xp_h)
	base.Experience:SetPoint("TOP", UIParent, "TOP", cfg.xp_x, cfg.xp_y)
	
	local xp_string = CityUi.util.gen_string(base.Experience, CityUi.config.font_size_med, nil, nil, "BOTTOM", "CENTER")
	xp_string:SetPoint("BOTTOM", 0, 1)
	base:Tag(xp_string, "[experience:cur] / [experience:max] - [experience:per]%")
	
	lib.gen_debuffs(base, cfg.primary_health_w, cfg.raid_auras["player"])
	lib.gen_buffs(base, cfg.primary_health_w, cfg.raid_auras["player"])
	lib.enable_test(base)
	
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, CityUi.config.font_size_med + 2)
	base.Buffs:SetPoint("BOTTOMRIGHT", base.Debuffs, "TOPRIGHT", 0, 1)
	base.Buffs.CustomFilter = lib.custom_buff_whitelist
	
	lib.gen_raid_mark(base, cfg.raid_marks["primary"])
end

local function create_target_style(base)
	
	local anchor, parent = unpack(cfg.frame_anchors["target"])
	lib.common_init(base, anchor, anchor, 0, 0, cfg.primary_health_w, parent)
	parent.child = base
	
	lib.gen_hp_bar(base, cfg.primary_health_w, cfg.primary_health_h, true)
	base.Health.colorTapping = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	lib.push_bar(base, base.Health)
	
	local hp_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	base:Tag(hp_string, "[city:color][city:hplong]")
	
	lib.gen_cast_bar(base, cfg.target_cast_w, cfg.target_cast_h, CityUi.config.font_size_med, false, true)
	base.Castbar:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", cfg.target_cast_x, cfg.target_cast_y)
	
	lib.gen_power_bar(base, cfg.primary_health_w, cfg.power_h)
	base.Power.colorReaction = true
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	lib.push_bar(base, base.Power)

	-- TODO make new bar
	base.Power.displayAltPower = true
	base.Power.altPowerColor = cfg.altp_color
	
	local power_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[city:color][city:pplongfrequent]")
	
	base:SetHeight(0 - base.stack_bottom)
	
	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 1)
	base:Tag(name_string, "[city:color][city:info][name]")
	
	lib.gen_buffs(base, cfg.primary_health_w, cfg.raid_auras["target_buff"])
	lib.gen_debuffs(base, cfg.primary_health_w, cfg.raid_auras["target_debuff"])
	lib.enable_test(base)
	
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, CityUi.config.font_size_med + 2)
	base.Debuffs.PostUpdateIcon = lib.post_update_icon
	base.Buffs:SetPoint("BOTTOMLEFT", base.Debuffs, "TOPLEFT", 0, 1)
	
	lib.gen_raid_mark(base, cfg.raid_marks["primary"])
end

local function create_nameplate_style(base)

	local w, h = cfg.nameplate_health_w, cfg.nameplate_health_h
	base:SetSize(w + 2, h + 2)
	base:SetPoint("BOTTOM", base:GetParent(), "CENTER")
	
	lib.gen_hp_bar(base, w, h, false)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.colorTapping = true
	base.Health.frequentUpdates = true
	base.Health:SetPoint("TOPLEFT", 1, -1)
	
	base.Power = CreateFrame("StatusBar", nil, base.Health)
	base.Power:SetStatusBarTexture(CityUi.media.textures.blank)
	base.Power:SetSize(w / 2, h / 3)
	base.Power:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.Power:SetPoint("BOTTOMRIGHT")
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	base.Power.colorPower = true
	
	base.name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med)
	base:Tag(base.name_string, "[city:color][name]")
	base.name_string:SetJustifyH("LEFT")
	base.name_string:SetJustifyV("BOTTOM")
	base.name_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 0, 3)
	
	lib.gen_nameplate_debuffs(base, cfg.raid_auras["nameplate"])
	base.Debuffs.CustomFilter = lib.player_only_whitelist
	base.Debuffs:SetPoint("TOPLEFT", base.Health, "TOPRIGHT", 1, 0)
	
	lib.gen_nameplate_cast_bar(base, w, cfg.nameplate_cast_h, CityUi.config.font_size_med)
	base.Castbar:SetPoint("TOP", base.Health, "BOTTOM", 0, -1)
	
	lib.gen_raid_mark(base, cfg.raid_marks["nameplate"])
end

local function create_tot_style(base)

	lib.common_init(base, "TOPLEFT", "BOTTOMLEFT", 0, -(CityUi.config.font_size_med + 1), cfg.secondary_health_w, oUF_CityTarget)
	
	lib.gen_hp_bar(base, cfg.secondary_health_w, cfg.secondary_health_h, true)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	lib.push_bar(base, base.Health)

	base:SetHeight(0 - base.stack_bottom)

	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 1)
	base:Tag(name_string, "[city:color][name]")
end

local function create_pet_style(base)

	lib.common_init(base, "TOPLEFT", "BOTTOMLEFT", 0, -(CityUi.config.font_size_med + 1), cfg.secondary_health_w, oUF_CityPlayer)
	
	lib.gen_hp_bar(base, cfg.secondary_health_w, cfg.secondary_health_h, true)
	base.Health.colorDisconnected = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	lib.push_bar(base, base.Health)
	
	local hp_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 1, 1)
	base:Tag(hp_string, "[city:color][city:currhp]")

	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(name_string, "[city:color][name]")
	
	lib.gen_power_bar(base, cfg.secondary_health_w, cfg.power_h)
	base.Power.colorReaction = true
	base.Power.frequentUpdates = true
	lib.push_bar(base, base.Power)

	base:SetHeight(0 - base.stack_bottom)
	
	local power_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[city:color][city:shortppfrequent]")
	
	lib.gen_debuffs(base, cfg.secondary_health_w, cfg.raid_auras["pet"])
	base.Debuffs:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(CityUi.config.font_size_med + 4))
	
	lib.gen_buffs(base, cfg.secondary_health_w, cfg.raid_auras["pet"])
	base.Buffs:SetPoint("TOPRIGHT", base.Debuffs, "BOTTOMRIGHT", 0, -1)
	base.Buffs.CustomFilter = lib.custom_buff_whitelist
end

local function create_focus_style(base)

	local w, h = cfg.frame_sizes["focus"][1], cfg.frame_sizes["focus"][2]
	
	local anchor, parent = unpack(cfg.frame_anchors["focus"])
	lib.common_init(base, anchor, anchor, 0, 0, w, parent)
	parent.child = base
	
	lib.gen_hp_bar(base, w, h, true)
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	lib.push_bar(base, base.Health)

	base:SetHeight(0 - base.stack_bottom)

	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(name_string, "[city:color][name]")

	lib.gen_debuffs(base, w, cfg.raid_auras["focus"])
	base.Debuffs.CustomFilter = lib.custom_blacklist
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, 1)
	lib.enable_test(base)
	
	lib.gen_cast_bar(base, w, cfg.cast_h, CityUi.config.font_size_med)
	base.Castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(CityUi.config.font_size_med + 2))
	
	lib.gen_raid_mark(base, cfg.raid_marks["focus"])
end

local function create_boss_style(base)

	local w, h = cfg.frame_sizes["boss"][1], cfg.frame_sizes["boss"][2]

	lib.common_init(base, nil, nil, 0, 0, w)
	
	lib.gen_hp_bar(base, w, h, true)
	base.Health.colorReaction = true
	lib.push_bar(base, base.Health)
	
	local hp_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 2)
	base:Tag(hp_string, "[city:color][perhp]%")
	
	lib.gen_cast_bar(base, w, cfg.cast_h, CityUi.config.font_size_med)
	base.Castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(CityUi.config.font_size_med + 2))
	
	lib.gen_power_bar(base, w, cfg.power_h)
	base.Power.colorReaction = true
	base.Power.colorPower = true
	lib.push_bar(base, base.Power)
	
	local power_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 2)
	base:Tag(power_string, "[city:color][perpp]%")
	
	lib.gen_altp_bar(base, w / 2, cfg.power_h)
	base.AlternativePower:SetPoint("CENTER", base.Health, "BOTTOM")
	
	base:SetHeight(0 - base.stack_bottom)
	
	local altp_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "RIGHT", "TOP")
	altp_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 1)
	base:Tag(altp_string, "[city:color][city:altpower]")
	
	local name_string = CityUi.util.gen_string(base, CityUi.config.font_size_med, nil, nil, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 2)
	name_string:SetPoint("TOPRIGHT", altp_string, "TOPLEFT", -5, 0)
	base:Tag(name_string, "[city:color][name]")
	
	lib.gen_nameplate_debuffs(base, cfg.raid_auras["boss"])
	base.Debuffs:SetPoint("TOPRIGHT", base, "TOPLEFT", -1, 0)
	base.Debuffs.CustomFilter = lib.player_only_whitelist
	
	lib.gen_raid_mark(base, cfg.raid_marks["boss"])
end

local tank_w = 1 + cfg.frame_sizes["tank"][1] + 1
local tank_h = 1 + cfg.frame_sizes["tank"][2] + 1 + cfg.power_h + 1

local function create_tank_style(base)

	local w, h = cfg.frame_sizes["tank"][1], cfg.frame_sizes["tank"][2]

	lib.common_init(base, nil, nil, 0, 0, w)
	
	lib.gen_hp_bar(base, w, h, true)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	lib.push_bar(base, base.Health)
	
	local name_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[city:color][name]")
	
	lib.gen_power_bar(base, w, cfg.power_h)
	base.Power.colorClass = true
	base.Power.frequentUpdates = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)
	
	lib.gen_debuffs(base, w, cfg.raid_auras["tank"])
	base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
	base.Debuffs.CustomFilter = lib.custom_blacklist
	
	base:SetHeight(0 - base.stack_bottom)
	
	lib.gen_raid_mark(base, cfg.raid_marks["party"])
	lib.gen_raid_role(base)
	lib.gen_ready_check(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.oor_alpha,
	}
end

local party_w = 1 + cfg.frame_sizes["party"][1] + 1
local party_h = 1 + cfg.frame_sizes["party"][2] + 1 + cfg.power_h + 1

local function create_party_style(base)

	local w, h = cfg.frame_sizes["party"][1], cfg.frame_sizes["party"][2]

	lib.common_init(base, nil, nil, 0, 0, w)
	
	lib.gen_hp_bar(base, w, h, true)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	lib.push_bar(base, base.Health)
	
	lib.gen_heal_bar(base, w)

	local name_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[city:color][name]")
	
	local hp_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
	hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
	hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
	base:Tag(hp_string, "[city:color][city:info][city:hpraid]")
	
	lib.gen_power_bar(base, w, cfg.power_h)
	base.Power.frequentUpdates = true
	base.Power.colorPower = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)
	
	lib.gen_debuffs(base, w, cfg.raid_auras["party"])
	base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
	base.Debuffs.CustomFilter = lib.custom_blacklist
	
	base:SetHeight(0 - base.stack_bottom)
	
	if (cfg.indicators) then
		lib.gen_indicators(base)
	end
	
	lib.gen_raid_mark(base, cfg.raid_marks["party"])
	lib.gen_raid_role(base)
	lib.gen_ready_check(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.oor_alpha,
	}
end

local create_raid_style

local raid_w, raid_h

if cfg.role == "DAMAGER" or cfg.role == "TANK" then
	
	raid_w = 1 + cfg.frame_sizes["damager"][1] + 1
	raid_h = 1 + cfg.frame_sizes["damager"][2] + 1 + cfg.power_h + 1

	create_raid_style = function(base)
	
		local w, h = cfg.frame_sizes["damager"][1], cfg.frame_sizes["damager"][2]

		lib.common_init(base, nil, nil, 0, 0, w)
		
		lib.gen_hp_bar(base, w, h, true)
		base.Health.frequentUpdates = true
		base.Health.colorDisconnected = true
		base.Health.colorClass = true
		base.Health.colorReaction = true
		lib.push_bar(base, base.Health)

		local name_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
		name_string:SetPoint("TOPLEFT")
		name_string:SetPoint("TOPRIGHT")
		base:Tag(name_string, "[city:color][name]")
		
		lib.gen_power_bar(base, w, cfg.power_h)
		base.Power.colorPower = true
		base.Power.altPowerColor = cfg.altp_color
		lib.push_bar(base, base.Power)
		
		lib.gen_debuffs(base, w, cfg.raid_auras["damager"])
		base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
		base.Debuffs.CustomFilter = lib.custom_whitelist
		
		base:SetHeight(0 - base.stack_bottom)
		
		if (cfg.indicators) then
			lib.gen_indicators(base)
		end
		
		lib.gen_raid_mark(base, cfg.raid_marks["raid"])
		lib.gen_raid_role(base)
		lib.gen_ready_check(base)
		
		base.Range = {
			insideAlpha = 1,
			outsideAlpha = cfg.oor_alpha,
		}
	end
else
	
	raid_w = 1 + cfg.frame_sizes["healer"][1] + 1
	raid_h = 1 + cfg.frame_sizes["healer"][2] + 1 + cfg.power_h + 1

	create_raid_style = function(base)
		
		local w, h = cfg.frame_sizes["healer"][1], cfg.frame_sizes["healer"][2]

		lib.common_init(base, nil, nil, 0, 0, w)
		
		lib.gen_hp_bar(base, w, h, true)
		base.Health.frequentUpdates = true
		base.Health.colorDisconnected = true
		base.Health.colorClass = true
		base.Health.colorReaction = true
		lib.push_bar(base, base.Health)
		
		lib.gen_heal_bar(base, w)

		local name_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
		name_string:SetPoint("TOPLEFT")
		name_string:SetPoint("TOPRIGHT")
		base:Tag(name_string, "[city:color][name]")
		
		local hp_string = CityUi.util.gen_string(base.Health, CityUi.config.font_size_med, nil, nil, "CENTER", "TOP")
		hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
		hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
		base:Tag(hp_string, "[city:color][city:info][city:hpraid]")
		
		lib.gen_power_bar(base, w, cfg.power_h)
		base.Power.colorPower = true
		base.Power.colorDisconnected = true
		lib.push_bar(base, base.Power)
		
		lib.gen_debuffs(base, w, cfg.raid_auras["healer"])
		base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
		base.Debuffs.CustomFilter = lib.custom_blacklist
		
		base:SetHeight(0 - base.stack_bottom)
		
		if (cfg.indicators) then
			lib.gen_indicators(base)
		end
		
		lib.gen_raid_mark(base, cfg.raid_marks["raid"])
		lib.gen_raid_role(base)
		lib.gen_ready_check(base)
		
		base.Range = {
			insideAlpha = 1,
			outsideAlpha = cfg.oor_alpha,
		}
	end
end

oUF:Factory(function(self)
	
	if cfg.enabled.nameplates then
		oUF:RegisterStyle("CityNameplate", create_nameplate_style)
		oUF:SpawnNamePlates("City", nil, cfg.nameplate_config)
		C_NamePlate.SetNamePlateEnemySize(cfg.nameplate_health_w, cfg.nameplate_health_h * 4)
		C_NamePlate.SetNamePlateFriendlySize(cfg.nameplate_health_w, cfg.nameplate_health_h * 4)
	end

	if cfg.enabled.player then
		oUF:RegisterStyle("CityPlayer", create_player_style)
		oUF:SetActiveStyle("CityPlayer")
		oUF:Spawn("player")
	end

	if cfg.enabled.target then
		oUF:RegisterStyle("CityTarget", create_target_style)
		oUF:SetActiveStyle("CityTarget")
		oUF:Spawn("target")
	end

	if cfg.enabled.tot then
		oUF:RegisterStyle("CityToT", create_tot_style)
		oUF:SetActiveStyle("CityToT")
		oUF:Spawn("targettarget")
	end

	if cfg.enabled.focus then
		oUF:RegisterStyle("CityFocus", create_focus_style)
		oUF:SetActiveStyle("CityFocus")
		oUF:Spawn("focus")
	end

	if cfg.enabled.boss then
		oUF:RegisterStyle("CityBoss", create_boss_style)
		oUF:SetActiveStyle("CityBoss")

		local boss = {}

		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "oUF_CityBoss"..i)

			if i == 1 then
				boss[i]:SetPoint(unpack(cfg.frame_anchors["boss"]))
			else
				-- Account for cast bar and debuffs.
				boss[i]:SetPoint("TOPRIGHT", boss[i - 1], "BOTTOMRIGHT", 0, -(cfg.cast_h + 2 * (CityUi.config.font_size_med + 4) + 6))
			end
		end
	end

	if cfg.enabled.pet then
		oUF:RegisterStyle("CityPet", create_pet_style)
		oUF:SetActiveStyle("CityPet")
		oUF:Spawn("pet")
	end

	if cfg.enabled.party then

		local test_w = party_w * 5 - 4
		local test_h = party_h

		oUF:RegisterStyle("CityParty", create_party_style)
		oUF:SetActiveStyle("CityParty")
   
		local party = oUF:SpawnHeader(
			"oUF_CityParty", nil,
			"custom [@raid1,exists] hide; [group:party,nogroup:raid] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showParty",          true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(party_w, party_h)
		)
		local anchor, parent = unpack(cfg.frame_anchors["party"])
		party:SetPoint(anchor, parent)
		local spacer = CreateFrame("Frame", nil, parent)
		CityUi.util.gen_backdrop(spacer)
		spacer:SetFrameStrata("BACKGROUND")
		spacer:SetPoint(anchor, parent)
		spacer:SetSize(test_w, test_h)
	end

	if cfg.enabled.tank then

		local test_w = tank_w
		local test_h = tank_h * 2 - 1

		oUF:RegisterStyle("CityTank", create_tank_style)
		oUF:SetActiveStyle("CityTank")
		local tank = oUF:SpawnHeader(
			"oUF_CityTank", 	nil,
			'raid, party, solo',
			'showRaid', 		true,
			"groupFilter", 		"MAINTANK",
			'yoffset', 			1,
			'xoffset', 			0,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(tank_w, tank_h)
		)
		local anchor, parent = unpack(cfg.frame_anchors["tank"])
		tank:SetPoint(anchor, parent)
		local spacer = CreateFrame("Frame", nil, parent)
		CityUi.util.gen_backdrop(spacer)
		spacer:SetFrameStrata("BACKGROUND")
		spacer:SetPoint(anchor, parent)
		spacer:SetSize(test_w, test_h)
	end
 
	if cfg.enabled.raid then

		local test_w = raid_w * 5 - 4
		local test_h = raid_h * 6 - 5

		oUF:RegisterStyle("CityRaid", create_raid_style)
		oUF:SetActiveStyle("CityRaid")
   
		local raid = oUF:SpawnHeader(
			"oUF_CityRaid21", nil,
			"custom [@raid1,exists] show; hide",
			"showPlayer",         true,
			"showSolo",           true,
			"showRaid",           true,
			"point",              "LEFT",
			"yoffset",            0,
			"xoffset",            -1,
			"columnSpacing",      -1,
			"columnAnchorPoint",  "TOP",
			"groupFilter",        "1,2,3,4,5,6",
			"groupBy",            "GROUP",
			"groupingOrder",      "1,2,3,4,5,6",
			"sortMethod",         "INDEX",
			"maxColumns",         8,
			"unitsPerColumn",     5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(raid_w, raid_h)
		)
		local anchor, parent = unpack(cfg.frame_anchors["raid"])
		raid:SetPoint(anchor, parent)
		local spacer = CreateFrame("Frame", nil, parent)
		CityUi.util.gen_backdrop(spacer)
		spacer:SetFrameStrata("BACKGROUND")
		spacer:SetPoint(anchor, parent)
		spacer:SetSize(test_w, test_h)
	end
end)

SlashCmdList["TESTBOSS"] = function()
	oUF_CityBoss1:Show(); oUF_CityBoss1.Hide = function() end oUF_CityBoss1.unit = "target"
	oUF_CityBoss2:Show(); oUF_CityBoss2.Hide = function() end oUF_CityBoss2.unit = "player"
	oUF_CityBoss3:Show(); oUF_CityBoss3.Hide = function() end oUF_CityBoss3.unit = "player"
	oUF_CityBoss4:Show(); oUF_CityBoss4.Hide = function() end oUF_CityBoss4.unit = "player"
	oUF_CityBoss5:Show(); oUF_CityBoss5.Hide = function() end oUF_CityBoss5.unit = "player"
end
SLASH_TESTBOSS1 = "/testboss"
