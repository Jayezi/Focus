local addon, ns = ...

local config = {}
ns.config = config
local CityUi = CityUi

oUF.colors.power['MANA'] = {46/255, 130/255, 215/255}
--oUF.colors.power['MANA'] = {46/255, 130/255, 215/255}

config.player_color = oUF.colors.class[CityUi.player.class]
config.altp_color = {.5, .5, .5, 1}
config.cast_non_interrupt_color = {.5, .2, .2, 1}
config.cast_interrupt_color = {.2, .5, .2, 1}

config.role = CityFrameRole[CityUi.player.realm][CityUi.player.name]

-- Primary unitframes (player, target mirrored across center).
config.primary_health_w, config.primary_health_h = 350, 35

-- Player castbar top relative to bottom, size.
config.player_cast_x, config.player_cast_y = 0, 480
config.player_cast_w, config.player_cast_h = 350, 28

-- Target castbar bottomright relative to target topright.
config.target_cast_x, config.target_cast_y = 0, 150
config.target_cast_w, config.target_cast_h = 500, 32

-- Non-movable secondary unitframes (pet, target of target mirrored across center)
config.secondary_health_w, config.secondary_health_h = 200, 25

-- Nameplates
config.nameplate_health_w, config.nameplate_health_h = 200, 15
config.nameplate_cast_h = 15

-- Experience bar top relative to top.
config.xp_x, config.xp_y = 0, -10
config.xp_w, config.xp_h = 500, 18

-- Defaults.
config.power_h = 8
config.cast_h = 25

-- Alpha for out of range frames.
config.oor_alpha = .4

-- Size of the unit's healthbar.
config.frame_sizes = {
	primary = {350, 35},
	secondary = {150, 25},
	focus = {300, 25},
	boss = {250, 25},
	tank = {110, 60},
	party = {110, 60},
	damager = {80, 50},
	healer = {105, 55},
}

config.frame_anchors = CityFrameList

config.aura_config = {
--	frame =				{size,	rows,	anchor, 		x-direction,	y-direction,	rowlimit,	countsize,	cdsize,	squashed}
	player = 			{48,	1,		"BOTTOMRIGHT",	"LEFT",			"UP", 			false,		15,			20,		false},
	boss = 				{50,	2, 		"TOPRIGHT", 	"LEFT", 		"DOWN",			2, 			15,			20,		true},
	pet = 				{48,	1, 		"BOTTOMRIGHT", 	"LEFT",			"UP", 			false, 		15,			20,		true},
	target_buff = 		{50,	3, 		"BOTTOMLEFT", 	"RIGHT",		"UP", 			false,		15,			15,		true},
	target_debuff = 	{50,	1, 		"BOTTOMLEFT", 	"RIGHT", 		"UP", 			false,		15,			20,		false},
	nameplate_debuff =	{50,	2, 		"TOPLEFT",		"RIGHT", 		"DOWN", 		3,			15,			20,		true},
	nameplate_buff =	{60,	1, 		"TOPRIGHT", 	"LEFT",			"DOWN", 		3,			15,			20,		true},
	tank = 				{22, 	1, 		"BOTTOMLEFT",	"RIGHT",		"DOWN", 		3,			10, 		10,		false},
	focus = 			{25, 	1, 		"BOTTOMRIGHT",	"LEFT", 		"UP", 			false, 		10, 		10,		false},
	party = 			{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		3, 			10, 		10,		false},
	healer = 			{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		3, 			10, 		10,		false},
	damager = 			{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		2, 			10, 		10,		false},
}

config.raid_marks = {
--  frame =         {anchor,        x offset,   y offset,   size}
    primary =		{"BOTTOM",      0,          0,          25},
    secondary =     {"TOPRIGHT",    -5,         -5,         20},
    boss =          {"TOP",         0,          0,          30},
    nameplate =     {"LEFT",        0,          0,          30},
    tank =          {"LEFT",        -50,        0,          25},
    focus =         {"TOP",         0,          0,          30},
    party =         {"LEFT",        0,          0,          15},
    raid =          {"TOP",     	0,          0,         	15},
}

config.raid_role = {"TOPLEFT", 3, -3, 10}

config.enabled = {
    player =        true,
    target =        true,
    nameplates =    true,
    tot =           true,
    pet =           true,
    focus =         true,
    boss =          true,
    party =         true,
    raid =          true,
    tank =          true,
}

