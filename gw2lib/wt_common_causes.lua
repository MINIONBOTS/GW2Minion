-- common causes uses by the system
-- those can easily be used in compound cause objects to check
-- for multiple causes at once


DebugModes = { Revive = { Master = true, TID = nil, state = false, Move = true, Revive = true, NoTarget = true }, Loot = { Master = true, state = false, Size = 0, index = nil, TSize = true, Move = true } ,LootChest = { Master = true, state = false, Size = 0, index = nil, TSize = true, Move = true }}
-- DebugModes.Revive.TID -- Target ID
-- DebugModes.Revive.Master -- Master Revive Debug message switch ( true / false ) if true do debug messages, if false don't do debug messages.
-- DebugModes.state
-- DebugModes.Revive.Move -- true = keep spamming the debug message
-- DebugModes.Revive.Revive -- true = keep spamming the debug message
-- DebugModes.Revive.NoTarget -- true = create debug message for No Revive Target
	
-- DebugModes.Loot.Size -- Table size of Loot Target table
-- DebugModes.Loot.index -- Target ID of Loot Target
-- DebugModes.Loot.Master -- Master Loot Debug message switch ( true / false ) if true do debug messages, if false don't do debug messages.
-- DebugModes.Loot.state


--**********************************************
-- NavMeshSwitch C&E
--**********************************************
c_navswitch = inheritsFrom( wt_cause )
e_navswitch = inheritsFrom( wt_effect )
function c_navswitch:evaluate()	
	if ( gNavSwitchEnabled == "1" and  not Player.inCombat) then	
		-- CHECK IF NEW MAP WAS SET ALREADY					
		if ( NavigationManager:GetTargetMapID() ~= 0 and NavigationManager:GetTargetMapID() ~= Player:GetLocalMapID()) then
			wt_debug("We need to Teleport!")					
			return true
		else
			NavigationManager:SetTargetMapID(0)		
		end
		
		-- CHECK IF IT IS TIME TO SWITCH MAPS		
		if (gMinionEnabled == "0" or (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1)) then			
			-- SOLO OR LEADER			
			gMapswitch = math.floor(((gNavSwitchTime * 60000) - (wt_global_information.Now - mm.lastswitchTmr)) / 1000)
			
			if (mm.lastswitchTmr == 0 ) then
				mm.lastswitchTmr = wt_global_information.Now
			elseif ( mm.GetmeshfilelistSize() > 1 and (wt_global_information.Now - mm.lastswitchTmr > (gNavSwitchTime * 60000))) then
				mm.lastswitchTmr = wt_global_information.Now
				
				local mapindex = math.random(1,mm.GetmeshfilelistSize())
				local lmapid = Player:GetLocalMapID()
				for i,meshfile in pairs(mm.meshfilelist) do	
					if (i~=nil and meshfile ~= nil and i == mapindex and lmapid ~= nil) then
						if ( tonumber(meshfile.MapID) ~= lmapid  ) then	
							if ( meshfile.WPIDList ~= nil ) then
								local newWP = meshfile.WPIDList[ math.random( TableSize(meshfile.WPIDList) ) ]
								wt_debug("Teleport to MapID: "..tostring(meshfile.MapID).. " / WaypointID: "..tostring(newWP))
								Settings.GW2MINION.TargetWaypointID = newWP								
								NavigationManager:SetTargetMapID(tonumber(meshfile.MapID))
								--  SEND TO MINIONS
								if (gMinionEnabled == "1") then	
									MultiBotSend( "20;"..tostring(newWP),"gw2minion" )
									MultiBotSend( "21;"..tostring(meshfile.MapID),"gw2minion" )
								end
								return true								
							end	
						end							
					end
				end
			end
		else
			gMapswitch = 0
		end		
	end
	return false
