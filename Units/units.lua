local _, addon = ...
if not addon.units.enabled then return end
local core = addon.core
local cfg = addon.units.cfg
local lib = addon.units.lib
local oUF = addon.oUF

local CreateFrame = CreateFrame
local C_NamePlate = C_NamePlate
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local UnitGUID = UnitGUID
local strsplit = strsplit
local CastingBarFrame_SetUnit = CastingBarFrame_SetUnit
local CastingBarFrame = CastingBarFrame
local PetCastingBarFrame = PetCastingBarFrame
local UnitExists = UnitExists

local create_player_style = function(base)

	local player_cfg = cfg.frames.player
	base:SetWidth(player_cfg.size.w)
	lib.enable_mouse(base)

	-- cast
	base.Castbar = lib.gen_cast_bar(base, player_cfg.cast.size.w, player_cfg.cast.size.h, core.config.font_size_med, true, false, core.player.color)
	base.Castbar:SetPoint(core.util.to_tl_anchor(base.Castbar, player_cfg.cast.pos))
	
	local power_standalone, power_invert, power_tag = unpack(player_cfg.power.cfg)
	local power_w = power_standalone and player_cfg.cast.size.w or player_cfg.size.w
	local power_h = power_standalone or player_cfg.power.h
	
	-- power
	base.Power = core.util.gen_statusbar(base, power_w, power_h)
	base.Power.colorClass = true
	if power_invert then
		base.Power.PostUpdateColor = lib.invert_color
	end

	-- classbar
	local resource_bar = lib.gen_resource_bar(core.player.class, base, power_w, power_h)
	if (resource_bar) then
		if (power_standalone) then
			resource_bar:SetPoint("TOPLEFT", base.Castbar, "BOTTOMLEFT", 0, 1)
			base.Power:SetPoint("TOPLEFT", resource_bar, "BOTTOMLEFT", 0, 1)
		else
			lib.push_bar(base, resource_bar)
			lib.push_bar(base, base.Power)
		end
	else
		if (power_standalone) then
			base.Power:SetPoint("TOPLEFT", base.Castbar, "BOTTOMLEFT", 0, 1)
		else
			lib.push_bar(base, base.Power)
		end
	end

	-- health
	base.Health = core.util.gen_statusbar(base, player_cfg.size.w, player_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)

	-- druid mana etc.
	base.AdditionalPower = core.util.gen_statusbar(base, player_cfg.size.w, player_cfg.power.h)
	base.AdditionalPower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AdditionalPower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AdditionalPower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	base.AdditionalPower.colorPower = true

	-- alternate power
	base.AlternativePower = core.util.gen_statusbar(base, player_cfg.alt_power.size.w, player_cfg.alt_power.size.h)
	base.AlternativePower:SetPoint(core.util.to_tl_anchor(base.AlternativePower, player_cfg.alt_power.pos))
	base.AlternativePower:GetStatusBarTexture():SetAlpha(0.5)

	base:SetHeight(base.stack_height)

	-- strings
	local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr/max state]")
	
	local altp_string = core.util.gen_string(base.AlternativePower, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "BOTTOM", "CENTER")
	altp_string:SetPoint("CENTER")
	base:Tag(altp_string, "[focus:color][focus:altp:perc]")

	local hp_perc_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	hp_perc_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	base:Tag(hp_perc_string, "[focus:color][focus:hp:perc.]")

	local name_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	name_string:SetPoint("LEFT", hp_perc_string, "RIGHT", 5, 0)
	base:Tag(name_string, "[focus:color][focus:status][name]")
	
	local power_string
	if (power_standalone) then
		power_string = core.util.gen_string(base.Power, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "CENTER", "BOTTOM")
		power_string:SetPoint("BOTTOM", 0, -10)
	else
		power_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "BOTTOM")
		power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	end
	base:Tag(power_string, power_tag)
	
	-- auras
	base.Debuffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 0, core.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, player_cfg.size.w, cfg.auras.player, "Buffs")
	base.Buffs:SetPoint("BOTTOMRIGHT", base.Debuffs, "TOPRIGHT", 0, 1)
	lib.apply_whitelist_to(base.Buffs, cfg.player_buff_whitelist)
	
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(player_cfg.mark.size, player_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("RIGHT", base.Health, "LEFT", -2, 0)
end

local create_target_style = function(base)

	local target_cfg = cfg.frames.target
	base:SetWidth(target_cfg.size.w)
	lib.enable_mouse(base)

	-- power
	base.Power = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.colorTapping = true
	lib.push_bar(base, base.Power)
	
	-- health
	base.Health = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.size.h)
	base.Health.colorTapping = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	-- alternate power
	--base.AlternativePower = core.util.gen_statusbar(base, target_cfg.size.w, target_cfg.power.h)
	--base.AlternativePower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	--base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	--base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, target_cfg.cast.size.w, target_cfg.cast.size.h, core.config.font_size_med, false, true)
	base.Castbar:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", target_cfg.cast.offset.x, target_cfg.cast.offset.y)
	
	base:SetHeight(base.stack_height)

	-- strings
	local power_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", 1, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr-perc]")

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	hp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr/max state]")

	local hp_perc_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "RIGHT", "TOP")
	hp_perc_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, 10)
	base:Tag(hp_perc_string, "[focus:color][focus:hp:perc.]")

	local name_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, 10)
	name_string:SetPoint("RIGHT", hp_perc_string, "LEFT", -5, 0)
	base:Tag(name_string, "[focus:color][focus:status][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_debuff, "Debuffs")
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, core.config.font_size_med + 2)

	base.Buffs = lib.gen_auras(base, target_cfg.size.w, cfg.auras.target_buff, "Buffs")
	base.Buffs:SetPoint("BOTTOMLEFT", base.Debuffs, "TOPLEFT", 0, 1)

	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(target_cfg.mark.size, target_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("LEFT", base.Health, "RIGHT", 2, 0)
end

local create_targettarget_style = function(base)

	local tot_cfg = cfg.frames.targettarget
	base:SetWidth(tot_cfg.size.w)
	base:SetPoint("TOPLEFT", _G["oUF_FocusUnitsTarget"], "BOTTOMLEFT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, tot_cfg.size.w, tot_cfg.size.h)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	base:SetHeight(base.stack_height)

	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 1, -1)
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", -1, -1)
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetMaxLines(2)
end

local create_pet_style = function(base)

	local pet_cfg = cfg.frames.pet
	base:SetWidth(pet_cfg.size.w)
	base:SetPoint("TOPRIGHT", _G["oUF_FocusUnitsPlayer"], "BOTTOMRIGHT", 0, -20)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = core.util.gen_statusbar(base, pet_cfg.size.w, pet_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.frequentUpdates = true
	lib.push_bar(base, base.Power)

	base:SetHeight(base.stack_height)
	
	-- strings
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "TOP")
	name_string:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -1)
	name_string:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 0, -1)
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetWordWrap(false)

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "TOP")
	hp_string:SetPoint("TOPRIGHT", base, "TOPLEFT", 0, -1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr]")

	local power_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "BOTTOM")
	power_string:SetPoint("BOTTOMRIGHT", base, "BOTTOMLEFT", 0, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, -(core.config.font_size_med + 2))
	
	base.Buffs = lib.gen_auras(base, pet_cfg.size.w, cfg.auras.pet, "Buffs")
	base.Buffs:SetPoint("TOPRIGHT", base.Debuffs, "BOTTOMRIGHT", 0, -1)
	lib.apply_whitelist_to(base.Buffs, cfg.pet_buff_whitelist)
