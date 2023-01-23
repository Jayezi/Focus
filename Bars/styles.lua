local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core
local cfg = addon.bars.cfg

local styles = {}
addon.bars.styles = styles

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local CharacterMicroButton = CharacterMicroButton
local MicroButtonPortrait = MicroButtonPortrait
local Mixin = Mixin
local BackdropTemplateMixin = BackdropTemplateMixin

styles.actionbutton = function(button, bar_cfg)
	if button.styled then return end
	button.styled = true

	local blank = core.media.textures.blank
	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))

	local name = button:GetName()

	-- ActionButtonTemplate (ActionButton, PetActionButtonTemplate, StanceButtonTemplate, PossessButtonTemplate)
	--   Layers
	--     BACKGROUND
	local icon = button.icon -- $parentIcon
	local mask = button.IconMask
	local slotbg = button.SlotBackground
	local slotart = button.SlotArt

	--     ARTWORK 1
	local flash = button.Flash -- $parentFlash
	local fobs = button.FlyoutBorderShadow -- $parentFlyoutBorderShadow
	--     ARTWORK 2
	--local foa  = button.FlyoutArrow -- $parentFlyoutArrow
	local hotkey = button.HotKey -- $parentHotKey
	local count = button.Count -- $parentCount
	--     OVERLAY
	local macro = button.Name -- $parentName
	local border = button.Border -- $parentBorder
	--     OVERLAY 1
	local new = button.NewActionTexture
	local spellhighlight = button.SpellHighlightTexture
	local auto = button.AutoCastable
	--local levellock = button.LevelLinkLockIcon
	--   Frames
	local flyout = button.FlyoutArrowContainer
	local shine = button.AutoCastShine -- $parentShine
	local cooldown = button.cooldown -- $parentCooldown
	--   NormalTexture
	--local normal = button.NormalTexture -- $parentNormalTexture
	--   PushedTexture
	--   HighlightTexture
	--   CheckedTexture
	----------------------------------
	-- MultiBarButtonTemplate
	--   Layers
	--     BACKGROUND 1
	local fbg = _G[name.."FloatingBG"]
	----------------------------------
	-- PetActionButtonTemplate
	--   Layers
	--     OVERLAY
	local petauto = _G[name.."AutoCastable"]
	--local spellhighlight = button.SpellHighlightTexture
	--   Frames
	--local shine = _G[name.."Shine"]
	--   NormalTexture
	--local normal2 = _G[name.."NormalTexture2"]
	----------------------------------
	-- StanceButtonTemplate
	--   NormalTexture
	--local normal2 = _G[name.."NormalTexture2"]

	----------------------------

	-- Frames

	cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
	cooldown:SetAllPoints(icon)
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	core.util.fix_string(cooldown:GetRegions(), bar_cfg and bar_cfg.cooldown_size or core.config.font_size_lrg)

	shine:SetFrameLevel(cooldown:GetFrameLevel() + 1)
	shine:SetAllPoints(icon)

	-- parent text regions to a higher frame so cooldown and highlights dont cover them
	local text_overlay = CreateFrame("Frame", button:GetName().."TextOverlay", button)
	text_overlay:SetFrameLevel(shine:GetFrameLevel() + 1)
	text_overlay:SetAllPoints(button)

	-- Layers

	-- BACKGROUND

	local adjust = 0.4 * button:GetHeight() / button:GetWidth()
	icon:SetTexCoord(0.1, 0.9, 0.5 - adjust, 0.5 + adjust)
	icon:SetDrawLayer("ARTWORK", -7)
	core.util.set_inside(icon, button)

	mask:Hide()
	slotbg:Hide()
	slotart:Hide()

	-- BACKGROUND 1

	if fbg then fbg:Hide() end

	-- ARTWORK 1

	flash:SetTexture(blank)
	flash:SetVertexColor(unpack(core.config.color.flash))
	flash:SetAllPoints(icon)

	fobs:SetTexture()

	-- ARTWORK 2

	core.util.fix_string(hotkey, core.config.font_size_med)
	hotkey:SetParent(text_overlay)
	hotkey:ClearAllPoints()
	hotkey:SetPoint("BOTTOMLEFT")
	hotkey:SetPoint("BOTTOMRIGHT")
	hotkey:SetJustifyH("RIGHT")
	hotkey:SetJustifyV("BOTTOM")

	core.util.fix_string(count, core.config.font_size_lrg)
	count:SetParent(text_overlay)
	count:ClearAllPoints()
	count:SetPoint("TOPLEFT", icon, "TOPLEFT", -4, 6)
	count:SetJustifyH("LEFT")
	count:SetJustifyV("TOP")

	-- OVERLAY

	macro:Hide()

	border:SetTexture(blank)
	border:SetAllPoints(button)
	border:SetDrawLayer("BORDER")

	if petauto then
		petauto:SetParent(text_overlay)
		petauto:SetDrawLayer("BACKGROUND")
		petauto:SetAllPoints()
		petauto:SetTexCoord(.22, .76, .22, .77)
	end

	-- OVERLAY 1

	new:SetAllPoints(icon)
	new:SetTexture(blank)
	new:SetVertexColor(unpack(core.config.color.new))

	spellhighlight:SetAllPoints(icon)
	spellhighlight:SetTexture(blank)
	spellhighlight:SetVertexColor(unpack(core.config.color.highlight))

	auto:SetParent(text_overlay)
	auto:SetDrawLayer("BACKGROUND")
	auto:SetAllPoints()
	auto:SetTexCoord(.22, .76, .22, .77)

	-------------------------

	local normal = button:GetNormalTexture()
	normal:SetAllPoints(icon)
	normal:SetTexture()

	-- pet thing
	hooksecurefunc(button, "SetNormalTexture", function()
		normal:SetTexture()
	end)

	local pushed = button:GetPushedTexture()
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(core.config.color.pushed))
	pushed:SetDrawLayer("ARTWORK", -6)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(core.config.color.highlight))

	local checked = button:GetCheckedTexture()
	checked:SetAllPoints(icon)
	checked:SetTexture(blank)
	checked:SetVertexColor(unpack(core.config.color.checked))
	checked.alt_SetAlpha = checked.SetAlpha
	hooksecurefunc(checked, "SetAlpha", function(self)
		self:alt_SetAlpha(core.config.color.checked[4])
	end)

	hooksecurefunc(button, "UpdateButtonArt", function()
		slotbg:Hide()
		slotart:Hide()

		local normal = button:GetNormalTexture()
		normal:SetAllPoints(icon)
		normal:SetTexture()

		local pushed = button:GetPushedTexture()
		pushed:SetAllPoints(icon)
		pushed:SetTexture(blank)
		pushed:SetVertexColor(unpack(core.config.color.pushed))
		pushed:SetDrawLayer("ARTWORK", -6)
	end)

	if button.UpdateHotkeys then
		hooksecurefunc(button, "UpdateHotkeys", function(self)
			self.HotKey:ClearAllPoints()
			self.HotKey:SetPoint("BOTTOMLEFT")
			self.HotKey:SetPoint("BOTTOMRIGHT")
		end)
	end