end
e_navswitch.throttle = 2500
e_navswitch.counter = 0
function e_navswitch:execute()	
	wt_debug("Switching NavMesh to MapID:" ..tostring(NavigationManager:GetTargetMapID()).." / WaypointID: "..tostring(Settings.GW2MINION.TargetWaypointID))
	if (Inventory:GetInventoryMoney() > 500) then
		if (tonumber(Settings.GW2MINION.TargetWaypointID) ~= nil and tonumber(Settings.GW2MINION.TargetWaypointID) ~= 0 and tonumber(NavigationManager:GetTargetMapID())~=nil and tonumber(NavigationManager:GetTargetMapID())~=0) then
			Player:StopMoving()			
			Player:TeleportToWaypoint(tonumber(Settings.GW2MINION.TargetWaypointID))
			e_navswitch.counter = e_navswitch.counter + 1
		else
			wt_error("Something went wrong while switching the navmesh")
		end	
		
		if (e_navswitch.counter > 3) then
			wt_error("Seems we cannot teleport to WaypointID : "..tostring(Settings.GW2MINION.TargetWaypointID))
			wt_error("Is this Waypoint not explored for this character?")
			e_navswitch.counter = 0
			NavigationManager:SetTargetMapID(0)
		end
	else
		wt_error("Whoooops, we don't have enough money for teleporting?!?")
		NavigationManager:SetTargetMapID(0)	
	end
end



--**********************************************
-- Death Check
--**********************************************
c_died = inheritsFrom( wt_cause )
e_died = inheritsFrom( wt_effect )
function c_died:evaluate()
	if ( Player.alive ~= true ) then
		return true
	end
	return false
end
function e_died:execute()
	Player:ClearTarget()
	Player:StopMoving()
	wt_core_controller.requestStateChange( wt_core_state_dead )
end



--***********************************************************
-- QuickLoot Cause & Effect (looting just the things that are in range already, this we can do while beeing infight)
--***********************************************************
c_quickloot = inheritsFrom( wt_cause )
e_quickloot = inheritsFrom( wt_effect )
function c_quickloot:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_quickloot.EList = CharacterList( "nearest,lootable,onmesh,maxdistance=120" )
		NextIndex, LootTarget = next( c_quickloot.EList )
		if ( NextIndex ~= nil ) then
			if ( NextIndex == Player:GetInteractableTarget() ) then
				return true
			end
		end
		--stupidcheck since some enemies are not marked as lootable but they are lootable
		local e = Player:GetInteractableTarget()
		if ( e ~= nil ) then
			etable = CharacterList:Get( e )
			if ( etable ~= nil ) then
				if ( etable.healthstate == GW2.HEALTHSTATE.Defeated and ( etable.attitude == GW2.ATTITUDE.Hostile or etable.attitude == GW2.ATTITUDE.Neutral ) and etable.isMonster ) then
					return true
				end
			end
		end
	end
	return false
end
e_quickloot.n_index = nil
e_quickloot.throttle = math.random( 150, 450 )
function e_quickloot:execute()
 	local NextIndex = 0
	local LootTarget = nil
	if (c_quickloot.EList ~= nil ) then
		NextIndex, LootTarget = next( c_quickloot.EList )
		if ( NextIndex ~= nil and NextIndex == Player:GetInteractableTarget() ) then
			if ( e_quickloot.n_index  ~= NextIndex ) then
				e_quickloot.n_index  = NextIndex
				wt_debug( "QuickLooting" )
			end
			Player:Interact( NextIndex )
		else
			local e = Player:GetInteractableTarget()
			if ( e ~= nil ) then
				etable = CharacterList:Get( e )
				if ( etable ~= nil ) then
					if ( etable.healthstate == GW2.HEALTHSTATE.Defeated and ( etable.attitude == GW2.ATTITUDE.Hostile or etable.attitude == GW2.ATTITUDE.Neutral ) and etable.isMonster ) then
						if ( e_quickloot.n_index  ~= e ) then
							e_quickloot.n_index  = e
							wt_debug( "QuickLooting" )
						end
						Player:Interact( e )
						return
					end
				end
			end
		end
	end
	wt_debug( "No Target to Quick-Loot" )
end


