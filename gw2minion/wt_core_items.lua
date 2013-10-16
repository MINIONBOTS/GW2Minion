-- contentIDs for vendor purchase items (key = rarity, value = contentID)
wt_core_items = {}
wt_core_items.itemBlacklist = {}
wt_core_items.contentIDs =
{
	[0] = 
	{
		[0] = 91433,
		[1] = 25389,
		[2] = 188002,
		[3] = 234459,
		[4] = 226329,
		[5] = 60920
	},
	[1] = 
	{
		[0] = 91435,
		[1] = 25393,
		[2] = 25400,
		[3] = 188003,
		[4] = 234463,
		[5] = 60921
	},
	[2] =
	{
		[0] = 91437,
		[1] = 25394,
		[2] = 25401,
		[3] = 188004,
		[4] = 226330,
		[5] = 60923
	},
	[3] = 
	{
		[0] = 25403,
		[1] = 25406,
		[2] = 25408,
		[3] = 25410,
		[4] = 25412
	}
}

wt_core_items.goldCost = 
{
	[0] = 
	{
		[0] = 24,
		[1] = 56,
		[2] = 88,
		[3] = 120,
		[4] = 160,
		[5] = 400
	},
	[1] = 
	{
		[0] = 24,
		[1] = 56,
		[2] = 88,
		[3] = 120,
		[4] = 160,
		[5] = 400
	},
	[2] =
	{
		[0] = 24,
		[1] = 56,
		[2] = 88,
		[3] = 120,
		[4] = 160,
		[5] = 400
	},
	[3] = 
	{
		[0] = 32,
		[1] = 88,
		[2] = 288,
		[3] = 800,
		[4] = 1536
	}
}

wt_core_items.ftool = 0
wt_core_items.ltool = 1
wt_core_items.mtool = 2
wt_core_items.skit = 3

wt_core_items.lastticks = 0
wt_core_items.interval = 1000

-- returns the best quality item in the itemList of the type supplied
function wt_core_items:GetBestQualityItem(itemList, wt_core_itemType)
	local bestItem = nil
	local qualityTable = table_invert(wt_core_items.contentIDs[wt_core_itemType])
	if (itemList ~= nil) then
		local id, item = next(itemList)
		while (id ~= nil) do
			if (qualityTable[item.contentID] ~= nil) then
				if (bestItem == nil or qualityTable[item.contentID] > qualityTable[bestItem.contentID]) then
					bestItem = item
				end
			end
			id, item = next(itemList, id)
		end
	end
	return bestItem
end

-- returns total amount of items in inventory
function wt_core_items:GetItemStock(wt_core_itemType)
	local myStock = ItemList("")
	local myStacks = 0
	local qualityTable = table_invert(wt_core_items.contentIDs[wt_core_itemType])
	if (myStock ~= nil) then
		id, item = next(myStock)
		while (id ~= nil) do
			if (qualityTable[item.contentID] ~= nil) then
				myStacks = myStacks + 1
			end
			id,item = next(myStock, id)
		end
	end

	return myStacks
end

-- returns total amount of items in inventory
function wt_core_items:GetItemStockByContentID(contentID)
	local myStock = ItemList("contentID="..contentID)
	local myStacks = 0
	if (myStock ~= nil) then
		id, item = next(myStock)
		while (id ~= nil) do
			myStacks = myStacks + 1
			id,item = next(myStock, id)
		end
	end

	return myStacks
end

-- checks to see if we need gathering tools and whether we can afford the stock we need
function wt_core_items:NeedGatheringTools()
	if (gBuyGatheringTools == "0") then
		return false
	end
	local totalCost = 0
	if (wt_core_items:GetItemStock(wt_core_items.ftool) == 0) then
		local fetool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool)
		if (fetool == nil) or (fetool.contentID ~= 217549 and fetool.contentID ~= 275764) then
			local goldCostTable = wt_core_items.goldCost[wt_core_items.ftool]
			totalCost = totalCost + (tonumber(gGatheringToolStock) * goldCostTable[tonumber(gGatheringToolQuality)])
		end
	end
	if (wt_core_items:GetItemStock(wt_core_items.ltool) == 0) then
		local letool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool)
		if (letool == nil) or (letool.contentID ~= 242480) then
			local goldCostTable = wt_core_items.goldCost[wt_core_items.ltool]
			totalCost = totalCost + (tonumber(gGatheringToolStock) * goldCostTable[tonumber(gGatheringToolQuality)])
		end
	end
	if (wt_core_items:GetItemStock(wt_core_items.mtool) == 0) then
		local metool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool)
		if (metool == nil) or (metool.contentID ~= 248409 and metool.contentID ~= 242106) then
			local goldCostTable = wt_core_items.goldCost[wt_core_items.mtool]
			totalCost = totalCost + (tonumber(gGatheringToolStock) * goldCostTable[tonumber(gGatheringToolQuality)])
		end
	end
	-- use 2*totalcost just to be safe
	return (totalCost ~= 0 and Inventory:GetInventoryMoney() - (2*totalCost) > 0)
