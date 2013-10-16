-- Combat State for all professions
-- Holds "basic" combat routines, every profession has to add it´s own combat cause&effects to this combatstate

wt_core_state_gcombat = inheritsFrom( wt_core_state )
wt_core_state_gcombat.name = "GCombat"
wt_core_state_gcombat.kelement_list = { }
wt_core_state_gcombat.CurrentTarget = 0
wt_core_state_gcombat.RestHealthLimit = math.random(60,75)
wt_core_state_gcombat.MovementTmr = 0
wt_core_state_gcombat.combatMoveTmr = 0
wt_core_state_gcombat.combatEvadeTmr = 0
wt_core_state_gcombat.combatEvadeLastHP = 0
wt_core_state_gcombat.combatJumpTmr = 0
wt_core_state_gcombat.AttackTmr = 0
wt_core_state_gcombat.LastTargetHP = 0


-- ADD gadget.contentID to this list if the bot should not attack them, better is to PM me the ID + screenshot ;)
wt_core_state_gcombat.Blacklist = {
	[288] = { type = 14, name = "Centaur Test Dummy"},
}



function wt_core_state_gcombat.IsCMActive()
	if (Player:GetMovement() ~= 0 ) then
		return true
	end
	return false
end

function wt_core_state_gcombat.StopCM()
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
c_gcombat_over = inheritsFrom( wt_cause )
e_gcombat_over = inheritsFrom( wt_effect )
function c_gcombat_over:evaluate()
	--local CurrentTarget = Player:GetTarget()
	if ( wt_core_state_gcombat.CurrentTarget == nil or wt_core_state_gcombat.CurrentTarget == 0 ) then
		return true
	else
		-- stop combatmovement when outside the mesh
		if ( Player.movementstate == GW2.MOVEMENTSTATE.GroundMoving and wt_core_state_gcombat.IsCMActive() and not Player.onmeshexact) then
			wt_core_state_gcombat.StopCM()
		end
		local T = GadgetList:Get( wt_core_state_gcombat.CurrentTarget )
		if ( T == nil or not T.alive or not T.onmesh or T.attitude == 0 or T.attitude == 3) then
			if (T == nil or not T.alive or not T.onmesh or T.attitude == 0 or T.attitude == 3)
			or (T ~= nil and wt_global_information.TargetIgnorelist ~= nil and wt_global_information.TargetIgnorelist[T.contentID] ~= nil and wt_global_information.TargetIgnorelist[T.contentID] < T.health.percent)
			or (wt_global_information.TargetBlacklist ~= nil and wt_global_information.TargetBlacklist[wt_core_state_combat.CurrentTarget] ~= nil) then
				Player:ClearTarget()
				wt_core_state_gcombat.StopCM()
				return true
			end
		end
	end
	return false
end
function e_gcombat_over:execute()
	wt_debug( "Gadget Combat finished" )
	wt_core_state_gcombat.CurrentTarget = 0
	wt_core_state_gcombat.StopCM()
	Player:ClearTarget()
	wt_core_state_gcombat.AttackTmr = 0
	wt_core_state_gcombat.LastTargetHP = 0
	wt_core_controller.requestStateChange( wt_core_state_idle )	
	return
end


--/////////////////////////////////////////////////////
-- Search for a better target Check
local c_gbetter_target_search = inheritsFrom( wt_cause )
local e_gbetter_target_search = inheritsFrom( wt_effect )
function c_gbetter_target_search:evaluate()
	--[[c_gbetter_target_search.TargetList = Gadgetlist( "hashpbar,iscombatant,los,attackable,alive,incombat,noCritter,onmesh,maxdistance="..wt_global_information.AttackRange..",exclude="..wt_core_state_gcombat.CurrentTarget )
	return ( TableSize( c_gbetter_target_search.TargetList ) > 0 )]]
	return false
