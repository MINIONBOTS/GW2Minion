gw2_sell_manager = {}
gw2_sell_manager.mainWindow = { name = GetString("sellmanager"), x = 350, y = 50, w = 250, h = 350}
gw2minion.MainWindow.ChildWindows[gw2_sell_manager.mainWindow.name] = gw2_sell_manager.mainWindow.name
gw2_sell_manager.filterList = {}
gw2_sell_manager.currentFilter = nil

function gw2_sell_manager.ModuleInit()
	if (Settings.GW2Minion.SellManager_FilterList == nil) then
		Settings.GW2Minion.SellManager_FilterList = {
		{
			itemtype = "Weapon",
			name = "Weapons_Junk",
			rarity = "Junk",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Weapon",
			name = "Weapons_Common",
			rarity = "Common",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Weapon",
			name = "Weapons_Masterwork",
			rarity = "Masterwork",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Weapon",
			name = "Weapons_Fine",
			rarity = "Fine",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Armor",
			name = "Armor_Junk",
			rarity = "Junk",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Armor",
			name = "Armor_Common",
			rarity = "Common",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Armor",
			name = "Armor_Masterwork",
			rarity = "Masterwork",
			soulbound = "false",
			weapontype = "None",
		},

		{
			itemtype = "Armor",
			name = "Armor_Fine",
			rarity = "Fine",
			soulbound = "false",
			weapontype = "None",
		},

		}
	end

	if (Settings.GW2Minion.SellManager_Active == nil ) then
		Settings.GW2Minion.SellManager_Active = "1"
	end

	if (Settings.GW2Minion.SellManager_ItemIDInfo == nil ) then
		Settings.GW2Minion.SellManager_ItemIDInfo = {}
	end



	gw2_sell_manager.filterList = Settings.GW2Minion.SellManager_FilterList
	gw2_sell_manager.refreshFilterlist()

	local mainWindow = WindowManager:NewWindow(gw2_sell_manager.mainWindow.name,gw2_sell_manager.mainWindow.x,gw2_sell_manager.mainWindow.y,gw2_sell_manager.mainWindow.w,gw2_sell_manager.mainWindow.h,false)
	if (mainWindow) then
		mainWindow:NewCheckBox(GetString("active"),"SellManager_Active",GetString("sellGroup"))
		mainWindow:NewButton(GetString("newfilter"),"SellManager_NewFilter")
		RegisterEventHandler("SellManager_NewFilter",gw2_sell_manager.CreateDialog)
		mainWindow:UnFold(GetString("sellGroup"))

		mainWindow:NewComboBox(GetString("sellByIDtems"),"SellManager_ItemToSell",GetString("sellByID"),"")
		mainWindow:NewButton(GetString("sellByIDAddItem"),"SellManager_AdditemID",GetString("sellByID"))
		RegisterEventHandler("SellManager_AdditemID",gw2_sell_manager.AddItemID)
		mainWindow:NewComboBox(GetString("sellItemList"),"SellManager_ItemIDList",GetString("sellByID"),"")
		SellManager_ItemIDList = "None"
		mainWindow:NewButton(GetString("sellByIDRemoveItem"),"SellManager_RemoveitemID",GetString("sellByID"))
		RegisterEventHandler("SellManager_RemoveitemID",gw2_sell_manager.RemoveItemID)

		mainWindow:Hide()
	end

	SellManager_Active = Settings.GW2Minion.SellManager_Active
	SellManager_ItemIDInfo = Settings.GW2Minion.SellManager_ItemIDInfo

	if (Player) then
		gw2_sell_manager.UpdateComboBox(Inventory(""),"SellManager_ItemToSell",SellManager_ItemIDInfo)
		gw2_sell_manager.UpdateComboBox(SellManager_ItemIDInfo,"SellManager_ItemIDList")
		gw2_sell_manager.refreshFilterlist()
	end
end

-- SINGLE ITEM STUFF HERE
-- Update singe-item drop-down list.
function gw2_sell_manager.UpdateComboBox(iTable,global,excludeTable,setToName)
	if (iTable and global) then
		local list = "None"
		for _,item in pairs(iTable) do
			if (ValidString(item.name) and StringContains(list, item.name) == false)then
				local name = item.name
				if (ValidTable(excludeTable)) then
					for _,eItem in pairs(excludeTable) do
						if (eItem.name == item.name) then
							name = ""
						end
					end
				end
				list = (ValidString(name) == true and list .. "," .. name or list)
			end
		end
		_G[global] = (setToName == false and _G[global] or ValidString(setToName) and setToName or "None")
		_G[global .. "_listitems"] = list
	end
