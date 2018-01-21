-- local addon, ns = ...
-- local gcfg = ns.cfg

--CharacterMicroButton:ClearAllPoints()
--CharacterMicroButton:SetPoint("TOP", UIParent, "TOP")

--for _, buttonName in pairs(MICRO_BUTTONS) do
--	local button = _G[buttonName]

	-- local bg = button:CreateTexture(nil, "BACKGROUND")
	-- bg:SetTexture("Interface\\Buttons\\WHITE8x8")
	-- bg:SetVertexColor(0, 0, 0, 1)
	-- bg:SetPoint("TOPLEFT", -1, -16)
	-- bg:SetPoint("BOTTOMRIGHT", 1, -1)
	
	-- -- Why the hell is this -17 thing so dumb?
	-- local norm = button:GetNormalTexture()
	-- norm:ClearAllPoints()
	-- norm:SetPoint("TOPLEFT", 0, -17)
	-- norm:SetPoint("BOTTOMRIGHT")
	-- norm:SetTexCoord(.19, .83, .48, .89)
	
	-- local pushed = button:GetPushedTexture()
	-- pushed:ClearAllPoints()
	-- pushed:SetPoint("TOPLEFT", 0, -17)
	-- pushed:SetPoint("BOTTOMRIGHT")
	-- pushed:SetTexCoord(.17, .80, .51, .92)
	
	-- local overlay = button:CreateTexture(nil, "OVERLAY")
	-- overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	-- overlay:ClearAllPoints()
	-- overlay:SetPoint("TOPLEFT", 0, -17)
	-- overlay:SetPoint("BOTTOMRIGHT")
	-- overlay:SetVertexColor(.6, .6, .1, .3)
	
	-- button:SetHighlightTexture(overlay)
--end


-- local cfg = gcfg.bars.microbar

-- if not cfg.enable then return end

-- local frame = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
-- local buttonList = {}

-- for _, buttonName in pairs(MICRO_BUTTONS) do
-- 	local button = _G[buttonName]
-- 	if button then
-- 		table.insert(buttonList, button)
-- 		button:SetParent(frame)
-- 	end
-- end



-- if cfg.hide then
-- 	frame:Hide()
-- 	return
-- end

-- local h = cfg.buttons.size
-- local w = h * .56

-- frame:SetWidth((w - 4) * #buttonList + 2 * cfg.padding)
-- frame:SetHeight(h + 2 * cfg.padding - 15)
-- frame:SetPoint(cfg.pos.a1, cfg.pos.af, cfg.pos.a2, cfg.pos.x, cfg.pos.y)
-- frame:SetScale(cfg.scale)

-- for i = 1, #buttonList do

-- 	local button = buttonList[i]
-- 	button:SetSize(w, h)
	
-- 	-- This worked mostly but I don't like it, and I hide them all anyway.
	
-- 	-- if i == 1 then
-- 		-- button:SetPoint("LEFT")
-- 	-- else
-- 		-- button.left_anchor = buttonList[i - 1]
-- 		-- button:SetPoint("LEFT", button.left_anchor, "RIGHT", 1, 0)
-- 	-- end
	
-- 	-- button.old_setPoint = button.SetPoint
-- 	-- button.SetPoint = function()
-- 		-- if button.left_anchor then
-- 			-- button:old_setPoint("LEFT", button.left_anchor, "RIGHT")
-- 		-- else
-- 			-- button:old_setPoint("LEFT")
-- 		-- end
-- 	-- end
	
-- 	local bg = button:CreateTexture(nil, "BACKGROUND")
-- 	bg:SetTexture("Interface\\Buttons\\WHITE8x8")
-- 	bg:SetVertexColor(0, 0, 0, 1)
-- 	bg:SetPoint("TOPLEFT", -1, -16)
-- 	bg:SetPoint("BOTTOMRIGHT", 1, -1)
	
-- 	-- Why the hell is this -17 thing so dumb?
-- 	local norm = button:GetNormalTexture()
-- 	norm:ClearAllPoints()
-- 	norm:SetPoint("TOPLEFT", 0, -17)
-- 	norm:SetPoint("BOTTOMRIGHT")
-- 	norm:SetTexCoord(.19, .83, .48, .89)
	
-- 	local pushed = button:GetPushedTexture()
-- 	pushed:ClearAllPoints()
-- 	pushed:SetPoint("TOPLEFT", 0, -17)
-- 	pushed:SetPoint("BOTTOMRIGHT")
-- 	pushed:SetTexCoord(.17, .80, .51, .92)
	
-- 	local overlay = button:CreateTexture(nil, "OVERLAY")
-- 	overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
-- 	overlay:ClearAllPoints()
-- 	overlay:SetPoint("TOPLEFT", 0, -17)
-- 	overlay:SetPoint("BOTTOMRIGHT")
-- 	overlay:SetVertexColor(.6, .6, .1, .3)
	
-- 	button:SetHighlightTexture(overlay)
-- end

-- MicroButtonPortrait:ClearAllPoints()
-- MicroButtonPortrait:SetPoint("TOPLEFT", 0, -17)
-- MicroButtonPortrait:SetPoint("BOTTOMRIGHT")

-- GuildMicroButtonTabard:SetAllPoints(GuildMicroButton)
-- GuildMicroButtonTabard:ClearAllPoints()
-- GuildMicroButtonTabard:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 0, -17)
-- GuildMicroButtonTabard:SetPoint("BOTTOMRIGHT", GuildMicroButton)

-- GuildMicroButtonTabardBackground:SetTexCoord(.19, .83, .48, .89)
-- GuildMicroButtonTabardBackground:ClearAllPoints()
-- GuildMicroButtonTabardBackground:SetPoint("TOPLEFT", GuildMicroButton, "TOPLEFT", 0, -17)
-- GuildMicroButtonTabardBackground:SetPoint("BOTTOMRIGHT", GuildMicroButton)

-- GuildMicroButtonTabardEmblem:SetSize(w / 2, w / 2)
-- GuildMicroButtonTabardEmblem:ClearAllPoints()
-- GuildMicroButtonTabardEmblem:SetPoint("CENTER", GuildMicroButtonTabardBackground)

-- MainMenuBarPerformanceBar:ClearAllPoints()
-- MainMenuBarPerformanceBar:Hide()

-- -- Disable reanchoring of the micro menu by the petbattle ui.
-- PetBattleFrame.BottomFrame.MicroButtonFrame:SetScript("OnShow", nil)

-- RegisterStateDriver(frame, "visibility", "[petbattle] hide; show")
