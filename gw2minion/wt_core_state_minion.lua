-- The Minion's Minion State ;)

wt_core_state_minion = inheritsFrom(wt_core_state)
wt_core_state_minion.name = "Minion"
wt_core_state_minion.kelement_list = { }
wt_core_state_minion.IdleTmr = 0
wt_core_state_minion.TaskChecks = {}

------------------------------------------------------------------------------
-- NoLeader Cause & Effect
local c_noleader = inheritsFrom( wt_cause )
local e_noleader = inheritsFrom( wt_effect )
c_noleader.throttle = math.random( 1000, 3000 )
function c_noleader:evaluate()
	if ( Settings.GW2MINION.gLeaderID ~= nil) then
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local leader = party[tonumber(Settings.GW2MINION.gLeaderID)]
			if (leader ~= nil) then
				return false
			end		
		end	
	end
	return true
end
e_noleader.throttle = math.random( 1000, 3000 )
function e_noleader:execute()
	wt_debug( "Leader is gone? ..reseting state" )
	wt_core_controller.requestStateChange( wt_core_state_idle )
end


-- Aggro is in wt_common_causes

-- DepositItems is in wt_common_causes

-- Search for Reviveable Partymembers is in wt_common_causes
  
  
-- Search for Reviveable Targets is in wt_common_causes


-- Loot is in wt_common_causes


-- LootChest is in wt_common_causes


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
			--wt_debug( "Attacking Focustarget" )
			wt_core_state_combat.setTarget( wt_global_information.FocusTarget )
			wt_core_controller.requestStateChange( wt_core_state_combat )
		end
	end
end

------------------------------------------------------------------------------
-- Gatherable Cause & Effect
local c_check_gatherable = inheritsFrom( wt_cause )
local e_gather = inheritsFrom( wt_effect )
c_check_gatherable.throttle = 1000
function c_check_gatherable:evaluate()
	if ( gDoGathering == "0" ) then
		return false
	end
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
c_followLead = inheritsFrom( wt_cause )
e_followLead = inheritsFrom( wt_effect )
function c_followLead:evaluate()
	if (Player:GetRole() ~= 1 and Settings.GW2MINION.gLeaderID ~= nil) then
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local leader = party[tonumber(Settings.GW2MINION.gLeaderID)]
			if (leader ~= nil) then
				if ((leader.distance > math.random(100,400) or leader.los~=true) and leader.onmesh) then
					return true
				end		
				-- TIMER for random movement when leader is standing on a spot too long, this should go in a seperate C&E ..but I'm lazy
				if ( Player.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving and wt_global_information.Now - wt_core_state_minion.IdleTmr > math.random(5000,30000) ) then
					return true					
				end
			else
				return true
			end		
		end
	end
	return false
end
e_followLead.throttle = math.random( 400, 1000 )
function e_followLead:execute()
	local party = Player:GetPartyMembers()
	if (party ~= nil and Settings.GW2MINION.gLeaderID ~= nil) then
		local leader = party[tonumber(Settings.GW2MINION.gLeaderID)]
		if (leader ~= nil) then
			if ((leader.distance > math.random(100,400) or leader.los~=true) and leader.onmesh) then
				local pos = leader.pos
				if (leader.movementstate == GW2.MOVEMENTSTATE.GroundMoving) then
					--wt_debug("PREDICT")
					--Player:MoveToPredict(pos.x,pos.y,pos.z,pos.hx,pos.hy,pos.hz);
					Player:MoveToRandom(pos.x,pos.y,pos.z,350);
				else				
					Player:MoveToRandomPointAroundCircle(pos.x,pos.y,pos.z,550);
				end
				wt_core_state_minion.IdleTmr = wt_global_information.Now
				return
			end
			
			if ( Player.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving and wt_global_information.Now - wt_core_state_minion.IdleTmr > math.random(5000,30000) ) then
				wt_core_state_minion.IdleTmr = wt_global_information.Now
				wt_core_state_minion.IdleTmr = wt_core_state_minion.IdleTmr + math.random(5000,10000)
				local pos = leader.pos
				Player:MoveToRandomPointAroundCircle(pos.x,pos.y,pos.z,550);
			end
		else
			wt_debug( "Leader is not in our map or there is no leader anymore?" )
			wt_debug( "Asking for leader.." )				
			wt_core_controller.requestStateChange( wt_core_state_idle )
		end
	end
