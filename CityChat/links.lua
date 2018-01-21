local addon, ns = ...
local cfg = ns.cfg
local CityUi = CityUi

local make_link = function(url)
	return " |Hurl:"..url.."|h|cff"..cfg.link_color.."["..url.."]|r|h "
end

local parse_msg = function(frame, text, ...)
	text = string.gsub(text, cfg.url_pattern, make_link)
	frame.oldAddMessage(frame, text, ...)
end

for i = 1, NUM_CHAT_WINDOWS do
	if (i ~= 2) then
		local frame = _G["ChatFrame"..i]
		frame.oldAddMessage = frame.AddMessage
		frame.AddMessage = parse_msg
		frame:HookScript("OnHyperlinkClick", function(self, link, text, button, ...)
			local linktype, linkstring = link:match("(%a+):(.+)")
			if linktype == "url" then
				local edit = _G[frame:GetName().."EditBox"]
				if edit then
					edit:Show()
					edit:SetText(linkstring)
					edit:SetFocus()
					edit:HighlightText()
				end
			end
		end)
	end
end

local old = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
	if link:sub(0, 3) == "url" then
		return
	end
	return old(self, link, ...)
end