end

-- Add Single-Item to itemIDlist.
function gw2_sell_manager.AddItemID()
	if (ValidString(SellManager_ItemToSell) and SellManager_ItemToSell ~= "None") then
		-- Make sure this item is not already in our SellList
		for _,item in pairs(SellManager_ItemIDInfo) do
			if (SellManager_ItemToSell == item.name) then
				return
			end
		end
		-- Find Item by Name in Inventory
		for _,item in pairs(Inventory("")) do
			if (ValidString(item.name) and item.name == SellManager_ItemToSell)then
				table.insert(SellManager_ItemIDInfo, {name = item.name, itemID = item.itemID})
				gw2_sell_manager.UpdateComboBox(SellManager_ItemIDInfo,"SellManager_ItemIDList",nil,item.name)
				break
			end
		end
		Settings.GW2Minion.SellManager_ItemIDInfo = SellManager_ItemIDInfo
		gw2_sell_manager.UpdateComboBox(Inventory(""),"SellManager_ItemToSell",SellManager_ItemIDInfo)
	end
	return false
end

-- Remove Single-Item from itemIDlist.
function gw2_sell_manager.RemoveItemID()
	if ( ValidString(SellManager_ItemIDList) and SellManager_ItemIDList ~= "None") then
		for id,item in pairs(SellManager_ItemIDInfo) do
			if (item.name == SellManager_ItemIDList) then
				table.remove(SellManager_ItemIDInfo, id)
				break
			end
		end
		Settings.GW2Minion.SellManager_ItemIDInfo = SellManager_ItemIDInfo
		gw2_sell_manager.UpdateComboBox(SellManager_ItemIDInfo,"SellManager_ItemIDList")
		gw2_sell_manager.UpdateComboBox(Inventory(""),"SellManager_ItemToSell",SellManager_ItemIDInfo)
	end
end

-- FILTER STUFF HERE
--Refresh filters.
function gw2_sell_manager.refreshFilterlist()
	local mainWindow = WindowManager:GetWindow(gw2_sell_manager.mainWindow.name)
	if (mainWindow) then
		mainWindow:DeleteGroup(GetString("sellfilters"))
		for id,filter in pairs(gw2_sell_manager.filterList) do
			mainWindow:NewButton(gw2_sell_manager.filterList[id].name, "SellManager_Filter" .. id,GetString("sellfilters"))
			RegisterEventHandler("SellManager_Filter" .. id ,gw2_sell_manager.CreateDialog)
		end
		mainWindow:UnFold(GetString("sellfilters"))
	end
end

-- Create New Filter Dialog.
function gw2_sell_manager.CreateDialog(filterID)
	if (filterID:find("SellManager_Filter")) then
		filterID = string.gsub(filterID, "SellManager_Filter", "")
		filterID = tonumber(filterID)
		gw2_sell_manager.currentFilter = filterID
	end
	local dialog = gw2_dialog_manager:GetDialog(GetString("newsellfilter"))
	if (dialog == nil) then
		dialog = gw2_dialog_manager:NewDialog(GetString("newsellfilter"))
		dialog:NewField(GetString("name"),"SellManager_Name")
		dialog:NewComboBox(GetString("soulbound"),"SellManager_Soulbound","true,false,either")
		local list = "None"
		for name,_ in pairs(GW2.ITEMTYPE) do list = list .. "," .. name end
		dialog:NewComboBox(GetString("itemtype"),"SellManager_Itemtype",list)
		list = GetString("rarityNone")..","..GetString("rarityJunk")..","..GetString("rarityCommon")..","..GetString("rarityFine")..","..GetString("rarityMasterwork")..","..GetString("rarityRare")..","..GetString("rarityExotic")
		dialog:NewComboBox(GetString("rarity"),"SellManager_Rarity",list)
		list = "None"
		for name,_ in pairs(GW2.WEAPONTYPE) do list = list .. "," .. name end
		dialog:NewComboBox(GetString("weapontype"),"SellManager_Weapontype",list)
		dialog:SetOkFunction(gw2_sell_manager.DialogOK)
		dialog:SetDeleteFunction(gw2_sell_manager.DialogDelete)
	end
	if (dialog) then
		local tType = (type(filterID) == "number")
		dialog:Show(tType)
		SellManager_Name = (tType and gw2_sell_manager.filterList[filterID].name or "")
		SellManager_Itemtype = (tType and gw2_sell_manager.filterList[filterID].itemtype or "None")
		SellManager_Rarity = (tType and gw2_sell_manager.filterList[filterID].rarity or GetString("rarityNone"))
		SellManager_Weapontype = (tType and gw2_sell_manager.filterList[filterID].weapontype or "None")
		SellManager_Soulbound = (tType and gw2_sell_manager.filterList[filterID].soulbound or "either")
	end
