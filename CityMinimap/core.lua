local CityUi = CityUi

local function strip_textures(object)
	local regions = {object:GetRegions()}
	for i = 1, #regions do
		local region = regions[i]
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		end
	end
end

local function style_children(object)
	strip_textures(object)
	local children = {object:GetChildren()}
	for _, child in pairs(children) do
		style_children(child)
	end
end

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

CityUi.util.gen_backdrop(Minimap)
MinimapCluster:SetSize(270, 270)

Minimap:SetSize(250, 250)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPLEFT", 10, -10)
Minimap:SetPoint("BOTTOMRIGHT", -10, 10)
Minimap:SetArchBlobRingScalar(0);
Minimap:SetQuestBlobRingScalar(0);
Minimap:SetMaskTexture(CityUi.media.textures.blank)
MinimapBackdrop:SetAllPoints(Minimap)
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

MinimapZoneTextButton:ClearAllPoints()
MinimapZoneTextButton:SetPoint("TOP", Minimap)
MinimapZoneTextButton:SetSize(200, 20)
MinimapZoneText:SetAllPoints()
MinimapZoneText:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
MinimapZoneText:SetShadowOffset(0, 0)

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapNorthTag:SetTexture(nil)
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

MiniMapMailFrame:SetSize(45, 45)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPLEFT")
strip_textures(MiniMapMailFrame)
MiniMapMailIcon:SetTexture("Interface\\Minimap\\TRACKING\\Mailbox")

GarrisonLandingPageMinimapButton:SetSize(45, 45)
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetParent(Minimap)
GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT")
GarrisonLandingPageMinimapButton:SetHitRectInsets(0, 0, 0, 0)

QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("LEFT", Minimap)
QueueStatusMinimapButtonBorder:Hide()

MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPRIGHT", -10, -10)
MiniMapTracking:SetSize(25, 25)

MiniMapTrackingButton:SetAllPoints(MiniMapTracking)
MiniMapTrackingIcon:SetAllPoints(MiniMapTracking)
MiniMapTrackingIcon.oldSetPoint = MiniMapTrackingIcon.SetPoint
MiniMapTrackingIcon.SetPoint = function(self) return end
MiniMapTrackingBackground:Hide()
MiniMapTrackingIconOverlay:Hide()
MiniMapTrackingButtonBorder:Hide()
MiniMapTrackingIconOverlay.oldShow = MiniMapTrackingIconOverlay.Show
MiniMapTrackingIconOverlay.Show = function(self) return end

strip_textures(MiniMapTrackingButton)

ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame.oldSetPoint = ObjectiveTrackerFrame.SetPoint
ObjectiveTrackerFrame.SetPoint = function(self)
	self:oldSetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -10)
	self:oldSetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -10)
end
ObjectiveTrackerFrame:SetHeight(500)

style_children(ObjectiveTrackerBlocksFrame)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 then
		MinimapZoomIn:Click()
	elseif delta < 0 then
		MinimapZoomOut:Click()
	end
end)