--********************************************************************
-- QuickLoot Chests Cause & Effect (looting just the things that are in range already, this we can do while beeing infight)
--********************************************************************
c_quicklootchest = inheritsFrom( wt_cause )
e_quicklootchest = inheritsFrom( wt_effect )
function c_quicklootchest:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_lootchest.EList = GadgetList("nearest,maxdistance=120,onmesh") --old contentID=198260
		if ( TableSize( c_lootchest.EList ) > 0 ) then			
			local index, LT = next( c_lootchest.EList )
			while ( index ~= nil and LT~=nil ) do
				if ( LT.isselectable == 1 and (LT.contentID == 198260 or LT.contentID == 232192 or LT.contentID == 232193 or LT.contentID == 232194)) then
					return true
				end
				index, LT = next( c_lootchest.EList,index )
			end
		end	
	end
	return false
end
e_quicklootchest.n_index = nil
e_quicklootchest.throttle = math.random( 150, 450 )
function e_quicklootchest:execute()
 	if ( TableSize( c_lootchest.EList ) > 0 ) then
		local chest,ID = nil
		local index, LT = next( c_lootchest.EList )
		while ( index ~= nil and LT~=nil ) do
			if ( LT.isselectable == 1 and (LT.contentID == 198260 or LT.contentID == 232192 or LT.contentID == 232193 or LT.contentID == 232194)) then
				chest = LT
				ID = index
				break
			end
			index, LT = next( c_lootchest.EList,index )
		end
		
		if ( chest ~= nil and ID ~= nil ) then	
			if ( ID == Player:GetInteractableTarget() ) then					
				wt_debug( "QuickLooting Chest ID:"..tostring(ID))					
				Player:Use( ID )				
			elseif (ID ~= Player:GetInteractableTarget()) then
				Player:StopMoving()
				wt_debug( "Targeting Chest" )					
				Player:SetTarget(ID)
			end
		end
	else
		wt_debug( "Idle: No Chest to Loot found" )
	end	
end


