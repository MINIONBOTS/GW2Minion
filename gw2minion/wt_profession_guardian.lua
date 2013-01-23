-- This file contains Guardian specific combat routines

-- load routine only if player is a Guardian
if ( GW2.CHARCLASS.Guardian ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_guardian  =  inheritsFrom( nil )
wt_profession_guardian.professionID = 1 -- needs to be set
wt_profession_guardian.professionRoutineName = "Guardian"
wt_profession_guardian.professionRoutineVersion = "1.0"
wt_profession_guardian.RestHealthLimit = 70

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
wt_profession_guardian.c_heal_action = inheritsFrom(wt_cause)
wt_profession_guardian.e_heal_action = inheritsFrom(wt_effect)

function wt_profession_guardian.c_heal_action:evaluate()
	return (Player.health.percent < 50 and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6)) 
	--or (Player.health.percent < 50 and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_14)) 
	--or (Player.health.percent < 50 and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_15))
end
wt_profession_guardian.e_heal_action.usesAbility = true

wt_profession_guardian.e_heal_action.throttle = 2000
function wt_profession_guardian.e_heal_action:execute()
	wt_debug("e_heal_action")
	if ( not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6) ) then
		Player:CastSpell(GW2.SKILLBARSLOT.Slot_6)
	--elseif ( not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_14)) then
	--	Player:CastSpell(GW2.SKILLBARSLOT.Slot_14)
	--elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_15)) then
	--		Player:CastSpell(GW2.SKILLBARSLOT.Slot_15,TID)
	end

	
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
wt_profession_guardian.c_MoveCloser = inheritsFrom(wt_cause)
wt_profession_guardian.e_MoveCloser = inheritsFrom(wt_effect)

function wt_profession_guardian.c_MoveCloser:evaluate()
	if ( wt_core_state_combat.CurrentTarget ~= 0 ) then
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T ~= nil ) then
			if (T.distance >= wt_global_information.AttackRange  or T.los~=true) then
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

function wt_profession_guardian.e_MoveCloser:execute()
	--wt_debug("e_MoveCloser ")
	local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
	if ( T ~= nil ) then
		local s3info = Player:GetSpellInfo( GW2.SKILLBARSLOT.Slot_3 )
		if (s3info.skillID == 9080 and  not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 500) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,wt_core_state_combat.CurrentTarget)
		else
			Player:MoveTo(T.pos.x,T.pos.y,T.pos.z,100) -- the last number is the distance to the target where to stop
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Attack Check
wt_profession_guardian.c_attack_action = inheritsFrom(wt_cause)
wt_profession_guardian.e_attack_action = inheritsFrom(wt_effect)

function wt_profession_guardian.c_attack_action:evaluate()
	return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_guardian.e_attack_action.usesAbility = true
function wt_profession_guardian.e_attack_action:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)		
		if ( T ~= nil ) then
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local MHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
			local OHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
			
			--if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8) and T.distance < 200) then
			--			Player:CastSpell(GW2.SKILLBARSLOT.Slot_8,TID)
			--elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_13) and T.distance < 200) then
			--			Player:CastSpell(GW2.SKILLBARSLOT.Slot_13,TID)
			--else
			if(MHweapon ~= nil and OHweapon == nil) then
				if ( MHweapon.weapontype == GW2.WEAPONTYPE.Staff ) then
					wt_global_information.AttackRange = 600
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 1200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 1200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 600) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				elseif(MHweapon.weapontype == GW2.WEAPONTYPE.Greatsword ) then
					wt_global_information.AttackRange = 130
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 600) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 250) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 130) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				elseif(MHweapon.weapontype == GW2.WEAPONTYPE.Hammer ) then
					wt_global_information.AttackRange = 130
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and  not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 1200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				elseif(MHweapon.weapontype == GW2.WEAPONTYPE.Sword ) then				
					wt_global_information.AttackRange = 130
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				elseif(MHweapon.weapontype == GW2.WEAPONTYPE.Mace ) then				
					wt_global_information.AttackRange = 130
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				elseif(MHweapon.weapontype == GW2.WEAPONTYPE.Scepter ) then				
					wt_global_information.AttackRange = 900
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 1200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				end
			-- 1H x 1H weapons
			elseif(MHweapon ~= nil and OHweapon ~= nil) then
				if ( MHweapon.weapontype == GW2.WEAPONTYPE.Sword ) then	
					if ( OHweapon.weapontype == GW2.WEAPONTYPE.Shield ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Focus ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Torch ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 300) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end					
					end
				elseif ( MHweapon.weapontype == GW2.WEAPONTYPE.Mace ) then	
					if ( OHweapon.weapontype == GW2.WEAPONTYPE.Shield ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Focus ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Torch ) then
						wt_global_information.AttackRange = 130
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 300) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end					
					end
				elseif ( MHweapon.weapontype == GW2.WEAPONTYPE.Scepter ) then	
					if ( OHweapon.weapontype == GW2.WEAPONTYPE.Shield ) then
						wt_global_information.AttackRange = 1200
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 1200) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Focus ) then
						wt_global_information.AttackRange = 1200
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 1200) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					elseif( OHweapon.weapontype == GW2.WEAPONTYPE.Torch ) then
						wt_global_information.AttackRange = 1200
						if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and T.distance < 160) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and T.distance < 300) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)					
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and T.distance < 600) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and T.distance < 400) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
						elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1)and T.distance < 1200) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end				
					end
				end				
			end
		end
	end
end


-----------------------------------------------------------------------------------
-- Registration and setup of causes and effects to the different states
-----------------------------------------------------------------------------------

-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_guardian.professionID > -1 and wt_profession_guardian.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Guardian")
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua
	
	
	-- Our C & E´s for Guardian combat:
	local ke_heal_action = wt_kelement:create("heal_action",wt_profession_guardian.c_heal_action,wt_profession_guardian.e_heal_action, 100 )
		wt_core_state_combat:add(ke_heal_action)
		
	local ke_MoveClose_action = wt_kelement:create("Move closer",wt_profession_guardian.c_MoveCloser,wt_profession_guardian.e_MoveCloser, 75 )
		wt_core_state_combat:add(ke_MoveClose_action)

	local ke_RangedFar_action = wt_kelement:create("Attack",wt_profession_guardian.c_attack_action,wt_profession_guardian.e_attack_action, 50 )
		wt_core_state_combat:add(ke_RangedFar_action)
		

	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_guardian
	wt_global_information.AttackRange = 130
end
-----------------------------------------------------------------------------------














