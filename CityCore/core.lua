local cui = {}
CityUi = cui

local player_class = select(2, UnitClass("player"))
local player_color = RAID_CLASS_COLORS[player_class]

cui.player = {
	name = UnitName("player"),
	class = player_class,
	color = {player_color.r, player_color.g, player_color.b},
	color_str = player_color.colorStr,
	realm = GetRealmName()
}

cui.media = {
	fonts = {
		role_symbols = [[Interface\Addons\CityCore\media\fonts\role_symbols.ttf]],
		gotham_thicc = [[Interface\Addons\CityCore\media\fonts\gotham_thicc.ttf]],
		gotham_burly = [[Interface\Addons\CityCore\media\fonts\gotham_burly.ttf]],
		gotham_ultra = [[Interface\Addons\CityCore\media\fonts\gotham_ultra.ttf]],
	},

	textures = {
		blank = [[Interface\Buttons\WHITE8x8]]
	}
}

local frame_background_color = CreateColor(.15, .15, .15, 1)
local frame_border_color = CreateColor(0, 0, 0, 1)
local tooltip_frame_border_color = CreateColor(.5, .5, .5, 1)
local azerite_frame_border_color = CreateColor(.5, .5, 0, 1)

cui.config = {
	default_font = cui.media.fonts.gotham_ultra,
	font_size_sml = 10,
	font_size_med = 15,
	font_size_lrg = 20,
	font_size_big = 30,
	font_flags = "THINOUTLINE",
	frame_background = {.15, .15, .15, 1},
	frame_background_light = {.3, .3, .3, 1},
	frame_background_transparent = {.15, .15, .15, .6},
	frame_border = {0, 0, 0, 1},
	frame_backdrop = {
		bgFile = cui.media.textures.blank,
		edgeFile = cui.media.textures.blank,
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},

		backdropColor = frame_background_color,
		backdropBorderColor = frame_border_color
	},

	ui_scale = PixelUtil.GetPixelToUIUnitFactor(),
}

-- filled as needed
local mover_frames = {}
-- exists after ADDON_LOADED
local saved_positions

cui.util = {

    gen_statusbar = function(parent, w, h, fg_color, bg_color)
        local bar = CreateFrame("StatusBar", nil, parent)
		bar:SetSize(w, h)
	    bar:SetStatusBarTexture(cui.media.textures.blank)
		bar:SetBackdrop(cui.config.frame_backdrop)
		bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
		bar:SetBackdropBorderColor(unpack(cui.config.frame_border))
		
		if fg_color then
			bar:SetStatusBarColor(unpack(fg_color))
		end

        if bg_color then
            bar:SetBackdropColor(unpack(bg_color))
        else
            bar:SetBackdropColor(unpack(cui.config.frame_background))
        end

        return bar
    end,

	gen_backdrop = function(frame, ...)
		frame:SetBackdrop(cui.config.frame_backdrop)
		frame:SetBackdropBorderColor(unpack(cui.config.frame_border))
		if (...) then
			frame:SetBackdropColor(...)
		else
			frame:SetBackdropColor(unpack(cui.config.frame_background))
		end
	end,

    gen_border = function(frame, ...)
		frame:SetBackdrop(cui.config.frame_backdrop)
		frame:SetBackdropColor({0, 0, 0, 0})
		if (...) then
			frame:SetBackdropBorderColor(...)
		else
			frame:SetBackdropBorderColor(cui.config.frame_border)
		end
	end,

	gen_backdrop_borderless = function(frame, h, ...)
		frame:SetBackdrop({
			bgFile = cui.media.textures.blank,
			edgeFile = cui.media.textures.blank,
			tile = false,
			tileSize = 0,
			edgeSize = h / 2,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		});
		if (...) then
			frame:SetBackdropColor(...)
			frame:SetBackdropBorderColor(...)
		else
			frame:SetBackdropColor(unpack(cui.config.frame_background))
			frame:SetBackdropBorderColor(unpack(cui.config.frame_background))
		end
	end,

	fix_string = function(fs, size, flags, font)
		fs:SetFont(font or cui.config.default_font, size, flags or cui.config.font_flags)
		fs:SetShadowOffset(0, 0)
	end,

	gen_string = function(parent, size, flags, font, h_justify, v_justify, name)
		local string = parent:CreateFontString(name, "OVERLAY")
		string:SetFont(font or cui.config.default_font, size, flags or cui.config.font_flags)
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
		local frame = CreateFrame("Frame", "City"..panel.name, panel.parent)
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
		outer:SetPoint("TOPLEFT", inner, "TOPLEFT", inset and -inset or -1, inset or 1)
		outer:SetPoint("BOTTOMRIGHT", inner, "BOTTOMRIGHT", inset or 1, inset and -inset or -1)
	end,

	set_inside = function(inner, outer, inset)
		inner:ClearAllPoints()
		inner:SetPoint("TOPLEFT", outer, "TOPLEFT", inset or 1, inset and -inset or -1)
		inner:SetPoint("BOTTOMRIGHT", outer, "BOTTOMRIGHT", inset and -inset or -1, inset or 1)
	end,

	get_mover_frame = function(name, default_pos)
		local frame_name = "City"..name.."Mover"
		local mover_frame = CreateFrame("Frame", frame_name, UIParent)
	
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
	
		cui.util.gen_backdrop(mover_frame)
	
		local note = cui.util.gen_string(mover_frame, cui.config.font_size_med)
		note:SetPoint("CENTER")
		note:SetText(name)
	
		mover_frame:Hide()
		mover_frames[name] = mover_frame
	
		return mover_frame
	end
}

