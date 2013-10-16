-- The Leader State

wt_core_state_leader = inheritsFrom(wt_core_state)
wt_core_state_leader.name = "Leader"
wt_core_state_leader.kelement_list = { } 
wt_core_state_minion.LeadBroadcastTmr = 0
wt_core_state_leader.TaskChecks = {}


-- Aggro is in wt_common_causes


-- DepositItems is in wt_common_causes

-- Search for Reviveable Partymembers is in wt_common_causes
  
  
-- Search for Reviveable Targets is in wt_common_causes


-- Loot is in wt_common_causes


-- LootChest is in wt_common_causes


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
-- Try to hold the Group together Cause & Effect
c_buildgrp = inheritsFrom( wt_cause )
e_buildgrp = inheritsFrom( wt_effect )
c_buildgrp.needtowait = false
c_buildgrp.needtowaitTmr = 0
function c_buildgrp:evaluate()
	if (c_buildgrp.needtowait == true) then		
		return true
	end
	
	local party = Player:GetPartyMembers()
	if (party ~= nil ) then
		local index, player  = next( party )
		while ( index ~= nil and player ~= nil ) do			
			if ((player.distance > 2000 and player.onmesh)) then
				return true
			end
			index, player  = next( party,index )
		end		
	end
	c_buildgrp.needtowait = false
	c_buildgrp.needtowaitTmr = 0
	return false
end
e_buildgrp.throttle = math.random(1500,2500)
function e_buildgrp:execute()
	local party = Player:GetPartyMembers()
	if (party ~= nil ) then
		local index, player  = next( party )
		while ( index ~= nil and player ~= nil ) do			
			if (player.onmesh and player.distance > 1200) then
				if (c_buildgrp.needtowait) then
					if (c_buildgrp.needtowaitTmr ~= 0 and wt_global_information.Now - c_buildgrp.needtowaitTmr > 5000) then
						c_buildgrp.needtowait = false
						return
					end
				end
				local rdist = math.random(1800,3500)
				if (player.distance > rdist ) then
					local pos = player.pos
					--TODO: Getmovementstate of player, adopt range accordingly
					Player:MoveTo(pos.x,pos.y,pos.z,1000)
					c_buildgrp.needtowait = true
					c_buildgrp.needtowaitTmr = wt_global_information.Now
					return
				elseif(player.distance <= rdist and player.distance > 2500 and c_buildgrp.needtowait == false) then
					wt_debug("Waiting for Partymembers to get to us")
					Player:StopMoving()
					c_buildgrp.needtowait = true
					c_buildgrp.needtowaitTmr = wt_global_information.Now
					return
				end
			end
			index, player  = next( party,index )
		end	
		c_buildgrp.needtowait = false
		c_buildgrp.needtowaitTmr = 0
	end
end


------------------------------------------------------------------------------
-- Lead Group Cause & Effect
local c_lead = inheritsFrom( wt_cause )
local e_lead = inheritsFrom( wt_effect )
function c_lead:evaluate()	
	return true
end
function e_lead:execute()
	wt_core_taskmanager:DoTask()
end
 
 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- C&E's attached to other states:


------------------------------------------------------------------------------
-- BroadCastFocusTarget Cause & Effect for the combat state
local c_setfocust = inheritsFrom( wt_cause )
local e_setfocust = inheritsFrom( wt_effect )
function c_setfocust:evaluate()
	if (gMinionEnabled == "1" and MultiBotIsConnected( )) then
		if ( wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0) then
			local T = CharacterList:Get( wt_core_state_combat.CurrentTarget )
			if ( T ~= nil and T.alive and ( T.attitude == 1 or T.attitude == 2 ) and T.onmesh) then
				if ( wt_core_state_leader.FocusTargetBroadcastTmr == nil or (wt_global_information.Now - wt_core_state_leader.FocusTargetBroadcastTmr > 1000)) then
					wt_core_state_leader.FocusTargetBroadcastTmr = wt_global_information.Now					
					MultiBotSend( "5;"..wt_core_state_combat.CurrentTarget,"gw2minion" )
					return false -- we always return false since we don't want to make the bot stop here
				end
			end
		end
	end
	return false
end
function e_setfocust:execute()
	return 
end


--[[function wt_core_state_leader.ClaimLead( Event ) 
	if ( MultiBotIsConnected( ) ) then
		wt_debug( "Claiming leadership.." )
		if (tonumber(Player.characterID) ~= nil) then
			MultiBotSend( "1;"..tonumber(Player.characterID),"gw2minion" )
		end
		wt_core_controller.requestStateChange( wt_core_state_idle )
	end
end]]

