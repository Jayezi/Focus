local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core

local cfg = {}
addon.bars.cfg = cfg

cfg.bars = {
	bag = {
		buttons = {
			size = 32,
			margin = 2,
		},
    },
	Action = {
		cooldown_size = core.config.font_size_med,
		buttons = {
			size = 36,
			margin = 4,
		},
	},
	MultiBarBottomLeft = {
		cooldown_size = core.config.font_size_med,
		buttons = {
			size = 36,
			margin = 4,
		},
	},
	MultiBarBottomRight = {
		cooldown_size = core.config.font_size_med,
		buttons = {
			size = 36,
			margin = 4,
		},
	},
	MultiBarLeft = {
		buttons = {
			size = 60,
			height = 40,
			margin = 2,
		},
	},
	MultiBarRight = {
		buttons = {
			size = 60,
			height = 40,
			margin = 2,
		},
	},
	Stance = {
		buttons = {
			size = 30,
			margin = 4,
		},
	},
	Possess = {
		buttons = {
			size = 30,
			margin = 4,
		},
	},
	PetAction = {
		cooldown_size = core.config.font_size_med,
		buttons = {
			size = 30,
			margin = 4,
		},
    },
}