end

styles.vehiclebutton = function(button)

	core.util.gen_backdrop(button)

	local blank = core.media.textures.blank

	local pushed = button:GetPushedTexture()
	core.util.set_inside(pushed, button)
	pushed:SetTexCoord(.2, .8, .2, .8)

	local normal = button:GetNormalTexture()
	core.util.set_inside(normal, button)
	normal:SetTexCoord(.2, .8, .2, .8)

	local highlight = button:GetHighlightTexture()
	core.util.set_inside(highlight, button)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(core.config.color.highlight))
end

styles.bagbutton = function(button)
	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))

	-- ItemButton
	--	BORDER
	local icon = button.icon -- $parentIconTexture
	--	ARTWORK 2
	local count = button.Count -- $parentCount
	-- local stock = button.Stock
	--	OVERLAY
	local border = button.IconBorder
	--	OVERLAY 1
	-- local overlay = button.IconOverlay -- Azerite/Corruption
	--	OVERLAY 2
	-- local overlay = button.IconOverlay2
	--	OVERLAY 4
	-- local search = button.searchOverlay -- $parentSearchOverlay
	--	OVERLAY 5
	-- local context = button.ItemContextOverla

	local normal = button.NormalTexture -- $parentNormalTexture
	local pushed = button:GetPushedTexture()
	local highlight = button:GetHighlightTexture()

	-- CircularItemButtonTemplate
	--	BORDER
	local mask = button.CircleMask

	-- BaseBagSlotButtonTemplate
	--	OVERLAY
	-- local anim = button.AnimIcon
	local slotHighlight = button.SlotHighlightTexture

	-------------------------------

	-- Layers

	-- BORDER

	icon:SetDrawLayer("ARTWORK", -7)
	icon:SetTexture("Interface/Icons/Inv_misc_bag_08")
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	core.util.set_inside(icon, button)

	mask:Hide()

	-- ARTWORK 2

	count:ClearAllPoints()
	count:SetPoint("BOTTOM", 0, -3)
	core.util.fix_string(count)

	-- OVERLAY

	slotHighlight:SetAllPoints(icon)
	slotHighlight:SetColorTexture(unpack(core.config.color.checked))

	normal:SetTexture()

	pushed:SetAllPoints(icon)
	pushed:SetColorTexture(unpack(core.config.color.pushed))
	pushed:SetDrawLayer("ARTWORK", -6)

	highlight:SetAllPoints(icon)
	highlight:SetColorTexture(unpack(core.config.color.highlight))

	hooksecurefunc(button, "UpdateTextures", function(self)
		local normal = self.NormalTexture
		normal:SetTexture()

		local pushed = self:GetPushedTexture()
		pushed:SetAllPoints(self.icon)
		pushed:SetColorTexture(unpack(core.config.color.pushed))

		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(unpack(core.config.color.highlight))

		self.SlotHighlightTexture:SetColorTexture(unpack(core.config.color.checked))
	end)