local load_frame = CreateFrame("Frame")
load_frame:RegisterEvent("ADDON_LOADED")
load_frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "CityCore" then
		if not CityFrameRole then CityFrameRole = {} end
		if not CityFrameRole[cui.player.realm] then CityFrameRole[cui.player.realm] = {} end
		if not CityFrameRole[cui.player.realm][cui.player.name] then CityFrameRole[cui.player.realm][cui.player.name] = "dps" end
		print("loaded "..CityFrameRole[cui.player.realm][cui.player.name].." role")

		if not CityFramePositions then CityFramePositions = {} end
		if not CityFramePositions[cui.player.realm] then CityFramePositions[cui.player.realm] = {} end
		if not CityFramePositions[cui.player.realm][cui.player.name] then CityFramePositions[cui.player.realm][cui.player.name] = {} end
		
		-- position any added movable frames that have been positioned before
		saved_positions = CityFramePositions[cui.player.realm][cui.player.name]
		for name, frame in pairs(mover_frames) do
			if saved_positions[name] then
				frame:ClearAllPoints()
				frame:SetPoint(cui.util.to_tl_anchor(frame, saved_positions[name]))
			end
		end
	end
end)

-- hide mover frames and save positions
SLASH_LOCKFRAMES1 = "/lockframes"
SlashCmdList.LOCKFRAMES = function()
	for name, frame in pairs(mover_frames) do
		frame:Hide()
		saved_positions[name] = {cui.util.to_tl_anchor(frame, {frame:GetPoint()})}
	end
end

-- show mover frames
SLASH_MOVEFRAMES1 = "/moveframes"
SlashCmdList.MOVEFRAMES = function()
	for name, frame in pairs(mover_frames) do
		frame:Show()
	end
end

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

-- change roles for raid frames
SLASH_ROLE1 = "/role"
SlashCmdList.ROLE = function(arg)
	if arg == "dps" then
		CityFrameRole[cui.player.realm][cui.player.name] = "dps"
		print("/rl for changes to take effect")
		print(CityFrameRole[cui.player.realm][cui.player.name])
	elseif arg == "healer" then
		CityFrameRole[cui.player.realm][cui.player.name] = "healer"
		print("/rl for changes to take effect")
		print(CityFrameRole[cui.player.realm][cui.player.name])
	elseif arg == "current" then
		print(CityFrameRole[cui.player.realm][cui.player.name])
	else
		print("/role (dps, healer, current)")
	end
end

-- combatlog reminder
local combatlog_checker = CreateFrame("Button", nil, UIParent)
combatlog_checker:Hide()
combatlog_checker:SetPoint("CENTER")
combatlog_checker:SetHeight(150)
combatlog_checker:SetWidth(300)
combatlog_checker:SetFrameStrata("HIGH")
combatlog_checker:RegisterForClicks("LeftButtonDown", "RightButtonDown")
cui.util.gen_backdrop(combatlog_checker)

