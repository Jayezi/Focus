---------------------------------------------------
-- Global Init ------------------------------------
---------------------------------------------------

local CityUi = {}
_G["CityUi"] = CityUi

local player_class = select(2, UnitClass("player"))
local player_color = RAID_CLASS_COLORS[player_class]
CityUi.player = {
	name = UnitName("player"),
	class = player_class,
	color = {player_color.r, player_color.g, player_color.b},
	color_str = player_color.colorStr,
	realm = GetRealmName()
}

CityUi.media = {
	fonts = {
		pixel_10 = [[Interface\Addons\CityCore\media\fonts\pixel_10.ttf]],
		role_symbols = [[Interface\Addons\CityCore\media\fonts\role_symbols.ttf]],
		gotham_ultra = [[Interface\Addons\CityCore\media\fonts\gotham_ultra.ttf]],
		gotham_narrow_bold = [[Interface\Addons\CityCore\media\fonts\gotham_narrow_bold.ttf]]
	},

	textures = {
		blank = [[Interface\Buttons\WHITE8x8]]
	}
}

CityUi.config = {
	font_size_sml = 10,
	font_size_med = 15,
	font_size_lrg = 20,
	font_size_big = 30,
	font_flags = "THINOUTLINE,MONOCHROME",
	frame_background = {.15, .15, .15},
    frame_background_light = {.3, .3, .3},
	frame_border = {0, 0, 0, 1},
	frame_backdrop = {
		bgFile = CityUi.media.textures.blank,
		edgeFile = CityUi.media.textures.blank,
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	},

	-- Adjusts scaling for pixel perfect measurements.
	ui_scale = 768 / select(2, GetPhysicalScreenSize()),
	frame_positions = {
		player =		{"TOPRIGHT", "BOTTOM", -200, 400},
		target =		{"TOPLEFT", "BOTTOM", 200, 400},
		tank =          {"TOPLEFT", "CENTER", 0, 0},
	    focus =         {"TOPLEFT", "CENTER", 0, 0},
	    party =         {"TOPLEFT", "CENTER", 0, 0},
	    boss =          {"TOPLEFT", "CENTER", 0, 0},
	    raid =			{"TOPLEFT", "CENTER", 0, 0},
    }
}

CityUi.util = {

    gen_statusbar = function(parent, w, h, fg_color, bg_color)
        local bar = CreateFrame("StatusBar", nil, parent)
	    bar:SetStatusBarTexture(CityUi.media.textures.blank)
        bar:SetSize(w, h)
        if fg_color then bar:SetStatusBarColor(unpack(fg_color)) end

        bar.border = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
        bar.border:SetTexture(CityUi.media.textures.blank)
        bar.border:SetVertexColor(unpack(CityUi.config.frame_border))
	    bar.border:SetPoint("TOPLEFT", -1, 1)
        bar.border:SetPoint("BOTTOMRIGHT", 1, -1)

        bar.backdrop = bar:CreateTexture(nil, "BACKGROUND", nil, -7)
	    bar.backdrop:SetTexture(CityUi.media.textures.blank)
	    bar.backdrop:SetAllPoints()

        if bg_color then
            bar.backdrop:SetVertexColor(unpack(bg_color))
        else
            bar.backdrop:SetVertexColor(unpack(CityUi.config.frame_background))
        end

        return bar
    end,

	gen_backdrop = function(frame, ...)
		frame:SetBackdrop(CityUi.config.frame_backdrop)
		frame:SetBackdropBorderColor(unpack(CityUi.config.frame_border))
		if (...) then
			frame:SetBackdropColor(...)
		else
			frame:SetBackdropColor(unpack(CityUi.config.frame_background))
		end
	end,

    gen_border = function(frame, ...)
		frame:SetBackdrop(CityUi.config.frame_backdrop)
        frame:SetBackdropColor({0, 0, 0, 0})
        frame:SetBackdropBorderColor(unpack(CityUi.config.frame_border))
	end,

	gen_backdrop_borderless = function(frame, h, ...)
		frame:SetBackdrop({
			bgFile = CityUi.media.textures.blank,
			edgeFile = CityUi.media.textures.blank,
			tile = false,
			tileSize = 0,
			edgeSize = h / 2,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		});
		if (...) then
			frame:SetBackdropColor(...)
			frame:SetBackdropBorderColor(...)
		else
			frame:SetBackdropColor(unpack(CityUi.config.frame_background))
			frame:SetBackdropBorderColor(unpack(CityUi.config.frame_background))
		end
	end,

	gen_string = function(parent, size, flags, font, h_justify, v_justify)
		local string = parent:CreateFontString(nil, "OVERLAY")
		string:SetFont(font or CityUi.media.fonts.pixel_10, size, flags or CityUi.config.font_flags)
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
}

