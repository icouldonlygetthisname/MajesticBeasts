local _, ns = ...

local ROW_HEIGHT = 44
local WIDTH = 540
local CRAFT_WIDTH = 58

local window

local function FormatDuration(seconds)
	if seconds >= 3600 then
		return ("%dh %dm"):format(seconds / 3600, (seconds % 3600) / 60)
	end
	return ("%dm"):format(math.ceil(seconds / 60))
end

local function UpdateRow(row)
	local beast = row.beast
	row.icon:SetTexture(ns.GetLureIcon(beast))
	row.lure:SetText(ns.GetLureName(beast))

	local count = ns.GetLureCount(beast)
	row.count:SetText(count > 0 and count or "")
	row.icon:SetDesaturated(count == 0)

	local status
	local cooldown = ns.GetLureCooldown(beast)
	local distance = ns.GetDistance(beast)
	if ns.IsBeastDone(beast) then
		status = ns.GetAvailabilityText(beast)
	elseif cooldown > 0 then
		status = "|cffff5555Lure ready in " .. FormatDuration(cooldown) .. "|r"
	elseif distance and distance <= 15 then
		status = "|cff55ff55You are here|r"
	else
		status = ns.GetAvailabilityText(beast)
		if distance then
			status = status .. (" - %d yds"):format(distance)
		elseif count == 0 then
			status = status .. " |cff888888(no lure)|r"
		end
	end
	row.status:SetText(status)

	local reagents, canCraft = ns.GetLureReagents(beast)
	row.craft:SetShown(#reagents > 0)
	row.craft:SetEnabled(canCraft and not InCombatLockdown())
end

local function ShowCraftTooltip(button)
	local beast = button:GetParent().beast
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine("Craft " .. ns.GetLureName(beast), 1, 0.82, 0)
	for _, reagent in ipairs(ns.GetLureReagents(beast)) do
		local r, g = 1, 0.3
		if reagent.have >= reagent.need then
			r, g = 0.3, 1
		end
		GameTooltip:AddDoubleLine(reagent.name, ("%d / %d"):format(reagent.have, reagent.need), 1, 1, 1, r, g, 0.3)
	end
	GameTooltip:AddLine("The first click opens Skinning if it isn't loaded yet.", 0.6, 0.6, 0.6, true)
	GameTooltip:Show()
end

local function CreateRow(parent, beast, index)
	local row = CreateFrame("Button", nil, parent)
	row.beast = beast
	row:SetSize(WIDTH - 24, ROW_HEIGHT)
	row:SetPoint("TOPLEFT", 12, -30 - (index - 1) * ROW_HEIGHT)

	local highlight = row:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetColorTexture(1, 1, 1, 0.08)

	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(34, 34)
	row.icon:SetPoint("LEFT", 4, 0)

	row.count = row:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	row.count:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", -1, 1)

	local name = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -1)
	name:SetText(("%s |cff999999(%s)|r"):format(beast.beast, beast.kind))

	row.lure = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	row.lure:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 8, 2)
	row.lure:SetTextColor(0.64, 0.21, 0.93)

	local location = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	location:SetPoint("TOPRIGHT", -16 - CRAFT_WIDTH, -5)
	location:SetText(("%s  |cffffd100%s|r"):format(beast.zone, ns.FormatCoords(beast)))

	row.status = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	row.status:SetPoint("BOTTOMRIGHT", -16 - CRAFT_WIDTH, 6)

	row.craft = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
	row.craft:SetSize(CRAFT_WIDTH, 22)
	row.craft:SetPoint("RIGHT", -6, 0)
	row.craft:SetText("Craft")
	row.craft:SetMotionScriptsWhileDisabled(true)
	row.craft:SetScript("OnEnter", ShowCraftTooltip)
	row.craft:SetScript("OnLeave", GameTooltip_Hide)
	row.craft:SetScript("OnClick", function(self)
		ns.CraftLure(self:GetParent().beast)
	end)

	row:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		ns.AddBeastTooltip(GameTooltip, self.beast)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Click to set a waypoint.", 0, 1, 0)
		GameTooltip:AddLine("Shift-click to link the location in chat.", 0, 1, 0)
		GameTooltip:Show()
	end)
	row:SetScript("OnLeave", GameTooltip_Hide)
	row:SetScript("OnClick", function(self)
		local b = self.beast
		if IsShiftKeyDown() then
			local openChat = ChatFrameUtil and ChatFrameUtil.OpenChat or ChatFrame_OpenChat
			openChat(("%s: %s %s (%s)"):format(b.beast, b.zone, ns.FormatCoords(b), ns.GetLureName(b)))
		else
			ns.SetWaypoint(b)
		end
	end)

	return row
end

local function CreateWindow()
	local f = CreateFrame("Frame", "MajesticBeastsFrame", UIParent, "BasicFrameTemplateWithInset")
	f:SetSize(WIDTH, 30 + #ns.BEASTS * ROW_HEIGHT + 34)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relativePoint, x, y = self:GetPoint()
		MajesticBeastsDB.position = { point, relativePoint, x, y }
	end)

	local position = MajesticBeastsDB.position
	if position then
		f:SetPoint(position[1], UIParent, position[2], position[3], position[4])
	else
		f:SetPoint("CENTER")
	end

	f.TitleText:SetText("Majestic Beasts - Lure Locations")

	f.rows = {}
	for i, beast in ipairs(ns.BEASTS) do
		f.rows[i] = CreateRow(f, beast, i)
	end

	local hint = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	hint:SetPoint("BOTTOMLEFT", 14, 12)
	hint:SetText("Dismount at the spot and wait for Sixth Sense before using a lure.")

	local elapsedTotal = 0
	f:SetScript("OnUpdate", function(self, elapsed)
		elapsedTotal = elapsedTotal + elapsed
		if elapsedTotal < 0.5 then return end
		elapsedTotal = 0
		for _, row in ipairs(self.rows) do
			UpdateRow(row)
		end
	end)
	f:SetScript("OnShow", function(self)
		for _, row in ipairs(self.rows) do
			UpdateRow(row)
		end
	end)

	tinsert(UISpecialFrames, "MajesticBeastsFrame")
	f:Hide()
	return f
end

function ns.ToggleWindow()
	window = window or CreateWindow()
	window:SetShown(not window:IsShown())
end
