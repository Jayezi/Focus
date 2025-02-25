local _, addon = ...

local core = addon.core
local lib = addon.skin.lib

local hooksecurefunc = hooksecurefunc

-- TODO use ClearNormalTexture etc
do
	local panel = ScriptErrorsFrame
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

if not addon.skin.enabled then return end

local panels = {
	CharacterFrame,
	SpellBookFrame,
	PVEFrame,
	GossipFrame,
	QuestFrame,
	FriendsFrame,
	GameMenuFrame,
	MerchantFrame,
	MailFrame,
	TalkingHeadFrame,
}

local role_texts = {}
role_texts[LFG_LIST_GROUP_DATA_ATLASES.TANK] = "|cff5F9BFFT|r"
role_texts[LFG_LIST_GROUP_DATA_ATLASES.HEALER] = "|cff8AFF30H|r"
role_texts[LFG_LIST_GROUP_DATA_ATLASES.DAMAGER] = "|cffFF6161D|r"
role_texts[false] = ""

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
		if panel.NineSlice then panel.NineSlice:Hide() end
	elseif type == "Dialog" then
		core.util.strip_textures(panel, true)
	elseif type == "SimplePanelTemplate" then
		panel.Bg:Hide()
		panel.NineSlice:Hide()
		core.util.gen_backdrop(panel, unpack(core.config.frame_background_transparent))
	elseif type == "PortraitFrameTemplate" or type == "PortraitFrameTemplateMinimizable" or type == "HeldBagLayout" then
		-- PortraitFrameBaseTemplate
		panel.NineSlice:Hide()

		panel.PortraitContainer.portrait:ClearAllPoints()
		panel.PortraitContainer.portrait:SetPoint("TOPLEFT", -10, 10)
		panel.PortraitContainer.bg = panel.PortraitContainer:CreateTexture(nil, "OVERLAY", nil, -2)
		panel.PortraitContainer.bg:SetColorTexture(unpack(core.config.color.light_border))
		core.util.set_outside(panel.PortraitContainer.bg, panel.PortraitContainer.portrait)

		panel.PortraitContainer.portrait.mask = panel.PortraitContainer.CircleMask
		core.util.circle_mask(panel.PortraitContainer, panel.PortraitContainer.portrait, 3)
		core.util.circle_mask(panel.PortraitContainer, panel.PortraitContainer.bg, 3)
		hooksecurefunc(panel, "SetPortraitShown", function(self, shown)
			if shown then
				panel.PortraitContainer.bg:Show()
			else
				panel.PortraitContainer.bg:Hide()
			end
		end)
		
		core.util.fix_string(panel.TitleContainer.TitleText, core.config.font_size_med)

		-- ButtonFrameTemplate
		if panel.Bg then
			panel.Bg:Hide()
			if panel.Bg.SetTexture then
				panel.Bg:SetTexture()
			end
		end

		if panel.TopTileStreaks then
			panel.TopTileStreaks:Hide()
			panel.TopTileStreaks:SetTexture()
		end

		if panel.CloseButton then
			panel.CloseButton:ClearAllPoints()
			panel.CloseButton:SetPoint("TOPRIGHT", -3, -3)
			lib.skin_icon_button(panel.CloseButton, nil, "x")
		end

		if name == "CharacterFrame" then

			-- skinned by PanelTemplates_SelectTab/PanelTemplates_DeselectTab
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
			core.util.fix_string(CharacterStatsPane.ItemLevelCategory.Title, core.config.font_size_med)

			CharacterStatsPane.ItemLevelFrame.Background:Hide()
			core.util.fix_string(CharacterStatsPane.ItemLevelFrame.Value, core.config.font_size_lrg)

			CharacterStatsPane.AttributesCategory.Background:Hide()
			core.util.fix_string(CharacterStatsPane.AttributesCategory.Title, core.config.font_size_med)

			CharacterStatsPane.EnhancementsCategory.Background:Hide()
			core.util.fix_string(CharacterStatsPane.EnhancementsCategory.Title, core.config.font_size_med)

			-- PaperDollFrame

			core.util.fix_string(CharacterLevelText, core.config.font_size_med)
			CharacterLevelText:SetWidth(300)
			core.util.fix_string(CharacterTrialLevelErrorText, core.config.font_size_med)
			hooksecurefunc("PaperDollFrame_SetLevel", function()
				if CharacterTrialLevelErrorText:IsShown() then
					CharacterLevelText:SetPoint("CENTER", PaperDollFrame, "TOP", -46, -32)
				else
					CharacterLevelText:SetPoint("CENTER", PaperDollFrame, "TOP", -46, -40)
				end
			end)

			-- PaperDollSidebarTabs
			PaperDollSidebarTabs.DecorLeft:Hide()
			PaperDollSidebarTabs.DecorRight:Hide()
			-- PaperDollSidebarTabTemplate
			for i = 1, 3 do
				local tab = _G["PaperDollSidebarTab"..i]
				tab.TabBg:SetAllPoints()
				tab.TabBg:SetColorTexture(unpack(core.config.frame_border))
				core.util.set_inside(tab.Icon, tab)
				tab.Hider:SetTexture()
				tab.Highlight:SetAllPoints(tab.Icon)
				tab.Highlight:SetColorTexture(unpack(core.config.color.highlight))
			end

			-- TitleManagerPane

			-- ScrollBox in PaperDollTitlesPane_InitButton
			core.util.fix_scrollbar(PaperDollFrame.TitleManagerPane.ScrollBar)
			PaperDollFrame.TitleManagerPane.ScrollBar:ClearAllPoints()
			PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("TOPLEFT", PaperDollFrame.TitleManagerPane.ScrollBox, "TOPRIGHT")
			PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("BOTTOMLEFT", PaperDollFrame.TitleManagerPane.ScrollBox, "BOTTOMRIGHT")

			-- EquipmentManagerPane

			-- ScrollBox in PaperDollEquipmentManagerPane_InitButton
			lib.skin_button(PaperDollFrame.EquipmentManagerPane.EquipSet)
			lib.skin_button(PaperDollFrame.EquipmentManagerPane.SaveSet)
			PaperDollFrame.EquipmentManagerPane.SaveSet:SetPoint("LEFT", PaperDollFrame.EquipmentManagerPane.EquipSet, "RIGHT", 1, 0)
			core.util.fix_scrollbar(PaperDollFrame.EquipmentManagerPane.ScrollBar)

			PaperDollFrame.EquipmentManagerPane.ScrollBar:ClearAllPoints()
			PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("TOPLEFT", PaperDollFrame.EquipmentManagerPane.ScrollBox, "TOPRIGHT")
			PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("BOTTOMLEFT", PaperDollFrame.EquipmentManagerPane.ScrollBox, "BOTTOMRIGHT")

			-- CharacterModelScene

			for _, region in ipairs({CharacterModelScene:GetRegions()}) do
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
			
			-- ScrollBox in ReputationFrame_InitReputationRow
			core.util.gen_backdrop(ReputationFrame.ScrollBox, unpack(core.config.frame_background_transparent))
			core.util.fix_scrollbar(ReputationFrame.ScrollBar)
			ReputationFrame.ScrollBar:SetPoint("TOPLEFT", ReputationFrame.ScrollBox, "TOPRIGHT")
			ReputationFrame.ScrollBar:SetPoint("BOTTOMLEFT", ReputationFrame.ScrollBox, "BOTTOMRIGHT")

			-- ReputationDetailFrame
			ReputationDetailFrame.alt_SetHeight = ReputationDetailFrame.SetHeight
			hooksecurefunc(ReputationDetailFrame, "SetHeight", function()
				ReputationDetailFrame:alt_SetHeight(250)
			end)
			ReputationDetailAtWarCheckBox:SetPoint("TOPLEFT", 5, -195)
			core.util.strip_textures(ReputationDetailFrame, true)
			core.util.gen_backdrop(ReputationDetailFrame, unpack(core.config.frame_background_transparent))
			core.util.fix_string(ReputationDetailFactionName, core.config.font_size_sml)
			core.util.fix_string(ReputationDetailFactionDescription, core.config.font_size_sml)
		
		elseif name == "InspectFrame" then

			InspectFrameTab1:ClearAllPoints()
			InspectFrameTab1:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 1)

			InspectFrameTab2:ClearAllPoints()
			InspectFrameTab2:SetPoint("TOPLEFT", InspectFrameTab1, "TOPRIGHT", -1, 0)

			InspectFrameTab3:ClearAllPoints()
			InspectFrameTab3:SetPoint("TOPLEFT", InspectFrameTab2, "TOPRIGHT", -1, 0)

			lib.skin_button(InspectPaperDollFrame.ViewButton)
			lib.skin_button(InspectPaperDollItemsFrame.InspectTalents)

			InspectModelFrameBorderTopLeft:Hide()
			InspectModelFrameBorderTopRight:Hide()
			InspectModelFrameBorderBottomLeft:Hide()
			InspectModelFrameBorderBottomRight:Hide()
			InspectModelFrameBorderLeft:Hide()
			InspectModelFrameBorderRight:Hide()
			InspectModelFrameBorderTop:Hide()
			InspectModelFrameBorderBottom:Hide()
			InspectModelFrameBorderBottom2:Hide()

			lib.skin_item_slot(InspectHeadSlot)
			lib.skin_item_slot(InspectNeckSlot)
			lib.skin_item_slot(InspectShoulderSlot)
			lib.skin_item_slot(InspectBackSlot)
			lib.skin_item_slot(InspectChestSlot)
			lib.skin_item_slot(InspectShirtSlot)
			lib.skin_item_slot(InspectTabardSlot)
			lib.skin_item_slot(InspectWristSlot)
			lib.skin_item_slot(InspectHandsSlot)
			lib.skin_item_slot(InspectWaistSlot)
			lib.skin_item_slot(InspectLegsSlot)
			lib.skin_item_slot(InspectFeetSlot)
			lib.skin_item_slot(InspectFinger0Slot)
			lib.skin_item_slot(InspectFinger1Slot)
			lib.skin_item_slot(InspectTrinket0Slot)
			lib.skin_item_slot(InspectTrinket1Slot)
			lib.skin_item_slot(InspectMainHandSlot)
			lib.skin_item_slot(InspectSecondaryHandSlot)

		elseif name == "SpellBookFrame" then
			
			SpellBookPage1:Hide()
			SpellBookPage2:Hide()

			lib.skin_help(SpellBookFrame.MainHelpButton)

			-- skinned by PanelTemplates_SelectTab/PanelTemplates_DeselectTab
			local anchor_tabs = function()
				for t = 1, 5 do
					local tab = _G["SpellBookFrameTabButton"..t]
					tab:ClearAllPoints()
					if t == 1 then
						tab:SetPoint("TOPLEFT", SpellBookFrame, "BOTTOMLEFT", 0, 1)
					else
						tab:SetPoint("TOPLEFT", _G["SpellBookFrameTabButton"..(t - 1)], "TOPRIGHT", -1, 0)
					end
				end
			end
			hooksecurefunc("SpellBookFrame_Update", anchor_tabs)
			anchor_tabs()

			-- SpellBookPageNavigationFrame
			core.util.fix_string(SpellBookPageText, core.config.font_size_med)
			SpellBookPageText:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
			SpellBookPageText:SetPoint("TOPRIGHT", SpellBookPrevPageButton, "TOPLEFT", -5, 0)
			SpellBookPageText:SetPoint("BOTTOMRIGHT", SpellBookPrevPageButton, "BOTTOMLEFT", -5, 0)

			lib.skin_icon_button(SpellBookNextPageButton, nil, ">")
			SpellBookNextPageButton:SetPoint("BOTTOMRIGHT", -3, 3)

			lib.skin_icon_button(SpellBookPrevPageButton, nil, "<")
			SpellBookPrevPageButton:SetPoint("BOTTOMRIGHT", SpellBookNextPageButton, "BOTTOMLEFT", -1, 0)

			-- SpellBookSpellIconsFrame
			for i = 1, SPELLS_PER_PAGE do
				local button = _G["SpellButton"..i]

				-- SpellButtonTemplate
				core.util.set_outside(button.EmptySlot, button)
				button.EmptySlot:SetColorTexture(unpack(core.config.color.border))

				button.TextBackground:Hide()
				button.TextBackground2:Hide()

				button.IconTextureBg:SetColorTexture(unpack(core.config.color.background))

				core.util.crop_icon(button.IconTexture)
				
				core.util.fix_string(button.SpellName, core.config.font_size_sml)
				core.util.fix_string(button.SpellSubName, core.config.font_size_sml)
				core.util.fix_string(button.RequiredLevelString, core.config.font_size_sml)
				core.util.fix_string(button.SeeTrainerString, core.config.font_size_sml)

				_G["SpellButton"..i.."SlotFrame"]:SetTexture()
				button.UnlearnedFrame:SetTexture()

				local r, g, b = unpack(core.config.color.highlight)
				button.SpellHighlightTexture:SetColorTexture(r, g, b, 1)
				button.SpellHighlightTexture:SetDrawLayer("BORDER", 1)
				button.SpellHighlightTexture:SetAllPoints(button.EmptySlot)
				
				button:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
				
				hooksecurefunc(button, "UpdateButton", function(self)
					button.SpellSubName:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
					button.IconTextureBg:Show()
					button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
					button:GetCheckedTexture():SetColorTexture(unpack(core.config.color.selected))
				end)
			end

			-- SpellBookSideTabsFrame
			for t = 1, MAX_SKILLLINE_TABS do
				-- SpellBookSkillLineTabTemplate

				local tab = _G["SpellBookSkillLineTab"..t]
				local regions = {tab:GetRegions()}
				for _, region in ipairs(regions) do
					if region:GetDrawLayer() == "BACKGROUND" then
						core.util.set_outside(region, tab)
						region:SetColorTexture(unpack(core.config.color.border))
					end
				end
				core.util.crop_icon(tab:GetNormalTexture())
				tab:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				tab:GetCheckedTexture():SetColorTexture(unpack(core.config.color.selected))
			end

			-- SpellBookProfessionFrame
			for p = 1, 2 do
				-- PrimaryProfessionTemplate

				local prof = _G["PrimaryProfession"..p]
				core.util.fix_string(prof.professionName, core.config.font_size_lrg)
				core.util.fix_string(prof.specialization, core.config.font_size_sml)
				core.util.fix_string(prof.missingHeader, core.config.font_size_med)
				core.util.fix_string(prof.missingText, core.config.font_size_sml)
				-- prof.missingHeader:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
				core.util.fix_string(prof.rank, core.config.font_size_sml)

				local border = _G["PrimaryProfession"..p.."IconBorder"]
				border:SetColorTexture(unpack(core.config.color.border))
				border:SetDrawLayer("BACKGROUND")
				core.util.circle_mask(prof, border, 3)
				core.util.circle_mask(prof, prof.icon, 3)
				prof.icon:SetAlpha(1)

				for b = 1, 2 do
					-- ProfessionButtonTemplate

					local button = prof["SpellButton"..b]
					-- button.subSpellString:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)

					core.util.crop_icon(button.IconTexture)
					_G[button:GetName().."NameFrame"]:SetColorTexture(unpack(core.config.color.border))
					core.util.set_outside(_G[button:GetName().."NameFrame"], button)
					
					button:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
					button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
					button:GetCheckedTexture():SetColorTexture(unpack(core.config.color.selected))
				end
				prof.SpellButton2:SetPoint("TOPRIGHT", -109, 0)
				prof.SpellButton1:SetPoint("TOPLEFT", prof.SpellButton2, "BOTTOMLEFT", 0, -3)
				
				prof.statusBar:SetPoint("TOPLEFT", prof.rank, "BOTTOMLEFT", 0, -5)
				prof.statusBar.rankText:SetPoint("CENTER")
				core.util.strip_textures(prof.statusBar, true)
				prof.statusBar:SetStatusBarTexture(core.media.textures.blank)
				prof.statusBar:SetStatusBarColor(0.25, 0.75, 0.25)
				prof.statusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
				core.util.gen_backdrop(prof.statusBar)
				
				prof.UnlearnButton:ClearAllPoints()
				prof.UnlearnButton:SetPoint("RIGHT", prof.statusBar, "LEFT", -2, 0)
			end

			for p = 1, 3 do
				-- SecondaryProfessionTemplate

				local prof = _G["SecondaryProfession"..p]

				for b = 1, 2 do
					-- ProfessionButtonTemplate
					
					local button = prof["SpellButton"..b]
					-- button.subSpellString:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)

					core.util.crop_icon(button.IconTexture)
					_G[button:GetName().."NameFrame"]:SetColorTexture(unpack(core.config.color.border))
					core.util.set_outside(_G[button:GetName().."NameFrame"], button)
					
					button:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
					button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
					button:GetCheckedTexture():SetColorTexture(unpack(core.config.color.selected))
				end
				
				prof.statusBar:SetPoint("BOTTOMLEFT", -14, 0)
				prof.statusBar.rankText:SetPoint("CENTER")
				core.util.strip_textures(prof.statusBar, true)

				prof.rank:SetPoint("BOTTOMLEFT", prof.statusBar, "TOPLEFT", 0, 4)
				prof.statusBar:SetStatusBarTexture(core.media.textures.blank)
				prof.statusBar:SetStatusBarColor(0.25, 0.75, 0.25)
				prof.statusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
				core.util.gen_backdrop(prof.statusBar)

				prof.missingHeader:SetTextColor(WHITE_FONT_COLOR.r / 2, WHITE_FONT_COLOR.g / 2, WHITE_FONT_COLOR.b / 2)
				core.util.fix_string(prof.missingText, core.config.font_size_sml)
				prof.missingText:SetTextColor(WHITE_FONT_COLOR.r / 2, WHITE_FONT_COLOR.g / 2, WHITE_FONT_COLOR.b / 2)
			end
		
		elseif name == "ClassTalentFrame" then

			ClassTalentFrame.TabSystem:SetPoint("TOPLEFT", ClassTalentFrame, "BOTTOMLEFT", 0, 1)
			hooksecurefunc(ClassTalentFrame.TabSystem, "LayoutChildren", function(self, children)
				local prev
				for i, child in ipairs(children) do
					--lib.skin_tab(child)
					child:ClearAllPoints()
					if prev then
						child:SetPoint("TOPLEFT", prev, "TOPRIGHT", -1, 0)
					else
						child:SetPoint("TOPLEFT", self, "TOPLEFT")
					end
					prev = child
				end
			end)

			-- ClassTalentFrame.TalentsTab
			-- ClassTalentTalentsTabTemplate

			ClassTalentFrame.TalentsTab.BlackBG:Hide()
			ClassTalentFrame.TalentsTab.BottomBar:Hide()
			
			hooksecurefunc(ClassTalentFrame.TalentsTab, "SetBackgroundAnimationsPlaying", function(self)
				for _, group in ipairs(self.backgroundAnims) do
					group:Stop()
				end
			end)

			lib.skin_dropdown(ClassTalentFrame.TalentsTab.LoadoutDropDown.DropDownControl.DropDownMenu)
			core.util.fix_editbox(ClassTalentFrame.TalentsTab.SearchBox)
			lib.skin_button(ClassTalentFrame.TalentsTab.ApplyButton)
			lib.skin_button(ClassTalentFrame.TalentsTab.InspectCopyButton)

			core.util.strip_textures(ClassTalentFrame.TalentsTab.WarmodeButton, true, {
				ClassTalentFrame.TalentsTab.WarmodeButton.Swords,
			})

			ClassTalentFrame.TalentsTab.WarmodeButton.Swords:ClearAllPoints()
			ClassTalentFrame.TalentsTab.WarmodeButton.Swords:SetPoint("CENTER")
			ClassTalentFrame.TalentsTab.WarmodeButton.Swords:SetSize(ClassTalentFrame.TalentsTab.WarmodeButton.Swords:GetWidth() * 1.5, ClassTalentFrame.TalentsTab.WarmodeButton.Swords:GetHeight() * 1.5)
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive:ClearAllPoints()
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive:SetPoint("BOTTOM", ClassTalentFrame.TalentsTab.WarmodeButton.Swords)

			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.CircleMask:Hide()
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.IconRing:SetDrawLayer("ARTWORK", -1)
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.IconRing:SetTexture(core.media.textures.blank)
			ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.IconRing:SetVertexColor(unpack(core.config.color.border))
			core.util.set_outside(ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive.IconRing, ClassTalentFrame.TalentsTab.WarmodeButton.WarmodeIncentive)

			ClassTalentFrame.SpecTab.BlackBG:Hide()
			ClassTalentFrame.SpecTab.Background:Hide()

			hooksecurefunc(ClassTalentFrame.SpecTab, "UpdateSpecContents", function(self)
				for frame in self.SpecContentFramePool:EnumerateActive() do
					if not frame.skinned then
						frame.skinned = true
						frame.ColumnDivider:SetTexture()
						--frame.SelectedBackgroundBack1:SetTexture()
						frame.SelectedBackgroundBack2:SetTexture()
						frame.SelectedBackgroundLeft1:SetTexture()
						frame.SelectedBackgroundLeft2:SetTexture()
						frame.SelectedBackgroundLeft3:SetTexture()
						frame.SelectedBackgroundLeft4:SetTexture()
						frame.SelectedBackgroundRight1:SetTexture()
						frame.SelectedBackgroundRight2:SetTexture()
						frame.SelectedBackgroundRight3:SetTexture()
						frame.SelectedBackgroundRight4:SetTexture()

						lib.skin_button(frame.ActivateButton)
					end
				end
			end)
		
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

			panel.PortraitContainer.bg:SetParent(panel)
			core.util.set_outside(panel.PortraitContainer.bg, FriendsFrameIcon)
			core.util.circle_mask(panel, FriendsFrameIcon, 3)

			FriendsFrameIcon:ClearAllPoints()
			FriendsFrameIcon:SetPoint("CENTER", panel, "TOPLEFT", 20, -20)

			FriendsFrameStatusDropDown:SetPoint("TOPLEFT", 50, -27)
			lib.skin_dropdown(FriendsFrameStatusDropDown)
			FriendsFrameStatusDropDownStatus:ClearAllPoints()
			FriendsFrameStatusDropDownStatus:SetPoint("LEFT", 5, 0)
			FriendsFrameStatusDropDownMouseOver:SetAllPoints(FriendsFrameStatusDropDownStatus)
			FriendsFrameStatusDropDown:SetWidth(45)

			hooksecurefunc(FriendsFrameBattlenetFrame.BroadcastFrame, "ShowFrame", function()
				FriendsFrameBattlenetFrame.BroadcastButton:GetNormalTexture():SetTexture()
				FriendsFrameBattlenetFrame.BroadcastButton:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
			end)

			hooksecurefunc(FriendsFrameBattlenetFrame.BroadcastFrame, "HideFrame", function()
				FriendsFrameBattlenetFrame.BroadcastButton:GetNormalTexture():SetTexture()
				FriendsFrameBattlenetFrame.BroadcastButton:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
			end)

			hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
				if not button.bg then
					button.bg = button:CreateTexture()
					button.bg:SetColorTexture(unpack(core.config.color.border))
					button.bg:SetDrawLayer("BACKGROUND")
					core.util.set_outside(button.bg, button.gameIcon)
					
					button.gameIcon:ClearAllPoints()
					button.gameIcon:SetPoint("RIGHT", -25, 0)
					button.gameIcon:SetSize(24, 24)

					button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))

					button.travelPassButton:SetPoint("TOPRIGHT", -2, -2)
					button.travelPassButton:SetSize(20, 30)

					core.util.fix_string(button.name, core.config.font_size_med)
					core.util.fix_string(button.info, core.config.font_size_sml)
				end

				if button.gameIcon:IsShown() then
					button.bg:Show()
				else
					button.bg:Hide()
				end

				button.gameIcon:SetTexCoord(0.18, 0.82, 0.18, 0.82)
			end)

			FriendsFrameBattlenetFrame.BroadcastButton:ClearAllPoints()
			FriendsFrameBattlenetFrame.BroadcastButton:SetPoint("TOPLEFT", FriendsFrameBattlenetFrame, "TOPRIGHT", 2, 0)
			FriendsFrameBattlenetFrame.BroadcastButton:SetSize(24, 22)
			lib.skin_icon_button(FriendsFrameBattlenetFrame.BroadcastButton, nil, nil, 0.25, 0.7, 0.275, 0.7)

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
			core.util.fix_scrollbar(FriendsListFrame.ScrollBar)

			lib.skin_button(FriendsFrameIgnorePlayerButton)
			lib.skin_button(FriendsFrameUnsquelchButton)
			core.util.fix_scrollbar(IgnoreListFrame.ScrollBar)

			lib.skin_button(WhoFrameGroupInviteButton)
			lib.skin_button(WhoFrameAddFriendButton)
			lib.skin_button(WhoFrameWhoButton)
			core.util.fix_scrollbar(WhoFrame.ScrollBar)
			
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

			-- QuickJoinFrame
			lib.skin_button(QuickJoinFrame.JoinQueueButton, core.config.font_size_sml)
			core.util.fix_scrollbar(QuickJoinFrame.ScrollBar)

			-- RecruitAFriendFrame
			lib.skin_button(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)

			core.util.strip_textures(RecruitAFriendFrame.RecruitList.Header, true)
			core.util.fix_scrollbar(RecruitAFriendFrame.RecruitList.ScrollBar)
			lib.skin_button(RecruitAFriendFrame.RecruitmentButton)

		elseif name == "PVEFrame" then

			core.util.strip_textures(panel, true, {
				panel.PortraitContainer.portrait,
				panel.PortraitContainer.portrait.bg
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

			-- -- LFDParentFrame
			core.util.strip_textures(LFDParentFrame)

			-- LFDQueueFrame
			LFDQueueFrameTypeDropDownName:SetPoint("RIGHT", LFDQueueFrameTypeDropDown, "LEFT", -5, 0)

			LFDQueueFrameTypeDropDown:ClearAllPoints()
			LFDQueueFrameTypeDropDown:SetPoint("BOTTOMRIGHT", GroupFinderFrame, "BOTTOMRIGHT", -5, 285)
			lib.skin_dropdown(LFDQueueFrameTypeDropDown)

			LFDQueueFrameTypeDropDown:HookScript("OnShow", function(self)
				self:SetSize(250, 24)
			end)

			core.util.strip_textures(LFDQueueFrameRandomScrollFrame)
			core.util.fix_scrollbar(LFDQueueFrameRandomScrollFrame.ScrollBar)

			--core.util.strip_textures(LFDQueueFrameSpecific.ScrollBox)
			core.util.fix_scrollbar(LFDQueueFrameSpecific.ScrollBar)

			lib.skin_button(LFDQueueFrameFindGroupButton)

			-- RaidFinderFrame
			core.util.strip_textures(RaidFinderFrame)

			lib.skin_button(RaidFinderFrameFindRaidButton)
			
			-- RaidFinderQueueFrame
			RaidFinderQueueFrameSelectionDropDownName:SetPoint("RIGHT", RaidFinderQueueFrameSelectionDropDown, "LEFT", -5, 0)

			RaidFinderQueueFrameSelectionDropDown:ClearAllPoints()
			RaidFinderQueueFrameSelectionDropDown:SetPoint("BOTTOMRIGHT", GroupFinderFrame, "BOTTOMRIGHT", -5, 285)
			lib.skin_dropdown(RaidFinderQueueFrameSelectionDropDown)

			RaidFinderQueueFrameSelectionDropDown:HookScript("OnShow", function(self)
				self:SetSize(250, 24)
			end)

			-- LFGListFrame
			lib.skin_button(LFGListFrame.CategorySelection.FindGroupButton)
			lib.skin_button(LFGListFrame.CategorySelection.StartGroupButton)

			core.util.fix_editbox(LFGListFrame.SearchPanel.SearchBox, 320, 22, 50)
			LFGListFrame.SearchPanel.SearchBox:SetPoint("TOPLEFT", LFGListFrame.SearchPanel.CategoryName, "BOTTOMLEFT", 0, -8)
			
			core.util.fix_scrollbar(LFGListFrame.SearchPanel.ScrollBar)
			LFGListFrame.SearchPanel.ScrollBar:SetPoint("BOTTOMLEFT", LFGListFrame.SearchPanel.ScrollBox, "BOTTOMRIGHT", 4, 15)

			lib.skin_button(LFGListFrame.SearchPanel.BackButton)
			lib.skin_button(LFGListFrame.SearchPanel.BackToGroupButton)
			lib.skin_button(LFGListFrame.SearchPanel.SignUpButton)

			lib.skin_icon_button(LFGListFrame.SearchPanel.RefreshButton, nil, nil, -0.02, 1.03, -0.06, 0.98)
			LFGListFrame.SearchPanel.RefreshButton:SetSize(24, 24)

			LFGListFrame.SearchPanel.ScrollBox:ForEachFrame(function(button)
				core.util.set_inside(button.ResultBG, button)

				button.ApplicationBG:SetColorTexture(0.12, 0.5, 0.12, 0.5)
				core.util.set_inside(button.ApplicationBG, button)

				core.util.set_inside(button.Selected, button)
				button.Selected:SetColorTexture(unpack(core.config.color.selected))

				core.util.set_inside(button.Highlight, button)
				button.Highlight:SetColorTexture(unpack(core.config.color.highlight))

				button.DataDisplay.Enumerate.roles = {}
				for i, icon in ipairs(button.DataDisplay.Enumerate.Icons) do
					button.DataDisplay.Enumerate.roles[i] = core.util.gen_string(button.DataDisplay.Enumerate, nil, nil, core.media.fonts.role_symbols)
					button.DataDisplay.Enumerate.roles[i]:SetAllPoints(icon)
				end

				lib.skin_stretchbutton(button.CancelButton, 1, {button.CancelButton.Icon})
			end)

			LFGListFrame.ApplicationViewer.DataDisplay.Enumerate.roles = {}
			for i, icon in ipairs(LFGListFrame.ApplicationViewer.DataDisplay.Enumerate.Icons) do
				LFGListFrame.ApplicationViewer.DataDisplay.Enumerate.roles[i] = core.util.gen_string(LFGListFrame.ApplicationViewer.DataDisplay.Enumerate, nil, nil, core.media.fonts.role_symbols)
				LFGListFrame.ApplicationViewer.DataDisplay.Enumerate.roles[i]:SetAllPoints(icon)
			end

			hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", function(self)
				if self.roles then
					for i, icon in ipairs(self.Icons) do
						self.roles[i]:SetText(role_texts[self.Icons[i]:GetAtlas()])
						icon:Hide()
					end
				end
			end)

			hooksecurefunc("LFGListApplicationViewer_UpdateRoleIcons", function(self)
				if not self.roles then
					self.roles = {}
					for i = 1, 3 do
						self.roles[i] = core.util.gen_string(self, nil, nil, core.media.fonts.role_symbols)
						self.roles[i]:SetAllPoints(self["RoleIcon"..i])
					end
				end

				for i = 1, 3 do
					local icon = self["RoleIcon"..i]
					self.roles[i]:SetText(role_texts[LFG_LIST_GROUP_DATA_ATLASES[icon.role]])
					icon:Hide()
				end		
			end)
			
			LFGListFrame.ApplicationViewer.InfoBackground:SetTexCoord(0.02, 0.98, 0.02, 0.96)

			lib.skin_button(LFGListFrame.ApplicationViewer.NameColumnHeader, core.config.font_size_sml)
			lib.skin_button(LFGListFrame.ApplicationViewer.RoleColumnHeader, core.config.font_size_sml)
			lib.skin_button(LFGListFrame.ApplicationViewer.ItemLevelColumnHeader, core.config.font_size_sml)
			lib.skin_button(LFGListFrame.ApplicationViewer.RatingColumnHeader, core.config.font_size_sml)
			lib.skin_icon_button(LFGListFrame.ApplicationViewer.RefreshButton, nil, nil, -0.02, 1.03, -0.06, 0.98)
			LFGListFrame.ApplicationViewer.RefreshButton:SetSize(24, 24)
			LFGListFrame.ApplicationViewer.RefreshButton:ClearAllPoints()
			LFGListFrame.ApplicationViewer.RefreshButton:SetPoint("LEFT", LFGListFrame.ApplicationViewer.RatingColumnHeader, "RIGHT", 5, 0)
			core.util.fix_scrollbar(LFGListFrame.ApplicationViewer.ScrollBar)

			skin_panel(LFGListApplicationDialog)
			lib.skin_button(LFGListApplicationDialog.SignUpButton)
			lib.skin_button(LFGListApplicationDialog.CancelButton)
			
			LFGListApplicationDialog.Description:SetSize(240, 46)
			LFGListApplicationDialog.Description:SetPoint("BOTTOM", 0, 44)
			lib.skin_input_scroller(LFGListApplicationDialog.Description)
		
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
			core.util.fix_scrollbar(QuestDetailScrollFrame.ScrollBar)

			-- QuestFrameRewardPanel
			lib.skin_button(QuestFrameCompleteQuestButton)
			QuestFrameCompleteQuestButton:SetWidth(150)
			
			core.util.strip_textures(QuestRewardScrollFrame)
			core.util.fix_scrollbar(QuestRewardScrollFrame.ScrollBar)

			local skin_rewardbutton = function(button)
				if not button.skinned then
					button.NameFrame:Hide()
					core.util.crop_icon(button.Icon)
					if button.IconBorder then
						core.util.set_outside(button.IconBorder, button.Icon)
					end
					button.skinned = true
				end
			end

			for _, button in ipairs(QuestInfoRewardsFrame.RewardButtons) do
				skin_rewardbutton(button)
			end
			for button in QuestInfoRewardsFrame.spellRewardPool:EnumerateActive() do
				skin_rewardbutton(button)
			end
			for button in QuestInfoRewardsFrame.followerRewardPool:EnumerateActive() do
				skin_rewardbutton(button)
			end
			for button in QuestInfoRewardsFrame.reputationRewardPool:EnumerateActive() do
				skin_rewardbutton(button)
			end

			QuestInfoRewardsFrame:HookScript("OnShow", function()
				for _, button in ipairs(QuestInfoRewardsFrame.RewardButtons) do
					skin_rewardbutton(button)
				end
				for button in QuestInfoRewardsFrame.spellRewardPool:EnumerateActive() do
					skin_rewardbutton(button)
				end
				for button in QuestInfoRewardsFrame.followerRewardPool:EnumerateActive() do
					skin_rewardbutton(button)
				end
				for button in QuestInfoRewardsFrame.reputationRewardPool:EnumerateActive() do
					skin_rewardbutton(button)
				end
			end)

			-- QuestFrameProgressPanel
			lib.skin_button(QuestFrameCompleteButton)
			lib.skin_button(QuestFrameGoodbyeButton)

			for i = 1, MAX_REQUIRED_ITEMS do
				skin_rewardbutton(_G["QuestProgressItem"..i])
			end
			
			core.util.strip_textures(QuestProgressScrollFrame)
			core.util.fix_scrollbar(QuestProgressScrollFrame.ScrollBar)

		elseif name == "GossipFrame" then
			-- GreetingPanel
			lib.skin_button(GossipFrame.GreetingPanel.GoodbyeButton)
			GossipFrame.GreetingPanel.GoodbyeButton:SetWidth(90)
			--core.util.strip_textures(GossipGreetingScrollFrame)
			core.util.fix_scrollbar(GossipFrame.GreetingPanel.ScrollBar)

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

				lib.skin_itembutton(item.ItemButton)

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
			
			core.util.strip_textures(MerchantNextPageButton)
			MerchantNextPageButton:SetHighlightTexture(core.media.textures.blank)
			lib.skin_icon_button(MerchantNextPageButton, nil, ">")

			core.util.strip_textures(MerchantPrevPageButton)
			MerchantPrevPageButton:SetHighlightTexture(core.media.textures.blank)
			lib.skin_icon_button(MerchantPrevPageButton, nil, "<")

			local slot = _G["MerchantBuyBackItemSlotTexture"]
			core.util.set_outside(slot, MerchantBuyBackItem.ItemButton)
			slot:SetColorTexture(unpack(core.config.color.border))
			slot:SetParent(MerchantBuyBackItem.ItemButton)

			lib.skin_itembutton(MerchantBuyBackItem.ItemButton)

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

			-- InboxFrame
			for i = 1, 7 do
				local frame = _G["MailItem"..i]
				core.util.strip_textures(frame, true)

				-- Button
				local button = frame.Button

				local bg = _G[button:GetName().."Slot"]
				core.util.set_outside(bg, button)
				bg:SetDrawLayer("BACKGROUND", -8)
				bg:SetColorTexture(unpack(core.config.color.border))

				core.util.set_outside(button.IconBorder, button)
				button.IconBorder:SetDrawLayer("BORDER")
				button.IconBorder:SetTexture(core.media.textures.blank)
				
				button.Icon:SetAllPoints()
				button.Icon:SetDrawLayer("ARTWORK")
				core.util.crop_icon(button.Icon)

				core.util.set_outside(button.IconOverlay, button)
				--button.IconOverlay:SetTexture(core.media.textures.blank)

				core.util.set_outside(button.IconOverlay2, button)
				--button.IconOverlay2:SetTexture(core.media.textures.blank)
				
				_G[button:GetName().."Count"]:SetPoint("BOTTOMRIGHT", -2, 2)
				
				local highlight = button:GetHighlightTexture()
				highlight:SetColorTexture(unpack(core.config.color.highlight))

				local checked = button:GetCheckedTexture()
				checked:SetColorTexture(unpack(core.config.color.selected))
			end

			lib.skin_button(OpenAllMail)
			InboxPrevPageButton:SetSize(25, 25)
			InboxNextPageButton:SetSize(25, 25)
			lib.skin_icon_button(InboxNextPageButton, nil, ">")
			lib.skin_icon_button(InboxPrevPageButton, nil, "<")

			MailFrameTab1:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, 1)
			MailFrameTab2:SetPoint("TOPLEFT", MailFrameTab1, "TOPRIGHT", -1, 0)

			-- SendMailFrame
			core.util.strip_textures(SendMailFrame, true)
			core.util.fix_scrollbar(SendMailScrollFrame.ScrollBar)
			core.util.strip_textures(SendMailScrollFrame, true, {SendStationeryBackgroundLeft, SendStationeryBackgroundRight})
			core.util.fix_editbox(SendMailNameEditBox)
			SendMailNameEditBox:SetTextInsets(0, 0, 0, 0)
			for _, region in ipairs({SendMailNameEditBox:GetRegions()}) do
				if region:GetObjectType() == "FontString" then
					region:ClearAllPoints()
					region:SetPoint("RIGHT", SendMailNameEditBox, "LEFT", -5, 0)
				end
			end
			core.util.fix_editbox(SendMailSubjectEditBox)
			SendMailSubjectEditBox:SetTextInsets(0, 0, 0, 0)
			for _, region in ipairs({SendMailSubjectEditBox:GetRegions()}) do
				if region:GetObjectType() == "FontString" then
					region:ClearAllPoints()
					region:SetPoint("RIGHT", SendMailSubjectEditBox, "LEFT", -5, 0)
				end
			end

			for i = 1, ATTACHMENTS_MAX do
				local button = SendMailFrame.SendMailAttachments[i]
				button.bg = button:GetRegions()
				button.bg:SetColorTexture(unpack(core.config.color.background))
				button.bg:SetAllPoints()
				button.Count:SetPoint("BOTTOMRIGHT", -2, 2)

				core.util.set_outside(button.IconBorder, button)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
			end

			hooksecurefunc("SendMailFrame_Update", function()
				for i = 1, ATTACHMENTS_MAX_SEND do
					local button = SendMailFrame.SendMailAttachments[i]
					if HasSendMailItem(i) then
						core.util.crop_icon(button:GetNormalTexture())
					end
				end
			end)
			
			core.util.fix_editbox(SendMailMoney.gold)
			core.util.fix_editbox(SendMailMoney.silver)
			SendMailMoney.silver.texture:SetPoint("RIGHT", -4, 0)
			core.util.fix_editbox(SendMailMoney.copper)
			SendMailMoney.copper.texture:SetPoint("RIGHT", -4, 0)

			SendMailMoneyBg:Hide()
			SendMailSendMoneyButton:SetPoint("TOPLEFT", SendMailMoney, "TOPRIGHT", 3, 12)
			lib.skin_checkbox(SendMailSendMoneyButton)
			SendMailCODButton:SetPoint("TOPLEFT", SendMailSendMoneyButton, "BOTTOMLEFT", 0, -3)
			lib.skin_checkbox(SendMailCODButton)
			
			lib.skin_button(SendMailCancelButton)
			lib.skin_button(SendMailMailButton)

			-- OpenMailFrame
			core.util.strip_textures(OpenMailFrame, true, {OpenMailFrameIcon})
			skin_panel(OpenMailFrame)

			OpenMailFrame.PortraitContainer.bg:SetParent(OpenMailFrame)
			core.util.set_outside(OpenMailFrame.PortraitContainer.bg, OpenMailFrameIcon)
			core.util.circle_mask(OpenMailFrame, OpenMailFrameIcon, 3)

			OpenMailFrameIcon:ClearAllPoints()
			OpenMailFrameIcon:SetPoint("CENTER", OpenMailFrame, "TOPLEFT", 20, -20)
			
			core.util.fix_scrollbar(OpenMailScrollFrame.ScrollBar)
			core.util.strip_textures(OpenMailScrollFrame, true, {OpenStationeryBackgroundLeft, OpenStationeryBackgroundRight})
			lib.skin_button(OpenMailReportSpamButton, core.config.font_size_sml)
			lib.skin_button(OpenMailCancelButton)
			lib.skin_button(OpenMailDeleteButton)
			lib.skin_button(OpenMailReplyButton)

			lib.skin_itembutton(OpenMailLetterButton)
			lib.skin_itembutton(OpenMailMoneyButton)

			for i = 1, ATTACHMENTS_MAX do
				local button = OpenMailFrame.OpenMailAttachments[i]
				lib.skin_itembutton(button)
				-- button.Count:SetPoint("BOTTOMRIGHT", -2, 2)

				-- core.util.set_outside(button.IconBorder, button)
				-- button.IconBorder:SetDrawLayer("BACKGROUND", 0)
				-- button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				-- button:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
			end

			hooksecurefunc("OpenMailFrame_UpdateButtonPositions", function()
				for i = 1, ATTACHMENTS_MAX_RECEIVE do
					local button = OpenMailFrame.OpenMailAttachments[i]
					if HasInboxItem(InboxFrame.openMailID, i) then
						core.util.crop_icon(button.icon)
						button:ClearNormalTexture()
					end
				end
			end)

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
			lib.skin_icon_button(AuctionHouseFrame.SearchBar.FavoritesSearchButton, nil, "F")

			lib.skin_stretchbutton(AuctionHouseFrame.SearchBar.FilterButton, nil, {AuctionHouseFrame.SearchBar.FilterButton.Icon})
			core.util.fix_editbox(AuctionHouseFrame.SearchBar.SearchBox)

			hooksecurefunc(AuctionHouseTableHeaderStringMixin, "Init", function(self)
				-- AuctionHouseTableHeaderStringTemplate
				lib.skin_button(self, core.config.font_size_sml)
				self.Arrow:ClearAllPoints()
				self.Arrow:SetPoint("RIGHT", self.Text, -5, 0)
			end)

			hooksecurefunc(AuctionHouseTableCellItemDisplayMixin, "Init", function(self)
				-- AuctionHouseTableCellItemDisplayTemplate
				self.Icon:SetSize(40, 20)
				self.Icon:SetTexCoord(0.1, 0.9, 0.3, 0.7)
				self.IconBorder:SetDrawLayer("BACKGROUND", 0)
				self.IconBorder:SetColorTexture(unpack(core.config.color.border))
				core.util.set_outside(self.IconBorder, self.Icon)
			end)

			hooksecurefunc(AuctionHouseTableCellMinPriceMixin, "Init", function(self)
				hooksecurefunc(self.MoneyDisplay, "UpdateAnchoring", function(self)
					if self.GoldDisplay.amount ~= nil and self.GoldDisplay.amount > 0 then
						self.SilverDisplay:Hide()
						self.GoldDisplay:SetPoint("RIGHT", self.CopperDisplay, "RIGHT")
					end
				end)
			end)

			local skin_item_list = function(list)
				list.ResultsText:SetShadowOffset(0, 0)
				core.util.fix_scrollbar(list.ScrollBar)
				core.util.fix_string(list.RefreshFrame.TotalQuantity, core.config.font_size_sml)
				lib.skin_icon_button(list.RefreshFrame.RefreshButton, nil, "R")
			end

			-- AuctionHouseFrame.CategoriesList
			core.util.fix_scrollbar(AuctionHouseFrame.CategoriesList.ScrollBar)
			hooksecurefunc("AuctionHouseFilterButton_SetUp", function(button, info)
				-- AuctionCategoryButtonTemplate
				button.NormalTexture:SetTexture()
				button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
				button.SelectedTexture:SetColorTexture(unpack(core.config.color.selected))
				core.util.fix_string(button.Text, core.config.font_size_sml)
			end)

			-- AuctionHouseFrame.BrowseResultsFrame
			skin_item_list(AuctionHouseFrame.BrowseResultsFrame.ItemList)
			hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, "RefreshScrollFrame", function(self)
				self.ScrollBox:ForEachFrame(function(button)
					-- AuctionHouseFavoritableLineTemplate
					button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
				end)
			end)

			-- AuctionHouseFrame.WoWTokenResults
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.PortraitContainer.bg:Hide()
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.LeftDisplay.Label:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.RightDisplay.Label:SetTextColor(WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b)
			AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			lib.skin_button(AuctionHouseFrame.WoWTokenResults.GameTimeTutorial.RightDisplay.StoreButton)

			core.util.gen_backdrop(AuctionHouseFrame.WoWTokenResults.GameTimeTutorial, unpack(core.config.frame_background_transparent))
			core.util.strip_textures(AuctionHouseFrame.WoWTokenResults.TokenDisplay, true)
			lib.skin_button(AuctionHouseFrame.WoWTokenResults.Buyout)
			core.util.fix_scrollbar(AuctionHouseFrame.WoWTokenResults.DummyScrollBar)

			-- AuctionHouseFrame.CommoditiesBuyFrame
			lib.skin_button(AuctionHouseFrame.CommoditiesBuyFrame.BackButton)
			core.util.strip_textures(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay, true)
			AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay.Name:SetShadowOffset(0, 0)
			core.util.fix_editbox(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.QuantityInput.InputBox)
			lib.skin_button(AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.BuyButton)

			skin_item_list(AuctionHouseFrame.CommoditiesBuyFrame.ItemList)
			hooksecurefunc(AuctionHouseFrame.CommoditiesBuyFrame.ItemList, "RefreshScrollFrame", function(self)
				self.ScrollBox:ForEachFrame(function(button)
					button.NormalTexture:Hide()
					button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
					button.SelectedHighlight:SetColorTexture(unpack(core.config.color.selected))
				end)
			end)
			
			-- AuctionHouseFrame.ItemBuyFrame
			lib.skin_button(AuctionHouseFrame.ItemBuyFrame.BackButton)
			AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Name:SetShadowOffset(0, 0)
			lib.skin_button(AuctionHouseFrame.ItemBuyFrame.BuyoutFrame.BuyoutButton)
			core.util.fix_editbox(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount.gold)
			core.util.fix_editbox(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount.silver)
			AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount.silver.texture:SetPoint("RIGHT", -4, 0)
			core.util.fix_editbox(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount.copper)
			AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount.copper.texture:SetPoint("RIGHT", -4, 0)

			AuctionHouseFrame.ItemBuyFrame.BidFrame.BidButton:SetPoint("LEFT", AuctionHouseFrame.ItemBuyFrame.BidFrame.BidAmount, "RIGHT", 10, 0)
			lib.skin_button(AuctionHouseFrame.ItemBuyFrame.BidFrame.BidButton)

			skin_item_list(AuctionHouseFrame.ItemBuyFrame.ItemList)
			hooksecurefunc(AuctionHouseFrame.ItemBuyFrame.ItemList, "RefreshScrollFrame", function(self)
				self.ScrollBox:ForEachFrame(function(button)
					button.NormalTexture:Hide()
					button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
					button.SelectedHighlight:SetColorTexture(unpack(core.config.color.selected))
				end)
			end)

			local remove_shadow = function(frame)
				frame.Label:SetShadowOffset(0, 0)
				frame.LabelTitle:SetShadowOffset(0, 0)
				frame.Subtext:SetShadowOffset(0, 0)
			end

			local skin_sell_frame = function(frame)
				-- AuctionHouseSellFrameTemplate
				core.util.strip_textures(frame, true)
				core.util.fix_string(frame.CreateAuctionLabel, core.config.font_size_med)
	
				core.util.strip_textures(frame.ItemDisplay, true)
				frame.ItemDisplay.ItemButton.EmptyBackground:SetColorTexture(unpack(core.config.color.background))
				frame.ItemDisplay.ItemButton.Icon:SetAllPoints()
				core.util.crop_icon(frame.ItemDisplay.ItemButton.Icon)
				core.util.set_outside(frame.ItemDisplay.ItemButton.IconBorder, frame.ItemDisplay.ItemButton)
				frame.ItemDisplay.ItemButton.IconBorder:SetColorTexture(unpack(core.config.color.border))
				frame.ItemDisplay.ItemButton.IconBorder:SetDrawLayer("BACKGROUND", -1)
				frame.ItemDisplay.ItemButton.IconBorder:Show()
				frame.ItemDisplay.ItemButton:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
				frame.ItemDisplay.ItemButton.Highlight:SetColorTexture(unpack(core.config.color.highlight))

				remove_shadow(frame.QuantityInput)
				core.util.fix_editbox(frame.QuantityInput.InputBox)
				lib.skin_button(frame.QuantityInput.MaxButton)
	
				remove_shadow(frame.PriceInput)
				core.util.fix_editbox(frame.PriceInput.MoneyInputFrame.CopperBox)
				core.util.fix_editbox(frame.PriceInput.MoneyInputFrame.SilverBox)
				core.util.fix_editbox(frame.PriceInput.MoneyInputFrame.GoldBox)
				core.util.fix_string(frame.PriceInput.PerItemPostfix, core.config.font_size_sml)
				frame.PriceInput.PerItemPostfix:SetShadowOffset(0, 0)

				lib.skin_dropdown(frame.DurationDropDown.DropDown)
				remove_shadow(frame.DurationDropDown)
				remove_shadow(frame.Deposit)
				remove_shadow(frame.TotalPrice)
				lib.skin_button(frame.PostButton)
			end

			-- AuctionHouseFrame.ItemSellFrame
			remove_shadow(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput)
			remove_shadow(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput)
			core.util.fix_editbox(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.MoneyInputFrame.CopperBox)
			core.util.fix_editbox(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
			core.util.fix_editbox(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
			core.util.fix_string(AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.PerItemPostfix, core.config.font_size_sml)
			AuctionHouseFrame.ItemSellFrame.SecondaryPriceInput.PerItemPostfix:SetShadowOffset(0, 0)

			skin_sell_frame(AuctionHouseFrame.ItemSellFrame)
			skin_item_list(AuctionHouseFrame.ItemSellList)
			hooksecurefunc(AuctionHouseFrame.ItemSellList, "RefreshScrollFrame", function(self)
				self.ScrollBox:ForEachFrame(function(button)
					button.NormalTexture:Hide()
					button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
					button.SelectedHighlight:SetColorTexture(unpack(core.config.color.selected))
				end)
			end)

			-- AuctionHouseFrame.CommoditySellFrame
			skin_sell_frame(AuctionHouseFrame.CommoditiesSellFrame)
			skin_item_list(AuctionHouseFrame.CommoditiesSellList)
			hooksecurefunc(AuctionHouseFrame.CommoditiesSellList, "RefreshScrollFrame", function(self)
				if self.ScrollBox:GetView() then
					self.ScrollBox:ForEachFrame(function(button)
						button.NormalTexture:Hide()
						button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))
						button.SelectedHighlight:SetColorTexture(unpack(core.config.color.selected))
					end)
				end
			end)

			-- AuctionHouseFrame.AuctionsFrame
			lib.skin_button(AuctionHouseFrame.AuctionsFrame.CancelAuctionButton)
			core.util.fix_scrollbar(AuctionHouseFrame.AuctionsFrame.SummaryList.ScrollBar)
			
			skin_item_list(AuctionHouseFrame.AuctionsFrame.AllAuctionsList)
			skin_item_list(AuctionHouseFrame.AuctionsFrame.BidsList)
			skin_item_list(AuctionHouseFrame.AuctionsFrame.ItemList)
			skin_item_list(AuctionHouseFrame.AuctionsFrame.CommoditiesList)

			lib.skin_button(AuctionHouseFrame.AuctionsFrame.BuyoutFrame.BuyoutButton)
			core.util.fix_editbox(AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount.gold)
			core.util.fix_editbox(AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount.silver)
			AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount.silver.texture:SetPoint("RIGHT", -4, 0)
			core.util.fix_editbox(AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount.copper)
			AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount.copper.texture:SetPoint("RIGHT", -4, 0)

			AuctionHouseFrame.AuctionsFrame.BidFrame.BidButton:SetPoint("LEFT", AuctionHouseFrame.AuctionsFrame.BidFrame.BidAmount, "RIGHT", 10, 0)
			lib.skin_button(AuctionHouseFrame.AuctionsFrame.BidFrame.BidButton)

			core.util.gen_backdrop(AuctionHouseFrame.BuyDialog)
			lib.skin_button(AuctionHouseFrame.BuyDialog.BuyNowButton)
			lib.skin_button(AuctionHouseFrame.BuyDialog.CancelButton)
			lib.skin_button(AuctionHouseFrame.BuyDialog.OkayButton)


		elseif name == "CommunitiesFrame" then

			CommunitiesFrame.PortraitContainer.bg:SetParent(CommunitiesFrame.PortraitOverlay)
			CommunitiesFrame.PortraitContainer.bg:SetDrawLayer("BACKGROUND", 0)
			CommunitiesFrame.PortraitOverlay.Portrait.mask = panel.PortraitOverlay.CircleMask
			core.util.circle_mask(panel.PortraitOverlay, panel.PortraitOverlay.Portrait, 3)
			core.util.set_outside(CommunitiesFrame.PortraitContainer.bg, CommunitiesFrame.PortraitOverlay.Portrait)

			hooksecurefunc(CommunitiesFrame.MaximizeMinimizeFrame, "Minimize", function(frame)
				local communitiesFrame = frame:GetParent()
				communitiesFrame.StreamDropDownMenu:SetPoint("LEFT", communitiesFrame.CommunitiesListDropDownMenu, "RIGHT", 5, 0);
			end)

			hooksecurefunc(CommunitiesFrame.MaximizeMinimizeFrame, "Maximize", function(frame)
				local communitiesFrame = frame:GetParent()
				communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", 200, -32)
			end)

			lib.skin_icon_button(CommunitiesFrame.MaximizeMinimizeFrame.MaximizeButton, nil, "+")
			lib.skin_icon_button(CommunitiesFrame.MaximizeMinimizeFrame.MinimizeButton, nil, "-")
			lib.skin_icon_button(CommunitiesFrame.CommunitiesCalendarButton, nil, "C")
			CommunitiesFrame.CommunitiesCalendarButton:SetSize(25, 25)
			CommunitiesFrame.CommunitiesCalendarButton:SetPoint("TOPRIGHT", -8, -30)

			lib.skin_stretchbutton(CommunitiesFrame.AddToChatButton)
			
			CommunitiesFrame.AddToChatButton:SetNormalTexture(core.media.textures.blank)
			local normal = CommunitiesFrame.AddToChatButton:GetNormalTexture()
			normal:SetTexture([[interface/buttons/arrow-down-up]])
			normal:SetTexCoord(-0.1, 1, -0.1, 0.65)
			normal:SetAllPoints(CommunitiesFrame.AddToChatButton:GetHighlightTexture())

			CommunitiesFrame.AddToChatButton:SetPushedTexture(core.media.textures.blank)
			local pushed = CommunitiesFrame.AddToChatButton:GetPushedTexture()
			pushed:SetTexture([[interface/buttons/arrow-down-down]])
			pushed:SetTexCoord(0, 1.1, 0.0, 0.75)
			pushed:SetAllPoints(CommunitiesFrame.AddToChatButton:GetHighlightTexture())
						
			-- CommunitiesFrame.CommunitiesList
			CommunitiesFrame.CommunitiesList:SetPoint("TOPLEFT", 1, -23)
			core.util.strip_textures(CommunitiesFrame.CommunitiesList)
			core.util.fix_scrollbar(CommunitiesFrame.CommunitiesList.ScrollBar)
			core.util.strip_textures(CommunitiesFrame.CommunitiesList.FilligreeOverlay)
			CommunitiesFrame.CommunitiesList.FilligreeOverlay:Hide()
			CommunitiesFrame.CommunitiesList.InsetFrame:Hide()

			-- CommunitiesListEntryTemplate
			hooksecurefunc(CommunitiesListEntryMixin, "Init", function(self)
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
			CommunitiesFrame.CommunitiesListDropDownMenu:SetWidth(115)
			CommunitiesFrame.CommunitiesListDropDownMenu:SetPoint("TOPLEFT", 10, -28)
			lib.skin_dropdown(CommunitiesFrame.CommunitiesListDropDownMenu)
			lib.skin_dropdown(CommunitiesFrame.GuildMemberListDropDownMenu)
			lib.skin_dropdown(CommunitiesFrame.CommunityMemberListDropDownMenu)
			CommunitiesFrame.GuildMemberListDropDownMenu:SetPoint("TOPRIGHT", -10, -30)
			CommunitiesFrame.CommunityMemberListDropDownMenu:SetPoint("TOPRIGHT", -10, -30)

			-- CommunitiesFrame.MemberList
			core.util.strip_textures(CommunitiesFrame.MemberList.WatermarkFrame)
			core.util.strip_textures(CommunitiesFrame.MemberList.ColumnDisplay)
			hooksecurefunc(CommunitiesFrame.MemberList.ColumnDisplay, "LayoutColumns", function(self)
				for button in pairs(self.columnHeaders.activeObjects) do
					lib.skin_button(button, core.config.font_size_sml)
				end
			end)

			core.util.fix_scrollbar(CommunitiesFrame.MemberList.ScrollBar)
			
			local crop_class = function(button)
				local left, top, _, bottom, right = button.Class:GetTexCoord()
				button.Class:SetTexCoord(left + 0.019, right - 0.019, top + 0.019, bottom - 0.019)
			end

			local skin_row = function(row)
				row:GetNormalTexture():SetTexture()
				row:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				crop_class(row)
				row.ProfessionHeader.Left:Hide()
				row.ProfessionHeader.Right:Hide()
				row.ProfessionHeader.Middle:Hide()
			end

			hooksecurefunc(CommunitiesMemberListEntryMixin, "Init", skin_row)
			hooksecurefunc(CommunitiesMemberListEntryMixin, "SetMember", crop_class)

			core.util.gen_backdrop(CommunitiesFrame.MemberList, unpack(core.config.frame_background_transparent))
			CommunitiesFrame.MemberList.ScrollBox:ForEachFrame(crop_class)

			hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
				self.ScrollBox:ForEachFrame(crop_class)
			end)

			lib.skin_checkbox(CommunitiesFrame.MemberList.ShowOfflineButton)
			CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(20, 20)
			CommunitiesFrame.MemberList.ShowOfflineButton:SetPoint("BOTTOMLEFT", CommunitiesFrame.MemberList, "TOPLEFT", 0, 28)
			CommunitiesFrame.MemberList.ShowOfflineButton.Text:SetPoint("LEFT", CommunitiesFrame.MemberList.ShowOfflineButton, "RIGHT", 3, 0)

			-- CommunitiesFrame.Chat
			core.util.gen_backdrop(CommunitiesFrame.Chat, unpack(core.config.frame_background_transparent))
			core.util.fix_scrollbar(CommunitiesFrame.Chat.ScrollBar)
			
			lib.skin_button(JumpToUnreadButton)

			-- CommunitiesFrame.ChatEditBox
			core.util.fix_editbox(CommunitiesFrame.ChatEditBox)

			lib.skin_button(CommunitiesFrame.InviteButton)
			CommunitiesFrame.InviteButton:SetPoint("BOTTOMRIGHT", -5, 2)
			lib.skin_button(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
			CommunitiesFrame.CommunitiesControlFrame:SetPoint("BOTTOMRIGHT", -5, 2)

			lib.skin_button(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
			lib.skin_button(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
			lib.skin_button(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)

			lib.skin_button(CommunitiesFrame.GuildLogButton)

			-- CommunitiesFrame.GuildBenefitsFrame
			core.util.strip_textures(CommunitiesFrame.GuildBenefitsFrame, true)

			core.util.strip_textures(CommunitiesFrame.GuildBenefitsFrame.Perks, true)
			core.util.strip_textures(CommunitiesFrame.GuildBenefitsFrame.Rewards, true)

			hooksecurefunc("CommunitiesGuildPerks_Update", function(self)
				self.ScrollBox:ForEachFrame(function(frame)
					if frame.skinned then return end
					frame.skinned = true
					core.util.strip_textures(frame, true, {frame.Right, frame.Icon})
					core.util.set_outside(frame.Right, frame.Icon)
					frame.Right:SetColorTexture(unpack(core.config.color.border))
					core.util.crop_icon(frame.Icon)
				end)
			end)

			local skin_reward = function(button)
				if button.skinned then return end
				button.skinned = true
				local normal = button:GetNormalTexture()
				core.util.set_outside(normal, button.Icon)
				normal:SetColorTexture(unpack(core.config.color.border))
				core.util.crop_icon(button.Icon)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
			end

			hooksecurefunc(CommunitiesGuildRewardsButtonMixin, "Init", skin_reward)
			hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
				self.ScrollBox:ForEachFrame(skin_reward)
			end)

			core.util.fix_scrollbar(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar)

			core.util.strip_textures(CommunitiesFrame.GuildDetailsFrame, true)
			core.util.strip_textures(CommunitiesFrame.GuildDetailsFrame.Info, true)
			core.util.fix_scrollbar(CommunitiesFrame.GuildDetailsFrame.Info.MOTDScrollFrame.ScrollBar)
			core.util.fix_scrollbar(CommunitiesFrame.GuildDetailsFrame.Info.DetailsFrame.ScrollBar)

			core.util.strip_textures(CommunitiesFrame.GuildDetailsFrame.News, true)
			core.util.fix_scrollbar(CommunitiesFrame.GuildDetailsFrame.News.ScrollBar)

			CommunitiesFrame.GuildDetailsFrame.News.ScrollBox:ForEachFrame(function(button)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				button.header:SetTexture()
			end)
			hooksecurefunc(CommunitiesGuildNewsButtonMixin, "Init", function(button)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				button.header:SetTexture()
			end)
			
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Left:Hide()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Right:Hide()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Middle:Hide()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.BG:ClearAllPoints()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.BG:SetAllPoints()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.BG:SetColorTexture(unpack(core.config.color.border))
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Shadow:ClearAllPoints()
			core.util.set_inside(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Shadow, CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar)
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Shadow:SetColorTexture(unpack(core.config.color.background))
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress:ClearAllPoints()
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress:SetPoint("TOPLEFT", 1, -1)
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress:SetPoint("BOTTOMLEFT", 1, 1)
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress:SetTexture(core.media.textures.blank)
			CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress:SetDrawLayer("BACKGROUND", 2)

			hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar, "SetProgress", function(bar, cur, max)
				if max == 0 then
					cur = 1
					max = 1
				end
			
				local max_width = bar:GetWidth() - 2;
				local progress = min(max_width * cur / max, max_width);
				bar.Progress:SetWidth(progress)
				
				bar.Shadow:Show()
			end)

			local set_roles = function(frame)
				if not frame.TankRoleFrame.CheckBox:IsEnabled() then
					frame.TankRoleFrame.string:SetText("|cffaaaaaaT|r")
				else
					frame.TankRoleFrame.string:SetText(role_texts[LFG_LIST_GROUP_DATA_ATLASES.TANK])
				end
				if not frame.HealerRoleFrame.CheckBox:IsEnabled() then
					frame.HealerRoleFrame.string:SetText("|cffaaaaaaH|r")
				else
					frame.HealerRoleFrame.string:SetText(role_texts[LFG_LIST_GROUP_DATA_ATLASES.HEALER])
				end
				if not frame.DpsRoleFrame.CheckBox:IsEnabled() then
					frame.DpsRoleFrame.string:SetText("|cffaaaaaaD|r")
				else
					frame.DpsRoleFrame.string:SetText(role_texts[LFG_LIST_GROUP_DATA_ATLASES.DAMAGER])
				end
			end

			local skin_role_frame = function(frame, text)
				frame.Icon:Hide()
				local string = core.util.gen_string(frame, 30, nil, core.media.fonts.role_symbols)
				string:SetText(text)
				string:SetAllPoints()
				lib.skin_checkbox(frame.CheckBox)
				frame.CheckBox:SetSize(15, 15)
				frame.string = string
			end

			local skin_club_finder = function(frame)
				-- OptionsList
				lib.skin_dropdown(frame.OptionsList.ClubFilterDropdown)
				lib.skin_dropdown(frame.OptionsList.ClubSizeDropdown)
				lib.skin_dropdown(frame.OptionsList.SortByDropdown)

				skin_role_frame(frame.OptionsList.TankRoleFrame, role_texts[LFG_LIST_GROUP_DATA_ATLASES.TANK])
				skin_role_frame(frame.OptionsList.HealerRoleFrame, role_texts[LFG_LIST_GROUP_DATA_ATLASES.HEALER])
				skin_role_frame(frame.OptionsList.DpsRoleFrame, role_texts[LFG_LIST_GROUP_DATA_ATLASES.DAMAGER])
				
				set_roles(frame.OptionsList)
				hooksecurefunc(frame.OptionsList, "SetEnabledRoles", set_roles)
				hooksecurefunc(frame.OptionsList, "SetupGuildFinderOptions", function(self)
					self.ClubFilterDropdown:SetWidth(150)
					self.ClubSizeDropdown:ClearAllPoints()
					self.ClubSizeDropdown:SetPoint("BOTTOMLEFT", self.ClubFilterDropdown, "BOTTOMRIGHT", 5, 0)
				end)
				hooksecurefunc(frame.OptionsList, "SetupCommunityFinderOptions", function(self)
					self.ClubFilterDropdown:SetWidth(150)
					self.SortByDropdown:ClearAllPoints()
					self.SortByDropdown:SetPoint("BOTTOMLEFT", self.ClubFilterDropdown, "BOTTOMRIGHT", 5, 0)
				end)
				frame.OptionsList.ClubFilterDropdown:SetWidth(150)

				core.util.fix_editbox(frame.OptionsList.SearchBox)
				lib.skin_button(frame.OptionsList.Search)
				frame.OptionsList.Search:ClearAllPoints()
				frame.OptionsList.Search:SetPoint("TOPLEFT", frame.OptionsList.SearchBox, "BOTTOMLEFT", 0, -5)
				frame.OptionsList.Search:SetPoint("TOPRIGHT", frame.OptionsList.SearchBox, "BOTTOMRIGHT", 0, -5)

				core.util.fix_scrollbar(frame.CommunityCards.ScrollBar)
				core.util.fix_scrollbar(frame.PendingCommunityCards.ScrollBar)

				lib.skin_icon_button(frame.GuildCards.PreviousPage, nil, "<")
				lib.skin_icon_button(frame.GuildCards.NextPage, nil, ">")
				lib.skin_icon_button(frame.PendingGuildCards.PreviousPage, nil, "<")
				lib.skin_icon_button(frame.PendingGuildCards.NextPage, nil, ">")
				
				skin_tab(frame.ClubFinderSearchTab)
				skin_tab(frame.ClubFinderPendingTab)
			end
			
			skin_club_finder(CommunitiesFrame.GuildFinderFrame)
			skin_club_finder(CommunitiesFrame.CommunityFinderFrame)

			core.util.gen_backdrop(CommunitiesFrame.GuildMemberDetailFrame)
			lib.skin_icon_button(CommunitiesFrame.GuildMemberDetailFrame.CloseButton, nil, "x")
			CommunitiesFrame.GuildMemberDetailFrame.CloseButton:SetPoint("TOPRIGHT", -3, -3)
			lib.skin_button(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton, core.config.font_size_sml)
			lib.skin_button(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton, core.config.font_size_sml)

			core.util.gen_backdrop(CommunitiesFrame.GuildMemberDetailFrame.NoteBackground)
			CommunitiesFrame.GuildMemberDetailFrame.NoteBackground.NineSlice:Hide()
			core.util.gen_backdrop(CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground)
			CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground.NineSlice:Hide()
		
		elseif name == "EncounterJournal" then
			
			core.util.fix_editbox(EncounterJournal.searchBox)
			lib.skin_navbar(EncounterJournal.navBar)
			lib.skin_dropdown(EncounterJournal.instanceSelect.tierDropDown)
			EncounterJournal.instanceSelect.tierDropDown:SetPoint("TOPRIGHT", -5, -5)
			core.util.fix_scrollbar(EncounterJournal.instanceSelect.ScrollBar)
			EncounterJournal.instanceSelect.border = EncounterJournal.instanceSelect:CreateTexture(nil, "BACKGROUND", nil, -1)
			EncounterJournal.instanceSelect.border:SetColorTexture(unpack(core.config.color.border))
			core.util.set_outside(EncounterJournal.instanceSelect.border, EncounterJournal.instanceSelect)
			EncounterJournal.instanceSelect.bg:SetAllPoints()
			EncounterJournal.instanceSelect.bg:SetTexCoord(0.01, 0.96, 0.01, 1)

			hooksecurefunc("EncounterJournal_ListInstances", function()
				EncounterJournal.instanceSelect.ScrollBox:ForEachFrame(function(frame)
					if frame.skinned then return end
					frame.skinned = true

					frame.border = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
					frame.border:SetColorTexture(unpack(core.config.color.border))
					frame.border:SetAllPoints()
					core.util.set_inside(frame.bgImage, frame)
					frame.bgImage:SetTexCoord(0.05, 0.63, 0.05, 0.69)

					frame:ClearNormalTexture()
					frame:GetPushedTexture():SetColorTexture(unpack(core.config.color.pushed))
					frame:GetPushedTexture():SetAllPoints(frame.bgImage)
					frame:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
					frame:GetHighlightTexture():SetAllPoints(frame.bgImage)
				end)
			end)

			core.util.fix_scrollbar(EncounterJournal.encounter.instance.LoreScrollBar)
			EncounterJournal.encounter.info.border = EncounterJournal.encounter.info:CreateTexture(nil, "BACKGROUND", nil, -1)
			EncounterJournal.encounter.info.border:SetColorTexture(unpack(core.config.color.border))
			core.util.set_outside(EncounterJournal.encounter.info.border, EncounterJournal.encounter.info)

			core.util.fix_scrollbar(EncounterJournal.encounter.info.BossesScrollBar)
			core.util.fix_scrollbar(EncounterJournalEncounterFrameInfoDetailsScrollFrame.ScrollBar)
			core.util.fix_scrollbar(EncounterJournalEncounterFrameInfoOverviewScrollFrame.ScrollBar)
			core.util.fix_scrollbar(EncounterJournal.encounter.info.LootContainer.ScrollBar)

			-- EJButtonTemplate
			local skin_filter_button = function(button)
				core.util.strip_textures(button, true)
				core.util.gen_backdrop(button)
				button:SetHighlightTexture(core.media.textures.blank)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
				core.util.set_inside(button:GetHighlightTexture(), button)
			end
			skin_filter_button(EncounterJournal.encounter.info.difficulty)
			skin_filter_button(EncounterJournal.encounter.info.LootContainer.filter)
			skin_filter_button(EncounterJournal.encounter.info.LootContainer.slotFilter)

			EncounterJournal.MonthlyActivitiesTab:ClearAllPoints()
			EncounterJournal.MonthlyActivitiesTab:SetPoint("TOPLEFT", EncounterJournal, "BOTTOMLEFT", 0, 1)
			EncounterJournal.suggestTab:ClearAllPoints()
			EncounterJournal.suggestTab:SetPoint("TOPLEFT", EncounterJournal.MonthlyActivitiesTab, "TOPRIGHT", -1, 0)
			EncounterJournal.dungeonsTab:ClearAllPoints()
			EncounterJournal.dungeonsTab:SetPoint("TOPLEFT", EncounterJournal.suggestTab, "TOPRIGHT", -1, 0)
			EncounterJournal.raidsTab:ClearAllPoints()
			EncounterJournal.raidsTab:SetPoint("TOPLEFT", EncounterJournal.dungeonsTab, "TOPRIGHT", -1, 0)
			EncounterJournal.LootJournalTab:ClearAllPoints()
			EncounterJournal.LootJournalTab:SetPoint("TOPLEFT", EncounterJournal.raidsTab, "TOPRIGHT", -1, 0)

			hooksecurefunc("EncounterJournal_CheckAndDisplayTradingPostTab", function()
				EncounterJournal.suggestTab:ClearAllPoints()
				if C_PlayerInfo.IsTradingPostAvailable() then
					EncounterJournal.suggestTab:SetPoint("TOPLEFT", EncounterJournal.MonthlyActivitiesTab, "TOPRIGHT", -1, 0)
				else
					EncounterJournal.suggestTab:SetPoint("TOPLEFT", EncounterJournal, "BOTTOMLEFT", 0, 1)
				end
			end)

		elseif name == "ClassTrainerFrame" then

			ClassTrainerFrame.BG:Hide()
			ClassTrainerFrameMoneyBg:Hide()

			core.util.strip_textures(ClassTrainerStatusBar, true)
			ClassTrainerStatusBar:SetStatusBarTexture(core.media.textures.blank)
			ClassTrainerStatusBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
			core.util.gen_backdrop(ClassTrainerStatusBar)
			ClassTrainerStatusBar:SetPoint("TOPLEFT", 60, -36)

			lib.skin_dropdown(ClassTrainerFrameFilterDropDown)
			ClassTrainerFrameFilterDropDown:HookScript("OnShow", function(self)
				self:SetWidth(120)
			end)
			ClassTrainerFrameFilterDropDown:SetPoint("TOPRIGHT", -5, -30)
			lib.skin_button(ClassTrainerTrainButton)
			core.util.fix_scrollbar(ClassTrainerFrame.ScrollBar)

			hooksecurefunc("ClassTrainerFrame_InitServiceButton", function(button)
				-- ClassTrainerSkillButtonTemplate
				
				if button.skinned then return end
				button.skinned = true
				
				core.util.crop_icon(button.icon)
				button.selectedTex:SetColorTexture(unpack(core.config.color.selected))
				button:GetNormalTexture():SetColorTexture(unpack(core.config.color.border))
				core.util.set_outside(button:GetNormalTexture(), button.icon)
				button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
			end)

		elseif name == "ProfessionsFrame" then
			
			ProfessionsFrame.TabSystem:SetPoint("TOPLEFT", ProfessionsFrame, "BOTTOMLEFT", 0, 1)
			hooksecurefunc(ProfessionsFrame.TabSystem, "LayoutChildren", function(self, children)
				local prev
				for i, child in ipairs(children) do
					child:ClearAllPoints()
					if prev then
						child:SetPoint("TOPLEFT", prev, "TOPRIGHT", -1, 0)
					else
						child:SetPoint("TOPLEFT", self, "TOPLEFT")
					end
					prev = child
				end
			end)

			lib.skin_tab(ProfessionsFrame:GetTabButton(ProfessionsFrame.recipesTabID))
			lib.skin_tab(ProfessionsFrame:GetTabButton(ProfessionsFrame.specializationsTabID))
			lib.skin_tab(ProfessionsFrame:GetTabButton(ProfessionsFrame.craftingOrdersTabID))

			-- ProfessionsCraftingPageTemplate
			lib.skin_help(ProfessionsFrame.CraftingPage.TutorialButton)
			core.util.gen_backdrop(ProfessionsFrame.CraftingPage.RecipeList, unpack(core.config.frame_background_transparent))
			ProfessionsFrame.CraftingPage.RecipeList.Backgroud:Hide()
			ProfessionsFrame.CraftingPage.RecipeList.BackgroundNineSlice:Hide()
			
			core.util.strip_textures(ProfessionsFrame.CraftingPage.RecipeList.FilterButton, true)
			core.util.gen_backdrop(ProfessionsFrame.CraftingPage.RecipeList.FilterButton)
			ProfessionsFrame.CraftingPage.RecipeList.FilterButton:SetHighlightTexture(core.media.textures.blank)
			ProfessionsFrame.CraftingPage.RecipeList.FilterButton:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
			core.util.set_inside(ProfessionsFrame.CraftingPage.RecipeList.FilterButton:GetHighlightTexture(), ProfessionsFrame.CraftingPage.RecipeList.FilterButton)
			core.util.fix_editbox(ProfessionsFrame.CraftingPage.RecipeList.SearchBox)

			ProfessionsFrame.CraftingPage.SchematicForm.Background:Show()
			ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox:SetPoint("TOPRIGHT", -(math.floor(ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox.text:GetStringWidth()) + 25), -16)
			ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox.text:SetPoint("LEFT", ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox, "RIGHT", 5, 0)
			lib.skin_checkbox(ProfessionsFrame.CraftingPage.SchematicForm.TrackRecipeCheckBox)
			lib.skin_checkbox(ProfessionsFrame.CraftingPage.SchematicForm.AllocateBestQualityCheckBox)

			lib.skin_button(ProfessionsFrame.CraftingPage.CreateButton)
			lib.skin_button(ProfessionsFrame.CraftingPage.CreateAllButton)

			core.util.strip_textures(ProfessionsFrame.CraftingPage.CreateMultipleInputBox, true)
			core.util.fix_editbox(ProfessionsFrame.CraftingPage.CreateMultipleInputBox)
			ProfessionsFrame.CraftingPage.CreateMultipleInputBox:SetWidth(40)
			lib.skin_icon_button(ProfessionsFrame.CraftingPage.CreateMultipleInputBox.IncrementButton, nil, ">")
			lib.skin_icon_button(ProfessionsFrame.CraftingPage.CreateMultipleInputBox.DecrementButton, nil, "<")
			ProfessionsFrame.CraftingPage.CreateMultipleInputBox.IncrementButton:SetPoint("LEFT", ProfessionsFrame.CraftingPage.CreateMultipleInputBox, "RIGHT", 1, 0)
			ProfessionsFrame.CraftingPage.CreateMultipleInputBox.DecrementButton:SetPoint("RIGHT", ProfessionsFrame.CraftingPage.CreateMultipleInputBox, "LEFT", -1, 0)

			lib.skin_itembutton(ProfessionsFrame.CraftingPage.Prof0ToolSlot)
			lib.skin_itembutton(ProfessionsFrame.CraftingPage.Prof0Gear0Slot)
			lib.skin_itembutton(ProfessionsFrame.CraftingPage.Prof0Gear1Slot)

			lib.skin_icon_button(ProfessionsFrame.CraftingPage.LinkButton, nil, ">")

			-- ProfessionsSpecPageTemplate
			ProfessionsFrame.SpecPage.PanelFooter:Hide()

			lib.skin_button(ProfessionsFrame.SpecPage.ApplyButton)
			lib.skin_button(ProfessionsFrame.SpecPage.UnlockTabButton)
			lib.skin_button(ProfessionsFrame.SpecPage.DetailedView.SpendPointsButton)
			lib.skin_button(ProfessionsFrame.SpecPage.DetailedView.UnlockPathButton)

			core.util.crop_icon(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.Icon)
			
			ProfessionsFrame.SpecPage.VerticalDivider:Hide()
			ProfessionsFrame.SpecPage.TopDivider:Hide()

			-- ProfessionsCraftingOrderPageTemplate
			core.util.gen_backdrop(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList, unpack(core.config.frame_background_transparent))

			ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.Backgroud:Hide()
			ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.BackgroundNineSlice:Hide()

			core.util.strip_textures(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton, true)
			core.util.gen_backdrop(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton)
			ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton:SetHighlightTexture(core.media.textures.blank)
			ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))
			core.util.set_inside(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton:GetHighlightTexture(), ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.FilterButton)
			core.util.fix_editbox(ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList.SearchBox)
			
			lib.skin_icon_button(ProfessionsFrame.OrdersPage.BrowseFrame.FavoritesSearchButton, nil, "F")
			lib.skin_button(ProfessionsFrame.OrdersPage.BrowseFrame.SearchButton)
			ProfessionsFrame.OrdersPage.BrowseFrame.SearchButton:SetPoint("LEFT", ProfessionsFrame.OrdersPage.BrowseFrame.FavoritesSearchButton, "RIGHT", 5, 0)

			ProfessionsFrame.OrdersPage.BrowseFrame.OrderList.NineSlice:Hide()
			ProfessionsFrame.OrdersPage.BrowseFrame.OrdersRemainingDisplay.Background:Hide()

			hooksecurefunc(ProfessionsFrame.OrdersPage, "SetupTable", function(self)
				for frame in self.tableBuilder:EnumerateHeaders() do
					lib.skin_button(frame, core.config.font_size_sml)
					frame.Arrow:SetSize(9, 12)
					frame.Arrow:ClearAllPoints()
					frame.Arrow:SetPoint("RIGHT", -5, 0)
				end
			end)
			for frame in ProfessionsFrame.OrdersPage.tableBuilder:EnumerateHeaders() do
				lib.skin_button(frame, core.config.font_size_sml)
				frame.Arrow:SetSize(9, 12)
				frame.Arrow:ClearAllPoints()
				frame.Arrow:SetPoint("RIGHT", -5, 0)
			end
		end

	elseif name == "WorldMapFrame" then

		WorldMapFrame.BorderFrame.InsetBorderTop:Hide()
		lib.skin_help(WorldMapFrame.BorderFrame.Tutorial)

		for _, frame in ipairs(WorldMapFrame.overlayFrames) do
			local relative, anchor, relative_to = frame:GetPoint()
			if relative == "TOPLEFT" and relative_to == "TOPLEFT" and frame.InitializeDropDown then
				lib.skin_dropdown(frame)
				frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 1, -1)
			end
		end

		lib.skin_navbar(WorldMapFrame.NavBar)

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

		panel.BorderFrame.TopBorder:SetTexture()
		panel.BorderFrame.TopBorder:Hide()

	elseif name == "TalkingHeadFrame" then

		TalkingHeadFrame:SetSize(500, 140)
		TalkingHeadFrame.PortraitFrame:Hide()
		TalkingHeadFrame.MainFrame.Model:SetSize(138, 138)
		TalkingHeadFrame.MainFrame.Model:SetPoint("TOPLEFT", 1, -1)
		TalkingHeadFrame.MainFrame.Model:SetPoint("BOTTOMRIGHT", TalkingHeadFrame.MainFrame, "TOPLEFT", 139, -139)
		TalkingHeadFrame.MainFrame.Model.PortraitBg:Hide()
		TalkingHeadFrame.MainFrame.CloseButton:SetPoint("TOPRIGHT", -1, -1)
		lib.skin_icon_button(TalkingHeadFrame.MainFrame.CloseButton, nil, "x")
		TalkingHeadFrame.BackgroundFrame:Hide()
		core.util.gen_backdrop(TalkingHeadFrame, unpack(core.config.frame_background_transparent))
		
	end

	if not nested then
		core.util.gen_backdrop(panel, unpack(core.config.frame_background_transparent))
		panel.skinned = true
	end
