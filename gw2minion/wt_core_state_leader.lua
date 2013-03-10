-- The Leader State

wt_core_state_leader = inheritsFrom(wt_core_state)
wt_core_state_leader.name = "Leader"
wt_core_state_leader.kelement_list = { } 
wt_core_state_minion.LeadBroadcastTmr = nil


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
		wt_debug("Cannot reach MultibotComServer... Make sure you have started the MultibotComServer.exe and the correct Password,IP and Port!")
	else
		MultiBotJoinChannel("remotecmd")
		MultiBotJoinChannel("gw2minion")
		wt_debug("Joined channels !")
	end	
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
	if ( gEnableRepair == "1" and IsEquipmentBroken() ) then
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
-- Try to hold the Group together Cause & Effect
local c_buildgrp = inheritsFrom( wt_cause )
local e_buildgrp = inheritsFrom( wt_effect )

function c_buildgrp:evaluate()
	if (gMinionstick == "1") then 
		local party = Player:GetPartyMembers()
		if (party ~= nil ) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.distance > 1200 and player.onmesh) then
					return true
				end
				index, player  = next( party,index )
			end		
		end
	end	
	return false
end
e_buildgrp.throttle = math.random(500,1000)
function e_buildgrp:execute()
	-- Making sure the group sticks together
	if (gMinionstick == "1") then 
		local party = Player:GetPartyMembers()
		if (party ~= nil ) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.onmesh) then
					if (player.distance > 2000 ) then
						local pos = player.pos
						--TODO: Getmovementstate of player, adopt range accordingly
						Player:MoveTo(pos.x,pos.y,pos.z,math.random( 20, 350 ))
						return
					elseif(player.distance <= 2000 and player.distance > 1200) then
						wt_debug("Waiting for Partymembers to get to us")
						Player:StopMoving()
						return
					end
				end
				index, player  = next( party,index )
			end		
		end
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
	-- To prevent fuckups, broadcast that we are the leader every 60 seconds / Check if this is still needed!
	if ( wt_core_state_leader.LeadBroadcastTmr == nil or (wt_global_information.Now - wt_core_state_leader.LeadBroadcastTmr > 30000)) then
		wt_core_state_leader.LeadBroadcastTmr = wt_global_information.Now
		MultiBotSend( "3;"..Player.characterID,"gw2minion" )
		return
	end	
	wt_core_taskmanager:DoTask()
end
 
 
 
 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- C&E's attached to other states:

-- MultiBotComServerConnect Cause & Effect fpr the idle state
local c_iamminion = inheritsFrom( wt_cause )
local e_iamminion = inheritsFrom( wt_effect )
function c_iamminion:evaluate()
	if (gMinionEnabled == "1") then		
		return true
	end	
	return false
end
function e_iamminion:execute()	
	if (wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID) then
		wt_debug( "Switching to Groupbotting Mode - Leader" )
		wt_core_controller.requestStateChange( wt_core_state_leader )
	else
		wt_debug( "Switching to Groupbotting Mode - Minion" )
		wt_core_controller.requestStateChange( wt_core_state_minion )
	end
