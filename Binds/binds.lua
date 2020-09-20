local _, addon = ...
local core = addon.core

local GetBindingKey = GetBindingKey
local SetBinding = SetBinding
local SaveBindings = SaveBindings
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local CreateFrame = CreateFrame

local bar_list = {
	"MultiActionBar1",
	"MultiActionBar2",
	"MultiActionBar3",
	"MultiActionBar4",
}

local key_list = {"1","2","3","4","5","6","7","8","9","0","-","="}

local load_layout = function(spec)
	local new_layout = FocusBindsLayouts[core.player.realm][core.player.name][spec]
	if new_layout then
		-- clears any existing binds if there are no new ones in the new layout
		
		-- do main action bar separate to preserve 1 through =
		for i = 1, 12 do
			--clears the non default binds
			local keys = {GetBindingKey("ActionButton"..i)}
			for k = 1, #keys do
				if not (keys[k] == key_list[i]) then
					SetBinding(keys[k])
				end
			end
			if new_layout["ActionButton"..i] then
				SetBinding(new_layout["ActionButton"..i], "ActionButton"..i)
			end
		end
		
		for _, bar in pairs(bar_list) do
			for i = 1, 12 do
				local keys = {GetBindingKey(bar.."Button"..i)}
				for k = 1, #keys do SetBinding(keys[k]) end
				if new_layout[bar.."Button"..i] then
					SetBinding(new_layout[bar.."Button"..i], bar.."Button"..i)
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
	-- do this separate since the first key defaults to 1 through =
	for i = 1, 12 do
		_, new_layout["ActionButton"..i] = GetBindingKey("ActionButton"..i)
	end
	for _, bar in pairs(bar_list) do
		for i = 1, 12 do
			new_layout[bar.."Button"..i] = GetBindingKey(bar.."Button"..i)
		end
	end
	FocusBindsLayouts[core.player.realm][core.player.name][spec] = new_layout
	print("saved "..spec.." binds")
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Focus" then
			if not FocusBindsLayouts then FocusBindsLayouts = {} end
			if not FocusBindsLayouts[core.player.realm] then FocusBindsLayouts[core.player.realm] = {} end
			if not FocusBindsLayouts[core.player.realm][core.player.name] then FocusBindsLayouts[core.player.realm][core.player.name] = {} end
		end
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local _, spec = GetSpecializationInfo(GetSpecialization())
		load_layout(spec)
	end
end)

core.settings:add_action("Save Binds", save_layout)