end

local skin_static_popup = function(popup)
	skin_panel(popup)

	lib.skin_button(popup.button1)
	lib.skin_button(popup.button2)
	lib.skin_button(popup.button3)
	lib.skin_button(popup.button4)
	lib.skin_button(popup.extraButton)

	core.util.fix_editbox(_G[popup:GetName().."EditBox"])

	lib.skin_itembutton(popup.ItemFrame, nil, 36, 36)
	_G[popup.ItemFrame:GetName().."NameFrame"]:Hide()

	local money_input = _G[popup:GetName().."MoneyInputFrame"]
	core.util.fix_editbox(money_input.gold)
	core.util.fix_editbox(money_input.silver)
	money_input.silver.texture:SetPoint("RIGHT", -4, 0)
	core.util.fix_editbox(money_input.copper)
	money_input.copper.texture:SetPoint("RIGHT", -4, 0)
end

skin_static_popup(StaticPopup1)
skin_static_popup(StaticPopup2)
skin_static_popup(StaticPopup3)
skin_static_popup(StaticPopup4)

hooksecurefunc("SetItemButtonQuality", function(button, quality, id_or_link)
	if button.CircleMask then
		icon = button.Icon or button.icon
		
		icon:SetAllPoints()
		core.util.set_outside(button.IconBorder, button)

		icon.mask = button.CircleMask
		core.util.circle_mask(button, icon)
		core.util.circle_mask(button, button.IconBorder)

		local quality_color = BAG_ITEM_QUALITY_COLORS[quality]
		if quality_color then
			button.IconBorder:SetVertexColor(quality_color.r, quality_color.g, quality_color.b)
		end
	end

	if id_or_link and IsArtifactRelicItem(id_or_link) then
		button.IconBorder:SetDrawLayer("OVERLAY")
	else
		button.IconBorder:SetDrawLayer("BACKGROUND", -8)
		button.IconBorder:SetTexture(core.media.textures.blank)
	end

	if not quality or quality < Enum.ItemQuality.Common or not BAG_ITEM_QUALITY_COLORS[quality] then
		button.IconBorder:Show()
		button.IconBorder:SetVertexColor(unpack(core.config.color.border))
	end
end)

