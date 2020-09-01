local addon, ns = ...
local cfg = {}
ns.cfg = cfg
local cui = CityUi

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
		cooldown_size = cui.config.font_size_med,
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 5},
	},
	MultiBarBottomLeft = {
		cooldown_size = cui.config.font_size_med,
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 45},
	},
	MultiBarBottomRight = {
		cooldown_size = cui.config.font_size_med,
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
		pos = {"BOTTOMLEFT", "CityActionBar", "BOTTOMRIGHT", 5, 0},
	},
	Possess = {
		buttons = {
			size = 30,
			margin = 5,
		},
		rows = 2,
		pos = {"BOTTOMRIGHT", "CityActionBar", "BOTTOMLEFT", -5, 0},
	},
	PetAction = {
		cooldown_size = cui.config.font_size_med,
		rows = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "CityMultiBarBottomRightBar", "TOPLEFT", 0, 5},
    },
}