-------------------------------------------------------------
-------------------------------------------------------------
--Group botting general functions
function wt_core_state_leader.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gMinionEnabled" or k == "gIP" or k == "gPort" or k == "gPw" or k == "gStats_enabled") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_core_state_leader:HandleInit()
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].browserStats,"gStats_enabled",strings[gCurrentLanguage].groupBotting);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].groupBotting,"gMinionEnabled",strings[gCurrentLanguage].groupBotting);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].serverIP,"gIP",strings[gCurrentLanguage].groupBotting);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].serverPort,"gPort",strings[gCurrentLanguage].groupBotting);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].serverPW,"gPw",strings[gCurrentLanguage].groupBotting);	
	--GUI_NewButton(wt_global_information.MainWindow.Name, "Claim Leadership" , "Claimlead.Event",strings[gCurrentLanguage].groupBotting)
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].groupBotting);
	
	gStats_enabled = Settings.GW2MINION.gStats_enabled
	gMinionEnabled = Settings.GW2MINION.gMinionEnabled
	gIP = Settings.GW2MINION.gIP
	gPort = Settings.GW2MINION.gPort
	gPw = Settings.GW2MINION.gPw	
	 
	
	-- Add to other states only after all files have been loaded

	local ke_setfocust = wt_kelement:create( "SendFocusTarget", c_setfocust, e_setfocust, 126 )
	wt_core_state_combat:add( ke_setfocust )	
end

function wt_core_state_leader:initialize()

	-- State GUI Options
	if ( Settings.GW2MINION.gMinionEnabled == nil ) then
		Settings.GW2MINION.gMinionEnabled = "0"
	end
	if ( Settings.GW2MINION.gIP == nil ) then
		Settings.GW2MINION.gIP = "127.0.0.1"
	end
	if ( Settings.GW2MINION.gPort == nil ) then
		Settings.GW2MINION.gPort = "7777"
	end
	if ( Settings.GW2MINION.gPw == nil ) then
		Settings.GW2MINION.gPw = "mypw"
	end
	
	--RegisterEventHandler("Claimlead.Event",wt_core_state_leader.ClaimLead)
	RegisterEventHandler("Module.Initalize",wt_core_state_leader.HandleInit)
	RegisterEventHandler("GUI.Update",wt_core_state_leader.GUIVarUpdate)	
	
	-- State C&E
	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_leader:add( ke_died )
	
	local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 110 )
	wt_core_state_leader:add( ke_quickloot )
	
	--local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 105 )
	--wt_core_state_leader:add( ke_quicklootchest )
	
	local ke_movecheck = wt_kelement:create( "MovementCheck", c_stopcbmove, e_stopcbmove, 107 )
	wt_core_state_leader:add( ke_movecheck )
	
	local ke_skillstuckcheck = wt_kelement:create( "UnStuckSkill", c_skillstuckcheck, e_skillstuckcheck, 105 )
	wt_core_state_leader:add( ke_skillstuckcheck )

	local ke_lootchests = wt_kelement:create("LootChest", c_lootchest, e_lootchest, 104 )
	wt_core_state_leader:add( ke_lootchests )

	local ke_doemertasks = wt_kelement:create( "EmergencyTask", c_doemergencytask, e_doemergencytask, 103 )
	wt_core_state_leader:add( ke_doemertasks )
	
	local ke_rezzparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 102 )
	wt_core_state_leader:add( ke_rezzparty )
	
	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 90 )
	wt_core_state_leader:add( ke_deposit )
	
	--salvaging 89

	local ke_loot = wt_kelement:create("Loot", c_check_loot, e_loot, 88 )
	wt_core_state_leader:add( ke_loot )
	
	local ke_revive_players = wt_kelement:create( "RevivePlayers", c_check_revive_players, e_revive_players, 87 )
	wt_core_state_leader:add( ke_revive_players )
	
	local ke_dopriotasks = wt_kelement:create( "PrioTask", c_dopriotask, e_dopriotask, 85 )
	wt_core_state_leader:add( ke_dopriotasks )
	
	local ke_revive = wt_kelement:create( "Revive", c_check_revive, e_revive, 80 )
	wt_core_state_leader:add( ke_revive )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_leader:add( ke_rest )
	
	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_leader:add( ke_gather )
	
	local ke_buildgrp = wt_kelement:create( "Grouping", c_buildgrp, e_buildgrp, 15 )
	wt_core_state_leader:add( ke_buildgrp )
	
	local ke_lead = wt_kelement:create( "Lead", c_lead, e_lead, 10 )
	wt_core_state_leader:add( ke_lead )
	
