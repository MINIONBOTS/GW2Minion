-- The Minion's Minion State ;)

wt_core_state_minion = inheritsFrom(wt_core_state)
wt_core_state_minion.name = "Beeing a Minion"
wt_core_state_minion.kelement_list = { }
wt_core_state_minion.LeadBroadcastTmr = nil
wt_core_state_minion.IdleTmr = 0


------------------------------------------------------------------------------
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Check the Multibot-Serverconnection Cause & Effect
local c_server = inheritsFrom( wt_cause )
local e_server = inheritsFrom( wt_effect )

function c_server:evaluate()
	if ( gMinionEnabled == "1" and not MultiBotIsConnected( ) ) then		
		return true
	end	
	return false
end
e_server.throttle = 1000
function e_server:execute()
	wt_debug("Trying to connect to MultibotComServer....")
	if ( not MultiBotConnect( gIP , tonumber(gPort) , gPw) ) then
		wt_debug("Cannot reach MultibotComServer... Make sure you have started the MultibotComServer.exe and setup the correct Password,IP and Port!")
	else
		MultiBotJoinChannel("remotecmd")
		MultiBotJoinChannel("gw2minion")
		wt_debug("Joined channels !")
	end	
end


------------------------------------------------------------------------------
-- Set this clients role Cause & Effect
local c_setrole = inheritsFrom( wt_cause )
local e_setrole = inheritsFrom( wt_effect )
c_setrole.askedCounter = 0

function c_setrole:evaluate()
	if ( MultiBotIsConnected( ) and wt_global_information.LeaderID == nil ) then	
		return true
	end	
	return false
end
e_setrole.throttle = 1000
function e_setrole:execute()	
	if ( c_setrole.askedCounter < 3 ) then
		wt_debug("Searching Leader..")
		c_setrole.askedCounter = c_setrole.askedCounter + 1
		MultiBotSend( "1;none","gw2minion" )
	else
		wt_debug("No leader found, setting our Role to Leader & telling others..")
		c_setrole.askedCounter = 0
		wt_global_information.LeaderID = Player.characterID
		MultiBotSend( "2;"..wt_global_information.LeaderID,"gw2minion" )
		wt_core_controller.requestStateChange( wt_core_state_leader  )
	end
end

------------------------------------------------------------------------------
-- NoLeader Cause & Effect
local c_noleader = inheritsFrom( wt_cause )
local e_noleader = inheritsFrom( wt_effect )
function c_noleader:evaluate()
	if (wt_global_information.TargetMapID == 0 and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID) then
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local leader = party[tonumber(wt_global_information.LeaderID)]
			if (leader == nil) then
				return true
			end		
		end	
	end
	return false
end
e_noleader.throttle = math.random( 1000, 3000 )
function e_noleader:execute()
	wt_debug( "Leader is not in the same map right now?" )
	wt_debug( "Resetting leader.." )
	wt_global_information.LeaderID = nil
	wt_core_controller.requestStateChange( wt_core_state_idle )
end


-- Aggro is in wt_common_causes

------------------------------------------------------------------------------
-- DepositItems Cause & Effect
local c_deposit = inheritsFrom( wt_cause )
local e_deposit = inheritsFrom( wt_effect )