hooksecurefunc("SetItemButtonTexture", function(button, texture)
	if not button then return end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"]
	core.util.crop_icon(icon)
end)

hooksecurefunc(PvpTalentSlotMixin, "Update", function(self)
	self.Border:SetTexture(core.media.textures.blank)
	self.Border:SetVertexColor(unpack(core.config.color.border))
end)

hooksecurefunc("TalentFrame_Update", function(frame)
	for r = 1, MAX_TALENT_TIERS do
		local row = frame["tier"..r]
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

hooksecurefunc("UpdateProfessionButton", function(button)
	button:GetHighlightTexture():SetTexture(core.media.textures.blank)
	button:GetHighlightTexture():SetVertexColor(unpack(core.config.color.highlight))
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

hooksecurefunc(TabSystemButtonArtMixin, "SetTabSelected", function(self, selected)
	lib.skin_tab(self)
	local text = self.Text or _G[self:GetName().."Text"]
	text:ClearAllPoints()
	text:SetPoint("CENTER", self)
	self.selected_texture:SetShown(selected)
end)

hooksecurefunc("PaperDollTitlesPane_InitButton", function(button)
	-- PlayerTitleButtonTemplate

	button.BgTop:Hide()
	button.BgBottom:Hide()
	button.BgMiddle:Hide()
	button.Stripe:SetColorTexture(0.5, 0.5, 0.5, 1)
	button.Check:SetTexture()

	button.SelectedBar:SetColorTexture(unpack(core.config.color.checked))
	button:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))

	button.text:SetPoint("LEFT", 3, 0)
	core.util.fix_string(button.text, core.config.font_size_mini)
end)