end
function e_gbetter_target_search:execute()
	nextTarget, E  = next( c_gbetter_target_search.TargetList )
	if ( nextTarget ~= nil ) then
		--wt_debug( "Combat: Switching to better target " .. nextTarget )		
		wt_core_state_gcombat.StopCM()
		wt_core_state_gcombat.setTarget( nextTarget )
		wt_core_state_gcombat.AttackTmr = 0
		wt_core_state_gcombat.LastTargetHP = 0
		-- CRASHES LIKE SHIT, DONT KNOW WHY
		--[[if (gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			if ( Player:GetRole() == 1 ) then
				MultiBotSend( "5;"..tonumber(nextTarget),"gw2minion" ) -- Set FocusTarget for Minions
			else
				MultiBotSend( "6;"..tonumber(nextTarget),"gw2minion" )	-- Inform leader about our aggro target
			end
		end]]
	end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
c_gMoveCloser = inheritsFrom(wt_cause)
e_gMoveCloser = inheritsFrom(wt_effect)
function c_gMoveCloser:evaluate()
	if ( wt_core_state_gcombat.CurrentTarget ~= nil and wt_core_state_gcombat.CurrentTarget ~= 0 ) then
		local T = GadgetList:Get(wt_core_state_gcombat.CurrentTarget)
		if ( T ~= nil ) then
			local Distance = T.distance or 0
			local LOS = T.los or false
			if (Distance >= wt_global_information.AttackRange or (LOS~=true and Distance > 200)) then				
				return true
			else
				if( Player:GetTarget() ~= wt_core_state_gcombat.CurrentTarget) then
					Player:SetTarget(wt_core_state_gcombat.CurrentTarget)
				end
			end
		end
	end
	return false;
end
function e_gMoveCloser:execute()
	if ( wt_core_state_gcombat.CurrentTarget ~= nil and wt_core_state_gcombat.CurrentTarget ~= 0 ) then
		local T = GadgetList:Get(wt_core_state_gcombat.CurrentTarget)
		if ( T ~= nil ) then
			local Tpos = T.pos
			Player:MoveTo(Tpos.x,Tpos.y,Tpos.z,120) -- the last number is the distance to the target where to stop
		end
	end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Random CombatMovement
c_gcombatmove = inheritsFrom(wt_cause)
e_gcombatmove = inheritsFrom(wt_effect)
function c_gcombatmove:evaluate()	
	if ( gCombatmovement == "1" and wt_core_state_gcombat.CurrentTarget ~= nil and wt_core_state_gcombat.CurrentTarget ~= 0 ) then
		
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
		
		
		local T = GadgetList:Get(wt_core_state_gcombat.CurrentTarget)
		if ( T ~= nil ) then
			local Tdist = T.distance					
			local playerHP = Player.health.percent
			local movedir = Player:GetMovement()
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange or 160
			end
			
			
			-- I know this should get an own state, but I'm too lazy now
			if ( T.distance < wt_global_information.AttackRange and (Player:GetCurrentlyCastedSpell() == 17)) then
				if ( wt_core_state_gcombat.AttackTmr == 0 or wt_core_state_gcombat.LastTargetHP == 0 or T.health.percent ~= wt_core_state_gcombat.LastTargetHP) then 
					wt_core_state_gcombat.LastTargetHP = T.health.percent
					wt_core_state_gcombat.AttackTmr = wt_global_information.Now
				elseif ( wt_global_information.Now - wt_core_state_gcombat.AttackTmr > 10000 and T.health.percent == wt_core_state_gcombat.LastTargetHP) then
					wt_debug("Cant attack Target. Going to ignore it for now.")
					wt_core_state_gcombat.AttackTmr = 0
					wt_core_state_gcombat.LastTargetHP = 0
					wt_global_information.TargetBlacklist[wt_core_state_gcombat.CurrentTarget] = wt_global_information.Now
				end
			end
			
			
			-- EVADE
			if (wt_core_state_gcombat.combatEvadeTmr == 0 or wt_global_information.Now - wt_core_state_gcombat.combatEvadeTmr > 2000) then
				wt_core_state_gcombat.combatEvadeTmr = wt_global_information.Now				
				wt_core_state_gcombat.combatEvadeLastHP = 0
			end				
			if (wt_core_state_gcombat.combatEvadeLastHP > 0 ) then
				if (wt_core_state_gcombat.combatEvadeLastHP <= playerHP) then
					wt_core_state_gcombat.combatEvadeLastHP = playerHP
				elseif (wt_core_state_gcombat.combatEvadeLastHP - playerHP > math.random(5,10) and Player.endurance >= 50 and Player:IsFacingTarget()) then
				-- we lost 5-10% hp in the last 2,5seconds, evade!
					wt_debug("Evade!");
					local tries = 0
					while (tries < 4) do
						local direction = math.random(0,7)
						if (Player:CanEvade(direction)) then
							Player:Evade(direction)
							wt_core_state_gcombat.combatEvadeLastHP = 0
							return
						end
						tries = tries + 1
					end					
				end
			else 
				wt_core_state_gcombat.combatEvadeLastHP = playerHP
			end
			
			
			--CONTROL CURRENT COMBAT MOVEMENT
			if ( wt_core_state_gcombat.IsCMActive() ) then
				if (Player.inCombat and not Player:IsFacingTarget() and Tdist > 150) then
					Player:UnSetMovement(1)
					Player:UnSetMovement(2)
					Player:UnSetMovement(3)
					local Tpos = T.pos
					Player:MoveTo(Tpos.x,Tpos.y,Tpos.z,110)
				end
				
				if (Tdist ~= nil) then
					if (wt_global_information.AttackRange > 300) then
						-- RANGE
						if (Tdist < wt_global_information.AttackRange / 3 and (movedir == 0 or movedir == 13 or movedir == 14)) then -- we are too close	and moving towards enemy						
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
						elseif (Tdist > wt_global_information.AttackRange + 50 and (movedir == 2 or movedir == 13 or movedir == 15 or movedir == 3 or movedir == 14 or movedir == 16)) then -- we are strafing outside the maxrange
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
			if ( Tdist ~= nil and wt_core_state_gcombat.combatMoveTmr == 0 or wt_global_information.Now - wt_core_state_gcombat.combatMoveTmr > 0 and OkToMove() and Player.onmeshexact and Player:IsFacingTarget() and T.los and Player.inCombat) then	
				wt_core_state_gcombat.combatMoveTmr = wt_global_information.Now + math.random(1000,2500)
				
				--tablecount:  1, 2, 3, 4, 5   --Table index starts at 1, not 0 
				local dirs = { 0, 1, 2, 3, 4 } --Forward = 0, Backward = 1, Left = 2, Right = 3, + stop
				
				-- yeahyeah, redudant code, but I may change the behavior later..
				if (wt_global_information.AttackRange > 300 ) then
										
					-- RANGE
					if (Tdist < wt_global_information.AttackRange ) then						
						if (Tdist > (wt_global_information.AttackRange * 0.85)) then 
							table.remove(dirs,2) -- We are too far away to walk backwards
						end
						if (Tdist < 160) then 
							table.remove(dirs,1) -- We are too close to walk forwards
						end							
						if (movedir == 2) then 
							table.remove(dirs,4) -- We are moving left, so don't try to go right
						end							
						if (movedir == 3) then
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
						if (movedir == 2) then 
							table.remove(dirs,4) -- We are moving left, so don't try to go right
						end							
						if (movedir == 3) then
							table.remove(dirs,3) -- We are moving right, so don't try to go left
						end							
					end						
				end
				
				-- MOVE
				local dir = dirs[ math.random( #dirs ) ] 
				wt_debug("MOVING DIR: "..tostring(dir))
				if ( dir ~= 4) then				
					-- I could have just used a table instead of 4 variables...too lazy to change it now lol										
					Player:SetMovement(dir)
				else 
					wt_core_state_gcombat.StopCM()
				end
				
				
				--[[ JUMP
				if (wt_core_state_gcombat.combatJumpTmr == 0 ) then
					wt_core_state_gcombat.combatJumpTmr = wt_global_information.Now + math.random(5000,10000)
				elseif(wt_global_information.Now - wt_core_state_gcombat.combatJumpTmr > 0) then	
					wt_core_state_gcombat.combatJumpTmr = wt_global_information.Now + math.random(2500,10000)
					local jmp = math.random(0,3)
					if ( jmp == 1) then
						Player:Jump()
					end		
				end	]]
				
			end	
		else
			wt_error("GadgetID is invalid.")
			wt_core_state_gcombat.StopCM()
		end
	end
end
function e_gcombatmove:execute()
	
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Default Attack 
c_gattack_default = inheritsFrom(wt_cause)
e_gattack_default = inheritsFrom(wt_effect)
function c_gattack_default:evaluate()
	return wt_core_state_gcombat.CurrentTarget ~= 0
end
e_gattack_default.usesAbility = true
function e_gattack_default:execute()
	TID = wt_core_state_gcombat.CurrentTarget
	if ( TID ~= nil and TID ~= 0 ) then
		local T = GadgetList:Get(TID)
		if ( T ~= nil ) then		
			--wt_debug("attacking " .. wt_core_state_gcombat.CurrentTarget .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100) and not s5.isGroundTargeted) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID,gadget)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)and not s5.isGroundTargeted) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID,gadget)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)and not s5.isGroundTargeted) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID,gadget)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)and not s5.isGroundTargeted) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID,gadget)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID,gadget)
				end
			end	
		end
	end