--*************************************************************
-- GROUP BOTTING Aggro Cause & Effect
-- I'm abusing the C&E System a bit ;) by using the c_groupaggro:evaluate() to add "Kill Tasks" to the Tasklist
-- These Kill Tasks are then performing the state change to combat
--*************************************************************
c_groupaggro = inheritsFrom( wt_cause )
e_groupaggro = inheritsFrom( wt_effect )
function c_groupaggro:evaluate()
	-- GROUP BOTTING
	if (gMinionEnabled == "1" and MultiBotIsConnected( )) then
		
		-- LEADER
		if ( Player:GetRole() == 1 ) then	
			local TList = ( CharacterList( "attackable,alive,noCritter,nearest,los,incombat,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
			if ( TableSize( TList ) > 0 ) then
				local id, E  = next( TList )
				if ( id ~= nil and id ~= 0 and E ~= nil) then
					wt_core_taskmanager:addKillTask( id, E, 3000 )
					return false
				end		
			end	
			
			local TList = ( CharacterList( "nearest,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
			if ( TableSize( TList ) > 0 ) then
				local id, E  = next( TList )
				if ( id ~= nil and id ~= 0 and E ~= nil) then
					wt_core_taskmanager:addKillTask( id, E, 2500 )
					return false
				end		
			end	
					
		
		-- MINION
		else
			local TList = ( CharacterList( "nearest,los,incombat,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
			if ( TableSize( TList ) > 0 ) then
				local id, E  = next( TList )
				if ( id ~= nil and id ~= 0 and E ~= nil) then
					wt_core_taskmanager:addKillTask( id, E, 3000 )
					MultiBotSend( "6;"..tonumber(id),"gw2minion" )	-- Inform leader about our aggro target
					return false
				end		
			end
		end		
	end	
	return false
end
function e_groupaggro:execute()
	return false
end


--*************************************************************
-- SOLO Aggro Cause & Effect
--*************************************************************
c_aggro = inheritsFrom( wt_cause )
e_aggro = inheritsFrom( wt_effect )
function c_aggro:evaluate()
	-- SOLO BOTTING
	if ( Player.inCombat ) then
		local TList = ( CharacterList( "attackable,alive,noCritter,nearest,los,incombat,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil) then
				wt_core_taskmanager:addKillTask( id, E, 3000 )
				return false
			end		
		end
	end
	
	local TList = ( CharacterList( "nearest,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil) then
			wt_core_taskmanager:addKillTask( id, E, 2500 )
			return false
		end		
	end	
	return false
end
function e_aggro:execute()	
	return false
end



--*************************************************************
-- DepositItems Cause & Effect
--*************************************************************
c_deposit = inheritsFrom( wt_cause )
e_deposit = inheritsFrom( wt_effect )
function c_deposit:evaluate()
	local depositPercent = math.random(50, 90)
	local percentFull = ((ItemList.slotCount - ItemList.freeSlotCount)/ItemList.slotCount) * 100
	if (percentFull > depositPercent or ItemList.freeSlotCount == 0) then
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


--************************************************************
-- Do Emergency Tasks Cause & Effect - Done before AggroCheck
--************************************************************
c_doemergencytask = inheritsFrom( wt_cause )
e_doemergencytask = inheritsFrom( wt_effect )
function c_doemergencytask:evaluate()
	if (wt_core_taskmanager.current_task ~= nil and wt_core_taskmanager.current_task.priority > 10000) then
		return true
	end	
	return false
end
function e_doemergencytask:execute()
	wt_core_taskmanager:DoTask()
end

--************************************************************
-- Do Event Tasks Cause & Effect - Done after AggroCheck
--************************************************************
c_doeventtask = inheritsFrom( wt_cause )
e_doeventtask = inheritsFrom( wt_effect )
function c_doeventtask:evaluate()
	if (wt_core_taskmanager.current_task ~= nil and wt_core_taskmanager.current_task.priority > 900 and wt_core_taskmanager.current_task.priority <= 999 ) then
		return true
	end
	return false
end
function e_doeventtask:execute()
	wt_core_taskmanager:DoTask()
end

--************************************************************
-- Do Prio Tasks Cause & Effect - Done after AggroCheck
--************************************************************
c_dopriotask = inheritsFrom( wt_cause )
e_dopriotask = inheritsFrom( wt_effect )
function c_dopriotask:evaluate()
	if (wt_core_taskmanager.current_task ~= nil and wt_core_taskmanager.current_task.priority > 999 and wt_core_taskmanager.current_task.priority <= 10000) then
		return true
	end
	return false
end
function e_dopriotask:execute()
	wt_core_taskmanager:DoTask()
end


--************************************************************
-- Do Tasks Cause & Effect 
--************************************************************
c_dotask = inheritsFrom( wt_cause )
e_dotask = inheritsFrom( wt_effect )
function c_dotask:evaluate()	
	return true
end
function e_dotask:execute()
	wt_core_taskmanager:DoTask()
end


--************************************************************
-- Rest Cause & Effect
--************************************************************
c_rest = inheritsFrom( wt_cause )
e_rest = inheritsFrom( wt_effect )
function c_rest:evaluate()
	local HP = Player.health.percent
	if ( HP < math.random(55,75) ) then
		
		local mybuffs = Player.buffs
		local hazardfound= false
		if (mybuffs ~= nil) then
		  i,e = next(mybuffs)
		  while (i ~= nil and e ~= nil) do		
			if (tonumber(e.skillID) ~= nil and tonumber(e.contentID) ~= nil) then
				if (e.skillID == 737 or	--Burning
					e.skillID == 723 or --Poison
					e.skillID == 736 ) then	--Bleeding
					hazardfound = true					
				end
			end
			 i,e = next(mybuffs,i)
		  end
		end
		if (not hazardfound) then
			return true
		end
	end	
	return false
end
e_rest.throttle = math.random( 500, 2500 )
function e_rest:execute()
	if (Player.profession == 8 ) then -- Necro, leave shroud
		local deathshroud = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
		if (not Player.inCombat and deathshroud ~= nil and deathshroud.skillID == 10585) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
			return
		end
	end
	local HP = Player.health.percent
	if ( HP < math.random(55,75) ) then
		local s6 = Player:GetSpellInfo( GW2.SKILLBARSLOT.Slot_6 )
		if( Player:GetCurrentlyCastedSpell() == 17 and not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_6 ) ) then
			if ( c_rest_heal ) then
				c_rest_heal = not c_rest_heal
				if ( s6 ~= nil ) then
					wt_debug( "Using "..tostring( s6.name ).." to heal ("..Player.health.percent.."%)" )
				end
			end
			Player:CastSpell( GW2.SKILLBARSLOT.Slot_6 )
		end
	end
	if (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1 ) then -- We Lead	
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.distance > 3500 and player.alive and player.onmesh and player.health.percent < math.random(55,75) ) then					
					local pos = player.pos
					Player:MoveTo(pos.x,pos.y,pos.z,math.random( 20, 100 ))
				end
				index, player  = next( party,index )
			end		
		end
	end
	return
end


--************************************************************
-- Revive PartyMember in Groupbotting
--************************************************************
c_revivep = inheritsFrom( wt_cause )
e_revivep = inheritsFrom( wt_effect )
c_revivep.ID = nil
function c_revivep:evaluate()
	local party = Player:GetPartyMembers()
	if (party ~= nil ) then
		local index, player  = next( party )
		while ( index ~= nil and player ~= nil ) do			
			if (player.distance < 4000 and ((player.healthstate == GW2.HEALTHSTATE.Defeated and not Player.inCombat) or (player.healthstate == GW2.HEALTHSTATE.Downed)) and player.onmesh) then
				c_revivep.ID = index
				if ( wt_core_controller.state ~= nil and wt_core_controller.state.name == "Combat" ) then
					wt_core_state_combat.CurrentTarget = 0 -- Leave combat state or it will never work :)
				end
				return true
			end
			index, player  = next( party,index )
		end		
	end
	return false
end
e_revivep.throttle = 250
function e_revivep:execute()
	if (c_revivep.ID ~= nil and c_revivep.ID ~= 0 ) then
		local T = CharacterList:Get( c_revivep.ID )
		if ( T ~= nil ) then
			if ( ((T.healthstate == GW2.HEALTHSTATE.Defeated and not Player.inCombat) or (T.healthstate == GW2.HEALTHSTATE.Downed)) and T.onmesh ) then		
				if ( T.distance > 110 ) then
					local TPOS = T.pos
					Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 25 )
				elseif( T.distance <= 110 ) then
					Player:StopMoving()
					if (Player:GetTarget() ~= Player:GetInteractableTarget() or Player:GetInteractableTarget() ~= c_revivep.ID) then
						Player:SetTarget(c_revivep.ID)					
					elseif( Player:GetCurrentlyCastedSpell() == 17 ) then
						Player:Interact( c_revivep.ID )
						wt_debug("Reviving Partymember: "..tostring(c_revivep.ID))
						return
					end
				end
			end
		end
	end
end


--****************************************************
-- Revive Nearby NPCs
--****************************************************
c_check_revive = inheritsFrom( wt_cause )
e_revive = inheritsFrom( wt_effect )
function c_check_revive:evaluate()
	local TID = Player:GetInteractableTarget()
	if ( TID ~= nil ) then
		local T = CharacterList:Get( TID )
		if ( T ~= nil ) then
			if ( T.distance < wt_global_information.MaxReviveDistance and T.attitude == GW2.ATTITUDE.Friendly and T.healthstate == GW2.HEALTHSTATE.Defeated and T.onmesh ) then
				if ( DebugModes.Revive.Master ) then
					if ( T.distance > 100 and DebugModes.state ~= "Move" ) then
						DebugModes.state = "Move"
						if ( DebugModes.Revive.TID ~= nil ) then DebugModes.Revive.TID = nil end
					elseif ( T.distance < 100 and DebugModes.state ~= "Revive" ) then
						DebugModes.state = "Revive"
						if ( DebugModes.Revive.TID ~= nil ) then DebugModes.Revive.TID = nil end
					end
					if ( DebugModes.Revive.Move or DebugModes.Revive.Revive ) then
						-- if ( DebugModes.Revive.TID ~= nil ) then DebugModes.Revive.TID = nil end
					end
				end
				return true
			end
		end
	end
	if ( DebugModes.Revive.Master ) then
		if ( DebugModes.state ~= false ) then DebugModes.state = false end
		if ( DebugModes.Revive.TID ~= nil ) then DebugModes.Revive.TID = nil end
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
					if ( DebugModes.Revive.TID ~= TID and DebugModes.Revive.Master ) then DebugModes.Revive.TID = TID wt_debug( string.format( "Idle: moving to reviveable target %s Dist: %u", tostring( T.name ), T.distance ) ) end
					local TPOS = T.pos
					Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 80 )
				elseif( T.distance < 100 ) then
					Player:StopMoving()
					if ( Player:GetCurrentlyCastedSpell() == 17 ) then
						if ( DebugModes.Revive.TID ~= TID and DebugModes.Revive.Master ) then DebugModes.Revive.TID = TID wt_debug( string.format( "Idle: reviving target %s", tostring( T.name ) ) ) end
						Player:Interact( TID )
						return
					end
				end
			end
		end
	else
		if ( DebugModes.Revive.NoTarget and DebugModes.Revive.Master ) then wt_debug( "Idle: No Target to revive" ) end
	end
end

--****************************************************
-- Revive Nearby Players
--****************************************************
c_check_revive_players = inheritsFrom( wt_cause )
e_revive_players = inheritsFrom( wt_effect )
function c_check_revive_players:evaluate()
	if (gPlayerRevive == "0") then
		return false
	end
	local playerList = CharacterList("nearest,player,downed,maxdistance=2500,onmesh")
	if (TableSize(playerList) == 0) then
		playerList = CharacterList("nearest,player,dead,maxdistance=2500,onmesh")
	end
	if (TableSize(playerList) > 0) then
		local index, player  = next( playerList )
		while ( index ~= nil and player ~= nil ) do			
			if (player.distance < 4000 and ((player.healthstate == GW2.HEALTHSTATE.Defeated and not Player.inCombat) or (player.healthstate == GW2.HEALTHSTATE.Downed)) and player.onmesh) then
				c_revivep.ID = index
				if ( wt_core_controller.state ~= nil and wt_core_controller.state.name == "Combat" ) then
					wt_core_state_combat.CurrentTarget = 0 -- Leave combat state or it will never work :)
				end
				return true
			end
			index, player  = next( playerList,index )
		end		
	end
	return false
end
function e_revive_players:execute()
 	if (c_revivep.ID ~= nil and c_revivep.ID ~= 0 ) then
		local T = CharacterList:Get( c_revivep.ID )
		if ( T ~= nil ) then
			if ( ((T.healthstate == GW2.HEALTHSTATE.Defeated and not Player.inCombat) or (T.healthstate == GW2.HEALTHSTATE.Downed)) and T.onmesh ) then		
				if ( T.distance > 110 ) then
					local TPOS = T.pos
					Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 25 )
				elseif( T.distance <= 110 ) then
					Player:StopMoving()
					if (Player:GetTarget() ~= Player:GetInteractableTarget() or Player:GetInteractableTarget() ~= c_revivep.ID) then
						Player:SetTarget(c_revivep.ID)					
					elseif( Player:GetCurrentlyCastedSpell() == 17 ) then
						Player:Interact( c_revivep.ID )
						wt_debug("Reviving Player: "..tostring(c_revivep.ID))
						return
					end
				end
			end
		end
	end
end

--*********************************************************
-- Loot Cause & Effect
--*********************************************************
c_check_loot = inheritsFrom( wt_cause )
e_loot = inheritsFrom( wt_effect )
function c_check_loot:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_check_loot.EList = CharacterList( "nearest,lootable,onmesh,maxdistance=" .. wt_global_information.MaxLootDistance )
		if ( TableSize( c_check_loot.EList ) > 0 ) then			
			local index, LT = next( c_check_loot.EList )
			if ( index ~= nil and LT~=nil) then					
				return true
			end
		end		
	end
	return false
end
e_loot.throttle = math.random( 250, 500 )
function e_loot:execute()	
	if ( TableSize( c_check_loot.EList ) > 0 ) then			
		local index, LT = next( c_check_loot.EList )
		if ( index ~= nil and LT~=nil) then	
			if ( LT.distance ~= nil and LT.distance > 130 ) then	
				local TPOS = LT.pos
				Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 0 )
			elseif ( LT.distance < 100 and index == Player:GetInteractableTarget() ) then
				Player:StopMoving()
				if ( Player:GetCurrentlyCastedSpell() == 17 ) then					
					wt_debug( "Looting Corpse" )					
					Player:Interact( index )
					if (gDoPause == "1" and TableSize(CharacterList("players,maxdistance=2500,los")) > 0 ) then
						wt_core_taskmanager:addPauseTask(1000,2000)
					end
				end
			elseif (LT.distance < 100 and index ~= Player:GetInteractableTarget()) then
				Player:StopMoving()
				wt_debug( "Targeting Corpse" )					
				Player:SetTarget(index)
			end
		end
	else
		wt_debug( "Idle: No Target to Loot" )
	end
end


--*********************************************************
-- LootChests Cause & Effect
--*********************************************************
c_lootchest = inheritsFrom( wt_cause )
e_lootchest = inheritsFrom( wt_effect )
function c_lootchest:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_lootchest.EList = GadgetList("nearest,maxdistance=" .. wt_global_information.MaxLootDistance..",onmesh") --old contentID=198260
		if ( TableSize( c_lootchest.EList ) > 0 ) then			
			local index, LT = next( c_lootchest.EList )
			while ( index ~= nil and LT~=nil ) do
				if ( LT.isselectable == 1 and (LT.contentID == 198260 or LT.contentID == 232192 or LT.contentID == 232193 or LT.contentID == 232194)) then
					return true
				end
				index, LT = next( c_lootchest.EList,index )
			end
		end	
	end
	return false
end
e_lootchest.throttle = math.random( 250, 500 )
function e_lootchest:execute()
	if ( TableSize( c_lootchest.EList ) > 0 ) then
		local chest,ID = nil
		local index, LT = next( c_lootchest.EList )
		while ( index ~= nil and LT~=nil ) do
			if ( LT.isselectable == 1 and (LT.contentID == 198260 or LT.contentID == 232192 or LT.contentID == 232193 or LT.contentID == 232194)) then
				chest = LT
				ID = index
				break
			end
			index, LT = next( c_lootchest.EList,index )
		end
		
		if ( chest ~= nil and ID ~= nil ) then	
			if ( chest.distance ~= nil and chest.distance >= 100 ) then	
				local TPOS = chest.pos
				Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 0 )
			elseif ( chest.distance < 100 and ID == Player:GetInteractableTarget() ) then
				Player:StopMoving()
				if ( Player:GetCurrentlyCastedSpell() == 17 ) then					
					wt_debug( "Looting Chest ID:"..tostring(ID))					
					Player:Use( ID )
				end
			elseif (chest.distance < 100 and ID ~= Player:GetInteractableTarget()) then
				Player:StopMoving()
				wt_debug( "Targeting Chest" )					
				Player:SetTarget(ID)
			end
		end
	else
		wt_debug( "Idle: No Chest to Loot found" )
	end	
end


--*********************************************************
-- Stupid-Make-Sure-We-Dont-Backpadel/Strafe-Into-The-Woods- Cause & Effect
--*********************************************************
c_stopcbmove = inheritsFrom( wt_cause )
e_stopcbmove = inheritsFrom( wt_effect )
c_stopcbmove.throttle = 2000
function c_stopcbmove:evaluate()
 local mstate = Player:GetMovementState()
    if mstate == 1 then Player:UnSetMovement(1) elseif
       mstate == 2 then Player:UnSetMovement(2) elseif
       mstate == 3 then Player:UnSetMovement(3)
    end
    return false
end
function e_stopcbmove:execute()
	
end