local _, addon = ...
if not addon.skin.enabled then return end
local core = addon.core
local lib = addon.skin.lib

local panels = {
	CharacterFrame,
	SpellBookFrame,
	WorldMapFrame,
	PVEFrame,
	GossipFrame,
	FriendsFrame,
	QuestFrame,
	GameMenuFrame
}

local skin_panel

skin_panel = function(panel, nested)
	if panel.skinned then return end

	local children = {panel:GetChildren()}
	for _, child in ipairs(children) do
		skin_panel(child, true)
	end

	local name = panel:GetDebugName()
	local type = force_type or panel.layoutType
	local obj_type = panel:GetObjectType()

	if type == "InsetFrameTemplate" then
		panel.Bg:Hide()
		panel.NineSlice:Hide()
	elseif type == "Dialog" then
		lib.strip_textures(panel, true)
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
		
		panel.portrait_icon_bg = panel:CreateTexture(nil, "OVERLAY", nil, -2)
		panel.portrait_icon_bg:SetAllPoints(panel.portrait)
		panel.portrait_icon_bg:SetColorTexture(unpack(core.config.color.border))

		panel.portrait_bg = panel:CreateTexture(nil, "OVERLAY", nil, -3)
		panel.portrait_bg:SetTexture(core.media.textures.blank)
		panel.portrait_bg:SetVertexColor(unpack(core.config.color.light_border))
		core.util.set_outside(panel.portrait_bg, panel.portrait)

		hooksecurefunc(panel, "SetPortraitShown", function(self, shown)
			if shown then
				panel.portrait_bg:Show()
				panel.portrait_icon_bg:Show()
			else
				panel.portrait_bg:Hide()
				panel.portrait_icon_bg:Hide()
			end
		end)
		
		if name == "CharacterFrame" then
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
			lib.strip_textures(ReputationListScrollFrame, true)
			core.util.gen_backdrop(ReputationListScrollFrame, unpack(core.config.frame_background_transparent))
			core.util.fix_scrollbar(ReputationListScrollFrameScrollBar)
			ReputationListScrollFrameScrollBar:SetPoint("TOPLEFT", ReputationListScrollFrame, "TOPRIGHT", 2, -16)
			ReputationListScrollFrameScrollBar:SetPoint("BOTTOMLEFT", ReputationListScrollFrame, "BOTTOMRIGHT", 2, 16)

			lib.strip_textures(ReputationDetailFrame, true)
			core.util.gen_backdrop(ReputationDetailFrame, unpack(core.config.frame_background_transparent))
			
			core.util.fix_string(ReputationDetailFactionName, core.config.font_size_sml)
			core.util.fix_string(ReputationDetailFactionDescription, core.config.font_size_sml)
		
		elseif name == "SpellBookFrame" then
			
			--SpellBookFrame.MainHelpButton:ClearAllPoints()
			--SpellBookFrame.MainHelpButton:SetPoint("CENTER", SpellBookFrame.portrait, "BOTTOMRIGHT")
			lib.skin_help(SpellBookFrame.MainHelpButton)

			SpellBookFrame.portrait:SetTexture("Interface\\Spellbook\\Spellbook-Icon")
			SpellBookFrame.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			
			-- SpellBookFrame.portrait_bg = SpellBookFrame:CreateTexture(nil, "OVERLAY", nil, -2)
			-- SpellBookFrame.portrait_bg:SetTexture(core.media.textures.blank)
			-- SpellBookFrame.portrait_bg:SetVertexColor(unpack(core.config.color.light_border))
			-- core.util.set_outside(SpellBookFrame.portrait_bg, SpellBookFrame.portrait)
			-- SpellBookFrame.portrait:SetBlendMode("DISABLE")

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
				_G["PrimaryProfession"..p.."IconBorder"]:SetTexture(core.media.textures.blank)
				_G["PrimaryProfession"..p.."IconBorder"]:SetVertexColor(unpack(core.config.color.border))
				_G["PrimaryProfession"..p.."IconBorder"]:SetDrawLayer("BACKGROUND")
				prof.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				prof.icon:SetAlpha(1)

				prof.unlearn:ClearAllPoints()
				prof.unlearn:SetPoint("CENTER", prof.icon, "BOTTOMRIGHT")
				
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
				lib.strip_textures(prof.statusBar, true)
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
				lib.strip_textures(prof.statusBar, true)
				prof.statusBar:SetStatusBarTexture(core.media.textures.blank)
				prof.statusBar:SetStatusBarColor(0.25, 0.75, 0.25)
				prof.statusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
				core.util.gen_backdrop(prof.statusBar)

				prof.missingText:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
			end
		
		elseif name == "PlayerTalentFrame" then

			--PlayerTalentFrame.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			PlayerTalentFrame.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			local _, texture = GetSpellTabInfo(2)
			PlayerTalentFrame.portrait:SetTexture(texture)
			
			-- PlayerTalentFrame.portrait_bg = PlayerTalentFrame:CreateTexture(nil, "OVERLAY", nil, -2)
			-- PlayerTalentFrame.portrait_bg:SetTexture(core.media.textures.blank)
			-- PlayerTalentFrame.portrait_bg:SetVertexColor(unpack(core.config.color.light_border))
			-- core.util.set_outside(PlayerTalentFrame.portrait_bg, PlayerTalentFrame.portrait)
			-- PlayerTalentFrame.portrait:SetBlendMode("DISABLE")

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
				spell.ring:SetTexture(core.media.textures.blank)
				spell.ring:SetVertexColor(unpack(core.config.color.border))
				spell.ring:SetDrawLayer("ARTWORK", -1)
				spell.ring:SetSize(spell.icon:GetWidth() + 2, spell.icon:GetHeight() + 2)
			end

			local skin_spec_frame = function(spec)
				lib.strip_textures(spec, true)
				lib.skin_help(spec.MainHelpButton)
				lib.skin_button(spec.learnButton)
				spec.learnButton.Flash:SetColorTexture(unpack(core.config.color.selected))
				core.util.set_inside(spec.learnButton.Flash, spec.learnButton)

				for t = 1, 5 do
					local tab = spec["specButton"..t]
					tab.bg:Hide()
					
					tab.ring:SetTexture(core.media.textures.blank)
					tab.ring:SetVertexColor(unpack(core.config.color.border))
					tab.ring:SetDrawLayer("ARTWORK", -1)
					tab.ring:SetSize(tab.specIcon:GetWidth() + 2, tab.specIcon:GetHeight() + 2)
					tab.ring:SetPoint("LEFT")

					tab.specName:SetPoint("TOPLEFT", tab.ring, "TOPRIGHT", 10, -20)

					tab.selectedTex:SetTexture(core.media.textures.blank)
					tab.selectedTex:SetVertexColor(unpack(core.config.color.pushed))
					tab.selectedTex:SetAllPoints()

					tab.learnedTex:SetTexture(core.media.textures.blank)
					tab.learnedTex:SetVertexColor(unpack(core.config.color.selected))
					tab.learnedTex:SetAllPoints()

					tab:SetHighlightTexture(core.media.textures.blank)
					tab:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
					tab:GetHighlightTexture():SetAllPoints()

					tab:SetHeight(tab.specIcon:GetWidth() + 2)
				end
				for _, child in ipairs({spec:GetChildren()}) do
					if not child:GetName() then
						child:Hide()
					end
				end
				local scroll = spec.spellsScroll
				lib.strip_textures(scroll, true)
				core.util.fix_scrollbar(scroll.ScrollBar)
				scroll.child.gradient:Hide()
				scroll.child.scrollwork_topleft:Hide()
				scroll.child.scrollwork_topright:Hide()
				scroll.child.scrollwork_bottomleft:Hide()
				scroll.child.scrollwork_bottomright:Hide()

				scroll.child.ring:SetTexture(core.media.textures.blank)
				scroll.child.ring:SetVertexColor(unpack(core.config.color.border))
				scroll.child.ring:SetDrawLayer("BORDER", 2)
				scroll.child.ring:SetSize(scroll.child.specIcon:GetWidth() + 2, scroll.child.specIcon:GetHeight() + 2)

				scroll.child.specIcon:SetPoint("CENTER", scroll.child.ring)

				scroll.child.specName:SetPoint("BOTTOMLEFT", scroll.child.ring, "RIGHT", 10, 3)
				
				scroll.child.Seperator:SetColorTexture(unpack(core.player.color))
				skin_spec_spell(scroll.child.abilityButton1)
			end
		
			-- PlayerTalentFrameSpecialization
			-- PlayerTalentFramePetSpecialization
			skin_spec_frame(PlayerTalentFrameSpecialization)
			skin_spec_frame(PlayerTalentFramePetSpecialization)

			hooksecurefunc("PlayerTalentFrame_CreateSpecSpellButton", function(self, index)
				skin_spec_spell(self.spellsScroll.child["abilityButton"..index])
			end)

			-- PlayerTalentFrameTalents
			lib.strip_textures(PlayerTalentFrameTalents, true)
			lib.skin_help(PlayerTalentFrameTalents.MainHelpButton)
			
			for r = 1, MAX_TALENT_TIERS do
				local row = PlayerTalentFrameTalents["tier"..r]
				lib.strip_textures(row, true)
				row.GlowFrame.TopGlowLine:SetColorTexture(unpack(core.config.color.highlight))
				row.GlowFrame.TopGlowLine:SetAllPoints()
				row.GlowFrame.BottomGlowLine:Hide()

				for t = 1, NUM_TALENT_COLUMNS do
					local talent = row["talent"..t]
					talent.GlowFrame.TopGlowLine:SetColorTexture(unpack(core.config.color.highlight))
					talent.GlowFrame.TopGlowLine:SetAllPoints()
					talent.GlowFrame.BottomGlowLine:Hide()

					talent.Slot:SetTexture(core.media.textures.blank)
					talent.Slot:SetVertexColor(unpack(core.config.color.border))
					talent.Slot:SetDrawLayer("BACKGROUND", -1)
					talent.Slot:SetSize(talent.icon:GetWidth() + 2, talent.icon:GetHeight() + 2)
					talent.Slot:SetPoint("CENTER", talent.icon)

					talent.knownSelection:SetAllPoints()

					talent.highlight:SetTexture(core.media.textures.blank)
					talent.highlight:SetAllPoints()

					talent.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				end
			end

			-- PlayerTalentFrameTalentsPvpTalentFrame
			lib.strip_textures(PlayerTalentFrameTalents.PvpTalentFrame, true, {
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
			-- FriendsFrame.FriendsTabHeader
			lib.strip_textures(FriendsFrameBattlenetFrame, true)
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

			core.util.gen_backdrop(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
			lib.skin_button(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
			lib.skin_button(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)
			
		end
	elseif name == "WorldMapFrame" then

		WorldMapFrame.BorderFrame.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		WorldMapFrame.BorderFrame.InsetBorderTop:Hide()
		lib.skin_help(WorldMapFrame.BorderFrame.Tutorial)

		-- WorldMapFrame.NavBar
		lib.strip_textures(WorldMapFrame.NavBar, true)
		WorldMapFrame.NavBar.overlay:Hide()
		lib.strip_textures(WorldMapFrame.NavBar.home, true, {WorldMapFrame.NavBar.home:GetHighlightTexture()})
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

					lib.strip_textures(nav.MenuArrowButton, true, {nav.MenuArrowButton.Art})
				end
			end
		end)

		-- QuestMapFrame
		WorldMapFrame.QuestLog.Background:Hide()
		WorldMapFrame.QuestLog.VerticalSeparator:Hide()
		core.util.gen_backdrop(WorldMapFrame.QuestLog.QuestsFrame,  unpack(core.config.frame_background_transparent))
		lib.strip_textures(WorldMapFrame.QuestLog.QuestsFrame.ScrollBar, true)
		core.util.fix_scrollbar(WorldMapFrame.QuestLog.QuestsFrame.ScrollBar)
		WorldMapFrame.QuestLog.QuestsFrame.DetailFrame:Hide()
		WorldMapFrame.QuestLog.QuestSessionManagement.BG:Hide()

	elseif name == "GameMenuFrame" then

		GameMenuFrame:SetWidth(194)
		GameMenuFrame.Header:SetPoint("TOP", 0, 5)
		lib.strip_textures(GameMenuFrame.Header, true)
		for _, child in ipairs({GameMenuFrame:GetChildren()}) do
			if child:GetObjectType() == "Button" then
				child:SetHeight(20)
				lib.skin_button(child)
			end
		end
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

hooksecurefunc("SetPortraitToTexture", function(icon, texture)
	if icon.SetTexture then
		icon:SetTexture(texture)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
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

hooksecurefunc("CharacterFrame_UpdatePortrait", function()
	if (GetSpecialization() ~= nil) then
		CharacterFrame.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end
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

if IsAddOnLoaded("Blizzard_TokenUI") then
	skin_token()
end

if IsAddOnLoaded("Blizzard_TalentUI") then
	skin_panel(PlayerTalentFrame)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TokenUI" then
		skin_token()
	elseif addon == "Blizzard_TalentUI" then
		skin_panel(PlayerTalentFrame)
	end
end)
