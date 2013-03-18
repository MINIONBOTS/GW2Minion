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
	if ( gNavSwitchEnabled == "1" and Inventory:GetInventoryMoney() > 500) then
		if ( NavigationManager:GetTargetMapID() ~= 0) then
			return true
		end		
		if (gMinionEnabled == "0" or (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID)) then			
			if (mm.lastswitchTmr == 0) then
				mm.lastswitchTmr = wt_global_information.Now
			else
				gMapswitch = math.floor(((gNavSwitchTime * 60000) - (wt_global_information.Now - mm.lastswitchTmr)) / 1000)
				if ( mm.GetmeshfilelistSize() > 1 and (wt_global_information.Now - mm.lastswitchTmr > (gNavSwitchTime * 60000))) then
					if ( not Player.inCombat ) then
						Player:StopMoving()			
						return true
					end
				end
			end
		else
			gMapswitch = 0
		end
	end
	return false
end
function e_navswitch:execute()
	wt_debug("Switching NavMesh!")
	mm.lastswitchTmr  = wt_global_information.Now
	wt_core_controller.requestStateChange( wt_core_state_navswitch )
end

--**********************************************
-- Death Check
--**********************************************
c_died = inheritsFrom( wt_cause )
e_died = inheritsFrom( wt_effect )
function c_died:evaluate()
	if ( not wt_core_taskmanager.behavior == "default" ) then
		wt_core_taskmanager:SetDefaultBehavior()
	end
	if ( Player.alive ~= true ) then
		return true
	end
	return false
end
function e_died:execute()
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
e_quickloot.throttle = math.random( 50, 250 )
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
	wt_error( "No Target to Quick-Loot" )
end





--********************************************************************
-- QuickLoot Chests Cause & Effect (looting just the things that are in range already, this we can do while beeing infight)
--********************************************************************
c_quicklootchest = inheritsFrom( wt_cause )
e_quicklootchest = inheritsFrom( wt_effect )
function c_quicklootchest:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_quicklootchest.EList = GadgetList("nearest,onmesh,contentID=198260" ) --contentID=198260
		NextIndex, LootTarget = next( c_quicklootchest.EList )
		if ( NextIndex ~= nil ) then
			if ( NextIndex == Player:GetInteractableTarget() ) then
				return true
			end
		end
	end
	return false
end
e_quicklootchest.n_index = nil
e_quicklootchest.throttle = math.random( 150, 450 )
function e_quicklootchest:execute()
 	local NextIndex = 0
	local LootTarget = nil
	if (c_quicklootchest.EList ~= nil ) then
		NextIndex, LootTarget = next( c_quicklootchest.EList )
		if ( NextIndex ~= nil and NextIndex == Player:GetInteractableTarget() ) then
			if ( e_quicklootchest.n_index  ~= NextIndex ) then
				e_quicklootchest.n_index  = NextIndex
				wt_debug( "QuickLootingChest" )
			end
			Player:Use( NextIndex )
		else
			local e = Player:GetInteractableTarget()
			if ( e ~= nil ) then
				local gadget = GadgetList:Get( e )
				if ( gadget ~= nil ) then
					if ( gadget.contentID == 198260) then --198260 is pve loot chest/box
						if ( e_quicklootchest.n_index  ~= e ) then
							e_quicklootchest.n_index  = e
							wt_debug( "QuickLootingChest" )
						end
						Player:Use( e )
						return
					end
				end
			end
		end
	end
	wt_error( "No Chest to Quick-Loot" )
end