config.nameplate_config = {
	["nameplateMinScale"] = 1,
	["nameplateMinScaleDistance"] = 10,
	["nameplateMaxScale"] = 1,
	["nameplateMaxScaleDistance"] = 90,
	["nameplateGlobalScale"] = 1,
	["nameplateMaxAlpha"] = .6,
	["nameplateMinAlpha"] = .6,
	["nameplateLargerScale"] = 1,
	["nameplateLargeBottomInset"] = -.01,
	["nameplateLargeTopInset"] = .03,
	["nameplateOtherBottomInset"] = -.01,
	["nameplateOtherTopInset"] = .03,
	["nameplateOverlapH"] = .5,
    ["nameplateOverlapV"] = .8,
	["nameplateSelectedAlpha"] = 1,
	["nameplateSelectedScale"] = 1,
	["nameplateSelfAlpha"] = 1,
	["nameplateSelfScale"] = 1,
	["nameplateSelfTopInset"] = 0,
	["nameplateSelfBottomInset"] = .4,
	["nameplateMaxDistance"] = 60,
    ["nameplateHorizontalScale"] = 1,
    ["nameplateVerticalScale"] = 1
}

local power_config = {
--  ["CLASS"] =         {center,    h,      flip,   tags}
	["HUNTER"] =        {true,      20,     true,	"[city:color][city:shortppfrequent]"},
	["DEATHKNIGHT"] =   {true,      20,     false,	"[city:color][city:shortppfrequent]"},
	["ROGUE"] =         {true,      20,     false,	"[city:color][city:shortppfrequent]"},
	["DEMONHUNTER"] =   {true,      20,     false,	"[city:color][city:shortppfrequent]"},
	["PALADIN"] =       {false,     8,      true,	"[city:color][city:pplongfrequent]"},
	["PRIEST"] =        {false,     8,      true,	"[city:color][city:pplongfrequent]"},
	["DRUID"] =         {false,     8,      false,	"[city:color][city:pplongfrequent]"},
	["SHAMAN"] =        {false,     8,      false,	"[city:color][city:pplongfrequent]"},
	["MAGE"] =          {false,     8,      false,	"[city:color][city:pplongfrequent]"},
	["MONK"] =          {true,      20,     false,	"[city:color][city:shortppfrequent]"},
	["WARRIOR"]	=       {true,      20,     false,	"[city:color][city:shortppfrequent]"},
}
config.player_power_config = power_config[CityUi.player.class]

local indicators = {
	--  ["xx"] = {spellId, {color}, "state/cd/count", castByPlayer, size}
	["PALADIN"] = {
		-- Beacon of Virtue
		["tr"] = {200025, {1, 1, .5}, "cd", true, 15},
		-- Beacon of Light
		["tl"] = {53563, {1, 1, .5}, "state", true, 12},
		-- Beacon of Faith
		["bl"] = {156910, {.5, .5, 1}, "state", true, 12},
		-- Blessing of Sacrifice
		["br"] = {6940, {1, .5, 1}, "cd", true, 15},
	}
}
config.indicators = indicators[CityUi.player.class]

config.buff_whitelist_pet = {
	[118455] = true,		--Beast Cleave
	[136] = true,			--Mend Pet
}

