--[[

	Might without control is wasted.
	Focus. Dominate.

	- The Primus

]]

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
local SetCVar = SetCVar

addon.units = { enabled = true }
addon.bars = { enabled = true }
addon.buffs = { enabled = true }
addon.raid = { enabled = false }
addon.chat = { enabled = true }
addon.map = { enabled = false }
addon.stats = { enabled = true }
addon.bag = { enabled = false }
addon.binds = { enabled = true }
addon.skin = { enabled = false }

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
		role_symbols = [[Interface\Addons\Focus\Media\role_symbols.ttf]],
		gotham_ultra = [[Interface\Addons\Focus\Media\gotham_ultra.ttf]],
		default_blizz = [[Fonts\FRIZQT__.TTF]]
	},

	textures = {
		blank = [[Interface\Buttons\WHITE8x8]]
	}
}

local frame_background_color = CreateColor(0.15, 0.15, 0.15, 1)
local frame_border_color = CreateColor(0, 0, 0, 1)
local tooltip_frame_border_color = CreateColor(0.75, 0.75, 0.75, 1)

core.config = {
	default_font = core.media.fonts.default_blizz,
	font_size_mini = 10,
	font_size_sml = 12,
	font_size_med = 14,
	font_size_lrg = 20,
	font_size_big = 30,
	font_flags = "THINOUTLINE",
	frame_background = {0.15, 0.15, 0.15, 1},
	frame_background_light = {0.3, 0.3, 0.3, 1},
	frame_background_transparent = {0.1, 0.1, 0.1, 0.85},
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
		selected = {0.66, 0.66, 0.66, 0.25},
		pushed = {0.33, 0.33, 0.33, 0.25},
		disabled = {0, 0, 0, 0.5},
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
		bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
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
		if frame:IsForbidden() then return end

		if not frame.SetBackdrop then
			Mixin(frame, BackdropTemplateMixin)
		end
		frame:SetBackdrop(core.config.frame_backdrop)
		frame.Center:SetDrawLayer("BACKGROUND", -8)
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

	fix_string = function(font_string, size, flags, font)
		font_string:SetFont(font or core.config.default_font, size or core.config.font_size_med, flags or core.config.font_flags)
		font_string:SetShadowOffset(0, 0)
	end,

	crop_icon = function(icon)
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	end,

	circle_mask = function(parent, tex, crop)
		if tex.mask then
			tex:RemoveMaskTexture(tex.mask)
		end
		local mask = tex.mask or parent:CreateMaskTexture()
		tex.mask = mask
		mask:SetPoint("TOPLEFT", tex, "TOPLEFT", crop or 0, crop and -crop or 0)
		mask:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", crop and -crop or 0, crop or 0)
		mask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		tex:AddMaskTexture(mask)
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

		-- HybridScrollBarTrimTemplate
		-- 		.trackBG
		-- 		.Top
		-- 		.Bottom
		-- 		.Middle

		-- 		.UpButton
		-- 		.DownButton
		
		-- 		.thumbTexture

		if scrollbar.trackBG then scrollbar.trackBG:Hide() end
		if scrollbar.ScrollBarTop then scrollbar.ScrollBarTop:Hide() end
		if scrollbar.Top then scrollbar.Top:Hide() end
		if scrollbar.ScrollBarBottom then scrollbar.ScrollBarBottom:Hide() end
		if scrollbar.Bottom then scrollbar.Bottom:Hide() end
		if scrollbar.ScrollBarMiddle then scrollbar.ScrollBarMiddle:Hide() end
		if scrollbar.Middle then scrollbar.Middle:Hide() end

		core.util.gen_backdrop(scrollbar)
		scrollbar:SetWidth(20)

		local scrollUpButton = scrollbar.ScrollUpButton or scrollbar.ScrollUp or scrollbar.UpButton
		local scrollDownButton = scrollbar.ScrollDownButton or scrollbar.ScrollDown or scrollbar.DownButton
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

	fix_editbox = function(frame, width, height, max)
		if frame.styled then return end
		frame.styled = true
	
		-- SearchBoxTemplate
		--   Layers
		--     OVERLAY
		local search_icon = frame.searchIcon -- $parentSearchIcon
		--   Frames
		--local clear_button = frame.clearButton -- $parentClearButton
		--     Layers
		--       ARTWORK
		--local clear_button_texture = clear_button.texture
	
	
		-- InputBoxInstructionsTemplate (SearchBoxTemplate)
		--   Layers
		--     ARTWORK
		local instructions = frame.Instructions
	
	
		-- InputBoxTemplate (InputBoxInstructionsTemplate)
		--   Layers
		--     BACKGROUND
		local left = frame.Left or (frame:GetName() and _G[frame:GetName().."Left"])
		if left then left:Hide() end
		local right = frame.Right or (frame:GetName() and _G[frame:GetName().."Right"])
		if right then right:Hide() end
		local middle = frame.Middle or frame.Mid  or (frame:GetName() and _G[frame:GetName().."Mid"])
		if middle then middle:Hide() end
	
		---------------------------------

		if search_icon then search_icon:Hide() end
	
		core.util.gen_backdrop(frame)
		
		frame:SetWidth(width or frame:GetWidth())
		frame:SetHeight(22)
		frame:SetMaxLetters(max)
		frame:SetTextInsets(5, 15, 0, 0)
		if instructions then core.util.fix_string(instructions, core.config.font_size_med) end
		core.util.fix_string(frame, core.config.font_size_med)

		local regions = {frame:GetRegions()}
		for _, region in ipairs(regions) do
			if region:GetObjectType() == "FontString" then
				region:ClearAllPoints()
				region:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, 0)
				region:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 0)
			end
		end
	end,

	strip_textures = function(frame, only_textures, exclusions)
		local regions = {frame:GetRegions()}
		for _, region in ipairs(regions) do
			local exluded = false
			if exclusions then
				for _, exclusion in ipairs(exclusions) do
					if region == exclusion then
						exluded = true
						break
					end
				end
			end
			if not exluded then
				if region:GetObjectType() == "Texture" then
					region:SetTexture()
					region:Hide()
				elseif not only_textures then
					region:Hide()
				end
			end
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

		core.util.gen_backdrop(mover_frame, unpack(core.config.frame_background_transparent))

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

