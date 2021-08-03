local _, addon = ...
if not addon.chat.enabled then return end

local core = addon.core
local cfg = addon.chat.cfg

local CreateFrame = CreateFrame
local GENERAL_CHAT_DOCK = GENERAL_CHAT_DOCK
local UIParent = UIParent
local GeneralDockManager = GeneralDockManager
local hooksecurefunc = hooksecurefunc
local ChatFrame1 = ChatFrame1
local ChatFrame2 = ChatFrame2
local ChatFrame3 = ChatFrame3
local ChatFrame4 = ChatFrame4
local ChatFrame5 = ChatFrame5
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetWindowName = FCF_SetWindowName
local CombatConfig_SetCombatFiltersToDefault = CombatConfig_SetCombatFiltersToDefault
local FCF_DockFrame = FCF_DockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local ReloadUI = ReloadUI
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame

if not IsAddOnLoaded("Blizzard_CombatLog") then
	LoadAddOn("Blizzard_CombatLog")
end

local copy_scroll = CreateFrame('ScrollFrame', nil, UIParent, 'UIPanelScrollFrameTemplate')
copy_scroll:SetPoint("CENTER")
copy_scroll:SetSize(800, 400)
copy_scroll:EnableMouse(true)
core.util.gen_backdrop(copy_scroll, unpack(core.config.frame_background_transparent))
core.util.fix_scrollbar(copy_scroll.ScrollBar)

local copy_edit = CreateFrame('EditBox', nil, copy_scroll)
copy_edit:SetSize(800, 400)
copy_edit:SetMultiLine(true)
copy_edit:SetMaxLetters(99999)
copy_edit:EnableMouse(true)
copy_edit:SetFontObject(ChatFontNormal)
copy_edit:SetScript('OnEscapePressed', function()
	copy_scroll:Hide()
end)
copy_scroll:SetScrollChild(copy_edit)
copy_scroll:Hide()

local copy_chat = function(frame)
	copy_scroll:Show()

	local lines = {}
	local index = 1
	for i = 1, frame:GetNumMessages() do
		local message = frame:GetMessageInfo(i)
		if message then
			lines[index] = message
			index = index + 1
		end
	end
	copy_edit:SetText(table.concat(lines, "\n", 1, index - 1))
end

local update_background = function(frame)
	local scrollbar = 0
	if frame.ScrollBar then
		scrollbar = frame.ScrollBar:GetWidth()
	end

	local quickbutton = 0
	if frame.CombatLogQuickButtonFrame then
		quickbutton = frame.CombatLogQuickButtonFrame:GetHeight()
	end

	frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 3 + quickbutton)
	frame.Background:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2 + scrollbar, 3 + quickbutton)
	frame.Background:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -2, -6)
	frame.Background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2 + scrollbar, -6)

	frame:SetClampRectInsets(0, 0, 0, 0)
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

local fix_frame_size_pos = function(frame)
	local left, bottom = frame:GetLeft(), frame:GetBottom()
	local width, height = frame:GetSize()
	frame:SetSize(math.floor(width + 0.5), math.floor(height + 0.5))
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", math.floor(left + 0.5), math.floor(bottom + 0.5))
end

local skin_button = function(button, texture, ...)
	core.util.gen_backdrop(button)

	if texture and not button.Icon then
		button.Icon = button:CreateTexture()
		button.Icon:SetTexture(texture)
		button.Icon:SetDrawLayer("BORDER")
	end
	core.util.set_inside(button.Icon, button)

	if ... then
		button.Icon:SetTexCoord(...)
	end

	local normal = button:GetNormalTexture()
	normal:SetTexture()

	local pushed = button:GetPushedTexture()
	core.util.set_inside(pushed, button)
	pushed:SetTexture(core.media.textures.blank)
	pushed:SetVertexColor(.3, .3, .3, .6)

	local highlight = button:GetHighlightTexture()
	core.util.set_inside(highlight, button)
	highlight:SetTexture(core.media.textures.blank)
	highlight:SetVertexColor(.6, .6, .6, .3)

	local disabled = button:GetDisabledTexture()
	if disabled then
		core.util.set_inside(disabled, button)
		disabled:SetTexture(core.media.textures.blank)
		disabled:SetVertexColor(0, 0, 0, .6)
	end