CityUi.event_manager = CreateFrame("Frame")
CityUi.event_manager.events = {}
CityUi.register_event = function(self, event, func)
	if not self.event_manager.events[event] then self.event_manager.events[event] = {} end
	table.insert(self.event_manager.events[event], func)
	if not self.event_manager:IsEventRegistered(event) then
		self.event_manager:RegisterEvent(event)
	end
end

CityUi.event_manager:SetScript("OnEvent", function(self, event, ...)
	local funcs = self.events[event]
	if funcs then
		for _, func in pairs(funcs) do
			func(...)
		end
	end
end)

---------------------------------------------------
-- UnitFrame Config -------------------------------
---------------------------------------------------

-- Loads the placement frames on startup and uses default values for positioning if not previously dragged.
-- Otherwise loads the position from CityFramePositions.
-- Frames will later be anchored to the top-left of these placement frames.
CityUi:register_event("ADDON_LOADED", function(addon)
	if addon == "CityCore" then
		if not CityFrameRole then CityFrameRole = {} end
		if not CityFrameRole[CityUi.player.realm] then CityFrameRole[CityUi.player.realm] = {} end
		if not CityFrameRole[CityUi.player.realm][CityUi.player.name] then CityFrameRole[CityUi.player.realm][CityUi.player.name] = "DAMAGER" end
		print("Loaded role: "..CityFrameRole[CityUi.player.realm][CityUi.player.name])

		if not CityFramePositions then CityFramePositions = {} end
		if not CityFramePositions[CityUi.player.realm] then CityFramePositions[CityUi.player.realm] = {} end
		if not CityFramePositions[CityUi.player.realm][CityUi.player.name] then
			CityFramePositions[CityUi.player.realm][CityUi.player.name] = CopyTable(CityUi.config.frame_positions)
		end
		local player_positions = CityFramePositions[CityUi.player.realm][CityUi.player.name]

		CityFrameList = {}

		for name, position in pairs(player_positions) do

			local temp_frame = CreateFrame("Frame", nil, UIParent)
			temp_frame:SetFrameStrata("HIGH")
			temp_frame.name = name
			CityUi.util.gen_backdrop(temp_frame)

			local note = CityUi.util.gen_string(temp_frame, CityUi.config.font_size_med)
			note:SetPoint("CENTER")
			note:SetText(name)

			if not player_positions[name] then player_positions[name] = CityUi.config.frame_positions[name] end
			local point = player_positions[name]
			temp_frame:SetPoint(point[1], UIParent, point[2], point[3], point[4])
			temp_frame:SetSize(200, 30)
			temp_frame:EnableMouse(true)
			temp_frame:SetMovable(true)
			temp_frame:RegisterForDrag("LeftButton")
			
            temp_frame:SetScript("OnDragStart", function(self)
				self:StartMoving()
			end)

			temp_frame:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				local frame_pos = {self:GetPoint()}
				player_positions[self.name] = {frame_pos[1], frame_pos[3], frame_pos[4], frame_pos[5]}
			end)
			
            CityFrameList[name] = {CityUi.config.frame_positions[name][1], temp_frame}
			temp_frame:Hide()
		end
	end
end)

-- Hide the positioning frames.
SLASH_LOCKFRAMES1 = "/lockframes"
SlashCmdList.LOCKFRAMES = function()
	local list = CityFrameList
	if list then
		for _, frame in pairs(CityFrameList) do
			frame[2]:Hide()
			if (frame[2].child and frame[2].child.test_frame) then frame[2].child.test_frame(false) end
		end
	end
end

-- Show the positioning frames.
SLASH_MOVEFRAMES1 = "/moveframes"
SlashCmdList.MOVEFRAMES = function()
	local list = CityFrameList
	if list then
		for _, frame in pairs(CityFrameList) do
			frame[2]:Show()
			if (frame[2].child and frame[2].child.test_frame) then frame[2].child.test_frame(true) end
		end
	end
end

-- Reset positioning frames.
SLASH_RESETFRAMES1 = "/resetframes"
SlashCmdList.RESETFRAMES = function()
	local list = CityFrameList
	if list then
		for name, frame in pairs(CityFrameList) do
			point = CityUi.config.frame_positions[name]
			frame[2]:SetPoint(point[1], UIParent, point[2], point[3], point[4])
		end
	end