combatlog_checker.text = cui.util.gen_string(combatlog_checker, cui.config.font_size_lrg)
combatlog_checker.text:SetPoint("CENTER")
combatlog_checker.text:SetTextColor(1, 1, 1, 1)
combatlog_checker:RegisterEvent("PLAYER_ENTERING_WORLD")

combatlog_checker:SetScript("OnEvent", function(self)
	if select(2, IsInInstance()) == "raid" then
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
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT = cui.config.frame_backdrop
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT.backdropBorderColor = tooltip_frame_border_color

for k, v in pairs(cui.config.frame_backdrop) do
	GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM[k] = v
end

GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.overlayAtlasTopScale = 1
GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM.backdropBorderColor = azerite_frame_border_color

GameTooltipStatusBar:SetStatusBarTexture(cui.media.textures.blank)

local tooltip_parent = cui.util.get_mover_frame("Tooltip")
tooltip_parent:SetPoint("BOTTOMRIGHT", UIParent, -10, 10)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
	self:SetOwner(tooltip_parent, "ANCHOR_TOPRIGHT", 0, -tooltip_parent:GetHeight())
end)

-- panels

cui.util.gen_panel({
	name = "DataPanel",
	strata = "BACKGROUND",
	parent = UIParent,
	w = 460,
	h = 25,
	point1 = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 2, 2},
	backdrop = cui.config.frame_backdrop,
	bgcolor = cui.config.frame_background_transparent,
	bordercolor = cui.config.frame_border,
})

-- afk screen

local afk = CreateFrame("Frame")
afk:SetAllPoints(WorldFrame)
cui.util.gen_backdrop(afk, 0, 0, 0, .75)
local name = cui.util.gen_string(afk, 50, nil, nil, "LEFT")
name:SetText(cui.player.name)
name:SetPoint("LEFT", WorldFrame, "CENTER")
name:SetPoint("RIGHT", WorldFrame, "RIGHT")
name:SetTextColor(unpack(cui.player.color))
afk:Hide()

local anims = {
	MONK = 732, -- Meditate
	HUNTER = 115 -- Kneel
}

local character_frame = CreateFrame("DressUpModel", "CityPlayerModel", nil)
character_frame:SetSize(600, 700)
character_frame:SetPoint("RIGHT", WorldFrame, "CENTER")

local start_afk = function()
	character_frame:SetUnit("player")
	character_frame:SetRotation(math.rad(25))
	character_frame:SetSheathed(true)
	character_frame:Show()

	if anims[cui.player.class] then
		character_frame:SetAnimation(anims[cui.player.class])
	end

	afk:Show()
	UIParent:SetAlpha(0)
	WorldFrame:SetAlpha(0)
end

local end_afk = function()
	character_frame:Hide()
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
afk:SetScript("OnEvent", function(event)	
	if UnitIsAFK("player") then
		start_afk()
	else
		end_afk()
	end
end)

ChatBubbleFont:SetFont(cui.config.default_font, cui.config.font_size_lrg, cui.config.font_flags)

local talking_head_frame = CreateFrame("Frame")
talking_head_frame:RegisterEvent("ADDON_LOADED")
talking_head_frame:SetScript("OnEvent", function()
	if addon == "Blizzard_TalkingHeadUI" then
		TalkingHeadFrame:ClearAllPoints()
		TalkingHeadFrame:SetPoint("TOPLEFT", 10, -10)
		TalkingHeadFrame.ignoreFramePositionManager = true
	end
end)