end

local skin_chat_frame = function(frame)
	if frame.skinned then return end
	frame.skinned = true

	local name = frame:GetName()

	-- FloatingBorderedFrame (FloatingChatFrameTemplate)
	--   Layers
	--     BACKGROUND
	local frame_bg = frame.Background -- $parentBackground
	--     BORDER
	-- frame_border_textures

	-------------------------------

	-- FloatingChatFrameTemplate
	--   Frames
	local resize = frame.ResizeButton -- $parentResizeButton
	local buttons = frame.buttonFrame -- $parentButtonFrame
	--     Frames
	local minimize = buttons.minimizeButton -- $parentMinimizeButton

	local bottom = frame.ScrollToBottomButton
	--     Layers
	--       OVERLAY
	local bottom_flash = bottom.Flash

	local scrollbar = frame.ScrollBar
	local thumb = scrollbar.ThumbTexture -- $parentThumbTexture

	local editbox = frame.editBox -- $parentEditBox
	--header
	--headerSuffix

	---------------------------------

	core.util.fix_string(frame)
	core.util.fix_string(editbox)
	core.util.fix_string(editbox.header)
	core.util.fix_string(editbox.headerSuffix)

	frame.backdrop = CreateFrame("Frame", nil, frame)
	frame.backdrop:SetAllPoints(frame_bg)
	frame.backdrop:SetFrameStrata(frame:GetFrameStrata())
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	core.util.gen_backdrop(frame.backdrop, unpack(core.config.frame_background_transparent))

	frame.copy = CreateFrame("Frame", nil, frame)
	frame.copy:SetSize(20, 20)
	frame.copy:SetPoint("TOPRIGHT", frame.backdrop, "TOPRIGHT", -2, -2)
	frame.copy:SetScript("OnMouseUp", function()
		copy_chat(frame)
	end)

	frame.copy.icon = frame.copy:CreateTexture()
	frame.copy.icon:SetTexture([[interface/buttons/ui-guildbutton-publicnote-up]])
	frame.copy.icon:SetAllPoints()

	local highlight = frame.copy:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetTexture(core.media.textures.blank)
	highlight:SetVertexColor(.6, .6, .6, .3)

	frame_bg:SetTexture()

	minimize:ClearAllPoints()
	minimize:SetPoint("TOPRIGHT")
	minimize:SetSize(22, 22)
	skin_button(minimize, minimize:GetNormalTexture():GetTexture(), 0.25, 0.74, 0.3, 0.7)

	bottom:SetSize(20, 15)
	bottom:ClearAllPoints()
	bottom:SetPoint("BOTTOMRIGHT", resize, "TOPRIGHT", -2, 5)
	bottom_flash:SetTexture()
	skin_button(bottom, [[interface/buttons/arrow-down-down]], 0.05, 1.0, 0.0, 0.7)

	scrollbar:SetWidth(20)

	thumb:SetTexture(core.media.textures.blank)
	thumb:SetWidth(18)
	thumb:SetVertexColor(.5, .5, .5)

	resize:SetSize(20, 20)
	resize:HookScript("OnMouseUp", function(self)
		if( self:GetParent().isDocked ) then
			fix_frame_size_pos(GENERAL_CHAT_DOCK.primary)
		else
			fix_frame_size_pos(self:GetParent())
		end
	end)

	for _, texture in pairs(frame_border_textures) do
		_G[name..texture]:SetTexture()
	end

	if frame.CombatLogQuickButtonFrame then
		_G[frame.CombatLogQuickButtonFrame:GetName().."ProgressBar"]:SetStatusBarTexture(core.media.textures.blank)
		frame.CombatLogQuickButtonFrame:ClearAllPoints()
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
		frame.CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
	end

	for _, texture in pairs(button_frame_textures) do
		_G[name..texture]:SetTexture()
	end

	frame:SetMaxResize(UIParent:GetWidth() / 2, UIParent:GetHeight() / 1.5)
	frame:SetMinResize(200, 100)

	_G[editbox:GetName().."Left"]:Hide()
	_G[editbox:GetName().."Mid"]:Hide()
	_G[editbox:GetName().."Right"]:Hide()

	editbox.focusLeft:SetTexture()
	editbox.focusRight:SetTexture()
	editbox.focusMid:SetTexture()
	editbox:SetAltArrowKeyMode(false)
	editbox:ClearAllPoints()
	editbox:SetPoint("BOTTOMLEFT", frame.backdrop, "TOPLEFT", 0, GeneralDockManager:GetHeight())
	editbox:SetPoint("BOTTOMRIGHT", frame.backdrop, "TOPRIGHT", 0, GeneralDockManager:GetHeight())
	core.util.gen_backdrop(editbox)

	local tab = _G[name.."Tab"]

	-- ChatTabArtTemplate
	--   BACKGROUND
	tab.leftTexture:SetTexture() -- $parentLeft
	tab.middleTexture:SetTexture() -- $parentMiddle
	tab.rightTexture:SetTexture() -- $parentRight
	--   BORDER
	tab.leftSelectedTexture:SetTexture() -- $parentSelectedLeft
	tab.middleSelectedTexture:SetTexture() -- $parentSelectedMiddle
	tab.rightSelectedTexture:SetTexture() -- $parentSelectedRight
	local glow = tab.glow -- $parentGlow
	--   HIGHLIGHT
	tab.leftHighlightTexture:SetTexture() -- $parentHighlightLeft
	tab.middleHighlightTexture:SetTexture() -- $parentHighlightMiddle
	tab.rightHighlightTexture:SetTexture() -- $parentHighlightRight

	-- ChatTabTemplate
	local tab_flash = _G[tab:GetName().."Flash"]
	local tab_text = tab.Text -- $parentText

	tab:SetAlpha(1)
	tab.alt_SetAlpha = tab.SetAlpha
	hooksecurefunc(tab, "SetAlpha", function(self)
		self:alt_SetAlpha(1)
	end)

	tab_flash:SetAllPoints()

	core.util.fix_string(tab_text)
	tab.leftTexture:SetWidth(10)
	tab.rightTexture:SetWidth(15)
	tab:SetHeight(25)
	tab_text:ClearAllPoints()
	tab_text:SetPoint("LEFT", tab.leftTexture, "RIGHT", 0, 0)
	tab_text:SetTextColor(unpack(core.player.color))

	tab.alt_SetWidth = tab.SetWidth
	hooksecurefunc(tab, "SetWidth", function(self)
		self.Text:SetSize(0, 0)
		local width = self.Text:GetSize()
		self.middleTexture:SetWidth(width)
		self:alt_SetWidth(width + 20)
	end)

	frame:HookScript("OnHide", function(self)
		tab_text:SetTextColor(unpack(cfg.not_selected_tab_color))
	end)

	frame:HookScript("OnShow", function(self)
		tab_text:SetTextColor(unpack(core.player.color))
	end)

	update_background(frame)