end

wt_core_state_leader:initialize()
wt_core_state_leader:register()

--Only put tasks here which are leader bot specific...any other tasks that are shared
--should go in wt_core_taskmanager:Update_Tasks()

--UID = "REPAIR"
--Throttle = 2500
function wt_core_state_leader:repairCheck()
	if ( gEnableRepair == "1" and NeedRepair() and not wt_core_taskmanager:CheckTaskQueue("REPAIR")) then
		local vendor = wt_core_helpers:GetClosestRepairVendor(999999)
		if (vendor) then
			wt_core_taskmanager:addRepairTask(5000, vendor)
			wt_core_taskmanager:addVendorTask(4500, vendor)
			return true
		end
	end	
	return false
end
table.insert(wt_core_state_leader.TaskChecks,{["func"]=wt_core_state_leader.repairCheck, ["throttle"]=2500})

--UID = "VENDORSELL"
--Throttle = 2500
function wt_core_state_leader:vendorSellCheck()
	if ( ItemList.freeSlotCount <= 3 and wt_global_information.InventoryFull == 1 and not wt_core_taskmanager:CheckTaskQueue("VENDORSELL")) then
		if (wt_core_items:CanVendor()) then
			local vendor = wt_core_helpers:GetClosestSellVendor(999999)
			if (vendor) then
				wt_core_taskmanager:addVendorTask(4500, vendor)
				return true
			else
				wt_debug("Need to vendor but no suitable vendor found on mesh - check your mesh to ensure it contains coins or broken shield icon")
			end
		else
			wt_debug("Need to vendor but you have nothing that can be vendored - check your settings!")
		end
	end
	return false
end
table.insert(wt_core_state_leader.TaskChecks,{["func"]=wt_core_state_leader.vendorSellCheck, ["throttle"]=2500})

--UID = "VENDORBUY..."
--Throttle = 2500
function wt_core_state_leader:vendorBuyCheck()
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
		local vendor = wt_core_helpers:GetClosestBuyVendor(999999)
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
		end
	end
	
	return false
end
table.insert(wt_core_state_leader.TaskChecks,{["func"]=wt_core_state_leader.vendorBuyCheck, ["throttle"]=2500})

--Throttle = 500
function wt_core_state_leader:aggroCheck()
	if ( wt_global_information.DoAggroCheck ) then
		local TList = ( CharacterList( "attackable,alive,noCritter,nearest,los,incombat,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				if (wt_global_information.TargetIgnorelist ~= nil and (wt_global_information.TargetIgnorelist[E.contentID] == nil or wt_global_information.TargetIgnorelist[E.contentID] > E.health.percent)) and
				(wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[id] == nil) then
					wt_core_taskmanager:addKillTask( id, E, 3000 )
					return true
				end
			end
		end
		
		local TList = ( CharacterList( "nearest,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				if (wt_global_information.TargetIgnorelist ~= nil and (wt_global_information.TargetIgnorelist[E.contentID] == nil or wt_global_information.TargetIgnorelist[E.contentID] > E.health.percent)) and
				(wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[id] == nil) then
					wt_core_taskmanager:addKillTask( id, E, 2500 )
					return true
				end
			end
		end
	return false
	end
end
table.insert(wt_core_state_leader.TaskChecks,{["func"]=wt_core_state_leader.aggroCheck, ["throttle"]=500})

--Throttle = 500
function wt_core_state_leader.aggroGadgetCheck()
	--wt_debug("aggroCheck")
	if ( gAttackGadgets == "1")then
	if ( wt_global_information.DoAggroCheck ) then
		if ( Player.inCombat ) then
			local GList = ( GadgetList( "attackable,alive,nearest,los,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
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
		
		--[[local GList = ( GadgetList( "attackable,alive,nearest,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
		if ( TableSize( GList ) > 0 ) then
			local id, E  = next( GList )
			if ( id ~= nil and id ~= 0 and E ~= nil) then
				wt_core_taskmanager:addKillGadgetTask( id, E, 3500 )
				return false
			end		
		end	]]
	end
	end
end
table.insert(wt_core_state_leader.TaskChecks,{["func"]=wt_core_state_leader.aggroGadgetCheck,["throttle"]=1000})
