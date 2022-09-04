local _, addon = ...
if not addon.raid.enabled then return end
local core = addon.core

-- disable raid/party frames
if true then

    hooksecurefunc("CompactPartyFrame_Generate", function()
        CompactPartyFrame.title:Hide()
    end)

    hooksecurefunc("CompactRaidGroup_GenerateForGroup", function(index)
        _G["CompactRaidGroup"..index]:Hide()
    end)

    hooksecurefunc("CompactUnitFrame_RegisterEvents", function(frame)
        if frame:IsForbidden() then return end
        if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
            return
        end
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
        frame:EnableMouse(false)
    end)

    hooksecurefunc("CompactUnitFrame_UpdateVisible", function(frame)
        if frame:IsForbidden() then return end
        if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
            return
        end
        if InCombatLockdown() then
            frame:SetAlpha(0)
        else
            frame:Hide()
        end
    end)

    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
    	if frame:IsForbidden() then return end
    	if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
    		return
    	end
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
        frame:EnableMouse(false)
    end)

    hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
    	if frame:IsForbidden() then return end
    	if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
    		return
    	end
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame:SetScript("OnUpdate", nil)
    	frame:RegisterForClicks()
        frame:EnableMouse(false)
    end)

    return
end

local init_unitframe = function(frame)
	frame.background:ClearAllPoints()
	frame.background:SetPoint("TOPLEFT", -1, 1)
    frame.background:SetPoint("BOTTOMRIGHT")
	frame.background:SetColorTexture(unpack(core.config.color.border))

	frame.myHealPrediction:SetColorTexture(0.25, 0.75, 0.25, 0.75)
	frame.totalAbsorb:SetColorTexture(0.75, 0.75, 0.5, 0.25)
	frame.myHealAbsorb:SetColorTexture(0.25, 0.25, 0.25, 0.75)

	frame.myHealAbsorbLeftShadow:SetTexture()
	frame.myHealAbsorbRightShadow:SetTexture()
	frame.otherHealPrediction:SetTexture()
	frame.totalAbsorbOverlay:SetTexture()
	frame.overAbsorbGlow:SetTexture()
	frame.overHealAbsorbGlow:SetTexture()
	
	frame.roleIcon:ClearAllPoints()
	frame.roleIcon:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT", -1, 1)
	frame.roleIcon:SetSize(12, 12)

	frame.role = core.util.gen_string(frame, nil, nil, core.media.fonts.role_symbols)
	frame.role:SetJustifyH("LEFT")
	frame.role:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")

	frame.name:ClearAllPoints()
	frame.name:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT")
	frame.name:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
	core.util.fix_string(frame.name, core.config.font_size_med)

    frame.statusText:ClearAllPoints()
    frame.statusText:SetPoint("CENTER", frame.healthBar)
    core.util.fix_string(frame.statusText, core.config.font_size_med)

    frame.readyCheckIcon:ClearAllPoints()
	frame.readyCheckIcon:SetPoint("CENTER", frame.healthBar)
	frame.readyCheckIcon:SetSize(20, 20)

    frame.centerStatusIcon:ClearAllPoints()
	frame.centerStatusIcon:SetPoint("CENTER", frame.healthBar)
	frame.centerStatusIcon:SetSize(25, 25)
	
	frame.healthBar:SetPoint("TOPLEFT")
	frame.healthBar:SetStatusBarTexture(core.media.textures.blank)
	if frame.powerBar then
		frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -1)
		frame.powerBar:SetStatusBarTexture(core.media.textures.blank)
		frame.powerBar.background:SetColorTexture(unpack(core.config.frame_background))
	end

	frame.debuffFrames[1]:ClearAllPoints()
	frame.debuffFrames[1]:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 1, 1)
	for i, aura in ipairs(frame.debuffFrames) do
		local text_overlay = CreateFrame("Frame", aura:GetName().."TextOverlay", aura)
		text_overlay:SetFrameLevel(aura.cooldown:GetFrameLevel() + 1)
		text_overlay:SetAllPoints(aura)
		aura.count:SetParent(text_overlay)
		aura.count:ClearAllPoints()
		aura.count:SetPoint("CENTER", text_overlay, "TOPRIGHT", -2, -2)

		if ( i > 1 ) then
			aura:ClearAllPoints()
			aura:SetPoint("TOPRIGHT", frame.debuffFrames[i - 1], "TOPLEFT", -1, 0)
		end
		
		aura.border:SetAllPoints(aura)
		aura.border:SetTexture(core.media.textures.blank)
		aura.border:SetDrawLayer("BACKGROUND")
		core.util.set_inside(aura.icon, aura)
		core.util.set_inside(aura.cooldown, aura)
		aura:SetSize(18, 18)
	end

	frame.buffFrames[1]:ClearAllPoints()
	frame.buffFrames[1]:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", -1, -18)
	for i, aura in ipairs(frame.buffFrames) do
		local text_overlay = CreateFrame("Frame", aura:GetName().."TextOverlay", aura)
		text_overlay:SetFrameLevel(aura.cooldown:GetFrameLevel() + 1)
		text_overlay:SetAllPoints(aura)
		aura.count:SetParent(text_overlay)
		aura.count:ClearAllPoints()
		aura.count:SetPoint("CENTER", text_overlay, "TOPRIGHT", -2, -2)

		if ( i > 1 ) then
			aura:ClearAllPoints()
			aura:SetPoint("TOPLEFT", frame.buffFrames[i - 1], "TOPRIGHT", -1, 0)
		end

		local border = aura:CreateTexture()
		border:SetColorTexture(unpack(core.config.color.border))
		border:SetDrawLayer("BACKGROUND")
		border:SetAllPoints(aura)
		core.util.set_inside(aura.icon, aura)
		core.util.set_inside(aura.cooldown, aura)
		aura.icon:SetTexCoord(.1, .9, .1, .9)
		aura:SetSize(18, 18)
	end

	frame.dispelDebuffFrames[1]:ClearAllPoints()
	frame.dispelDebuffFrames[1]:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", 0, -18)
	for i, aura in ipairs(frame.dispelDebuffFrames) do
		if ( i > 1 ) then
			aura:ClearAllPoints()
			aura:SetPoint("TOPRIGHT", frame.dispelDebuffFrames[i - 1], "TOPLEFT", 0, 0)
		end
		aura:SetSize(18, 18)
	end

	frame.selectionHighlight:SetAllPoints(frame.background)
	frame.selectionHighlight:SetColorTexture(1, 1, 1, 1)
	frame.selectionHighlight:SetDrawLayer("BACKGROUND", 1)

	frame.aggroHighlight:SetAllPoints(frame.background)
	frame.aggroHighlight:SetColorTexture(1, 0, 0, 1)
	frame.aggroHighlight:SetDrawLayer("BACKGROUND", 2)