end

local dock_chat = function()
	local anchor = _G["FocusDataPanel"]
	local frame = ChatFrame1
	frame:ClearAllPoints()
	frame:SetHeight(300)
	frame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 2, 8)
	frame:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", -2 + -frame.ScrollBar:GetWidth(), 8)
	frame:SetUserPlaced(true)
end

local setup_chat = function()

	-- reset
	FCF_ResetChatWindows()
	FCF_SetWindowName(ChatFrame1, "Chat")

	CombatConfig_SetCombatFiltersToDefault()
	FCF_DockFrame(ChatFrame2)
	FCF_SetWindowName(ChatFrame2, "Log")

	FCF_OpenNewWindow("General", true)
	FCF_OpenNewWindow("Loot", true)

	-- chat tab
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame1, "PET_INFO")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_MISC_INFO")
	ChatFrame_AddMessageGroup(ChatFrame1, "TARGETICONS")
	ChatFrame_RemoveChannel(ChatFrame1, "Trade")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")

	-- log tab
	ChatFrame_RemoveAllMessageGroups(ChatFrame2)

	-- voice tab
	-- ChatFrame3

	-- general tab
	ChatFrame_AddChannel(ChatFrame4, "General")
	ChatFrame_AddChannel(ChatFrame4, "Trade")
	ChatFrame_AddChannel(ChatFrame4, "LocalDefense")
	ChatFrame_AddChannel(ChatFrame4, "LookingForGroup")

	-- loot tab
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame5, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame5, "CURRENCY")
	ChatFrame_AddMessageGroup(ChatFrame5, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame5, "TRADESKILLS")
	ChatFrame_AddMessageGroup(ChatFrame5, "OPENING")

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")

	dock_chat()
	ReloadUI()
