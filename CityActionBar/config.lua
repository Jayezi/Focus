local addon, ns = ...
local cfg = {}
ns.cfg = cfg
local cui = CityUi

cfg.color = {
	pressed = {.3, .3, .3, .5},
	checked = {.5, .5, 0, .5},
	highlight = {.6, .6, .6, .3},
}

cfg.bars = {
	extra = {
		pos = {"TOP", "UIParent", "TOP", 0, -50}
	},
	zone = {
		pos = {"TOP", "UIParent", "TOP", 0, -50}
	},
	Action = {
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 5},
		visibility = "[petbattle] hide; show"
	},
	MultiBarBottomLeft = {
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 45},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	},
	MultiBarBottomRight = {
		rows = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 85},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	},
	MultiBarLeft = {
		rows = 2,
		buttons = {
			size = 60,
			margin = 2,
		},
		short = true,
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 200},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	},
	MultiBarRight = {
		rows = 2,
		buttons = {
			size = 60,
			margin = 2,
		},
		short = true,
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 284},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	},
	Stance = {
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "CityActionBar", "BOTTOMRIGHT", 5, 0},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; show"
	},
	Possess = {
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "CityActionBar", "TOPLEFT", 0, 5},
		visibility = "[possessbar] show; hide"
	},
	PetAction = {
		rows = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "CityMultiBarBottomRightBar", "TOPLEFT", 0, 5},
		visibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
    },
    MicroMenu = {
		enable = false,
		buttons = {
			size = 30,
			margin = 2,
			width_scale = .777
		},
		pos = {"BOTTOMRIGHT", "CityBagBar", "BOTTOMRIGHT", -5, 5},
		visibility = "[petbattle] hide; show"
    },
    Bag = {
		buttons = {
			size = 30,
			margin = 2,
		},
		pos = {"BOTTOMRIGHT", "CityMicroMenuBar", "BOTTOMLEFT", -10, 0},
		visibility = "[petbattle] hide; show"
    },
}
