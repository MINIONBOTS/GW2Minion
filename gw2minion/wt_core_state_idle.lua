-- The Idle State
-- Check for Buffs/Debuffs
-- Check for Full Inventory
-- Check for Goals
-- ...

-- We inherit from wt_core_state, which gives us: function wt_core_state:run(), function wt_core_state:add( kelement ) and function wt_core_state:register()
wt_core_state_idle = inheritsFrom( wt_core_state )
wt_core_state_idle.name = "Idle"
wt_core_state_idle.kelement_list = { }


------------------------------------------------------------------------------
-- DepositItems Cause & Effect
local c_deposit = inheritsFrom( wt_cause )
local e_deposit = inheritsFrom( wt_effect )

function c_deposit:evaluate()
	if ( ItemList.freeSlotCount <= 2 ) then
		if ( wt_global_information.InventoryFull == 0 ) then
			return true
		else
			return false -- already tried to deposit stuff, still have 0 space in inventory -> vendoringcheck will jump in
		end
	else
		wt_global_information.InventoryFull = 0
	end
	return false
end
e_deposit.throttle = 500
function e_deposit:execute()
	wt_debug( "Idle: Deposing Collectables.." )
	wt_global_information.InventoryFull = 1
	Inventory:DepositCollectables()
end

------------------------------------------------------------------------------
-- Vendoring Check Cause & Effect
local c_vendorcheck = inheritsFrom( wt_cause )
local e_vendorcheck = inheritsFrom( wt_effect )
c_vendorcheck.throttle = 2500
function c_vendorcheck:evaluate()
	if ( ItemList.freeSlotCount <= 3 and wt_global_information.InventoryFull == 1) then
		c_vendorcheck.EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
		if ( TableSize( c_vendorcheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_vendorcheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
				return true	
			end
		end
	end
	return false
end
function e_vendorcheck:execute()
	if (gVendor_Repair == "1") then
		wt_core_taskmanager:addRepairTask({priority = 10001, task_type = "custom"})
	end
	wt_core_taskmanager:addVendorTask({priority = 10001, task_type = "custom"})
end

------------------------------------------------------------------------------
-- NeedRepair Check Cause & Effect
local c_repaircheck = inheritsFrom( wt_cause )
local e_repaircheck = inheritsFrom( wt_effect )
-- IsEquipmentBroken() is defined in /gw2lib/wt_utility.lua
c_repaircheck.throttle = 2500
function c_repaircheck:evaluate()
	if ( gEnableRepair == "1" and IsEquipmentDamaged() ) then
		c_repaircheck.EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
		if ( TableSize( c_repaircheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_repaircheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then
				return true
			end
		end
	end	
	return false
end

function e_repaircheck:execute()
	wt_core_taskmanager:addRepairTask({priority = 10001, task_type = "custom"})
	if( gVendor_Repair == "1") then
		wt_core_taskmanager:addVendorTask({priority = 10001, task_type = "custom"})
	end
end



------------------------------------------------------------------------------
-- Gatherbale Cause & Effect
local c_check_gatherable = inheritsFrom( wt_cause )
local e_gather = inheritsFrom( wt_effect )

c_check_gatherable.throttle = 1000
function c_check_gatherable:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then		
		c_check_gatherable.EList = GadgetList( "onmesh,shortestpath,gatherable,maxdistance="..wt_global_information.MaxGatherDistance )
		if ( TableSize( c_check_gatherable.EList ) > 0 ) then
			local nextTarget
			nextTarget, GatherTarget = next( c_check_gatherable.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then
				return true
			end
		end
	end
	return false
end
function e_gather:execute()
	if ( TableSize( c_check_gatherable.EList ) > 0 ) then
		local nextTarget
		nextTarget, E  = next( c_check_gatherable.EList )
		if ( nextTarget ~= nil and nextTarget ~= 0 ) then
			wt_debug( "Gatherable Target found.." )
			wt_core_state_gathering.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_gathering )
		end
	end
end


------------------------------------------------------------------------------
-- Do Tasks Cause & Effect
local c_dotask = inheritsFrom( wt_cause )
local e_dotask = inheritsFrom( wt_effect )

function c_dotask:evaluate()
	return true
end

function e_dotask:execute()
	wt_core_taskmanager:DoTask()
end


function wt_core_state_idle:initialize()

	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_idle:add( ke_died )

	local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 110 )
	wt_core_state_idle:add( ke_quickloot )
	
	local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 105 )
	wt_core_state_idle:add( ke_quicklootchest )

	local ke_aggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_idle:add( ke_aggro )

	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 95 )
	wt_core_state_idle:add( ke_deposit )

	--89 salvage
	
	local ke_dopriotasks = wt_kelement:create( "DoPrioTask", c_dopriotask, e_dopriotask, 88 )
	wt_core_state_idle:add( ke_dopriotasks )
	
	local ke_vendorcheck = wt_kelement:create( "VendoringCheck", c_vendorcheck, e_vendorcheck, 87 )
	wt_core_state_idle:add( ke_vendorcheck )

	local ke_repaircheck = wt_kelement:create( "RepairCheck", c_repaircheck, e_repaircheck, 86 )
	wt_core_state_idle:add( ke_repaircheck )

	local ke_revive = wt_kelement:create( "Revive", c_check_revive, e_revive, 80 )
	wt_core_state_idle:add( ke_revive )

	--leave shroud from necro , prio 76
	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_idle:add( ke_rest )

	local ke_loot = wt_kelement:create("Loot", c_check_loot, e_loot, 50 )
	wt_core_state_idle:add( ke_loot )
	
	local ke_lootchests = wt_kelement:create("LootChest", c_lootchest, e_lootchest, 49 )
	wt_core_state_idle:add( ke_lootchests )

	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_idle:add( ke_gather )
	
	local ke_switchmesh = wt_kelement:create( "SwitchNavMesh", c_navswitch, e_navswitch, 37 )
	wt_core_state_idle:add( ke_switchmesh )	

	local ke_dotasks = wt_kelement:create( "DoTask", c_dotask, e_dotask, 35 )
	wt_core_state_idle:add( ke_dotasks )

end

-- setup kelements for the state
wt_core_state_idle:initialize()
-- register the State with the system
wt_core_state_idle:register()
