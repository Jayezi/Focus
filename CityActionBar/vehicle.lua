local addon, ns = ...
local cfg = ns.cfg
local lib = ns.lib

-- Leaving both ways here for now just to see how they go

-- Reuse the default button
MainMenuBarVehicleLeaveButton.oldSetPoint = MainMenuBarVehicleLeaveButton.SetPoint
MainMenuBarVehicleLeaveButton.SetPoint = function(self)
	self:oldSetPoint(unpack(cfg.bars.vehicle.pos))
end

MainMenuBarVehicleLeaveButton:HookScript("OnShow", function(self)
	lib.style_vehicle(self)
	self:SetSize(50, 50)
	self:SetScale(1 / cfg.bars.main.scale)
	self:SetPoint()
end)

-- Make my own

local vehicle = CreateFrame("Button", "CityExitVehicle", UIParent)

function vehicle:VehicleOnEvent(event)
    if CanExitVehicle() then
        self:Show()
    else
        self:Hide()
    end
end

function vehicle:VehicleOnClick()
    if (UnitOnTaxi("player")) then
        TaxiRequestEarlyLanding()
		print("Requested early landing from flight path.")
    else
        VehicleExit()
		print("Exiting vehicle.")
    end
end

vehicle:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 5, -5)
vehicle:SetSize(80, 50)
vehicle:SetFrameStrata("TOOLTIP")

CityUi.util.gen_backdrop(vehicle)

vehicle:SetFrameStrata("MEDIUM")
vehicle:SetFrameLevel(10)
vehicle:EnableMouse(true)
vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", vehicle.VehicleOnClick)
vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicle:RegisterEvent("VEHICLE_UPDATE")
vehicle:Hide()
vehicle:SetScript("OnEvent", vehicle.VehicleOnEvent)
vehicle:SetScript("OnEnter", function()
	ShowUIPanel(GameTooltip)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
	
	if (UnitOnTaxi("player")) then
		GameTooltip:AddLine("Request Stop")
	else
		GameTooltip:AddLine("Leave Vehicle")
	end
	
	GameTooltip:Show()
end)

vehicle:SetScript("OnLeave", function() 
	GameTooltip:Hide()
end)

vehicle.text = vehicle:CreateFontString(nil, "OVERLAY")
vehicle.text:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_lrg, CityUi.config.font_flags)
vehicle.text:SetText("Exit")
vehicle.text:SetAllPoints(vehicle)
vehicle.text:SetJustifyH("CENTER")
