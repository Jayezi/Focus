local addon, cuf = ...
local cfg = cuf.cfg

local alt_power_index = ALTERNATE_POWER_INDEX

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
		endTime = math.math.floor(rawTime / 60)
	else 
		endTime = math.math.floor(rawTime)
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

-- misc

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

oUF.Tags.Methods["city:status"] = function(unit)
	if not UnitIsConnected(unit) then return "OFF " end
	local status = ""
	if UnitIsAFK(unit) then status = status.."AFK " end
	if UnitIsDND(unit) then status = status.."DND " end
	return status
end
oUF.Tags.Events["city:status"] = "PLAYER_ENTERING_WORLD PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods['city:color'] = function(unit)
	if not UnitIsConnected(unit) then
		return hex(oUF.colors.tapped)
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

-- health

oUF.Tags.Methods["city:hp:curr/max state"] = function(unit)
	local curr, max = UnitHealth(unit), UnitHealthMax(unit)

	local shortcurr = numFormat(curr)
	local shortmax = numFormat(max)
	
	local str = shortcurr.."/"..shortmax
	
	if UnitIsDead(unit) then 
		str = str.." Dead"
	end
	
	if UnitIsGhost(unit) then
		str = str.." Ghost"
	end
	
	return str
end
oUF.Tags.Events["city:hp:curr/max state"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["city:hp:curr-perc"] = function(unit)
	local curr, max = UnitHealth(unit), UnitHealthMax(unit)
	local perc = 0
	if max > 0 then
		perc = math.floor(UnitHealth(unit) / max * 100 + 0.5)
	end

	local str = numFormat(curr).."-"..perc.."%"
	
	return str
end
oUF.Tags.Events["city:hp:curr-perc"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["city:hp:perc"] = function(unit)
	local max = UnitHealthMax(unit)
	local str = 0
	if max > 0 then
		str = math.floor(UnitHealth(unit) / max * 100 + 0.5)
	end
	
	return str
end
oUF.Tags.Events["city:hp:perc"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"

oUF.Tags.Methods["city:hp:perc."] = function(unit)
	local max = UnitHealthMax(unit)
	local str = 0
	if max > 0 then
		local perc = UnitHealth(unit) / max * 100
		if perc < 10 then
			str = ("%.1f"):format(perc)
		else
			str = math.floor(perc + 0.5)
		end
	end
	
	return str
end
oUF.Tags.Events["city:hp:perc."] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"

oUF.Tags.Methods["city:hp:curr"] = function(unit)
	return numFormat(UnitHealth(unit))
end
oUF.Tags.Events["city:hp:curr"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"

oUF.Tags.Methods["city:hp:group"] = function(unit)
	if not UnitIsConnected(unit) then return "OFF" end
	if UnitIsDeadOrGhost(unit) then return "Dead" end
	if UnitIsAFK(unit) then return "AFK" end

	local heal_absorb = UnitGetTotalHealAbsorbs(unit)
	if heal_absorb > 0 then
		return hex(1, .25, .25)..numFormat(heal_absorb)
	end

	return ""
end
oUF.Tags.Events["city:hp:group"] = "UNIT_NAME_UPDATE UNIT_ABSORB_AMOUNT_CHANGED UNIT_HEAL_ABSORB_AMOUNT_CHANGED UNIT_CONNECTION"

-- power

oUF.Tags.Methods["city:pp:curr/max-perc"] = function(unit)
	local curr, max = UnitPower(unit), UnitPowerMax(unit)
	local per = 0
	if max > 0 then
		per = math.floor(curr / max * 100 + 0.5)
	end
	return numFormat(curr).."/"..numFormat(max).."-"..per.."%"
end
oUF.Tags.Events["city:pp:curr/max-perc"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["city:pp:curr-perc"] = function(unit)
	local curr, max = UnitPower(unit), UnitPowerMax(unit)
	local per = 0
	if max > 0 then
		per = math.floor(curr / max * 100 + 0.5)
	end
	return numFormat(curr).."-"..per.."%"
end
oUF.Tags.Events["city:pp:curr-perc"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

oUF.Tags.Methods["city:pp:curr"] = function(unit)
	return numFormat(UnitPower(unit))
end
oUF.Tags.Events["city:pp:curr"] = "UNIT_POWER_FREQUENT"

-- alternative power

oUF.Tags.Methods["city:altp:perc"] = function(unit)
	local max = UnitPowerMax(unit, alt_power_index)
	local str = ""
	if max > 0 then
		str = math.floor(UnitPower(unit, alt_power_index) / max * 100 + 0.5)
	end
	return str
end
oUF.Tags.Events["city:altp:perc"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"
