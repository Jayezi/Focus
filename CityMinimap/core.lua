local cui = CityUi

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

cui.util.gen_border(MinimapCluster)
MinimapCluster:SetSize(250, 250)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)

Minimap:SetSize(249, 249)
cui.util.set_inside(Minimap, MinimapCluster)
Minimap:SetArchBlobRingScalar(0);
Minimap:SetQuestBlobRingScalar(0);
Minimap:SetMaskTexture(cui.media.textures.blank)
MinimapBackdrop:SetAllPoints(Minimap)
function GetMinimapShape() return "SQUARE" end



local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
clockTime:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
clockTime:SetShadowOffset(0, 0)
clockTime:SetTextColor(1, 1, 1, 1)
clockTime:SetJustifyH("RIGHT")
clockTime:SetJustifyV("BOTTOM")
clockTime:ClearAllPoints()
clockTime:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
clockTime:Show()

TimeManagerClockButton:SetHitRectInsets(0, 0, 0, 0)
TimeManagerClockButton:SetAllPoints(clockTime)

MinimapZoneText:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetShadowOffset(0, 0)
MinimapZoneText:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 5, -5)
MinimapZoneText:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -5)

MinimapZoneTextButton:SetAllPoints(MinimapZoneText)

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapNorthTag:SetTexture(nil)
MiniMapWorldMapButton:Hide()

local game_time_string = GameTimeFrame:GetFontString()
game_time_string:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
game_time_string:SetTextColor(1, 1, 1, 1)
game_time_string:ClearAllPoints()
game_time_string:SetPoint("TOPRIGHT", clockTime, "TOPLEFT", -5, 0)
game_time_string:SetPoint("BOTTOMRIGHT", clockTime, "BOTTOMLEFT", -5, 0)
game_time_string:SetJustifyH("CENTER")
game_time_string:SetJustifyV("MIDDLE")

GameTimeFrame:SetAllPoints(game_time_string)
GameTimeFrame:SetNormalTexture(nil)
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture(nil)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)

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
MiniMapTracking:SetPoint("TOPRIGHT", -5, -5)
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

DurabilityFrame:ClearAllPoints()
DurabilityFrame.oldSetPoint = DurabilityFrame.SetPoint
DurabilityFrame.SetPoint = function(self) 
	self:oldSetPoint("BOTTOMRIGHT", MinimapCluster, "BOTTOMLEFT", -20, 5)
end

VehicleSeatIndicator:ClearAllPoints()
VehicleSeatIndicator.oldSetPoint = VehicleSeatIndicator.SetPoint
VehicleSeatIndicator.SetPoint = function(self) 
	self:oldSetPoint("TOPRIGHT", MinimapCluster, "BOTTOMLEFT", -20, -5)
end

style_children(ObjectiveTrackerBlocksFrame)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 then
		MinimapZoomIn:Click()
	elseif delta < 0 then
		MinimapZoomOut:Click()
	end
end)
