local _, addon = ...
if not addon.units.enabled then return end
local core = addon.core
local oUF = addon.oUF

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
    tank =          false,
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
			size = {w = 500, h = 30},
			pos = {"TOP", UIParent, "TOP", 0, -10},
		},
		mark = {size = 40},
	},
	pet = {
		size = {w = 220, h = 30},
		power = {
			h = 8
		},
		mark = {size = 20},
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
		},
		mark = {size = 40},
	},
	targettarget = {
		size = {w = 220, h = 30},
	},
	focus = {
		size = {w = 260, h = 40},
		pos = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10},
		cast = {
			h = 30
		},
		mark = {size = 30},
	},
	tank = {
		size = {w = 110, h = 60},
		pos = {"TOPLEFT", UIParent, "TOPLEFT", 10, -10},
		power = {
			h = 8
		},
		mark = {size = 20},
	},
	party = {
		size = {w = 150, h = 60},
		pos = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10},
		power = {
			h = 8
		},
		indicators = indicators[core.player.class],
		mark = {size = 30},
	},
	raid = {
		size = {
			["minimal"] = {w = 94, h = 50},
			["detailed"] = {w = 124, h = 60},
		},
		pos = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10},
		power = {
			h = 8
		},
		indicators = indicators[core.player.class],
		mark = {size = 15},
	},
	boss = {
		size = {w = 300, h = 40},
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -10, -1},
		power = {
			h = 8
		},
		cast = {
			h = 25
		},
		mark = {size = 30},
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
		},
		alpha = {
			target = 1,
			non_target = 0.6
		},
		mark = {size = 30},
	},
}

cfg.auras = {
--	frame				size	rows	anchor			x-direction		y-direction		rowlimit	countsize	cdsize	cdposition		squashed
	player = 			{50,	1,		"BOTTOMRIGHT",	"LEFT",			"UP", 			false,		15,			20,		"CENTER",		false},
	boss = 				{46,	2, 		"TOPRIGHT", 	"LEFT", 		"DOWN",			3, 			15,			20,		"CENTER",		true},
	pet = 				{50,	1, 		"BOTTOMRIGHT", 	"LEFT",			"UP", 			false, 		15,			20,		"CENTER",		true},
	target_buff = 		{50,	3, 		"BOTTOMLEFT", 	"RIGHT",		"UP", 			false,		15,			15,		"CENTER",		true},
	target_debuff = 	{50,	1, 		"BOTTOMLEFT", 	"RIGHT", 		"UP", 			false,		15,			20,		"CENTER",		false},
	nameplate_debuff =	{58,	2, 		"TOPLEFT",		"RIGHT", 		"DOWN", 		3,			15,			20,		"CENTER",		true},
	nameplate_buff =	{58,	2, 		"TOPRIGHT", 	"LEFT",			"DOWN", 		3,			15,			20,		"CENTER",		true},
	tank = 				{22, 	1, 		"BOTTOMLEFT",	"RIGHT",		"DOWN", 		3,			10, 		10,		"CENTER",		false},
	focus = 			{40, 	1, 		"BOTTOMLEFT",	"RIGHT", 		"UP", 			false, 		10, 		15,		"CENTER",		true},
	party = 			{30, 	1, 		"TOPRIGHT",		"LEFT", 		"DOWN", 		4, 			12, 		12,		"CENTER",		false},
	-- raid
	minimal = 			{36, 	1, 		"TOPRIGHT",		"LEFT", 		"DOWN", 		2, 			10, 		12,		"BELOW_RIGHT",	true},
	detailed = 			{30, 	1, 		"TOPRIGHT",		"LEFT", 		"DOWN", 		3, 			12, 		12,		"CENTER",		false},
}

