-- Combat State for all professions
-- Holds "basic" combat routines, every profession has to add it´s own combat cause&effects to this combatstate

wt_core_state_combat = inheritsFrom( wt_core_state )
wt_core_state_combat.name = "Combat"
wt_core_state_combat.kelement_list = { }
wt_core_state_combat.CurrentTarget = 0
wt_core_state_combat.RestHealthLimit = math.random(60,75)
wt_core_state_combat.MovementTmr = 0
wt_core_state_combat.combatMoveTmr = 0
wt_core_state_combat.combatEvadeTmr = 0
wt_core_state_combat.combatEvadeLastHP = 0
wt_core_state_combat.combatJumpTmr = 0
wt_core_state_combat.searchBetterTarget = true
wt_core_state_combat.AttackTmr = 0
wt_core_state_combat.LastTargetHP = 0

function wt_core_state_combat.IsCMActive()
	if (Player:GetMovement() ~= 0 ) then
		return true
	end
	return false
end

function wt_core_state_combat.StopCM()
	-- Stupid but Player:StopMoving() doesn't seem to do the job 
	Player:UnSetMovement(1)
	Player:UnSetMovement(0)
	Player:UnSetMovement(2)
	Player:UnSetMovement(3)
	Player:StopMoving()
end

-- Thanks Havoc
function OkToMove()
    return --Player.movementstate ~= GW2.MOVEMENTSTATE.GroundNotMoving
        --or 
		Player:GetCurrentlyCastedSpell() == GW2.SKILLBARSLOT.Slot_1
        or not Player:IsCasting()
end

--/////////////////////////////////////////////////////
-- Combat over Check
c_combat_over = inheritsFrom( wt_cause )
e_combat_over = inheritsFrom( wt_effect )
function c_combat_over:evaluate()
	--local CurrentTarget = Player:GetTarget()
	if ( wt_core_state_combat.CurrentTarget == nil or wt_core_state_combat.CurrentTarget == 0 ) then
		return true
	else
		-- stop combatmovement when outside the mesh
		if ( Player.movementstate == GW2.MOVEMENTSTATE.GroundMoving and wt_core_state_combat.IsCMActive() and not Player.onmeshexact) then
			wt_core_state_combat.StopCM()
		end
		local T = CharacterList:Get( wt_core_state_combat.CurrentTarget )
		if (T == nil or not T.alive or not T.onmesh or T.attitude == 0 or T.attitude == 3)
		or (T ~= nil and wt_global_information.TargetIgnorelist ~= nil and wt_global_information.TargetIgnorelist[T.contentID] ~= nil and wt_global_information.TargetIgnorelist[T.contentID] < T.health.percent)
		or (wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[wt_core_state_combat.CurrentTarget] ~= nil) then
			Player:ClearTarget()
			return true
		end
	end
	return false
end
function e_combat_over:execute()
	wt_debug( "Combat finished" )
	wt_core_state_combat.CurrentTarget = 0
	wt_core_state_combat.StopCM()
	Player:ClearTarget()
	wt_core_state_combat.AttackTmr = 0
	wt_core_controller.requestStateChange( wt_core_state_idle )	
	return
end

--/////////////////////////////////////////////////////
-- Invincible Check
c_invi_check = inheritsFrom( wt_cause )
e_invi_check = inheritsFrom( wt_effect )
c_invi_check.throttle = 5000
function c_invi_check:evaluate()
	if ( wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0 ) then		
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T ~= nil ) then	
			-- Check for Determined buff
			local tbuffs = T.buffs
			if (tbuffs ~= nil) then
			  i,e = next(tbuffs)
			  while (i ~= nil and e ~= nil) do		
				if (tonumber(e.skillID) ~= nil) then
					if (e.skillID == 762)then --Determined					
						return true
					end
				end
				 i,e = next(tbuffs,i)
			  end
			end
		end
	end
	return false
end

e_invi_check.throttle = 5000
function e_invi_check:execute()
	wt_debug("Blacklisting Enemy, detected the Determined boon")
	wt_global_information.TargetBlacklist[wt_core_state_combat.CurrentTarget] = wt_global_information.Now
end



