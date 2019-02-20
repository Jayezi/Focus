--[[
City_Layouts = {
	"Holy" = {
		command = keybind,
		command2 = keybind2,
		command3 = keybind3,
	},
	"Ret" = {
		command = keybind,
		command2 = keybind2,
		command3 = keybind3,
	},
}
]]

local CityUi = CityUi

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "CityBinds" then
		if not CityBindLayouts then CityBindLayouts = {} end
		if not CityBindLayouts[CityUi.player.realm] then CityBindLayouts[CityUi.player.realm] = {} end
		if not CityBindLayouts[CityUi.player.realm][CityUi.player.name] then CityBindLayouts[CityUi.player.realm][CityUi.player.name] = {} end
	end
end)

local bar_list = {
	"MultiActionBar1",
	"MultiActionBar2",
	"MultiActionBar3",
	"MultiActionBar4",
}

local key_list = {"1","2","3","4","5","6","7","8","9","0","-","="}

local save_layout = function(name)
	for layout, _ in pairs(CityBindLayouts[CityUi.player.realm][CityUi.player.name]) do
		if layout == name then
			print("Already exists, overwriting.")
			break
		end
	end
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
	CityBindLayouts[CityUi.player.realm][CityUi.player.name][name] = new_layout
end

local load_layout = function(name)
	local new_layout = CityBindLayouts[CityUi.player.realm][CityUi.player.name][name]
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
				--SetBinding(key_list[i], "ActionButton"..i)
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
		print("Loaded layout: "..name)
	else
		print("No layout has been saved with that name.")
	end
end

local delete_layout = function(name)
	if CityBindLayouts[CityUi.player.realm][CityUi.player.name][name] then
		CityBindLayouts[CityUi.player.realm][CityUi.player.name][name] = nil
	else
		print("No layout has been saved with that name.")
	end
end

SLASH_CITYBINDS1 = "/cbinds"
local handle_command = function(arg, _)
	if arg == "list" then
		-- show all saved bindings
		print("Saved layouts:")
		for layout_name, _ in pairs(CityBindLayouts[CityUi.player.realm][CityUi.player.name]) do
			print(layout_name)
		end
	elseif arg:find("save") then
		local user_arg = arg:sub(5)
		if (user_arg) and (not (user_arg == "")) then
			save_layout(user_arg)
			print("Saved layout: "..user_arg)
		end
	elseif arg:find("load") then
		local user_arg = arg:sub(5)
		if (user_arg) and (not (user_arg == "")) then
			load_layout(user_arg)
		end
	elseif arg:find("delete") then
		local user_arg = arg:sub(7)
		if (user_arg) and (not (user_arg == "")) then
			delete_layout(user_arg)
			print("Deleted layout: "..user_arg)
		end
	else
		print("/cbinds list - list all saved layouts")
		print("/cbinds deleteName - deletes a layout with the Name directly following \"delete\" (no spaces)")
		print("/cbinds saveName - saves a layout with the Name directly following \"save\" (no spaces)")
		print("/cbinds loadName - loads a layout with the Name directly following \"load\" (no spaces)")
	end
end
SlashCmdList["CITYBINDS"] = handle_command