end



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
---------------------------------------------------------------------
-- HandleMultiBotMessages
function HandleMultiBotMessages( event, message, channel )	
--d("MBM:" .. message)		
	if ( wt_core_controller.shouldRun and gMinionEnabled == "1" and MultiBotIsConnected( ) ) then				
		if (channel == "gw2minion" ) then
			
			local delimiter = message:find(';')
			if (delimiter ~= nil and delimiter ~= 0) then
				local msgID = message:sub(0,delimiter-1)
				local msg = message:sub(delimiter+1)
				--d("msgID:" .. msgID)
				--d("msg:" .. msg)
				if (msgID ~= nil and msg ~= nil ) then
					if( tonumber(msgID) == 1 ) then -- Ask for leader
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID) then
							MultiBotSend( "2;"..wt_global_information.LeaderID,"gw2minion" )
						end
					elseif ( tonumber(msgID) == 2 ) then -- Set Leader to the one with the smallest ID (no idea how to do this in a better way yet...)
						if ( wt_global_information.LeaderID == nil or wt_global_information.LeaderID > tonumber(msg)) then
							wt_global_information.LeaderID = tonumber(msg)
							wt_debug( "New Leader is characterID : "..tostring(msg) )
						end
						if ( wt_core_controller.state ~= nil and wt_core_controller.state == wt_core_state_leader and wt_global_information.LeaderID ~= Player.characterID) then
							wt_core_controller.requestStateChange( wt_core_state_minion )
						end
					elseif ( tonumber(msgID) == 3 ) then -- Claim Leader			
						wt_global_information.LeaderID = tonumber(msg)
						wt_debug( "Leadership got claimed by characterID : "..tostring(msg) )
						if ( wt_core_controller.state ~= nil and wt_core_controller.state == wt_core_state_leader and wt_global_information.LeaderID ~= Player.characterID) then
							wt_core_controller.requestStateChange( wt_core_state_minion )
						end						
					elseif ( tonumber(msgID) == 5 ) then -- Set FocusTarget
						--wt_debug( "FocusTarget is characterID : "..tonumber(msg) )
						wt_global_information.FocusTarget = tonumber(msg)
					elseif ( tonumber(msgID) == 6 ) then -- Inform leader about party-aggro-target
						local newTarget = CharacterList:Get(tonumber(msg))
						if (newTarget ~= nil and wt_global_information.PartyAggroTargets ~= nil and wt_global_information.PartyAggroTargets[tonumber(msg)] == nil and newTarget.distance ~= nil and newTarget.distance < 4500 and newTarget.alive ) then 
							wt_debug( "Adding new PartyAggroTarget to List : "..tostring(msg) )
							wt_global_information.PartyAggroTargets[tonumber(msg)] = newTarget
						end						
					elseif ( tonumber(msgID) == 10 ) then -- A minion needs to Vendor, set our Primary task accordingly
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID  == Player.characterID) then
							wt_debug( "A Minion needs to vendor, going to Vendor" )
							wt_core_taskmanager:addVendorTask({task_type = "party", priority = 10001})
						end
					elseif ( tonumber(msgID) == 11 ) then -- Leader tells Minions to Vendor
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID ) then
							wt_debug( "Leader sais we should Vendor now.." )
							local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
							if ( TableSize( EList ) > 0 ) then			
								local nextTarget
								nextTarget, E = next( EList )
								if ( nextTarget ~= nil and nextTarget ~= 0) then
									wt_core_state_vendoring.setTarget( nextTarget )
									wt_core_controller.requestStateChange( wt_core_state_vendoring )				
								end
							end		
						end					
					elseif ( tonumber(msgID) == 15 ) then -- A minion needs to Repair, set our Primary task accordingly
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID  == Player.characterID) then
							wt_debug( "A Minion needs to repair, going to Merchant" )
							wt_core_taskmanager:addRepairTask({task_type = "party", priority = 10001})
						end
					elseif ( tonumber(msgID) == 16 ) then -- Leader tells Minions to Repair
						if ( gEnableRepair == "1" and IsEquipmentBroken() and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID ) then
							wt_debug( "Leader sais we should Repair now.." )
							local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
							if ( TableSize( EList ) > 0 ) then			
								local nextTarget
								nextTarget, E = next( EList )
								if ( nextTarget ~= nil and nextTarget ~= 0) then
									wt_core_state_repair.setTarget( nextTarget )
									wt_core_controller.requestStateChange( wt_core_state_repair )										
								end
							end		
						end
					elseif ( tonumber(msgID) == 20 ) then -- Tell Minions to Teleport - Set TargetWaypointID
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID) then
							wt_debug( "Leader sais we need to teleport - recieved TargetWaypointID" )
							wt_global_information.TargetWaypointID = tonumber(msg)
						end
					elseif ( tonumber(msgID) == 21 ) then -- Tell Minions to Teleport - Set TargetMapID
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID) then
							wt_debug( "Leader sais we need to teleport - recieved TargetMapID" )
							NavigationManager:SetTargetMapID(tonumber(msg))
						end
					elseif ( tonumber(msgID) == 50 ) then -- Tell Minions to Load a Mesh
						if ( wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID ~= Player.characterID) then
							wt_debug( "Leader sais we need should (re)load our navmesh :"..tostring(msg) )
							mm.UnloadNavMesh()
							mm.LoadNavMesh(tostring(msg))
						end					
					end
				end
			end
		end
	end
end

function wt_core_state_leader.ClaimLead( Event ) 
	if ( MultiBotIsConnected( ) ) then
		wt_debug( "Claiming leadership.." )
		wt_global_information.LeaderID = Player.characterID
		wt_core_state_leader.name = "Beeing Leader"
		MultiBotSend( "3;"..wt_global_information.LeaderID,"gw2minion" )
	end
end