--/////////////////////////////////////////////////////
-- Search for a better target Check
c_better_target_search = inheritsFrom( wt_cause )
e_better_target_search = inheritsFrom( wt_effect )
function c_better_target_search:evaluate()
	if (wt_core_state_combat.searchBetterTarget) then
		local target = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if (wt_core_taskmanager.current_task ~= nil) then
			if (string.find(wt_core_taskmanager.current_task.name, "Event") == nil) then
				if (target ~= nil) then
					if (target.isVeteran) then
						return false
					end
				end
			end
		end
		
		if ( wt_global_information.AttackRange and wt_core_state_combat.CurrentTarget ) then
			c_better_target_search.TargetList = CharacterList( "lowesthealth,los,attackable,alive,incombat,noCritter,onmesh,maxdistance="..wt_global_information.AttackRange..",exclude="..wt_core_state_combat.CurrentTarget )
			local nextTarget, E  = next( c_better_target_search.TargetList )
			if ( nextTarget ~= nil and E ~= nil) then
				if ( E.alive and E.onmesh and (E.attitude == 1 or E.attitude == 2)) then
					if (wt_global_information.TargetIgnorelist ~= nil and wt_global_information.TargetIgnorelist[E.contentID] ~= nil and wt_global_information.TargetIgnorelist[E.contentID] > E.health.percent) then
						return true
					elseif (wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[nextTarget] == nil) then
						return true
					end
				end
			end			
		end
	end
	return false	
end
function e_better_target_search:execute()
	nextTarget, E  = next( c_better_target_search.TargetList )
	if ( nextTarget ~= nil ) then
		--wt_debug( "Combat: Switching to better target " .. nextTarget )		
		wt_core_state_combat.StopCM()
		wt_core_state_combat.setTarget( nextTarget )
		wt_core_state_combat.AttackTmr = 0
		if (gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			if ( Player:GetRole() == 1 ) then
				MultiBotSend( "5;"..tonumber(nextTarget),"gw2minion" ) -- Set FocusTarget for Minions
			else
				MultiBotSend( "6;"..tonumber(nextTarget),"gw2minion" )	-- Inform leader about our aggro target
			end
		end
	end
end


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
c_heal_action = inheritsFrom(wt_cause)
e_heal_action = inheritsFrom(wt_effect)
function c_heal_action:evaluate()
	if (gSMactive == "0") then
		return (Player.health.percent < wt_core_state_combat.RestHealthLimit and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6))
	else
		return false
	end
end
e_heal_action.usesAbility = true
function e_heal_action:execute()
	--wt_debug("e_heal_action")
	Player:CastSpell(GW2.SKILLBARSLOT.Slot_6)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
c_MoveCloser = inheritsFrom(wt_cause)
e_MoveCloser = inheritsFrom(wt_effect)
function c_MoveCloser:evaluate()
	if ( wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0 ) then
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T ~= nil ) then
			local Distance = T.distance or 0
			local LOS = T.los or false
			if (Distance >= wt_global_information.AttackRange or LOS~=true) then				
				return true
			else
				if( Player:GetTarget() ~= wt_core_state_combat.CurrentTarget) then
					Player:SetTarget(wt_core_state_combat.CurrentTarget)
				end
			end
		end
	end	
	return false;
end
function e_MoveCloser:execute()
	if ( wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0 ) then
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T ~= nil ) then
			local Tpos = T.pos
			Player:MoveTo(Tpos.x,Tpos.y,Tpos.z,120) -- the last number is the distance to the target where to stop
		end
	end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Random CombatMovement
