local _, addon = ...
if not addon.map.enabled then return end

local core = addon.core

local MinimapZoomIn = MinimapZoomIn
local MinimapZoomOut = MinimapZoomOut

local strip_textures = function(object)
	local regions = {object:GetRegions()}
	for i = 1, #regions do
		local region = regions[i]
		if region:GetObjectType() == "Texture" then
			region:SetTexture()
		end
	end
end

local style_children
style_children = function(object)
	strip_textures(object)
	local children = {object:GetChildren()}
	for _, child in pairs(children) do
		style_children(child)
	end
end

GetMinimapShape = function() return "SQUARE" end

core.util.gen_border(MinimapCluster)
hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", function()
	core.util.set_inside(Minimap, MinimapCluster)
end)
core.util.set_inside(Minimap, MinimapCluster)

Minimap:SetSize(MinimapCluster:GetWidth() - 2, MinimapCluster:GetHeight() - 2)
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)
Minimap:SetMaskTexture(core.media.textures.blank)

MinimapBackdrop:SetAllPoints(Minimap)
MinimapCompassTexture:Hide()

MinimapCluster.Tracking:SetSize(25, 25)
MinimapCluster.Tracking:ClearAllPoints()
MinimapCluster.Tracking:SetPoint("TOPLEFT", 5, -5)
MinimapCluster.Tracking.Background:Hide()
MinimapCluster.Tracking.Button:SetAllPoints(MinimapCluster.Tracking)
MinimapCluster.Tracking.Button:GetPushedTexture():SetAtlas("ui-hud-minimap-tracking-up")

hooksecurefunc("MiniMapMailFrame_UpdatePosition", function()
	MinimapCluster.MailFrame:ClearAllPoints()
	MinimapCluster.MailFrame:SetPoint("TOPRIGHT", -5, -5)
end)

hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", function()
	MinimapCluster.MailFrame:ClearAllPoints()
	MinimapCluster.MailFrame:SetPoint("TOPRIGHT", -5, -5)
end)

MinimapCluster.MailFrame:SetSize(25, 25)
MinimapCluster.MailFrame:ClearAllPoints()
MinimapCluster.MailFrame:SetPoint("TOPRIGHT", -5, -5)
MiniMapMailIcon:SetAllPoints()

MinimapCluster.BorderTop:Hide()
core.util.fix_string(MinimapZoneText, core.config.font_size_med)
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint("TOP", Minimap, "TOP", 0, -5)
MinimapZoneText:SetPoint("LEFT", MinimapCluster.Tracking, "RIGHT", 5, 0)
MinimapZoneText:SetPoint("RIGHT", MinimapCluster.MailFrame, "LEFT", -5, 0)
MinimapZoneText:SetJustifyH("CENTER")
MinimapZoneText:SetJustifyV("TOP")
MinimapCluster.ZoneTextButton:SetAllPoints(MinimapZoneText)

ExpansionLandingPageMinimapButton:ClearAllPoints()
ExpansionLandingPageMinimapButton:SetPoint("BOTTOMLEFT")

hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIconForGarrison", function(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT")
end)

MinimapCluster.InstanceDifficulty:ClearAllPoints()
MinimapCluster.InstanceDifficulty:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)

hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", function(self)
	self.InstanceDifficulty:ClearAllPoints()
	self.InstanceDifficulty:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)
end)


Minimap.ZoomHitArea:ClearAllPoints()
Minimap.ZoomHitArea:SetPoint("RIGHT")
Minimap.ZoomIn:ClearAllPoints()
Minimap.ZoomIn:SetPoint("BOTTOMRIGHT", MinimapCluster, "RIGHT", -2, 2)
Minimap.ZoomOut:ClearAllPoints()
Minimap.ZoomOut:SetPoint("TOPRIGHT", MinimapCluster, "RIGHT", -2, -2)

-- clock

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

core.util.fix_string(TimeManagerClockTicker, core.config.font_size_med)
TimeManagerClockTicker:SetJustifyH("RIGHT")
TimeManagerClockTicker:SetJustifyV("BOTTOM")
TimeManagerClockTicker:ClearAllPoints()
TimeManagerClockTicker:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -3, 3)
TimeManagerClockButton:SetHitRectInsets(0, 0, 0, 0)
TimeManagerClockButton:SetAllPoints(TimeManagerClockTicker)
TimeManagerAlarmFiredTexture:SetTexture()

