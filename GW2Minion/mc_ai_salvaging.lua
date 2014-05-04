-- Handles Salvaging.
mc_ai_salvaging = {}
mc_ai_needToSalvage = false

c_salvage = inheritsFrom( ml_cause )
e_salvage = inheritsFrom( ml_effect )
function c_salvage:evaluate()
	if (SalvageManager_Active == "1" and (Inventory.freeSlotCount < 10 or mc_ai_needToSalvage == true) and Inventory.freeSlotCount >= 2
	and TableSize(Inventory("itemtype="..GW2.ITEMTYPE.SalvageTool))>0 and TableSize(mc_salvagemanager.createItemList())>0 ) then
		mc_ai_needToSalvage = true
		return true
	end
	mc_ai_needToSalvage = false
	return false
end

-- salvagingkits 0= lowest quality 
e_salvage.kitlist = {
					-- normal kits
					[23038] = {name = GetString("buyCrude"),		rarity = 0,},		-- Crude Salvage Kit (rarity 1)
					[23040] = {name = GetString("buyBasic"),		rarity = 1,},		-- Basic Salvage Kit (rarity 1)
					[23041] = {name = GetString("buyFine"),			rarity = 2,},		-- Fine (rarity 2)
					[23042] = {name = GetString("buyJourneyman"),	rarity = 3,},	-- Journeyman (rarity 3)
					[23043] = {name = GetString("buyMaster"),		rarity = 4,},		-- Master (rarity 4)
					-- special kits
					[23045] = {name = GetString("mysticKit"),		rarity = 4,},		-- Mystic Kit (rarity 4)
					[44602] = {name = GetString("unlimitedKit"),	rarity = 1,},	-- Copper-Fed Kit (rarity 1)
}

function e_salvage:execute()
	ml_log("e_need_salvage")
	local TList = Inventory("itemtype="..GW2.ITEMTYPE.SalvageTool)
	local IList = mc_salvagemanager.createItemList()
	local prefTool = nil
	local bestTool = nil
	local slowdown = math.random(0,3)
	if ( TList and IList and mc_ai_needToSalvage == true and slowdown == 0 ) then 
		for _,item in pairs(IList) do
			for _,tool in pairs(TList) do
				-- try to get the prefered tool setup in the filters first (what a bs!)
				for _,filter in ipairs(mc_salvagemanager.filterList) do
					if ((mc_salvagemanager.validFilter(filter))
					and (filter.rarity == "None" or filter.rarity == nil or GW2.ITEMRARITY[filter.rarity] == item.rarity)
					and (filter.itemtype == "None" or filter.itemtype == nil or GW2.ITEMTYPE[filter.itemtype] == item.itemtype)
					and (filter.preferedKit ~= nil and filter.preferedKit ~= "None" and e_salvage.kitlist[tool.itemID].name == filter.preferedKit)
					) then
						prefTool = tool
						break
					end
				end
				-- found preferred tool, continue to salvage
				if (prefTool) then
					break
				-- try to get a tool with the same raritylevel or the closest one matching
				elseif ((prefTool == nil and e_salvage.kitlist[tool.itemID])
				and (bestTool == nil or ( math.abs(item.rarity - e_salvage.kitlist[tool.itemID].rarity) < math.abs(item.rarity - e_salvage.kitlist[tool.itemID].rarity)))
				) then
					bestTool = tool
				end
			end
			-- Salvage the item with correct tool.
			local sTool = prefTool or bestTool
			if (sTool and Player:GetCurrentlyCastedSpell() == 17) then
				d("Salvaging "..item.name.." with "..sTool.name)
				sTool:Use(item)
				return ml_log(true)
			end
		end
	end
	return ml_log(false)
end