end

local create_nameplate_style = function(base)

	base:SetAllPoints()
	base:SetScale(0.5)

	local nameplate_cfg = cfg.frames.nameplate
	local w, h = nameplate_cfg.size.w, nameplate_cfg.size.h

	-- health
	base.Health = core.util.gen_statusbar(base, w, h, false)
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.colorTapping = true
	base.Health.frequentUpdates = true
	base.Health:SetPoint("BOTTOM", base, "BOTTOM", 0, 20)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)

	base.Health.PostUpdateColor = function(self, unit)
		local guid = UnitGUID(unit)
		if not guid then return end
		local _, _, _, _, _, npc_id, _ = strsplit("-", guid)
    	if cfg.nameplate_colors[tonumber(npc_id)] then
			self:SetStatusBarColor(unpack(cfg.nameplate_colors[tonumber(npc_id)]))
		end
	end
	
	-- power
	base.Power = CreateFrame("StatusBar", nil, base.Health)
	base.Power:SetStatusBarTexture(core.media.textures.blank)
	base.Power:SetSize(w - 2, nameplate_cfg.power.h)
	base.Power:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.Power:SetPoint("TOPLEFT", 1, -1)
	base.Power.colorClass = true
	base.Power.colorDisconnected = true
	base.Power.frequentUpdates = true
	base.Power.colorTapping = true
	base.Power.colorPower = true
	
	-- strings
	base.name_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
	base:Tag(base.name_string, "[focus:color][name]")
	base.name_string:SetPoint("BOTTOMLEFT", base.Health, "TOPLEFT", 1, 1)

	local hp_string = core.util.gen_string(base.Health, core.config.font_size_lrg, nil, core.media.fonts.gotham_ultra, "RIGHT", "TOP")
	base:Tag(hp_string, "[focus:color][focus:hp:perc]")
	hp_string:SetPoint("RIGHT", base.Health, "BOTTOMRIGHT", -1, 0)

	-- cast
	base.Castbar = lib.gen_nameplate_cast_bar(base, w, nameplate_cfg.cast.h, nameplate_cfg.cast.h + h - 3, core.config.font_size_med)
	base.Castbar:SetPoint("TOPLEFT", base.Health, "BOTTOMLEFT", 0, 1)

	-- auras
	base.Debuffs = lib.gen_auras(base, w, cfg.auras.nameplate_debuff, "Debuffs")
	base.Debuffs:SetPoint("TOPLEFT", base.Health, "TOPRIGHT", 1, 0)
	base.Debuffs.disableMouse = false
	lib.apply_blacklist_to(base.Debuffs, cfg.nameplate_debuff_blacklist, {player = true, pet = true})
	
	base.Buffs = lib.gen_auras(base, w, cfg.auras.nameplate_buff, "Buffs")
	base.Buffs:SetPoint("TOPRIGHT", base.Castbar.Icon, "TOPLEFT", -2, 1)
	base.Buffs.CustomFilter = function(element, _, _, _, _, _, debuffType, _, _, caster, _, _, spellID)
		if debuffType == "" or debuffType == "Magic" then
			return true
		end

		if cfg.nameplate_buff_whitelist[spellID] then
			return true
		end
	
		return false
	end
	
	-- mark
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(nameplate_cfg.mark.size, nameplate_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("CENTER", base.Health, "BOTTOM")
end

local create_focus_style = function(base)

	local focus_cfg = cfg.frames.focus
	base:SetWidth(focus_cfg.size.w)
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, focus_cfg.size.w, focus_cfg.size.h)
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base:SetHeight(base.stack_height)

	-- strings
	local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	name_string:SetPoint("TOPLEFT", base.Health, "BOTTOMLEFT", 1, 8)
	base:Tag(name_string, "[focus:color][name]")

	-- auras
	base.Debuffs = lib.gen_auras(base, focus_cfg.size.w, cfg.auras.focus, "Debuffs")
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	base.Debuffs:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 0, 1)
	
	-- cast
	local castbar = lib.gen_cast_bar(base, focus_cfg.size.w, focus_cfg.cast.h, core.config.font_size_med)
	castbar:SetPoint("TOPRIGHT", base, "BOTTOMRIGHT", 0, 1)
	castbar.Icon:ClearAllPoints()
	castbar.Icon:SetPoint("RIGHT", castbar, "TOPRIGHT", -1, 0)
	
	-- mark
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(focus_cfg.mark.size, focus_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("RIGHT", base.Health, "LEFT", -2, 0)
end

local create_boss_style = function(base)

	local boss_cfg = cfg.frames.boss
	base:SetWidth(boss_cfg.size.w)
	lib.enable_mouse(base)
	
	-- power
	base.Power = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.Power.colorReaction = true
	base.Power.colorPower = true
	lib.push_bar(base, base.Power)

	-- health
	base.Health = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.size.h)
	base.Health.colorReaction = true
	base.Health.frequentUpdates = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	-- alt power
	base.AlternativePower = core.util.gen_statusbar(base, boss_cfg.size.w, boss_cfg.power.h)
	base.AlternativePower:SetFrameLevel(base.Health:GetFrameLevel() + 1)
	base.AlternativePower:SetPoint("TOPLEFT", base.Health, "TOPLEFT", 2, -2)
	base.AlternativePower:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -2, -2)
	
	base:SetHeight(base.stack_height)
	
	-- cast
	base.Castbar = lib.gen_cast_bar(base, boss_cfg.size.w, boss_cfg.cast.h, core.config.font_size_med)
	base.Castbar:SetPoint("TOPLEFT", base, "BOTTOMLEFT", 0, 1)

	-- strings
	local altp_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "RIGHT", "BOTTOM")
	altp_string:SetPoint("BOTTOMRIGHT", base, "TOPRIGHT", -1, 1)
	base:Tag(altp_string, "[focus:color][focus:altp:perc]")
	
	local name_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	name_string:SetPoint("BOTTOMLEFT", base, "TOPLEFT", 1, 1)
	name_string:SetPoint("RIGHT", altp_string, "LEFT", -5, 0)
	base:Tag(name_string, "[focus:color][name]")

	local hp_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	hp_string:SetPoint("TOPLEFT", base, "TOPRIGHT", 1, -1)
	base:Tag(hp_string, "[focus:color][focus:hp:curr-perc]")
	
	local power_string = core.util.gen_string(base, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "TOP")
	power_string:SetPoint("BOTTOMLEFT", base, "BOTTOMRIGHT", 1, 1)
	base:Tag(power_string, "[focus:color][focus:pp:curr]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, boss_cfg.size.w , cfg.auras.boss, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base, "TOPLEFT", -1, 0)
	base.Debuffs.onlyShowPlayer = true
	
	-- mark
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(boss_cfg.mark.size, boss_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("CENTER")
end

local create_tank_style = function(base)

	local tank_cfg = cfg.frames.tank
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)
	
	-- power
	base.Power = core.util.gen_statusbar(base, tank_cfg.size.w, tank_cfg.power.h)
	base.Power.colorClass = true
	base.Power.frequentUpdates = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local role = core.util.gen_string(base.Health, 15, nil, core.media.fonts.role_symbols)
	role:SetPoint("BOTTOMRIGHT", -1, 1)
	base:Tag(role, '[focus:role]')

	local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "CENTER", "TOP")
	name_string:SetPoint("TOPLEFT")
	name_string:SetPoint("TOPRIGHT")
	base:Tag(name_string, "[focus:color][name]")
	
	-- auras
	base.Debuffs = lib.gen_auras(base, tank_cfg.size.w, cfg.auras.tank, "Debuffs")
	base.Debuffs:SetPoint("BOTTOM", base.Health, "BOTTOM", 0, -5)
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	
	-- misc
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(tank_cfg.mark.size, tank_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("TOPLEFT", 2, -2)

	lib.gen_ready_check(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.range_alpha,
	}
end

local create_party_style = function(base)

	local party_cfg = cfg.frames.party
	lib.enable_mouse(base)
	
	-- health
	base.Health = core.util.gen_statusbar(base, party_cfg.size.w, party_cfg.size.h)
	base.Health.frequentUpdates = true
	base.Health.colorDisconnected = true
	base.Health.colorClass = true
	base.Health.colorReaction = true
	base.Health.PostUpdateColor = lib.invert_color
	lib.push_bar(base, base.Health)

	base.HealthPrediction = lib.gen_heal_bar(base.Health)
	base.HealthPrediction.frequentUpdates = true

	-- power
	base.Power = core.util.gen_statusbar(base, party_cfg.size.w, party_cfg.power.h)
	base.Power.frequentUpdates = true
	base.Power.colorPower = true
	base.Power.colorDisconnected = true
	lib.push_bar(base, base.Power)

	-- strings
	local role = core.util.gen_string(base.Health, 15, nil, core.media.fonts.role_symbols)
	role:SetPoint("BOTTOMRIGHT", -1, 1)
	base:Tag(role, '[focus:role]')

	local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
	name_string:SetPoint("BOTTOMLEFT", 1, 1)
	name_string:SetPoint("BOTTOMRIGHT", role, "BOTTOMLEFT", 2, 0)
	base:Tag(name_string, "[focus:color][name]")
	name_string:SetWordWrap(false)
	
	local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
	hp_string:SetPoint("BOTTOMLEFT", name_string, "TOPLEFT")
	base:Tag(hp_string, "[focus:color][focus:hp:group]")	

	-- auras
	base.Debuffs = lib.gen_auras(base, party_cfg.size.w, cfg.auras.party, "Debuffs")
	base.Debuffs:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -1, -1)
	lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
	
	-- base.AuraWatch = lib.gen_indicators(base, party_cfg.indicators)
	
	base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
	base.RaidTargetIndicator:SetSize(party_cfg.mark.size, party_cfg.mark.size)
	base.RaidTargetIndicator:SetPoint("TOPRIGHT", base.Health, "TOPLEFT", -2, -2)
	
	lib.gen_ready_check(base)
	lib.gen_summon(base)
	
	base.Range = {
		insideAlpha = 1,
		outsideAlpha = cfg.range_alpha,
	}
