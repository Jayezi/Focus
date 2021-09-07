﻿-- Might without control is wasted...
-- Focus.
-- Dominate.
--                    - The Primus

local _, addon = ...
local core = {}
addon.core = core

local UIParent = UIParent
local CreateFrame = CreateFrame
local BackdropTemplateMixin = BackdropTemplateMixin
local Mixin = Mixin
local GetPhysicalScreenSize = GetPhysicalScreenSize
local strfind = strfind
local Round = Round
local ReloadUI = ReloadUI
local IsInInstance = IsInInstance
local LoggingCombat = LoggingCombat
local UnitExists = UnitExists
local UnitName = UnitName
local WorldFrame = WorldFrame
local UnitIsAFK = UnitIsAFK
local CinematicFrame = CinematicFrame

addon.bars = { enabled = true }
addon.units = { enabled = true }
addon.buffs = { enabled = true }
addon.chat = { enabled = true }
addon.map = { enabled = true }
addon.stats = { enabled = true }
addon.bag = { enabled = true }
addon.binds = { enabled = true }
addon.skin = { enabled = true }

local _, player_class = UnitClass("player")
local player_color = RAID_CLASS_COLORS[player_class]

core.player = {
	name = UnitName("player"),
	class = player_class,
	color = {player_color.r, player_color.g, player_color.b},
	color_str = player_color.colorStr,
	realm = GetRealmName(),
}

core.media = {
	fonts = {
		role_symbols = [[Interface\Addons\Focus\fonts\role_symbols.ttf]],
		gotham_ultra = [[Interface\Addons\Focus\fonts\gotham_ultra.ttf]],
	},

	textures = {
		blank = [[Interface\Buttons\WHITE8x8]]
	}
}

local frame_background_color = CreateColor(0.15, 0.15, 0.15, 1)
local frame_border_color = CreateColor(0, 0, 0, 1)
local tooltip_frame_border_color = CreateColor(0.75, 0.75, 0.75, 1)

core.config = {
	default_font = core.media.fonts.gotham_ultra,
	font_size_sml = 12,
	font_size_med = 15,
	font_size_lrg = 20,
	font_size_big = 30,
	font_flags = "THINOUTLINE",
	frame_background = {0.15, 0.15, 0.15, 1},
	frame_background_light = {0.3, 0.3, 0.3, 1},
	frame_background_transparent = {0.15, 0.15, 0.15, 0.6},
	frame_border = {0, 0, 0, 1},
	frame_backdrop = {
		bgFile = core.media.textures.blank,
		edgeFile = core.media.textures.blank,
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		},
	},
	color = {
		highlight = {1, 1, 1, 0.25},
		pushed = {0.5, 0.5, 1, 0.25},
		selected = {1, 1, 0.5, 0.25},
		border = {0, 0, 0, 1},
		light_border = {0.75, 0.75, 0.75, 1},
		background = {0.15, 0.15, 0.15, 1},
	},

	ui_scale = PixelUtil.GetPixelToUIUnitFactor(),
}

-- filled as needed
local mover_frames = {}
-- exists after ADDON_LOADED
local saved_positions

