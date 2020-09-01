local cui = CityUi

local data_parent = CityDataPanel
local class_colors = RAID_CLASS_COLORS
local class_list = LOCALIZED_CLASS_NAMES_MALE

-- memory ---------------

local format_mem = function(mem)
	local value = mem / 8192
	local new_mem = mem > 1024 and mem / 1024 or mem
	local size = mem > 1024 and "mb" or "kb"
	if value > 1 then value = 1 end
	return string.format("%.1f|c%s%s|r", new_mem, cui.player.color_str, size)
end
local function sortdesc(a, b) return a[2] > b[2] end

local mem_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
mem_text:SetPoint("BOTTOMLEFT", data_parent, "BOTTOMLEFT", 7, 5)

local mem_frame = CreateFrame("Button", "CityMem", UIParent)
mem_frame:SetAllPoints(mem_text)
mem_frame.last = 0

mem_frame:RegisterEvent"PLAYER_LOGIN"
mem_frame:SetScript("OnEvent", function(self, event)
	mem_frame.num = GetNumAddOns()
	local mem_sum = 0
	UpdateAddOnMemoryUsage()
	for i = 1, mem_frame.num do
		mem_sum = mem_sum + GetAddOnMemoryUsage(i)
	end
	mem_text:SetText(format_mem(mem_sum))
end)

mem_frame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Memory", 1, 1, 1)
	GameTooltip:AddLine" "
	local mem_sum = 0
	local mem_list = {}
	UpdateAddOnMemoryUsage()
	for i = 1, self.num do
		local _, name = GetAddOnInfo(i)
		local memory = 0
		if IsAddOnLoaded(i) then
			memory = GetAddOnMemoryUsage(i)
			if not mem_list[1] then
				table.insert(mem_list, 1, {name, memory})
			else
				local p = 1
				while p <= self.num and mem_list[p] and memory < mem_list[p][2] do
					p = p + 1
				end
				table.insert(mem_list, p, {name, memory})
			end
		end
		mem_sum = mem_sum + memory
	end
	for _, addon in pairs(mem_list) do
		GameTooltip:AddDoubleLine(addon[1]..":", format_mem(addon[2]), 1, 1, 1, 1, 1, 1)
	end
	local total_mem = gcinfo()
	local blizz_mem = total_mem - mem_sum
	GameTooltip:AddLine" "
	GameTooltip:AddDoubleLine("AddOn Memory:", format_mem(mem_sum), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Default UI Memory:", format_mem(blizz_mem), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Total Memory:", format_mem(total_mem), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
	mem_text:SetText(format_mem(mem_sum))
end)
mem_frame:SetScript("OnUpdate", function(self, last)
	if mem_frame.num then
		self.last = self.last + last
		if self.last >= 5 then
			local mem_sum = 0
			UpdateAddOnMemoryUsage()
			for i = 1, mem_frame.num do
				mem_sum = mem_sum + GetAddOnMemoryUsage(i)
			end
			mem_text:SetText(format_mem(mem_sum))
			self.last = self.last - 5
		end
	end
end)
mem_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
mem_frame:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		UpdateAddOnMemoryUsage()
		local old_mem = gcinfo()
		collectgarbage()
		UpdateAddOnMemoryUsage()
		print("garbage collected: ", format_mem(old_mem - gcinfo()))
		self.last = 5
		self:GetScript("OnEnter")(self)
	end
end)

-- friends --------------

local friend_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
friend_text:SetPoint("BOTTOMLEFT", mem_text, "BOTTOMRIGHT", 5, 0)

local friend_frame = CreateFrame("Button", "CityFriends", UIParent)
friend_frame:SetAllPoints(friend_text)
friend_frame.ttopen = false