end

--... Calling ItemList up to 25 times per CanVendor() call ? .... -.- bad kitty!
function wt_core_items:CanVendor()
	local canVendor = false
	if ( gVendor_Weapons == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0) do
			local sweapons = ItemList("itemtype=18,notsoulbound,rarity="..tmpR)	
			if (sweapons ~=nil) then
				local id,item = next(sweapons)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1			
		end
	end
	
	if ( gVendor_Armor == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0) do
			local sarmor = ItemList("itemtype=0,notsoulbound,rarity="..tmpR)					
			if (sarmor ~=nil) then
				local id,item = next(sarmor)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1
		end		
	end
		
	if ( gVendor_Trinkets == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0 ) do
			local strinket = ItemList("itemtype=15,notsoulbound,rarity="..tmpR)					
			if ( strinket ~= nil ) then
				local id,item = next(strinket)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1
		end			
	end
		
	if ( gVendor_UpgradeComps == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0 ) do
			local supgrade = ItemList("itemtype=17,notsoulbound,rarity="..tmpR)					
			if ( supgrade ~= nil ) then
				local id,item = next(supgrade)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1
		end		
	end
		
	if ( gVendor_CraftingMats == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0 ) do
			local scraftmats = ItemList("itemtype=5,notsoulbound,rarity="..tmpR)				
			if ( scraftmats ~= nil ) then
				local id,item = next(scraftmats)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1
		end		
	end
		
	if ( gVendor_Trophies == "1") then
		local tmpR = tonumber(gMaxItemSellRarity)	
		while ( tmpR > 0 ) do
			local strophies = ItemList("itemtype=16,notsoulbound,rarity="..tmpR)					
			if ( strophies ~= nil) then
				local id,item = next(strophies)
				if (id ~=nil and item ~= nil) then
					local blacklistCount = wt_core_taskmanager.itemBlacklist[item.dataID]
					if(blacklistCount == nil or blacklistCount < 3) then
						return true
					end
				end
			end
			tmpR = tmpR - 1
		end			
	end
	
	return false
end

-- checks to see if we need salvage and whether we can afford the stock we need
function wt_core_items:NeedSalvageKits()
	if (gBuySalvageKits == "0") then
		return false
	end
	local threshold
	if (tonumber(gSalvageKitStock) == 1) then
		threshold = 0
	else
		threshold = 1
	end
	local totalCost = 0
	if (wt_core_items:GetItemStock(wt_core_items.skit) <= threshold) then
		local goldCostTable = wt_core_items.goldCost[wt_core_items.skit]
		totalCost = (tonumber(gSalvageKitStock) * goldCostTable[tonumber(gSalvageKitQuality)])
	end
	-- use 2*totalcost just to be safe
	return (totalCost ~= 0 and Inventory:GetInventoryMoney() - (2*totalCost) > 0)
end

function wt_core_items.EquipGatheringTools()
    local foragingtool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool)
    if not foragingtool and gDoGathering == "1" then
		local ftool = wt_core_items:GetBestQualityItem(ItemList(""), wt_core_items.ftool)
		if ftool and not Player.inCombat then
			ftool:Equip(GW2.EQUIPMENTSLOT.ForagingTool)
			return
		end
    end
		
    local loggingtool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool)
    if not loggingtool and gDoGathering == "1" then
        local ltool = wt_core_items:GetBestQualityItem(ItemList(""), wt_core_items.ltool)
		if ltool and not Player.inCombat then
			ltool:Equip(GW2.EQUIPMENTSLOT.LoggingTool)
			return
		end
    end
    
    local miningtool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool)
    if not miningtool and gDoGathering == "1" then
        local mtool = wt_core_items:GetBestQualityItem(ItemList(""), wt_core_items.mtool)
		if mtool and not Player.inCombat then
			mtool:Equip(GW2.EQUIPMENTSLOT.MiningTool)
			return
		end
    end
end

--********************************************************************************?************
-- Handler
-- Your mama wears combat boots
--********************************************************************************?************

function wt_core_items.OnUpdateHandler( Event, ticks )
    if ( ticks - wt_core_items.lastticks > wt_core_items.interval ) then
		if ( wt_core_controller.shouldRun ) then
			wt_core_items.EquipGatheringTools()
		end
		wt_core_items.lastticks = ticks
    end
end

RegisterEventHandler("Gameloop.Update",wt_core_items.OnUpdateHandler)