core.util = {

	pretty_number = function(v)
		if not v then return "" end
		if (v >= 1e9) then
			return ("%.2fb"):format(v / 1e9)
		elseif (v >= 1e6) then
			return ("%.2fm"):format(v / 1e6)
		elseif (v >= 1e3) then
			return ("%.2fk"):format(v / 1e3)
		else
			return ("%d"):format(v)
		end
	end,

	pretty_time = function(v)
		if not v then return "" end
		if (v > 60) then
			return ("%dm %ds"):format(math.floor(v / 60), v % 60)
		else
			return ("%ds"):format(v)
		end
	end,

    gen_statusbar = function(parent, w, h, fg_color, bg_color)
		local bar = CreateFrame("StatusBar", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
		bar:SetSize(w, h)
	    bar:SetStatusBarTexture(core.media.textures.blank)
		bar:SetBackdrop(core.config.frame_backdrop)
		bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
		bar:SetBackdropBorderColor(unpack(core.config.frame_border))

		if fg_color then
			bar:SetStatusBarColor(unpack(fg_color))
		end

        if bg_color then
            bar:SetBackdropColor(unpack(bg_color))
        else
            bar:SetBackdropColor(unpack(core.config.frame_background))
        end

        return bar
    end,

	gen_backdrop = function(frame, ...)
		if not frame.SetBackdrop then
			Mixin(frame, BackdropTemplateMixin)
		end
		frame:SetBackdrop(core.config.frame_backdrop)
		frame:SetBackdropBorderColor(unpack(core.config.frame_border))
		if (...) then
			frame:SetBackdropColor(...)
		else
			frame:SetBackdropColor(unpack(core.config.frame_background))
		end
	end,

	gen_border = function(frame, ...)
		if not frame.SetBackdrop then
			Mixin(frame, BackdropTemplateMixin)
		end
		frame:SetBackdrop(core.config.frame_backdrop)
		frame:SetBackdropColor({0, 0, 0, 0})
		if (...) then
			frame:SetBackdropBorderColor(...)
		else
			frame:SetBackdropBorderColor(core.config.frame_border)
		end
	end,

	gen_backdrop_borderless = function(frame, h, ...)
		if not frame.SetBackdrop then
			Mixin(frame, BackdropTemplateMixin)
		end
		frame:SetBackdrop({
			bgFile = core.media.textures.blank,
			edgeFile = core.media.textures.blank,
			tile = false,
			tileSize = 0,
			edgeSize = h / 2,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		});
		if (...) then
			frame:SetBackdropColor(...)
			frame:SetBackdropBorderColor(...)
		else
			frame:SetBackdropColor(unpack(core.config.frame_background))
			frame:SetBackdropBorderColor(unpack(core.config.frame_background))
		end
	end,

	fix_string = function(fs, size, flags, font)
		fs:SetFont(font or core.config.default_font, size or core.config.font_size_med, flags or core.config.font_flags)
		fs:SetShadowOffset(0, 0)
	end,

	crop_icon = function(icon)
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	end,

	fix_scrollbar = function(scrollbar)
		-- HybridScrollFrameTemplate
		--		.ScrollChild
		--		.scrollBar
		--		HybridScrollBarBackgroundTemplate
		--			.trackBG
		--			.ScrollBarTop
		--			.ScrollBarBottom
		--			.ScrollBarMiddle
		--			.thumbTexture
		--		HybridScrollBarTemplate
		--			.ScrollUpButton		UIPanelScrollUpButtonTemplate
		--			.ScrollDownButton	UIPanelScrollDownButtonTemplate

		-- UIPanelScrollBarTemplate
		--		.ThumbTexture

		--		.ScrollUpButton		UIPanelScrollUpButtonTemplate
		--		.ScrollDownButton	UIPanelScrollDownButtonTemplate

		if scrollbar.trackBG then scrollbar.trackBG:Hide() end
		if scrollbar.ScrollBarTop then scrollbar.ScrollBarTop:Hide() end
		if scrollbar.ScrollBarBottom then scrollbar.ScrollBarBottom:Hide() end
		if scrollbar.ScrollBarMiddle then scrollbar.ScrollBarMiddle:Hide() end

		core.util.gen_backdrop(scrollbar)
		scrollbar:SetWidth(20)

		local scrollUpButton = scrollbar.ScrollUpButton or scrollbar.ScrollUp
		local scrollDownButton = scrollbar.ScrollDownButton or scrollbar.ScrollDown
		local thumbTexture = scrollbar.ThumbTexture or scrollbar.thumbTexture
		
		thumbTexture:SetTexture(core.media.textures.blank)
		thumbTexture:SetWidth(18)
		thumbTexture:SetVertexColor(0.5, 0.5, 0.5)

		if scrollUpButton then
			core.util.gen_backdrop(scrollUpButton)
			scrollUpButton:SetSize(20, 15)
			scrollUpButton:SetPoint("BOTTOM", scrollbar, "TOP", 0, 1)

			local highlight = scrollUpButton:GetHighlightTexture()
			highlight:SetTexture(core.media.textures.blank)
			highlight:SetVertexColor(.6, .6, .6, .3)
			core.util.set_inside(highlight, scrollUpButton)

			local normal = scrollUpButton:GetNormalTexture()
			normal:SetTexture([[interface/buttons/arrow-up-up]])
			normal:SetTexCoord(-0.1, 1, 0.25, 1)
			normal:SetAllPoints(highlight)

			local pushed = scrollUpButton:GetPushedTexture()
			pushed:SetTexture([[interface/buttons/arrow-up-down]])
			pushed:SetTexCoord(0, 1.1, 0.35, 1.05)
			pushed:SetAllPoints(highlight)

			local disabled = scrollUpButton:GetDisabledTexture()
			disabled:SetTexture([[interface/buttons/arrow-up-disabled]])
			disabled:SetTexCoord(-0.1, 1, 0.25, 1)
			disabled:SetAllPoints(highlight)
		end

		if scrollDownButton then
			core.util.gen_backdrop(scrollDownButton)
			scrollDownButton:SetSize(20, 15)
			scrollDownButton:SetPoint("TOP", scrollbar, "BOTTOM", 0, -1)

			local highlight = scrollDownButton:GetHighlightTexture()
			highlight:SetTexture(core.media.textures.blank)
			highlight:SetVertexColor(.6, .6, .6, .3)
			core.util.set_inside(highlight, scrollDownButton)

			local normal = scrollDownButton:GetNormalTexture()
			normal:SetTexture([[interface/buttons/arrow-down-up]])
			normal:SetTexCoord(-0.1, 1, -0.1, 0.65)
			normal:SetAllPoints(highlight)

			local pushed = scrollDownButton:GetPushedTexture()
			pushed:SetTexture([[interface/buttons/arrow-down-down]])
			pushed:SetTexCoord(0, 1.1, -0.05, 0.75)
			pushed:SetAllPoints(highlight)

			local disabled = scrollDownButton:GetDisabledTexture()
			disabled:SetTexture([[interface/buttons/arrow-down-disabled]])
			disabled:SetTexCoord(-0.1, 1, -0.1, 0.65)
			disabled:SetAllPoints(highlight)
		end
	end,

	gen_string = function(parent, size, flags, font, h_justify, v_justify, name)
		local string = parent:CreateFontString(name, "OVERLAY")
		string:SetFont(font or core.config.default_font, size or core.config.font_size_med, flags or core.config.font_flags)
        if h_justify then
			if h_justify == "MIDDLE" then h_justify = "CENTER" end
			string:SetJustifyH(h_justify)
        end
	    if v_justify then
			if v_justify == "CENTER" then v_justify = "MIDDLE" end
			string:SetJustifyV(v_justify)
	    end
		return string
	end,

	gen_panel = function(panel)
		local frame = CreateFrame("Frame", "Focus"..panel.name, panel.parent, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetFrameStrata(panel.strata)

		if panel.w then frame:SetWidth(panel.w) end
		if panel.h then frame:SetHeight(panel.h) end

		frame:SetPoint(panel.point1[1], _G[panel.point1[2]], panel.point1[3], panel.point1[4], panel.point1[5])
		if panel.point2 then
			frame:SetPoint(panel.point2[1], _G[panel.point2[2]], panel.point2[3], panel.point2[4], panel.point2[5])
		end
		if panel.point3 then
			frame:SetPoint(panel.point3[1], _G[panel.point3[2]], panel.point3[3], panel.point3[4], panel.point3[5])
		end
		frame:SetBackdrop(panel.backdrop)
		frame:SetBackdropColor(unpack(panel.bgcolor))
		frame:SetBackdropBorderColor(unpack(panel.bordercolor))
		frame:Show()
		return frame
	end,

	to_tl_anchor = function(frame, point)
		local frame_w, frame_h = frame:GetSize()
		local screen_w, screen_h = GetPhysicalScreenSize()
		local from, parent, to, x, y = unpack(point)

		if type(parent) == "table" then
			parent = parent:GetName()
		end

		local new_y = y
		if strfind(to, "BOTTOM") then
			new_y = new_y - screen_h
		elseif not strfind(to, "TOP") then
			new_y = new_y - screen_h / 2
		end

		if strfind(from, "BOTTOM") then
			new_y = new_y + frame_h
		elseif not strfind(from, "TOP") then
			new_y = new_y + frame_h / 2
		end

		new_y = Round(new_y)

		local new_x = x
		if strfind(to, "RIGHT") then
			new_x = new_x + screen_w
		elseif not strfind(to, "LEFT") then
			new_x = new_x + screen_w / 2
		end

		if strfind(from, "RIGHT") then
			new_x = new_x - frame_w
		elseif not strfind(from, "LEFT") then
			new_x = new_x - frame_w / 2
		end

		new_x = Round(new_x)

		return "TOPLEFT", parent, "TOPLEFT", new_x, new_y
	end,

	set_outside = function(outer, inner, offest)
		outer:ClearAllPoints()
		outer:SetPoint("TOPLEFT", inner, "TOPLEFT", offest and -offest or -1, offest or 1)
		outer:SetPoint("BOTTOMRIGHT", inner, "BOTTOMRIGHT", offest or 1, offest and -offest or -1)
	end,

	set_inside = function(inner, outer, inset)
		inner:ClearAllPoints()
		inner:SetPoint("TOPLEFT", outer, "TOPLEFT", inset or 1, inset and -inset or -1)
		inner:SetPoint("BOTTOMRIGHT", outer, "BOTTOMRIGHT", inset and -inset or -1, inset or 1)
	end,

	get_mover_frame = function(name, default_pos)
		local frame_name = "Focus"..name.."Mover"
		local mover_frame = CreateFrame("Frame", frame_name, UIParent, BackdropTemplateMixin and "BackdropTemplate")

		local pos = saved_positions and saved_positions[name]
		if pos then
			mover_frame:SetPoint(unpack(pos))
		elseif default_pos then
			mover_frame:SetPoint(unpack(default_pos))
		end

		mover_frame:SetSize(200, 50)
		mover_frame:SetFrameStrata("TOOLTIP")
		mover_frame:SetFrameLevel(20)
		mover_frame:SetClampedToScreen(true)
		mover_frame:SetMovable(true)
		mover_frame:EnableMouse(true)

		mover_frame:SetScript("OnMouseDown", function(self, click)
			if click == "LeftButton" and not self.isMoving then
				self:StartMoving()
				self.isMoving = true
			end
		end)

		mover_frame:SetScript("OnMouseUp", function(self, click)
			if click == "LeftButton" and self.isMoving then
				self:StopMovingOrSizing()
				self:SetUserPlaced(false)
				self.isMoving = false
			end
		end)

		mover_frame:SetScript("OnHide", function(self)
			if ( self.isMoving ) then
				self:StopMovingOrSizing()
				self:SetUserPlaced(false)
				self.isMoving = false
			end
		end)

		core.util.gen_backdrop(mover_frame)

		local note = core.util.gen_string(mover_frame, core.config.font_size_med)
		note:SetPoint("CENTER")
		note:SetText(name)

		mover_frame:Hide()
		mover_frames[name] = mover_frame

		return mover_frame
	end
}

-- panels

local data_panel = core.util.gen_panel({
	name = "DataPanel",
	strata = "BACKGROUND",
	parent = UIParent,
	w = 500,
	h = 24,
	point1 = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 2, 2},
	backdrop = core.config.frame_backdrop,
	bgcolor = core.config.frame_background_transparent,
	bordercolor = core.config.frame_border,
})
data_panel.add_left = function(self, stat)
	if self.left then
		stat:SetPoint("BOTTOMLEFT", self.left, "BOTTOMRIGHT", 5, 0)
	else
		stat:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 5, 3)
	end
	self.left = stat
