local addon, cab = ...
local cfg = cab.cfg
local lib = {}
cab.lib = lib
local cui = CityUi

local scripts = {
	"OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}
  
local to_hide = {
	MainMenuBar, OverrideActionBar
}
  
local to_disable = {
	MainMenuBar, MicroButtonAndBagsBar, MainMenuBarArtFrame, StatusTrackingBarManager,
	ActionBarDownButton, ActionBarUpButton, MainMenuBarVehicleLeaveButton,
	OverrideActionBar, OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame
}

local disable_scripts = function(frame)
	for i, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

lib.create_bar = function(name, num, cfg)

	local per_row = num / (cfg.rows or 1)
	local bar = CreateFrame("Frame", "City"..name.."Bar", UIParent, "SecureHandlerStateTemplate")

	if cfg.buttons.size then
		bar:SetWidth((cfg.buttons.size * (cfg.buttons.width_scale or 1) + cfg.buttons.margin) * per_row - cfg.buttons.margin)
		bar:SetHeight((cfg.buttons.size + cfg.buttons.margin) * (cfg.rows or 1) - cfg.buttons.margin)
	end
	
	local point = cfg.pos
	if point[2] == "UIParent" then
		point = {cui.util.to_tl_anchor(bar, point)}
	end
	if type(point[2]) == "string" then
		point[2] = _G[point[2]]
	end
	bar:SetPoint(unpack(point))

	if cfg.visibility then
		RegisterStateDriver(bar, "visibility", cfg.visibility or "[petbattle] hide; show")
	end

	return bar
end

lib.setup_bar = function(name, bar, num, cfg, style_func, buttons)
	local per_row = num / (cfg.rows or 1)

	for i = 1, num do
		local button = buttons and buttons[i] or _G[name.."Button"..i]

		button.short = cfg.short
		if cfg.buttons.size then
			button:SetSize(cfg.buttons.size * (cfg.buttons.width_scale or 1), cfg.buttons.size * (button.short and (2 / 3) or 1))
		end
		
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", bar)
			button:SetAttribute("flyoutDirection", "LEFT");
		elseif i % per_row == 1 then
			button:SetPoint("TOPLEFT", buttons and buttons[i - per_row] or _G[name.."Button"..(i - per_row)], "BOTTOMLEFT", 0, -cfg.buttons.margin)
			button:SetAttribute("flyoutDirection", "LEFT");
		else
			button:SetPoint("TOPLEFT", buttons and buttons[i - 1] or _G[name.."Button"..(i - 1)], "TOPRIGHT", cfg.buttons.margin, 0)
			if i % per_row == 0 then
				button:SetAttribute("flyoutDirection", "RIGHT");
			else
				button:SetAttribute("flyoutDirection", "UP");
			end
		end
		
		style_func(button)
	end
end

lib.hide_blizzard = function()
	local hidden_parent = CreateFrame("Frame")
	hidden_parent:Hide()

	hidden_parent:SetScript("OnEvent", function()
		TokenFrame_LoadUI()
		TokenFrame_Update()
		BackpackTokenFrame_Update()
	end)

	hidden_parent:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	
	for i, frame in next, to_hide do
		frame:SetParent(hidden_parent)
	end
	
	for i, frame in next, to_disable do
		frame:UnregisterAllEvents()
		disable_scripts(frame)
	end
end

local skin_textures = function(button, icon, normal)

	icon:SetDrawLayer("OVERLAY", -8)
	
	if button.short then
		icon:SetTexCoord(0.1, 0.9, 0.23, 0.77)
	else
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	cui.util.set_inside(icon, button)

	local blank = cui.media.textures.blank
	
	local checked = button:GetCheckedTexture()
	checked:SetAllPoints(icon)
	checked:SetTexture(blank)
	checked:SetVertexColor(unpack(cfg.color.checked))
	hooksecurefunc(checked, "SetAlpha", function(self, a)
		if a ~= 0.5 then
			self:SetAlpha(0.5)
		end
	end)
	
	local pushed = button:GetPushedTexture()
	pushed:SetDrawLayer("OVERLAY", -6)
	pushed:SetAllPoints(icon)
	pushed:SetTexture(blank)
	pushed:SetVertexColor(unpack(cfg.color.pressed))

	button:SetNormalTexture("")
	if normal then
		normal.SetTexCoord = function() return end
		hooksecurefunc(button, "SetNormalTexture", function(self, tex)
			if tex ~= "" then
				self:SetNormalTexture("")
			end
		end)
	end

	local highlight = button:GetHighlightTexture()
	highlight:SetAllPoints(icon)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end

lib.style_menu = function(button)
	if not button or button.styled then
		return
	end
	button.styled = true
	
	local regions = {button:GetRegions()}
	for k, v in pairs(regions) do
		v:SetTexCoord(.22, .80, .22, .81)
		v:ClearAllPoints()
		cui.util.set_inside(v, button)
	end

	local pushed = button:GetPushedTexture()
	pushed:SetTexCoord(.19, .77, .28, .86)
	
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture(cui.media.textures.blank)
	overlay:SetAllPoints()
	cui.util.set_inside(overlay, button)
	overlay:SetVertexColor(.6, .6, .6, .3)
		
	button:SetHighlightTexture(overlay)

	cui.util.gen_border(button)
end

lib.style_action = function(button)
	if not button or button.styled then
		return
	end
	button.styled = true

	local r, g, b = unpack(cui.config.frame_background)
	cui.util.gen_backdrop(button, r, g, b, .6)

	local action = button.action
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	local count  = _G[name.."Count"]
	local border  = _G[name.."Border"]
	local hotkey  = _G[name.."HotKey"]
	local cooldown = _G[name.."Cooldown"]
	local auto = button.AutoCastable
	local shine = _G[name.."Shine"]
	
	local macro  = _G[name.."Name"]
	local flash  = _G[name.."Flash"]
	local fbg  = _G[name.."FloatingBG"]
	local fob = _G[name.."FlyoutBorder"]
	local fobs = _G[name.."FlyoutBorderShadow"]

	if fbg then fbg:Hide() end
	if fob then fob:SetTexture("") end
	if fobs then fobs:SetTexture("") end
	if border then
		border:SetTexture(cui.media.textures.blank)
		border:SetAllPoints(button)
		border:SetDrawLayer("BORDER")
	end

	skin_textures(button, icon)

	local text_overlay = CreateFrame("Frame", nil, button)
	text_overlay:SetAllPoints(button)
	text_overlay:SetFrameStrata("TOOLTIP")

	count:SetDrawLayer("OVERLAY", 7)
	count:SetFont(cui.config.default_font, cui.config.font_size_lrg, cui.config.font_flags)
	count:ClearAllPoints()
	count:SetParent(text_overlay)
	count:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 6)
	count:SetJustifyH("LEFT")
	count:SetJustifyV("TOP")

	if hotkey then
		hotkey:SetDrawLayer("OVERLAY", 7)
		hotkey:SetFont(cui.config.default_font, cui.config.font_size_med, cui.config.font_flags)
		hotkey:ClearAllPoints()
		hotkey:SetParent(text_overlay)
		hotkey:SetPoint("BOTTOMLEFT", 3, -1)
		hotkey:SetPoint("BOTTOMRIGHT", 4, -1)
		hotkey:SetJustifyH("RIGHT")
		hotkey:SetJustifyV("BOTTOM")
	end

	if macro then
		macro:Hide()
	end

	cooldown:SetAllPoints(icon)
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	cui.util.fix_string(cooldown:GetRegions(), cui.config.font_size_lrg)

	auto:SetParent(text_overlay)
	auto:SetTexCoord(.18, .82, .16, .82)
	auto:SetPoint("TOPLEFT", icon, -5, 5)
	auto:SetPoint("BOTTOMRIGHT", icon, 5, -5)

	shine:SetPoint("TOPLEFT", icon, 1, -1)
	shine:SetPoint("BOTTOMRIGHT", icon, -1, 1)
