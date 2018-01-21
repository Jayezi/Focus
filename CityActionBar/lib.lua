local addon, ns = ...
local cfg = ns.cfg
local lib = {}
ns.lib = lib
local CityUi = CityUi

local skin_textures = function(button, icon, normal)

	icon:SetDrawLayer("OVERLAY", -8)
	icon:SetTexCoord(.1, .9, .1, .9)
	icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

	local blank = CityUi.media.textures.blank
	
	local checked = button:GetCheckedTexture()
	checked:SetAllPoints(icon)
	checked:SetTexture(blank)
	checked:SetVertexColor(unpack(cfg.color.checked))
	checked.SetAlpha = function() return end
	
	local pushed = button:GetPushedTexture()
	pushed:SetDrawLayer("OVERLAY", -6)
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(cfg.color.pressed))

	button:SetNormalTexture("")
	if normal then
		normal.SetTexCoord = function() return end
		button.SetNormalTexture = function() return end
	end

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))

end

lib.style_action = function(button)
	if not button or button.styled then
		return
	end
	button.styled = true

	local r, g, b = unpack(CityUi.config.frame_background)
	CityUi.util.gen_backdrop(button, r, g, b, .6)

	local action = button.action
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	local count  = _G[name.."Count"]
	local border  = _G[name.."Border"]
	local hotkey  = _G[name.."HotKey"]
	local cooldown = _G[name.."Cooldown"]
	
	local macro  = _G[name.."Name"]
	local flash  = _G[name.."Flash"]
	local fbg  = _G[name.."FloatingBG"]
	local fob = _G[name.."FlyoutBorder"]
	local fobs = _G[name.."FlyoutBorderShadow"]

	if fbg then fbg:Hide() end
	if fob then fob:SetTexture("") end
	if fobs then fobs:SetTexture("") end
	if border then
		border:SetTexture(CityUi.media.textures.blank)
		border:SetAllPoints(button)
		border:SetDrawLayer("BORDER")
	end

	skin_textures(button, icon)

	local text_overlay = CreateFrame("Frame", nil, button)
	text_overlay:SetAllPoints(button)
	text_overlay:SetFrameStrata("TOOLTIP")

	count:SetDrawLayer("OVERLAY", 7)
	count:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	count:ClearAllPoints()
	count:SetParent(text_overlay)
	count:SetPoint("TOPLEFT", -1, 3)
	count:SetJustifyH("LEFT")
	count:SetJustifyV("TOP")

	if hotkey then
		hotkey:SetDrawLayer("OVERLAY", 7)
		hotkey:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
		hotkey:ClearAllPoints()
		hotkey:SetParent(text_overlay)
		hotkey:SetPoint("TOPRIGHT", 0, 1)
		hotkey:SetPoint("TOPLEFT", count, "TOPRIGHT", 3, 0)
		hotkey:SetJustifyH("RIGHT")
		hotkey:SetJustifyV("TOP")
	end

	if macro then
		macro:SetDrawLayer("OVERLAY", 7)
		macro:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_sml, CityUi.config.font_flags)
		macro:SetShadowOffset(0, 0)
		macro:ClearAllPoints()
		macro:SetParent(text_overlay)
		macro:SetPoint("BOTTOMLEFT", 0, -1)
		macro:SetPoint("BOTTOMRIGHT", 0, -1)
		macro:SetJustifyH("LEFT")
		macro:SetJustifyV("BOTTOM")
	end

	cooldown:SetAllPoints(icon)
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	cooldown:GetRegions():SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_lrg, CityUi.config.font_flags)
	cooldown:GetRegions():SetShadowOffset(0, 0)
end

lib.style_vehicle = function(button)

	if not button or button.style then return end
	button.styled = true

	CityUi.util.gen_backdrop(button)

	local blank = CityUi.media.textures.blank
	
	local pushed = button:GetPushedTexture()
	pushed:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	pushed:SetTexCoord(.2, .8, .2, .8)

	local normal = button:GetNormalTexture()
	normal:SetPoint("TOPLEFT", 1, -1)
	normal:SetPoint("BOTTOMRIGHT", -1, 1)
	normal:SetTexCoord(.2, .8, .2, .8)

	local highlight = button:GetHighlightTexture()
	highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end


lib.style_pet = function(button)
	if not button or button.styled then return end
	button.styled = true
	
	CityUi.util.gen_backdrop(button)
	
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	local hotkey  = _G[name.."HotKey"]
	local normal2  = _G[name.."NormalTexture2"]
	local auto = _G[name.."AutoCastable"]
	local shine = _G[name.."Shine"]
	local cooldown = _G[name.."Cooldown"]

	skin_textures(button, icon, normal2)
	
	local text_overlay = CreateFrame("Frame", nil, button)
	text_overlay:SetAllPoints(button)
	text_overlay:SetFrameStrata("TOOLTIP")

	auto:SetParent(text_overlay)
	auto:SetTexCoord(.18, .82, .16, .82)
	auto:SetPoint("TOPLEFT", icon, -5, 5)
	auto:SetPoint("BOTTOMRIGHT", icon, 5, -5)

	shine:SetPoint("TOPLEFT", icon, 1, -1)
	shine:SetPoint("BOTTOMRIGHT", icon, -1, 1)

	hotkey:SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_sml, CityUi.config.font_flags)
	hotkey:ClearAllPoints()
	hotkey:SetParent(text_overlay)
	hotkey:SetPoint("TOPRIGHT", button, 3, 1)
	hotkey:SetPoint("TOPLEFT", button, 0, 1)

	cooldown:SetAllPoints(icon)
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	cooldown:GetRegions():SetFont(CityUi.media.fonts.pixel_10, CityUi.config.font_size_med, CityUi.config.font_flags)
	cooldown:GetRegions():SetShadowOffset(0, 0)
end

lib.style_stance = function(button)
	if not button or button.styled then return end
	button.styled = true
	
	CityUi.util.gen_backdrop(button)
	
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	
	skin_textures(button, icon)
end

lib.style_bag = function(button)
	if not button or button.styled then return end
	button.styled = true
	
	CityUi.util.gen_backdrop(button)

	local name = button:GetName()
	local icon = _G[name.."IconTexture"]
	local normal = _G[name.."NormalTexture"]
	local border = button["IconBorder"]

	border.Show = function() end
	border:Hide()
	
	skin_textures(button, icon, normal)
end