end
data_panel.add_right = function(self, stat)
	if self.right then
		stat:SetPoint("BOTTOMRIGHT", self.right, "BOTTOMLEFT", -5, 0)
	else
		stat:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 3)
	end
	self.right = stat
end

-- settings

local settings = CreateFrame("Frame", "FocusSettings", UIParent)
core.settings = settings

settings:SetParent(GameMenuFrame)
settings:SetSize(1, 1)
settings:SetPoint("BOTTOMLEFT", GameMenuFrame, "TOPLEFT", 0, -1)
settings:SetPoint("BOTTOMRIGHT", GameMenuFrame, "TOPRIGHT", 0, -1)
core.util.gen_backdrop(settings, unpack(core.config.frame_background_transparent))
settings.actions = {}

settings.add_action = function(self, name, func)
	local button = CreateFrame("Button", nil, self)
	button.click = func
	core.util.gen_backdrop(button)
	button:SetSize(140, 20)
	button:SetText(name)
	core.util.fix_string(button:GetFontString())
	button:SetScript("OnClick", function(self)
		self.click()
	end)
	table.insert(self.actions, button)
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	core.util.set_inside(highlight, button)
	highlight:SetColorTexture(unpack(core.config.color.highlight))
end

settings.build = function(self)
	local height = 30
	local last
	for _, button in ipairs(self.actions) do
		if last then
			button:SetPoint("TOP", last, "BOTTOM", 0, -1)
		else
			button:SetPoint("TOP", self, "TOP", 0, -15)
		end
		height = height + button:GetHeight() + 1
		last = button
	end
	self:SetHeight(height)