-- calendar

GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame.date = core.util.gen_string(GameTimeFrame)
GameTimeFrame.date:SetText(C_DateAndTime.GetCurrentCalendarTime().monthDay)
GameTimeFrame.date:SetPoint("TOPRIGHT", TimeManagerClockTicker, "TOPLEFT", -5, 0)
GameTimeFrame.date:SetPoint("BOTTOMRIGHT", TimeManagerClockTicker, "BOTTOMLEFT", -5, 0)
GameTimeFrame:SetAllPoints(GameTimeFrame.date)

GameTimeFrame:SetNormalTexture("")
GameTimeFrame:SetPushedTexture("")
GameTimeFrame:SetHighlightTexture("")

hooksecurefunc("GameTimeFrame_SetDate", function()
	GameTimeFrame.date:SetText(C_DateAndTime.GetCurrentCalendarTime().monthDay)
	GameTimeFrame:GetNormalTexture():SetTexture()
	GameTimeFrame:GetPushedTexture():SetTexture()
	GameTimeFrame:GetHighlightTexture():SetTexture()
end)

GameTimeCalendarInvitesTexture:SetTexture()
GameTimeCalendarInvitesGlow:SetTexture()
GameTimeCalendarEventAlarmTexture:SetTexture()

-- objectives

-- if not IsAddOnLoaded("Blizzard_ObjectiveTracker") then
-- 	LoadAddOn("Blizzard_ObjectiveTracker")
-- end

-- hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", function(self)
-- 	self.Bar.BorderLeft:Hide()
-- 	self.Bar.BorderRight:Hide()
-- 	self.Bar.BorderMid:Hide()
	
-- 	if not self.Bar.styled then
-- 		self.Bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
-- 		self.Bar:SetStatusBarTexture(core.media.textures.blank);
-- 		core.util.gen_backdrop(self.Bar)
-- 		self.Bar.styled = true
-- 	end
-- end)

-- hooksecurefunc("BonusObjectiveTrackerProgressBar_UpdateReward", function(self)
-- 	self.Bar.IconBG:Hide()
-- end)

-- hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", function(self)
-- 	self.Bar.BarFrame:Hide()
-- 	self.Bar.IconBG:Hide()
-- 	self.Bar.BarFrame2:Hide()
-- 	self.Bar.BarFrame3:Hide()
-- 	self.Bar.BarBG:Hide()	
-- 	self.Bar.BarGlow:Hide()
-- 	self.Bar.Sheen:Hide()
-- 	self.Bar.Starburst:Hide()

-- 	self.Bar.Icon:SetMask(nil)
-- 	self.Bar.Icon:SetTexCoord(.1, .9, .1, .9);

-- 	if not self.Bar.styled then
-- 		self.Bar:SetHeight(18)
-- 		self.Bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
-- 		self.Bar:SetStatusBarTexture(core.media.textures.blank)
-- 		core.util.gen_backdrop(self.Bar)
		
-- 		self.Bar.Icon.border = self.Bar:CreateTexture()
-- 		self.Bar.Icon.border:SetDrawLayer("BACKGROUND", -2)
-- 		core.util.set_outside(self.Bar.Icon.border, self.Bar.Icon)
-- 		self.Bar.Icon.border:SetTexture(core.media.textures.blank)
-- 		self.Bar.Icon.border:SetVertexColor(unpack(core.config.frame_border))
-- 		self.Bar.Icon:SetPoint("RIGHT", 32, 0)
		
-- 		self.Bar.styled = true
-- 	end
-- end)

hooksecurefunc("ObjectiveTracker_AddHeader", function(header)
	header.Background:Hide()
end)

-- ObjectiveTrackerFrame.alt_SetPoint = ObjectiveTrackerFrame.SetPoint
-- hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(self)
-- 	self:alt_SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -10)
-- end)

-- DurabilityFrame.alt_SetPoint = DurabilityFrame.SetPoint
-- hooksecurefunc(DurabilityFrame, "SetPoint", function(self)
-- 	self:ClearAllPoints()
-- 	self:alt_SetPoint("BOTTOMRIGHT", MinimapCluster, "BOTTOMLEFT", -20, 5)
-- end)

-- VehicleSeatIndicator.alt_SetPoint = VehicleSeatIndicator.SetPoint
-- hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self)
-- 	self:ClearAllPoints()
-- 	self:alt_SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMLEFT", -20, -5)
-- end)
