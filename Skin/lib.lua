local _, addon = ...
local core = addon.core

local lib = {}
addon.skin.lib = lib

lib.skin_button = function(button)
	button.Left:Hide()
	button.Middle:Hide()
    button.Right:Hide()
	core.util.gen_backdrop(button)
	core.util.fix_string(button.Text)

	button:SetHighlightTexture(core.media.textures.blank)
	button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
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

lib.strip_textures = function(frame, only_textures, exclusions)
	local regions = {frame:GetRegions()}
	for _, region in ipairs(regions) do
        local exluded = false
        if exclusions then
            for _, exclusion in ipairs(exclusions) do
                if region == exclusion then
                    exluded = true
                    break
                end
            end
        end
        if not exluded then
            if region:GetObjectType() == "Texture" then
                region:SetTexture()
                region:Hide()
            elseif not only_textures then
                region:Hide()
            end
        end
	end
end

lib.skin_tab = function(tab)
	
	if not tab.skinned then
		-- core.util.fix_string(tab.label_text, core.config.font_size_sml)
		
		lib.strip_textures(tab, true)
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
		tab.selected_texture:SetTexture(core.media.textures.blank)
		tab.selected_texture:SetVertexColor(unpack(core.config.color.selected))
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