hooksecurefunc("PaperDollEquipmentManagerPane_InitButton", function(button)
	-- GearSetButtonTemplate

	button.BgTop:Hide()
	button.BgBottom:Hide()
	button.BgMiddle:Hide()
	button.Stripe:SetColorTexture(0.5, 0.5, 0.5, 1)
	-- button.Check
	core.util.fix_string(button.text, core.config.font_size_sml)
	
	button.SpecRing:SetColorTexture(unpack(core.config.color.border))
	button.SpecRing:SetDrawLayer("OVERLAY", -4)
	button.SpecIcon:ClearAllPoints()
	button.SpecIcon:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 2, -2)
	core.util.set_outside(button.SpecRing, button.SpecIcon)
	core.util.crop_icon(button.SpecIcon)

	button.HighlightBar:SetColorTexture(unpack(core.config.color.highlight))
	button.SelectedBar:SetColorTexture(unpack(core.config.color.checked))

	core.util.crop_icon(button.icon)
	button.icon_bg = button:CreateTexture(nil, "BORDER")
	button.icon_bg:SetColorTexture(unpack(core.config.color.border))
	core.util.set_outside(button.icon_bg, button.icon)
end)

hooksecurefunc("ReputationFrame_InitReputationRow", function(button)
	-- ReputationBarTemplate

	button.Container.Background:Hide()
	button.Container.ReputationBar.AtWarHighlight1:SetColorTexture(1, 0.25, 0.25, 1)
	button.Container.ReputationBar.AtWarHighlight2:SetTexture()

	button.Container.ReputationBar.LeftTexture:Hide()
	button.Container.ReputationBar.RightTexture:Hide()

	button.Container.ReputationBar.Highlight1:SetColorTexture(unpack(core.config.color.highlight))
	button.Container.ReputationBar.Highlight1:SetAllPoints(button)
	button.Container.ReputationBar.Highlight2:SetTexture()
	
	core.util.gen_backdrop(button.Container.ReputationBar)
	button.Container.ReputationBar:SetStatusBarTexture(core.media.textures.blank)
	button.Container.ReputationBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
	button.Container.ReputationBar:SetHeight(16)
end)

