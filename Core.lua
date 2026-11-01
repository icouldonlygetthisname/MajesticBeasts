local addonName, ns = ...

local PREFIX = "|cff33ff99Majestic Beasts|r: "
local ARRIVE_YARDS = 15

local defaults = {
	pins = true,
	alert = true,
}

function ns.Print(msg)
	print(PREFIX .. msg)
end

function ns.FormatCoords(beast)
	return ("%.1f, %.1f"):format(beast.x, beast.y)
end

function ns.GetLureName(beast)
	return C_Item.GetItemNameByID(beast.lureID) or beast.lureName
end

function ns.GetLureIcon(beast)
	return C_Item.GetItemIconByID(beast.lureID) or 134400
end

function ns.GetLureCount(beast)
	return C_Item.GetItemCount(beast.lureID) or 0
end

-- True once the beast has been killed today; resets with the daily reset.
function ns.IsBeastDone(beast)
	return C_QuestLog.IsQuestFlaggedCompleted(beast.questID) or false
end

function ns.GetAvailabilityText(beast)
	return ns.IsBeastDone(beast) and "|cffff5555Done today|r" or "|cff55ff55Available|r"
end

-- Seconds left on the lure's own cooldown, or 0 when it is ready/unknown.
function ns.GetLureCooldown(beast)
	local start, duration = C_Container.GetItemCooldown(beast.lureID)
	if not start or not duration or start == 0 or duration <= 1.5 then
		return 0
	end
	return math.max(0, start + duration - GetTime())
end

ns.SKINNING = 393

local function IsSkinning(index)
	return index and select(7, GetProfessionInfo(index)) == ns.SKINNING
end

function ns.HasSkinning()
	local prof1, prof2 = GetProfessions()
	return IsSkinning(prof1) or IsSkinning(prof2) or false
end

-- Lure spots never move, so their world positions are looked up once.
local beastWorld = {}
local function GetBeastWorldPos(beast)
	local cached = beastWorld[beast]
	if not cached then
		local continent, pos = C_Map.GetWorldPosFromMapPos(beast.mapID, CreateVector2D(beast.x / 100, beast.y / 100))
		if not pos then return end
		cached = { continent = continent, pos = pos }
		beastWorld[beast] = cached
	end
	return cached.continent, cached.pos
end

-- Nil when the player has no position (instances).
local function GetPlayerWorldPos()
	local playerMap = C_Map.GetBestMapForUnit("player")
	if not playerMap then return end
	local playerPos = C_Map.GetPlayerMapPosition(playerMap, "player")
	if not playerPos then return end
	return C_Map.GetWorldPosFromMapPos(playerMap, playerPos)
end

local function DistanceFrom(pContinent, pWorld, beast)
	local bContinent, bWorld = GetBeastWorldPos(beast)
	if not pWorld or not bWorld or pContinent ~= bContinent then return end
	local dx, dy = pWorld.x - bWorld.x, pWorld.y - bWorld.y
	return math.sqrt(dx * dx + dy * dy)
end

-- Distance in yards from the player to the lure spot, nil when the player
-- is on another continent or has no position (instances).
function ns.GetDistance(beast)
	local pContinent, pWorld = GetPlayerWorldPos()
	return DistanceFrom(pContinent, pWorld, beast)
end

function ns.SetWaypoint(beast, quiet)
	local title = ("%s (%s)"):format(beast.beast, ns.GetLureName(beast))
	local x, y = beast.x / 100, beast.y / 100
	if TomTom and TomTom.AddWaypoint then
		TomTom:AddWaypoint(beast.mapID, x, y, { title = title, from = addonName })
	elseif C_Map.CanSetUserWaypointOnMap(beast.mapID) then
		C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(beast.mapID, x, y))
		C_SuperTrack.SetSuperTrackedUserWaypoint(true)
	else
		ns.Print("Can't set a waypoint in " .. beast.zone .. " from here.")
		return
	end
	if not quiet then
		ns.Print(("Waypoint set: %s - %s %s"):format(title, beast.zone, ns.FormatCoords(beast)))
	end
end

