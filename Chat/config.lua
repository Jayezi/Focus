local _, addon = ...
if not addon.chat.enabled then return end
local core = addon.core

local cfg = {}
addon.chat.cfg = cfg

cfg.selected_tab_color = core.player.color
cfg.not_selected_tab_color = {0.5, 0.5, 0.5}
cfg.link_color = "0099FF"
cfg.url_pattern = "([wWhH][wWtT][wWtT][%.pP]%S+[^%p%s])"