end
 
 
function wt_core_state_minion:initialize()

		
	-- State C&E
	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_minion:add( ke_died )
			
	local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 110 )
	wt_core_state_minion:add( ke_quickloot )
	
	--local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 105 )
	--wt_core_state_minion:add( ke_quicklootchest )
	local ke_movecheck = wt_kelement:create( "MovementCheck", c_stopcbmove, e_stopcbmove, 107 )
	wt_core_state_minion:add( ke_movecheck )
		
	local ke_lootchests = wt_kelement:create("LootChest", c_lootchest, e_lootchest, 105 )
	wt_core_state_minion:add( ke_lootchests )
		
	local ke_skillstuckcheck = wt_kelement:create( "UnStuckSkill", c_skillstuckcheck, e_skillstuckcheck, 104 )
	wt_core_state_minion:add( ke_skillstuckcheck )
	
	local ke_doemertasks = wt_kelement:create( "EmergencyTask", c_doemergencytask, e_doemergencytask, 103 )
	wt_core_state_minion:add( ke_doemertasks )
	
	local ke_noleader = wt_kelement:create( "NoLeader", c_noleader, e_noleader, 102 )
	wt_core_state_minion:add( ke_noleader )	

	local ke_revparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 101 )
	wt_core_state_minion:add( ke_revparty )
	
	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 91 )
	wt_core_state_minion:add( ke_deposit )
	--salvaging 89

	
	local ke_loot = wt_kelement:create("Loot", c_check_loot, e_loot, 88 )
	wt_core_state_minion:add( ke_loot )
	
	local ke_revive_players = wt_kelement:create( "RevivePlayers", c_check_revive_players, e_revive_players, 87 )
	wt_core_state_minion:add( ke_revive_players )
	
	local ke_dopriotasks = wt_kelement:create( "PrioTask", c_dopriotask, e_dopriotask, 85 )
	wt_core_state_minion:add( ke_dopriotasks )
		
	local ke_revive = wt_kelement:create( "Revive", c_check_revive, e_revive, 80 )
	wt_core_state_minion:add( ke_revive )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_minion:add( ke_rest )
	
	local ke_atkfocus = wt_kelement:create("FocusAtk", c_focus, e_focus, 45 )
	wt_core_state_minion:add( ke_atkfocus )
	
	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_minion:add( ke_gather )
	
	local ke_sticktoleader = wt_kelement:create( "Follow Leader", c_followLead, e_followLead, 20 )
	wt_core_state_minion:add( ke_sticktoleader )
		
end

wt_core_state_minion:initialize()
wt_core_state_minion:register()

--Only put tasks here which are solo bot specific...any other tasks that are shared
--should go in wt_core_taskmanager:Update_Tasks()

--UID = "REPAIR"
--Throttle = 2500
function wt_core_state_minion:repairCheck()
	if ( gEnableRepair == "1" and NeedRepair() and not wt_core_taskmanager:CheckTaskQueue("REPAIR")) then
		local vendor = wt_core_helpers:GetClosestRepairVendor(5000)
		if (vendor) then
			wt_core_taskmanager:addRepairTask(5000, vendor)
			wt_core_taskmanager:addVendorTask(4500, vendor)
			return true
		elseif ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			vendor = wt_core_helpers:GetClosestRepairVendor(999999)
			if (vendor) then
				MultiBotSend( "15;0","gw2minion" )
				return true
			else
				wt_debug("Need to repair but no repair vendor found - check your mesh!")
			end
		end
	end
	return false
end
table.insert(wt_core_state_minion.TaskChecks,{["func"]=wt_core_state_minion.repairCheck, ["throttle"]=2500})

--UID = "VENDORSELL"
--Throttle = 2500
function wt_core_state_minion:vendorSellCheck()
	if ( ItemList.freeSlotCount <= 3 and wt_global_information.InventoryFull == 1 and not wt_core_taskmanager:CheckTaskQueue("VENDORSELL")) then
		if (wt_core_items:CanVendor()) then
			local vendor = wt_core_helpers:GetClosestSellVendor(5000)
			if (vendor) then
				wt_core_taskmanager:addVendorTask(4500, vendor)
				return true
			elseif ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
				vendor = wt_core_helpers:GetClosestSellVendor(999999)
				if (vendor) then
					MultiBotSend( "10;0","gw2minion" )
					return true
				else
					wt_debug("Need to sell but no suitable vendor found - check your mesh!")
				end
			end
		end
	end
	return false
end
table.insert(wt_core_state_minion.TaskChecks,{["func"]=wt_core_state_minion.vendorSellCheck, ["throttle"]=2500})

