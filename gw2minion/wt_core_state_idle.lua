-- The Idle State
-- Check for Buffs/Debuffs
-- Check for Full Inventory
-- Check for Goals
-- ...

-- We inherit from wt_core_state, which gives us: function wt_core_state:run(), function wt_core_state:add( kelement ) and function wt_core_state:register()
wt_core_state_idle = inheritsFrom( wt_core_state )
wt_core_state_idle.name = "Idle"
wt_core_state_idle.kelement_list = { }
wt_core_state_idle.DebugModes = { Revive = { Master = true, TID = nil, state = false, Move = true, Revive = true, NoTarget = true }, Loot = { Master = true, state = false, Size = 0, index = nil, TSize = true, Move = true } }
-- wt_core_state_idle.DebugModes.Revive.TID -- Target ID
-- wt_core_state_idle.DebugModes.Revive.Master -- Master Revive Debug message switch ( true / false ) if true do debug messages, if false don't do debug messages.
-- wt_core_state_idle.DebugModes.state
-- wt_core_state_idle.DebugModes.Revive.Move -- true = keep spamming the debug message
-- wt_core_state_idle.DebugModes.Revive.Revive -- true = keep spamming the debug message
-- wt_core_state_idle.DebugModes.Revive.NoTarget -- true = create debug message for No Revive Target

-- wt_core_state_idle.DebugModes.Loot.Size -- Table size of Loot Target table
-- wt_core_state_idle.DebugModes.Loot.index -- Target ID of Loot Target
-- wt_core_state_idle.DebugModes.Loot.Master -- Master Loot Debug message switch ( true / false ) if true do debug messages, if false don't do debug messages.
-- wt_core_state_idle.DebugModes.Loot.state

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