c_combatmove = inheritsFrom(wt_cause)
e_combatmove = inheritsFrom(wt_effect)
function c_combatmove:evaluate()	
	if ( gCombatmovement == "1" and wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0 ) then
		
		-- Check for knockdown & immobilized buffs
		local mybuffs = Player.buffs
		if (mybuffs ~= nil) then
		  i,e = next(mybuffs)
		  while (i ~= nil and e ~= nil) do		
			if (tonumber(e.skillID) ~= nil) then
				if (e.skillID == 791 or	--Fear
					e.skillID == 727 )then --Immobilized					
					return false
				end
			end
			 i,e = next(mybuffs,i)
		  end
		end
		
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T ~= nil ) then
			local Tdist = T.distance					
			local playerHP = Player.health.percent
			local movedir = Player:GetMovement()
			
			-- I know this should get an own state, but I'm too lazy now
			if ( T.distance < wt_global_information.AttackRange and (Player:GetCurrentlyCastedSpell() == 17)) then
				if ( wt_core_state_combat.AttackTmr == 0 or wt_core_state_combat.LastTargetHP == 0 or T.health.percent ~= wt_core_state_combat.LastTargetHP) then 
					wt_core_state_combat.LastTargetHP = T.health.percent
					wt_core_state_combat.AttackTmr = wt_global_information.Now
				elseif ( wt_global_information.Now - wt_core_state_combat.AttackTmr > 10000 and T.health.percent == wt_core_state_combat.LastTargetHP) then
					wt_error("Cant attack Target. Going to ignore it for now.")
					wt_core_state_combat.AttackTmr = 0
					wt_core_state_combat.LastTargetHP = 0
					wt_global_information.TargetBlacklist[wt_core_state_combat.CurrentTarget] = wt_global_information.Now
				end
			end
			
			
			if ( gSMactive and gSMactive == "0" ) then -- update wt_global_information.AttackRange if skillmanager is OFF
				local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
				if (s1 ~= nil) then
					local newrange = s1.maxRange
					if ( newrange < 110 ) then newrange = 160 end
					wt_global_information.AttackRange = newrange
				end
			end
			
			
			-- EVADE
			if (wt_core_state_combat.combatEvadeTmr == 0 or wt_global_information.Now - wt_core_state_combat.combatEvadeTmr > 2000) then
				wt_core_state_combat.combatEvadeTmr = wt_global_information.Now				
				wt_core_state_combat.combatEvadeLastHP = 0
			end				
			if (wt_core_state_combat.combatEvadeLastHP > 0 ) then
				if (wt_core_state_combat.combatEvadeLastHP <= playerHP) then
					wt_core_state_combat.combatEvadeLastHP = playerHP
				elseif (wt_core_state_combat.combatEvadeLastHP - playerHP > math.random(5,10) and Player.endurance >= 50 and Player:IsFacingTarget()) then
				-- we lost 5-10% hp in the last 2,5seconds, evade!
					wt_debug("Evade!");
					local tries = 0
					while (tries < 4) do
						local direction = math.random(0,7)
						if (Player:CanEvade(direction)) then
							Player:Evade(direction)
							wt_core_state_combat.combatEvadeLastHP = 0
							return
						end
						tries = tries + 1
					end					
				end
			else 
				wt_core_state_combat.combatEvadeLastHP = playerHP
			end
			
			
			--CONTROL CURRENT COMBAT MOVEMENT
			if ( wt_core_state_combat.IsCMActive() ) then
				if (Player.inCombat and not Player:IsFacingTarget() and Tdist > 150) then
					Player:UnSetMovement(1)
					Player:UnSetMovement(2)
					Player:UnSetMovement(3)
					local Tpos = T.pos
					Player:MoveTo(Tpos.x,Tpos.y,Tpos.z,120)
				end
				
				if (Tdist ~= nil) then
					if (wt_global_information.AttackRange > 300) then
						-- RANGE
						if (Tdist < wt_global_information.AttackRange / 2 and (movedir == 0 or movedir == 13 or movedir == 14)) then -- we are too close	and moving towards enemy						
							Player:UnSetMovement(0)	-- stop moving forward	
						elseif ( Tdist > wt_global_information.AttackRange and (movedir == 1 or movedir == 15 or movedir == 16)) then -- we are too far away and moving backwards
							Player:UnSetMovement(1)	-- stop moving backward	
						elseif (Tdist > wt_global_information.AttackRange and (movedir == 2 or movedir == 13 or movedir == 15 or movedir == 3 or movedir == 14 or movedir == 16)) then -- we are strafing outside the maxrange
							if ( movedir == 2 or movedir == 13 or movedir == 15) then
								Player:UnSetMovement(2) -- stop moving Left	
							elseif( movedir == 3 or movedir == 14 or movedir == 16) then
								Player:UnSetMovement(3) -- stop moving Right
							end
						end	
					else
						-- MELEE
						if ( Tdist < 85 and (movedir == 0 or movedir == 13 or movedir == 14)) then -- we are too close	and moving towards enemy
							Player:UnSetMovement(0)	-- stop moving forward	
						elseif (Tdist > wt_global_information.AttackRange and (movedir == 1 or movedir == 15 or movedir == 16)) then -- we are too far away and moving backwards
							Player:UnSetMovement(1)	-- stop moving backward	
						elseif ((Tdist > wt_global_information.AttackRange + 50 or Tdist < 50) and (movedir == 2 or movedir == 13 or movedir == 15 or movedir == 3 or movedir == 14 or movedir == 16)) then -- we are strafing outside the maxrange
							if ( movedir == 2 or movedir == 13 or movedir == 15) then
								Player:UnSetMovement(2) -- stop moving Left	
							elseif( movedir == 3 or movedir == 14 or movedir == 16) then
								Player:UnSetMovement(3) -- stop moving Right
							end							
						end
					end
				end		
			end
			
			
			
			--Set New Movement
			if ( Tdist ~= nil and wt_core_state_combat.combatMoveTmr == 0 or wt_global_information.Now - wt_core_state_combat.combatMoveTmr > 0 and OkToMove() and Player.onmeshexact and Player:IsFacingTarget() and T.los and Player.inCombat) then	
				wt_core_state_combat.combatMoveTmr = wt_global_information.Now + math.random(1000,2500)
				
				--tablecount:  1, 2, 3, 4, 5   --Table index starts at 1, not 0 
				local dirs = { 0, 1, 2, 3, 4 } --Forward = 0, Backward = 1, Left = 2, Right = 3, + stop
				
				-- yeahyeah, redudant code, but I may change the behavior later..
				if (wt_global_information.AttackRange > 300 ) then
										
					-- RANGE
					if (Tdist < wt_global_information.AttackRange ) then						
						if (Tdist > (wt_global_information.AttackRange * 0.85)) then 
							table.remove(dirs,2) -- We are too far away to walk backwards
						end
						if (Tdist < 600) then 
							table.remove(dirs,1) -- We are too close to walk forwards
						end							
						if (movedir == 2 or Tdist < 50) then 
							table.remove(dirs,4) -- We are moving left, so don't try to go right
						end							
						if (movedir == 3 or Tdist < 50) then
							table.remove(dirs,3) -- We are moving right, so don't try to go left
						end							
					end					
					
				else
					-- MELEE
					if (Tdist < wt_global_information.AttackRange ) then						
						if (Tdist > 200) then 
							table.remove(dirs,2) -- We are too far away to walk backwards
						end
						if (Tdist < 100) then 
							table.remove(dirs,1) -- We are too close to walk forwards
						end							
						if (movedir == 2 or Tdist < 50) then 
							table.remove(dirs,4) -- We are moving left, so don't try to go right
						end							
						if (movedir == 3 or Tdist < 50) then
							table.remove(dirs,3) -- We are moving right, so don't try to go left
						end							
					end						
				end
				
				-- MOVE
				local dir = dirs[ math.random( #dirs ) ] 
				--wt_debug("MOVING DIR: "..tostring(dir))
				if ( dir ~= 4) then				
					-- I could have just used a table instead of 4 variables...too lazy to change it now lol										
					Player:SetMovement(dir)
				else 
					wt_core_state_combat.StopCM()
				end
				
				
				--[[ JUMP
				if (wt_core_state_combat.combatJumpTmr == 0 ) then
					wt_core_state_combat.combatJumpTmr = wt_global_information.Now + math.random(5000,10000)
				elseif(wt_global_information.Now - wt_core_state_combat.combatJumpTmr > 0) then	
					wt_core_state_combat.combatJumpTmr = wt_global_information.Now + math.random(2500,10000)
					local jmp = math.random(0,3)
					if ( jmp == 1) then
						Player:Jump()
					end		
				end	]]
				
			end	
		else
			wt_core_state_combat.StopCM()
		end
	end
end
function e_combatmove:execute()
	
end


--/////////////////////////////////////////////////////
-- Sets our target for this combatstate
function wt_core_state_combat.setTarget( CurrentTarget )
	if ( CurrentTarget ~= nil and CurrentTarget ~= 0 ) then
		wt_core_state_combat.CurrentTarget = CurrentTarget
		Player:StopMoving()
	else
		wt_core_state_combat.CurrentTarget = 0
	end
end


--/////////////////////////////////////////////////////
function wt_core_state_combat:initialize()

		local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
		wt_core_state_combat:add( ke_died )

		local ke_combat_over = wt_kelement:create( "combat_over", c_combat_over, e_combat_over, 150 )
		wt_core_state_combat:add( ke_combat_over )

		local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 145 )
		wt_core_state_combat:add( ke_quickloot )
		
		local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 144 )
		wt_core_state_combat:add( ke_quicklootchest )	
		
		local ke_skillstuckcheck = wt_kelement:create( "UnStuckSkill", c_skillstuckcheck, e_skillstuckcheck, 135 )
		wt_core_state_combat:add( ke_skillstuckcheck )	
		
		local ke_revivparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 130 )
		wt_core_state_combat:add( ke_revivparty )	
		
		local ke_invincibleCheck = wt_kelement:create( "InvincibleCheck", c_invi_check, e_invi_check, 128 )
		wt_core_state_combat:add( ke_invincibleCheck )
		
		--groupbotting, focustargetbroadcast @ prio 126
				
		local ke_better_target_search = wt_kelement:create( "better_target_search", c_better_target_search, e_better_target_search, 125 )
		wt_core_state_combat:add( ke_better_target_search )
		
		local ke_heal_action = wt_kelement:create("heal_action",c_heal_action,e_heal_action, 100 )
		wt_core_state_combat:add(ke_heal_action)
		
		local ke_CombatMove = wt_kelement:create("CombatMove",c_combatmove,e_combatmove, 85 )
		wt_core_state_combat:add(ke_CombatMove)
		
		local ke_MoveClose_action = wt_kelement:create("Move closer",c_MoveCloser,e_MoveCloser, 75 )
		wt_core_state_combat:add(ke_MoveClose_action)
end

-- setup kelements for the state
wt_core_state_combat:initialize()
-- register the State with the system
wt_core_state_combat:register()