end

-- Dialog OK button function.
function gw2_sell_manager.DialogOK()
	local saveFilter = {name = SellManager_Name,itemtype = SellManager_Itemtype,rarity = SellManager_Rarity,weapontype = SellManager_Weapontype,soulbound = SellManager_Soulbound,}
	if (ValidString(saveFilter.name) == false) then
		ml_error("Please enter a filter name before saving.")
	elseif (gw2_sell_manager.validFilter(saveFilter)) then -- check if filter is valid.
		if (type(gw2_sell_manager.currentFilter) ~= "number") then -- new filter, making sure name is not in use.
			for _,filter in pairs(gw2_sell_manager.filterList) do
				if (saveFilter.name == filter.name) then
					return "Filter with this name already exists, please change the name."
				end
			end
			table.insert(gw2_sell_manager.filterList, saveFilter)
		else
			gw2_sell_manager.filterList[gw2_sell_manager.currentFilter] = saveFilter
		end
		Settings.GW2Minion.SellManager_FilterList = gw2_sell_manager.filterList
		gw2_sell_manager.refreshFilterlist()
		return true
	else
		return "Filter Not Valid. Filter needs to have both type and rarity set. Junk rarity can be set without any type."
	end
end

-- Dialog DELETE button function.
function gw2_sell_manager.DialogDelete()
	table.remove(gw2_sell_manager.filterList, gw2_sell_manager.currentFilter)
	Settings.GW2Minion.SellManager_FilterList = gw2_sell_manager.filterList
	gw2_sell_manager.refreshFilterlist()
	return true
end

-- Check if filter is valid:
function gw2_sell_manager.validFilter(filter)
	if (filter.itemtype ~= "None" and filter.itemtype ~= nil and
	filter.rarity ~= "None" and filter.rarity ~= nil) then
		return true
	elseif (filter.rarity == "Junk") then
		return true
	end
	return false
end

-- Working stuff here.
--Create filtered sell item list.
function gw2_sell_manager.createItemList()
	local items = Inventory("exclude_contentid="..ml_blacklist.GetExcludeString(GetString("salvageItems")))
	local filteredItems = {}
	if (items) then
		for _,item in pairs(items) do
			if (item.accountbound == false and item.soulbound == false) then
				local addItem = false
				for _,filter in pairs(gw2_sell_manager.filterList) do
					if (gw2_sell_manager.validFilter(filter)) then
						if ((filter.rarity == "None" or filter.rarity == nil or GW2.ITEMRARITY[filter.rarity] == item.rarity) and
						(filter.itemtype == "None" or filter.itemtype == nil or GW2.ITEMTYPE[filter.itemtype] == item.itemtype) and
						(filter.weapontype == "None" or filter.weapontype == nil or GW2.WEAPONTYPE[filter.weapontype] == item.weapontype) and
						(filter.soulbound == "either" or (filter.soulbound == nil and item.soulbound == false) or filter.soulbound == tostring(item.soulbound))) then
							addItem = true
						end
					end
				end
				-- Check for single itemlist
				if (addItem == false) then
					for iID,lItem in pairs(SellManager_ItemIDInfo) do
						if (item.itemID == lItem.itemID) then
							addItem = true
							break
						end
					end
				end
				-- Add item if found in filters.
				if (addItem) then
					table.insert(filteredItems, item)
				end
			end
		end
		if (ValidTable(filteredItems)) then
			return filteredItems
		end
	end
	return false
end

--Have items to sell.
function gw2_sell_manager.haveItemToSell()
	if (ValidTable(gw2_sell_manager.createItemList())) then
		return true
	end
	return false
end

-- Get closest sellMarker
function gw2_sell_manager.getClosestSellMarker(nearby)
	local closestLocation = nil
	local listArg = (nearby == true and ",maxdistance=5000" or "")
	local markers = MapMarkerList("onmesh,nearest,worldmarkertype=24,markertype=25"..listArg..",exclude_characterid="..ml_blacklist.GetExcludeString(GetString("vendors")))
	if ( TableSize(markers) > 0 ) then
		local i,marker = next (markers)
		while ( i and marker ) do
			local mCID = marker.contentID
			if (mCID == GW2.MAPMARKER.Merchant or mCID == GW2.MAPMARKER.Armorsmith or mCID == GW2.MAPMARKER.Weaponsmith or mCID == GW2.MAPMARKER.Repair) then
				if (closestLocation == nil or closestLocation.distance > marker.distance) then
					if (nearby == true and marker.pathdistance < 4000) then
						closestLocation = marker
					elseif (nearby ~= true) then
						closestLocation = marker
					end
				end
			end
			i,marker = next (markers,i)
		end
	end

	return closestLocation