-- override color on specific units to help see them
cfg.nameplate_colors = {
	[120651] = {0.25, 0.75, 0.25},	-- Explosive
	[177891] = {0.75, 0.25, 0.75},	-- Mawforged Summoner
	[179963] = {0.75, 0.75, 0.25},	-- Terror Orb
	[184140] = {0.75, 0.75, 0.25},	-- Xy Acolyte
	[183033] = {0.75, 0.75, 0.25},	-- Grim Reflection
	[179733] = {0.75, 0.25, 0.75},  -- Invigorating Fish Stick
}

cfg.pet_buff_whitelist = {
	[136] = true,			-- Mend Pet
}

-- in addition to magic and enrage buffs, show these buffs on nameplates
cfg.nameplate_buff_whitelist = {
	[343502] = true,		-- Inspiring Presence
}

-- useless stuff that crowds enemy nameplate debuffs
cfg.nameplate_debuff_blacklist = {
	[356329] = true,		-- Scouring Touch (Shard of Dyz)
	[356372] = true,		-- Exsanguinated (Shard of Bek)

	[50285] = true,			-- Dust Cloud
	
	[269576] = true,		-- Master Marksman
	[257044] = true,		-- Rapid Fire

	[270339] = true,		-- Shrapnel Bomb
	--[270332] = true,		-- Pheramone Bomb
	[271049] = true,		-- Volatile Bomb
	[270343] = true,		-- Internal Bleeding

	[352939] = true,		-- Soulglow Spectrometer
	[353354] = true,		-- Dream Delver
}

-- track above player unitframe
cfg.player_buff_whitelist = {

	-- All
	[208431] = true,		-- Corruption: Descent into Madness
	[26297] = true,			-- Berserking
	[80353] = true,			-- Time Warp
	[2825] = true,			-- Bloodlust
	[32182] = true,			-- Heroism
	[90355] = true,			-- Ancient Hysteria
	[160452] = true,		-- Netherwinds
	[230935] = true,		-- Drums of the Mountain
	[178207] = true,		-- Drums of Fury
	[242584] = true,		-- Concordance of the Legionfall
	[208052] = true,		-- Sephuz's Secret
	[234143] = true,		-- Temptation
	[188024] = true,		-- Skystep Potion
	[287916] = true,		-- V.I.G.O.R Engaged
	[268311] = true,		-- Galecaller's Boon
	[279152] = true,		-- Battle Potion of Agility
	[268899] = true,		-- Masterful Navigation
	[268898] = true,		-- Masterful Navigation
	[274443] = true,		-- Dance of Death
	[303570] = true,		-- Razor Coral
	[315763] = true,		-- Void Titanshard
	[10060] = true,			-- Power Infusion
 
	-- Paladin
	[132403] = true,		-- Shield of the Righteous
	[1044] = true,			-- Blessing of Freedom
	[1022] = true,			-- Blessing of Protection
	[223819] = true,		-- Divine Purpose
	[200652] = true,		-- Tyr's Deliverance
	[31842] = true,			-- Avenging Wrath (Holy)
	[31884] = true,			-- Avenging Wrath (Ret, Prot)
	[31821] = true,			-- Aura Mastery
	[105809] = true,		-- Holy Avenger
	[642] = true,			-- Divine Shield
	[498] = true,			-- Divine Protection
	[211422] = true,		-- Knight of the Silver Hand
	[207589] = true,		-- Ilterendi, Crown Jewel of Silvermoon
	[234862] = true,		-- Maraad's Dying Breath

	-- Hunter
	[35079] = true,			-- Misdirect
	[193526] = true,		-- Trueshot
	[204090] = true,		-- Bullseye
	[193530] = true,		-- Aspect of the Wild
	[19574] = true,			-- Bestial Wrath
	[221796] = true,		-- Blood Frenzy
	[186289] = true,		-- Aspect of the Eagle
	[186265] = true,		-- Aspect of the Turtle
	[208913] = true,		-- Sentinels Sight
	[235712] = true,		-- Gyroscopic Stabilization
	[190515] = true,		-- Survival of the Fittest
	[266779] = true,		-- Coordinated Assault
	[259388] = true,		-- Mongoose Fury
	[260402] = true,		-- Double Tap
	[288613] = true,		-- Trueshot
	[269576] = true,		-- Master Marksman
	[257622] = true,		-- Trick Shots
	[272733] = true,		-- In The Rhythm
	[193534] = true,		-- Steady Focus
	[320224] = true,		-- Podtender
	[257946] = true,		-- Thrill of the Hunt
	[268877] = true,		-- Beast Cleave
	
	-- Monk
	[137639] = true, 		-- Storm, Earth, and Fire
	[215479] = true,		-- Ironskin Brew
	[119085] = true,		-- Chi Torpedo
	[235054] = true,		-- The Emperor's Capacitor
	[129914] = true,		-- Power Strikes
	[196741] = true,		-- Hit Combo

	-- Pet
	[118455] = true,		-- Beast Cleave
	[136] = true,			-- Mend Pet

	-- Death Knight
	[195181] = true,		-- Bone Shield
	[81256] = true,			-- Dancing Rune Weapon
	[55233] = true,			-- Vampiric Blood
	[48707] = true,			-- Anti-Magic Shell
	[116888] = true,		-- Shroud of Purgatory
	[235559] = true,		-- Haemostasis
	[48792] = true,			-- Icebound Fortitude
	[194679] = true,		-- Rune Tap
	[207256] = true,		-- Obliteration
	[196770] = true,		-- Remorseless Winter
	[51271] = true,			-- Pillar of Frost
	--[53365] = true,			-- Unholy Strength
}