FocusAddMenuOption = function(name, func)
	settings:add_action(name, func)
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

local tooltip_parent = core.util.get_mover_frame("Tooltip")
tooltip_parent:SetPoint("BOTTOMRIGHT", UIParent, -10, 10)

-- hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self)
-- 	self:SetOwner(tooltip_parent, "ANCHOR_TOPRIGHT", 0, -tooltip_parent:GetHeight())
-- end)

hooksecurefunc("EmbeddedItemTooltip_UpdateSize", function(button)
	button.IconBorder:SetTexture(core.media.textures.blank)
	button.IconBorder:SetDrawLayer("BORDER")
	button.IconBorder:SetSize(button.Icon:GetWidth() + 2, button.Icon:GetHeight() + 2)
	button.Icon:SetTexCoord(.1, .9, .1, .9)
end)

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
login_frame:RegisterEvent("UI_SCALE_CHANGED")
login_frame:SetScript("OnEvent", function(self, event)
	
	if event == "UI_SCALE_CHANGED" then
		UIParent:SetScale(core.config.ui_scale)
		WorldFrame:SetScale(core.config.ui_scale)
	else
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

		SetCVar("deselectOnClick", 1)
	end
end)

-- widgets

hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(self, widgetInfo, widgetContainer)
	if self.Bar:IsForbidden() then return end
	
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