end

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

-- Command to change roles for raid frame sizes.
SLASH_ROLE1 = "/role"
SlashCmdList.ROLE = function(arg)
	if arg == "dps" or arg == "tank" then
		CityFrameRole[CityUi.player.realm][CityUi.player.name] = "DAMAGER"
		print("/rl for changes to take effect")
		print(CityFrameRole[CityUi.player.realm][CityUi.player.name])
	elseif arg == "healer" then
		CityFrameRole[CityUi.player.realm][CityUi.player.name] = "HEALER"
		print("/rl for changes to take effect")
		print(CityFrameRole[CityUi.player.realm][CityUi.player.name])
	elseif arg == "current" then
		print(CityFrameRole[CityUi.player.realm][CityUi.player.name])
	else
		print("/role (dps, tank, healer, current)")
	end
end

---------------------------------------------------
-- Combatlog Reminder -----------------------------
---------------------------------------------------

local combatlog_checker = CreateFrame("Button", nil, UIParent)
combatlog_checker:Hide()
combatlog_checker:SetPoint("CENTER")
combatlog_checker:SetHeight(150)
combatlog_checker:SetWidth(300)
combatlog_checker:SetFrameStrata("HIGH")
combatlog_checker:RegisterForClicks("LeftButtonDown", "RightButtonDown")
CityUi.util.gen_backdrop(combatlog_checker)

combatlog_checker.text = CityUi.util.gen_string(combatlog_checker, CityUi.config.font_size_lrg)
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
			print("Combat logging enabled.")
			self:Hide()
		end
	else
		if combatlog_checker.log_on then
			LoggingCombat(false)
			print("Combat logging disabled.")
			self:Hide()
		else
			self:Hide()
		end
	end
end)

---------------------------------------------------
-- Panels -----------------------------------------
---------------------------------------------------

CityUi.util.gen_panel({
	name = "DataPanel",
	strata = "BACKGROUND",
	parent = UIParent,
	w = 460,
	h = 25,
	point1 = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 5, 5},
	backdrop = CityUi.config.frame_backdrop,
	bgcolor = {.15, .15, .15, .7},
	bordercolor = {0, 0, 0, 1},
})

CityUi.util.gen_panel({
	name = "ChatPanel",
	strata = "BACKGROUND",
	parent = UIParent,
	w = 460,
	h = 260,
	point1 = {"BOTTOMLEFT", "CityDataPanel", "TOPLEFT", 0, 5},
	backdrop = CityUi.config.frame_backdrop,
	bgcolor = {.15, .15, .15, .7},
	bordercolor = {0, 0, 0, 1},
})

CityUi.util.gen_panel({
	name = "TradePanel",
	strata = "BACKGROUND",
	parent = UIParent,
	w = 460,
	h = 260,
	point1 = {"BOTTOMLEFT", "CityChatPanel", "TOPLEFT", 0, 60},
	backdrop = CityUi.config.frame_backdrop,
	bgcolor = {.15, .15, .15, .7},
	bordercolor = {0, 0, 0, 1},
})

local set_chat = function()
	local panel = CityChatPanel
	local frame = ChatFrame1
	if panel and frame then
		FCF_SetLocked(frame, nil)
		frame:SetMovable(1)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 3, 3)
		frame:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
		frame:SetUserPlaced(true)
		FCF_SavePositionAndDimensions(frame)
		FCF_SetLocked(frame, 1)
	end
end

local set_trade = function()
	local panel = CityTradePanel
	local frame = ChatFrame3
	if panel and frame then
		panel:Show()
		FCF_SetLocked(frame, nil)
		FCF_UnDockFrame(frame)
		frame:SetMovable(1)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 3, 3)
		frame:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
		frame:SetUserPlaced(true)
		FCF_SavePositionAndDimensions(frame)
		FCF_SetLocked(frame, 1)
	end
end

