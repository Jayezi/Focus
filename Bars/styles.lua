local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core
local cfg = addon.bars.cfg

local styles = {}
addon.bars.styles = styles

styles.actionbutton = function(button, bar_cfg)

	local blank = core.media.textures.blank
	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))

	local name = button:GetName()

	-- ActionButtonTemplate (ActionButton, PetActionButtonTemplate, StanceButtonTemplate, PossessButtonTemplate)
	--   Layers
	--     BACKGROUND
	local icon  = button.icon -- $parentIcon
	--     ARTWORK 1
	local flash  = button.Flash -- $parentFlash
	local fob = button.FlyoutBorder -- $parentFlyoutBorder
	local fobs = button.FlyoutBorderShadow -- $parentFlyoutBorderShadow
	--     ARTWORK 2
	--local foa  = button.FlyoutArrow -- $parentFlyoutArrow
	local hotkey  = button.HotKey -- $parentHotKey
	local count  = button.Count -- $parentCount
	--     OVERLAY
	local macro  = button.Name -- $parentName
	local border  = button.Border -- $parentBorder
	--     OVERLAY 1
	local new = button.NewActionTexture
	local spellhighlight = button.SpellHighlightTexture
	local auto = button.AutoCastable
	--local levellock = button.LevelLinkLockIcon
	--   Frames
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

	-- BACKGROUND 1

	if fbg then fbg:Hide() end

	-- ARTWORK 1

	flash:SetTexture(blank)
	flash:SetVertexColor(unpack(cfg.color.flash))
	flash:SetAllPoints(icon)

	fob:SetTexture()
	fobs:SetTexture()

	-- ARTWORK 2

	core.util.fix_string(hotkey, core.config.font_size_med)
	hotkey:SetParent(text_overlay)
	hotkey:ClearAllPoints()
	hotkey:SetPoint("BOTTOMLEFT", 3, -1)
	hotkey:SetPoint("BOTTOMRIGHT", 4, -1)
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
	new:SetVertexColor(unpack(cfg.color.new))

	spellhighlight:SetAllPoints(icon)
	spellhighlight:SetTexture(blank)
	spellhighlight:SetVertexColor(unpack(cfg.color.highlight))

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
	pushed:SetVertexColor(unpack(cfg.color.pressed))
	pushed:SetDrawLayer("ARTWORK", -6)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))

	local checked = button:GetCheckedTexture()
	checked:SetAllPoints(icon)
	checked:SetTexture(blank)
	checked:SetVertexColor(unpack(cfg.color.checked))
	checked.alt_SetAlpha = checked.SetAlpha
	hooksecurefunc(checked, "SetAlpha", function(self)
		self:alt_SetAlpha(cfg.color.checked[4])
	end)
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
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end

styles.bagbutton = function(button)

	core.util.gen_backdrop(button, unpack(core.config.frame_background_transparent))
	local blank = core.media.textures.blank
	--local name = button:GetName()

	-- ItemButton (MainMenuBarBackpackButton, BagSlotButtonTemplate)
	--   Layers
	--     BORDER
	local icon = button.icon -- $parentIconTexture
	--     ARTWORK 2
	local count = button.Count -- $parentCount
	--local stock = _G[name.."Stock"]
	--     OVERLAY
	local border = button.IconBorder
	--     OVERLAY 1
	--local overlay = button.IconOverlay -- Azerite/Corruption
	--     OVERLAY 2
	--local levellock = button.LevelLinkLockTexture
	--     OVERLAY 4
	--local search = button.searchOverlay -- $parentSearchOverlay
	--     OVERLAY 5
	--local context = button.ItemContextOverlay

	-- ItemAnimTemplate (MainMenuBarBackpackButton, BagSlotButtonTemplate)
	--   Layers
	--     OVERLAY
	--local anim = button.animIcon

	-- MainMenuBarBackpackButton
	--   Layers
	--     OVERLAY
	local slothighlight = button.SlotHighlightTexture

	-- BagSlotButtonTemplate (CharacterBag)
	--   Layers
	--     OVERLAY
	--local slothighlight = button.SlotHighlightTexture

	-- Normal
	-- Pushed
	-- Highlight

	-------------------------------

	-- Layers

	-- BORDER

	icon:SetDrawLayer("ARTWORK", -7)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	core.util.set_inside(icon, button)

	-- ARTWORK 2

	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT")
	core.util.fix_string(count)

	-- OVERLAY

	border:SetTexture(blank)
	border:SetAllPoints(button)
	border:SetDrawLayer("BORDER")
	border:SetBlendMode("ADD")

	border.alt_SetTexture = border.SetTexture
	hooksecurefunc(border, "SetTexture", function(self)
		self:alt_SetTexture(blank)
	end)

	slothighlight:SetAllPoints()
	--slothighlight:SetTexture(blank)
	--slothighlight:SetVertexColor(unpack(cfg.color.highlight))
	slothighlight:SetTexCoord(.07, .93, .07, .93)

	------------------------------

	local normal = button:GetNormalTexture()
	normal:SetAllPoints(icon)
	normal:SetTexture()

	local pushed = button:GetPushedTexture()
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(cfg.color.pressed))
	pushed:SetDrawLayer("ARTWORK", -6)

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end

styles.microbutton = function(button)

	-- CharacterMicroButton
	--   Layers
	--     OVERLAY
	--local portrait = MicroButtonPortrait
	-- SpellbookMicroButton
	-- TalentMicroButton
	-- AchievementMicroButton
	-- QuestLogMicroButton
	-- GuildMicroButton
	--   Frames
	--local tabard = _G[name.."Tabard"]
	--     Layers
	--       ARTWORK
	--local bg = tabard.background -- $parentBackground
	--       OVERLAY 1
	--local emblem = tabard.emblem -- $parentEmblem
	--   100
	--local notification = button.NotificationOverlay
	--     Layers
	--       OVERLAY
	--local unread = notification.UnreadNotificationIcon
	-- LFDMicroButton
	-- CollectionsMicroButton
	-- EJMicroButton
	--   Frames
	--local adventure = button.NewAdventureNotice
	-- StoreMicroButton
	-- MainMenuMicroButton
	--   Layers
	--     OVERLAY
	--local performance = MainMenuBarPerformanceBar
	--local download = MainMenuBarDownload
	-- HelpMicroButton

	-------------------------------

	-- 28x36
	-- MainMenuBarMicroButton
	--   Layers
	--     OVERLAY
	local flash = button.Flash -- $parentFlash
	--   NormalTexture
	--   HighlightTexture
	--   PushedTexture
	--   DisabledTexture

	local inset = 3

	flash:SetTexture(core.media.textures.blank)
	flash:SetVertexColor(unpack(cfg.color.flash))
	core.util.set_inside(flash, button, inset)

	if button == CharacterMicroButton then
		MicroButtonPortrait:SetAllPoints(flash)
	end

	local normal = button:GetNormalTexture()
	normal:SetTexCoord(.22, .80, .22, .81)
	normal:SetAllPoints(flash)

	local pushed = button:GetPushedTexture()
	-- make it not move when pressed
	pushed:SetTexCoord(.19, .77, .28, .86)
	pushed:SetAllPoints(flash)

	local highlight = button:GetHighlightTexture()
	highlight:SetTexture(core.media.textures.blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
	highlight:SetAllPoints(flash)

	local disabled = button:GetDisabledTexture()
	if disabled then
		disabled:SetTexCoord(.22, .80, .22, .81)
		disabled:SetAllPoints(flash)
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
end