function c_deposit:evaluate()
	if ( ItemList.freeSlotCount <= 3 ) then
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
e_deposit.throttle = 1000
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
		c_vendorcheck.EList = MapObjectList( "onmesh,maxdistance=5000,type="..GW2.MAPOBJECTTYPE.Merchant )
		if ( TableSize( c_vendorcheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_vendorcheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
				return true	
			end
		elseif ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			MultiBotSend( "10;0","gw2minion" )
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
-- IsEquipmentBroken() is defined in /gw2lib/wt_utility.lua
c_repaircheck.throttle = 2500
function c_repaircheck:evaluate()
	if ( gEnableRepair == "1" and IsEquipmentDamaged() ) then
		c_repaircheck.EList = MapObjectList( "onmesh,maxdistance=5000,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
		if ( TableSize( c_repaircheck.EList ) > 0 ) then
			local nextTarget
			nextTarget, E = next( c_repaircheck.EList )
			if ( nextTarget ~= nil and nextTarget ~= 0 ) then
				return true
			end
		elseif ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			MultiBotSend( "15;0","gw2minion" )
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
-- Search for Reviveable Partymembers Cause & Effect
  
------------------------------------------------------------------------------
-- Search for Reviveable Targets Cause & Effect

------------------------------------------------------------------------------
-- Loot Cause & Effect


------------------------------------------------------------------------------
-- Kill FocusTarget Cause & Effect
local c_focus = inheritsFrom( wt_cause )
local e_focus = inheritsFrom( wt_effect )
function c_focus:evaluate()
	-- kill focus target
	if ( wt_global_information.FocusTarget ~= nil ) then
		local target = CharacterList:Get(tonumber(wt_global_information.FocusTarget))
		if ( target ~= nil and target.distance < 4000 and target.alive and target.onmesh) then
			return true
		end
	end
	wt_global_information.FocusTarget = nil
	return false
end
function e_focus:execute()
	if ( wt_global_information.FocusTarget ~= nil ) then
		local target = CharacterList:Get(tonumber(wt_global_information.FocusTarget))
		if ( target ~= nil and target.distance < 4000 and target.alive and target.onmesh) then
			wt_debug( "Attacking Focustarget" )
			wt_core_state_combat.setTarget( wt_global_information.FocusTarget )
			wt_core_controller.requestStateChange( wt_core_state_combat )
		end
	end
end

------------------------------------------------------------------------------
-- Gatherbale Cause & Effect
local c_check_gatherable = inheritsFrom( wt_cause )
local e_gather = inheritsFrom( wt_effect )

c_check_gatherable.throttle = 1000
function c_check_gatherable:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then		
		c_check_gatherable.EList = GadgetList( "onmesh,shortestpath,gatherable,maxdistance=1200")
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
-- Follow Leader Cause & Effect
local c_followLead = inheritsFrom( wt_cause )
local e_followLead = inheritsFrom( wt_effect )
function c_followLead:evaluate()
	if (wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= 0 and wt_global_information.LeaderID ~= Player.characterID) then
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local leader = party[tonumber(wt_global_information.LeaderID)]
			if (leader ~= nil) then
				if ((leader.distance > math.random(100,400) or leader.los~=true) and leader.onmesh) then
					wt_core_state_minion.IdleTmr = wt_global_information.Now
					return true
				end		
				-- TIMER for random movement when leader is standing on a spot too long, this should go in a seperate C&E ..but I'm lazy
				if ( Player.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving and wt_global_information.Now - wt_core_state_minion.IdleTmr > math.random(2500,15000) ) then
					wt_core_state_minion.IdleTmr = wt_global_information.Now
					wt_core_state_minion.IdleTmr = wt_core_state_minion.IdleTmr + math.random(5000,10000)
					local pos = leader.pos
					Player:MoveToRandomPointAroundCircle(pos.x,pos.y,pos.z,550);
				end
			else
				wt_debug( "YOU ARE NOT IN A PARTY WITH THE LEADER! JOIN A PARTY!" )
			end		
		end
	end
	return false
end
e_followLead.throttle = math.random( 400, 1000 )
function e_followLead:execute()
	local party = Player:GetPartyMembers()
	if (party ~= nil and wt_global_information.LeaderID ~= nil) then
		local leader = party[tonumber(wt_global_information.LeaderID)]
		if (leader ~= nil) then
			local pos = leader.pos
			if (leader.movementstate == GW2.MOVEMENTSTATE.GroundMoving) then
				Player:MoveToRandom(pos.x,pos.y,pos.z,350);
			else				
				Player:MoveToRandomPointAroundCircle(pos.x,pos.y,pos.z,550);
			end
		end
	end
end
 
 
function wt_core_state_minion:initialize()

		
	-- State C&E
	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_minion:add( ke_died )
	
	local ke_checkServer = wt_kelement:create( "CheckServer", c_server, e_server, 450 )
	wt_core_state_minion:add( ke_checkServer )
	
	local ke_setRole = wt_kelement:create( "SetRole", c_setrole, e_setrole, 440 )
	wt_core_state_minion:add( ke_setRole )
		
	local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 110 )
	wt_core_state_minion:add( ke_quickloot )
	
	local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 105 )
	wt_core_state_minion:add( ke_quicklootchest )

	local ke_switchmesh = wt_kelement:create( "SwitchNavMesh", c_navswitch, e_navswitch, 104)
	wt_core_state_minion:add( ke_switchmesh )
	
	local ke_noleader = wt_kelement:create( "NoLeader", c_noleader, e_noleader, 102 )
	wt_core_state_minion:add( ke_noleader )	

	local ke_revparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 101 )
	wt_core_state_minion:add( ke_revparty )
	
	local ke_maggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_minion:add( ke_maggro )
	
	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 90 )
	wt_core_state_minion:add( ke_deposit )
	--salvaging 89
	local ke_vendorcheck = wt_kelement:create( "VendoringCheck", c_vendorcheck, e_vendorcheck, 88 )
	wt_core_state_minion:add( ke_vendorcheck )

	local ke_repaircheck = wt_kelement:create( "RepairCheck", c_repaircheck, e_repaircheck, 86 )
	wt_core_state_minion:add( ke_repaircheck )
	
	local ke_revive = wt_kelement:create( "Revive", c_check_revive, e_revive, 80 )
	wt_core_state_minion:add( ke_revive )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_minion:add( ke_rest )
	
	local ke_loot = wt_kelement:create("Loot", c_check_loot, e_loot, 50 )
	wt_core_state_minion:add( ke_loot )

	local ke_atkfocus = wt_kelement:create("FocusAtk", c_focus, e_focus, 45 )
	wt_core_state_minion:add( ke_atkfocus )
	
	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_minion:add( ke_gather )
	
	local ke_sticktoleader = wt_kelement:create( "Follow Leader", c_followLead, e_followLead, 20 )
	wt_core_state_minion:add( ke_sticktoleader )
		
end

wt_core_state_minion:initialize()
wt_core_state_minion:register()