local gen_friend_tt = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Friends", 1, 1, 1)
	GameTooltip:AddLine" "
		
	-- bnet friends:	<status> first last			game
	-- if on wow:		lvl name race				zone

	-- hasFocus, characterName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText,
	-- broadcastText, broadcastTime, canSoR, bnetIDGameAccount = BNGetFriendGameAccountInfo(friendIndex, toonIndex)
	local num_bnet_friends = BNGetNumFriends()
	for i = 1, num_bnet_friends do
		-- 5.0.4 change
		-- 1presenceID, 2name, 3battleTag, 4onlinebnet(not sure?), 5toonName, 6toonID, 7client, 8isOnline, 9lastOnline,
		-- 10isAFK, 11isDND, 12messageText, 13noteText, 14isRIDFriend, 15broadcastTime, 16canSoR = BNGetFriendInfo(i)
		local _, full_name, battletag, _, toon_name, _, game, online, _, afk, dnd, _, _, _, _, _ = BNGetFriendInfo(i)
		local status = (afk and "|cffFF0000<AFK>|r ") or (dnd and "|cffFFFF00<DND>|r ") or ""
		if online then
			if game == "WoW" then
				local player, class, race, zone, level
				for p = 1, BNGetNumFriendGameAccounts(i) do
					_, player, _, _, _, _, race, class, _, zone, level, _, _, _ = BNGetFriendGameAccountInfo(i, p)
					if toon_name == player then
						break
					end
				end
				for k,v in pairs(class_list) do if class == v then class = k end end
				local class_color = class_colors[class]
				local name_colored = string.format("|cff%02x%02x%02x%s|r", class_color.r * 255, class_color.g * 255, class_color.b * 255, toon_name)
				local lvl_colored = level == 110 and string.format("|cff00FF00%s|r", level) or string.format("|cff969696%s|r", level)
				local zone_colored = GetRealZoneText() == zone and string.format("|cff00FF00%s|r", zone) or string.format("|cff969696%s|r", zone)
				GameTooltip:AddDoubleLine(full_name..status, game, 0, 1, 1, 0, 1, 1)
				GameTooltip:AddDoubleLine("   "..lvl_colored.." "..name_colored.." "..string.format("|cffC8C8C8%s|r", race), zone_colored, 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(full_name..status, game, 0, 1, 1, 0, 1, 1)
			end
		else
			break
		end
	end
	
	-- regular friends: <status> lvl name		zone
	local num_friends = GetNumFriends()
	if num_friends > 0 then GameTooltip:AddLine" " end
	for i = 1, num_friends do
		local name, level, class, zone, connected, status, _ = GetFriendInfo(i)
		if connected then
			for k,v in pairs(class_list) do if class == v then class = k end end
			local class_color = class_colors[class]
			local status = (status == "<AFK>" and "|cffFF0000<AFK>|r ") or (status == "<DND>" and "|cffFFFF00<DND>|r ") or ""
			local name_colored = string.format("|cff%02x%02x%02x%s|r", class_color.r*255, class_color.g*255, class_color.b*255, name)
			local lvl_colored = level == 85 and string.format("|cff00FF00%s|r", level) or string.format("|cff969696%s|r", level)
			local zone_colored = GetRealZoneText() == zone and string.format("|cff00FF00%s|r", zone) or string.format("|cff969696%s|r", zone)
			GameTooltip:AddDoubleLine(lvl_colored.." "..name_colored..status, zone_colored, 1, 1, 1, 1, 1, 1)
		else
			break
		end
	end
	GameTooltip:Show()
end

friend_frame:RegisterEvent"PLAYER_LOGIN"
friend_frame:RegisterEvent"FRIENDLIST_UPDATE"
friend_frame:RegisterEvent"BN_CONNECTED"
friend_frame:RegisterEvent"BN_FRIEND_ACCOUNT_ONLINE"
friend_frame:RegisterEvent"BN_FRIEND_ACCOUNT_OFFLINE"
friend_frame:RegisterEvent"BN_FRIEND_LIST_SIZE_CHANGED"

friend_frame:SetScript("OnEvent", function(self, event)
	local all_friends, online_friends = GetNumFriends()
	local all_bn_friends, online_bn_friends = BNGetNumFriends()
	friend_text:SetText(string.format("%d|c%sf|r", online_friends + online_bn_friends, cui.player.color_str))
	if friend_frame.ttopen then
		gen_friend_tt(friend_frame)
	end
end)
friend_frame:SetScript("OnEnter", gen_friend_tt)
friend_frame:SetScript("OnLeave", function(self)
	friend_frame.ttopen = false
	GameTooltip:Hide()
end)
friend_frame:SetScript("OnClick", function(_, button) if button == "LeftButton" then ToggleFriendsPanel() end end)

-- latency --------------

local net_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
net_text:SetPoint("BOTTOMLEFT", friend_text, "BOTTOMRIGHT", 5, 0)

local net_frame = CreateFrame("Frame", "CityNet", UIParent)
net_frame:SetAllPoints(net_text)
net_frame.last = 0

net_frame:RegisterEvent"PLAYER_LOGIN"
net_frame:SetScript("OnEvent", function(self, event)
	local _,_,home,world = GetNetStats()
	net_text:SetText(string.format("%s|c%sh|r %s|c%sw|r", home, cui.player.color_str, world, cui.player.color_str))
end)
net_frame:SetScript("OnUpdate", function(self, last)
	self.last = self.last + last
	if self.last >= 3 then
		local _,_,home,world = GetNetStats()
		net_text:SetText(string.format("%s|c%sh|r %s|c%sw|r", home, cui.player.color_str, world, cui.player.color_str))
		self.last = self.last - 3
	end
end)

-- framerate ------------

local fps_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
fps_text:SetPoint("BOTTOMLEFT", net_text, "BOTTOMRIGHT", 5, 0)

local fps_frame = CreateFrame("Frame", "CityFps", UIParent)
fps_frame:SetAllPoints(fps_text)
fps_frame.last = 0

fps_frame:RegisterEvent"PLAYER_LOGIN"
fps_frame:SetScript("OnEvent", function(self, event)
	local fps = GetFramerate()
	fps_text:SetText(string.format("%d|c%sfps|r", floor(fps), cui.player.color_str, "fps"))
end)
fps_frame:SetScript("OnUpdate", function(self, last)
	self.last = self.last + last
	if self.last >= .25 then
		self.last = self.last - .25
		local fps = GetFramerate()
		fps_text:SetText(string.format("%d|c%sfps|r", floor(fps), cui.player.color_str, "fps"))
	end
end)

-- gold -------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "CityStats" then
		if not CityRealmGold then CityRealmGold = {} end
		if not CityRealmGold[cui.player.realm] then CityRealmGold[cui.player.realm] = {} end
	end
end)

