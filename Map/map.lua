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

MinimapCluster:SetSize(250, 250)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
--core.util.gen_border(MinimapCluster)
core.util.set_inside(Minimap, MinimapCluster)
Minimap:SetSize(249, 249)
Minimap:SetArchBlobRingScalar(0);
Minimap:SetQuestBlobRingScalar(0);
Minimap:SetMaskTexture(core.media.textures.blank)
MinimapBackdrop:SetAllPoints(Minimap)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 then
		MinimapZoomIn:Click()
	elseif delta < 0 then
		MinimapZoomOut:Click()
	end
end)

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)
MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetPoint("TOP", MinimapZoneText, "BOTTOM", 0, -5)

-- MinimapBorder:Hide()
-- MinimapBorderTop:Hide()
-- MinimapZoomIn:Hide()
-- MinimapZoomOut:Hide()
-- MinimapNorthTag:SetTexture()
-- MinimapCompassTexture:SetTexture()
-- MiniMapWorldMapButton:Hide()

-- QueueStatusMinimapButton:ClearAllPoints()
-- QueueStatusMinimapButton:SetPoint("LEFT", Minimap)
-- QueueStatusMinimapButtonBorder:Hide()

-- MiniMapMailFrame:SetSize(25, 25)
-- MiniMapMailFrame:ClearAllPoints()
-- MiniMapMailFrame:SetPoint("TOPRIGHT", -5, -5)
-- MiniMapMailIcon:SetAllPoints()
-- MiniMapMailIcon:SetTexture("Interface\\Minimap\\Tracking\\Mailbox")
-- MiniMapMailBorder:Hide()

-- MiniMapTracking:SetSize(25, 25)
-- MiniMapTracking:ClearAllPoints()
-- MiniMapTracking:SetPoint("TOPLEFT", 5, -5)
-- MiniMapTrackingButton:SetAllPoints(MiniMapTracking)
-- MiniMapTrackingIcon:SetAllPoints()
-- MiniMapTrackingBackground:Hide()
-- MiniMapTrackingIconOverlay:Hide()
-- MiniMapTrackingButtonBorder:Hide()
-- MiniMapTrackingButtonShine:SetTexture()
-- MiniMapTrackingButton:GetHighlightTexture():SetTexture()

-- MiniMapTrackingButton:HookScript("OnMouseDown", function()
-- 	MiniMapTrackingIcon:SetAllPoints()
-- end);
-- MiniMapTrackingButton:HookScript("OnMouseUp", function()
-- 	MiniMapTrackingIcon:SetAllPoints()
-- end);

-- core.util.fix_string(MinimapZoneText, core.config.font_size_med)
-- MinimapZoneText:ClearAllPoints()
-- MinimapZoneText:SetPoint("TOP", Minimap, "TOP", 0, -5)
-- MinimapZoneText:SetPoint("LEFT", MiniMapTracking, "RIGHT", 5, 0)
-- MinimapZoneText:SetPoint("RIGHT", MiniMapMailFrame, "LEFT", -5, 0)
-- MinimapZoneTextButton:SetAllPoints(MinimapZoneText)

-- clock

if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

-- local clock_bg, clock_ticker, alarm_fired = TimeManagerClockButton:GetRegions()
-- clock_bg:Hide()
-- alarm_fired:SetTexture()
-- core.util.fix_string(clock_ticker, core.config.font_size_med)
-- clock_ticker:SetTextColor(1, 1, 1, 1)
-- clock_ticker:SetJustifyH("RIGHT")
-- clock_ticker:SetJustifyV("BOTTOM")
-- clock_ticker:ClearAllPoints()
-- clock_ticker:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
-- clock_ticker:Show()
-- TimeManagerClockButton:SetHitRectInsets(0, 0, 0, 0)
-- TimeManagerClockButton:SetAllPoints(clock_ticker)

-- calendar

