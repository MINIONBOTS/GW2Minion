-- The salvaging State
-- Walking towards nearest Merchant n sell and buy stuff

-- We inherit from wt_core_state, which gives us: function wt_core_state:run(), function wt_core_state:add( kelement ) and function wt_core_state:register()
wt_core_state_salvaging = inheritsFrom(wt_core_state)
wt_core_state_salvaging.name = "Salvaging"
wt_core_state_salvaging.kelement_list = { }
wt_core_state_salvaging.salvageBlacklist = {}
wt_core_state_salvaging.itemSlotTable = {}
wt_core_state_salvaging.lastItemSlot = nil
wt_core_state_salvaging.lastItemStacks = nil
wt_core_state_salvaging.lastItemContentID = nil

-- utility functions
function wt_core_state_salvaging.ShouldSalvage(item)
	if ( item ~= nil and not item.soulbound and ( item.itemtype ==  GW2.ITEMTYPE.Armor or item.itemtype ==  GW2.ITEMTYPE.Weapon or item.itemtype ==  GW2.ITEMTYPE.Trinket or
	   ( gDoSalvageTrophies == "1" and item.itemtype == GW2.ITEMTYPE.Trophy))) 
	then
		salSet = Settings.GW2MINION.salvagesettings[item.rarity]
		if ( salSet~=nil and salSet.salvage == "1" ) then
			return true
		end
	end
	return false
end

function wt_core_state_salvaging.GetSalvageableItems()
	local inventory = ItemList("")
	local salvageItems = {}
	local salvageTools = {}
	id , item = next(inventory)
	-- check the first item to see if it has changed, blacklist if not
	while ( id ~= nil ) do
		if ( wt_core_state_salvaging.ShouldSalvage(item) and wt_core_state_salvaging.salvageBlacklist[item.contentID] == nil) then
			if( TableSize(salvageItems) == 0 ) then
				if (wt_core_state_salvaging.lastItemSlot == id and wt_core_state_salvaging.lastItemStacks == item.stackcount and wt_core_state_salvaging.lastItemContentID == item.contentID) then
					-- add item to blacklist
					wt_debug("Blacklisting item "..(item.name).." for salvage")
					wt_core_state_salvaging.salvageBlacklist[item.contentID] = true
				else
					-- have to save the itemlistslot so we can write it after the item is salvaged
					wt_core_state_salvaging.itemSlotTable = {}
					table.insert(wt_core_state_salvaging.itemSlotTable,id)
					table.insert(salvageItems,item)
				end
			else
				--d("id "..id)
				--d("item "..(item.name))
				table.insert(salvageItems,item)
			end
		elseif ( item.itemtype == GW2.ITEMTYPE.SalvageTool ) then
			table.insert(salvageTools,item)
		end
		id, item  = next(inventory,id)
	end
	return salvageItems,salvageTools
end

-- To be added to the idle state
local c_need_salvage = inheritsFrom(wt_cause)
local e_need_salvage = inheritsFrom(wt_effect)

function c_need_salvage:evaluate()
	if (gDoSalvaging == "0") then
		return false
	end
	
	if ( ItemList.freeSlotCount < 5) then
		local items,tools = wt_core_state_salvaging.GetSalvageableItems()
		if ( TableSize(items) > 0 and TableSize(tools) > 0 ) then
			return true
		end
	end
	return false
end

function e_need_salvage:execute()
	wt_core_controller.requestStateChange( wt_core_state_salvaging )
end


local c_salvage = inheritsFrom(wt_cause)
local e_salvage = inheritsFrom(wt_effect)

function c_salvage:evaluate()
	c_salvage.items, c_salvage.tools = wt_core_state_salvaging.GetSalvageableItems()
	if ( TableSize(c_salvage.items) > 0 and TableSize(c_salvage.tools) >0 ) then
		return true
	end
	
	return false
end

e_salvage.throttle = math.random( 800, 1000 )
function e_salvage:execute()
	id , item = next(c_salvage.items)
	tid , tool = next(c_salvage.tools)
	if ( id ~= nil and item ~= nil and tid ~=nil and tool ~= nil ) then
		if ( Player:GetCurrentlyCastedSpell() == 17 ) then
			wt_debug("salvaging item " .. (item.name) .. " with " .. (tool.name))
			wt_core_state_salvaging.lastItemSlot = wt_core_state_salvaging.itemSlotTable[id]
			wt_core_state_salvaging.lastItemContentID = item.contentID
			wt_core_state_salvaging.lastItemStacks = item.stackcount
			tool:Use(item)
			--item:Salvage()
		end
	end