local game_fonts = {
	-- SharedFonts.xml
	SystemFont_Tiny2,
	SystemFont_Tiny,
	SystemFont_Shadow_Small,
	Game10Font_o1,
	--SystemFont_Small,
	SystemFont_Small2,
	SystemFont_Shadow_Small2,
	SystemFont_Shadow_Med1_Outline,
	SystemFont_Shadow_Med1,
	--SystemFont_Med2,
	--SystemFont_Med3,
	SystemFont_Shadow_Med3,
	SystemFont_Shadow_Med3_Outline,
	QuestFont_Large,
	--QuestFont_Huge,
	QuestFont_30,
	QuestFont_39,
	--SystemFont_Large,
	SystemFont_Shadow_Large_Outline,
	SystemFont_Shadow_Med2,
	SystemFont_Shadow_Med2_Outline,
	SystemFont_Shadow_Large,
	SystemFont_Shadow_Large2,
	Game17Font_Shadow,
	SystemFont_Shadow_Huge1,
	SystemFont_Huge2,
	SystemFont_Shadow_Huge2,
	SystemFont_Shadow_Huge2_Outline,
	SystemFont_Shadow_Huge3,
	SystemFont_Shadow_Outline_Huge3,
	SystemFont_Huge4,
	SystemFont_Shadow_Huge4,
	SystemFont_Shadow_Huge4_Outline,
	SystemFont_World,
	SystemFont_World_ThickOutline,
	SystemFont22_Outline,
	SystemFont22_Shadow_Outline,
	--SystemFont_Med1,
	SystemFont_WTF2,
	SystemFont_Outline_WTF2,
	--GameTooltipHeader,
	System_IME,
	NumberFont_Shadow_Tiny,
	NumberFont_Shadow_Small,
	NumberFont_Shadow_Med,
	NumberFont_Shadow_Large,
	ChatFontNormal,
	ChatFontSmall,
	ConsoleFontNormal,
	ConsoleFontSmall,
	Tooltip_Med,
	Tooltip_Small,
	System15Font,
	Game30Font,
	Game32Font_Shadow2,
	Game36Font_Shadow2,
	Game40Font_Shadow2,
	Game46Font_Shadow2,
	Game52Font_Shadow2,
	Game58Font_Shadow2,
	Game69Font_Shadow2,
	Game72Font,
	Game72Font_Shadow,
	-- SharedFontStyles.xml
	GameFontNormal,
	GameFontNormal_NoShadow,
	GameFontNormalCenter,
	GameFontDisable,
	GameFontHighlight,
	GameFontHighlightLeft,
	GameFontHighlightCenter,
	GameFontHighlightRight,
	GameFontNormalHuge,
	GameFontHighlightHuge,
	GameFontDisableHuge,
	GameFontNormalSmall,
	GameFontNormalTiny,
	GameFontWhiteTiny,
	GameFontDisableTiny,
	GameFontBlackTiny,
	GameFontNormalTiny2,
	GameFontWhiteTiny2,
	GameFontDisableTiny2,
	GameFontBlackTiny2,
	GameFontNormalMed1,
	GameFontNormalMed2,
	GameFontNormalLarge,
	GameFontHighlightLarge,
	GameFontDisableLarge,
	GameFontNormalMed2Outline,
	GameFontNormalLargeOutline,
	GameFontDisableSmall,
	GameFontDisableSmall2,
	GameFontNormalShadowOutline22,
	GameFontHighlightShadowOutline22,
	GameFontNormalOutline,
	GameFontHighlightOutline,
	QuestFontNormalLarge,
	QuestFontNormalHuge,
	QuestFontHighlightHuge,
	GameFontHighlightMedium,
	GameFontBlackMedium,
	GameFontBlackSmall,
	GameFontRed,
	GameFontRedLarge,
	GameFontGreen,
	--GameFontBlack,
	GameFontWhite,
	GameFontHighlightMed2,
	GameFontHighlightLarge,
	GameFontNormalMed3,
	GameFontNormalMed3Outline,
	GameFontDisableMed3,
	GameFontDisableLarge,
	GameFontDisableMed2,
	GameFontHighlightSmall,
	GameFontHighlightSmallLeft,
	GameFontDisableSmallLeft,
	GameFontHighlightSmall2,
	GameFontBlackSmall2,
	GameFontNormalSmall2,
	GameFontNormalLarge2,
	GameFontHighlightLarge2,
	GameFontNormalWTF2,
	GameFontNormalWTF2Outline,
	GameFontNormalHuge2,
	GameFontHighlightHuge2,
	GameFontNormalShadowHuge2,
	GameFontHighlightShadowHuge2,
	GameFontNormalOutline22,
	GameFontHighlightOutline22,
	GameFontDisableOutline22,
	GameFontNormalHugeOutline,
	GameFontNormalHuge3,
	GameFontNormalHuge3Outline,
	GameFontNormalHuge4,
	GameFontNormalHuge4Outline,
	GameFont72Normal,
	GameFont72Highlight,
	GameFont72NormalShadow,
	GameFont72HighlightShadow,
	GameTooltipHeaderText,
	GameTooltipText,
	GameTooltipTextSmall,
	IMENormal,
	IMEHighlight,
	-- FontStyles.xml
	GameFontNormalLeft,
	GameFontNormalLeftBottom,
	GameFontNormalLeftGreen,
	GameFontNormalLeftYellow,
	GameFontNormalLeftOrange,
	GameFontNormalLeftLightGreen,
	GameFontNormalLeftGrey,
	GameFontNormalLeftRed,
	GameFontNormalRight,
	GameFontDisableLeft,
	GameFontGreen,
	GameFontWhiteSmall,
	GameFontNormalSmallLeft,
	GameFontHighlightSmallLeftTop,
	GameFontHighlightSmallRight,
	GameFontHighlightExtraSmall,
	GameFontHighlightExtraSmallLeft,
	GameFontHighlightExtraSmallLeftTop,
	GameFontDarkGraySmall,
	GameFontNormalGraySmall,
	GameFontGreenSmall,
	GameFontRedSmall,
	GameFontHighlightSmallOutline,
	GameFontNormalLargeLeft,
	GameFontNormalLargeLeftTop,
	GameFontGreenLarge,
	GameFontNormalHugeBlack,
	BossEmoteNormalHuge,
	NumberFontNormal,
	NumberFontNormalRight,
	NumberFontNormalRightRed,
	NumberFontNormalRightGreen,
	NumberFontNormalRightYellow,
	NumberFontNormalRightGray,
	NumberFontNormalYellow,
	NumberFontNormalSmall,
	NumberFontNormalSmallGray,
	NumberFontNormalGray,
	NumberFontNormalLarge,
	NumberFontNormalLargeRight,
	NumberFontNormalLargeRightRed,
	NumberFontNormalLargeRightYellow,
	NumberFontNormalLargeRightGray,
	NumberFontNormalLargeYellow,
	NumberFontNormalHuge,
	NumberFontSmallYellowLeft,
	NumberFontSmallWhiteLeft,
	NumberFontSmallBattleNetBlueLeft,
	GameFontNormalSmallBattleNetBlueLeft,
	Number11FontWhite,
	Number13FontWhite,
	Number13FontYellow,
	Number13FontGray,
	Number13FontRed,
	PriceFontWhite,
	PriceFontYellow,
	PriceFontGray,
	PriceFontRed,
	PriceFontGreen,
	Number14FontWhite,
	Number14FontGray,
	Number14FontGreen,
	Number14FontRed,
	Number15FontWhite,
	Number18FontWhite,
	--QuestTitleFont,
	--QuestTitleFontBlackShadow,
	--QuestFont,
	--QuestFontLeft,
	--QuestFontNormalSmall,
	QuestDifficulty_Impossible,
	QuestDifficulty_VeryDifficult,
	QuestDifficulty_Difficult,
	QuestDifficulty_Standard,
	QuestDifficulty_Trivial,
	QuestDifficulty_Header,
	ItemTextFontNormal,
	--MailTextFontNormal,
	SubSpellFont,
	NewSubSpellFont,
	DialogButtonNormalText,
	DialogButtonHighlightText,
	ZoneTextFont,
	SubZoneTextFont,
	PVPInfoTextFont,
	ErrorFont,
	TextStatusBarText,
	GameNormalNumberFont,
	WhiteNormalNumberFont,
	TextStatusBarTextLarge,
	CombatLogFont,
	WorldMapTextFont,
	--InvoiceTextFontNormal,
	InvoiceTextFontSmall,
	CombatTextFont,
	CombatTextFontOutline,
	MissionCombatTextFontOutline,
	MovieSubtitleFont,
	AchievementPointsFont,
	AchievementPointsFontSmall,
	--AchievementDescriptionFont,
	AchievementCriteriaFont,
	AchievementDateFont,
	VehicleMenuBarStatusBarText,
	FocusFontSmall,
	ObjectiveFont,
	ArtifactAppearanceSetNormalFont,
	ArtifactAppearanceSetHighlightFont,
	CommentatorTeamScoreFont,
	CommentatorDampeningFont,
	CommentatorTeamNameFont,
	CommentatorCCFont,
	CommentatorFontSmall,
	CommentatorFontMedium,
	CommentatorVictoryFanfare,
	CommentatorVictoryFanfareTeam,
	SystemFont_Small2,
	-- Fonts.xml
	SystemFont_Outline_Small,
	SystemFont_Outline,
	SystemFont_InverseShadow_Small,
	SystemFont_Huge1,
	SystemFont_Huge1_Outline,
	SystemFont_OutlineThick_Huge2,
	SystemFont_OutlineThick_Huge4,
	SystemFont_OutlineThick_WTF,
	NumberFont_GameNormal,
	NumberFont_OutlineThick_Mono_Small,
	Number12Font_o1,
	NumberFont_Small,
	Number11Font,
	Number12Font,
	Number13Font,
	PriceFont,
	Number15Font,
	Number16Font,
	Number18Font,
	NumberFont_Normal_Med,
	NumberFont_Outline_Med,
	NumberFont_Outline_Large,
	NumberFont_Outline_Huge,
	Fancy22Font,
	--QuestFont_Shadow_Huge,
	QuestFont_Outline_Huge,
	--QuestFont_Super_Huge,
	QuestFont_Shadow_Super_Huge,
	QuestFont_Super_Huge_Outline,
	SplashHeaderFont,
	Game11Font_Shadow,
	Game11Font,
	Game12Font,
	Game13Font,
	Game13FontShadow,
	Game15Font,
	Game16Font,
	Game18Font,
	Game20Font,
	Game24Font,
	Game27Font,
	Game32Font,
	Game36Font,
	--Game40Font,
	Game42Font,
	Game46Font,
	Game48Font,
	Game48FontShadow,
	Game60Font,
	Game120Font,
	Game11Font_o1,
	Game12Font_o1,
	Game13Font_o1,
	Game15Font_o1,
	--QuestFont_Enormous,
	QuestFont_Shadow_Enormous,
	DestinyFontMed,
	DestinyFontLarge,
	CoreAbilityFont,
	--DestinyFontHuge,
	QuestFont_Shadow_Small,
	--MailFont_Large,
	SpellFont_Small,
	--InvoiceFont_Med,
	InvoiceFont_Small,
	AchievementFont_Small,
	ReputationDetailFont,
	FriendsFont_Normal,
	FriendsFont_11,
	FriendsFont_Small,
	FriendsFont_Large,
	FriendsFont_UserText,
	GameFont_Gigantic,
	ChatBubbleFont,
	Fancy12Font,
	Fancy14Font,
	--Fancy16Font,
	Fancy18Font,
	Fancy20Font,
	Fancy24Font,
	Fancy27Font,
	Fancy30Font,
	Fancy32Font,
	Fancy48Font,
	SystemFont_NamePlateFixed,
	SystemFont_LargeNamePlateFixed,
	SystemFont_NamePlate,
	SystemFont_LargeNamePlate,
	SystemFont_NamePlateCastBar,
}
for _, font in ipairs(game_fonts) do
	local _, height = font:GetFont()
	
	core.util.fix_string(font, math.floor(height + 0.5))
end

SystemFont_NamePlate:SetFont(core.media.fonts.gotham_ultra, core.config.font_size_mini, "THINOUTLINE")

QuestTitleFont:SetShadowOffset(0, 0)
QuestTitleFontBlackShadow:SetShadowOffset(0, 0)

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

ExtraAbilityContainer:ClearAllPoints()

-- mock libstub

if not LibStub then
	LibStub = {}
	LibStub.libs = {}
	LibStub.minors = {}
	LibStub.minor = 0
	setmetatable(LibStub, { __call = function() return nil end })
end