hooksecurefunc("GearSetButton_SetSpecInfo", function(self, specID)
	if ( specID and specID > 0 ) then
		local _, _, _, texture = GetSpecializationInfoByID(specID);
		self.SpecIcon:SetTexture(texture)
		self.SpecIcon:ClearAllPoints()
		self.SpecIcon:SetPoint("BOTTOMRIGHT", self.icon, "BOTTOMRIGHT", 2, -2)
		core.util.crop_icon(self.SpecIcon)
		core.util.set_outside(self.SpecRing, self.SpecIcon)
	end
end)

hooksecurefunc("EquipmentFlyout_CreateButton", function()
	for _, item in ipairs(EquipmentFlyoutFrame.buttons) do
		lib.skin_itembutton(item)
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

hooksecurefunc("NavBar_AddButton", function(bar)
	local nav = bar.navList[#bar.navList]
	nav:SetText("->  "..nav:GetText())

	if nav.skinned then return end
	nav.skinned = true

	nav.text:SetPoint("LEFT", 2, 0)
	nav.selected:SetColorTexture(unpack(core.config.color.selected))
	nav.arrowUp:SetTexture()
	nav.arrowDown:SetTexture()
	nav:GetNormalTexture():SetTexture()
	nav:GetPushedTexture():SetTexture()
	nav:GetHighlightTexture():SetColorTexture(unpack(core.config.color.highlight))

	core.util.strip_textures(nav.MenuArrowButton, true, {nav.MenuArrowButton.Art})
end)

local skin_token = function()
	-- TokenFrame

	core.util.gen_backdrop(TokenFrame.ScrollBox, unpack(core.config.frame_background_transparent))
	core.util.fix_scrollbar(TokenFrame.ScrollBar)
	TokenFrame.ScrollBar:SetPoint("TOPLEFT", TokenFrame.ScrollBox, "TOPRIGHT")
	TokenFrame.ScrollBar:SetPoint("BOTTOMLEFT", TokenFrame.ScrollBox, "BOTTOMRIGHT")

	hooksecurefunc("TokenFrame_InitTokenButton", function(self, button)
		-- TokenButtonTemplate

		-- button.Stripe
		core.util.crop_icon(button.Icon)

		button.CategoryLeft:SetTexture()
		button.CategoryRight:SetTexture()
		button.CategoryMiddle:SetTexture()

		button.Highlight:SetColorTexture(unpack(core.config.color.highlight))
	end)
	
end

local skin_challenges = function()

	core.util.strip_textures(ChallengesFrame, true, {ChallengesFrame.Background})
	ChallengesFrameInset:Hide()

	hooksecurefunc(ChallengesFrame, "Update", function(self)
		local width = ChallengesFrame.WeeklyInfo:GetWidth()
		local size = (width - (#self.DungeonIcons * 5)) / #self.DungeonIcons
		local prev
		for _, dungeon in ipairs(self.DungeonIcons) do
			dungeon:SetSize(size, size)

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
				dungeon:SetPoint("BOTTOMLEFT", prev, "BOTTOMLEFT", size + 5, 0)
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
	core.util.fix_scrollbar(HonorFrame.SpecificScrollBar)

	hooksecurefunc("HonorFrame_InitSpecificButton", function(button)
		-- PVPInstanceListEntryButtonTemplate
		button.Bg:Hide()
		button.SelectedTexture:SetColorTexture(unpack(core.config.color.selected))
		button.Border:SetColorTexture(unpack(core.config.color.border))
		button.Border:SetDrawLayer("BORDER", 1)
		core.util.set_outside(button.Border, button.Icon)
		
		button.HighlightTexture:SetColorTexture(unpack(core.config.color.highlight))

		core.util.fix_string(button.InfoText, core.config.font_size_sml)
	end)

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

local skin_raid_manager = function()

	core.util.strip_textures(CompactRaidFrameManager)
	core.util.gen_backdrop(CompactRaidFrameManager, unpack(core.config.frame_background_transparent))
	CompactRaidFrameManager.toggleButton:SetPoint("RIGHT")
	CompactRaidFrameManager.toggleButton.arrow = core.util.gen_string(CompactRaidFrameManager.toggleButton)
	CompactRaidFrameManager.toggleButton.arrow:SetText(">")
	CompactRaidFrameManager.toggleButton.arrow:SetAllPoints(CompactRaidFrameManager.toggleButton:GetNormalTexture())
	CompactRaidFrameManager.toggleButton:GetNormalTexture():SetTexture()
	core.util.strip_textures(CompactRaidFrameManager.displayFrame, true)
	CompactRaidFrameManager.displayFrame.optionsFlowContainer:SetPoint("TOPLEFT", -10, -30)
	core.util.strip_textures(CompactRaidFrameManager.displayFrame.filterOptions)

	hooksecurefunc("CompactRaidFrameManager_Expand", function(self)
		CompactRaidFrameManager.toggleButton.arrow:SetText("<")
	end)

	hooksecurefunc("CompactRaidFrameManager_Collapse", function(self)
		CompactRaidFrameManager.toggleButton.arrow:SetText(">")
	end)

	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.editMode, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.hiddenModeToggle, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.convertToRaid, core.config.font_size_sml)

	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.leaderOptions.countdownButton, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton, core.config.font_size_sml)
	lib.skin_stretchbutton(_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName().."RaidWorldMarkerButton"], nil, {
		_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName().."RaidWorldMarkerButton"].Icon
	})

	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager, core.config.font_size_sml)

	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup1, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup2, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup3, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup4, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup5, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup6, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup7, core.config.font_size_sml)
	lib.skin_stretchbutton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup8, core.config.font_size_sml)