end

local create_raid_style = function(spec_role)

	if spec_role == "minimal" then
	
		return function(base)
		
			local raid_cfg = cfg.frames.raid
			lib.enable_mouse(base)
			
			-- health
			base.Health = core.util.gen_statusbar(base, raid_cfg.size[spec_role].w, raid_cfg.size[spec_role].h)
			base.Health.frequentUpdates = true
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdateColor = lib.invert_color
			lib.push_bar(base, base.Health)

			-- power
			base.Power = core.util.gen_statusbar(base, raid_cfg.size[spec_role].w, raid_cfg.power.h)
			base.Power.colorPower = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local role = core.util.gen_string(base.Health, 15, nil, core.media.fonts.role_symbols)
			role:SetPoint("TOPLEFT", 1, -1)
			base:Tag(role, '[focus:role]')

			local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
			name_string:SetPoint("BOTTOMLEFT", 1, 1)
			name_string:SetPoint("BOTTOMRIGHT", -1, 1)
			name_string:SetWordWrap(false)
			base:Tag(name_string, "[focus:color][name]")
			
			-- auras
			base.Debuffs = lib.gen_auras(base, raid_cfg.size[spec_role].w, cfg.auras.minimal, "Debuffs")
			base.Debuffs:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -1, -1)
			lib.apply_whitelist_to(base.Debuffs, cfg.debuff_whitelist)
			
			-- base.AuraWatch = lib.gen_indicators(base, raid_cfg.indicators)
			
			base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
			base.RaidTargetIndicator:SetSize(raid_cfg.mark.size, raid_cfg.mark.size)
			base.RaidTargetIndicator:SetPoint("CENTER", base.Health, "LEFT", 2, 0)

			lib.gen_ready_check(base)
			lib.gen_summon(base)
			
			base.Range = {
				insideAlpha = 1,
				outsideAlpha = cfg.range_alpha,
			}
		end

	else
	
		return function(base)

			local raid_cfg = cfg.frames.raid
			lib.enable_mouse(base)
			
			-- health
			base.Health = core.util.gen_statusbar(base, raid_cfg.size[spec_role].w, raid_cfg.size[spec_role].h)
			base.Health.colorDisconnected = true
			base.Health.colorClass = true
			base.Health.colorReaction = true
			base.Health.PostUpdateColor = lib.invert_color
			lib.push_bar(base, base.Health)
			
			base.HealthPrediction = lib.gen_heal_bar(base.Health)

			-- power
			base.Power = core.util.gen_statusbar(base, raid_cfg.size[spec_role].w, raid_cfg.power.h)
			base.Power.colorPower = true
			base.Power.colorDisconnected = true
			lib.push_bar(base, base.Power)
	
			-- strings
			local role = core.util.gen_string(base.Health, 15, nil, core.media.fonts.role_symbols)
			role:SetPoint("BOTTOMRIGHT", -1, 1)
			base:Tag(role, '[focus:role]')

			local name_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "LEFT", "BOTTOM")
			name_string:SetPoint("BOTTOMLEFT", 1, 1)
			name_string:SetPoint("BOTTOMRIGHT", role, "BOTTOMLEFT", 2, 0)
			name_string:SetWordWrap(false)
			base:Tag(name_string, "[focus:color][name]")
			
			local hp_string = core.util.gen_string(base.Health, core.config.font_size_med, nil, core.media.fonts.gotham_ultra, "CENTER", "TOP")
			hp_string:SetPoint("TOPLEFT", name_string, "BOTTOMLEFT")
			hp_string:SetPoint("TOPRIGHT", name_string, "BOTTOMRIGHT")
			base:Tag(hp_string, "[focus:color][focus:hp:group]")
			
			-- auras
			base.Debuffs = lib.gen_auras(base, raid_cfg.size[spec_role].w, cfg.auras.detailed, "Debuffs")
			base.Debuffs:SetPoint("TOPRIGHT", base.Health, "TOPRIGHT", -1, -1)
			lib.apply_blacklist_to(base.Debuffs, cfg.debuff_blacklist)
			
			-- base.AuraWatch = lib.gen_indicators(base, raid_cfg.indicators)
			
			base.RaidTargetIndicator = base.Health:CreateTexture(nil, "OVERLAY")
			base.RaidTargetIndicator:SetSize(raid_cfg.mark.size, raid_cfg.mark.size)
			base.RaidTargetIndicator:SetPoint("TOPLEFT", 1, -1)

			lib.gen_ready_check(base)
			lib.gen_summon(base)
			
			base.Range = {
				insideAlpha = 1,
				outsideAlpha = cfg.range_alpha,
			}
		end
	end