-- important debuffs to track on minimal frames
cfg.debuff_whitelist = {

	-- Jailer
	[360281] = true,		-- Rune of Damnation
	[366703] = true,		-- Azerite Radiation
	[368591] = true,		-- Death Sentence
	[368592] = true,		-- Death Sentence
	[368593] = true,		-- Death Sentence

	-- test
	--[264689] = true,		-- Fatigued
	--[161918] = true,		-- Fiery Ground
}

-- things that aren't useful to track on larger frames that otherwise show all debuffs
cfg.debuff_blacklist = {

	[57724] = true,			-- Sated
	[57723] = true,			-- Exhaustion
	[80354] = true,			-- Temporal Displacement
	[95809] = true,			-- Insanity
	[25771] = true,			-- Forbearance
	[87024] = true,			-- Cauterized
	[41425] = true,			-- Hypothermia
	[108095] = true,		-- Recently Shapeshifted
	[11196] = true,			-- Recently Bandaged
	[95223] = true,			-- Recently Mass Resurrected
	[36032] = true,			-- Arcane Charge
	[6788] = true,			-- Weakened Soul
	[206151] = true,		-- Challenger's Burden
	[45181] = true,			-- Cheated Death
	[214648] = true,		-- Warlord's Exhaustion
	[113942] = true,		-- Demonic Gateway
	[234143] = true,		-- Temptation
	[43265] = true,			-- Death and Decay
	[211426] = true,		-- The Light Saves
	[245764] = true,		-- Essence of the Lifebinder
	[182496] = true,		-- Unbreakable Will
	[226802] = true,		-- Lord of Flames

	[253752] = true,		-- Sense of Dread
	[253753] = true,		-- Sense of Dread

	[243968] = true,		-- Torment of Flames
	[243980] = true,		-- Torment of Fel
	[243977] = true,		-- Torment of Frost

	[257215] = true,		-- Titanforged

	[195776] = true,		-- Moonfeather Fever

	[36893] = true,			-- Transporter Malfunction
	[36895] = true,			-- Transporter Malfunction
	[36897] = true,			-- Transporter Malfunction
	[36899] = true,			-- Transporter Malfunction

	[188409] = true,		-- Felflame Campfire

	[23445] = true,			-- Evil Twin
	[36900] = true,			-- Soul Split: Evil!

	[249224] = true,		-- Chaotic Flames
	[265206] = true,		-- Immunosuppression

	[287967] = true,		-- V.I.G.O.R Cooldown
	[284645] = true,		-- Topaz of Brilliant Sunlight
}
