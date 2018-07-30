local addon, ns = ...
local cfg = ns.cfg
local CityUi = CityUi

LoadAddOn("Blizzard_CombatLog")

-- guild
CHAT_GUILD_GET = "|Hchannel:GUILD|hG|h %s "
CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "

-- raid
CHAT_RAID_GET = "|Hchannel:RAID|hR|h %s "
CHAT_RAID_WARNING_GET = "RW %s "
CHAT_RAID_LEADER_GET = "|Hchannel:RAID|hRL|h %s "

-- party
CHAT_PARTY_GET = "|Hchannel:PARTY|hP|h %s "
CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|hPL|h %s "
CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|hPG|h %s "

-- instance
CHAT_INSTANCE_CHAT_GET = "|Hchannel:Battleground|hI.|h %s: "
CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "

-- whisper
CHAT_WHISPER_INFORM_GET = "to %s "
CHAT_WHISPER_GET = "from %s "
CHAT_BN_WHISPER_INFORM_GET = "to %s "
CHAT_BN_WHISPER_GET = "from %s "

-- say / yell
CHAT_SAY_GET = "%s "
CHAT_YELL_GET = "%s "

--flags
CHAT_FLAG_AFK = "[AFK] "
CHAT_FLAG_DND = "[DND] "
CHAT_FLAG_GM = "[GM] "

FloatingChatFrame_OnMouseScroll = function(self, delta)
	if (delta > 0) then
		if (IsShiftKeyDown()) then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	else
		if (IsShiftKeyDown()) then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end

FloatingChatFrame_UpdateBackgroundAnchors = function(self) return end

FCF_ToggleLockOnDockedFrame = function()
	local chatFrame = FCF_GetCurrentChatFrame();
	local newLockValue = not chatFrame.isLocked;
	
	-- thanks Blizz
	if not chatFrame.isDocked then
		FCF_ToggleLock()
	else
		for _, frame in pairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
			FCF_SetLocked(frame, newLockValue);
		end
	end
end

CHAT_FONT_HEIGHTS = {[1] = 10}
for i = 2, 15 do
	CHAT_FONT_HEIGHTS[i] = CHAT_FONT_HEIGHTS[1] + i
end

ChatFrameMenuButton:ClearAllPoints()
ChatFrameMenuButton:SetPoint("TOPLEFT", ChatFrame1Background, "TOPRIGHT")

ChatFrameChannelButton:ClearAllPoints()
ChatFrameChannelButton:SetPoint("TOP", ChatFrameMenuButton, "BOTTOM")

BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-10, 10, 10, -10)

ChatFontNormal:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
ChatFontNormal:SetShadowOffset(0, 0)
ChatFontNormal:SetShadowColor(0, 0, 0, 0)

local frame_border_textures = {
	"TopLeftTexture",
	"BottomLeftTexture",
	"TopRightTexture",
	"BottomRightTexture",
	"LeftTexture",
	"RightTexture",
	"BottomTexture",
	"TopTexture"
}

local button_frame_textures = {
	"ButtonFrameBackground",
	"ButtonFrameTopLeftTexture",
	"ButtonFrameBottomLeftTexture",
	"ButtonFrameTopRightTexture",
	"ButtonFrameBottomRightTexture",
	"ButtonFrameLeftTexture",
	"ButtonFrameRightTexture",
	"ButtonFrameBottomTexture",
	"ButtonFrameTopTexture"
}

