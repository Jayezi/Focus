local _, addon = ...
if not addon.chat.enabled then return end
local core = addon.core
local cfg = addon.chat.cfg

LoadAddOn("Blizzard_CombatLog")

CHAT_GUILD_GET = "|Hchannel:GUILD|hG|h %s "
CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "
CHAT_RAID_GET = "|Hchannel:RAID|hR|h %s "
CHAT_RAID_WARNING_GET = "RW %s "
CHAT_RAID_LEADER_GET = "|Hchannel:RAID|hRL|h %s "
CHAT_PARTY_GET = "|Hchannel:PARTY|hP|h %s "
CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|hPL|h %s "
CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|hPG|h %s "
CHAT_INSTANCE_CHAT_GET = "|Hchannel:Battleground|hI.|h %s: "
CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "
CHAT_WHISPER_INFORM_GET = "to %s "
CHAT_WHISPER_GET = "from %s "
CHAT_BN_WHISPER_INFORM_GET = "to %s "
CHAT_BN_WHISPER_GET = "from %s "
CHAT_SAY_GET = "%s "
CHAT_YELL_GET = "%s "
CHAT_FLAG_AFK = "[AFK] "
CHAT_FLAG_DND = "[DND] "
CHAT_FLAG_GM = "[GM] "

CHAT_FONT_HEIGHTS = {[1] = 10}
for i = 2, 15 do
	CHAT_FONT_HEIGHTS[i] = CHAT_FONT_HEIGHTS[1] + i
end

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
	frame_bg:SetTexture(core.media.textures.blank)
	frame_bg:SetVertexColor(unpack(core.config.frame_background_transparent))
	frame_bg.SetVertexColor = function() return end
	frame_bg.SetAlpha = function() return end

	frame_bg:ClearAllPoints()
	frame_bg:SetPoint("TOPLEFT", -5, 5 + (frame.CombatLogQuickButtonFrame and frame.CombatLogQuickButtonFrame:GetHeight() or 0))
	frame_bg:SetPoint("BOTTOMRIGHT", 5, -5)

	for _, tex_name in pairs(frame_border_textures) do
		local texture = _G[name..tex_name]
		texture:SetTexture(core.media.textures.blank)
		texture:SetSize(1, 1)
		texture:SetVertexColor(unpack(core.config.frame_border))
		texture.SetVertexColor = function() return end
		texture:SetAlpha(1)
		texture.SetAlpha = function() return end
	end

	_G[name.."TopLeftTexture"]:SetPoint("TOPLEFT", frame_bg, "TOPLEFT")
	_G[name.."BottomLeftTexture"]:SetPoint("BOTTOMLEFT", frame_bg, "BOTTOMLEFT")
	_G[name.."TopRightTexture"]:SetPoint("TOPRIGHT", frame_bg, "TOPRIGHT")
	_G[name.."BottomRightTexture"]:SetPoint("BOTTOMRIGHT", frame_bg, "BOTTOMRIGHT")

	if frame.CombatLogQuickButtonFrame then
		_G[frame.CombatLogQuickButtonFrame:GetName().."ProgressBar"]:SetStatusBarTexture(core.media.textures.blank)
		frame.CombatLogQuickButtonFrame:ClearAllPoints()
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
	end

	for _, tex_name in pairs(button_frame_textures) do
		_G[name..tex_name]:SetTexture(nil)
	end

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth() / 2, UIParent:GetHeight() / 1.5)
	frame:SetMinResize(200, 100)
	core.util.fix_string(frame, core.config.font_size_med)

	local edit = _G[name.."EditBox"]
	_G[name.."EditBoxLeft"]:Hide()
	_G[name.."EditBoxMid"]:Hide()
	_G[name.."EditBoxRight"]:Hide()
	_G[name.."EditBoxFocusLeft"]:SetTexture(nil)
	_G[name.."EditBoxFocusRight"]:SetTexture(nil)
	_G[name.."EditBoxFocusMid"]:SetTexture(nil)
	edit:SetAltArrowKeyMode(false)
	edit:ClearAllPoints()

	if frame:GetID() == 2 then
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 54)
	else
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 30)
	end

	edit:SetPoint("LEFT", frame, "LEFT", 0, 0)
	edit:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

	core.util.gen_backdrop(edit)

	local tab = _G[name.."Tab"]

	tab:SetAlpha(1)
	tab.SetAlpha = function() end

	local tab_fs = tab:GetFontString()
	core.util.fix_string(tab_fs, core.config.font_size_med)
	tab_fs:SetTextColor(1, 1, 1, 1)
	tab_fs.oldSetTextColor = tab_fs.SetTextColor
	tab_fs.SetTextColor = function() return end

	_G[name.."TabLeft"]:SetTexture(nil)
	if not frame.isStaticDocked then
		_G[name.."TabLeft"]:SetWidth(1)
	end
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
		tab_fs:oldSetTextColor(unpack(core.player.color))
	end)

	frame.skinned = true
end

