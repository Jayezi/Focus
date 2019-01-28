local addon, ns = ...
local cfg = {}
ns.cfg = cfg

cfg.color = {
	pressed = {.3, .3, .3, .5},
	checked = {.5, .5, 0, .5},
	highlight = {.6, .6, .6, .3},
}

cfg.bars = {
	main = {
		scale = 1,
		pos = {"TOP", UIParent, "BOTTOM", 0, -200}
	},
	vehicle = {
		size = 50,
		pos = {"LEFT", UIParent, "LEFT", 5, 0}
	},
	extra = {
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 125}
	},
	zone = {
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 125}
	},
	ActionButton = {
		rows = 1,
		scale = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 5},
	},
	MultiBarBottomLeftButton = {
		rows = 1,
		scale = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 45},
	},
	MultiBarBottomRightButton = {
		rows = 1,
		scale = 1,
		buttons = {
			size = 35,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 85},
	},
	MultiBarLeftButton = {
		rows = 2,
		scale = 1,
		buttons = {
			size = 60,
			margin = 2,
		},
		short = true,
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 200},
	},
	MultiBarRightButton = {
		rows = 2,
		scale = 1,
		buttons = {
			size = 60,
			margin = 2,
		},
		short = true,
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 284},
	},
	stance = {
		scale = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 125},
	},
	possess = {
		scale = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 160},
	},
	pet = {
		rows = 2,
		scale = 1,
		buttons = {
			size = 30,
			margin = 5,
		},
		pos = {"BOTTOMLEFT", "UIParent", "BOTTOM", 300, 5},
    },
    menu = {
		enable = false,
		scale = 1,
		buttons = {
			size = 50
		},
		pos = {"TOP", "UIParent", "TOP"},
    },
    bag = {
		scale = 1,
		pos = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 470, 5},
    },
}
