local _, addon = ...
if not addon.binds.enabled then return end

local core = addon.core

local GetBindingKey = GetBindingKey
local SetBinding = SetBinding
local SaveBindings = SaveBindings
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

local bar_list = {
	"MULTIACTIONBAR1",
	"MULTIACTIONBAR2",
	"MULTIACTIONBAR3",
	"MULTIACTIONBAR4",
}

local default_action_bar = {
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true,
	["0"] = true,
	["-"] = true,
	["="] = true,
}

local load_layout = function(spec)
	local new_layout = FocusBindsLayouts[core.player.realm][core.player.name][spec]
	if new_layout then

		-- clears any existing binds
		for i = 1, 12 do
			local keys = {GetBindingKey("ACTIONBUTTON"..i)}
			for k = 1, #keys do
				SetBinding(keys[k])
			end
		end

		for _, bar in pairs(bar_list) do
			for i = 1, 12 do
				local keys = {GetBindingKey(bar.."BUTTON"..i)}
				for k = 1, #keys do
					SetBinding(keys[k])
				end
			end
		end

		for i = 1, 12 do
			if new_layout["ACTIONBUTTON"..i] then
				-- do the default number binds first so they show up on the buttons
				for k = 1, #new_layout["ACTIONBUTTON"..i] do
					if default_action_bar[new_layout["ACTIONBUTTON"..i][k]] then
						SetBinding(new_layout["ACTIONBUTTON"..i][k], "ACTIONBUTTON"..i)
					end
				end
				for k = 1, #new_layout["ACTIONBUTTON"..i] do
					if not default_action_bar[new_layout["ACTIONBUTTON"..i][k]] then
						SetBinding(new_layout["ACTIONBUTTON"..i][k], "ACTIONBUTTON"..i)
					end
				end
			end
		end
		
		for _, bar in pairs(bar_list) do
			for i = 1, 12 do
				local keys = {GetBindingKey(bar.."BUTTON"..i)}
				if new_layout[bar.."BUTTON"..i] then
					for k = 1, #new_layout[bar.."BUTTON"..i] do
						SetBinding(new_layout[bar.."BUTTON"..i][k], bar.."BUTTON"..i)
					end
				end
			end
		end
		
		SaveBindings(2)
		print("loaded "..spec.." binds")
	end
end

local save_layout = function()
	local _, spec = GetSpecializationInfo(GetSpecialization())
	local new_layout = {}
	for i = 1, 12 do
		new_layout["ACTIONBUTTON"..i] = {GetBindingKey("ACTIONBUTTON"..i)}
	end
	for _, bar in pairs(bar_list) do
		for i = 1, 12 do
			new_layout[bar.."BUTTON"..i] = {GetBindingKey(bar.."BUTTON"..i)}
		end
	end
	FocusBindsLayouts[core.player.realm][core.player.name][spec] = new_layout
	print("saved "..spec.." binds")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == "Focus" then
			if not FocusBindsLayouts then FocusBindsLayouts = {} end
			if not FocusBindsLayouts[core.player.realm] then FocusBindsLayouts[core.player.realm] = {} end
			if not FocusBindsLayouts[core.player.realm][core.player.name] then FocusBindsLayouts[core.player.realm][core.player.name] = {} end
		end
	elseif event == "PLAYER_LOGIN" then
		local _, spec = GetSpecializationInfo(GetSpecialization())
		load_layout(spec)
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" and not InCombatLockdown() and ... == "player" then
		local _, spec = GetSpecializationInfo(GetSpecialization())
		load_layout(spec)
	end
end)

core.settings:add_action("Save Binds", save_layout)
