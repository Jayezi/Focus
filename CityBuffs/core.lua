local addon, ns = ...
local cfg = ns.cfg
local cui = CityUi

-- taint spam :(
-- HOUR_ONELETTER_ABBR = "%dh"
-- DAY_ONELETTER_ABBR = "%dd"
-- MINUTE_ONELETTER_ABBR = "%dm"
-- SECOND_ONELETTER_ABBR = "%ds"

local style_button = function(button)
	if not button or (button and button.styled) then return end

	local name = button:GetName()
	
	local debuff = string.match(name, "Debuff")

	button:SetSize(cfg.button_size, cfg.button_size)

	local icon = _G[name.."Icon"]
	icon:SetTexCoord(.1, .9, .1, .9)
	cui.util.set_inside(icon, button)
	icon:SetDrawLayer("BACKGROUND", -7)
	button.icon = icon

	local border = _G[name.."Border"] or button:CreateTexture(name.."Border", "BACKGROUND", nil, -8)
	border:SetTexture(cui.media.textures.blank)
	border:SetTexCoord(0, 1, 0, 1)
	border:SetDrawLayer("BACKGROUND", -8)
	
	if not debuff then
		border:SetVertexColor(unpack(cui.config.frame_border))
	end
	
	border:ClearAllPoints()
	border:SetAllPoints(button)
	button.border = border

	cui.util.fix_string(button.duration, cui.config.font_size_med)
	button.duration:ClearAllPoints()
	button.duration:SetPoint(unpack(cfg.duration_pos))

	button.count:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
	button.count:ClearAllPoints()
	button.count:SetPoint(unpack(cfg.count_pos))

	button.styled = true
end

local update_debuffs = function(name, index)

	local button = _G[name..index]
	
	if not button then return end
	if not button.styled then style_button(button) end
	
	button:ClearAllPoints()
	if index == 1 then
		button:SetPoint("TOPRIGHT", BuffFrame, "BOTTOMRIGHT", 0, -cfg.row_gap * 2)
	elseif index > 1 and mod(index, cfg.buttons_per_row) == 1 then
		button:SetPoint("TOPRIGHT", _G[name..(index - cfg.buttons_per_row)], "BOTTOMRIGHT", 0, -cfg.row_gap)
	else
		button:SetPoint("TOPRIGHT", _G[name..(index - 1)], "TOPLEFT", -cfg.col_gap, 0)
	end
end

local update_buffs = function()

	local name = "BuffButton"
	local num_buffs = BUFF_ACTUAL_DISPLAY
	local prev, above

	local buff_count = 0
	for index = 1, num_buffs do
		local button = _G[name..index]
		if not button then return end
		if not button.consolidated then
			buff_count = buff_count + 1
			
			if not button.styled then style_button(button) end
			button:ClearAllPoints()
			if index == 1 then
				button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
				above = button
			elseif index > 1 and mod(index, cfg.buttons_per_row) == 1 then
				button:SetPoint("TOPRIGHT", above, "BOTTOMRIGHT", 0, -cfg.row_gap)
				above = button
			else
				button:SetPoint("TOPRIGHT", prev, "TOPLEFT", -cfg.col_gap, 0)
			end
			prev = button
		end
	end

	local height = (cfg.button_size + cfg.row_gap) * ceil(buff_count / cfg.buttons_per_row) - cfg.row_gap
	local width = (cfg.button_size + cfg.col_gap) * min(cfg.buttons_per_row, num_buffs) - cfg.col_gap
	BuffFrame:SetSize(width, height)
end

local buffs_setpoint = BuffFrame.SetPoint
hooksecurefunc(BuffFrame, "SetPoint", function(self)
	self:ClearAllPoints()
	buffs_setpoint(self, "TOPRIGHT", Minimap, "TOPLEFT", -20, 0)
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	
	local name = caster and UnitName(caster)
	if name then
		self:AddLine(" ")
		self:AddDoubleLine(name, id, .3, 1, .3, 1, .3, .3)
		self:Show()
	end
end)

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", update_buffs)
hooksecurefunc("DebuffButton_UpdateAnchors", update_debuffs)
