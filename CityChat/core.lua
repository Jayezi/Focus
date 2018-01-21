local addon, ns = ...
local cfg = ns.cfg
local CityUi = CityUi
  
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

FCF_FadeInChatFrame = function(self)
	self.hasBeenFaded = true
end

FCF_FadeOutChatFrame = function(self)
	self.hasBeenFaded = false
end

FCFTab_UpdateColors = function(self, selected)
	if (selected) then
		self:SetAlpha(cfg.selected_tab_alpha)
		self:GetFontString():SetTextColor(unpack(cfg.selected_tab_color))
		self.leftSelectedTexture:Show()
		self.middleSelectedTexture:Show()
		self.rightSelectedTexture:Show()
	else
		self:GetFontString():SetTextColor(unpack(cfg.not_selected_tab_color))
		self:SetAlpha(cfg.not_selected_tab_alpha)
		self.leftSelectedTexture:Hide()
		self.middleSelectedTexture:Hide()
		self.rightSelectedTexture:Hide()
	end
end

FloatingChatFrame_OnMouseScroll = function(self, dir)
	if (dir > 0) then
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

for i = 1, 23 do
	CHAT_FONT_HEIGHTS[i] = i + 7
end

QuickJoinToastButton:Hide()
QuickJoinToastButton.Show = function() end
-- CityUi.util.gen_backdrop(QuickJoinToastButton)
-- print(QuickJoinToastButton.FriendsButton:GetDrawLayer())
-- QuickJoinToastButton.FriendsButton:SetDrawLayer("BORDER", 7)
-- QuickJoinToastButton.FriendsButton:SetTexCoord(.2, .75, .15, .9)
-- QuickJoinToastButton.FriendsButton:SetTexture(CityUi.media.textures.blank)

ChatFrameMenuButton:ClearAllPoints()
ChatFrameMenuButton:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 0, 0)
-- CityUi.util.gen_backdrop(ChatFrameMenuButton)
-- ChatFrameMenuButton:GetRegions():SetTexCoord(.2, .8, .1, .85)

BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-15, 15, 15, -15)

ChatFontNormal:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
ChatFontNormal:SetShadowOffset(0, 0)
ChatFontNormal:SetShadowColor(0, 0, 0, 0)

local skin_chat_frame = function(frame)
	if not frame or frame.skinned then return end

	local name = frame:GetName()

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
	frame:SetMinResize(100, 100)
	frame:SetFading(false)
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
	edit:SetAltArrowKeyMode(false)
	edit:ClearAllPoints()
	if name == "ChatFrame2" then
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 49)
	else
		edit:SetPoint("BOTTOM", frame, "TOP", 0, 25)
	end
	edit:SetPoint("LEFT", frame, "LEFT", 0, 0)
	edit:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	CityUi.util.gen_backdrop(edit)
	local tex = {edit:GetRegions()}
	for t = 6, #tex do tex[t]:SetAlpha(0) end

	local tab = _G[name.."Tab"]
	tab:SetAlpha(cfg.selected_tab_alpha)
	local tab_fs = tab:GetFontString()
	tab_fs:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	tab_fs:SetShadowOffset(0, 0)
	tab_fs:SetShadowColor(0, 0, 0, 0)
	tab_fs:SetTextColor(unpack(cfg.selected_tab_color))
	
	_G[name.."TabLeft"]:SetTexture(nil)
	_G[name.."TabMiddle"]:SetTexture(nil)
	_G[name.."TabRight"]:SetTexture(nil)
	_G[name.."TabSelectedLeft"]:SetTexture(nil)
	_G[name.."TabSelectedMiddle"]:SetTexture(nil)
	_G[name.."TabSelectedRight"]:SetTexture(nil)
	_G[name.."TabHighlightLeft"]:SetTexture(nil)
	_G[name.."TabHighlightMiddle"]:SetTexture(nil)
	_G[name.."TabHighlightRight"]:SetTexture(nil)

	frame.skinned = true
end

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

local a = CreateFrame("Frame")
CityUi:register_event("PLAYER_LOGIN", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local name = "ChatFrame"..i
		local tab = _G[name.."Tab"]
		tab:SetAlpha(cfg.selected_tab_alpha)
	end
end)
