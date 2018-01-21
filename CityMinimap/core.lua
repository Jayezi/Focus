local CityUi = CityUi

local function strip_textures(object)
	for i = 1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		end
	end
end

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

CityUi.util.gen_backdrop(Minimap)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
Minimap:SetSize(175, 175)
Minimap:SetArchBlobRingScalar(0);
Minimap:SetQuestBlobRingScalar(0);
Minimap:SetMaskTexture(CityUi.media.textures.blank)
function GetMinimapShape() return "SQUARE" end

TimeManagerClockButton:SetSize(50, 30)
TimeManagerClockButton:SetHitRectInsets(0, 0, 0, 0)
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOMRIGHT", Minimap)

local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
clockTime:SetShadowOffset(0, 0)
clockTime:SetTextColor(1, 1, 1, 1)
clockTime:SetJustifyH("CENTER")
clockTime:SetJustifyV("MIDDLE")
clockTime:SetAllPoints(TimeManagerClockButton)
clockTime:Show()

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOP", Minimap)

MiniMapVoiceChatFrame:ClearAllPoints()
MiniMapVoiceChatFrame:SetPoint("RIGHT", Minimap)

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapBackdrop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapNorthTag:SetTexture(nil)
MinimapZoneTextButton:Hide()
MiniMapWorldMapButton:Hide()

GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("BOTTOMRIGHT", TimeManagerClockButton, "BOTTOMLEFT", 0, 0)
GameTimeFrame:SetNormalTexture(nil)
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture(nil)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:SetSize(30, 30)

local game_time_string = GameTimeFrame:GetFontString()
game_time_string:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
game_time_string:SetTextColor(1, 1, 1, 1)
game_time_string:SetAllPoints(GameTimeFrame)
game_time_string:SetJustifyH("CENTER")
game_time_string:SetJustifyV("MIDDLE")

MiniMapMailFrame:SetSize(30, 30)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPLEFT", Minimap)
strip_textures(MiniMapMailFrame)
MiniMapMailIcon:SetTexture("Interface\\Minimap\\TRACKING\\Mailbox")

GarrisonLandingPageMinimapButton:SetSize(40, 40)
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetParent(Minimap)
GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap)
GarrisonLandingPageMinimapButton:SetHitRectInsets(0, 0, 0, 0)

QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("LEFT", Minimap)
QueueStatusMinimapButtonBorder:Hide()

MiniMapTracking:SetSize(30, 30)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPRIGHT", Minimap)
MiniMapTrackingButton:SetHitRectInsets(0, 0, 0, 0)
strip_textures(MiniMapTrackingButton)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 then
		MinimapZoomIn:Click()
	elseif delta < 0 then
		MinimapZoomOut:Click()
	end
end)