end

GameMenuFrame:HookScript("OnShow", function(self)
	settings:build()
	--settings:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Round(self:GetRight()), Round(self:GetTop()))
end)

local load_frame = CreateFrame("Frame")
load_frame:RegisterEvent("ADDON_LOADED")
load_frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Focus" then

		if not FocusFramePositions then FocusFramePositions = {} end
		if not FocusFramePositions[core.player.realm] then FocusFramePositions[core.player.realm] = {} end
		if not FocusFramePositions[core.player.realm][core.player.name] then FocusFramePositions[core.player.realm][core.player.name] = {} end

		-- position any added movable frames that have been positioned before
		saved_positions = FocusFramePositions[core.player.realm][core.player.name]
		for name, frame in pairs(mover_frames) do
			if saved_positions[name] then
				frame:ClearAllPoints()
				frame:SetPoint(core.util.to_tl_anchor(frame, saved_positions[name]))
			end
		end
	end
end)

-- hide mover frames and save positions
settings:add_action("Lock Frames", function()
	for name, frame in pairs(mover_frames) do
		frame:Hide()
		saved_positions[name] = {core.util.to_tl_anchor(frame, {frame:GetPoint()})}
	end
end)

-- show mover frames
settings:add_action("Move Frames", function()
	for _, frame in pairs(mover_frames) do
		frame:Show()
	end
end)