-- A Buff whitelist mainly usefull for tracking cd durations on the player frame.
config.buff_whitelist = {

	-- All
	[208431] = true,		--Corruption: Descent into Madness
	[26297] = true,			--Berserking
	[80353] = true,			--Time Warp
	[2825] = true,			--Bloodlust
	[32182] = true,			--Heroism
	[90355] = true,			--Ancient Hysteria
	[160452] = true,		--Netherwinds
	[230935] = true,		--Drums of the Mountain
	[178207] = true,		--Drums of Fury
	[242584] = true,		--Concordance of the Legionfall
	[208052] = true,		--Sephuz's Secret
	[234143] = true,		--Temptation
	[188024] = true,		--Skystep Potion

	-- Paladin
	[132403] = true,		--Shield of the Righteous
	[1044] = true,			--Blessing of Freedom
	[1022] = true,			--Blessing of Protection
	[223819] = true,		--Divine Purpose
	[200652] = true,		--Tyr's Deliverance
	[31842] = true,			--Avenging Wrath (Holy)
	[31884] = true,			--Avenging Wrath (Ret, Prot)
	[31821] = true,			--Aura Mastery
	[105809] = true,		--Holy Avenger
	[642] = true,			--Divine Shield
	[498] = true,			--Divine Protection
	[211422] = true,		--Knight of the Silver Hand
	[207589] = true,		--Ilterendi, Crown Jewel of Silvermoon
	[234862] = true,		--Maraad's Dying Breath

	-- Hunter
	[35079] = true,			--Misdirect
	[193526] = true,		--Trueshot
	[204090] = true,		--Bullseye
	[193530] = true,		--Aspect of the Wild
	[19574] = true,			--Bestial Wrath
	[221796] = true,		--Blood Frenzy
	[186289] = true,		--Aspect of the Eagle
	[186265] = true,		--Aspect of the Turtle
	[208913] = true,		--Sentinels Sight
	[235712] = true,		--Gyroscopic Stabilization
	[190515] = true,		--Survival of the Fittest
	[266779] = true,		--Coordinated Assault

	-- Monk
	[137639] = true, 		--Storm, Earth, and Fire
	[215479] = true,		--Ironskin Brew
	[119085] = true,		--Chi Torpedo
	[235054] = true,		--The Emperor's Capacitor
	[129914] = true,		--Power Strikes
	[196741] = true,		--Hit Combo

	-- Pet
	[118455] = true,		--Beast Cleave
	[136] = true,			--Mend Pet

	-- Death Knight
	[195181] = true,		--Bone Shield
	[81256] = true,			--Dancing Rune Weapon
	[55233] = true,			--Vampiric Blood
	[48707] = true,			--Anti-Magic Shell
	[116888] = true,		--Shroud of Purgatory
	[235559] = true,		--Haemostasis
	[48792] = true,			--Icebound Fortitude
	[194679] = true,		--Rune Tap
	[207256] = true,		--Obliteration
	[196770] = true,		--Remorseless Winter
	[51271] = true,			--Pillar of Frost
	[53365] = true,			--Unholy Strength
}

-- A debuff whitelist mainly useful for showing only select auras on small frames.
config.debuff_whitelist = {

	[116888] = true,		--Shroud of Purgatory
	[225080] = true,		--Reincarnation
	[255234] = true,		--Totemic Revival
	[221837] = true,		--Solitude
	[87023] = true,			--Cauterize
}

-- A debuff blacklist useful for keeping larger frames from getting too crowded but still generally showing all auras.
config.debuff_blacklist = {

	[57724] = true,			--Sated
	[57723] = true,			--Exhaustion
	[80354] = true,			--Temporal Displacement
	[95809] = true,			--Insanity
	[25771] = true,			--Forbearance
	[87024] = true,			--Cauterized
	[41425] = true,			--Hypothermia
	[108095] = true,		--Recently Shapeshifted
	[11196] = true,			--Recently Bandaged
	[95223] = true,			--Recently Mass Resurrected
	[36032] = true,			--Arcane Charge
	[6788] = true,			--Weakened Soul
	[206151] = true,		--Challenger's Burden
	[45181] = true,			--Cheated Death
	[214648] = true,		--Warlord's Exhaustion
	[113942] = true,		--Demonic Gateway
	[234143] = true,		--Temptation
	[43265] = true,			--Death and Decay
	[211426] = true,		--The Light Saves
	[245764] = true,		--Essence of the Lifebinder
	[182496] = true,		--Unbreakable Will
	[226802] = true,		--Lord of Flames

	[253752] = true,		--Sense of Dread
	[253753] = true,		--Sense of Dread

	[243968] = true,		--Torment of Flames
	[243980] = true,		--Torment of Fel
	[243977] = true,		--Torment of Frost

	[257215] = true,		--Titanforged

	[195776] = true,		--Moonfeather Fever

	[36893] = true,			--Transporter Malfunction
	[36895] = true,			--Transporter Malfunction
	[36897] = true,			--Transporter Malfunction
	[36899] = true,			--Transporter Malfunction

	[188409] = true,		--Felflame Campfire

	[23445] = true,			--Evil Twin
	[36900] = true,			--Soul Split: Evil!

	[249224] = true,		--Chaotic Flames
}
