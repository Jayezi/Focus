local _, addon = ...
local core = addon.core

local lib = {}
addon.skin.lib = lib

lib.skin_button = function(button, font_size)
	button.Left:Hide()
	button.Middle:Hide()
    button.Right:Hide()
	core.util.gen_backdrop(button)
	local text = button.Text or (button.GetFontString and button:GetFontString())
	if text then
		text:ClearAllPoints()
		core.util.set_inside(text, button)
		core.util.fix_string(text, font_size)
	end

	button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
    core.util.set_inside(button:GetHighlightTexture(), button)
end

lib.skin_stretchbutton = function(button, font_size, exclusions)
	core.util.strip_textures(button, true, exclusions)

	core.util.gen_backdrop(button)
	local text = button.Text or (button.GetFontString and button:GetFontString())
	if text then
		text:ClearAllPoints()
		core.util.set_inside(text, button)
		core.util.fix_string(text, font_size)
	end

	button:GetHighlightTexture():Show()
	button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
    core.util.set_inside(button:GetHighlightTexture(), button)
end

lib.skin_item = function(item)
	if item.skinned then return end

	local pushed = item:GetPushedTexture()
	pushed:SetTexture(core.media.textures.blank)
	pushed:SetVertexColor(unpack(core.config.color.pushed))

	local highlight = item:GetHighlightTexture()
	highlight:Show()
	highlight:SetTexture(core.media.textures.blank)
	highlight:SetVertexColor(unpack(core.config.color.highlight))
	
	_G[item:GetName().."NormalTexture"]:SetTexture(nil)
	core.util.crop_icon(item.icon)
	item.IconBorder:SetDrawLayer("BORDER", -8)
	item.IconBorder.alt_SetTexture = item.IconBorder.SetTexture
	hooksecurefunc(item.IconBorder, "SetTexture", function(self)
		self:alt_SetTexture(core.media.textures.blank)
	end)
	core.util.set_outside(item.IconBorder, item)

	item.skinned = true
end

lib.skin_item_slot = function(item)

	local regions = {item:GetRegions()}
	for _, region in ipairs(regions) do
		if not region:GetName() then
			region:Hide()
		end
	end

	_G[item:GetName().."Frame"]:Hide()

	hooksecurefunc(item, "ResetAzeriteTextures", function(self)
		self:SetHighlightTexture(core.media.textures.blank)
	end)

	lib.skin_item(item)
end

lib.skin_tab = function(tab)
	
	if not tab.skinned then
		-- core.util.fix_string(tab.label_text, core.config.font_size_sml)

		local tabText = tab.Text or _G[tab:GetName().."Text"]
		tabText:ClearAllPoints()
		tabText:SetPoint("CENTER", tab)
		
		core.util.strip_textures(tab, true)
		core.util.gen_backdrop(tab, unpack(core.config.frame_background_transparent))
		
		local highlight = tab:GetHighlightTexture()
		if highlight then
			highlight:Show()
			core.util.set_inside(highlight, tab)
			highlight:SetTexture(core.media.textures.blank)
			highlight:SetVertexColor(unpack(core.config.color.highlight))
		end

		tab.selected_texture = tab:CreateTexture(nil, "OVERLAY")
		core.util.set_inside(tab.selected_texture, tab)
		tab.selected_texture:SetColorTexture(unpack(core.config.color.selected))
		tab.selected_texture:Hide()

		tab.skinned = true
	end
end

lib.skin_help = function(button)
	button.Ring:Hide()
	button.RingPulse:Hide()
	button:SetHighlightTexture(button.I:GetTexture())
	button:GetHighlightTexture():SetBlendMode("ADD")
	button:GetHighlightTexture():SetAllPoints(button.I)
end

-- UIDropDownMenuTemplate
-- 		.Left
-- 		.Middle
-- 		.Right
-- 		.Text
-- 		.Icon

-- 		.Button
-- 			.NormalTexture
-- 			.PushedTexture
-- 			.DisabledTexture
-- 			.HighlightTexture
lib.skin_dropdown = function(dropdown)

	core.util.gen_backdrop(dropdown)

	dropdown.Left:Hide()
	dropdown.Middle:Hide()
	dropdown.Right:Hide()

	local button = dropdown.Button

	dropdown:SetHeight(24)
	button:HookScript("OnMouseDown", function()
		dropdown:SetHeight(24)
	end)

	button:ClearAllPoints()
	button:SetPoint("RIGHT", -2, 0)
	button:SetSize(20, 20)
	core.util.gen_backdrop(button)

	local highlight = button.HighlightTexture
	highlight:SetColorTexture(unpack(core.config.color.highlight))
	core.util.set_inside(highlight, button)

	local normal = button.NormalTexture
	normal:SetTexture([[interface/buttons/arrow-down-up]])
	normal:SetTexCoord(-0.1, 1, -0.1, 0.65)
	normal:SetAllPoints(highlight)

	local pushed = button.PushedTexture
	pushed:SetTexture([[interface/buttons/arrow-down-down]])
	pushed:SetTexCoord(0, 1.1, -0.05, 0.75)
	pushed:SetAllPoints(highlight)

	local disabled = button.DisabledTexture
	disabled:SetTexture([[interface/buttons/arrow-down-disabled]])
	disabled:SetTexCoord(-0.1, 1, -0.1, 0.65)
	disabled:SetAllPoints(highlight)

	dropdown.Text:ClearAllPoints()
	dropdown.Text:SetPoint("LEFT")
	dropdown.Text:SetPoint("RIGHT", button, "LEFT")
	dropdown.Text:SetJustifyH("MIDDLE")
	core.util.fix_string(dropdown.Text, core.config.font_size_sml)

	dropdown.Icon:ClearAllPoints()
	dropdown.Icon:SetPoint("LEFT")
	dropdown.Icon:SetPoint("RIGHT", button, "LEFT")
end