--*************************************************************
-- Aggro Cause & Effect
--*************************************************************
c_aggro = inheritsFrom( wt_cause )
e_aggro = inheritsFrom( wt_effect )
function c_aggro:evaluate()
	-- For Groupbotting
	if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_global_information.LeaderID ~= nil and Player.characterID ~= nil) then
		if ( wt_global_information.LeaderID == Player.characterID ) then -- We Lead			
			-- Kill all PartyAggroTargets in range of leader first
			if ( TableSize( wt_global_information.PartyAggroTargets ) > 0 ) then
				local nextTarget
				nextTarget, nChar = next( wt_global_information.PartyAggroTargets )
				if ( nextTarget ~= nil and nextTarget ~= 0) then
					local ntarget = CharacterList:Get(tonumber(nextTarget))
					if ( ntarget ~= nil and ntarget.distance < 4000 and ntarget.alive and ntarget.onmesh) then
						c_aggro.TargetList[tonumber(nextTarget)] = nChar
						return true
					else 
						table.remove(wt_global_information.PartyAggroTargets,tonumber(nextTarget))
					end
				end
			end
			
			-- Search for new FocusTarget
			c_aggro.TargetList = ( CharacterList( "nearest,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
			if ( TableSize( c_aggro.TargetList ) > 0 ) then
				return true
			end
			c_aggro.TargetList = ( CharacterList( "nearest,los,attackable,incombat,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
			if ( TableSize( c_aggro.TargetList ) > 0 ) then
				return true
			end			
			
		else -- We follow
			-- close range aggro targets
			c_aggro.TargetList = ( CharacterList( "nearest,los,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
			if ( TableSize( c_aggro.TargetList ) > 0 ) then
				nextTarget, E  = next( c_aggro.TargetList )
				if ( nextTarget ~= nil ) then
					return true
				end
			end
		end
		return false		
	end
	
	-- For Solo botting	
	if ( Player.inCombat ) then
		c_aggro.TargetList = ( CharacterList( "nearest,attackable,alive,incombat,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
		if ( TableSize( c_aggro.TargetList ) > 0 ) then
			nextTarget, E  = next( c_aggro.TargetList )
			if ( nextTarget ~= nil ) then
				return true
			end
		end
	end

	c_aggro.TargetList = ( CharacterList( "nearest,los,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		return true
	end
	return false
end
function e_aggro:execute()
	-- For Groupbotting
	if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_global_information.LeaderID ~= nil ) then
		if ( wt_global_information.LeaderID == Player.characterID ) then -- We Lead		
			if ( TableSize( c_aggro.TargetList ) > 0 ) then
				nextTarget, E  = next( c_aggro.TargetList )
				if ( nextTarget ~= nil ) then
					wt_debug( "Begin Combat, Possible aggro target found" )
					MultiBotSend( "5;"..nextTarget,"gw2minion" )
					wt_core_state_combat.setTarget( nextTarget )
					wt_core_controller.requestStateChange( wt_core_state_combat )
				end
			end
		else -- We Follow			
			if ( TableSize( c_aggro.TargetList ) > 0 ) then
				nextTarget, E  = next( c_aggro.TargetList )
				if ( nextTarget ~= nil ) then
					wt_debug( "Begin Combat, Possible aggro target found" )
					--TODO: Inform leader about our aggro target
					MultiBotSend( "6;"..nextTarget,"gw2minion" )					
					wt_core_state_combat.setTarget( nextTarget )
					wt_core_controller.requestStateChange( wt_core_state_combat )
				end
			end
		end
		return false
	end
	
	--For Solo botting
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		nextTarget, E  = next( c_aggro.TargetList )
		if ( nextTarget ~= nil ) then
			wt_debug( "Begin Combat, Possible aggro target found" )
			wt_core_state_combat.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_combat )
		end
	end
end


--************************************************************
-- Do Emergency Tasks Cause & Effect
--************************************************************
c_doemergencytask = inheritsFrom( wt_cause )
e_doemergencytask = inheritsFrom( wt_effect )
function c_doemergencytask:evaluate()
	if ( wt_core_taskmanager ~= nil ) then
		return wt_core_taskmanager:CheckEmergencyTask()	
	end	
	return false
end
function e_doemergencytask:execute()
	wt_core_taskmanager:DoEmergencyTask()
end



--************************************************************
-- Do Prio Tasks Cause & Effect
--************************************************************
c_dopriotask = inheritsFrom( wt_cause )
e_dotask = inheritsFrom( wt_effect )
function c_dopriotask:evaluate()
	if ( wt_core_taskmanager ~= nil ) then
		return wt_core_taskmanager:CheckPrioTask()	
	end	
	return false
end
function e_dotask:execute()
	wt_core_taskmanager:DoPrioTask()
end




--************************************************************
-- Rest Cause & Effect
--************************************************************
c_rest = inheritsFrom( wt_cause )
e_rest = inheritsFrom( wt_effect )
function c_rest:evaluate()
	local HP = Player.health.percent
	if ( HP < wt_global_information.Currentprofession.RestHealthLimit ) then
		local mybuffs = Player.buffs
		local hazardfound= false
		if (mybuffs~=nil) then
		  i,e = next(mybuffs)
		  while (i~=nil and e~=nil) do
			 if (e.skillID == 737 or e.contentID == 134797 or
				 e.skillID == 723 or e.contentID == 35864) then --Burning
				hazardfound = true
			 end
			 i,e = next(mybuffs,i)
		  end
		end
		if (not hazardfound) then
			return true
		end
	end
	--[[if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID ) then -- We Lead	
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.distance < 4000 and player.alive and player.onmesh and player.health.percent < 75 ) then					
					return true
				end
				index, player  = next( party,index )
			end		
		end		
	end]]
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
	if ( HP < wt_global_information.Currentprofession.RestHealthLimit ) then
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
	if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID ) then -- We Lead	
		local party = Player:GetPartyMembers()
		if (party ~= nil) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.distance > 3500 and player.alive and player.onmesh and player.health.percent < wt_global_information.Currentprofession.RestHealthLimit ) then					
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
	if (party ~= nil and wt_global_information.LeaderID ~= nil) then
		local index, player  = next( party )
		while ( index ~= nil and player ~= nil ) do			
			if (player.distance < 4000 and ((player.healthstate == GW2.HEALTHSTATE.Defeated and not Player.inCombat) or (player.healthstate == GW2.HEALTHSTATE.Downed)) and player.onmesh) then
				c_revivep.ID = index
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
		if ( DebugModes.Revive.NoTarget and DebugModes.Revive.Master ) then wt_error( "Idle: No Target to revive" ) end
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
				end
			elseif (LT.distance < 100 and index ~= Player:GetInteractableTarget()) then
				Player:StopMoving()
				wt_debug( "Targeting Corpse" )					
				Player:SetTarget(index)
			end
		end
	else
		wt_error( "Idle: No Target to Loot" )
	end
end


------------------------------------------------------------------------------
-- LootChests Cause & Effect
c_lootchest = inheritsFrom( wt_cause )
e_lootchest = inheritsFrom( wt_effect )
function c_lootchest:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_lootchest.EList = GadgetList("nearest,onmesh,contentID=198260,maxdistance=" .. wt_global_information.MaxLootDistance )
		if ( TableSize( c_lootchest.EList ) > 0 ) then			
			local index, LT = next( c_lootchest.EList )
			if ( index ~= nil and LT~=nil) then					
				return true
			end
		end	
	end
	return false
end
e_lootchest.throttle = math.random( 250, 500 )
function e_lootchest:execute()
	if ( TableSize( c_lootchest.EList ) > 0 ) then			
		local index, LT = next( c_lootchest.EList )
		if ( index ~= nil and LT~=nil) then	
			if ( LT.distance ~= nil and LT.distance > 130 ) then	
				local TPOS = LT.pos
				Player:MoveTo( TPOS.x, TPOS.y, TPOS.z , 0 )
			elseif ( LT.distance < 100 and index == Player:GetInteractableTarget() ) then
				Player:StopMoving()
				if ( Player:GetCurrentlyCastedSpell() == 17 ) then					
					wt_debug( "Looting Chest" )					
					Player:Interact( index )
				end
			elseif (LT.distance < 100 and index ~= Player:GetInteractableTarget()) then
				Player:StopMoving()
				wt_debug( "Targeting Chest" )					
				Player:SetTarget(index)
			end
		end
	else
		wt_error( "Idle: No Chest to Loot found" )
	end	
end