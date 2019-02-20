local addon, cab = ...
local cfg = cab.cfg
local lib = cab.lib

local vehicle = CreateFrame("Button", "CityExitVehicleButton", UIParent)

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

vehicle:SetPoint("BOTTOMRIGHT", _G["CityBagBar"], "BOTTOMLEFT", -10, 0)
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
vehicle.text:SetFont(CityUi.config.default_font, CityUi.config.font_size_med, CityUi.config.font_flags)
vehicle.text:SetText("Vehicle")
vehicle.text:SetAllPoints(vehicle)
vehicle.text:SetJustifyH("CENTER")