end

styles.microbutton = function(button)

	-- 19 x 26
	-- MainMenuBarMicroButton
	--   Layers
	--     OVERLAY
	local flash = button.FlashBorder
	--   NormalTexture
	--   HighlightTexture
	--   PushedTexture
	--   DisabledTexture
	
	local flashContent = button.FlashContent

	local inset = 3

	flash:SetColorTexture(unpack(core.config.color.flash))
	core.util.set_inside(flash, button, inset)

	flashContent:SetTexCoord(.1, .85, .1, .9)
	flashContent:ClearAllPoints()
	flashContent:SetPoint("TOPLEFT", flash, "TOPLEFT", 0, -4)
	flashContent:SetPoint("BOTTOMRIGHT", flash, "BOTTOMRIGHT")

	local normal = button:GetNormalTexture()
	normal:SetTexCoord(.1, .85, .1, .9)
	normal:ClearAllPoints()
	normal:SetPoint("TOPLEFT", flash, "TOPLEFT", 0, -4)
	normal:SetPoint("BOTTOMRIGHT", flash, "BOTTOMRIGHT")

	local pushed = button:GetPushedTexture()
	pushed:SetTexCoord(.1, .85, .1, .9)
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", flash, "TOPLEFT", 0, -4)
	pushed:SetPoint("BOTTOMRIGHT", flash, "BOTTOMRIGHT")

	local highlight = button:GetHighlightTexture()
	highlight:SetColorTexture(unpack(core.config.color.highlight))
	highlight:SetAllPoints(flash)

	local disabled = button:GetDisabledTexture()
	disabled:SetTexCoord(.1, .85, .1, .9)
	disabled:ClearAllPoints()
	disabled:SetPoint("TOPLEFT", flash, "TOPLEFT", 0, -4)
	disabled:SetPoint("BOTTOMRIGHT", flash, "BOTTOMRIGHT")

	if button:GetName() == "MainMenuMicroButton" then
		hooksecurefunc(button, "SetNormalAtlas", function(self)
			local normal = self:GetNormalTexture()
			normal:SetTexCoord(.1, .85, .1, .9)
		end)

		hooksecurefunc(button, "SetPushedAtlas", function(self)
			local pushed = self:GetPushedTexture()
			pushed:SetTexCoord(.1, .85, .1, .9)
		end)

		hooksecurefunc(button, "SetDisabledAtlas", function(self)
			local disabled = self:GetDisabledTexture()
			disabled:SetTexCoord(.1, .85, .1, .9)
		end)

		hooksecurefunc(button, "SetHighlightAtlas", function(self)
			local highlight = self:GetHighlightTexture()
			highlight:SetColorTexture(unpack(core.config.color.highlight))
		end)

		button.MainMenuBarPerformanceBar:ClearAllPoints()
		button.MainMenuBarPerformanceBar:SetPoint("TOPLEFT", flash, "BOTTOMLEFT", -1, -1)
		button.MainMenuBarPerformanceBar:SetPoint("TOPRIGHT", flash, "BOTTOMRIGHT", 1, -1)
		button.MainMenuBarPerformanceBar:SetHeight(3)
		button.MainMenuBarPerformanceBar:SetTexture(core.media.textures.blank)
	end

	local backdrop = {
		bgFile = core.media.textures.blank,
		tile = false,
		tileSize = 0,
		insets = {
			left = inset - 1,
			right = inset - 1,
			top = inset - 1,
			bottom = inset - 1
		}
	}

	if not button.SetBackdrop then
		Mixin(button, BackdropTemplateMixin)
	end
	button:SetBackdrop(backdrop)
	button:SetBackdropColor(unpack(core.config.frame_border))

	button:SetSize(24, 33)
end