local login_frame = CreateFrame("Frame")
login_frame:RegisterEvent("PLAYER_LOGIN")
login_frame:SetScript("OnEvent", function()

	UIParent:SetScale(cui.config.ui_scale)
	WorldFrame:SetScale(cui.config.ui_scale)

	if LibStub and LibStub("LibSharedMedia-3.0") then
		LibStub("LibSharedMedia-3.0"):Register("font", "Gotham Thicc", cui.media.fonts.gotham_thicc)
		LibStub("LibSharedMedia-3.0"):Register("font", "Gotham Burly", cui.media.fonts.gotham_burly)
		LibStub("LibSharedMedia-3.0"):Register("font", "Gotham Ultra", cui.media.fonts.gotham_ultra)
		LibStub("LibSharedMedia-3.0"):Register("statusbar", "Blank", cui.media.textures.blank)
		LibStub("LibSharedMedia-3.0"):Register("border", "Blank", cui.media.textures.blank)
	end

	local skada_windows = {"Damage", "Healing", "Threat"}

	for _, v in pairs(skada_windows) do
		local window = _G["SkadaBarWindow"..v]
		if window then
			local regions = {window.button:GetRegions()}
			for _, v in pairs(regions) do
				if v.GetText then
					v:SetShadowOffset(0, 0)
				end
			end
		end
	end
end)

-- BW skin

local f = CreateFrame("Frame")
local register_bw_skin = function()

	local backdropBorder = {
		bgFile = cui.media.textures.blank,
		edgeFile = cui.media.textures.blank,
		tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	}

	local function removeStyle(bar)
		bar.candyBarBackdrop:Hide()
		local height = bar:Get("bigwigs:restoreheight")
		if height then
			bar:SetHeight(height)
		end

		local tex = bar:Get("bigwigs:restoreicon")
		if tex then
			bar:SetIcon(tex)
			bar:Set("bigwigs:restoreicon", nil)

			bar.candyBarIconFrameBackdrop:Hide()
		end

		bar.candyBarDuration:ClearAllPoints()
		bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
		bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)

		bar.candyBarLabel:ClearAllPoints()
		bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
		bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
	end

	local function styleBar(bar)
		local height = bar:GetHeight()
		bar:Set("bigwigs:restoreheight", height)
		bar:SetHeight(height / 2)

		local bd = bar.candyBarBackdrop

		bd:SetBackdrop(backdropBorder)
		bd:SetBackdropColor(unpack(cui.config.frame_background_transparent))
		bd:SetBackdropBorderColor(unpack(cui.config.frame_border))

		cui.util.set_outside(bd, bar)
		bd:Show()

		local tex = bar:GetIcon()
		if tex then
			local icon = bar.candyBarIconFrame
			bar:SetIcon(nil)
			icon:SetTexture(tex)
			icon:Show()
			if bar.iconPosition == "RIGHT" then
				icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 5, 0)
			else
				icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 0)
			end
			icon:SetSize(height, height)
			bar:Set("bigwigs:restoreicon", tex)

			local icon_bd = bar.candyBarIconFrameBackdrop
			icon_bd:SetBackdrop(backdropBorder)
			icon_bd:SetBackdropColor(unpack(cui.config.frame_background_transparent))
			icon_bd:SetBackdropBorderColor(unpack(cui.config.frame_border))

			cui.util.set_outside(icon_bd, icon)
			icon_bd:Show()
		end

		bar.candyBarLabel:ClearAllPoints()
		bar.candyBarLabel:SetPoint("BOTTOMLEFT", bar.candyBarBar, "TOPLEFT", 2, 2)

		bar.candyBarDuration:ClearAllPoints()
		bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "TOPRIGHT", -2, 2)
	end

	if not BigWigs then return end
	local bars = BigWigs:GetPlugin("Bars", true)
	if not bars then return end

	f:UnregisterEvent("ADDON_LOADED")
	f:UnregisterEvent("PLAYER_LOGIN")

	bars:RegisterBarStyle("identifier", {
		apiVersion = 1,
		version = 1,
		barHeight = 20,
		fontSizeNormal = 16,
		fontSizeEmphasized = 16,
		GetSpacing = function(bar) return bar:GetHeight() + 10 end,
		ApplyStyle = styleBar,
		BarStopped = removeStyle,
		GetStyleName = function() return "CityUI" end,
	})
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
local reason = nil
f:SetScript("OnEvent", function(self, event, msg)
	if event == "ADDON_LOADED" then
		if not reason then reason = (select(6, GetAddOnInfo("BigWigs_Plugins"))) end
		if (reason == "MISSING" and msg == "BigWigs") or msg == "BigWigs_Plugins" then
			register_bw_skin()
		end
	elseif event == "PLAYER_LOGIN" then
		register_bw_skin()
	end
end)