local menu_frame = CreateFrame("Frame", "CityUiMapMenu", UIParent, "UIDropDownMenuTemplate")
local menu_list = {
	{
		text = "Micro Menu",
		isTitle = true,
		notCheckable = true
	},
	{
		text = CHARACTER,
		icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
		func = function()
			securecall(ToggleCharacter, 'PaperDollFrame')
		end,
		notCheckable = true
	},
	{
		text = SPELLBOOK,
		icon = 'Interface\\MINIMAP\\TRACKING\\Class',
		func = function()
			securecall(ToggleSpellBook, BOOKTYPE_SPELL)
		end,
		notCheckable = true,
	},
	{
		text = TALENTS,
		icon = 'Interface\\MINIMAP\\TRACKING\\Ammunition',
		func = function()
			if (not PlayerTalentFrame) then
				LoadAddOn('Blizzard_TalentUI')
			end

			if (not GlyphFrame) then
				LoadAddOn('Blizzard_GlyphUI')
			end

			securecall(ToggleTalentFrame)
		end,
		notCheckable = true,
	},
	{
		text = INVENTORY_TOOLTIP,
		icon = 'Interface\\MINIMAP\\TRACKING\\Banker',
		func = function()
			securecall(ToggleAllBags)
		end,
		notCheckable = true,
	},
	{
		text = ACHIEVEMENTS,
		icon = 'Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Shield',
		func = function()
			securecall(ToggleAchievementFrame)
		end,
		notCheckable = true,
	},
	{
		text = QUESTLOG_BUTTON,
		icon = 'Interface\\GossipFrame\\ActiveQuestIcon',
		func = function()
			securecall(ToggleFrame, WorldMapFrame)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, QUESTLOG_BUTTON, 'TOGGLEQUESTLOG'),
		tooltipText = NEWBIE_TOOLTIP_QUESTLOG,
		notCheckable = true,
	},
	{
		text = FRIENDS,
		icon = 'Interface\\FriendsFrame\\PlusManz-BattleNet',
		func = function()
			securecall(ToggleFriendsFrame, 1)
		end,
		notCheckable = true,
	},
	{
		text = GUILD,
		icon = 'Interface\\GossipFrame\\TabardGossipIcon',
		arg1 = IsInGuild('player'),
		func = function()
			if (IsTrialAccount()) then
				UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT, 1, 0, 0)
			else
				securecall(ToggleGuildFrame)
			end
		end,
		notCheckable = true,
	},
	{
		text = GROUP_FINDER,
		icon = 'Interface\\LFGFRAME\\BattleNetWorking0',
		func = function()
			securecall(PVEFrame_ToggleFrame, 'GroupFinderFrame', LFDParentFrame)
		end,
		notCheckable = true,
	},
	{
		text = PLAYER_V_PLAYER,
		icon = 'Interface\\MINIMAP\\TRACKING\\BattleMaster',
		func = function()
			securecall(PVEFrame_ToggleFrame, 'PVPUIFrame', HonorFrame)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, PLAYER_V_PLAYER, 'TOGGLECHARACTER4'),
		tooltipText = NEWBIE_TOOLTIP_PVP,
		notCheckable = true,
	},
	{
		text = ENCOUNTER_JOURNAL,
		icon = 'Interface\\MINIMAP\\TRACKING\\Profession',
		func = function()
			securecall(ToggleEncounterJournal)
		end,
		notCheckable = true,
	},
	{
		text = MOUNTS,
		icon = 'Interface\\MINIMAP\\TRACKING\\StableMaster',
		func = function()
			securecall(ToggleCollectionsJournal, 1)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, MOUNTS_AND_PETS, 'TOGGLEPETJOURNAL'),
		notCheckable = true,
	},
	{
		text = PETS,
		icon = 'Interface\\MINIMAP\\TRACKING\\StableMaster',
		func = function()
			securecall(ToggleCollectionsJournal, 2)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, MOUNTS_AND_PETS, 'TOGGLEPETJOURNAL'),
		notCheckable = true,
	},
	{
		text = TOY_BOX,
		icon = 'Interface\\MINIMAP\\TRACKING\\Reagents',
		func = function()
			securecall(ToggleCollectionsJournal, 3)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, TOY_BOX, 'TOGGLETOYBOX'),
		notCheckable = true,
	},
	{
		text = "Heirlooms",
		icon = 'Interface\\MINIMAP\\TRACKING\\Reagents',
		func = function()
			securecall(ToggleCollectionsJournal, 4)
		end,
		tooltipTitle = securecall(MicroButtonTooltipText, TOY_BOX, 'TOGGLETOYBOX'),
		notCheckable = true,
	},
	{
		text = BLIZZARD_STORE,
		icon = 'Interface\\MINIMAP\\TRACKING\\BattleMaster',
		func = function()
			if (not StoreFrame) then
				LoadAddOn('Blizzard_StoreUI')
			end
			securecall(ToggleStoreUI)
		end,
		notCheckable = true,
	},
	{
		text = GAMEMENU_HELP,
		icon = 'Interface\\CHATFRAME\\UI-ChatIcon-Blizz',
		func = function()
			securecall(ToggleHelpFrame)
		end,
		notCheckable = true,
	},
	{
		text = BATTLEFIELD_MINIMAP,
		func = function()
			securecall(ToggleBattlefieldMinimap)
		end,
		notCheckable = true,
	},
}

Minimap:SetScript("OnMouseUp", function(self, button)
	if button == "RightButton" then
		securecall(EasyMenu, menu_list, menu_frame, self, 27, 190, "MENU", 8)
	else
		Minimap_OnClick(self)
	end
end)
