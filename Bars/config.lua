local _, addon = ...
if not addon.bars.enabled then return end
local core = addon.core

local cfg = {}
addon.bars.cfg = cfg

cfg.color = {
	pressed = {.3, .3, .3, .5},
	checked = {.5, .5, 0, .5},
	new = {.7, .7, 0, .7},
	highlight = {.6, .6, .6, .3},
	flash = {.5, .5, .5, .5}
}

cfg.bars = {
	extra = {
		pos = {"LEFT", "UIParent", "LEFT", 50, 0}
	},
	zone = {
		pos = {"TOP", "UIParent", "TOP", 0, -50}
	},
    bag = {
		buttons = {
			size = 32,
			margin = 2,
		},
		pos = {"BOTTOMRIGHT", "CharacterMicroButton", "BOTTOMLEFT", -10, 2},
    },
	Action = {
		cooldown_size = core.config.font_size_med,
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 5},
	},
	MultiBarBottomLeft = {
		cooldown_size = core.config.font_size_med,
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 45},
	},
	MultiBarBottomRight = {
		cooldown_size = core.config.font_size_med,
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 85},
	},
	MultiBarLeft = {
		rows = 2,
		buttons = {
			size = 60,
			height = 40,
			margin = 2,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 200},
	},
	MultiBarRight = {
		rows = 2,
		buttons = {
			size = 60,
			height = 40,
			margin = 2,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 284},
	},
	Stance = {
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "FocusBarsActionBar", "BOTTOMRIGHT", 5, 0},
	},
	Possess = {
		buttons = {
			size = 30,
			margin = 5,
		},
		rows = 2,
		pos = {"BOTTOMRIGHT", "FocusBarsActionBar", "BOTTOMLEFT", -5, 0},
	},
	PetAction = {
		cooldown_size = core.config.font_size_med,
		rows = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "FocusBarsMultiBarBottomRightBar", "TOPLEFT", 0, 5},
    },
}