local skin_chatframe_button = function(frame, prev)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -2)
	frame:SetSize(25, 25)
	core.util.gen_backdrop(frame)
	frame:SetNormalTexture("")
	frame:SetPushedTexture("")
	frame.iconPushedOffsetX = 0
	frame.iconPushedOffsetY = 0
end

local dock_chat = function()
	local panel = FocusDataPanel
	local frame = ChatFrame1
	if panel and frame then
		frame:SetUserPlaced(true)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", panel, "TOPLEFT", 5, 10)
		frame:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -5, 10)
		frame:SetHeight(300)
	end
end

local setup_chat = function()

	-- reset
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, "Chat")

	CombatConfig_SetCombatFiltersToDefault()
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, "Log")

	FCF_OpenNewWindow(GENERAL)
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_DockFrame(ChatFrame4)

	-- chat tab
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")

	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")

	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")

	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame1, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame1, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_INFO")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_MISC_INFO")

	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "CHANNEL")
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
	
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")

	-- log tab
	ChatFrame_RemoveAllMessageGroups(ChatFrame2)

	-- general tab
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddChannel(ChatFrame3, "General")
	ChatFrame_AddChannel(ChatFrame3, "Trade")
	ChatFrame_AddChannel(ChatFrame3, "LocalDefense")
	ChatFrame_AddChannel(ChatFrame3, "LookingForGroup")

	-- loot tab
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame4, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame4, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame4, "TRADESKILLS")
	ChatFrame_AddMessageGroup(ChatFrame4, "OPENING")

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	
	dock_chat()
end

ChatFrameMenuButton:ClearAllPoints()
ChatFrameMenuButton:SetPoint("TOPLEFT", ChatFrame1Background, "TOPRIGHT", 2, 0)
ChatFrameMenuButton:SetSize(25, 22)
core.util.gen_backdrop(ChatFrameMenuButton)

local normal = ChatFrameMenuButton:GetNormalTexture()
core.util.set_inside(normal, ChatFrameMenuButton)
normal:SetTexCoord(0.21, 0.73, 0.28, 0.76)
ChatFrameMenuButton:SetPushedTexture(normal:GetTexture())

local pushed = ChatFrameMenuButton:GetPushedTexture()
pushed:SetTexCoord(0.21, 0.73, 0.28, 0.76)

local highlight = ChatFrameMenuButton:GetHighlightTexture()
core.util.set_inside(highlight, ChatFrameMenuButton)
highlight:SetTexture(core.media.textures.blank)
highlight:SetVertexColor(.6, .6, .6, .3)

skin_chatframe_button(ChatFrameChannelButton, ChatFrameMenuButton)
skin_chatframe_button(ChatFrameToggleVoiceDeafenButton, ChatFrameChannelButton)
skin_chatframe_button(ChatFrameToggleVoiceMuteButton, ChatFrameToggleVoiceDeafenButton)

BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-10, 10, 10, -10)

core.util.fix_string(ChatFontNormal, core.config.font_size_med)
ChatFontNormal:SetShadowColor(0, 0, 0, 0)

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

GeneralDockManager:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 8)
GeneralDockManager:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 8)

QuickJoinToastButton:ClearAllPoints()
QuickJoinToastButton:SetPoint("TOPLEFT", ChatFrame1)
QuickJoinToastButton:EnableMouse(false)
QuickJoinToastButton.ClearAllPoints = function() end
QuickJoinToastButton.SetPoint = function() end
QuickJoinToastButton:SetAlpha(0)

SLASH_SETUPCHAT1 = "/setupchat"
SlashCmdList.SETUPCHAT = setup_chat

SLASH_DOCKCHAT1 = "/dockchat"
SlashCmdList.DOCKCHAT = dock_chat

hooksecurefunc("FCF_OpenTemporaryWindow", function()
	skin_chat_frame(FCF_GetCurrentChatFrame())
end)

hooksecurefunc("FCF_RestorePositionAndDimensions", function()
	dock_chat()
end)

hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", function(self)
	self.Background:ClearAllPoints()
	self.Background:SetPoint("TOPLEFT", -5, 5 + (self.CombatLogQuickButtonFrame and self.CombatLogQuickButtonFrame:GetHeight() or 0))
	self.Background:SetPoint("BOTTOMRIGHT", 5, -5)
	self:SetClampRectInsets(0, 0, 0, 0);
end)

hooksecurefunc("FCF_UpdateScrollbarAnchors", function(chatFrame)
	if chatFrame.ScrollBar then
		chatFrame.ScrollBar:ClearAllPoints();
		chatFrame.ScrollBar:SetPoint("TOPRIGHT", 3, 0);

		if chatFrame.ScrollToBottomButton:IsShown() then
			chatFrame.ScrollBar:SetPoint("BOTTOM", chatFrame.ScrollToBottomButton, "TOP", 0, 0);
		elseif chatFrame.ResizeButton:IsShown() then
			chatFrame.ScrollBar:SetPoint("BOTTOM", chatFrame.ResizeButton, "TOP", 0, 0);
		else
			chatFrame.ScrollBar:SetPoint("BOTTOM");
		end
	end
end)