local skin_chat_frame = function(frame)
	if not frame or frame.skinned then return end

	local name = frame:GetName()

	local frame_bg = _G[name.."Background"]
	frame_bg:SetTexture(CityUi.media.textures.blank)
	frame_bg:SetVertexColor(unpack(cfg.bg_color))
	frame_bg.SetVertexColor = function() return end
	frame_bg:SetAlpha(cfg.bg_alpha)
	frame_bg.SetAlpha = function() return end
	frame_bg:ClearAllPoints()
	frame_bg:SetPoint("TOPLEFT", -5, 5)
	frame_bg:SetPoint("BOTTOMRIGHT", 5, -5)

	for _, tex_name in pairs(frame_border_textures) do
		local texture = _G[name..tex_name]
		texture:SetTexture(CityUi.media.textures.blank)
		texture:SetSize(1, 1)
		texture:SetVertexColor(unpack(cfg.border_color))
		texture.SetVertexColor = function() return end
		texture:SetAlpha(1)
		texture.SetAlpha = function() return end
	end

	_G[name.."TopLeftTexture"]:SetPoint("TOPLEFT", frame_bg, "TOPLEFT")
	_G[name.."BottomLeftTexture"]:SetPoint("BOTTOMLEFT", frame_bg, "BOTTOMLEFT")
	_G[name.."TopRightTexture"]:SetPoint("TOPRIGHT", frame_bg, "TOPRIGHT")
	_G[name.."BottomRightTexture"]:SetPoint("BOTTOMRIGHT", frame_bg, "BOTTOMRIGHT")

	if frame.CombatLogQuickButtonFrame then
		_G[frame.CombatLogQuickButtonFrame:GetName().."ProgressBar"]:SetStatusBarTexture(CityUi.media.textures.blank)
		frame_bg:SetPoint("TOPLEFT", -5, 5 + frame.CombatLogQuickButtonFrame:GetHeight())
		frame.CombatLogQuickButtonFrame:ClearAllPoints()
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
		frame.CombatLogQuickButtonFrame.oldSetPoint = frame.CombatLogQuickButtonFrame.SetPoint
		frame.CombatLogQuickButtonFrame.SetPoint = function(self)
			self:oldSetPoint("BOTTOMLEFT", frame, "TOPLEFT")
			self:oldSetPoint("BOTTOMLEFT", frame, "TOPRIGHT")
		end
	end

	local resize_button = _G[name.."ResizeButton"]
	resize_button:SetPoint("BOTTOMRIGHT")

	frame.ScrollBar:ClearAllPoints()
	frame.ScrollBar:SetPoint("BOTTOMRIGHT", frame.ScrollToBottomButton, "TOPRIGHT", -1, 0)
	frame.ScrollBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, 0)
	frame.ScrollBar.oldSetPoint = frame.ScrollBar.SetPoint
	frame.ScrollBar.SetPoint = function(self)
		self:oldSetPoint("BOTTOMRIGHT", frame.ScrollToBottomButton, "TOPRIGHT", -1, 0)
		self:oldSetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, 0)
	end

	for _, tex_name in pairs(button_frame_textures) do
		_G[name..tex_name]:SetTexture(nil)
	end

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth() / 2, UIParent:GetHeight() / 1.5)
	frame:SetMinResize(200, 100)
	frame:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	frame:SetShadowOffset(0, 0)
	frame:SetShadowColor(0, 0, 0, 0)

	local button_frame = _G[name.."ButtonFrame"]
	button_frame:Hide()
	button_frame:HookScript("OnShow", frame.Hide)

	local edit = _G[name.."EditBox"]
	_G[name.."EditBoxLeft"]:Hide()
	_G[name.."EditBoxMid"]:Hide()
	_G[name.."EditBoxRight"]:Hide()
	_G[name.."EditBoxFocusLeft"]:SetTexture(nil)
	_G[name.."EditBoxFocusRight"]:SetTexture(nil)
	_G[name.."EditBoxFocusMid"]:SetTexture(nil)
	edit:SetAltArrowKeyMode(false)
	edit:ClearAllPoints()

	if name == "ChatFrame2" then
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 54)
	else
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 30)
	end

	edit:SetPoint("LEFT", frame, "LEFT", 0, 0)
	edit:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

	CityUi.util.gen_backdrop(edit)

	local tab = _G[name.."Tab"]

	local tab_fs = tab:GetFontString()
	tab_fs:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	tab_fs:SetShadowOffset(0, 0)
	tab_fs:SetShadowColor(0, 0, 0, 0)
	tab_fs:SetTextColor(1, 1, 1, 1)
	tab_fs.oldSetTextColor = tab_fs.SetTextColor
	tab_fs.SetTextColor = function() return end
	
	_G[name.."TabLeft"]:SetTexture(nil)
	_G[name.."TabMiddle"]:SetTexture(nil)
	_G[name.."TabRight"]:SetTexture(nil)
	_G[name.."TabSelectedLeft"]:SetTexture(nil)
	_G[name.."TabSelectedMiddle"]:SetTexture(nil)
	_G[name.."TabSelectedRight"]:SetTexture(nil)
	_G[name.."TabHighlightLeft"]:SetTexture(nil)
	_G[name.."TabHighlightMiddle"]:SetTexture(nil)
	_G[name.."TabHighlightRight"]:SetTexture(nil)

	hooksecurefunc(frame, "Hide", function(self)
		tab_fs:oldSetTextColor(unpack(cfg.not_selected_tab_color))
	end)

	hooksecurefunc(frame, "Show", function(self)
		tab_fs:oldSetTextColor(unpack(cfg.selected_tab_color))
	end)

	hooksecurefunc(tab, "SetAlpha", function(self, a)
		if a < 1 then
			self:SetAlpha(1)
		end
	end)

	frame.skinned = true
end

GeneralDockManager:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 8)
GeneralDockManager:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 8)
for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	skin_chat_frame(frame)
	if ( i ~= 2 ) then
		local oldAddMessage = frame.AddMessage
		frame.AddMessage = function(frame, text, ...)
			return oldAddMessage(frame, string.gsub(text, '|h%[(%d+)%. .-%]|h', '|h%1|h'), ...)
		end
	end
end

hooksecurefunc("FCF_OpenTemporaryWindow", function()
	for _, name in pairs(CHAT_FRAMES) do
		local frame = _G[name]
		if (frame.isTemporary) then
			skin_chat_frame(frame)
		end
	end
end)

local dock_chat = function()
	local panel = CityDataPanel
	local frame = ChatFrame1
	if panel and frame then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 5, 10)
		frame:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -5, 10)
		frame:SetHeight(300)
	end
end

SLASH_DOCKCHAT1 = "/dockchat"
SlashCmdList.DOCKCHAT = dock_chat

CityUi:register_event("PLAYER_LOGIN", function()
	dock_chat()
end)