--UID = "VENDORBUY..."
--Throttle = 2500
function wt_core_state_minion:vendorBuyCheck()
	--wt_debug("vendorBuyCheck")
	if (wt_core_taskmanager:CheckTaskQueue("VENDORBUY")) then
		return false
	end
	
	local buyfTools, buylTools, buymTools, buyKits = false
	local slotsLeft = ItemList.freeSlotCount
	
	if 	(wt_core_items:NeedGatheringTools() and ItemList.freeSlotCount > (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.ftool))) then
		local fetool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool)
		if (fetool == nil) or (fetool.contentID ~= 217549 and fetool.contentID ~= 275764) then
			buyfTools = true
			slotsLeft = ItemList.freeSlotCount - (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.ftool))
		end
	end
	
	if 	(wt_core_items:NeedGatheringTools() and slotsLeft > (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.ltool))) then
		local letool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool)
		if (letool == nil) or (letool.contentID ~= 242480) then
			buylTools = true
			slotsLeft = slotsLeft - (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.ltool))
		end
	end
	
	if 	(wt_core_items:NeedGatheringTools() and slotsLeft > (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.mtool))) then
		local metool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool)
		if (metool == nil) or (metool.contentID ~= 248409) and (metool.contentID ~= 242106) then
			buymTools = true
			slotsLeft = slotsLeft - (tonumber(gGatheringToolStock) - wt_core_items:GetItemStock(wt_core_items.mtool))
		end
	end
	
	if (wt_core_items:NeedSalvageKits() and slotsLeft > tonumber(gSalvageKitStock)) then
		buyKits = true
	end

	if (buyfTools or buylTools or buymTools or buyKits) then
		local vendor = wt_core_helpers:GetClosestBuyVendor(5000)
		if (vendor) then
			if (buyfTools) then
				wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.ftool, tonumber(gGatheringToolStock),gGatheringToolQuality, vendor)
			end
			if (buylTools) then
				wt_core_taskmanager:addVendorBuyTask(4751, wt_core_items.ltool, tonumber(gGatheringToolStock),gGatheringToolQuality, vendor)
			end
			if (buymTools) then
				wt_core_taskmanager:addVendorBuyTask(4752, wt_core_items.mtool, tonumber(gGatheringToolStock),gGatheringToolQuality, vendor)
			end
			if (buyKits) then
				wt_core_taskmanager:addVendorBuyTask(4753, wt_core_items.skit, tonumber(gSalvageKitStock),gSalvageKitQuality, vendor)
			end
			return true
		elseif ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			vendor = wt_core_helpers:GetClosestBuyVendor(999999)
			if (vendor) then
				MultiBotSend( "12;0","gw2minion" )
				return true
			else
				wt_debug("Need to buy tools/kits but no suitable vendor found - check your mesh!")
			end
		end
	end
	
	return false
end
table.insert(wt_core_state_minion.TaskChecks,{["func"]=wt_core_state_minion.vendorBuyCheck, ["throttle"]=2500})

--Throttle = 500
function wt_core_state_minion:aggroCheck()
	if ( wt_global_information.DoAggroCheck ) then
		local TList = ( CharacterList( "nearest,los,incombat,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil) then
				if (wt_global_information.TargetIgnorelist ~= nil and (wt_global_information.TargetIgnorelist[E.contentID] == nil or wt_global_information.TargetIgnorelist[E.contentID] > E.health.percent)) and
				(wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[id] == nil) then
					wt_core_taskmanager:addKillTask( id, E, 3000 )
					MultiBotSend( "6;"..tonumber(id),"gw2minion" )	-- Inform leader about our aggro target
					return true
				end
			end
		end
	return false
	end
end
table.insert(wt_core_state_minion.TaskChecks,{["func"]=wt_core_state_minion.aggroCheck, ["throttle"]=500})

--Throttle = 500
function wt_core_state_minion.aggroGadgetCheck()
	--wt_debug("aggroCheck")
	if ( gAttackGadgets == "1")then
	if ( wt_global_information.DoAggroCheck ) then
		local GList = ( GadgetList( "attackable,alive,nearest,los,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
		if ( TableSize( GList ) > 0 ) then
			local id, E  = next( GList )
			if ( id ~= nil and id ~= 0 and E ~= nil and wt_core_state_gcombat.Blacklist[E.contentID2] == nil) then
				if (wt_global_information.TargetIgnorelist ~= nil and (wt_global_information.TargetIgnorelist[E.contentID] == nil or wt_global_information.TargetIgnorelist[E.contentID] > E.health.percent)) and
				(wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[id] == nil) then
					wt_core_taskmanager:addKillGadgetTask( id, E, 3000 )
					return false
				end
			end
		end
	end
	end
end
table.insert(wt_core_state_minion.TaskChecks,{["func"]=wt_core_state_minion.aggroGadgetCheck,["throttle"]=1000})