end


--/////////////////////////////////////////////////////
-- Sets our target for this combatstate
function wt_core_state_gcombat.setTarget( CurrentTarget )
	if ( CurrentTarget ~= nil and CurrentTarget ~= 0 ) then
		wt_core_state_gcombat.CurrentTarget = CurrentTarget
		Player:StopMoving()
	else
		wt_core_state_gcombat.CurrentTarget = 0
	end
end


--/////////////////////////////////////////////////////
function wt_core_state_gcombat:initialize()

		local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
		wt_core_state_gcombat:add( ke_died )

		local ke_gcombat_over = wt_kelement:create( "gcombat_over", c_gcombat_over, e_gcombat_over, 150 )
		wt_core_state_gcombat:add( ke_gcombat_over )

		local ke_quickloot = wt_kelement:create( "QuickLoot", c_quickloot, e_quickloot, 145 )
		wt_core_state_gcombat:add( ke_quickloot )
		
		local ke_quicklootchest = wt_kelement:create( "QuickLootChest", c_quicklootchest, e_quicklootchest, 144 )
		wt_core_state_gcombat:add( ke_quicklootchest )	
		
		local ke_skillstuckcheck = wt_kelement:create( "UnStuckSkill", c_skillstuckcheck, e_skillstuckcheck, 135 )
		wt_core_state_gcombat:add( ke_skillstuckcheck )	
		
		local ke_revivparty = wt_kelement:create( "ReviveParty", c_revivep, e_revivep, 130 )
		wt_core_state_gcombat:add( ke_revivparty )	
		
		--groupbotting, focustargetbroadcast @ prio 126
		
		--local ke_gbetter_target_search = wt_kelement:create( "better_target_search", c_gbetter_target_search, e_gbetter_target_search, 125 )
		--wt_core_state_gcombat:add( ke_gbetter_target_search )
		
		local ke_heal_action = wt_kelement:create("heal_action",c_heal_action,e_heal_action, 100 )
		wt_core_state_gcombat:add(ke_heal_action)
		
		local ke_gcombatmove = wt_kelement:create("CombatMove",c_gcombatmove,e_gcombatmove, 85 )
		wt_core_state_gcombat:add(ke_gcombatmove)
		
		local ke_MoveClose_action = wt_kelement:create("Move closer",c_gMoveCloser,e_gMoveCloser, 75 )
		wt_core_state_gcombat:add(ke_MoveClose_action)
		
		local ke_GAttack_default = wt_kelement:create("GAttack",c_gattack_default,e_gattack_default, 45 )
		wt_core_state_gcombat:add(ke_GAttack_default)
end

-- setup kelements for the state
wt_core_state_gcombat:initialize()
-- register the State with the system
wt_core_state_gcombat:register()
