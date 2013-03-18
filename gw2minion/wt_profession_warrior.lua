-- This file contains warrior specific combat routines
if (not Player) then
return
end
-- Load routine only if player is a warrior
if ( 2 ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_warrior  =  inheritsFrom( nil )
wt_profession_warrior.professionID = 2 -- needs to be set
wt_profession_warrior.professionRoutineName = "Warrior"
wt_profession_warrior.professionRoutineVersion = "1.0"
wt_profession_warrior.RestHealthLimit = math.random(60,75)
wt_profession_warrior.switchweaponTmr = 0
wt_profession_warrior.combatMoveTmr = 0
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
wt_profession_warrior.c_heal_action = inheritsFrom(wt_cause)
wt_profession_warrior.e_heal_action = inheritsFrom(wt_effect)

function wt_profession_warrior.c_heal_action:evaluate()
	return (Player.health.percent < wt_profession_warrior.RestHealthLimit and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6))
end
wt_profession_warrior.e_heal_action.usesAbility = true

function wt_profession_warrior.e_heal_action:execute()
	wt_debug("e_heal_action")
	Player:CastSpell(GW2.SKILLBARSLOT.Slot_6)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
wt_profession_warrior.c_MoveCloser = inheritsFrom(wt_cause)
wt_profession_warrior.e_MoveCloser = inheritsFrom(wt_effect)

function wt_profession_warrior.c_MoveCloser:evaluate()
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

function wt_profession_warrior.e_MoveCloser:execute()
	--wt_debug("e_MoveCloser ")
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
-- Determine our weapons
function wt_profession_warrior.GetMainHandWeapon(MainHand)
	-- A bit stoopid but failsafe way to always get the correct weapons
	--d(Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID)
	if (MainHand ~= nil ) then
		if     (MainHand.skillID == 14432 ) then return ("Rifle") 
		elseif (MainHand.skillID == 14356 or MainHand.skillID == 14373 or MainHand.skillID == 14374) then return ("GreatSword") 
		elseif (MainHand.skillID == 14358 ) then return ("Hammer")
		elseif (MainHand.skillID == 14431 ) then return ("Longbow")
		elseif (MainHand.skillID == 14364 or MainHand.skillID == 14365 or MainHand.skillID == 14363) then return ("Sword")
		elseif (MainHand.skillID == 14376 ) then return ("Mace")
		elseif (MainHand.skillID == 14369 or MainHand.skillID == 14371 or MainHand.skillID == 14370) then return ("Axe")		
		end
	end
	return "default"
end
-- Determine our weapon
function wt_profession_warrior.GetOffHandWeapon(OffHand)
	if (OffHand ~= nil ) then
		if     (OffHand.skillID == 14395 ) then return ("Rifle") 
		elseif (OffHand.skillID == 14510 ) then return ("GreatSword") 
		elseif (OffHand.skillID == 14359 ) then return ("Hammer")
		elseif (OffHand.skillID == 14505 ) then return ("Longbow")		
		elseif (OffHand.skillID == 14498 ) then return ("Sword")
		elseif (OffHand.skillID == 14518 ) then return ("Mace")
		elseif (OffHand.skillID == 14418 ) then return ("Axe")		
		elseif (OffHand.skillID == 14393 ) then return ("Warhorn")
		elseif (OffHand.skillID == 14361 ) then return ("Shield")
		end
	end
	return "default"
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Randomly switch Weaponset
function wt_profession_warrior.SwitchWeapon()
	if (wt_profession_warrior.switchweaponTmr == 0 or wt_global_information.Now - wt_profession_warrior.switchweaponTmr > math.random(1500,5000)) then	
		wt_profession_warrior.switchweaponTmr = wt_global_information.Now
		if ( gWarSwapWeapons == "1" and Player:CanSwapWeaponSet() ) then
			Player:SwapWeaponSet()
			return true
		end
	end
	return false 
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Random CombatMovement
function wt_profession_warrior.CombatMovement()
	if (wt_profession_warrior.combatMoveTmr == 0 or wt_global_information.Now - wt_profession_warrior.combatMoveTmr > 1000) then	
		wt_profession_warrior.combatMoveTmr = wt_global_information.Now + math.random(500,2000)
		if (Player:GetMovementState() == 0) then			
			if ( wt_core_state_combat.CurrentTarget ~= nil and wt_core_state_combat.CurrentTarget ~= 0 ) then
				local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
				if ( T ~= nil ) then					
					if (T.distance ~= nil and T.distance < 140) then
						local s = math.random(0,2)
						if( s == 0 and T.health.percent < math.random(0,90) and Player.endurance >= 50) then
							Player:Evade(3)							
						elseif ( s == 1) then
							--Player:SetMovement(2)
						elseif (s == 2) then
							--Player:SetMovement(3)
						end
						return
					end
				end
			end
		else
			Player:StopMoving()
		end
	end	
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Default Attack 
wt_profession_warrior.c_attack_default = inheritsFrom(wt_cause)
wt_profession_warrior.e_attack_default = inheritsFrom(wt_effect)

function wt_profession_warrior.c_attack_default:evaluate()
	  return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_warrior.e_attack_default.usesAbility = true