end

lib.style_vehicle = function(button)

	if not button or button.style then return end
	button.styled = true

	cui.util.gen_backdrop(button)

	local blank = cui.media.textures.blank
	
	local pushed = button:GetPushedTexture()
	cui.util.set_inside(pushed, button)
	pushed:SetTexCoord(.2, .8, .2, .8)

	local normal = button:GetNormalTexture()
	cui.util.set_inside(normal, button)
	normal:SetTexCoord(.2, .8, .2, .8)

	local highlight = button:GetHighlightTexture()
	cui.util.set_inside(highlight, button)
	highlight:SetTexture(blank)
	highlight:SetVertexColor(unpack(cfg.color.highlight))
end


lib.style_pet = function(button)
	if not button or button.city_styled then return end
	button.city_styled = true
	
	cui.util.gen_backdrop(button)
	
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	local hotkey  = _G[name.."HotKey"]
	local normal2  = _G[name.."NormalTexture2"]
	local auto = _G[name.."AutoCastable"]
	local shine = _G[name.."Shine"]
	local cooldown = _G[name.."Cooldown"]
	local flash = _G[name.."Flash"]

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

	hotkey:SetFont(cui.config.default_font, cui.config.font_size_sml, cui.config.font_flags)
	hotkey:ClearAllPoints()
	hotkey:SetParent(text_overlay)
	hotkey:SetPoint("TOPRIGHT", button, 3, 1)
	hotkey:SetPoint("TOPLEFT", button, 0, 1)

	cooldown:SetAllPoints(icon)
	cooldown:SetHideCountdownNumbers(false)
	cooldown:SetDrawEdge(false)
	cui.util.fix_string(cooldown:GetRegions(), cui.config.font_size_med)

	flash.oldShow = flash.Show
	flash.Show = function(self)
		self:Hide()
	end
end

lib.style_stance = function(button)
	if not button or button.styled then return end
	button.styled = true
	
	cui.util.gen_backdrop(button)
	
	local name = button:GetName()
	local icon  = _G[name.."Icon"]
	
	skin_textures(button, icon)
end

lib.style_bag = function(button)
	if not button or button.styled then return end
	button.styled = true
	
	cui.util.gen_backdrop(button)

	local name = button:GetName()
	local icon = _G[name.."IconTexture"]
	local normal = _G[name.."NormalTexture"]
	local border = button["IconBorder"]

	border.Show = function() end
	border:Hide()
	
	skin_textures(button, icon, normal)
end