-- combatlog reminder

local combatlog_checker = CreateFrame("Button", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
combatlog_checker:Hide()
combatlog_checker:SetPoint("CENTER")
combatlog_checker:SetHeight(150)
combatlog_checker:SetWidth(300)
combatlog_checker:SetFrameStrata("HIGH")
combatlog_checker:RegisterForClicks("LeftButtonDown", "RightButtonDown")
core.util.gen_backdrop(combatlog_checker)

combatlog_checker.text = core.util.gen_string(combatlog_checker, core.config.font_size_lrg)
combatlog_checker.text:SetPoint("CENTER")
combatlog_checker.text:SetTextColor(1, 1, 1, 1)
combatlog_checker:RegisterEvent("PLAYER_ENTERING_WORLD")

combatlog_checker:SetScript("OnEvent", function(self)
	local is, type = IsInInstance()
	if type == "raid" or type == "party" then
		combatlog_checker.log_on = LoggingCombat()
		if combatlog_checker.log_on then
			self.text:SetText("Logging is ON\nL-click to hide\nR-click to disable")
		else
			self.text:SetText("Logging is OFF\nL-click to enable\nR-click to hide")
		end
		self:Show()
	end
end)

combatlog_checker:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		if combatlog_checker.log_on then
			self:Hide()
		else
			LoggingCombat(true)
			print("combat logging enabled")
			self:Hide()
		end
	else
		if combatlog_checker.log_on then
			LoggingCombat(false)
			print("combat logging disabled")
			self:Hide()
		else
			self:Hide()
		end
	end
end)

-- tooltips

local style_backdrop = function(tooltip)
	if tooltip.IsEmbedded then return end

	tooltip:SetBackdrop(core.config.frame_backdrop)
	tooltip:SetBackdropColor(unpack(core.config.frame_background))
	tooltip:SetBackdropBorderColor(tooltip_frame_border_color:GetRGB())
