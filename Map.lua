local _, ns = ...

local PIN_TEMPLATE = "MajesticBeastsPinTemplate"

function ns.AddBeastTooltip(tooltip, beast)
	tooltip:AddLine(beast.beast, 1, 0.82, 0)
	tooltip:AddLine(beast.kind, 0.7, 0.7, 0.7)
	tooltip:AddDoubleLine("Lure", ns.GetLureName(beast), 1, 1, 1, 0.64, 0.21, 0.93)
	tooltip:AddDoubleLine("Location", ("%s %s"):format(beast.zone, ns.FormatCoords(beast)), 1, 1, 1, 1, 1, 1)
	tooltip:AddDoubleLine("In bags", tostring(ns.GetLureCount(beast)), 1, 1, 1, 1, 1, 1)
	if beast.points > 0 then
		tooltip:AddDoubleLine("Recipe unlock", beast.points .. " skinning spec points", 1, 1, 1, 1, 1, 1)
	end
	tooltip:AddLine(" ")
	tooltip:AddLine(beast.note, 1, 1, 1, true)
	tooltip:AddLine("Stand on foot until you get Sixth Sense, then use the lure.", 0.4, 0.8, 1, true)
end

-- Pin
MajesticBeastsPinMixin = CreateFromMixins(MapCanvasPinMixin)

function MajesticBeastsPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
	self:SetScalingLimits(1, 1.0, 1.2)
	if not self.icon then
		self.icon = self:CreateTexture(nil, "ARTWORK")
		self.icon:SetAllPoints()
		self.border = self:CreateTexture(nil, "OVERLAY")
		self.border:SetPoint("CENTER")
		self.border:SetSize(38, 38)
		self.border:SetAtlas("auctionhouse-itemicon-border-purple")
	end
end

function MajesticBeastsPinMixin:OnAcquired(beast, x, y)
	self.beast = beast
	self.icon:SetTexture(ns.GetLureIcon(beast))
	self:SetPosition(x, y)
end

function MajesticBeastsPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	ns.AddBeastTooltip(GameTooltip, self.beast)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Click to set a waypoint.", 0, 1, 0)
	GameTooltip:Show()
end

function MajesticBeastsPinMixin:OnMouseLeave()
	GameTooltip:Hide()
end

function MajesticBeastsPinMixin:OnMouseUp(button)
	if button == "LeftButton" then
		ns.SetWaypoint(self.beast)
	end
end

-- Data provider
local provider = CreateFromMixins(MapCanvasDataProviderMixin)

function provider:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(PIN_TEMPLATE)
end

-- Position of a lure spot on the viewed map: its own zone map directly,
-- or translated through world coordinates for the continent map.
local function GetPinPosition(beast, mapID)
	local x, y = beast.x / 100, beast.y / 100
	if mapID == beast.mapID then
		return x, y
	end
	local info = C_Map.GetMapInfo(mapID)
	if not info or info.mapType ~= Enum.UIMapType.Continent then return end
	local continent, world = C_Map.GetWorldPosFromMapPos(beast.mapID, CreateVector2D(x, y))
	if not world then return end
	local _, pos = C_Map.GetMapPosFromWorldPos(continent, world, mapID)
	if not pos then return end
	local px, py = pos:GetXY()
	if px > 0 and px < 1 and py > 0 and py < 1 then
		return px, py
	end
end

function provider:RefreshAllData()
	self:RemoveAllData()
	if not MajesticBeastsDB or not MajesticBeastsDB.pins then return end
	local mapID = self:GetMap():GetMapID()
	if not mapID then return end
	for _, beast in ipairs(ns.BEASTS) do
		local x, y = GetPinPosition(beast, mapID)
		if x then
			self:GetMap():AcquirePin(PIN_TEMPLATE, beast, x, y)
		end
	end
end

WorldMapFrame:AddDataProvider(provider)

function ns.RefreshPins()
	if WorldMapFrame:IsShown() then
		provider:RefreshAllData()
	end
end