local dock_trade = function()
	local panel = CityTradePanel
	local frame = ChatFrame3
	if panel and frame then
		FCF_DockFrame(frame, #FCFDock_GetChatFrames(GENERAL_CHAT_DOCK) + 1, false)
		panel:Hide()
	end
end

SLASH_SETCHAT1 = "/setchat"
SlashCmdList.SETCHAT = set_chat

SLASH_SETTRADE1 = "/settrade"
SlashCmdList.SETTRADE = set_trade

SLASH_DOCKTRADE1 = "/docktrade"
SlashCmdList.DOCKTRADE = dock_trade

SLASH_ALTPBAR1 = "/testaltp"
SlashCmdList.ALTPBAR = function(input)

	if UnitAlternatePowerInfo("player") then return end

	UnitPowerBarAlt_TearDown(PlayerPowerBarAlt)
	if not PlayerPowerBarAlt:IsShown() then
		UnitPowerBarAlt_SetUp(PlayerPowerBarAlt, 26)
		local textureInfo = {
			frame = { "Interface\\UNITPOWERBARALT\\UndeadMeat_Horizontal_Frame", 1, 1, 1 },
			background = { "Interface\\UNITPOWERBARALT\\Generic1Player_Horizontal_Bgnd", 1, 1, 1 },
			fill = { "Interface\\UNITPOWERBARALT\\Generic1_Horizontal_Fill", 0.16862745583057, 0.87450987100601, 0.24313727021217 },
			spark = { nil, 1, 1, 1 },
			flash = { "Interface\\UNITPOWERBARALT\\Meat_Horizontal_Flash", 1, 1, 1 },
		}
		for name, info in next, textureInfo do
			local texture = PlayerPowerBarAlt[name]
			local path, r, g, b = unpack(info)
			texture:SetTexture(path)
			texture:SetVertexColor(r, g, b)
		end

		PlayerPowerBarAlt.minPower = 0
		PlayerPowerBarAlt.maxPower = 300
		PlayerPowerBarAlt.range = PlayerPowerBarAlt.maxPower - PlayerPowerBarAlt.minPower
		PlayerPowerBarAlt.value = 150
		PlayerPowerBarAlt.displayedValue = PlayerPowerBarAlt.value
		TextStatusBar_UpdateTextStringWithValues(PlayerPowerBarAlt.statusFrame, PlayerPowerBarAlt.statusFrame.text, PlayerPowerBarAlt.displayedValue, PlayerPowerBarAlt.minPower, PlayerPowerBarAlt.maxPower)

		PlayerPowerBarAlt:UpdateFill()
		PlayerPowerBarAlt:Show()
	else
		UnitPowerBarAlt_TearDown(PlayerPowerBarAlt)
		PlayerPowerBarAlt:Hide()
	end
end

SLASH_EXTRAB1 = "/testextrab"
SlashCmdList.EXTRAB = function(input)
    local frame = ExtraActionBarFrame
	if not HasExtraActionBar() and not InCombatLockdown() then
		if frame:IsShown() then
			frame.intro:Stop()
			frame.outro:Play()
		else
			frame.button:Show()
			frame:Show()
			frame.outro:Stop()
			frame.intro:Play()
			if not frame.button.icon:GetTexture() then
				frame.button.icon:SetTexture("Interface\\ICONS\\ABILITY_SEAL")
				frame.button.icon:Show()
			end
		end
	end
end

---------------------------------------------------
-- UI Setup ---------------------------------------
---------------------------------------------------

--GameFontNormal:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
--GameFontNormal:SetShadowOffset(0, 0)
GameFontNormalHuge:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
GameFontNormalHuge:SetShadowOffset(0, 0)
MailTextFontNormal:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med)

UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = CityUi.config.font_size_med

ZoneTextString:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_big, CityUi.config.font_flags)
SubZoneTextString:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_big, CityUi.config.font_flags)
PVPInfoTextString:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_lrg, CityUi.config.font_flags)
PVPArenaTextString:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_lrg, CityUi.config.font_flags)

CityUi:register_event("PLAYER_LOGIN", function()
	UIParent:SetScale(CityUi.config.ui_scale)
	WorldFrame:SetScale(CityUi.config.ui_scale)
	SetSortBagsRightToLeft(true)
	SetInsertItemsLeftToRight(true)
	SetCVar("Sound_NumChannels", 128)

	if LibStub and LibStub("LibSharedMedia-3.0") then
		LibStub("LibSharedMedia-3.0"):Register("font", "Pixel10", CityUi.media.fonts.pixel_10)
		LibStub("LibSharedMedia-3.0"):Register("statusbar", "Blank", CityUi.media.textures.blank)
		LibStub("LibSharedMedia-3.0"):Register("border", "Blank", CityUi.media.textures.blank)
	end

	if DBM and DBT then
        local skin = DBT:RegisterSkin("CityCore")

	    skin.defaults = {
	        Template = "CityUiSkinTemplate",
	    }

	    if (DBM.Bars.options.Template ~= skin.defaults.Template) then
	        DBM.Bars:SetSkin("CityCore")
	    end
    end

	set_chat()
	dock_trade()
end)