end

local skin_weekly_reward = function()

	lib.skin_icon_button(WeeklyRewardsFrame.CloseButton, nil, "x")
	lib.skin_button(WeeklyRewardsFrame.SelectRewardButton)

	hooksecurefunc(WeeklyRewardConfirmSelectionMixin, "ShowPopup", function(self)
		item = self.ItemFrame
		item.NameFrame:Hide()
		core.util.set_outside(item.IconBorder, item.Icon)
		core.util.crop_icon(item.Icon)
	end)

	hooksecurefunc(WeeklyRewardConfirmSelectionMixin, "RefreshRewards", function(self)
		if #self.activityInfo.rewards > 1 then
			for frame in self.AlsoItemsFrame.pool:EnumerateActive() do
				core.util.crop_icon(frame.Icon)
				frame.IconBorder:SetDrawLayer("BORDER", -8)
				frame.IconBorder:SetTexture(core.media.textures.blank)
				core.util.set_outside(frame.IconBorder, frame.Icon)
			end
		end
	end)
end

if IsAddOnLoaded("Blizzard_ChallengesUI") then
	skin_challenges()
end

if IsAddOnLoaded("Blizzard_PVPUI") then
	skin_pvp()
end

if IsAddOnLoaded("Blizzard_TokenUI") then
	skin_token()
