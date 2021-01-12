local _, addon = ...
if not addon.units.enabled then return end
local core = addon.core

local cfg = {}
addon.units.cfg = cfg

local UIParent = UIParent

oUF.colors.power['MANA'] = {.15, .5, .85}

cfg.cast_non_interrupt_color = {.5, .2, .2, 1}
cfg.cast_interrupt_color = {.2, .5, .2, 1}
cfg.range_alpha = .5

cfg.enabled = {
    player =        true,
    target =        true,
    nameplates =    true,
    targettarget =  true,
    pet =           true,
    focus =         true,
    boss =          true,
    party =         true,
    raid =          true,
    tank =          true,
}

local powers = {
--	class				standalone		invert		tags
	["HUNTER"] =		{20,			true,		"[focus:color][focus:pp:curr]"},
	["DEATHKNIGHT"] =	{20,      		false,		"[focus:color][focus:pp:curr]"},
	["ROGUE"] =			{20,      		false,		"[focus:color][focus:pp:curr]"},
	["DEMONHUNTER"] =	{20,      		false,		"[focus:color][focus:pp:curr]"},
	["PALADIN"] =		{false,     	true,		"[focus:color][focus:pp:curr/max-perc]"},
	["PRIEST"] =		{false,     	true,		"[focus:color][focus:pp:curr/max-perc]"},
	["DRUID"] =			{false,     	false,		"[focus:color][focus:pp:curr/max-perc]"},
	["SHAMAN"] =		{false,     	false,		"[focus:color][focus:pp:curr/max-perc]"},
	["MAGE"] =			{false,     	false,		"[focus:color][focus:pp:curr/max-perc]"},
	["MONK"] =			{20,      		false,		"[focus:color][focus:pp:curr]"},
	["WARRIOR"]	=		{20,			false,		"[focus:color][focus:pp:curr]"},
}

local indicators = {
--	class = pos = spellId, color, "state/cd/count", castByPlayer, size
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

cfg.frames = {
	player = {
		size = {w = 350, h = 40},
		pos = {"TOPRIGHT", UIParent, "BOTTOM", -200, 400},
		cast = {
			size = {w = 350, h = 30},
			pos = {"BOTTOM", UIParent, "BOTTOM", 0, 460},
		},
		power = {
			cfg = powers[core.player.class],
			h = 8,
		},
		alt_power = {
			size = {w = 300, h = 20},
			pos = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10},
		},
	},
	pet = {
		size = {w = 220, h = 30},
		power = {
			h = 8
		}
	},
	target = {
		size = {w = 350, h = 40},
		pos = {"TOPLEFT", UIParent, "BOTTOM", 200, 400},
		cast = {
			size = {w = 500, h = 40},
			offset = {x = 0, y = 150},
		},
		power = {
			h = 8
		}
	},
	targettarget = {
		size = {w = 220, h = 30},
	},
	focus = {
		size = {w = 300, h = 35},
		pos = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10},
		cast = {
			h = 30
		},
	},
	tank = {
		size = {w = 110, h = 60},
		pos = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10},
		power = {
			h = 8
		},
	},
	party = {
		size = {w = 110, h = 60},
		pos = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10},
		power = {
			h = 8
		},
		indicators = indicators[core.player.class]
	},
	raid = {
		size = {
			dps = {w = 80, h = 50},
			healer = {w = 105, h = 55},
		},
		pos = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10},
		power = {
			h = 8
		},
		indicators = indicators[core.player.class]
	},
	boss = {
		size = {w = 300, h = 40},
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -10, -1},
		power = {
			h = 8
		},
		cast = {
			h = 25
		}
	},
	nameplate = {
		size = {
			w = 250,
			h = 20
		},
		cast = {
			h = 12
		},
		power = {
			h = 4
		}
	},
}