end

hooksecurefunc("FCF_StopDragging", function(frame)
	if not frame.isDocked then
		fix_frame_size_pos(frame)
	end
end)

hooksecurefunc("FCFTab_UpdateColors", function(tab, selected)
	if selected then
		tab.Text:SetTextColor(unpack(core.player.color))
	else
		tab.Text:SetTextColor(unpack(cfg.not_selected_tab_color))
	end
end)

hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", update_background)
hooksecurefunc("FCF_RestorePositionAndDimensions", dock_chat)

local update_scrollbar = function(frame)
	if frame.ScrollBar then
		frame.ScrollBar:ClearAllPoints()

		if frame.copy then
			frame.ScrollBar:SetPoint("TOPRIGHT", frame.copy, "BOTTOMRIGHT", 0, -2)
		else
			frame.ScrollBar:SetPoint("TOPRIGHT", frame.Background, "TOPRIGHT", -2, -2)
		end

		if frame.ScrollToBottomButton:IsShown() then
			frame.ScrollBar:SetPoint("BOTTOMLEFT", frame.ScrollToBottomButton, "TOPLEFT", 0, 2)
		elseif frame.ResizeButton:IsShown() then
			frame.ScrollBar:SetPoint("BOTTOM", frame.ResizeButton, "TOP", 0, 2)
		else
			frame.ScrollBar:SetPoint("BOTTOM", frame.Background, "BOTTOM", 0, 2)
		end
	end
end

hooksecurefunc("FCF_UpdateScrollbarAnchors", update_scrollbar)

hooksecurefunc("FCF_OpenTemporaryWindow", function()
	local frame = FCF_GetCurrentChatFrame()
	skin_chat_frame(frame)
	update_scrollbar(frame)
end)

hooksecurefunc("FCF_CreateMinimizedFrame", function(frame)
	local min = _G[frame:GetName().."Minimized"]
	core.util.gen_backdrop(min)
	core.util.fix_string(min.Text)
	core.util.set_inside(min.glow, min)

	min.leftTexture:SetTexture()
	min.rightTexture:SetTexture()
	min.middleTexture:SetTexture()

	min.leftHighlightTexture:SetTexture()
	min.rightHighlightTexture:SetTexture()
	min.middleHighlightTexture:SetTexture()

	min:SetHighlightTexture(core.media.textures.blank)
	min:GetHighlightTexture():SetVertexColor(.6, .6, .6, .3)
	min:GetHighlightTexture():SetAllPoints(min.glow)

	local max = _G[min:GetName().."MaximizeButton"]
	max:SetSize(20, 20)

	local normal = max:GetNormalTexture()
	normal:SetTexture([[interface/moneyframe/arrow-right-up]])
	normal:SetTexCoord(-.1, .6, 0, 1)
	core.util.set_inside(normal, max)

	local pushed = max:GetPushedTexture()
	pushed:SetTexture([[interface/moneyframe/arrow-right-down]])
	pushed:SetTexCoord(0, .6, 0, 1)
	pushed:SetAllPoints(normal)

	local highlight = max:GetHighlightTexture()
	highlight:SetTexture()
end)