function wt_profession_warrior.e_attack_default:execute()
	wt_profession_warrior.CombatMovement()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= nil and TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then		
			--wt_debug("attacking " .. wt_core_state_combat.CurrentTarget .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			local F1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
			
			-- F1-F4 Skills
			if ( gWarUseBurst == "1" and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_13) and F1~=nil and Player:GetProfessionPowerPercentage() == 100 and (T.distance < F1.maxRange)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
					return
			end
			-- Skill 7,8,9,Elite
			if ( tonumber(gWarSK7) > 0 ) then
				local SK7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
				if ( SK7 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7) and Player.health.percent < randomize(tonumber(gWarSK7)) and (T.distance < SK7.maxRange or T.distance < 140 or SK7.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
					return
				end
			end
			if ( tonumber(gWarSK8) > 0 ) then
				local SK8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
				if ( SK8 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8) and Player.health.percent < randomize(tonumber(gWarSK8)) and (T.distance < SK8.maxRange or T.distance < 140 or SK8.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
					return
				end
			end
			if ( tonumber(gWarSK9) > 0 ) then
				local SK9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
				if ( SK9 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9) and Player.health.percent < randomize(tonumber(gWarSK9)) and (T.distance < SK9.maxRange or T.distance < 140 or SK9.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
					return
				end
			end
			if ( tonumber(gWarSK10) > 0 ) then
				local SK10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10)
				if ( SK10 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_10) and Player.health.percent < randomize(tonumber(gWarSK10)) and (T.distance < SK10.maxRange or T.distance < 140 or SK10.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_10)
					return
				end
			end
			
			-- Attack with weapon
			local myMHWeap = wt_profession_warrior.GetMainHandWeapon(s1)
			local myOHWeap = wt_profession_warrior.GetOffHandWeapon(s4)
						
			if ( myOHWeap == "Rifle" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return
					end
				end
			end
			if ( myOHWeap == "GreatSword") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return				
					end
				end	
			end				
			if ( myOHWeap == "Hammer") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end
			if ( myOHWeap == "Longbow") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end				
			if ( myOHWeap == "Sword") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return				
					end
				end
			end
			if ( myOHWeap == "Mace") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160 and T.inCombat) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end
			if ( myOHWeap == "Axe") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160 and T.inCombat) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end				
			end
			if ( myOHWeap == "Warhorn") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160 and T.inCombat) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end						
			end
			if ( myOHWeap == "Shield") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160 and T.inCombat) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end
			------
			if ( myMHWeap == "Rifle" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID) 
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "GreatSword") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 500 and T.distance > 350) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end			
			elseif ( myMHWeap == "Hammer") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end	
			elseif ( myMHWeap == "Longbow") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end						
			elseif ( myMHWeap == "Sword") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange and T.distance > 300 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "Mace") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < 160 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "Axe") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange and T.distance > 300 and T.movementstate == GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_warrior.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
				
			
			else --DEFAULT ATTACK
				if (s1 ~= nil) then
					
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
					end
				end
			end	
		end
	end
end


-----------------------------------------------------------------------------------
-- Registration and setup of GUI and causes and effects to the different states for this profession
-----------------------------------------------------------------------------------
function wt_profession_warrior.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gWarSwapWeapons" or k == "gWarUseBurst" or k == "gWarSK7" or k == "gWarSK8" or k == "gWarSK9" or k == "gWarSK10") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_profession_warrior:HandleInit() 	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoSwapWeaponSets","gWarSwapWeapons","Warrior-Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoUse F1","gWarUseBurst","Warrior-Settings");
	GUI_NewLabel(wt_global_information.MainWindow.Name,"Allowed Range [0-100], 0=Disabled","Warrior-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill7 at HP%","gWarSK7","Warrior-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill8 at HP%","gWarSK8","Warrior-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill9 at HP%","gWarSK9","Warrior-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Elite  at HP%","gWarSK10","Warrior-Settings");
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	
	
	gWarSwapWeapons = Settings.GW2MINION.gWarSwapWeapons
	gWarUseBurst = Settings.GW2MINION.gWarUseBurst
	gWarSK7 = Settings.GW2MINION.gWarSK7
	gWarSK8 = Settings.GW2MINION.gWarSK8
	gWarSK9 = Settings.GW2MINION.gWarSK9
	gWarSK10 = Settings.GW2MINION.gWarSK10
	
end
-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_warrior.professionID > -1 and wt_profession_warrior.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Warrior")
	
	-- GUI Elements
	if ( Settings.GW2MINION.gWarSwapWeapons == nil ) then
		Settings.GW2MINION.gWarSwapWeapons = "0"
	end
	if ( Settings.GW2MINION.gWarUseBurst == nil ) then
		Settings.GW2MINION.gWarUseBurst = "0"
	end
	if ( Settings.GW2MINION.gWarSK7 == nil ) then
		Settings.GW2MINION.gWarSK7 = "0"
	end
	if ( Settings.GW2MINION.gWarSK8 == nil ) then
		Settings.GW2MINION.gWarSK8 = "0"
	end
	if ( Settings.GW2MINION.gWarSK9 == nil ) then
		Settings.GW2MINION.gWarSK9 = "0"
	end
	if ( Settings.GW2MINION.gWarSK10 == nil ) then
		Settings.GW2MINION.gWarSK10 = "0"
	end
	RegisterEventHandler("Module.Initalize",wt_profession_warrior.HandleInit)
	RegisterEventHandler("GUI.Update",wt_profession_warrior.GUIVarUpdate)
	
				
	-- Our C & E´s for Warrior combat:
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua		
	local ke_heal_action = wt_kelement:create("heal_action",wt_profession_warrior.c_heal_action,wt_profession_warrior.e_heal_action, 100 )
	wt_core_state_combat:add(ke_heal_action)

	local ke_MoveClose_action = wt_kelement:create("Move closer",wt_profession_warrior.c_MoveCloser,wt_profession_warrior.e_MoveCloser, 75 )
	wt_core_state_combat:add(ke_MoveClose_action)
		
	local ke_Attack_default = wt_kelement:create("Attack",wt_profession_warrior.c_attack_default,wt_profession_warrior.e_attack_default, 45 )
	wt_core_state_combat:add(ke_Attack_default)
		

	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_warrior
	wt_global_information.AttackRange = 130
end
-----------------------------------------------------------------------------------