-------------------------------------------------------------
-------------------------------------------------------------
--Group botting general functions
function wt_core_state_leader.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gMinionEnabled" or k == "gIP" or k == "gPort" or k == "gMinionstick" or k == "gPw" or k == "gStats_enabled") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_core_state_leader:HandleInit() 
	GUI_NewLabel(wt_global_information.MainWindow.Name,"THE HOST NEEDS TO START THE","GroupBotting");
	GUI_NewLabel(wt_global_information.MainWindow.Name,"MultiBotComServer.exe!!","GroupBotting");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable BrowserStats","gStats_enabled","GroupBotting");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Groupbotting","gMinionEnabled","GroupBotting");
	GUI_NewField(wt_global_information.MainWindow.Name,"MultiBotComServer IP","gIP","GroupBotting");
	GUI_NewField(wt_global_information.MainWindow.Name,"MultiBotComServer Port","gPort","GroupBotting");
	GUI_NewField(wt_global_information.MainWindow.Name,"MultiBotComServer Password","gPw","GroupBotting");
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	GUI_NewButton(wt_global_information.MainWindow.Name, "Claim Leadership" , "Claimlead.Event","GroupBotting")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Always stick together","gMinionstick","GroupBotting");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"GroupBotting");
	
	gStats_enabled = Settings.GW2MINION.gStats_enabled
	gMinionEnabled = Settings.GW2MINION.gMinionEnabled
	gIP = Settings.GW2MINION.gIP
	gPort = Settings.GW2MINION.gPort
	gPw = Settings.GW2MINION.gPw	
	gMinionstick = Settings.GW2MINION.gMinionstick
	 
	
	-- Add to other states only after all files have been loaded
	local ke_iamminion = wt_kelement:create( "MultiBotServerCheck", c_iamminion, e_iamminion, 250 )
	wt_core_state_idle:add( ke_iamminion )

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
	if ( Settings.GW2MINION.gMinionstick == nil ) then
		Settings.GW2MINION.gMinionstick = "1"
	end
	if ( Settings.GW2MINION.gPw == nil ) then
		Settings.GW2MINION.gPw = "mypassword"
	end
	
	RegisterEventHandler("Claimlead.Event",wt_core_state_leader.ClaimLead)
	RegisterEventHandler("Module.Initalize",wt_core_state_leader.HandleInit)
	RegisterEventHandler("GUI.Update",wt_core_state_leader.GUIVarUpdate)
	RegisterEventHandler("MULTIBOT.Message",HandleMultiBotMessages)
	
	-- State C&E
	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_leader:add( ke_died )
	
	local ke_checkServer = wt_kelement:create( "CheckServer", c_server, e_server, 450 )
	wt_core_state_leader:add( ke_checkServer )
		
	local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 110 )
	wt_core_state_leader:add( ke_quickloot )
	
	local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 105 )
	wt_core_state_leader:add( ke_quicklootchest )	

	local ke_doemergencytasks = wt_kelement:create( "DoEmergencyTask", c_doemergencytask, e_doemergencytask, 104 )
	wt_core_state_leader:add( ke_doemergencytasks )
	
	local ke_rezzparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 102 )
	wt_core_state_leader:add( ke_rezzparty )
	
	local ke_maggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_leader:add( ke_maggro )
	
	local ke_switchmesh = wt_kelement:create( "SwitchNavMesh", c_navswitch, e_navswitch, 92 )
	wt_core_state_leader:add( ke_switchmesh )
	
	local ke_deposit = wt_kelement:create( "DepositItems", c_deposit, e_deposit, 90 )
	wt_core_state_leader:add( ke_deposit )
	--salvaging 89
	
	local ke_dopriotasks = wt_kelement:create( "DoPrioTask", c_dopriotask, e_dopriotask, 88 )
	wt_core_state_leader:add( ke_dopriotasks )
	
	local ke_vendorcheck = wt_kelement:create( "VendoringCheck", c_vendorcheck, e_vendorcheck, 87 )
	wt_core_state_leader:add( ke_vendorcheck )

	local ke_repaircheck = wt_kelement:create( "RepairCheck", c_repaircheck, e_repaircheck, 86 )
	wt_core_state_leader:add( ke_repaircheck )
	
	local ke_revive = wt_kelement:create( "Revive", c_check_revive, e_revive, 80 )
	wt_core_state_leader:add( ke_revive )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_leader:add( ke_rest )
	
	local ke_loot = wt_kelement:create("Loot", c_check_loot, e_loot, 50 )
	wt_core_state_leader:add( ke_loot )

	local ke_lootchests = wt_kelement:create("LootChest", c_lootchest, e_lootchest, 49 )
	wt_core_state_leader:add( ke_lootchests )
	
	local ke_gather = wt_kelement:create( "Gather", c_check_gatherable, e_gather, 40 )
	wt_core_state_leader:add( ke_gather )
	
	local ke_buildgrp = wt_kelement:create( "Grouping", c_buildgrp, e_buildgrp, 15 )
	wt_core_state_leader:add( ke_buildgrp )
	
	local ke_lead = wt_kelement:create( "Lead", c_lead, e_lead, 10 )
	wt_core_state_leader:add( ke_lead )
	
end

wt_core_state_leader:initialize()
wt_core_state_leader:register()