function c_vendorcheck:evaluate()
	if ( ItemList.freeSlotCount <= 2 and wt_global_information.InventoryFull == 1 and wt_global_information.HasVendor ) then
		c_vendorcheck.EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
		if ( TableSize( c_vendorcheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_vendorcheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then
				return true
			else
				wt_global_information.HasVendor = false
			end
		end
	end
	return false
end

function e_vendorcheck:execute()
	if ( TableSize( c_vendorcheck.EList ) > 0 ) then
		local nextTarget
		nextTarget, E  = next( c_vendorcheck.EList )
		if ( nextTarget ~=nil and nextTarget ~= 0 ) then
			wt_debug( "Merchant on NavMesh found.." )
			wt_core_state_vendoring.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_vendoring )
		end
	end
end

------------------------------------------------------------------------------
-- NeedRepair Check Cause & Effect
local c_repaircheck = inheritsFrom( wt_cause )
local e_repaircheck = inheritsFrom( wt_effect )
-- IsEquippmentDamaged() is defined in /gw2lib/wt_utility.lua
function c_repaircheck:evaluate()
	if ( gEnableRepair == "1" and wt_global_information.HasRepairMerchant and IsEquippmentDamaged() ) then
		c_repaircheck.EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
		if ( TableSize( c_repaircheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_repaircheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then
				return true
			else
				wt_global_information.HasRepairMerchant = false
			end
		end
	end
	return false
end

function e_repaircheck:execute()
	if ( TableSize( c_repaircheck.EList ) > 0 ) then
		local nextTarget
		nextTarget, E  = next( c_repaircheck.EList )
		if (nextTarget ~= nil and nextTarget ~= 0 ) then
			wt_debug( "RepairMerchant on NavMesh found.." )
			wt_core_state_repair.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_repair )
		end
	end
end

------------------------------------------------------------------------------
-- Search for Reviveable Targets Cause & Effect
local c_check_revive = inheritsFrom( wt_cause )
local e_revive = inheritsFrom( wt_effect )

function c_check_revive:evaluate()
	local TID = Player:GetInteractableTarget()
	if ( TID ~= nil ) then
		local T = CharacterList:Get( TID )
		if ( T ~= nil ) then
			if ( T.distance < wt_global_information.MaxReviveDistance and T.attitude == GW2.ATTITUDE.Friendly and T.healthstate == GW2.HEALTHSTATE.Defeated and T.onmesh ) then
				if ( wt_core_state_idle.DebugModes.Revive.Master ) then
					if ( T.distance > 100 and wt_core_state_idle.DebugModes.state ~= "Move" ) then
						wt_core_state_idle.DebugModes.state = "Move"
						if ( wt_core_state_idle.DebugModes.Revive.TID ~= nil ) then wt_core_state_idle.DebugModes.Revive.TID = nil end
					elseif ( T.distance < 100 and wt_core_state_idle.DebugModes.state ~= "Revive" ) then
						wt_core_state_idle.DebugModes.state = "Revive"
						if ( wt_core_state_idle.DebugModes.Revive.TID ~= nil ) then wt_core_state_idle.DebugModes.Revive.TID = nil end
					end
					if ( wt_core_state_idle.DebugModes.Revive.Move or wt_core_state_idle.DebugModes.Revive.Revive ) then
						-- if ( wt_core_state_idle.DebugModes.Revive.TID ~= nil ) then wt_core_state_idle.DebugModes.Revive.TID = nil end
					end
				end
				return true
			end
		end
	end
	if ( wt_core_state_idle.DebugModes.Revive.Master ) then
		if ( wt_core_state_idle.DebugModes.state ~= false ) then wt_core_state_idle.DebugModes.state = false end
		if ( wt_core_state_idle.DebugModes.Revive.TID ~= nil ) then wt_core_state_idle.DebugModes.Revive.TID = nil end
	end
	return false
end

function e_revive:execute()
 	local TID = Player:GetInteractableTarget()
	if ( TID ~= nil ) then
		local T = CharacterList:Get( TID )
		if ( T ~= nil ) then
			if ( T.healthstate == GW2.HEALTHSTATE.Defeated and T.attitude == GW2.ATTITUDE.Friendly and T.onmesh ) then
				if ( T.distance > 100 ) then
					if ( wt_core_state_idle.DebugModes.Revive.TID ~= TID and wt_core_state_idle.DebugModes.Revive.Master ) then wt_core_state_idle.DebugModes.Revive.TID = TID wt_debug( string.format( "Idle: moving to reviveable target %s Dist: %u", tostring( T.name ), T.distance ) ) end
					local TPOS = T.pos
					Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 80 )
				elseif( T.distance < 100 ) then
					Player:StopMoving()
					if ( Player:GetCurrentlyCastedSpell() == 17 ) then
						if ( wt_core_state_idle.DebugModes.Revive.TID ~= TID and wt_core_state_idle.DebugModes.Revive.Master ) then wt_core_state_idle.DebugModes.Revive.TID = TID wt_debug( string.format( "Idle: reviving target %s", tostring( T.name ) ) ) end
						Player:Interact( TID )
						return
					end
				end
			end
		end
	else
		if ( wt_core_state_idle.DebugModes.Revive.NoTarget and wt_core_state_idle.DebugModes.Revive.Master ) then wt_error( "Idle: No Target to revive" ) end
	end
end

------------------------------------------------------------------------------
-- Loot Cause & Effect
local c_check_loot = inheritsFrom( wt_cause )
local e_loot = inheritsFrom( wt_effect )
local e_loot_t_size = 0
local e_loot_n_index = nil

function c_check_loot:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_check_loot.EList = CharacterList( "nearest,lootable,onmesh,maxdistance=" .. wt_global_information.MaxLootDistance )
		if ( TableSize( c_check_loot.EList ) > 0 ) then
			if ( wt_core_state_idle.DebugModes.Loot.Master ) then
				local index, LT = next( c_check_loot.EList )
				if ( index ~= nil ) then
					if ( wt_core_state_idle.DebugModes.Loot.index == index or wt_core_state_idle.DebugModes.Loot.state == false ) then
						if ( LT.distance > 130 and wt_core_state_idle.DebugModes.Loot.state ~= "Moving" and wt_core_state_idle.DebugModes.Loot.Move ) then
							wt_core_state_idle.DebugModes.Loot.state = "Moving"
							if ( wt_core_state_idle.DebugModes.Loot.index == index ) then wt_core_state_idle.DebugModes.Loot.index = nil end
						elseif ( LT.distance < 100 and wt_core_state_idle.DebugModes.Loot.state ~= "Looting" ) then
							wt_core_state_idle.DebugModes.Loot.state = "Looting"
							if ( wt_core_state_idle.DebugModes.Loot.index == index ) then wt_core_state_idle.DebugModes.Loot.index = nil end
						elseif ( LT.distance < 150 and wt_core_state_idle.DebugModes.Loot.state ~= "DirectMoving" ) then
							wt_core_state_idle.DebugModes.Loot.state = "DirectMoving"
							if ( wt_core_state_idle.DebugModes.Loot.index == index ) then wt_core_state_idle.DebugModes.Loot.index = nil end
						end
					end
					if ( wt_core_state_idle.DebugModes.Loot.Size ~= TableSize( c_check_loot.EList ) and wt_core_state_idle.DebugModes.Loot.TSize ) then wt_core_state_idle.DebugModes.Loot.Size = TableSize( c_check_loot.EList ) end
					return true
				end
			end
			return true
		end
		if ( wt_core_state_idle.DebugModes.Loot.Master ) then
			if ( wt_core_state_idle.DebugModes.Loot.Size ~= TableSize( c_check_loot.EList ) ) then wt_core_state_idle.DebugModes.Loot.Size = TableSize( c_check_loot.EList ) end
			if ( wt_core_state_idle.DebugModes.Loot.state ~= false ) then wt_core_state_idle.DebugModes.Loot.state = false end
		end
	end
	return false
end

e_loot.throttle = math.random( 500, 1500 )
e_loot.delay = math.random( 100, 500 )
-- A Note to "e_loot:execute()" after the introduction of QuickLoot, "e_loot:Execute()" never seem to reach past "Idle: moving to loot" if QuickLoot is present in state.
function e_loot:execute()
	local NextIndex, LootTarget = 0, nil
	NextIndex, LootTarget = next( c_check_loot.EList )
	if ( NextIndex ~= nil ) then
		if ( wt_core_state_idle.DebugModes.Loot.Master and wt_core_state_idle.DebugModes.Loot.Size > 0 and wt_core_state_idle.DebugModes.Loot.index ~= NextIndex ) then wt_debug( "Idle: loottable size " .. TableSize( c_check_loot.EList ) ) end
		if ( LootTarget.distance > 130 ) then
			if ( wt_core_state_idle.DebugModes.Loot.Master and wt_core_state_idle.DebugModes.Loot.index ~= NextIndex and wt_core_state_idle.DebugModes.Loot.state == "Moving" ) then wt_core_state_idle.DebugModes.Loot.index = NextIndex wt_debug( "Idle: moving to loot" ) end
			local TPOS = LootTarget.pos
			Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 0 )
		elseif ( LootTarget.distance < 100 and NextIndex == Player:GetInteractableTarget() ) then
			Player:StopMoving()
			if ( Player:GetCurrentlyCastedSpell() == 17 ) then
				if ( e_loot_n_index ~= NextIndex ) then
					e_loot_n_index = NextIndex
					wt_debug( "Idle: looting" )
				end
				Player:Interact( NextIndex )
			end
		elseif ( LootTarget.distance < 150 ) then
			if ( e_loot_n_index ~= NextIndex ) then
				e_loot_n_index = NextIndex
				wt_debug( "Idle: directly moving to loot" )
			end
			local TPOS = LootTarget.pos
			Player:MoveToStraight( TPOS.x, TPOS.y, TPOS.z , 0 )
		end
	else
		wt_error( "Idle: No Target to Loot" )
	end
end

------------------------------------------------------------------------------
-- Gatherbale Cause & Effect
local c_check_gatherable = inheritsFrom( wt_cause )
local e_gather = inheritsFrom( wt_effect )

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

e_gather.throttle = 250
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

	local ke_aggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_idle:add( ke_aggro )

	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 90 )
	wt_core_state_idle:add( ke_deposit )

	local ke_vendorcheck = wt_kelement:create( "VendoringCheck", c_vendorcheck, e_vendorcheck, 88 )
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

	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_idle:add( ke_gather )

	local ke_dotasks = wt_kelement:create( "DoTask", c_dotask, e_dotask, 35 )
	wt_core_state_idle:add( ke_dotasks )

end

-- setup kelements for the state
wt_core_state_idle:initialize()
-- register the State with the system
wt_core_state_idle:register()