end

-- Sell at vendor
gw2_sell_manager.lastVendorID = nil
gw2_sell_manager.VendorSellHistroy = {}
function gw2_sell_manager.sellAtVendor(vendorMarker)
	if (vendorMarker) then
		vendor = CharacterList:Get(vendorMarker.characterID)
		if (vendor and vendor.isInInteractRange and vendor.distance < 100) then
			Player:StopMovement()
			-- Reset vendorhistory on new vendor
			if ( gw2_sell_manager.lastVendorID == nil or gw2_sell_manager.lastVendorID ~= vendor.id ) then
				gw2_sell_manager.lastVendorID = vendor.id
				gw2_sell_manager.VendorSellHistroy = {}
			end

			local target = Player:GetTarget()
			if (not target or target.id ~= vendor.id) then
				Player:SetTarget(vendor.id)
				return true
			else
				if (Inventory:IsVendorOpened() == false and Player:IsConversationOpen() == false) then
					d(" Opening Vendor.. ")
					Player:Interact(vendor.id)
					ml_global_information.Wait(1500)
					return true
				else
					local result = gw2_common_functions.handleConversation("sell")
					if (result == false) then
						d("Vendor blacklisted, cant handle opening conversation.")
						ml_blacklist.AddBlacklistEntry(GetString("vendors"), vendor.id, vendor.name, true)
						return false
					elseif (result == nil) then
						ml_global_information.Wait(math.random(520,1200))
						return true
					end
				end
				local iList = gw2_sell_manager.createItemList()
				local slowdown = math.random(0,1)
				local soldstuff = false
				if ( iList ) then
					if ( slowdown == 0 ) then
						for _,item in pairs(iList) do
							d("Selling: "..item.name)
							item:Sell()
							if ( not gw2_sell_manager.VendorSellHistroy[item.itemID] or gw2_sell_manager.VendorSellHistroy[item.itemID] < 10 ) then

								if ( not gw2_sell_manager.VendorSellHistroy[item.itemID] ) then
									gw2_sell_manager.VendorSellHistroy[item.itemID] = 1
								else
									gw2_sell_manager.VendorSellHistroy[item.itemID] = gw2_sell_manager.VendorSellHistroy[item.itemID] + 1
								end
							else
								d("Can't sell "..item.name..", blacklisting it")
								ml_blacklist.AddBlacklistEntry(GetString("salvageItems"), item.itemID, item.name, true)
							end
							return true
						end
						return false
					end
					return true
				end

				-- No more items to sell
				d("Selling finished..")
				Inventory:SellJunk()

			end
		else
			local pos = vendorMarker.pos
			if ( pos ) then
				local newTask = gw2_task_moveto.Create()
				newTask.targetPos = pos
				newTask.targetID = vendorMarker.characterID
				newTask.targetType = "character"
				newTask.name = "MoveTo Vendor(SELL)"
				newTask.useWaypoint = true
				ml_task_hub:CurrentTask():AddSubTask(newTask)
				return true
			end
		end
	end
	return false
end

-- Need to sell
function gw2_sell_manager.needToSell(nearby)
	if (gw2_sell_manager.haveItemToSell() and (gw2_sell_manager.getClosestSellMarker(nearby) or gw2_marker_manager.GetClosestVendorMarker() ~= nil)) then
		if (nearby and ((ml_global_information.Player_Inventory_SlotsFree*100)/Inventory.slotCount) < 33) then
			return true
		elseif (ml_global_information.Player_Inventory_SlotsFree <= 2) then
			return true
		end
	end
	return false
end

-- Toggle menu.
function gw2_sell_manager.ToggleMenu()
	local mainWindow = WindowManager:GetWindow(gw2_sell_manager.mainWindow.name)
	if (mainWindow) then
		if ( mainWindow.visible ) then
			mainWindow:Hide()
		else
			local wnd = WindowManager:GetWindow(gw2minion.MainWindow.Name)
			if ( wnd ) then
				mainWindow:SetPos(wnd.x+wnd.width,wnd.y)
				mainWindow:Show()
				gw2_sell_manager.UpdateComboBox(Inventory(""),"SellManager_ItemToSell",SellManager_ItemIDInfo)
			end
		end
	end
end

RegisterEventHandler("Module.Initalize",gw2_sell_manager.ModuleInit)