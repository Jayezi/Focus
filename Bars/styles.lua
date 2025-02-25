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
local ActionButtonCastType = {
	Cast = 1, 
	Channel = 2, 
	Empowered = 3, 
}

local blank = core.media.textures.blank
local blank2 = core.media.textures.blank2
local setInside = core.util.set_inside

styles.ActionButtonInterruptTemplate = function(frame)
	
	-- Frames

	local highlight = frame.Highlight
	-- >> Layers
	-- >> ARTWORK
	local highlightHighlightTexture = highlight.HighlightTexture
	local highlightMask = highlight.Mask
	-- >> Animations
	local highlightAnimIn = highlight.AnimIn

	local base = frame.Base
	-- >> Layers
	-- >> ARTWORK
	local baseBase = base.Base
	-- >> Animations
	local baseAnimIn = base.AnimIn

	highlight:SetAllPoints()

	highlightHighlightTexture:SetColorTexture(1, 0, 0, 0.25)
	highlightHighlightTexture:SetAllPoints()

	highlightMask:SetTexture(blank2, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	setInside(highlightMask, highlight)

	setInside(base, frame)
	baseBase:SetAllPoints()
	baseBase:SetColorTexture(1, 0, 0, 0.25)
end

styles.ActionButtonCastingAnimFrameTemplate = function(frame)

	-- Frames

	local fill = frame.Fill
	-- >> Layers
	-- >> ARTWORK
	local fillInnerGlowTexture = fill.InnerGlowTexture
	local fillCastFill = fill.CastFill
	local fillFillMask = fill.FillMask -- CastFill
	-- >> Animations
	local fillCastingAnim = fill.CastingAnim

	local endBurst = frame.EndBurst
	-- >> Layers
	-- >> ARTWORK
	local endBurstGlowRing = endBurst.GlowRing
	local endBurstEndMask = endBurst.EndMask
	-- >> Animations
	local endBurstFinishCastAnim = endBurst.FinishCastAnim

	fill:SetAllPoints()

	fillInnerGlowTexture:SetAllPoints()
	fillInnerGlowTexture:Hide()

	setInside(fillFillMask, fill)
    fillFillMask:SetTexture(core.media.textures.blank2, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

	hooksecurefunc(frame, "Setup", function(self, actionButtonCastType)
		local isChannelCast = actionButtonCastType == ActionButtonCastType.Channel
		fillInnerGlowTexture:SetColorTexture(1, 1, 1, 1)
		fillCastFill:SetColorTexture(1, 1, 1, 0.5)
		fillCastFill:ClearAllPoints()
		fillCastFill:SetSize(fill:GetWidth(), fill:GetHeight())
		if isChannelCast then
			fillCastFill:SetPoint("BOTTOMLEFT", fill, "BOTTOMRIGHT")
			fillCastingAnim.CastFillTranslation:SetOffset(-fill:GetWidth(), 0)
		else
			fillCastFill:SetPoint("BOTTOMRIGHT", fill, "BOTTOMLEFT")
			fillCastingAnim.CastFillTranslation:SetOffset(fill:GetWidth(), 0)
		end
	end)

	endBurst:SetAllPoints()

	endBurstGlowRing:SetAllPoints()
	endBurstGlowRing:SetColorTexture(0, 1, 0, 0.25)

	setInside(endBurstEndMask, endBurst)
	endBurstEndMask:SetTexture(blank2, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
end

styles.ActionButtonTargetReticleFrameTemplate = function(frame)
	
	-- Layers

	-- OVERLAY 2
	local base = frame.Base
	-- OVERLAY 3
	local highlight = frame.Highlight
	local mask = frame.Mask -- Highlight

	-- Animations

	local highlightAnim = frame.HighlightAnim -- Highlight

	base:SetAllPoints()

	highlight:SetAllPoints()
	highlight:Hide()
	mask:SetAllPoints()
	mask:Hide()
end

styles.ActionButtonCooldownFlashTemplate = function(frame)
	
	-- Layers

	-- ARTWORK
	local flipbook = frame.Flipbook

	-- Animations

	local flashAnim = frame.FlashAnim -- Flipbook

	flipbook:SetAllPoints()
end

styles.ActionButtonSpellFXTemplate = function(button)
	if button.styled.ActionButtonSpellFXTemplate then return end
	button.styled.ActionButtonSpellFXTemplate = true

	-- Frames

	local interruptDisplay = button.InterruptDisplay -- (ActionButtonInterruptTemplate)
	local spellCastAnimFrame = button.SpellCastAnimFrame -- (ActionButtonCastingAnimFrameTemplate)
	local targetReticleAnimFrame = button.TargetReticleAnimFrame -- (ActionButtonTargetReticleFrameTemplate)
	local cooldownFlash = button.CooldownFlash

	spellCastAnimFrame:SetAllPoints()
	styles.ActionButtonCastingAnimFrameTemplate(spellCastAnimFrame)

	interruptDisplay:SetAllPoints()
	styles.ActionButtonInterruptTemplate(interruptDisplay)

	targetReticleAnimFrame:SetAllPoints()
	styles.ActionButtonTargetReticleFrameTemplate(targetReticleAnimFrame)

	cooldownFlash:SetAllPoints()
	styles.ActionButtonCooldownFlashTemplate(cooldownFlash)
end

styles.AutoCastOverlayTemplate = function(frame)

	-- Layers

	-- OVERLAY 0
	local shine = frame.Shine
	local shineAnim = shine.Anim
	local mask = frame.Mask -- Shine
	-- OVERLAY 1
	local corners = frame.Corners

	shine:ClearAllPoints()
	shine:SetPoint("CENTER")
	shine:SetSize(frame:GetWidth(), frame:GetWidth())

	mask:SetAllPoints()

	-- corners:SetTexCoord(0, 1, 0, 1)
	corners:SetPoint("TOPLEFT", -1, 1)
	corners:SetPoint("BOTTOMRIGHT", 1, -1)
end

styles.CooldownFrameTemplate = function(frame)
	core.util.fix_string(frame:GetRegions(), bar_cfg and bar_cfg.cooldown_size or core.config.font_size_lrg)
end

styles.ActionButtonTemplate = function(button, bar_cfg)
	if button.styled.ActionButtonTemplate then return end
	button.styled.ActionButtonTemplate = true

	-- Layers

	local normalTexture = button.NormalTexture
	local pushedTexture = button.PushedTexture
	local highlightTexture = button.HighlightTexture
	local checkedTexture = button.CheckedTexture

	-- BACKGROUND
	local icon = button.icon -- $parentIcon
	local iconMask = button.IconMask -- icon
	local slotBackground = button.SlotBackground
	local slotArt = button.SlotArt

	-- ARTWORK 1
	local flash = button.Flash -- $parentFlash
	local flyoutBorderShadow = button.FlyoutBorderShadow -- $parentFlyoutBorderShadow

	-- OVERLAY
	local name = button.Name -- $parentName
	local border = button.Border -- $parentBorder

	-- OVERLAY 1
	local newActionTexture = button.NewActionTexture
	local spellHighlightTexture = button.SpellHighlightTexture
	local levelLinkLockIcon = button.LevelLinkLockIcon

	-- Animations

	local spellHighlightAnim = button.SpellHighlightAnim

	-- Frames

	local textOverlayContainer = button.TextOverlayContainer -- frameLevel=500
	-- >> Layers
	-- >> OVERLAY
	local textOverlayContainerHotKey = textOverlayContainer.HotKey -- $parentHotKey
	local textOverlayContainerCount = textOverlayContainer.Count -- $parentCount

	local flyoutArrowContainer = button.FlyoutArrowContainer
	-- >> Layers
	-- >> ARTWORK 2
	local flyoutArrowContainerFlyoutArrowNormal = flyoutArrowContainer.FlyoutArrowNormal
	local flyoutArrowContainerFlyoutArrowPushed = flyoutArrowContainer.FlyoutArrowPushed
	local flyoutArrowContainerFlyoutArrowHighlight = flyoutArrowContainer.FlyoutArrowHighlight

	local autoCastOverlay = button.AutoCastOverlay -- (AutoCastOverlayTemplate)

	local cooldown = button.cooldown -- $parentCooldown (CooldownFrameTemplate) useParentLevel

	setInside(cooldown, button)
	styles.CooldownFrameTemplate(cooldown)

	--autoCastOverlay:SetFrameLevel(cooldown:GetFrameLevel() + 1)
	autoCastOverlay:SetAllPoints()
	styles.AutoCastOverlayTemplate(autoCastOverlay)

	local adjust = 0.4 * button:GetHeight() / button:GetWidth()
	icon:SetTexCoord(0.1, 0.9, 0.5 - adjust, 0.5 + adjust)
	icon:SetDrawLayer("ARTWORK", -7)
	setInside(icon, button)

	iconMask:Hide()
	slotBackground:Hide()
	slotArt:Hide()

	flash:SetTexture(blank)
	flash:SetVertexColor(unpack(core.config.color.flash))
	flash:SetAllPoints(icon)

	flyoutBorderShadow:SetTexture()

	core.util.fix_string(textOverlayContainerHotKey, core.config.font_size_med)
	textOverlayContainerHotKey:ClearAllPoints()
	textOverlayContainerHotKey:SetPoint("BOTTOMRIGHT")
	hooksecurefunc(button, "UpdateHotkeys", function(button)
		button.HotKey:ClearAllPoints()
		button.HotKey:SetPoint("BOTTOMRIGHT")
	end)


	core.util.fix_string(textOverlayContainerCount, core.config.font_size_lrg)
	textOverlayContainerCount:ClearAllPoints()
	textOverlayContainerCount:SetPoint("TOPLEFT")
	textOverlayContainerCount:SetJustifyH("LEFT")

	name:Hide()

	border:SetTexture(blank)
	border:SetAllPoints()
	border:SetDrawLayer("BORDER")

	newActionTexture:SetAllPoints(icon)
	newActionTexture:SetTexture(blank)
	newActionTexture:SetVertexColor(unpack(core.config.color.new))

	spellHighlightTexture:SetAllPoints(icon)
	spellHighlightTexture:SetTexture(blank)
	spellHighlightTexture:SetVertexColor(unpack(core.config.color.highlight))

	normalTexture:SetAllPoints(icon)
	normalTexture:SetTexture()

	pushedTexture:SetAllPoints(icon)
	pushedTexture:SetTexture(blank)
	pushedTexture:SetVertexColor(unpack(core.config.color.pushed))
	--pushedTexture:SetDrawLayer("ARTWORK", -6)

	highlightTexture:SetAllPoints(icon)
	highlightTexture:SetTexture(blank)
	highlightTexture:SetVertexColor(unpack(core.config.color.highlight))

	checkedTexture:SetAllPoints(icon)
	checkedTexture:SetTexture(blank)
	checkedTexture:SetVertexColor(unpack(core.config.color.checked))
	-- checked.alt_SetAlpha = checked.SetAlpha
	-- hooksecurefunc(checked, "SetAlpha", function(self)
	-- 	self:alt_SetAlpha(core.config.color.checked[4])
	-- end)

	styles.ActionButtonSpellFXTemplate(button)
end

styles.QuickKeybindButtonTemplate = function(button)
	if button.styled.QuickKeybindButtonTemplate then return end
	button.styled.QuickKeybindButtonTemplate = true

	-- Layers

	-- OVERLAY
	local quickKeybindHighlightTexture = button.QuickKeybindHighlightTexture

	setInside(quickKeybindHighlightTexture, button)
	quickKeybindHighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
end

styles.ActionBarButtonCodeTemplate = function(button)
	if button.styled.ActionBarButtonCodeTemplate then return end
	button.styled.ActionBarButtonCodeTemplate = true

	styles.QuickKeybindButtonTemplate(button)
	styles.ActionButtonSpellFXTemplate(button)


end


styles.ActionBarButtonTemplate = function(button, bar_cfg)
	if button.styled.ActionBarButtonTemplate then return end
	button.styled.ActionBarButtonTemplate = true

	styles.ActionButtonTemplate(button, bar_cfg)
	styles.ActionBarButtonCodeTemplate(button)
end

styles.ActionBarButtonSpellActivationAlert = function(frame)
	frame.ProcStartFlipbook:SetSize(frame:GetWidth() * 2.5, frame:GetHeight() * 2.5)
end

local dummy = function()
	-- ActionButtonTemplate
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
	local autocast = button.AutoCastOverlay
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





	-- parent text regions to a higher frame so cooldown and highlights dont cover them
	local text_overlay = CreateFrame("Frame", button:GetName().."TextOverlay", button)
	text_overlay:SetFrameLevel(autocast:GetFrameLevel() + 1)
	text_overlay:SetAllPoints(button)

	-- Layers


	-- BACKGROUND 1

	if fbg then fbg:Hide() end

	-- ARTWORK 2



	-- OVERLAY

	

	if petauto then
		petauto:SetParent(text_overlay)
		petauto:SetDrawLayer("BACKGROUND")
		petauto:SetAllPoints()
		petauto:SetTexCoord(.22, .76, .22, .77)
	end

	-- OVERLAY 1

	

	

	auto:SetParent(text_overlay)
	auto:SetDrawLayer("BACKGROUND")
	auto:SetAllPoints()
	auto:SetTexCoord(.22, .76, .22, .77)

	-------------------------

	

	-- pet thing
	hooksecurefunc(button, "SetNormalTexture", function()
		normal:SetTexture()
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
	if button.styled then return end
	button.styled = true

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
