local _, addon = ...
if not addon.buffs.enabled then return end
local core = addon.core

local BuffFrame = BuffFrame
local UnitAura = UnitAura
local GameTooltip = GameTooltip
local Minimap = Minimap
local UnitName = UnitName

local cfg = {
	row_spacing = 10,
	col_spacing = 8,
	per_row = 12,
	size = 44,
	duration_pos = {"BOTTOM", 0, -4},
	count_pos = {"TOPRIGHT", 4, 4}
}

local style_buff = function(button)
	
	button:SetSize(cfg.size, cfg.size)

	local name = button:GetParent():GetParent():GetName()
	local is_debuff = string.match(name, "Debuff")

	-- AuraButtonTemplate
	--   Layers
	--     BACKGROUND
	local icon = button.Icon -- $parentIcon
	local count = button.count -- $parentCount
	local duration = button.duration -- $parentDuration

	-- DebuffButtonTemplate
	--   Layers
	--     OVERLAY
	local border = button.Border or button.bg -- $parentBorder
	--local symbol = button.symbol

	-- TempEnchantButtonTemplate
	--   Layers
	--     OVERLAY
	--local border = button.Border -- $parentBorder

	-----------------------------

	icon:SetTexCoord(.1, .9, .1, .9)
	core.util.set_inside(icon, button)
	icon:SetDrawLayer("BACKGROUND", -7)
	button.icon = icon

	if not border then
		border = button:CreateTexture()
		button.bg = border
	end
	border:SetTexture(core.media.textures.blank)
	border:SetTexCoord(0, 1, 0, 1)
	border:SetDrawLayer("BACKGROUND", -8)
	border:SetAllPoints(button)

	if not is_debuff then
		border:SetVertexColor(unpack(core.config.frame_border))
	end

	core.util.fix_string(duration)
	duration:ClearAllPoints()
	duration:SetPoint(unpack(cfg.duration_pos))

	if count then
		core.util.fix_string(count)
		count:ClearAllPoints()
		count:SetPoint(unpack(cfg.count_pos))
	end
end

local update_debuffs = function(name, index)
	local buff_rows = math.ceil((BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants) / cfg.per_row);
	local button = BuffFrame[name][index]

	style_buff(button)
	button:ClearAllPoints()
	if index % cfg.per_row == 1 then
		button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, (buff_rows + math.floor(index / cfg.per_row)) * -(cfg.size + cfg.row_spacing) + -cfg.row_spacing)
	elseif index % cfg.per_row == 0 then
		button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", (cfg.per_row - 1) * -(cfg.size + cfg.col_spacing), (buff_rows + math.floor(index / cfg.per_row) - 1) * -(cfg.size + cfg.row_spacing) + -cfg.row_spacing)
	else
		button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", (index % cfg.per_row - 1) * -(cfg.size + cfg.col_spacing), (buff_rows + math.floor(index / cfg.per_row)) * -(cfg.size + cfg.row_spacing) + -cfg.row_spacing)
	end
end

local update_buffs = function()
	local num_buffs = BuffFrame.numEnchants
	local num_rows = (num_buffs > 0 and 1) or 0

	for index = 1, BUFF_ACTUAL_DISPLAY do
		local button = BuffFrame.BuffButton[index]
		style_buff(button)
		button:ClearAllPoints()
		if num_buffs == 0 then
			button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
			num_buffs = 1
			num_rows = 1
		elseif num_buffs == cfg.per_row then
			button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, num_rows * -(cfg.size + cfg.row_spacing))
			num_buffs = 1
			num_rows = num_rows + 1
		else
			button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", num_buffs * -(cfg.size + cfg.col_spacing), (num_rows - 1) * -(cfg.size + cfg.row_spacing))
			num_buffs = num_buffs + 1
		end
	end
end

local update_enchants = function()
	local num_buffs = 0
	local num_rows = 0

	for index = 1, BuffFrame.numEnchants do
		local button = TemporaryEnchantFrame.TempEnchant[index]
		style_buff(button)
		button:ClearAllPoints()
		if num_buffs == 0 then
			button:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
			num_buffs = 1
			num_rows = 1
		elseif num_buffs == cfg.per_row then
			button:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, num_rows * -(cfg.size + cfg.row_spacing))
			num_buffs = 1
			num_rows = num_rows + 1
		else
			button:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", num_buffs * -(cfg.size + cfg.col_spacing), (num_rows - 1) * -(cfg.size + cfg.row_spacing))
			num_buffs = num_buffs + 1
		end
	end
end

-- BuffFrame:SetPoint in UIParent_UpdateTopFramePositions()
-- BuffFrame.alt_SetPoint = BuffFrame.SetPoint
-- hooksecurefunc(BuffFrame, "SetPoint", function(self)
-- 	self:alt_SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -20, 0)
-- end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	local name = caster and UnitName(caster)
	if name then
		self:AddLine(" ")
		self:AddDoubleLine(name, id, .3, 1, .3, 1, .3, .3)
		self:Show()
	end
end)

-- hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", update_buffs)
-- hooksecurefunc("DebuffButton_UpdateAnchors", update_debuffs)
-- hooksecurefunc("TemporaryEnchantFrame_Update", update_enchants)

hooksecurefunc(BuffFrame, "UpdateGridLayout", function()
	for _, aura in ipairs(BuffFrame.auraFrames) do
		style_buff(aura)
	end
end)

hooksecurefunc(DebuffFrame, "UpdateGridLayout", function()
	for _, aura in ipairs(DebuffFrame.auraFrames) do
		style_buff(aura)
	end
end)