cfg.auras = {
--	frame				size	rows	anchor			x-direction		y-direction		rowlimit	countsize	cdsize	squashed
	player = 			{50,	1,		"BOTTOMRIGHT",	"LEFT",			"UP", 			false,		15,			20,		false},
	boss = 				{46,	2, 		"TOPRIGHT", 	"LEFT", 		"DOWN",			3, 			15,			20,		true},
	pet = 				{50,	1, 		"BOTTOMRIGHT", 	"LEFT",			"UP", 			false, 		15,			20,		true},
	target_buff = 		{50,	3, 		"BOTTOMLEFT", 	"RIGHT",		"UP", 			false,		15,			15,		true},
	target_debuff = 	{50,	1, 		"BOTTOMLEFT", 	"RIGHT", 		"UP", 			false,		15,			20,		false},
	nameplate_debuff =	{58,	2, 		"TOPLEFT",		"RIGHT", 		"DOWN", 		3,			15,			20,		true},
	nameplate_buff =	{58,	2, 		"TOPRIGHT", 	"LEFT",			"DOWN", 		3,			15,			20,		true},
	tank = 				{22, 	1, 		"BOTTOMLEFT",	"RIGHT",		"DOWN", 		3,			10, 		10,		false},
	focus = 			{40, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"UP", 			false, 		10, 		15,		true},
	party = 			{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		3, 			10, 		10,		false},
	healer = 			{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		3, 			10, 		10,		false},
	dps = 				{25, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"DOWN", 		2, 			10, 		10,		false},
}

cfg.raid_marks = {
--  frame			anchor			x offset	y offset	size
    primary =		{"BOTTOM",      0,          0,          25},
    secondary =     {"TOPRIGHT",    -5,         -5,         20},
    boss =          {"TOP",         0,          0,          30},
    nameplate =     {"LEFT",        0,          0,          30},
    tank =          {"LEFT",        -50,        0,          25},
    focus =         {"TOP",         0,          0,          30},
    party =         {"LEFT",        0,          0,          15},
    raid =          {"TOP",     	0,          0,         	15},
}

cfg.raid_role = {
	point = "TOPLEFT",
	x = 3,
	y = -3,
	size = 10
}

cfg.nameplate_cfg = {
	["nameplateMotion"] = 1,
	["nameplateMinScale"] = 1,
	["nameplateMinScaleDistance"] = 10,
	["nameplateMaxScale"] = 1,
	["nameplateMaxScaleDistance"] = 90,
	["nameplateGlobalScale"] = 1,
	["nameplateMaxAlpha"] = 0.6,
	["nameplateMinAlpha"] = 0.6,
	["nameplateLargerScale"] = 1,
	["nameplateLargeBottomInset"] = -.01,
	["nameplateLargeTopInset"] = .03,
	["nameplateOtherBottomInset"] = -.01,
	["nameplateOtherTopInset"] = .03,
	["nameplateOverlapH"] = 0.5,
    ["nameplateOverlapV"] = 0.8,
	["nameplateSelectedAlpha"] = 1,
	["nameplateSelectedScale"] = 1,
	["nameplateSelfAlpha"] = 1,
	["nameplateSelfScale"] = 1,
	["nameplateSelfTopInset"] = 0,
	["nameplateSelfBottomInset"] = .4,
	["nameplateMaxDistance"] = 60,
    ["nameplateHorizontalScale"] = 1,
	["nameplateVerticalScale"] = 1,
	["nameplateOccludedAlphaMult"] = 0.2
}

-- override color on specific units to help see them
cfg.nameplate_colors = {
	[175992] = {1, 0.25, 1},
	[169924] = {1, 0.25, 1},
}

cfg.pet_buff_whitelist = {
	[136] = true,			--Mend Pet
}

cfg.nameplate_buff_whitelist = {
	[277242] = true,		--Symbiote of G'huun
	[288219] = true,		--Refractive Ice
	[300635] = true,		--Gathering Nightmare
}

cfg.player_buff_whitelist = {

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
	[287916] = true,		--V.I.G.O.R Engaged
	[268311] = true,		--Galecaller's Boon
	[279152] = true,		--Battle Potion of Agility
	[268899] = true,		--Masterful Navigation
	[268898] = true,		--Masterful Navigation
	[274443] = true,		--Dance of Death
	[303570] = true,		--Razor Coral
	[315763] = true,		--Void Titanshard

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
	[259388] = true,		--Mongoose Fury
	[260402] = true,		--Double Tap
	[288613] = true,		--Trueshot
	[269576] = true,		--Master Marksman
	[257622] = true,		--Trick Shots
	[272733] = true,		--In The Rhythm
	[193534] = true,		--Steady Shot
	
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
cfg.debuff_whitelist = {

	[116888] = true,		--Shroud of Purgatory
	[225080] = true,		--Reincarnation
	[255234] = true,		--Totemic Revival
	[221837] = true,		--Solitude
	[87023] = true,			--Cauterize
}

-- A debuff blacklist useful for keeping larger frames from getting too crowded but still generally showing all auras.
cfg.debuff_blacklist = {

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
	[265206] = true,		--Immunosuppression

	[287967] = true,		--V.I.G.O.R Cooldown
	[284645] = true,		--Topaz of Brilliant Sunlight
}
