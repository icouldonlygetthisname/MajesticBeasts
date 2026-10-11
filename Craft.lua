local _, ns = ...

local SKINNING = 393

local function GetReagentItemID(reagent)
	return reagent.itemID or (reagent.reagent and reagent.reagent.itemID)
end

local function GetBasicSlots(beast)
	local schematic = C_TradeSkillUI.GetRecipeSchematic(beast.recipeID, false)
	local slots = {}
	for _, slot in ipairs(schematic and schematic.reagentSlotSchematics or {}) do
		if slot.reagentType == Enum.CraftingReagentType.Basic then
			slots[#slots + 1] = slot
		end
	end
	return slots
end

-- Returns a list of { itemID, name, have, need } for the lure's recipe and
-- whether every reagent is covered. The list is empty when the recipe data
-- isn't available.
function ns.GetLureReagents(beast)
	local reagents, canCraft = {}, true
	for _, slot in ipairs(GetBasicSlots(beast)) do
		local have, firstID = 0, nil
		-- A slot lists one item per quality tier; any mix of them counts.
		for _, reagent in ipairs(slot.reagents) do
			local itemID = GetReagentItemID(reagent)
			if itemID then
				firstID = firstID or itemID
				have = have + C_Item.GetItemCount(itemID, true, false, true, true)
			end
		end
		if firstID then
			reagents[#reagents + 1] = {
				itemID = firstID,
				name = C_Item.GetItemNameByID(firstID) or ("item:" .. firstID),
				have = have,
				need = slot.quantityRequired,
			}
			if have < slot.quantityRequired then
				canCraft = false
			end
		end
	end
	return reagents, canCraft and #reagents > 0
end

-- Quality-tiered reagents have to be allocated explicitly; use the lowest
-- quality first.
local function BuildReagentInfos(beast)
	local infos = {}
	for _, slot in ipairs(GetBasicSlots(beast)) do
		if slot.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
			local remaining = slot.quantityRequired
			for _, reagent in ipairs(slot.reagents) do
				local itemID = GetReagentItemID(reagent)
				local use = itemID and math.min(remaining, C_Item.GetItemCount(itemID, true, false, true, true)) or 0
				if use > 0 then
					infos[#infos + 1] = {
						itemID = itemID,
						reagent = { itemID = itemID },
						dataSlotIndex = slot.dataSlotIndex,
						quantity = use,
					}
					remaining = remaining - use
				end
			end
		end
	end
	return infos
end

-- Must be called from a click. The recipe can only be cast while Skinning
-- is the loaded profession, so the first click may just open it.
function ns.CraftLure(beast)
	if InCombatLockdown() then
		ns.Print("Can't craft in combat.")
		return
	end
	local _, canCraft = ns.GetLureReagents(beast)
	if not canCraft then
		ns.Print("Missing reagents for " .. ns.GetLureName(beast) .. ".")
		return
	end

	local profession = C_TradeSkillUI.GetBaseProfessionInfo()
	if not (profession and profession.professionID == SKINNING and C_TradeSkillUI.IsTradeSkillReady()) then
		if C_TradeSkillUI.OpenTradeSkill(SKINNING) then
			ns.Print("Opened Skinning - click Craft again to make the lure.")
		else
			ns.Print("You need the Skinning profession to craft lures.")
		end
		return
	end

	local recipe = C_TradeSkillUI.GetRecipeInfo(beast.recipeID)
	if not recipe or not recipe.learned then
		ns.Print(("You haven't learned %s yet (%d skinning spec points)."):format(ns.GetLureName(beast), beast.points))
		return
	end

	C_TradeSkillUI.CraftRecipe(beast.recipeID, 1, BuildReagentInfos(beast))
end