end

if IsAddOnLoaded("Blizzard_Collections") then
	skin_panel(CollectionsJournal)
end

if IsAddOnLoaded("Blizzard_Communities") then
	skin_panel(CommunitiesFrame)
end

if IsAddOnLoaded("Blizzard_ClassTalentUI") then
	skin_panel(ClassTalentFrame)
end

if IsAddOnLoaded("Blizzard_WorldMap") then
	skin_panel(WorldMapFrame)
end

if IsAddOnLoaded("Blizzard_FlightMap") then
	skin_panel(FlightMapFrame)
end

if IsAddOnLoaded("Blizzard_ItemSocketingUI") then
	skin_panel(ItemSocketingFrame)
end

if IsAddOnLoaded("Blizzard_AuctionHouseUI") then
	skin_panel(AuctionHouseFrame)
end

if IsAddOnLoaded("Blizzard_WeeklyRewards") then
	skin_weekly_reward()
end

if IsAddOnLoaded("Blizzard_EncounterJournal") then
	skin_panel(EncounterJournal)
end

if IsAddOnLoaded("Blizzard_InspectUI") then
	skin_panel(InspectFrame)
end

if IsAddOnLoaded("Blizzard_TrainerUI") then
	skin_panel(ClassTrainerFrame)
end

if IsAddOnLoaded("Blizzard_Professions") then
	skin_panel(ProfessionsFrame)