end

oUF:Factory(function(self)

	if cfg.enabled.nameplates then
		oUF:RegisterStyle("FocusUnitsNameplate", create_nameplate_style)
		oUF:SpawnNamePlates("FocusUnits", function(nameplate, event, unit)
			local nameplate_cfg = cfg.frames.nameplate
			if event == "NAME_PLATE_UNIT_ADDED" then
				nameplate.blizz_plate = nameplate:GetParent().UnitFrame

				if UnitIsUnit(unit, "target") then
					if oUF_NamePlateDriver.target_nameplate then
						oUF_NamePlateDriver.target_nameplate:SetAlpha(nameplate_cfg.alpha.non_target)
					end
					oUF_NamePlateDriver.target_nameplate = nameplate
					nameplate:SetAlpha(nameplate_cfg.alpha.target)
				else
					nameplate:SetAlpha(nameplate_cfg.alpha.non_target)
				end

				nameplate.widgets = nameplate.blizz_plate.WidgetContainer
				if nameplate.widgets then
					nameplate.widgets:SetParent(nameplate)
					nameplate.widgets:ClearAllPoints()
					nameplate.widgets:SetPoint("BOTTOM", nameplate, "TOP", 0, 30)
					nameplate.widgets:SetScale(1.0 / PixelUtil.GetPixelToUIUnitFactor())
				end

				if UnitReaction(unit, 'player') > 4 then
					nameplate:DisableElement("Health")
					nameplate:DisableElement("Power")
					nameplate:DisableElement("Castbar")
					nameplate:DisableElement("Debuffs")
					nameplate:DisableElement("Buffs")
					nameplate.name_string:ClearAllPoints()
					nameplate.name_string:SetPoint("BOTTOM", 0, 20)
					nameplate.name_string:SetJustifyH("CENTER")
					nameplate.name_string:SetJustifyV("MIDDLE")
					nameplate.name_string:SetFont(core.media.fonts.gotham_ultra, core.config.font_size_lrg, "THINOUTLINE")
				else
					nameplate:EnableElement("Health")
					nameplate:EnableElement("Power")
					nameplate:EnableElement("Castbar")
					nameplate:EnableElement("Debuffs")
					nameplate:EnableElement("Buffs")
					nameplate.name_string:ClearAllPoints()
					nameplate.name_string:SetPoint("BOTTOMLEFT", nameplate.Health, "TOPLEFT", 1, 1)
					nameplate.name_string:SetJustifyH("LEFT")
					nameplate.name_string:SetJustifyV("BOTTOM")
					nameplate.name_string:SetFont(core.media.fonts.gotham_ultra, core.config.font_size_med, "THINOUTLINE")
				end
				
			elseif event == "NAME_PLATE_UNIT_REMOVED" then
				if nameplate.widgets then
					nameplate.widgets:SetParent(nameplate.blizz_plate)
					nameplate.widgets:ClearAllPoints()
					nameplate.widgets:SetPoint("TOP", nameplate.blizz_plate.castBar, "BOTTOM")
					nameplate.widgets:SetScale(1.0)
				end
				nameplate:SetAlpha(nameplate_cfg.alpha.non_target)
			elseif event == "PLAYER_TARGET_CHANGED" then
				if oUF_NamePlateDriver.target_nameplate then
					oUF_NamePlateDriver.target_nameplate:SetAlpha(nameplate_cfg.alpha.non_target)
				end
				if nameplate then
					nameplate:SetAlpha(nameplate_cfg.alpha.target)
				end
				oUF_NamePlateDriver.target_nameplate = nameplate
			end
		end)
	end

	if cfg.enabled.player then
		local mover = core.util.get_mover_frame("Player", cfg.frames.player.pos)

		oUF:RegisterStyle("FocusUnitsPlayer", create_player_style)
		oUF:SetActiveStyle("FocusUnitsPlayer")
		oUF:Spawn("player"):SetPoint("TOPRIGHT", mover)

		CastingBarFrame_SetUnit(CastingBarFrame)
		CastingBarFrame_SetUnit(PetCastingBarFrame)
	end

	if cfg.enabled.pet then
		oUF:RegisterStyle("FocusUnitsPet", create_pet_style)
		oUF:SetActiveStyle("FocusUnitsPet")
		oUF:Spawn("pet")
	end

	if cfg.enabled.target then
		local mover = core.util.get_mover_frame("Target", cfg.frames.target.pos)

		oUF:RegisterStyle("FocusUnitsTarget", create_target_style)
		oUF:SetActiveStyle("FocusUnitsTarget")
		oUF:Spawn("target"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.targettarget then
		oUF:RegisterStyle("FocusUnitsTargetTarget", create_targettarget_style)
		oUF:SetActiveStyle("FocusUnitsTargetTarget")
		oUF:Spawn("targettarget")
	end

	if cfg.enabled.focus then
		local mover = core.util.get_mover_frame("Focus", cfg.frames.focus.pos)

		oUF:RegisterStyle("FocusUnitsFocus", create_focus_style)
		oUF:SetActiveStyle("FocusUnitsFocus")
		oUF:Spawn("focus"):SetPoint("TOPLEFT", mover)
	end

	if cfg.enabled.boss then
		oUF:RegisterStyle("FocusUnitsBoss", create_boss_style)
		oUF:SetActiveStyle("FocusUnitsBoss")

		local boss = {}
		local mover = core.util.get_mover_frame("Boss", cfg.frames.boss.pos)

		for i = 1, 8 do
			boss[i] = oUF:Spawn("boss"..i, "oUF_FocusUnitsBoss"..i)

			if i == 1 then
				boss[i]:SetPoint("TOPLEFT", mover)
			else
				boss[i]:SetPoint("TOPRIGHT", boss[i - 1], "BOTTOMRIGHT", 0, -(20 + cfg.frames.boss.cast.h + 2 * core.config.font_size_med))
			end
		end

		core.settings:add_action("Test Boss", function()
			oUF_FocusUnitsBoss1.unit = "target"
			oUF_FocusUnitsBoss1.Hide = function() end
			oUF_FocusUnitsBoss1:Show()
		
			oUF_FocusUnitsBoss2.unit = "player"
			oUF_FocusUnitsBoss2.Hide = function() end
			oUF_FocusUnitsBoss2:Show()
			
			oUF_FocusUnitsBoss3.unit = "pet"
			oUF_FocusUnitsBoss3.Hide = function() end
			oUF_FocusUnitsBoss3:Show()
			
			oUF_FocusUnitsBoss4.unit = "player"
			oUF_FocusUnitsBoss4.Hide = function() end
			oUF_FocusUnitsBoss4:Show()
			
			oUF_FocusUnitsBoss5.unit = "player"
			oUF_FocusUnitsBoss5.Hide = function() end
			oUF_FocusUnitsBoss5:Show()

			oUF_FocusUnitsBoss6.unit = "mouseover"
			oUF_FocusUnitsBoss6.Hide = function() end
			oUF_FocusUnitsBoss6:Show()

			oUF_FocusUnitsBoss7.unit = "target"
			oUF_FocusUnitsBoss7.Hide = function() end
			oUF_FocusUnitsBoss7:Show()

			oUF_FocusUnitsBoss8.unit = "focus"
			oUF_FocusUnitsBoss8.Hide = function() end
			oUF_FocusUnitsBoss8:Show()
		end)
	end

	if cfg.enabled.party then

		local w = cfg.frames.party.size.w
		local h = cfg.frames.party.size.h + cfg.frames.party.power.h - 1
		local mover = core.util.get_mover_frame("Party", cfg.frames.party.pos)
		mover:SetSize(w, h * 5 - 4)

		oUF:RegisterStyle("FocusUnitsParty", create_party_style)
		oUF:SetActiveStyle("FocusUnitsParty")
   
		local party = oUF:SpawnHeader(
			"oUF_FocusUnitsParty", nil,	"custom [@raid1,exists] hide; [group:party,nogroup:raid] show; hide",
			"showPlayer", true,
			"showSolo", true,
			"showParty", true,
			"point", "BOTTOM",
			"yoffset", -1,
			"xoffset", 0,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		party:SetPoint("BOTTOMLEFT", mover)
	end

	if cfg.enabled.tank then

		local w = cfg.frames.tank.size.w
		local h = cfg.frames.tank.size.h + cfg.frames.tank.power.h - 1
		local mover = core.util.get_mover_frame("Tank", cfg.frames.tank.pos)
		mover:SetSize(w, h * 2 - 1)

		oUF:RegisterStyle("FocusUnitsTank", create_tank_style)
		oUF:SetActiveStyle("FocusUnitsTank")
		local tank = oUF:SpawnHeader("oUF_FocusUnitsTank", nil, "raid",
			"showRaid", true,
			"groupFilter", "MAINTANK",
			"yoffset", 1,
			"xoffset", 0,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		tank:SetPoint("TOPLEFT", mover)
	end
 
	if cfg.enabled.raid then

		local role
		if GetSpecializationRole(GetSpecialization()) == "HEALER" then
			role = "detailed"
		else
			role = "minimal"
		end

		local w = cfg.frames.raid.size[role].w
		local h = cfg.frames.raid.size[role].h + cfg.frames.raid.power.h - 1
		local mover_mythic = core.util.get_mover_frame("RaidMythic", cfg.frames.raid.pos)
		mover_mythic:SetSize(w * 5 - 4, h * 4 - 3)

		oUF:RegisterStyle("FocusUnitsMinimalRaid", create_raid_style(role))
		oUF:SetActiveStyle("FocusUnitsMinimalRaid")
   
		local raid_mythic = oUF:SpawnHeader("oUF_FocusUnitsRaidMythic", nil, "custom [@raid21,exists] hide; [@raid1,exists] show; hide",
			"showPlayer", true,
			"showSolo", true,
			"showRaid", true,
			"point", "LEFT",
			"yoffset", 0,
			"xoffset", -1,
			"columnSpacing", -1,
			"columnAnchorPoint", "TOP",
			"groupFilter", "1,2,3,4",
			"groupBy", "GROUP",
			"groupingOrder", "1,2,3,4",
			"sortMethod", "INDEX",
			"maxColumns", 4,
			"unitsPerColumn", 5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		raid_mythic:SetPoint("TOPLEFT", mover_mythic)

		w = cfg.frames.raid.size[role].w
		h = cfg.frames.raid.size[role].h + cfg.frames.raid.power.h - 1
		local mover_full = core.util.get_mover_frame("RaidFull", cfg.frames.raid.pos)
		mover_full:SetSize(w * 5 - 4, h * 8 - 7)

		oUF:RegisterStyle("FocusUnitsDetailedRaid", create_raid_style(role))
		oUF:SetActiveStyle("FocusUnitsDetailedRaid")

		local raid_full = oUF:SpawnHeader("oUF_FocusUnitsRaidFull", nil, "custom [@raid21,exists] show; hide",
			"showPlayer", true,
			"showSolo", true,
			"showRaid", true,
			"point", "LEFT",
			"yoffset", 0,
			"xoffset", -1,
			"columnSpacing", -1,
			"columnAnchorPoint", "TOP",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"sortMethod", "INDEX",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(w, h)
		)
		raid_full:SetPoint("TOPLEFT", mover_full)
	end
end)
