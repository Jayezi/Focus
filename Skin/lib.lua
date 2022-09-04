local _, addon = ...
local core = addon.core

local lib = {}
addon.skin.lib = lib

lib.skin_input_scroller = function(scrollframe)
	scrollframe:GetScrollChild():SetWidth(scrollframe:GetWidth())

	core.util.strip_textures(scrollframe, true)
	core.util.gen_backdrop(scrollframe)

	local edit = scrollframe.EditBox
	edit:SetTextInsets(5, 5, 2, 2)
	core.util.fix_string(edit, core.config.font_size_med)
	
	local instructions = edit.Instructions
	core.util.fix_string(instructions, core.config.font_size_med)

	local regions = {edit:GetRegions()}
	for _, region in ipairs(regions) do
		if region:GetObjectType() == "FontString" then
			region:ClearAllPoints()
			region:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 5, -2)
			region:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", -5, 2)
		end
	end

	core.util.fix_scrollbar(scrollframe.ScrollBar)
	scrollframe.ScrollBar:ClearAllPoints()
	scrollframe.ScrollBar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 1, 0)
	scrollframe.ScrollBar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 1, 0)

	edit:SetWidth(scrollframe:GetWidth())
end

lib.skin_button = function(button, font_size)
	if button.Left then button.Left:Hide() end
	if button.Middle then button.Middle:Hide() end
	if button.Right then button.Right:Hide() end

	core.util.gen_backdrop(button)
	local text = button.Text or (button.GetFontString and button:GetFontString())
	if text then
		text:ClearAllPoints()
		core.util.set_inside(text, button)
		core.util.fix_string(text, font_size)
	end

	button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
    core.util.set_inside(button:GetHighlightTexture(), button)

	button:SetNormalTexture(nil)
	button:SetPushedTexture(nil)
	button:SetDisabledTexture(nil)
end

lib.skin_icon_button = function(button, texture, ...)
	core.util.gen_backdrop(button)

	local icon = texture or (button.Icon and button.Icon:GetTexture()) or (button:GetNormalTexture() and button:GetNormalTexture():GetTexture())

	if icon then
		if not button.Icon then
			button.Icon = button:CreateTexture()
		end
		button.Icon:SetTexture(icon)
		button.Icon:SetDrawLayer("BORDER")
		core.util.set_inside(button.Icon, button)

		if ... then
			button.Icon:SetTexCoord(...)
		end
	end

	local normal = button:GetNormalTexture()
	normal:SetTexture()

	local pushed = button:GetPushedTexture()
	core.util.set_inside(pushed, button)
	pushed:SetColorTexture(unpack(core.config.color.pushed))

	local highlight = button:GetHighlightTexture()
	core.util.set_inside(highlight, button)
	highlight:SetColorTexture(unpack(core.config.color.highlight))

	local disabled = button:GetDisabledTexture()
	if disabled then
		core.util.set_inside(disabled, button)
		disabled:SetColorTexture(unpack(core.config.color.disabled))
	end
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

lib.skin_itembutton = function(item, templates, w, h)
	if item.skinned then return end

	if w and h then
		item:SetSize(w, h)
	end

	local bg = item:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetColorTexture(unpack(core.config.color.background))
	bg:SetAllPoints()

	-- ItemButton
	-- BORDER
	local icon = item.icon
	-- ARTWORK
	local count = item.Count
	local stock = item.Stock
	-- OVERLAY
	local border = item.IconBorder
	-- OVERLAY 1
	local overlay1 = item.IconOverlay
	-- OVERLAY 2
	local lock = item.LevelLinkLockTexture
	local overlay2 = item.IconOverlay2
	-- OVERLAY 4
	local search = item.searchOverlay
	-- OVERLAY 5
	local context = item.ItemContextOverlay
	
	item:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
	item:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
	item:SetNormalTexture(nil)

	core.util.crop_icon(icon)
	icon:SetDrawLayer("ARTWORK")
	
	core.util.set_outside(border, icon)
	border:SetDrawLayer("BACKGROUND", -8)
	border:SetTexture(core.media.textures.blank)

	overlay1:SetAllPoints()
	overlay2:SetAllPoints()

	if templates then
		
		if templates["LootButtonTemplate"] then

			-- Layers

			-- ARTWORK
			local name = _G[item:GetName().."NameFrame"]

			-- OVERLAY
			local quest = _G[item:GetName().."IconQuestTexture"]
			local text = _G[item:GetName().."Text"]

			quest:SetAllPoints(icon)
		end

		if templates["ContainerFrameItemButtonTemplate"] then

			-- Frames

			local cooldown = _G[item:GetName().."Cooldown"] -- CooldownFrameTemplate

			-- Animations

			local new_anim = item.newitemglowAnim
			local flash_anim = item.flashAnim

			local anims = {new_anim:GetAnimations()}
			for i, anim in ipairs(anims) do
				if anim:GetOrder() == 1 then
					anim:SetFromAlpha(0.5)
					anim:SetToAlpha(0.1)
				elseif anim:GetOrder() == 2 then
					anim:SetFromAlpha(0.1)
					anim:SetToAlpha(0.5)
				end
			end

			-- Layers

			-- OVERLAY 1
			local upgrade = item.UpgradeIcon
			-- OVERLAY 2
			local quest = _G[item:GetName().."IconQuestTexture"]
			local flash = item.flash
			local new = item.NewItemTexture
			local battlepay = item.BattlepayItemTexture
			local extended = item.ExtendedSlot
			-- OVERLAY 5
			local junk = item.JunkIcon
			
			quest.letter = core.util.gen_string(item, core.config.font_size_lrg, nil, nil, "LEFT", "TOP", item:GetName().."QuestLetter")
			quest.letter:SetText("Q")
			quest.letter:SetTextColor(0.75, 0.75, 0)
			quest.letter:SetAllPoints(icon)
			quest.letter:Hide()
			
			quest:SetAllPoints(icon)

			hooksecurefunc(quest, "SetTexture", function(self, texture)
				if texture == TEXTURE_ITEM_QUEST_BORDER then
					self.letter:Show()
				else
					self.letter:Hide()
				end
			end)

			quest.alt_Hide = quest.Hide
			hooksecurefunc(quest, "Show", function(self)
				if self.letter:IsShown() then
					self:alt_Hide()
				end
			end)

			hooksecurefunc(quest, "Hide", function(self)
				self.letter:Hide()
			end)

			new:SetAllPoints(icon)
			new:SetTexture(core.media.textures.blank)
			hooksecurefunc(new, "SetAtlas", function(self)
				self:SetTexture(core.media.textures.blank)
			end)
		end

	end

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

	lib.skin_itembutton(item)
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

	dropdown.alt_SetHeight = dropdown.SetHeight
	hooksecurefunc(dropdown, "SetHeight", function(self)
		self:alt_SetHeight(24)
	end)
	dropdown:alt_SetHeight(24)

	button:ClearAllPoints()
	button:SetPoint("TOPRIGHT")
	button:SetSize(24, 24)
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
	pushed:SetTexCoord(0, 1.1, 0.0, 0.75)
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