local format_gold = function(rawgold)
	return string.format("%d|c%sg|r", floor(rawgold * 0.0001), cui.player.color_str)
end

local gold_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
gold_text:SetPoint("BOTTOMRIGHT", data_parent, "BOTTOMRIGHT", -7, 5)

local gold_frame = CreateFrame("Button", "CityGold", UIParent)
gold_frame:SetAllPoints(gold_text)

gold_frame:RegisterEvent"PLAYER_LOGIN"
gold_frame:RegisterEvent"PLAYER_MONEY"
gold_frame:SetScript("OnEvent", function(self, event)
		local new_gold = GetMoney()
		gold_text:SetText(format_gold(new_gold))
		CityRealmGold[cui.player.realm][cui.player.name] = new_gold
	end
)
gold_frame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format("Gold on |c%s%s|r", cui.player.color_str, cui.player.realm), 1, 1, 1)
	GameTooltip:AddLine" "
	local sum = 0
	for player, gold in pairs(CityRealmGold[cui.player.realm]) do
		GameTooltip:AddDoubleLine(player, format_gold(gold), 1, 1, 1, 1, 1, 1)
		sum = sum + gold
	end
	GameTooltip:AddLine" "
	GameTooltip:AddDoubleLine("Total:", format_gold(sum), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end)
gold_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
gold_frame:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		ToggleCharacter"TokenFrame"
	end
end)


-- azerite -----------------

local azerite_text = cui.util.gen_string(data_parent, cui.config.font_size_med)
azerite_text:SetPoint("BOTTOMRIGHT", gold_text, "BOTTOMLEFT", -5, 0)

local azerite_frame = CreateFrame("Frame", "CityAzerite", UIParent)
azerite_frame:SetAllPoints(azerite_text)

azerite_frame:RegisterEvent"PLAYER_ENTERING_WORLD"
azerite_frame:RegisterEvent"AZERITE_ITEM_EXPERIENCE_CHANGED"

azerite_frame:SetScript("OnEvent", function(self, event)
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	
	if (not azeriteItemLocation) then
		return
	end
	
	self.xp, self.totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
	self.currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
	self.xpToNextLevel = self.totalLevelXP - self.xp;
	
	azerite_text:SetText(format("%s - %d|c%s%s|r", self.currentLevel, floor(100 * self.xp / self.totalLevelXP), cui.player.color_str, "%"))
end)

azerite_frame:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format("Level |c%s%d|r", cui.player.color_str, self.currentLevel), 1, 1, 1)
	GameTooltip:AddLine(format("%d / %d", self.xp, self.totalLevelXP), 1, 1, 1)
	GameTooltip:AddLine(format("|c%s%d|r to next level", cui.player.color_str, self.xpToNextLevel), 1, 1, 1)
	GameTooltip:AddLine" "

	-- reputations
	reps = {
		[2164] = "Champions",
		[2157] = "Honorbound",
		[2391] = "Rustbolt",
		[2163] = "Tortollan",
		[2373] = "Unshackled",
		[2158] = "Voldunai",
		[2103] = "Zandalari",
		[2156] = "Talanji's",
	}

	for id, name in pairs(reps) do
		if (C_Reputation.IsFactionParagon(id)) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(id);
			local value = currentValue % threshold;
			if ( hasRewardPending ) then 
				value = value + threshold;
			end
			
			GameTooltip:AddDoubleLine(name, format("|c%s%d / %d|r", cui.player.color_str, value, threshold), 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:Show()
end)

azerite_frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