hooksecurefunc("FCFMin_UpdateColors", function(frame)
	local r, g, b = unpack(core.player.color)
	frame:GetFontString():SetTextColor(r, g, b)
	frame.glow:SetVertexColor(r, g, b)
	frame.conversationIcon:SetVertexColor(r, g, b)
end)

local fix_button_side = function(frame)
	frame.buttonFrame:ClearAllPoints()
	frame.buttonFrame:SetPoint("TOPLEFT", frame.backdrop, "TOPRIGHT", 1, 0)
	frame.buttonFrame:SetPoint("BOTTOMLEFT", frame.backdrop, "BOTTOMRIGHT", 1, 0)
end

hooksecurefunc("FCF_SetButtonSide", fix_button_side)

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	skin_chat_frame(frame)
end

ChatAlertFrame:SetPoint("BOTTOMLEFT", ChatFrame1.editBox, "TOPLEFT", 0, 5)

GeneralDockManager:SetPoint("BOTTOMLEFT", ChatFrame1.backdrop, "TOPLEFT")
GeneralDockManager:SetPoint("BOTTOMRIGHT", ChatFrame1.backdrop, "TOPRIGHT")

ChatFrameMenuButton:ClearAllPoints()
ChatFrameMenuButton:SetPoint("BOTTOMLEFT", ChatFrame1ButtonFrame, "BOTTOMLEFT")
ChatFrameMenuButton:SetSize(24, 24)
skin_button(ChatFrameMenuButton, [[interface/gossipframe/chatbubblegossipicon]])

ChatFrameChannelButton:ClearAllPoints()
ChatFrameChannelButton:SetPoint("TOPLEFT", ChatFrame1ButtonFrame, "TOPLEFT")
ChatFrameChannelButton:SetSize(24, 24)
skin_button(ChatFrameChannelButton, nil, 0, .9, .1, 1)
ChatFrameChannelButton.Flash:SetAllPoints()
ChatFrameChannelButton.Flash:SetTexture(core.media.textures.blank)
ChatFrameChannelButton.Flash:SetVertexColor(.5, .5, 0, .5)

ChatFrameToggleVoiceDeafenButton:ClearAllPoints()
ChatFrameToggleVoiceDeafenButton:SetPoint("TOPLEFT", ChatFrameChannelButton, "BOTTOMLEFT", 0, -1)
ChatFrameToggleVoiceDeafenButton:SetSize(24, 24)
skin_button(ChatFrameToggleVoiceDeafenButton)

ChatFrameToggleVoiceMuteButton:ClearAllPoints()
ChatFrameToggleVoiceMuteButton:SetPoint("TOPLEFT", ChatFrameToggleVoiceDeafenButton, "BOTTOMLEFT", 0, -1)
ChatFrameToggleVoiceMuteButton:SetSize(24, 24)
skin_button(ChatFrameToggleVoiceMuteButton)

QuickJoinToastButton:EnableMouse(false)
for _, region in ipairs({QuickJoinToastButton:GetRegions()}) do
	if region:GetObjectType() == "Texture" then
		region:SetTexture()
	end
	region:Hide()
end

fix_button_side(ChatFrame1)

core.settings:add_action("Dock Chat", dock_chat)
core.settings:add_action("Reset Chat", setup_chat)