end

hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame)
	if frame:IsForbidden() then return end
	if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
		return
	end
	init_unitframe(frame)
end)

hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
	if frame:IsForbidden() then return end
	if not string.find(frame:GetDebugName(), "CompactRaidFrame") and not string.find(frame:GetDebugName(), "CompactPartyFrame") then
		return
	end
	init_unitframe(frame)
end)

hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", function(frame)
	if frame:IsForbidden() then return end

	local width = frame.healthBar:GetWidth()
	local _, max = frame.healthBar:GetMinMaxValues()
	if max <= 0 then return end
	
	local current = frame.healthBar:GetValue()
	local missing = max - current
	
	local incoming = UnitGetIncomingHeals(frame.displayedUnit) or 0
	local absorbs = UnitGetTotalAbsorbs(frame.displayedUnit) or 0
	local heal_absorbs = UnitGetTotalHealAbsorbs(frame.displayedUnit) or 0

	local healthbar = frame.healthBar:GetStatusBarTexture()

	if incoming > 0 then
		frame.myHealPrediction:Show()
	end
	frame.myHealPrediction:ClearAllPoints()
	frame.myHealPrediction:SetPoint("TOPLEFT", frame.healthBar:GetStatusBarTexture(), "TOPRIGHT")
	frame.myHealPrediction:SetPoint("BOTTOMLEFT", frame.healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
	frame.myHealPrediction:SetWidth(math.min(missing, incoming) / max * width)
	
	if absorbs > 0 then
		frame.totalAbsorb:Show()
	end
	frame.totalAbsorb:ClearAllPoints()
	frame.totalAbsorb:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
	frame.totalAbsorb:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT")
	frame.totalAbsorb:SetWidth(math.min(max, absorbs) / max * width)

	if heal_absorbs > 0 then
		frame.myHealAbsorb:Show()
	end
	frame.myHealAbsorb:ClearAllPoints()
	frame.myHealAbsorb:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT")
	frame.myHealAbsorb:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
	frame.myHealAbsorb:SetWidth(math.min(max, heal_absorbs) / max * width)

end)

hooksecurefunc("CompactUnitFrame_UpdateRoleIcon", function(frame)
	if frame:IsForbidden() then return end

	if frame.roleIcon then
		frame.roleIcon:Hide()
	end
	if frame.role then
		local role = UnitGroupRolesAssigned(frame.unit)
		if role == "HEALER" then
			frame.role:SetText("|cff8AFF30H|r")
		elseif role == "TANK" then
			frame.role:SetText("|cff5F9BFFT|r")
		else
			frame.role:SetText("")
		end
	end
end)

hooksecurefunc("CompactUnitFrame_UtilSetDebuff", function(aura, _, _, _, is_boss)
	if aura:IsForbidden() then return end
	if is_boss then
		aura.icon:SetTexCoord(.1, .9, .3, .7)
		aura:SetSize(40, 20)
	else
		aura.icon:SetTexCoord(.1, .9, .1, .9)
		aura:SetSize(20, 20)
	end
end)

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if frame:IsForbidden() then return end
	frame.name:SetTextColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)
end)

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
	if frame:IsForbidden() then return end
	frame.healthBar:SetStatusBarColor(unpack(core.config.frame_background))
	frame.healthBar.background:SetColorTexture(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)
    frame.name:SetTextColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)
end)