end

hooksecurefunc("SharedTooltip_SetBackdropStyle", style_backdrop)
style_backdrop(GameTooltip)

GameTooltipStatusBar:SetStatusBarTexture(core.media.textures.blank)

local tooltip_parent = core.util.get_mover_frame("Tooltip")
tooltip_parent:SetPoint("BOTTOMRIGHT", UIParent, -10, 10)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self)
	self:SetOwner(tooltip_parent, "ANCHOR_TOPRIGHT", 0, -tooltip_parent:GetHeight())
end)

hooksecurefunc("EmbeddedItemTooltip_UpdateSize", function(button)
	button.IconBorder:SetTexture(core.media.textures.blank)
	button.IconBorder:SetDrawLayer("BORDER")
	button.IconBorder:SetSize(button.Icon:GetWidth() + 2, button.Icon:GetHeight() + 2)
	button.Icon:SetTexCoord(.1, .9, .1, .9)
end)

-- afk screen

if false then
	local afk = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate")
	afk:SetAllPoints(WorldFrame)
	core.util.gen_backdrop(afk, 0, 0, 0, .75)
	afk:Hide()

	local anims = {
		MONK = 732, -- Meditate
		HUNTER = 115 -- Kneel
	}

	local character_frame = CreateFrame("DressUpModel", "FocusPlayerModel", nil)
	character_frame:SetSize(700, 750)
	character_frame:SetPoint("CENTER", WorldFrame)

	local pet_frame = CreateFrame("PlayerModel", "FocusPetModel", nil)
	pet_frame:SetSize(600, 600)
	pet_frame:SetPoint("BOTTOMRIGHT", character_frame, "BOTTOM", 0, -100)
	pet_frame:SetFrameLevel(character_frame:GetFrameLevel() + 1)

	local afk_name = core.util.gen_string(afk, 50, nil, nil, "CENTER")
	afk_name:SetText(core.player.name)
	afk_name:SetPoint("LEFT", WorldFrame, "CENTER")
	afk_name:SetPoint("RIGHT", WorldFrame, "RIGHT")
	afk_name:SetTextColor(unpack(core.player.color))

	local rotate_model = function(model, add_distance, add_yaw, add_pitch)

		model:SetPortraitZoom(0)
		model:SetCamDistanceScale(1)
		model:SetPosition(0, 0, 0)
		model:SetRotation(0)
		model:RefreshCamera()
		model:SetCustomCamera(1)

		local x, y, z = model:GetCameraPosition()
		local tx, ty, tz = model:GetCameraTarget()
		model:SetCameraTarget(0, ty, tz)

		local distance = math.sqrt(x * x + y * y + z * z) + add_distance
		local yaw = -math.atan(y / x) + add_yaw
		local pitch = -math.atan(z / x) + add_pitch

		local x = distance * math.cos(yaw) * math.cos(pitch)
		local y = distance * math.sin(-yaw) * math.cos(pitch)
		local z = distance * math.sin(-pitch)
		model:SetCameraPosition(x, y, z)
	end

	local start_afk = function()
		character_frame:Show()
		character_frame:SetUnit("player")
		character_frame:SetSheathed(true)
		rotate_model(character_frame, .5, math.rad(25), math.rad(0))
		if anims[core.player.class] then
			character_frame:SetAnimation(anims[core.player.class])
		end

		if UnitExists("pet") then
			pet_frame:Show()
			pet_frame:SetUnit("pet")
			rotate_model(pet_frame, .5, math.rad(30), math.rad(0))
			afk_name:SetText(core.player.name.."\nand\n"..UnitName("pet"))
		end

		afk:Show()
		UIParent:SetAlpha(0)
		WorldFrame:SetAlpha(0)
	end

	local end_afk = function()
		character_frame:Hide()
		pet_frame:Hide()
		afk:Hide()
		UIParent:SetAlpha(1)
		WorldFrame:SetAlpha(1)
	end

	afk:EnableMouse(true)
	afk:SetScript("OnMouseUp", function(self, click)
		if click == "LeftButton" then
			end_afk()
		end
	end)

	afk:RegisterEvent("PLAYER_FLAGS_CHANGED")
	afk:RegisterEvent("PLAYER_ENTERING_WORLD")
	afk:RegisterEvent("PLAYER_LEAVING_WORLD")
	afk:SetScript("OnEvent", function()
		if UnitIsAFK("player") then
			start_afk()
		else
			end_afk()
		end
	end)
