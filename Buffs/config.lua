local _, addon = ...
if not addon.buffs.enabled then return end

local cfg = {}
addon.buffs.cfg = cfg

cfg.row_gap = 10
cfg.col_gap = 6
cfg.buttons_per_row = 15
cfg.button_size = 45
cfg.duration_pos = {"BOTTOM", 0, -4}
cfg.count_pos = {"TOPRIGHT", 4, 4}