-- local game_time_string = GameTimeFrame:GetFontString()
-- core.util.fix_string(game_time_string)
-- game_time_string:SetTextColor(1, 1, 1, 1)
-- game_time_string:ClearAllPoints()
-- game_time_string:SetPoint("TOPRIGHT", clock_ticker, "TOPLEFT", -5, 0)
-- game_time_string:SetPoint("BOTTOMRIGHT", clock_ticker, "BOTTOMLEFT", -5, 0)
-- game_time_string:SetJustifyH("CENTER")
-- game_time_string:SetJustifyV("MIDDLE")
-- GameTimeCalendarInvitesTexture:SetTexture()
-- GameTimeCalendarInvitesGlow:SetTexture()
-- GameTimeCalendarEventAlarmTexture:SetTexture()
-- GameTimeFrame:SetAllPoints(game_time_string)
-- GameTimeFrame:SetNormalTexture(nil)
-- GameTimeFrame:SetPushedTexture(nil)
-- GameTimeFrame:SetHighlightTexture(nil)
-- GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)

-- objectives

if not IsAddOnLoaded("Blizzard_ObjectiveTracker") then
	LoadAddOn("Blizzard_ObjectiveTracker")
end

hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", function(self)
	self.Bar.BorderLeft:Hide()
	self.Bar.BorderRight:Hide()
	self.Bar.BorderMid:Hide()
	
	if not self.Bar.styled then
		self.Bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
		self.Bar:SetStatusBarTexture(core.media.textures.blank);
		core.util.gen_backdrop(self.Bar)
		self.Bar.styled = true
	end
end)

hooksecurefunc("BonusObjectiveTrackerProgressBar_UpdateReward", function(self)
	self.Bar.IconBG:Hide()
end)

hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", function(self)
	self.Bar.BarFrame:Hide()
	self.Bar.IconBG:Hide()
	self.Bar.BarFrame2:Hide()
	self.Bar.BarFrame3:Hide()
	self.Bar.BarBG:Hide()	
	self.Bar.BarGlow:Hide()
	self.Bar.Sheen:Hide()
	self.Bar.Starburst:Hide()

	self.Bar.Icon:SetMask(nil)
	self.Bar.Icon:SetTexCoord(.1, .9, .1, .9);

	if not self.Bar.styled then
		self.Bar:SetHeight(18)
		self.Bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
		self.Bar:SetStatusBarTexture(core.media.textures.blank)
		core.util.gen_backdrop(self.Bar)
		
		self.Bar.Icon.border = self.Bar:CreateTexture()
		self.Bar.Icon.border:SetDrawLayer("BACKGROUND", -2)
		core.util.set_outside(self.Bar.Icon.border, self.Bar.Icon)
		self.Bar.Icon.border:SetTexture(core.media.textures.blank)
		self.Bar.Icon.border:SetVertexColor(unpack(core.config.frame_border))
		self.Bar.Icon:SetPoint("RIGHT", 32, 0)
		
		self.Bar.styled = true
	end
end)

hooksecurefunc("ObjectiveTracker_AddHeader", function(header)
	header.Background:Hide()
end)

ObjectiveTrackerFrame.alt_SetPoint = ObjectiveTrackerFrame.SetPoint
hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(self)
	self:alt_SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -10)
end)

DurabilityFrame.alt_SetPoint = DurabilityFrame.SetPoint
hooksecurefunc(DurabilityFrame, "SetPoint", function(self)
	self:ClearAllPoints()
	self:alt_SetPoint("BOTTOMRIGHT", MinimapCluster, "BOTTOMLEFT", -20, 5)
end)

VehicleSeatIndicator.alt_SetPoint = VehicleSeatIndicator.SetPoint
hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self)
	self:ClearAllPoints()
	self:alt_SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMLEFT", -20, -5)
end)

-- hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
-- 	self:ClearAllPoints()
-- 	self:SetPoint("BOTTOMLEFT")
-- end)