end

ChatBubbleFont:SetFont(core.config.default_font, core.config.font_size_lrg, core.config.font_flags)

CinematicFrame:HookScript("OnShow", function(self)
	local bar_height = WorldFrame:GetHeight() / 6
	WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -bar_height);
	WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, bar_height);

	CinematicFrame.UpperBlackBar:SetHeight(bar_height);
	CinematicFrame.LowerBlackBar:SetHeight(bar_height);
end)

local login_frame = CreateFrame("Frame")
login_frame:RegisterEvent("PLAYER_LOGIN")
login_frame:SetScript("OnEvent", function()
	UIParent:SetScale(core.config.ui_scale)
	WorldFrame:SetScale(core.config.ui_scale)

	C_NamePlate.SetNamePlateEnemySize(125, 25)
	C_NamePlate.SetNamePlateFriendlySize(1, 1)
	SetCVar("nameplateShowOnlyNames", 1)

	-- stacking
	SetCVar("nameplateMotion", 1)

	SetCVar("nameplateMotionSpeed", 0.1)
	SetCVar("nameplateMaxDistance", 100)
	SetCVar("nameplateOccludedAlphaMult", 0.2)
	
	SetCVar("nameplateGlobalScale", 2)
	SetCVar("nameplateHorizontalScale", 1)
	SetCVar("nameplateVerticalScale", 1)
	SetCVar("nameplateLargerScale", 1)
	
	SetCVar("nameplateOverlapH", 1)
	SetCVar("nameplateOverlapV", 1)

	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMinScale", 1)
	SetCVar("nameplateMinScaleDistance", 10)
	SetCVar("nameplateMinAlphaDistance", 10)

	SetCVar("nameplateMaxAlpha", 1)
	SetCVar("nameplateMaxScale", 1)
	SetCVar("nameplateMaxScaleDistance", 100)
	SetCVar("nameplateMaxAlphaDistance", 100)
	
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("nameplateSelectedScale", 1)

	SetCVar("nameplateLargeBottomInset", -0.01)
	SetCVar("nameplateLargeTopInset", 0.03)
	SetCVar("nameplateOtherBottomInset", -0.01)
	SetCVar("nameplateOtherTopInset", 0.03)
	
	SetCVar("nameplateSelfAlpha", 1)
	SetCVar("nameplateSelfScale", 1)
	SetCVar("nameplateSelfTopInset", 0)
	SetCVar("nameplateSelfBottomInset", 0.4)
end)

-- widgets

hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(self, widgetInfo, widgetContainer)
	self.Bar.BGLeft:Hide()
	self.Bar.BGRight:Hide()
	self.Bar.BGCenter:Hide()
	self.Bar.BorderLeft:Hide()
	self.Bar.BorderRight:Hide()
	self.Bar.BorderCenter:Hide()
	self.Bar.Spark:Hide()
	if not self.Bar.styled then
		self.Bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
		core.util.gen_backdrop(self.Bar, 0, 0, 0, .25)
		self.Bar.styled = true
	end
end)

if not IsAddOnLoaded("Blizzard_DebugTools") then
	LoadAddOn("Blizzard_DebugTools")
end

TableAttributeDisplay:SetSize(1000, 800)
TableAttributeDisplay.LinesScrollFrame:SetSize(900, 700)
TableAttributeDisplay.LinesScrollFrame.LinesContainer:SetWidth(600)
TableAttributeDisplay.TitleButton:SetWidth(750)
TableAttributeDisplay.TitleButton.Text:SetWidth(750)

hooksecurefunc(TableAttributeLineMixin, "Initialize", function(self)
	self:SetWidth(800)
	if self.ValueButton then
		self.ValueButton:SetWidth(620)
		self.ValueButton.Text:SetWidth(620)
	end
end)
