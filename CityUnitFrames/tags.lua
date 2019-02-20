local addon, cuf = ...
local cfg = cuf.cfg

local hex = function(r, g, b)
	if r then
		if (type(r) == 'table') then
			if (r.r) then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end
		return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
	end
end

local formatTime = function(rawTime)
	if rawTime > 60 then 
		endTime = math.floor(rawTime / 60)
	else 
		endTime = math.floor(rawTime)
	end
	return endTime
end

local numFormat = function(v)
	if (v >= 1e9) then
		return ("%.1fb"):format(v / 1e9)
	elseif (v >= 1e6) then
		return ("%.1fm"):format(v / 1e6)
	elseif (v >= 1e3) then
		return ("%.1fk"):format(v / 1e3)
	else
		return ("%d"):format(v)
	end
end

local alt_power_index = ALTERNATE_POWER_INDEX

oUF.Tags.Methods['city:role'] = function(u)
	local role = UnitGroupRolesAssigned(u)
	if role == "HEALER" then
		return "|cff8AFF30H|r"
	elseif role == "TANK" then
		return "|cff5F9BFFT|r"
	elseif role == "DAMAGER" then
		return "|cffFF6161D|r"
	end
end
oUF.Tags.Events['city:role'] = 'PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE'

oUF.Tags.Methods["city:info"] = function(unit) 
	local status
	if (UnitIsAFK(unit)) then
		status = "AFK "
	elseif (UnitIsDND(unit)) then
		status = "DND "
	end
	return status
end
oUF.Tags.Events["city:info"] = "PLAYER_ENTERING_WORLD PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods['city:color'] = function(unit)
	if not UnitIsConnected(unit) then
		return "|cff999999"
	end
	
	if (UnitIsPlayer(unit)) then
		return hex(oUF.colors.class[select(2, UnitClass(unit))])
	elseif (UnitIsTapDenied(unit)) then
		return hex(oUF.colors.tapped)
	else
		return hex(oUF.colors.reaction[UnitReaction(unit, "player")])
	end
end
oUF.Tags.Events['city:color'] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION UNIT_FACTION"

oUF.Tags.Methods["city:hplong"] = function(unit)

	local curr, max = UnitHealth(unit), UnitHealthMax(unit)

	local shortcurr = numFormat(curr)
	local shortmax = numFormat(max)
	
	local hp = shortcurr.."/"..shortmax
	
	if UnitIsDead(unit) then 
		hp = hp.." Dead"
	end
	
	if UnitIsGhost(unit) then
		hp = hp.." Ghost"
	end
	
	if not UnitIsConnected(unit) then
		hp = hp.." Off"
	end
	
	return hp
end
oUF.Tags.Events["city:hplong"] = "UNIT_HEALTH UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["city:bosshp"] = function(unit)

	if (UnitIsDead(unit) or UnitIsGhost(unit)) then 
		return "Dead"
	end
	
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local per = 0
	if max > 0 then
		per = floor(min / max * 100)
	end
	
	local shortmin = numFormat(min)
	local shortmax = numFormat(max)
	
	return shortmin.."/"..shortmax.."-"..per.."%"  
end
oUF.Tags.Events["city:bosshp"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Methods["city:shorthp"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local shortmin = numFormat(min)
	local shortmax = numFormat(max)
	return shortmin.."/"..shortmax
end
oUF.Tags.Events["city:shorthp"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Methods["city:currhp"] = function(unit)
	return numFormat(UnitHealth(unit))
end
oUF.Tags.Events["city:currhp"] = "UNIT_HEALTH UNIT_MAXHEALTH"

oUF.Tags.Methods["city:ppdefault"] = function(unit)
	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local per = 0
	if max > 0 then
		per = floor(min / max * 100)
	end
	local shortmin = numFormat(min)
	return shortmin.."-"..per.."%"
end
oUF.Tags.Events["city:ppdefault"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["city:pplongfrequent"] = function(unit)
	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local per = 0
	if max > 0 then
		per = floor(min / max * 100)
	end
	local shortmin = numFormat(min)
	return shortmin.."-"..per.."%"
end
oUF.Tags.Events["city:pplongfrequent"] = "UNIT_POWER_FREQUENT"

oUF.Tags.Methods["city:bosspp"] = function(unit)
	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local per = 0
	if max > 0 then
		per = floor(min / max * 100)
	end
	local shortmin = numFormat(min)
	return shortmin.."-"..per.."%"
end
oUF.Tags.Events["city:bosspp"] = "UNIT_POWER_FREQUENT"

oUF.Tags.Methods["city:shortpp"] = function(unit)
	return numFormat(UnitPower(unit))
end
oUF.Tags.Events["city:shortpp"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["city:shortppfrequent"] = function(unit)
	return numFormat(UnitPower(unit))
end
oUF.Tags.Events["city:shortppfrequent"] = "UNIT_POWER_FREQUENT"

oUF.Tags.Methods['city:altpower'] = function(unit)
	local cur = UnitPower(unit, alt_power_index)
	local max = UnitPowerMax(unit, alt_power_index)
	if(max > 0 and not UnitIsDeadOrGhost(unit)) then
		return ("%s%%"):format(math.floor(cur / max * 100 + .5))
	else
		return ""
	end
end
oUF.Tags.Events['city:altpower'] = 'UNIT_POWER_UPDATE'

oUF.Tags.Methods["city:hpraid"] = function(unit)
	if not UnitIsConnected(unit) then
		return "Off"
	end
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		return "Dead"
	end
	local heal_absorb = UnitGetTotalHealAbsorbs(unit) or 0
	if heal_absorb > 0 then return "|r"..hex(1, .25, .25)..numFormat(heal_absorb).."|r" end

	return ""
end
oUF.Tags.Events["city:hpraid"] = "UNIT_NAME_UPDATE UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION"
