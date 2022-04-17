local _, addon = ...
if not addon.skin.enabled then return end
local core = addon.core
local lib = addon.skin.lib

local hooksecurefunc = hooksecurefunc

local panels = {
	ScriptErrorsFrame,
	CharacterFrame,
	SpellBookFrame,
	WorldMapFrame,
	PVEFrame,
	GossipFrame,
	FriendsFrame,
	QuestFrame,
	GameMenuFrame,
	MerchantFrame,
	MailFrame
}

local skin_panel

skin_panel = function(panel, nested)
	if panel.skinned then return end

	local children = {panel:GetChildren()}
	for _, child in ipairs(children) do
		skin_panel(child, true)
	end

	local name = panel:GetDebugName()
	local type = panel.layoutType

	if type == "InsetFrameTemplate" then
		if panel.Bg then panel.Bg:Hide() end
		if panel.Background then panel.Background:Hide() end
		panel.NineSlice:Hide()
	elseif type == "Dialog" then
		core.util.strip_textures(panel, true)
	elseif type == "SimplePanelTemplate" then
		panel.Bg:Hide()
		panel.NineSlice:Hide()
		core.util.gen_backdrop(panel, unpack(core.config.frame_background_transparent))
	elseif type == "PortraitFrameTemplate" or type == "PortraitFrameTemplateMinimizable" then
		panel.Bg:Hide()
		panel.Bg:SetTexture(nil)
		panel.TitleBg:Hide()
		panel.TitleBg:SetTexture(nil)
		panel.TopTileStreaks:Hide()
		panel.TopTileStreaks:SetTexture(nil)
		panel.NineSlice:Hide()
		--core.util.fix_string(panel.TitleText, core.config.font_size_med)

		panel.portrait_bg = panel:CreateTexture(nil, "OVERLAY", nil, -3)
		panel.portrait_bg:SetColorTexture(unpack(core.config.color.light_border))
		core.util.set_outside(panel.portrait_bg, panel.portrait)
		core.util.circle_mask(panel, panel.portrait_bg)

		hooksecurefunc(panel, "SetPortraitShown", function(self, shown)
			if shown then
				panel.portrait_bg:Show()
			else
				panel.portrait_bg:Hide()
			end
		end)
		
		if name == "CharacterFrame" then
			core.util.circle_mask(panel, panel.portrait_bg, 3)
			core.util.circle_mask(panel, panel.portrait, 3)

			for t = 1, 3 do
				local tab = _G["CharacterFrameTab"..t]
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("TOPLEFT", CharacterFrame, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", _G["CharacterFrameTab"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end
			core.util.gen_backdrop(panel.InsetRight, unpack(core.config.frame_background_transparent))

			-- CharacterStatsPane
			CharacterStatsPane.ClassBackground:Hide()
			CharacterStatsPane.ItemLevelCategory.Background:Hide()
			--core.util.fix_string(CharacterStatsPane.ItemLevelCategory.Title, core.config.font_size_med)
			CharacterStatsPane.ItemLevelFrame.Background:Hide()

			CharacterStatsPane.AttributesCategory.Background:Hide()
			--core.util.fix_string(CharacterStatsPane.AttributesCategory.Title, core.config.font_size_med)

			CharacterStatsPane.EnhancementsCategory.Background:Hide()
			--core.util.fix_string(CharacterStatsPane.EnhancementsCategory.Title, core.config.font_size_med)

			-- PaperDollSidebarTabs
			PaperDollSidebarTabs.DecorLeft:Hide()
			PaperDollSidebarTabs.DecorRight:Hide()
			for i = 1, 3 do
				local tab = _G["PaperDollSidebarTab"..i]
				core.util.set_inside(tab.Icon, tab)
				tab.TabBg:SetAllPoints()
				tab.TabBg:SetTexture(core.media.textures.blank)
				tab.TabBg:SetVertexColor(unpack(core.config.frame_border))
				tab.Hider:SetTexture(nil)
				tab.Highlight:SetAllPoints(tab.Icon)
				tab.Highlight:SetTexture(core.media.textures.blank)
				tab.Highlight:SetVertexColor(unpack(core.config.color.highlight))
			end

			-- PaperDollTitlesPane
			core.util.fix_scrollbar(PaperDollTitlesPane.scrollBar)
			PaperDollTitlesPane.scrollBar:ClearAllPoints()
			PaperDollTitlesPane.scrollBar:SetPoint("TOPRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -2, -18)
			PaperDollTitlesPane.scrollBar:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMRIGHT", -2, 18)

			-- PaperDollEquipmentManagerPane
			lib.skin_button(PaperDollEquipmentManagerPane.EquipSet)
			lib.skin_button(PaperDollEquipmentManagerPane.SaveSet)
			PaperDollEquipmentManagerPane.SaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPane.EquipSet, "RIGHT", 1, 0)
			core.util.fix_scrollbar(PaperDollEquipmentManagerPane.scrollBar)
			PaperDollEquipmentManagerPane.scrollBar:ClearAllPoints()
			PaperDollEquipmentManagerPane.scrollBar:SetPoint("TOPRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -2, -18)
			PaperDollEquipmentManagerPane.scrollBar:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMRIGHT", -2, 18)

			-- CharacterModelFrame
			for _, region in ipairs({CharacterModelFrame:GetRegions()}) do
				region:Hide()
			end

			-- PaperDollItemsFrame
			for _, item in ipairs(PaperDollItemsFrame.EquipmentSlots) do
				lib.skin_item_slot(item)
			end
			for _, item in ipairs(PaperDollItemsFrame.WeaponSlots) do
				lib.skin_item_slot(item)
			end

			-- ReputationFrame
			ReputationListScrollFrame:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 4, -4)
			ReputationListScrollFrame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -23, 4)
			ReputationDetailFrame:SetHeight(250)
			ReputationDetailAtWarCheckBox:SetPoint("TOPLEFT", 10, -195)
			core.util.strip_textures(ReputationListScrollFrame, true)
			core.util.gen_backdrop(ReputationListScrollFrame, unpack(core.config.frame_background_transparent))
			core.util.fix_scrollbar(ReputationListScrollFrameScrollBar)
			ReputationListScrollFrameScrollBar:SetPoint("TOPLEFT", ReputationListScrollFrame, "TOPRIGHT", 2, -16)
			ReputationListScrollFrameScrollBar:SetPoint("BOTTOMLEFT", ReputationListScrollFrame, "BOTTOMRIGHT", 2, 16)

			core.util.strip_textures(ReputationDetailFrame, true)
			core.util.gen_backdrop(ReputationDetailFrame, unpack(core.config.frame_background_transparent))
			
			core.util.fix_string(ReputationDetailFactionName, core.config.font_size_sml)
			core.util.fix_string(ReputationDetailFactionDescription, core.config.font_size_sml)
		
		elseif name == "SpellBookFrame" then
			
			lib.skin_help(SpellBookFrame.MainHelpButton)

			SpellBookPage1:Hide()
			SpellBookPage2:Hide()
			for t = 1, 5 do
				local tab = _G["SpellBookFrameTabButton"..t]
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", _G["SpellBookFrameTabButton"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end

			-- SpellBookPageNavigationFrame
			SpellBookPageText:SetTextColor(1, 1, 1)
			
			-- SpellBookSideTabsFrame
			for t = 1, MAX_SKILLLINE_TABS do
				local tab = _G["SpellBookSkillLineTab"..t]

				local regions = {tab:GetRegions()}
				for _, region in ipairs(regions) do
					if region:GetDrawLayer() == "BACKGROUND" then
						core.util.set_outside(region, tab)
						region:SetTexture(core.media.textures.blank)
						region:SetVertexColor(core.config.color.border)
					end
				end
				tab:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
				tab:SetHighlightTexture(core.media.textures.blank)
				tab:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
				
				tab:SetCheckedTexture(core.media.textures.blank)
				tab:GetCheckedTexture():SetVertexColor(unpack(core.config.color.selected))
			end

			for p = 1, 2 do
				local prof = _G["PrimaryProfession"..p]
				prof.missingText:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
				local border = _G["PrimaryProfession"..p.."IconBorder"]
				border:SetColorTexture(unpack(core.config.color.border))
				border:SetDrawLayer("BACKGROUND")
				core.util.circle_mask(prof, border, 3)
				core.util.circle_mask(prof, prof.icon, 3)
				prof.icon:SetAlpha(1)

				prof.unlearn:ClearAllPoints()
				prof.unlearn:SetPoint("RIGHT", prof.statusBar, "LEFT", -2, 0)
				
				for b = 1, 2 do
					local button = prof["button"..b]
					_G[button:GetDebugName().."NameFrame"]:SetTexture(core.media.textures.blank)
					_G[button:GetDebugName().."NameFrame"]:SetVertexColor(unpack(core.config.color.border))
					core.util.set_outside(_G[button:GetDebugName().."NameFrame"], button)
					button.subSpellString:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
					button:GetPushedTexture():SetBlendMode("ADD")
				end
				prof.button2:SetPoint("TOPRIGHT", -109, 0)
				prof.button1:SetPoint("TOPLEFT", prof.button2, "BOTTOMLEFT", 0, -3)

				prof.statusBar:SetPoint("TOPLEFT", prof.rank, "BOTTOMLEFT", 0, -5)
				prof.statusBar.rankText:SetPoint("CENTER")
				core.util.strip_textures(prof.statusBar, true)
				prof.statusBar:SetStatusBarTexture(core.media.textures.blank)
				prof.statusBar:SetStatusBarColor(0.25, 0.75, 0.25)
				prof.statusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
				core.util.gen_backdrop(prof.statusBar)
			end

			for p = 1, 3 do
				local prof = _G["SecondaryProfession"..p]

				for b = 1, 2 do
					local button = prof["button"..b]
					_G[button:GetDebugName().."NameFrame"]:SetTexture(core.media.textures.blank)
					_G[button:GetDebugName().."NameFrame"]:SetVertexColor(unpack(core.config.color.border))
					core.util.set_outside(_G[button:GetDebugName().."NameFrame"], button)
					button.subSpellString:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
					button:GetPushedTexture():SetBlendMode("ADD")
				end

				prof.rank:SetPoint("BOTTOMLEFT", prof.statusBar, "TOPLEFT", 0, 4)
				prof.statusBar:SetPoint("BOTTOMLEFT", -14, 0)
				prof.statusBar.rankText:SetPoint("CENTER")
				core.util.strip_textures(prof.statusBar, true)
				prof.statusBar:SetStatusBarTexture(core.media.textures.blank)
				prof.statusBar:SetStatusBarColor(0.25, 0.75, 0.25)
				prof.statusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
				core.util.gen_backdrop(prof.statusBar)

				prof.missingText:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
			end
		
		elseif name == "PlayerTalentFrame" then

			core.util.set_outside(panel.portrait_bg, panel.portrait, -2)

			hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
				for t = 1, 3 do
					local tab = _G["PlayerTalentFrameTab"..t]
					tab:ClearAllPoints()
					if t == 1 then
						tab:SetPoint("TOPLEFT", PlayerTalentFrame, "BOTTOMLEFT", 0, 1)
					else
						tab:SetPoint("TOPLEFT", _G["PlayerTalentFrameTab"..(t - 1)], "TOPRIGHT", -1, 0)
					end
				end
			end)

			local skin_spec_spell = function(spell)
				spell.ring:ClearAllPoints()
				spell.ring:SetPoint("CENTER")
				spell.ring:SetColorTexture(unpack(core.config.color.border))
				spell.ring:SetDrawLayer("ARTWORK", -1)
				spell.ring:SetSize(spell.icon:GetWidth(), spell.icon:GetHeight())
				core.util.circle_mask(spell, spell.ring, 2)
				core.util.circle_mask(spell, spell.icon, 3)
			end

			local skin_spec_frame = function(spec)
				core.util.strip_textures(spec, true)
				lib.skin_help(spec.MainHelpButton)
				lib.skin_button(spec.learnButton)
				spec.learnButton.Flash:SetColorTexture(unpack(core.config.color.selected))
				core.util.set_inside(spec.learnButton.Flash, spec.learnButton)

				for t = 1, 5 do
					local tab = spec["specButton"..t]
					local glow = _G[tab:GetName().."Glow"]
					tab.bg:Hide()

					tab.specIcon:SetPoint("CENTER", tab.ring)

					tab.ring:SetColorTexture(unpack(core.config.color.border))
					tab.ring:SetDrawLayer("ARTWORK", -1)
					tab.ring:SetSize(tab.specIcon:GetWidth(), tab.specIcon:GetHeight())
					tab.ring:SetPoint("LEFT", 2, 0)
					core.util.circle_mask(tab, tab.ring, 2)

					tab.specName:SetPoint("TOPLEFT", tab.ring, "TOPRIGHT", 10, -20)

					tab.selectedTex:SetColorTexture(unpack(core.config.color.pushed))
					tab.selectedTex:SetAllPoints()

					tab.learnedTex:SetColorTexture(unpack(core.config.color.selected))
					tab.learnedTex:SetAllPoints()
					tab.learnedTex:SetDrawLayer("ARTWORK", -2)

					tab:SetHighlightTexture(core.media.textures.blank)
					tab:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
					tab:GetHighlightTexture():SetAllPoints()

					glow:SetAllPoints(tab)
					glow:SetColorTexture(unpack(core.config.color.highlight))

					tab:SetHeight(tab.specIcon:GetHeight())
				end
				for _, child in ipairs({spec:GetChildren()}) do
					if not child:GetName() then
						child:Hide()
					end
				end
				local scroll = spec.spellsScroll
				core.util.strip_textures(scroll, true)
				core.util.fix_scrollbar(scroll.ScrollBar)
				scroll.child.gradient:Hide()
				scroll.child.scrollwork_topleft:Hide()
				scroll.child.scrollwork_topright:Hide()
				scroll.child.scrollwork_bottomleft:Hide()
				scroll.child.scrollwork_bottomright:Hide()

				scroll.child.ring:SetColorTexture(unpack(core.config.color.border))
				scroll.child.ring:SetDrawLayer("BORDER", 2)
				core.util.circle_mask(scroll.child, scroll.child.ring, 2)
				scroll.child.ring:SetSize(scroll.child.specIcon:GetWidth(), scroll.child.specIcon:GetHeight())

				core.util.circle_mask(scroll.child, scroll.child.specIcon, 3)
				scroll.child.specIcon:SetPoint("CENTER", scroll.child.ring)
				scroll.child.specName:SetPoint("BOTTOMLEFT", scroll.child.ring, "RIGHT", 10, 3)
				scroll.child.Seperator:SetColorTexture(unpack(core.player.color))
				skin_spec_spell(scroll.child.abilityButton1)
			end
		
			-- PlayerTalentFrameSpecialization
			-- PlayerTalentFramePetSpecialization
			skin_spec_frame(PlayerTalentFrameSpecialization)
			skin_spec_frame(PlayerTalentFramePetSpecialization)

			hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
				for t = 1, 5 do
					local tab = self["specButton"..t]
					core.util.circle_mask(tab, tab.specIcon, 3)
				end
			end)

			hooksecurefunc("PlayerTalentFrame_CreateSpecSpellButton", function(self, index)
				skin_spec_spell(self.spellsScroll.child["abilityButton"..index])
			end)

			-- PlayerTalentFrameTalents
			core.util.strip_textures(PlayerTalentFrameTalents, true)
			lib.skin_help(PlayerTalentFrameTalents.MainHelpButton)
			
			for r = 1, MAX_TALENT_TIERS do
				local row = PlayerTalentFrameTalents["tier"..r]
				core.util.strip_textures(row, true)
				row.GlowFrame.TopGlowLine:SetColorTexture(unpack(core.config.color.highlight))
				row.GlowFrame.TopGlowLine:SetAllPoints()
				row.GlowFrame.BottomGlowLine:Hide()

				for t = 1, NUM_TALENT_COLUMNS do
					local talent = row["talent"..t]
					talent.GlowFrame.TopGlowLine:SetColorTexture(unpack(core.config.color.highlight))
					talent.GlowFrame.TopGlowLine:SetAllPoints()
					talent.GlowFrame.BottomGlowLine:Hide()

					talent.Slot:SetColorTexture(unpack(core.config.color.border))
					talent.Slot:SetDrawLayer("BACKGROUND", -1)
					core.util.set_outside(talent.Slot, talent.icon)
					talent.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

					talent.knownSelection:SetAllPoints()
					talent.knownSelection:SetDrawLayer("BACKGROUND", -2)

					talent.highlight:SetTexture(core.media.textures.blank)
					talent.highlight:SetAllPoints()

				end
			end

			-- PlayerTalentFrameTalentsPvpTalentFrame
			core.util.strip_textures(PlayerTalentFrameTalents.PvpTalentFrame, true, {
				PlayerTalentFrameTalents.PvpTalentFrame.Swords,
			})
			
			hooksecurefunc(PlayerTalentFrameTalents.PvpTalentFrame, "UpdateModelScene", function(self, scene)
				scene:Hide()
			end)

			PlayerTalentFrameTalents.PvpTalentFrame.Swords:SetSize(PlayerTalentFrameTalents.PvpTalentFrame.Swords:GetWidth() * 1.5, PlayerTalentFrameTalents.PvpTalentFrame.Swords:GetHeight() * 1.5)
			PlayerTalentFrameTalents.PvpTalentFrame.InvisibleWarmodeButton:SetAllPoints(PlayerTalentFrameTalents.PvpTalentFrame.Swords)
			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive:SetPoint("CENTER", PlayerTalentFrameTalents.PvpTalentFrame.InvisibleWarmodeButton, "BOTTOM")

			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.CircleMask:Hide()
			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.IconRing:SetDrawLayer("ARTWORK", -1)
			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.IconRing:SetTexture(core.media.textures.blank)
			PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.IconRing:SetVertexColor(unpack(core.config.color.border))
			core.util.set_outside(PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive.IconRing, PlayerTalentFrameTalents.PvpTalentFrame.WarmodeIncentive)

			for s = 1, 3 do
				-- PvpTalentSlotTemplate
				local talent = PlayerTalentFrameTalents.PvpTalentFrame["TalentSlot"..s]
				talent.Border:SetDrawLayer("BACKGROUND", -1)
				talent.Texture:SetSize(40, 40)
				talent.TalentName:SetSize(130, 15)
				talent.TalentName:SetPoint("TOP", talent.Border, "BOTTOM")
				core.util.set_outside(talent.Border, talent.Texture)
				core.util.circle_mask(talent, talent.Border, 3)
				core.util.circle_mask(talent, talent.Texture, 3)
			end

			-- PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame
			for _, child in ipairs({PlayerTalentFrameTalentsPvpTalentFrame.TalentList:GetChildren()}) do
				if child.Left then
					lib.skin_button(child)
				end
			end
			
			-- PvpTalentButtonTemplate
			local buttons = PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame.buttons
			for i = 1, #buttons do
				local button = buttons[i]

				local bg
				for _, region in ipairs({button:GetRegions()}) do
					if region:GetDrawLayer() == "BACKGROUND" then
						bg = region
					end
				end

				bg:SetTexture(core.media.textures.blank)
				bg:SetVertexColor(unpack(core.config.color.border))
				core.util.set_outside(bg, button.Icon)
				button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

				button.Selected:SetTexture(core.media.textures.blank)
				button.Selected:SetVertexColor(unpack(core.config.color.selected))

				button:SetHighlightTexture(core.media.textures.blank)
				button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
			end
			
			for _, child in ipairs({PlayerTalentFrameTalentsPvpTalentFrame.TalentList:GetChildren()}) do
				if child:GetObjectType() == "Button" then
					child:SetPoint("BOTTOM", 0, 2)
				end
			end

			core.util.fix_scrollbar(PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame.ScrollBar)
			PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame, "TOPRIGHT", -2, -15)
			PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", PlayerTalentFrameTalentsPvpTalentFrame.TalentList.ScrollFrame, "BOTTOMRIGHT", -2, 15)
			core.util.gen_backdrop(PlayerTalentFrameTalentsPvpTalentFrame.TalentList.Inset, unpack(core.config.frame_background_transparent))
		
		elseif name == "FriendsFrame" then

			for t = 1, 3 do
				local tab = _G["FriendsTabHeaderTab"..t]
				lib.skin_tab(tab)
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("BOTTOMLEFT", FriendsListFrameScrollFrame, "TOPLEFT", 0, -1)
				else
					tab:SetPoint("TOPLEFT", _G["FriendsTabHeaderTab"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end

			for t = 1, 4 do
				local tab = _G["FriendsFrameTab"..t]
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("TOPLEFT", FriendsFrame, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", _G["FriendsFrameTab"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end

			core.util.set_outside(panel.portrait_bg, FriendsFrameIcon)
			core.util.circle_mask(panel, panel.portrait_bg, 4)
			core.util.circle_mask(panel, FriendsFrameIcon, 4)

			FriendsFrameIcon:ClearAllPoints()
			FriendsFrameIcon:SetPoint("CENTER", panel, "TOPLEFT", 20, -20)

			FriendsFrameStatusDropDown:HookScript("OnShow", function()
				FriendsFrameStatusDropDown:SetHeight(24)
			end)

			FriendsFrameStatusDropDown:SetPoint("TOPLEFT", 50, -27)
			lib.skin_dropdown(FriendsFrameStatusDropDown)
			FriendsFrameStatusDropDownStatus:ClearAllPoints()
			FriendsFrameStatusDropDownStatus:SetPoint("LEFT", 5, 0)
			FriendsFrameStatusDropDownMouseOver:SetAllPoints(FriendsFrameStatusDropDownStatus)
			FriendsFrameStatusDropDown:SetWidth(45)

			-- FriendsFrame.FriendsTabHeader
			core.util.strip_textures(FriendsFrameBattlenetFrame, true)
			core.util.gen_backdrop(FriendsFrameBattlenetFrame.BroadcastFrame)

			local editbox = FriendsFrameBattlenetFrame.BroadcastFrame.EditBox
			editbox.TopLeftBorder:Hide()
			editbox.TopRightBorder:Hide()
			editbox.TopBorder:Hide()
			editbox.BottomLeftBorder:Hide()
			editbox.BottomRightBorder:Hide()
			editbox.BottomBorder:Hide()
			editbox.LeftBorder:Hide()
			editbox.RightBorder:Hide()
			editbox.MiddleBorder:Hide()

			editbox:SetHeight(22)
			core.util.gen_backdrop(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
			lib.skin_button(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
			lib.skin_button(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)

			lib.skin_button(FriendsFrameAddFriendButton)
			lib.skin_button(FriendsFrameSendMessageButton)
			core.util.fix_scrollbar(FriendsListFrameScrollFrame.Slider)

			lib.skin_button(FriendsFrameIgnorePlayerButton)
			lib.skin_button(FriendsFrameUnsquelchButton)
			core.util.fix_scrollbar(IgnoreListFrameScrollFrame.Slider)

			lib.skin_button(WhoFrameGroupInviteButton)
			lib.skin_button(WhoFrameAddFriendButton)
			lib.skin_button(WhoFrameWhoButton)
			core.util.fix_scrollbar(WhoListScrollFrame.Slider)
			
			WhoFrameEditBox:SetPoint("BOTTOM", -10, 30)
			WhoFrameEditBox:SetHeight(22)
			core.util.gen_backdrop(WhoFrameEditBox)

			for t = 1, 4 do
				local header = _G["WhoFrameColumnHeader"..t]
				lib.skin_button(header, core.config.font_size_sml)
				if t == 1 then
					--header:SetPoint("TOPLEFT", FriendsFrame, "BOTTOMLEFT", 0, 1)
				else
					header:SetPoint("TOPLEFT", _G["WhoFrameColumnHeader"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end

			lib.skin_dropdown(WhoFrameDropDown)
			WhoFrameDropDown:SetAllPoints(WhoFrameColumnHeader2)
			WhoFrameDropDownHighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
			core.util.set_inside(WhoFrameDropDownHighlightTexture, WhoFrameDropDown)

			lib.skin_button(RaidFrameConvertToRaidButton, core.config.font_size_sml)
			lib.skin_button(RaidFrameRaidInfoButton, core.config.font_size_sml)

			lib.skin_button(QuickJoinFrame.JoinQueueButton, core.config.font_size_sml)
			core.util.fix_scrollbar(QuickJoinScrollFrame.Slider)

			-- RecruitAFriendFrame
			lib.skin_button(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)

			core.util.strip_textures(RecruitAFriendFrame.RecruitList.Header, true)
			core.util.fix_scrollbar(RecruitAFriendFrame.RecruitList.ScrollFrame.Slider)
			lib.skin_button(RecruitAFriendFrame.RecruitmentButton)

		elseif name == "PVEFrame" then
			core.util.strip_textures(panel, true, {
				panel.portrait,
				panel.portrait_bg
			})

			for t = 1, 3 do
				local tab = panel["tab"..t]
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", panel["tab"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end
			
			-- GroupFinderFrame
			for t = 1, 3 do
				local button = GroupFinderFrame["groupButton"..t]

				button.selected = button:CreateTexture()
				button.selected:SetColorTexture(unpack(core.config.color.selected))
				button.selected:SetAllPoints(button)
				button.selected:Hide()

				button.bg:Hide()
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				button:GetHighlightTexture():SetAllPoints(button)

				button.ring:SetColorTexture(unpack(core.config.color.border))
				button.ring:SetDrawLayer("ARTWORK", -1)
				core.util.circle_mask(button, button.ring, 4)
				button.ring:SetSize(button.icon:GetWidth(), button.icon:GetHeight())
				button.ring:SetPoint("LEFT")
				core.util.circle_mask(button, button.icon, 5)
			end

			hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
				for t = 1, 3 do
					local button = GroupFinderFrame["groupButton"..t]
					if t == index then
						button.selected:Show()
					else
						button.selected:Hide()
					end
				end
			end)

			core.util.strip_textures(panel.shadows)

			-- LFDParentFrame
			core.util.strip_textures(LFDParentFrame)

			-- LFDQueueFrame
			LFDQueueFrameTypeDropDownName:SetPoint("RIGHT", LFDQueueFrameTypeDropDown, "LEFT", -5, 0)

			LFDQueueFrameTypeDropDown:ClearAllPoints()
			LFDQueueFrameTypeDropDown:SetPoint("BOTTOMRIGHT", GroupFinderFrame, "BOTTOMRIGHT", -5, 285)
			lib.skin_dropdown(LFDQueueFrameTypeDropDown)

			LFDQueueFrameTypeDropDown:HookScript("OnShow", function()
				LFDQueueFrameTypeDropDown:SetSize(250, 24)
			end)

			core.util.strip_textures(LFDQueueFrameSpecificListScrollFrame)
			core.util.fix_scrollbar(LFDQueueFrameSpecificListScrollFrameScrollBar)

			core.util.strip_textures(LFDQueueFrameRandomScrollFrame)
			core.util.fix_scrollbar(LFDQueueFrameRandomScrollFrameScrollBar)

			lib.skin_button(LFDQueueFrameFindGroupButton)

			-- -- RaidFinderFrame
			core.util.strip_textures(RaidFinderFrame)

			lib.skin_button(RaidFinderFrameFindRaidButton)
			
			-- RaidFinderQueueFrame
			RaidFinderQueueFrameSelectionDropDownName:SetPoint("RIGHT", RaidFinderQueueFrameSelectionDropDown, "LEFT", -5, 0)

			RaidFinderQueueFrameSelectionDropDown:ClearAllPoints()
			RaidFinderQueueFrameSelectionDropDown:SetPoint("BOTTOMRIGHT", GroupFinderFrame, "BOTTOMRIGHT", -5, 285)
			lib.skin_dropdown(RaidFinderQueueFrameSelectionDropDown)

			RaidFinderQueueFrameSelectionDropDown:HookScript("OnShow", function()
				RaidFinderQueueFrameSelectionDropDown:SetSize(250, 24)
			end)

			-- LFGListFrame
			lib.skin_button(LFGListFrame.CategorySelection.FindGroupButton)
			lib.skin_button(LFGListFrame.CategorySelection.StartGroupButton)

			core.util.fix_editbox(LFGListFrame.SearchPanel.SearchBox, 320, 22, 50)
			LFGListFrame.SearchPanel.SearchBox:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.CategoryName, "BOTTOMLEFT", 0, -8)
			
			core.util.fix_scrollbar(LFGListFrame.SearchPanel.ScrollFrame.scrollBar)
			LFGListFrame.SearchPanel.ScrollFrame.scrollBar:SetPoint("BOTTOMLEFT", LFGListFrame.SearchPanel.ScrollFrame, "BOTTOMRIGHT", 4, 15)

			lib.skin_button(LFGListFrame.SearchPanel.BackButton)
			lib.skin_button(LFGListFrame.SearchPanel.BackToGroupButton)
			lib.skin_button(LFGListFrame.SearchPanel.SignUpButton)		
			
			-- LFGListFrame.ApplicationViewer
			LFGListFrame.ApplicationViewer.InfoBackground:SetTexCoord(0.01, 0.99, 0.01, 0.99)
		
		elseif name == "CollectionsJournal" then
			
			for t = 1, 5 do
				local tab = _G[name.."Tab"..t]
				tab:ClearAllPoints()
				if t == 1 then
					tab:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", _G[name.."Tab"..(t - 1)], "TOPRIGHT", -1, 0)
				end
			end

		elseif name == "QuestFrame" then
			-- QuestFrameDetailPanel
			lib.skin_button(QuestFrameAcceptButton)
			lib.skin_button(QuestFrameDeclineButton)
			
			core.util.strip_textures(QuestDetailScrollFrame)
			core.util.fix_scrollbar(QuestDetailScrollFrameScrollBar)

			-- QuestFrameRewardPanel
			lib.skin_button(QuestFrameCompleteQuestButton)
			QuestFrameCompleteQuestButton:SetWidth(150)
			
			core.util.strip_textures(QuestRewardScrollFrame)
			core.util.fix_scrollbar(QuestRewardScrollFrameScrollBar)

			-- QuestFrameProgressPanel
			lib.skin_button(QuestFrameCompleteButton)
			lib.skin_button(QuestFrameGoodbyeButton)
			
			core.util.strip_textures(QuestProgressScrollFrame)
			core.util.fix_scrollbar(QuestProgressScrollFrameScrollBar)

		elseif name == "GossipFrame" then
			-- GossipFrameGreetingPanel
			lib.skin_button(GossipFrameGreetingGoodbyeButton)
			GossipFrameGreetingGoodbyeButton:SetWidth(90)
			core.util.strip_textures(GossipGreetingScrollFrame)
			core.util.fix_scrollbar(GossipGreetingScrollFrameScrollBar)

			-- hooksecurefunc(GossipTitleButtonMixin, "UpdateTitleForQuest", function(self, _, text, ignored, trivial)
			-- 	if ignored then
			-- 		self:SetFormattedText("%s (ignored)", text);
			-- 	elseif trivial then
			-- 		self:SetFormattedText("%s (low level)", text);
			-- 	else
			-- 		self:SetText(text)
			-- 	end
			-- end)
		elseif name == "MerchantFrame" then

			core.util.circle_mask(panel, panel.portrait_bg, 1)
			core.util.circle_mask(panel, panel.portrait, 1)

			BuybackBG:SetTexture()
			BuybackBG:Hide()

			MerchantFrameBottomLeftBorder:SetTexture()
			MerchantFrameBottomLeftBorder:Hide()
			MerchantFrameBottomRightBorder:SetTexture()
			MerchantFrameBottomRightBorder:Hide()

			hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
				for i = 1, BUYBACK_ITEMS_PER_PAGE do
					local item = _G["MerchantItem"..i]
					local alt_currency = _G["MerchantItem"..i.."AltCurrencyFrame"]
					alt_currency:ClearAllPoints()
					alt_currency:SetPoint("LEFT", item.ItemButton, "BOTTOMRIGHT", 5, 0)
				end
			end)

			for i = 1, BUYBACK_ITEMS_PER_PAGE do
				local item = _G["MerchantItem"..i]
				-- MerchantItemTemplate
				local slot = _G["MerchantItem"..i.."SlotTexture"]
				core.util.set_outside(slot, item.ItemButton)
				slot:SetColorTexture(unpack(core.config.color.border))
				slot:SetParent(item.ItemButton)

				lib.skin_item(item.ItemButton)

				local bg = _G["MerchantItem"..i.."NameFrame"]
				bg:SetTexture()
				bg:Hide()

				item.Name:ClearAllPoints()
				item.Name:SetPoint("TOPLEFT", item.ItemButton, "TOPRIGHT", 5, 0)
				item.Name:SetJustifyV("TOP")

				local money = _G["MerchantItem"..i.."MoneyFrame"]
				money:ClearAllPoints()
				money:SetPoint("LEFT", item.ItemButton, "BOTTOMRIGHT", 5, 0)

				local alt_currency = _G["MerchantItem"..i.."AltCurrencyFrame"]
				alt_currency:ClearAllPoints()
				alt_currency:SetPoint("LEFT", item.ItemButton, "BOTTOMRIGHT", 5, -1)
			end

			local slot = _G["MerchantBuyBackItemSlotTexture"]
			core.util.set_outside(slot, MerchantBuyBackItem.ItemButton)
			slot:SetColorTexture(unpack(core.config.color.border))
			slot:SetParent(MerchantBuyBackItem.ItemButton)

			lib.skin_item(MerchantBuyBackItem.ItemButton)

			local bg = _G["MerchantBuyBackItemNameFrame"]
			bg:SetTexture()
			bg:Hide()

			MerchantBuyBackItem.Name:ClearAllPoints()
			MerchantBuyBackItem.Name:SetPoint("TOPLEFT", MerchantBuyBackItem.ItemButton, "TOPRIGHT", 5, 0)
			MerchantBuyBackItem.Name:SetJustifyV("TOP")

			local money = _G["MerchantBuyBackItemMoneyFrame"]
			money:ClearAllPoints()
			money:SetPoint("LEFT", MerchantBuyBackItem.ItemButton, "BOTTOMRIGHT", 5, 0)

			core.util.strip_textures(MerchantExtraCurrencyBg)
			core.util.strip_textures(MerchantMoneyBg)

			MerchantFrameTab1:ClearAllPoints()
			MerchantFrameTab1:SetPoint("TOPLEFT", MerchantFrame, "BOTTOMLEFT", 0, 1)
			MerchantFrameTab2:ClearAllPoints()
			MerchantFrameTab2:SetPoint("TOPLEFT", MerchantFrameTab1, "TOPRIGHT", -1, 0)

			lib.skin_dropdown(panel.lootFilter)
			panel.lootFilter:SetPoint("TOPRIGHT", -2, -28)

			-- MerchantRepairItemButton
			local border = select(1, MerchantRepairItemButton:GetRegions())
			local backdrop = MerchantRepairItemButton:CreateTexture(nil, "BACKGROUND", nil, -8)
			backdrop:SetColorTexture(unpack(core.config.color.border))
			backdrop:SetAllPoints()
			core.util.set_inside(border, MerchantRepairItemButton)
			--border:SetColorTexture(unpack(core.config.color.border))
			border:SetTexCoord(.04, .25, .07, .50)

			local pushed = MerchantRepairItemButton:GetPushedTexture()
			pushed:SetColorTexture(unpack(core.config.color.pushed))
			pushed:SetAllPoints(border)
			local highlight = MerchantRepairItemButton:GetHighlightTexture()
			highlight:SetColorTexture(unpack(core.config.color.highlight))
			highlight:SetAllPoints(border)

			-- MerchantRepairAllButton
			local border = MerchantRepairAllIcon
			local backdrop = MerchantRepairAllButton:CreateTexture(nil, "BACKGROUND", nil, -8)
			backdrop:SetColorTexture(unpack(core.config.color.border))
			backdrop:SetAllPoints()
			core.util.set_inside(border, MerchantRepairAllButton)
			--border:SetColorTexture(unpack(core.config.color.border))
			border:SetTexCoord(.31, .54, .07, .50)

			local pushed = MerchantRepairAllButton:GetPushedTexture()
			pushed:SetColorTexture(unpack(core.config.color.pushed))
			pushed:SetAllPoints(border)
			local highlight = MerchantRepairAllButton:GetHighlightTexture()
			highlight:SetColorTexture(unpack(core.config.color.highlight))
			highlight:SetAllPoints(border)

			-- MerchantGuildBankRepairButton
			local border = MerchantGuildBankRepairButtonIcon
			local backdrop = MerchantGuildBankRepairButton:CreateTexture(nil, "BACKGROUND", nil, -8)
			backdrop:SetColorTexture(unpack(core.config.color.border))
			backdrop:SetAllPoints()
			core.util.set_inside(border, MerchantGuildBankRepairButton)
			--border:SetColorTexture(unpack(core.config.color.border))
			border:SetTexCoord(.59, .82, .07, .50)

			local pushed = MerchantGuildBankRepairButton:GetPushedTexture()
			pushed:SetColorTexture(unpack(core.config.color.pushed))
			pushed:SetAllPoints(border)
			local highlight = MerchantGuildBankRepairButton:GetHighlightTexture()
			highlight:SetColorTexture(unpack(core.config.color.highlight))
			highlight:SetAllPoints(border)

		elseif name == "MailFrame" then
			local regions = {panel:GetRegions()}
			for _, region in ipairs(regions) do
				if not region:GetName() and region ~= panel.portrait_bg and region ~= panel.portrait_bg.mask then
					region:SetTexture()
					region:Hide()
				end
			end
			panel.portrait:SetSize(70, 70)
			panel.portrait:SetTexture("Interface\\MailFrame\\Mail-Icon")
			core.util.circle_mask(panel, panel.portrait_bg, 5)
			core.util.circle_mask(panel, panel.portrait, 5)

		elseif name == "AuctionHouseFrame" then

			core.util.strip_textures(AuctionHouseFrame.MoneyFrameBorder)
			AuctionHouseFrame.MoneyFrameBorder.MoneyFrame:SetPoint("RIGHT", 0, 0)

			hooksecurefunc(AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, "UpdateAnchoring", function(self)
				if self.GoldDisplay.amount ~= nil and self.GoldDisplay.amount > 0 then
					self.CopperDisplay:Hide()
					self.SilverDisplay:Hide()
					self.GoldDisplay:SetPoint("RIGHT")
				end
			end)

			for i, tab in ipairs(AuctionHouseFrame.Tabs) do
				tab:ClearAllPoints()
				if i == 1 then
					tab:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 1)
				else
					tab:SetPoint("TOPLEFT", AuctionHouseFrame.Tabs[i - 1], "TOPRIGHT", -1, 0)
				end
			end

			lib.skin_button(AuctionHouseFrame.SearchBar.SearchButton)
			lib.skin_stretchbutton(AuctionHouseFrame.SearchBar.FilterButton, nil, {AuctionHouseFrame.SearchBar.FilterButton.Icon})
			core.util.fix_editbox(AuctionHouseFrame.SearchBar.SearchBox)

			hooksecurefunc("FilterButton_SetUp", function(button, info)
				-- AuctionCategoryButtonTemplate
				button.NormalTexture:SetTexture(nil)
				button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
				button.SelectedTexture:SetColorTexture(unpack(core.config.color.selected))
				core.util.fix_string(button.Text, core.config.font_size_sml)
			end)

			core.util.strip_textures(AuctionHouseFrame.CategoriesList.ScrollFrame)
			core.util.fix_scrollbar(AuctionHouseFrame.CategoriesList.ScrollFrame.ScrollBar)

			-- AuctionHouseFrame.BrowseResultsFrame.ItemList.HeaderContainer
			hooksecurefunc(AuctionHouseTableHeaderStringMixin, "Init", function(self)
				-- ColumnDisplayButtonShortTemplate
				lib.skin_button(self, core.config.font_size_sml)
				self.Arrow:ClearAllPoints()
				self.Arrow:SetPoint("RIGHT", self.Text, -5, 0)
			end)

			hooksecurefunc(AuctionHouseTableCellItemDisplayMixin, "Init", function(self)
				self.Icon:SetSize(26, 26)
				self.IconBorder:SetDrawLayer("BACKGROUND", 0)
				self.IconBorder:SetColorTexture(unpack(core.config.color.border))
				core.util.set_outside(self.IconBorder, self.Icon)
				core.util.crop_icon(self.Icon)
			end)

			hooksecurefunc(AuctionHouseFavoritableLineMixin, "InitLine", function(self)
				self:SetHeight(30)
				self.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
			end)

			hooksecurefunc(AuctionHouseItemListMixin, "Init", function(self)
				self.ResultsText:SetShadowOffset(0, 0)
			end)

			hooksecurefunc(AuctionHouseTableCellMinPriceMixin, "Init", function(self)
				hooksecurefunc(self.MoneyDisplay, "UpdateAnchoring", function(self)
					if self.GoldDisplay.amount ~= nil and self.GoldDisplay.amount > 0 then
						self.SilverDisplay:Hide()
						self.GoldDisplay:SetPoint("RIGHT", self.CopperDisplay, "RIGHT")
					end
				end)
			end)
			
			core.util.fix_scrollbar(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollFrame.scrollBar)

		elseif name == "CommunitiesFrame" then

			hooksecurefunc(CommunitiesFrame.MaximizeMinimizeFrame, "Minimize", function(frame)
				local communitiesFrame = frame:GetParent()
				communitiesFrame.StreamDropDownMenu:SetPoint("LEFT", communitiesFrame.CommunitiesListDropDownMenu, "RIGHT", 5, 0);
			end)

			hooksecurefunc(CommunitiesFrame.MaximizeMinimizeFrame, "Maximize", function(frame)
				local communitiesFrame = frame:GetParent()
				communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", 200, -32)
			end)
			
			-- CommunitiesFrame.CommunitiesList
			core.util.strip_textures(CommunitiesFrame.CommunitiesList)
			core.util.fix_scrollbar(CommunitiesFrame.CommunitiesList.ListScrollFrame.ScrollBar)
			core.util.strip_textures(CommunitiesFrame.CommunitiesList.FilligreeOverlay)
			CommunitiesFrame.CommunitiesList.FilligreeOverlay:Hide()
			CommunitiesFrame.CommunitiesList.InsetFrame:Hide()
			CommunitiesFrame.CommunitiesList:SetPoint("TOPLEFT", 1, -23)
			CommunitiesFrame.CommunitiesList:SetPoint("BOTTOMRIGHT", CommunitiesFrame, "BOTTOMLEFT", 160, 29)
			CommunitiesFrame.CommunitiesList.ListScrollFrame.ScrollBar:SetPoint("TOPLEFT", CommunitiesFrame.CommunitiesList.ListScrollFrame, "TOPRIGHT", 1, -15)
			CommunitiesFrame.CommunitiesList.ListScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", CommunitiesFrame.CommunitiesList.ListScrollFrame, "BOTTOMRIGHT", 1, 11)
			CommunitiesFrame.CommunitiesList.ListScrollFrame.ScrollBar.Background:SetTexture()

			-- CommunitiesListEntryTemplate
			hooksecurefunc(CommunitiesListEntryMixin, "SetClubInfo", function(self)
				self.Background:SetTexture()
				self.Selection:SetColorTexture(unpack(core.config.color.selected))
				self.Selection:SetAllPoints()
				self:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				self:GetHighlightTexture():SetAllPoints()
			end)

			hooksecurefunc(CommunitiesListEntryMixin, "SetFindCommunity", function(self)
				self.Background:SetTexture()
				self.Selection:SetColorTexture(unpack(core.config.color.selected))
				self.Selection:SetAllPoints()
				self:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				self:GetHighlightTexture():SetAllPoints()
			end)

			hooksecurefunc(CommunitiesListEntryMixin, "SetAddCommunity", function(self)
				self.Background:SetTexture()
				self.Selection:SetColorTexture(unpack(core.config.color.selected))
				self.Selection:SetAllPoints()
				self:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				self:GetHighlightTexture():SetAllPoints()
			end)

			hooksecurefunc(CommunitiesListEntryMixin, "SetGuildFinder", function(self)
				self.Background:SetTexture()
				self.Selection:SetColorTexture(unpack(core.config.color.selected))
				self.Selection:SetAllPoints()
				self:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				self:GetHighlightTexture():SetAllPoints()
			end)

			-- CommunitiesFrameTabTemplate
			local skin_tab = function(tab)
				local regions = {tab:GetRegions()}
				for _, region in ipairs(regions) do
					if region:GetDrawLayer() == "BORDER" then
						core.util.set_outside(region, tab)
						region:SetColorTexture(unpack(core.config.color.border))
					end
				end
				
				tab.Icon:SetAllPoints()
				core.util.crop_icon(tab.Icon)

				tab:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				tab:GetCheckedTexture():SetColorTexture(unpack(core.config.color.selected))
			end

			skin_tab(CommunitiesFrame.ChatTab)
			skin_tab(CommunitiesFrame.RosterTab)
			skin_tab(CommunitiesFrame.GuildBenefitsTab)
			skin_tab(CommunitiesFrame.GuildInfoTab)

			lib.skin_dropdown(CommunitiesFrame.StreamDropDownMenu)
			hooksecurefunc(CommunitiesFrame, "UpdateStreamDropDown", function(self)
				self.StreamDropDownMenu:SetHeight(24)
			end)
			CommunitiesFrame.CommunitiesListDropDownMenu:SetWidth(115)
			CommunitiesFrame.CommunitiesListDropDownMenu:SetPoint("TOPLEFT", 10, -28)
			lib.skin_dropdown(CommunitiesFrame.CommunitiesListDropDownMenu)
			CommunitiesFrame.CommunitiesListDropDownMenu:HookScript("OnShow", function(self)
				self:SetHeight(24)
			end)
			lib.skin_dropdown(CommunitiesFrame.GuildMemberListDropDownMenu)
			CommunitiesFrame.GuildMemberListDropDownMenu:HookScript("OnShow", function(self)
				self:SetHeight(24)
			end)
			lib.skin_dropdown(CommunitiesFrame.CommunityMemberListDropDownMenu)
			CommunitiesFrame.CommunityMemberListDropDownMenu:HookScript("OnShow", function(self)
				self:SetHeight(24)
			end)

			-- CommunitiesFrame.MemberList
			core.util.strip_textures(CommunitiesFrame.MemberList.WatermarkFrame)
			core.util.strip_textures(CommunitiesFrame.MemberList.ColumnDisplay)
			hooksecurefunc(CommunitiesFrame.MemberList.ColumnDisplay, "LayoutColumns", function(self)
				for button in pairs(self.columnHeaders.activeObjects) do
					lib.skin_button(button, core.config.font_size_sml)
				end
			end)

			core.util.fix_scrollbar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
			CommunitiesFrame.MemberList.ListScrollFrame.scrollBar.Background:SetTexture()

			hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
				local buttons = self.ListScrollFrame.buttons
				for i = 1, #buttons do
					local button = buttons[i]
					button:SetHeight(22)
					button:GetNormalTexture():SetTexture()
					button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
					button.Class:SetSize(22, 22)
					local left, top, _, bottom, right = button.Class:GetTexCoord()
					button.Class:SetTexCoord(left + 0.019, right - 0.019, top + 0.019, bottom - 0.019)
				end
			end)

			-- CommunitiesFrame.Chat
			core.util.fix_scrollbar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
			lib.skin_button(JumpToUnreadButton)

			-- CommunitiesFrame.ChatEditBox
			core.util.fix_editbox(CommunitiesFrame.ChatEditBox)

			lib.skin_button(CommunitiesFrame.InviteButton)
			CommunitiesFrame.InviteButton:SetPoint("BOTTOMRIGHT", -5, 2)
			lib.skin_button(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
			CommunitiesFrame.CommunitiesControlFrame:SetPoint("BOTTOMRIGHT", -5, 2)
		end

	elseif name == "WorldMapFrame" then

		WorldMapFrame.BorderFrame.InsetBorderTop:Hide()
		lib.skin_help(WorldMapFrame.BorderFrame.Tutorial)

		-- WorldMapFrame.NavBar
		core.util.strip_textures(WorldMapFrame.NavBar, true)
		WorldMapFrame.NavBar.overlay:Hide()
		core.util.strip_textures(WorldMapFrame.NavBar.home, true, {WorldMapFrame.NavBar.home:GetHighlightTexture()})
		WorldMapFrame.NavBar.home:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
		WorldMapFrame.NavBar.home:GetHighlightTexture():ClearAllPoints()
		WorldMapFrame.NavBar.home:GetHighlightTexture():SetPoint("TOPLEFT")
		WorldMapFrame.NavBar.home:GetHighlightTexture():SetPoint("BOTTOMRIGHT", -20, 0)
		
		hooksecurefunc(WorldMapFrame.NavBar, "Refresh", function(self)
			for _, nav in ipairs(self.navList) do
				if nav.selected then
					nav.text:SetPoint("LEFT", 2, 0)
					nav:SetText("->  "..nav:GetText())
					nav.selected:SetColorTexture(unpack(core.config.color.selected))
					nav.arrowUp:SetTexture(nil)
					nav.arrowDown:SetTexture(nil)
					nav:SetNormalTexture(nil)
					nav:SetPushedTexture(nil)
					nav:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))

					core.util.strip_textures(nav.MenuArrowButton, true, {nav.MenuArrowButton.Art})
				end
			end
		end)

		WorldMapFrame.QuestLog.Background:Hide()
		WorldMapFrame.QuestLog.VerticalSeparator:Hide()
		core.util.gen_backdrop(WorldMapFrame.QuestLog.QuestsFrame,  unpack(core.config.frame_background_transparent))
		core.util.strip_textures(WorldMapFrame.QuestLog.QuestsFrame.ScrollBar, true)
		core.util.fix_scrollbar(WorldMapFrame.QuestLog.QuestsFrame.ScrollBar)
		WorldMapFrame.QuestLog.QuestsFrame.DetailFrame:Hide()
		WorldMapFrame.QuestLog.QuestSessionManagement.BG:Hide()

		-- QuestMapFrame
		core.util.strip_textures(QuestMapFrame.DetailsFrame, true, {
			QuestMapFrame.DetailsFrame.Bg,
			QuestMapFrame.DetailsFrame.SealMaterialBG
		})

		lib.skin_button(QuestMapFrame.DetailsFrame.BackButton)
		lib.skin_button(QuestMapFrame.DetailsFrame.AbandonButton)
		lib.skin_button(QuestMapFrame.DetailsFrame.TrackButton)
		core.util.strip_textures(QuestMapFrame.DetailsFrame.ShareButton, true)
		lib.skin_button(QuestMapFrame.DetailsFrame.ShareButton)
		QuestMapFrame.DetailsFrame.AbandonButton:SetWidth(110)
		QuestMapFrame.DetailsFrame.ShareButton:SetWidth(85)
		QuestMapFrame.DetailsFrame.ShareButton:SetPoint("LEFT", QuestMapFrame.DetailsFrame.AbandonButton, "RIGHT", -1, 0)
		QuestMapFrame.DetailsFrame.TrackButton:SetPoint("LEFT", QuestMapFrame.DetailsFrame.ShareButton, "RIGHT", -1, 0)

	elseif name == "GameMenuFrame" then

		GameMenuFrame:SetWidth(194)
		GameMenuFrame.Header:SetPoint("TOP", 0, 5)
		core.util.strip_textures(GameMenuFrame.Header, true)
		for _, child in ipairs({GameMenuFrame:GetChildren()}) do
			if child:GetObjectType() == "Button" then
				child:SetHeight(20)
				lib.skin_button(child)
			end
		end

	elseif name == "FlightMapFrame" then
		core.util.circle_mask(panel.BorderFrame, panel.BorderFrame.portrait_bg, 4)
		core.util.circle_mask(panel, FlightMapFramePortrait, 4)
		panel.BorderFrame.TopBorder:SetTexture()
		panel.BorderFrame.TopBorder:Hide()

	elseif name == "ScriptErrorsFrame" then

		core.util.fix_string(panel.Title, core.config.font_size_med)

		core.util.strip_textures(panel, true)
		panel:SetScale(core.config.ui_scale)
		panel:SetSize(500, 300)
		panel.DragArea:ClearAllPoints()
		panel.DragArea:SetPoint("TOPLEFT")
		panel.DragArea:SetPoint("TOPRIGHT")
		panel.DragArea:SetHeight(30)

		panel.ScrollFrame:SetSize(490, 220)
		panel.ScrollFrame:SetPoint("TOPLEFT", 5, -30)
		
		panel.ScrollFrame.Text:SetSize(490, 220)
		core.util.fix_string(panel.ScrollFrame.Text, core.config.font_size_med)

		core.util.fix_scrollbar(panel.ScrollFrame.ScrollBar)

		panel:ClearAllPoints()
		panel:SetPoint("BOTTOMLEFT")
		core.util.gen_backdrop(panel)

		lib.skin_button(panel.Close)
		lib.skin_button(panel.Reload)
		
	end

	if not nested then
		core.util.gen_backdrop(panel, unpack(core.config.frame_background_transparent))
		panel.skinned = true
	end
end

hooksecurefunc(PvpTalentSlotMixin, "Update", function(self)
	self.Border:SetTexture(core.media.textures.blank)
	self.Border:SetVertexColor(unpack(core.config.color.border))
end)

hooksecurefunc("TalentFrame_Update", function(frame, talentUnit)
	for r = 1, MAX_TALENT_TIERS do
		local row = PlayerTalentFrameTalents["tier"..r]
		for t = 1, NUM_TALENT_COLUMNS do
			local talent = row["talent"..t]
			if talent.knownSelection then
				talent.knownSelection:SetTexture(core.media.textures.blank)
				talent.knownSelection:SetVertexColor(unpack(core.config.color.selected))
			end
			if talent.highlight then
				talent.highlight:SetVertexColor(unpack(core.config.color.highlight))
			end
		end
	end
end)

hooksecurefunc("SpellButton_OnShow", function(button)
	if button.skinned then return end

	if button.EmptySlot then
		button.EmptySlot:SetTexture(core.media.textures.blank)
		button.EmptySlot:SetVertexColor(unpack(core.config.color.border))
		core.util.set_outside(button.EmptySlot, button)
		button.TextBackground:Hide()
		button.TextBackground2:Hide()
		button.IconTextureBg:SetTexture(core.media.textures.blank)
		button.IconTextureBg:SetVertexColor(unpack(core.config.color.background))
		_G[button:GetDebugName().."SlotFrame"]:SetTexture(nil)
		core.util.set_outside(_G[button:GetDebugName().."AutoCastable"], button)
		_G[button:GetDebugName().."AutoCastable"]:SetTexCoord(0.22, 0.76, 0.22, 0.77)

		core.util.set_outside(button.SpellHighlightTexture, button)
		button.SpellHighlightTexture:SetDrawLayer("BACKGROUND", 1)
		button.SpellHighlightTexture:SetTexture(core.media.textures.blank)
	end
	button:SetPushedTexture(core.media.textures.blank)
	button:GetPushedTexture():SetVertexColor(unpack(core.config.color.pushed))
	button:GetPushedTexture():SetBlendMode("ADD")

	button:SetCheckedTexture(core.media.textures.blank)
	button:GetCheckedTexture():SetVertexColor(unpack(core.config.color.selected))

	_G[button:GetDebugName().."IconTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	button.skinned = true
end)

hooksecurefunc("UpdateProfessionButton", function(button)
	button:GetHighlightTexture():SetTexture(core.media.textures.blank)
	button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
end)

hooksecurefunc("SpellButton_UpdateButton", function(button)
	if button.IconTextureBg then
		button.IconTextureBg:Show()
	end
	
	if button.SpellName then
		button.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		button.SpellSubName:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
		button.RequiredLevelString:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
	end
	
	button:GetHighlightTexture():SetTexture(core.media.textures.blank)
	button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
	
	if button.shine then
		button.shine:SetAllPoints()
	end
end)

hooksecurefunc("ReputationFrame_SetRowType", function(factionRow, isChild, isHeader, hasRep)
	local factionRowName = factionRow:GetName()
	_G[factionRowName.."Background"]:Hide()
	_G[factionRowName.."ReputationBarLeftTexture"]:Hide()
	_G[factionRowName.."ReputationBarRightTexture"]:Hide()
	
	local factionBar = _G[factionRowName.."ReputationBar"]
	factionBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
	factionBar:SetStatusBarTexture(core.media.textures.blank)
	core.util.gen_backdrop(factionBar)
	factionBar:SetHeight(16)

	_G[factionRowName.."ReputationBarAtWarHighlight1"]:SetTexture(core.media.textures.blank)
	_G[factionRowName.."ReputationBarAtWarHighlight1"]:SetVertexColor(1, 0.25, 0.25, 0.25)
	_G[factionRowName.."ReputationBarAtWarHighlight2"]:SetTexture(nil)

	_G[factionRowName.."ReputationBarHighlight1"]:SetTexture(core.media.textures.blank)
	_G[factionRowName.."ReputationBarHighlight1"]:SetVertexColor(unpack(core.config.color.highlight))
	_G[factionRowName.."ReputationBarHighlight1"]:SetAllPoints(factionRow)
	_G[factionRowName.."ReputationBarHighlight2"]:SetTexture(nil)
end)

hooksecurefunc("PaperDollFrame_UpdateStats", function()
	for frame in CharacterStatsPane.statsFramePool:EnumerateActive() do
		frame.Background:Hide()
	end
end)

hooksecurefunc("PanelTemplates_TabResize", function(tab)
	lib.skin_tab(tab)

	local tabName = tab:GetName()
	local buttonMiddle = tab.Middle or tab.middleTexture or _G[tabName.."Middle"]
	local buttonMiddleDisabled = tab.MiddleDisabled or (tabName and _G[tabName.."MiddleDisabled"])
	local left = tab.Left or tab.leftTexture or _G[tabName.."Left"]
	local right = tab.Right or tab.rightTexture or _G[tabName.."Right"]
	local tabText = tab.Text or _G[tab:GetName().."Text"]
	local highlightTexture = tab.HighlightTexture or (tabName and _G[tabName.."HighlightTexture"])

	local width = tabText:GetWidth() + 12
	
	tab:SetWidth(width)
	if buttonMiddle then buttonMiddle:SetWidth(width) end
	if buttonMiddleDisabled then buttonMiddleDisabled:SetWidth(width) end

	left:SetWidth(0)
	right:SetWidth(0)
	
	tabText:ClearAllPoints()
	tabText:SetPoint("CENTER", tab)

	if highlightTexture then core.util.set_inside(highlightTexture, tab) end
end)

hooksecurefunc("PanelTemplates_SelectTab", function(tab)
	lib.skin_tab(tab)
	local tabText = tab.Text or _G[tab:GetName().."Text"]
	tabText:ClearAllPoints()
	tabText:SetPoint("CENTER", tab)
	tab.selected_texture:Show()
end)

hooksecurefunc("PanelTemplates_DeselectTab", function(tab)
	lib.skin_tab(tab)
	local tabText = tab.Text or _G[tab:GetName().."Text"]
	tabText:ClearAllPoints()
	tabText:SetPoint("CENTER", tab)
	tab.selected_texture:Hide()
end)

hooksecurefunc("PaperDollTitlesPane_Update", function()
	local buttons = PaperDollTitlesPane.buttons
	for i = 1, #buttons do
		button = buttons[i]
		if not button.skinned then
			button.BgTop:SetTexture(nil)
			button.BgBottom:SetTexture(nil)
			button.BgMiddle:Hide()
			button.SelectedBar:SetTexture(core.media.textures.blank)
			button.SelectedBar:SetVertexColor(unpack(core.config.color.selected))
			button:GetHighlightTexture():SetTexture(core.media.textures.blank)
			button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
			button.Check:SetTexture(nil)
			button.text:SetPoint("LEFT", 3, 0)

			button.skinned = true
		end
	end
end)

hooksecurefunc("PaperDollEquipmentManagerPane_Update", function()
	local buttons = PaperDollEquipmentManagerPane.buttons;
	for i = 1, #buttons do
		button = buttons[i]
		if not button.skinned then
			button.BgTop:SetTexture(nil)
			button.BgBottom:SetTexture(nil)
			button.BgMiddle:Hide()
			button.SelectedBar:SetTexture(core.media.textures.blank)
			button.SelectedBar:SetVertexColor(unpack(core.config.color.selected))
			button.HighlightBar:SetTexture(core.media.textures.blank)
			button.HighlightBar:SetVertexColor(unpack(core.config.color.highlight))

			button.icon_bg = button:CreateTexture(nil, "Border")
			button.icon_bg:SetTexture(core.media.textures.blank)
			button.icon_bg:SetVertexColor(unpack(core.config.color.border))
			core.util.set_outside(button.icon_bg, button.icon)

			button.SpecRing:SetTexture(nil)
			core.util.crop_icon(button.icon)

			button.skinned = true
		end
	end
end)

hooksecurefunc("GearSetButton_SetSpecInfo", function(self, specID)
	if ( specID and specID > 0 ) then
		local _, _, _, texture = GetSpecializationInfoByID(specID);
		self.SpecIcon:SetTexture(texture)
		core.util.crop_icon(self.SpecIcon)
		if not self.spec_bg then
			self.spec_bg = self:CreateTexture(nil, "OVERLAY", nil, -4)
			self.spec_bg:SetTexture(core.media.textures.blank)
			self.spec_bg:SetVertexColor(unpack(core.config.color.border))
			core.util.set_outside(self.spec_bg, self.SpecIcon)
		end
		self.spec_bg:Show()
	else
		if self.spec_bg then
			self.spec_bg:Hide()
		end
	end
end)

hooksecurefunc("EquipmentFlyout_CreateButton", function()
	for _, item in ipairs(EquipmentFlyoutFrame.buttons) do
		lib.skin_item(item)
	end
end)

EquipmentFlyoutFrame.Highlight:SetColorTexture(unpack(core.config.color.highlight))
hooksecurefunc("EquipmentFlyout_Show", function(item)
	local i = 1
	while EquipmentFlyoutFrame.buttonFrame["bg"..i] do
		EquipmentFlyoutFrame.buttonFrame["bg"..i]:Hide()
		i = i + 1
	end
	core.util.set_outside(EquipmentFlyoutFrame.Highlight, item)
end)

for _, name in ipairs(panels) do
	skin_panel(name)
end

StackSplitFrame:SetFrameStrata("DIALOG")
StackSplitFrame:SetFrameLevel(2)

hooksecurefunc(MoneyDenominationDisplayMixin, "OnLoad", function(self)
	self.Text:SetShadowOffset(0, 0)
end)

hooksecurefunc(MoneyDenominationDisplayMixin, "UpdateWidth", function(self)
	self.Icon:SetSize(15, 15)
	self.Text:ClearAllPoints()
	self.Text:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMLEFT")
end)

hooksecurefunc(MoneyDenominationDisplayMixin, "UpdateDisplayType", function(self)
	self.Icon:SetSize(15, 15)
end)

local skin_token = function()

	-- TokenFrame
	core.util.gen_backdrop(TokenFrameContainer, unpack(core.config.frame_background_transparent))
	core.util.fix_scrollbar(TokenFrameContainerScrollBar)
	TokenFrameContainerScrollBar:SetPoint("TOPLEFT", TokenFrameContainer, "TOPRIGHT", 2, -16)
	TokenFrameContainerScrollBar:SetPoint("BOTTOMLEFT", TokenFrameContainer, "BOTTOMRIGHT", 2, 16)

	hooksecurefunc("TokenFrame_Update", function()
		if not TokenFrameContainer.buttons then return end
		local button
		for i=1, #TokenFrameContainer.buttons do
			button = TokenFrameContainer.buttons[i]
			if not button.skinned then
				button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				button.categoryLeft:SetTexture(nil)
				button.categoryRight:SetTexture(nil)
				button.categoryMiddle:SetTexture(nil)
				button.stripe:SetTexture(nil)
				button.highlight:SetVertexColor(unpack(core.config.color.highlight))
				button.highlight.alt_SetTexture = button.highlight.SetTexture
				hooksecurefunc(button.highlight, "SetTexture", function(self)
					self:alt_SetTexture(core.media.textures.blank)
				end)
				button:SetHighlightTexture(core.media.textures.blank)
				button.skinned = true
			end
		end
	end)
end

local skin_challenges = function()

	core.util.strip_textures(ChallengesFrame, true, {ChallengesFrame.Background})
	ChallengesFrameInset:Hide()

	hooksecurefunc("ChallengesFrame_Update", function(self)
		local prev
		for _, dungeon in ipairs(self.DungeonIcons) do
			local border
			for _, region in ipairs({dungeon:GetRegions()}) do
				if region ~= dungeon.Icon and region ~= dungeon.HighestLevel then
					border = region
				end
			end
			
			border:SetDrawLayer("BACKGROUND", -1)
			border:SetColorTexture(unpack(core.config.color.border))
			core.util.set_inside(dungeon.Icon, dungeon)
			dungeon.Icon:SetTexCoord(.05, .95, .05, .95)
	
			core.util.fix_string(dungeon.HighestLevel, core.config.font_size_lrg)

			if prev then
				dungeon:ClearAllPoints()
				dungeon:SetPoint("BOTTOMLEFT", prev, "BOTTOMRIGHT", 2, 0)
			end
			prev = dungeon
		end
	end)
end

local skin_pvp = function()

	lib.skin_button(PVPQueueFrame.NewSeasonPopup.Leave)

	for t = 1, 3 do
		local button = PVPQueueFrame["CategoryButton"..t]

		button.selected = button:CreateTexture()
		button.selected:SetColorTexture(unpack(core.config.color.selected))
		button.selected:SetAllPoints(button)
		button.selected:Hide()

		button.Background:Hide()
		button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
		button:GetHighlightTexture():SetAllPoints(button)

		button.Ring:SetColorTexture(unpack(core.config.color.border))
		button.Ring:SetDrawLayer("ARTWORK", -1)
		core.util.circle_mask(button, button.Ring, 4)
		button.Ring:SetSize(button.Icon:GetWidth(), button.Icon:GetHeight())
		button.Ring:SetPoint("LEFT")
		core.util.circle_mask(button, button.Icon, 5)
	end

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		for t = 1, 3 do
			local button = PVPQueueFrame["CategoryButton"..t]
			if t == index then
				button.selected:Show()
			else
				button.selected:Hide()
			end
		end
	end)

	HonorFrame.ConquestBar.Border:SetTexture(nil)
	HonorFrame.ConquestBar.Border:Hide()
	HonorFrame.ConquestBar.Background:SetTexture(nil)
	HonorFrame.ConquestBar.Background:Hide()
	core.util.gen_backdrop(HonorFrame.ConquestBar)
	HonorFrame.ConquestBar:SetStatusBarTexture(core.media.textures.blank)

	HonorFrame.Inset.Bg:Hide()
	HonorFrame.Inset.NineSlice:Hide()

	HonorFrameTypeDropDown:SetPoint("BOTTOMRIGHT", HonorFrame.Inset, "TOPRIGHT", -5, 5)
	lib.skin_dropdown(HonorFrameTypeDropDown)
	core.util.fix_scrollbar(HonorFrameSpecificFrameScrollBar)

	lib.skin_button(HonorFrame.QueueButton)

	ConquestFrame.ConquestBar.Border:SetTexture(nil)
	ConquestFrame.ConquestBar.Border:Hide()
	ConquestFrame.ConquestBar.Background:SetTexture(nil)
	ConquestFrame.ConquestBar.Background:Hide()
	core.util.gen_backdrop(ConquestFrame.ConquestBar)
	ConquestFrame.ConquestBar:SetStatusBarTexture(core.media.textures.blank)

	ConquestFrame.Inset.Bg:Hide()
	ConquestFrame.Inset.NineSlice:Hide()

	lib.skin_button(ConquestFrame.JoinButton)

	core.util.strip_textures(PVPQueueFrame.HonorInset, true)
	PVPQueueFrame.HonorInset.NineSlice:Hide()
end

if IsAddOnLoaded("Blizzard_AuctionHouseUI") then
	skin_panel(AuctionHouseFrame)
end

if IsAddOnLoaded("Blizzard_TokenUI") then
	skin_token()
end

if IsAddOnLoaded("Blizzard_TalentUI") then
	skin_panel(PlayerTalentFrame)
end

if IsAddOnLoaded("Blizzard_Collections") then
	skin_panel(CollectionsJournal)
end

if IsAddOnLoaded("Blizzard_FlightMap") then
	skin_panel(FlightMapFrame)
end

if IsAddOnLoaded("Blizzard_PVPUI") then
	skin_pvp()
end

if IsAddOnLoaded("Blizzard_ChallengesUI") then
	skin_challenges()
end

if IsAddOnLoaded("Blizzard_Communities") then
	skin_panel(CommunitiesFrame)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TokenUI" then
		skin_token()
	elseif addon == "Blizzard_TalentUI" then
		skin_panel(PlayerTalentFrame)
	elseif addon == "Blizzard_Collections" then
		skin_panel(CollectionsJournal)
	elseif addon == "Blizzard_FlightMap" then
		skin_panel(FlightMapFrame)
	elseif addon == "Blizzard_AuctionHouseUI" then
		skin_panel(AuctionHouseFrame)
	elseif addon == "Blizzard_PVPUI" then
		skin_pvp()
	elseif addon == "Blizzard_ChallengesUI" then
		skin_challenges()
	elseif addon == "Blizzard_Communities" then
		skin_panel(CommunitiesFrame)
	end
end)