-- One-shot chat alert when the player walks onto a lure spot.
local arrived = {}
local function CheckArrival()
	if UnitOnTaxi("player") then return end
	local pContinent, pWorld = GetPlayerWorldPos()
	for i, beast in ipairs(ns.BEASTS) do
		local distance = DistanceFrom(pContinent, pWorld, beast)
		local near = distance and distance <= ARRIVE_YARDS and not ns.IsBeastDone(beast)
		if near and not arrived[i] then
			local msg = ("You're at the %s spot."):format(beast.beast)
			if IsMounted() then
				msg = msg .. " Dismount - Sixth Sense doesn't show while mounted."
			else
				msg = msg .. " Wait for the Sixth Sense debuff, then use your " .. ns.GetLureName(beast) .. "."
			end
			ns.Print(msg)
			PlaySound(SOUNDKIT.RAID_WARNING)
		end
		arrived[i] = near or nil
	end
end

-- The alert only runs on characters with Skinning, and only while enabled.
local ticker
local function UpdateArrivalTicker()
	local wanted = MajesticBeastsDB.alert and ns.HasSkinning()
	if wanted and not ticker then
		ticker = C_Timer.NewTicker(1, CheckArrival)
	elseif not wanted and ticker then
		ticker:Cancel()
		ticker = nil
		wipe(arrived)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
	if event == "ADDON_LOADED" then
		if name ~= addonName then return end
		self:UnregisterEvent("ADDON_LOADED")

		MajesticBeastsDB = MajesticBeastsDB or {}
		for key, value in pairs(defaults) do
			if MajesticBeastsDB[key] == nil then
				MajesticBeastsDB[key] = value
			end
		end

		-- Prime the item cache so lure names and icons are localized.
		for _, beast in ipairs(ns.BEASTS) do
			C_Item.RequestLoadItemDataByID(beast.lureID)
		end

		-- Profession info isn't reliable until login; SKILL_LINES_CHANGED
		-- covers learning or dropping Skinning later.
		self:RegisterEvent("PLAYER_LOGIN")
		self:RegisterEvent("SKILL_LINES_CHANGED")
	else
		UpdateArrivalTicker()
	end
end)

SLASH_MAJESTICBEASTS1 = "/majestic"
SLASH_MAJESTICBEASTS2 = "/mbeasts"
SlashCmdList.MAJESTICBEASTS = function(msg)
	msg = strtrim(msg or ""):lower()
	if msg == "pins" then
		MajesticBeastsDB.pins = not MajesticBeastsDB.pins
		ns.RefreshPins()
		ns.Print("World map pins " .. (MajesticBeastsDB.pins and "shown." or "hidden."))
	elseif msg == "alert" then
		MajesticBeastsDB.alert = not MajesticBeastsDB.alert
		UpdateArrivalTicker()
		local suffix = MajesticBeastsDB.alert and not ns.HasSkinning() and " (inactive - this character has no Skinning)" or ""
		ns.Print("Arrival alert " .. (MajesticBeastsDB.alert and "on" or "off") .. suffix .. ".")
	elseif msg == "status" then
		local available = 0
		for _, beast in ipairs(ns.BEASTS) do
			if not ns.IsBeastDone(beast) then
				available = available + 1
			end
			ns.Print(("%s (%s): %s"):format(beast.beast, beast.zone, ns.GetAvailabilityText(beast)))
		end
		ns.Print(("%d of %d beasts available today."):format(available, #ns.BEASTS))
	elseif msg == "list" then
		for _, beast in ipairs(ns.BEASTS) do
			ns.Print(("%s - %s %s (%s)"):format(beast.beast, beast.zone, ns.FormatCoords(beast), ns.GetLureName(beast)))
		end
	elseif msg == "" then
		ns.ToggleWindow()
	else
		ns.Print("/majestic - toggle the window")
		ns.Print("/majestic status - print which beasts are still available today")
		ns.Print("/majestic list - print all lure spots to chat")
		ns.Print("/majestic pins - toggle world map pins")
		ns.Print("/majestic alert - toggle the arrival alert")
	end
end

function MajesticBeasts_OnAddonCompartmentClick()
	ns.ToggleWindow()
end