end

if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
	skin_raid_manager()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TokenUI" then
		skin_token()
	elseif addon == "Blizzard_ClassTalentUI" then
		skin_panel(ClassTalentFrame)
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
	elseif addon == "Blizzard_Professions" then
		skin_panel(ProfessionsFrame)
	elseif addon == "Blizzard_ItemSocketingUI" then
		skin_panel(ItemSocketingFrame)
	elseif addon == "Blizzard_InspectUI" then
		skin_panel(InspectFrame)
	elseif addon == "Blizzard_WorldMap" then
		skin_panel(WorldMapFrame)
	elseif addon == "Blizzard_EncounterJournal" then
		skin_panel(EncounterJournal)
	elseif addon == "Blizzard_TrainerUI" then
		skin_panel(ClassTrainerFrame)
	elseif addon == "Blizzard_CompactRaidFrames" then
		skin_raid_manager()
	elseif addon == "Blizzard_WeeklyRewards" then
		skin_weekly_reward()
	end
end)

local style_backdrop = function(tooltip)
	if tooltip.IsEmbedded or tooltip:IsForbidden() then return end

	if not tooltip.styled then
		core.util.gen_backdrop(tooltip, unpack(core.config.frame_background_transparent))
		tooltip:SetBackdropBorderColor(unpack(core.config.color.light_border))

		local status_bar = _G[tooltip:GetName().."StatusBar"]
		if status_bar then
			status_bar:SetStatusBarTexture(core.media.textures.blank)
			core.util.gen_backdrop(status_bar)
			status_bar:SetPoint("TOPLEFT", tooltip, "BOTTOMLEFT", 0, 1)
			status_bar:SetPoint("TOPRIGHT", tooltip, "BOTTOMRIGHT", 0, 1)
			status_bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1)
			GameTooltipStatusBar:SetBackdropBorderColor(unpack(core.config.color.light_border))
		end

		tooltip.styled = true
	end

	tooltip.NineSlice:Hide()
end

hooksecurefunc("SharedTooltip_SetBackdropStyle", style_backdrop)
style_backdrop(GameTooltip)