end


local c_salvage_done = inheritsFrom(wt_cause)
local e_salvage_done = inheritsFrom(wt_effect)

function c_salvage_done:evaluate()
	c_salvage.items, c_salvage.tools = wt_core_state_salvaging.GetSalvageableItems()
	if ( TableSize(c_salvage.items) == 0 or TableSize(c_salvage.tools)  == 0 ) then
		return true
	end
	return false
end

function e_salvage_done:execute()
	wt_core_state_salvaging.firstSalvage = true
	wt_core_controller.requestStateChange( wt_core_state_idle )
end

--use a local aggro check/state change request instead of kill task so we don't have
--to deal with calling DoPrioTasks()
--*************************************************************
-- Aggro Cause & Effect
--*************************************************************
local c_aggro = inheritsFrom( wt_cause )
local e_aggro = inheritsFrom( wt_effect )

function c_aggro:evaluate()
	c_aggro.TargetList = ( CharacterList( "nearest,los,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		return true
	end
	
	return false
end
function e_aggro:execute()	
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		nextTarget, E  = next( c_aggro.TargetList )
		if ( nextTarget ~= nil ) then
			wt_debug( "Begin Combat, Possible aggro target found" )
			wt_core_state_combat.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_combat )
		end
	end
end
-------------------------------------------------------------

function wt_core_state_salvaging.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		
		local delimiter = k:find('_')
		if (delimiter ~= nil and delimiter ~= 0) then
			local control = k:sub(0,delimiter-1)
			local id = k:sub(delimiter+1)
			if ( control == "gSalvage" and id ~= nil) then
				Settings.GW2MINION.salvagesettings[ tonumber(id) ].salvage = v
				Settings.GW2MINION.salvagesettings = Settings.GW2MINION.salvagesettings -- Trigger save
			end
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end


function wt_core_state_salvaging:HandleInit() 
	
	if (Settings.GW2MINION.salvagesettings == nil) then
		Settings.GW2MINION.salvagesettings = {	
		[1] = { desc=strings[gCurrentLanguage].rarityCommon, salvage="0"},	
		[2] = { desc=strings[gCurrentLanguage].rarityFine, salvage="0"},	
		[3] = { desc=strings[gCurrentLanguage].rarityMasterwork, salvage="0"},		
		[4] = { desc=strings[gCurrentLanguage].rarityRare, salvage="0"},		
		--[5] = { desc=strings[gCurrentLanguage].rarityExotic, salvage="0"},
		}
	end
	
	for k,v in pairs(Settings.GW2MINION.salvagesettings) do
		GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].salvage .. v.desc ,"gSalvage_" .. k,strings[gCurrentLanguage].salvageSettings)
		_G["gSalvage_"..k] = v.salvage
	end
	
	-- Add to other states only after all files have been loaded
	local ke_do_salvage = wt_kelement:create( strings[gCurrentLanguage].enableSalvage, c_need_salvage, e_need_salvage, 89 )
	wt_core_state_idle:add( ke_do_salvage )
	wt_core_state_minion:add( ke_do_salvage )
	wt_core_state_leader:add( ke_do_salvage )
	
end

function wt_core_state_salvaging:initialize()


	RegisterEventHandler("Module.Initalize",wt_core_state_salvaging.HandleInit)
	RegisterEventHandler("GUI.Update",wt_core_state_salvaging.GUIVarUpdate)
	
	-- State C&E
	local ke_died = wt_kelement:create("Died",c_died,e_died, wt_effect.priorities.interrupt )
	wt_core_state_salvaging:add(ke_died)
		
	local ke_aggro = wt_kelement:create("AggroCheck",c_aggro,e_aggro, 100 )
	wt_core_state_salvaging:add(ke_aggro)
			
	local ke_salvage = wt_kelement:create("Salvage",c_salvage,e_salvage,60)
	wt_core_state_salvaging:add(ke_salvage)

	local ke_salvage_done = wt_kelement:create("Salvage done",c_salvage_done,e_salvage_done,50)
	wt_core_state_salvaging:add(ke_salvage_done)
	

end


-- setup kelements for the state
wt_core_state_salvaging:initialize()
-- register the State with the system
wt_core_state_salvaging:register()
