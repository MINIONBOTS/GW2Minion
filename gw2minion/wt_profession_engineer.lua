-- This file contains Engineer specific combat routines

-- load routine only if player is a Engineer
if ( 3 ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_engineer  =  inheritsFrom( nil )
wt_profession_engineer.professionID = 3 -- needs to be set
wt_profession_engineer.professionRoutineName = "Engineer"
wt_profession_engineer.professionRoutineVersion = "1.1"
wt_profession_engineer.RestHealthLimit = math.random(60,75)
wt_profession_engineer.switchweaponTmr = 0
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
wt_profession_engineer.c_heal_action = inheritsFrom(wt_cause)
wt_profession_engineer.e_heal_action = inheritsFrom(wt_effect)

function wt_profession_engineer.c_heal_action:evaluate()
	return (Player.health.percent < wt_profession_engineer.RestHealthLimit and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6))
end
wt_profession_engineer.e_heal_action.usesAbility = true

function wt_profession_engineer.e_heal_action:execute()
	wt_debug("e_heal_action")
	Player:CastSpell(GW2.SKILLBARSLOT.Slot_6)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
wt_profession_engineer.c_MoveCloser = inheritsFrom(wt_cause)
wt_profession_engineer.e_MoveCloser = inheritsFrom(wt_effect)

function wt_profession_engineer.c_MoveCloser:evaluate()
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

function wt_profession_engineer.e_MoveCloser:execute()
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
function wt_profession_engineer.GetMainHandWeapon(MainHand)
	-- A bit stoopid but failsafe way to always get the correct weapons
	--d(Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID)
	if (MainHand ~= nil ) then
		if     (MainHand.skillID == 5814 or MainHand.skillID == 6003) then return ("Rifle") 
		elseif (MainHand.skillID == 5827 or MainHand.skillID == 6042  ) then return ("Pistol")
		elseif (MainHand.skillID == 5928 ) then return ("Flamethrower")
		elseif (MainHand.skillID == 5934 or MainHand.skillID == 6048  ) then return ("Elixiergun")
		elseif (MainHand.skillID == 5882 or MainHand.skillID == 6017  ) then return ("Grenades")
		elseif (MainHand.skillID == 5992 ) then return ("Crowbar")
		elseif (MainHand.skillID == 5842 ) then return ("Bigbomb")
		end
	end
	return "default"
end
-- Determine our weapon
function wt_profession_engineer.GetOffHandWeapon(OffHand)
	if (OffHand ~= nil ) then
		if     (OffHand.skillID == 5801 or OffHand.skillID == 6154) then return ("Rifle") 
		elseif (OffHand.skillID == 5831 or OffHand.skillID == 6152) then return ("Pistol") 
		elseif (OffHand.skillID == 6053 ) then return ("Shield")
		elseif (OffHand.skillID == 5929 ) then return ("Flamethrower")
		elseif (OffHand.skillID == 5936 ) then return ("Elixiergun")
		elseif (OffHand.skillID == 5809 or OffHand.skillID == 6016) then return ("Grenades")
		elseif (OffHand.skillID == 5998 ) then return ("Crowbar")
		elseif (OffHand.skillID == 5824 ) then return ("Bigbomb")
		end
	end
	return "default"
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Randomly switch Weaponset
function wt_profession_engineer.SwitchWeapon()	
	if ( gEngSwapWeapons == "1" and (wt_profession_engineer.switchweaponTmr == 0 or wt_global_information.Now - wt_profession_engineer.switchweaponTmr > math.random(1500,5000))) then	
		wt_profession_engineer.switchweaponTmr = wt_global_information.Now
		local SK7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
		local SK8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
		local SK9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
		-- 5927 - Flamethrower / off:6114
		-- 5933 - Elixiergun / off:6115
		-- 5904 - Crowbar / off: 6113
		-- 5812 - Bigbomb / off: 6111
		-- 5805/6020 - Grenades / off: 6110
		
		-- Switch back to normal weapon
		if ( SK7 ~= nil and SK7.skillID == 6114 or SK7.skillID == 6115 or SK7.skillID == 6113 or SK7.skillID == 6111 or SK7.skillID == 6110) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
			return true
		elseif ( SK8 ~= nil and SK8.skillID == 6114 or SK8.skillID == 6115 or SK8.skillID == 6113 or SK8.skillID == 6111 or SK8.skillID == 6110) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
			return true
		elseif ( SK9 ~= nil and SK9.skillID == 6114 or SK9.skillID == 6115 or SK9.skillID == 6113 or SK9.skillID == 6111 or SK9.skillID == 6110) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
			return true
		end
		
		-- Switch to Kit
		if ( SK7 ~= nil and (SK7.skillID == 5927 or SK7.skillID == 5933 or SK7.skillID == 5904 or SK7.skillID == 5812 or SK7.skillID == 5805 or SK7.skillID ==6020) and  not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7)) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
			return true
		elseif ( SK8 ~= nil and (SK8.skillID == 5927 or SK8.skillID == 5933 or SK8.skillID == 5904 or SK8.skillID == 5812 or SK8.skillID == 5805 or SK7.skillID ==6020) and  not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8)) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
			return true
		elseif ( SK9 ~= nil and (SK9.skillID == 5927 or SK9.skillID == 5933 or SK9.skillID == 5904 or SK9.skillID == 5812 or SK9.skillID == 5805 or SK7.skillID ==6020 ) and  not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9)) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
			return true
		end
	end
	return false 
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Default Attack 
wt_profession_engineer.c_attack_default = inheritsFrom(wt_cause)
wt_profession_engineer.e_attack_default = inheritsFrom(wt_effect)

function wt_profession_engineer.c_attack_default:evaluate()
	  return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_engineer.e_attack_default.usesAbility = true
function wt_profession_engineer.e_attack_default:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
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
			--if ( gWarUseBurst == "1" and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_13) and F1~=nil and Player:GetProfessionPowerPercentage() == 100 and (T.distance < F1.maxRange)) then
			--		Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
			--		return
			--end
			-- Skill 7,8,9,Elite
			if ( tonumber(gEngSK7) > 0 ) then
				local SK7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
				if ( SK7 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7) and Player.health.percent < randomize(tonumber(gEngSK7)) and (T.distance < SK7.maxRange or T.distance < 140 or SK7.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
					return
				end
			end
			if ( tonumber(gEngSK8) > 0 ) then
				local SK8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
				if ( SK8 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8) and Player.health.percent < randomize(tonumber(gEngSK8)) and (T.distance < SK8.maxRange or T.distance < 140 or SK8.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
					return
				end
			end
			if ( tonumber(gEngSK9) > 0 ) then
				local SK9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
				if ( SK9 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9) and Player.health.percent < randomize(tonumber(gEngSK9)) and (T.distance < SK9.maxRange or T.distance < 140 or SK9.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
					return
				end
			end
			if ( tonumber(gEngSK10) > 0 ) then
				local SK10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10)
				if ( SK10 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_10) and Player.health.percent < randomize(tonumber(gEngSK10)) and (T.distance < SK10.maxRange or T.distance < 140 or SK10.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_10)
					return
				end
			end
			
			-- Attack with weapon
			local myMHWeap = wt_profession_engineer.GetMainHandWeapon(s1)
			local myOHWeap = wt_profession_engineer.GetOffHandWeapon(s4)
						
			if ( myOHWeap == "Rifle" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange) and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return
					end
				end
			end
			if ( myOHWeap == "Pistol") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange and T.distance > 160 and T.movementstate == GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 200) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return				
					end
				end	
			end				
			if ( myOHWeap == "Shield") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end
			if ( myOHWeap == "Elixiergun") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 240 and Player.health.percent < math.random(75,90)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end
			if ( myOHWeap == "Flamethrower") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end	
			if ( myOHWeap == "Grenades") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and ((T.distance < s5.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) or T.distance < 600)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and ((T.distance < s5.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) or T.distance < 600)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end	
			if ( myOHWeap == "Crowbar") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange and T.distance > 600)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160 and T.inCombat) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end	
			if ( myOHWeap == "Bigbomb") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end	
			
			------
			if ( myMHWeap == "Rifle" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 100) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID) 
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange and T.distance > 160 and T.movementstate == GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "Pistol") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end			
			elseif ( myMHWeap == "Elixiergun") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end	
			elseif ( myMHWeap == "Flamethrower") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end	
			elseif ( myMHWeap == "Grenades") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and ((T.distance < s3.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) or T.distance < 600)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and ((T.distance < s2.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) or T.distance < 600)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and ((T.distance < s1.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) or T.distance < 600)) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end	
			elseif ( myMHWeap == "Crowbar") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_engineer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "Bigbomb") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < 160) then
						if (not wt_profession_engineer.SwitchWeapon()) then
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
function wt_profession_engineer.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gEngSwapWeapons" or k == "gEngSK7" or k == "gEngSK8" or k == "gEngSK9" or k == "gEngSK10") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_profession_engineer:HandleInit() 	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoSwapToKits","gEngSwapWeapons","Engineer-Settings");
	GUI_NewLabel(wt_global_information.MainWindow.Name,"Allowed Range [0-100], 0=Disabled","Engineer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill7 at HP%","gEngSK7","Engineer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill8 at HP%","gEngSK8","Engineer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill9 at HP%","gEngSK9","Engineer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Elite  at HP%","gEngSK10","Engineer-Settings");
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	
	gEngSwapWeapons = Settings.GW2MINION.gEngSwapWeapons
	gEngSK7 = Settings.GW2MINION.gEngSK7
	gEngSK8 = Settings.GW2MINION.gEngSK8
	gEngSK9 = Settings.GW2MINION.gEngSK9
	gEngSK10 = Settings.GW2MINION.gEngSK10
	
end
-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_engineer.professionID > -1 and wt_profession_engineer.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Engineer")
	
	-- GUI Elements
	if ( Settings.GW2MINION.gEngSwapWeapons == nil ) then
		Settings.GW2MINION.gEngSwapWeapons = "0"
	end
	if ( Settings.GW2MINION.gEngSK7 == nil ) then
		Settings.GW2MINION.gEngSK7 = "0"
	end
	if ( Settings.GW2MINION.gEngSK8 == nil ) then
		Settings.GW2MINION.gEngSK8 = "0"
	end
	if ( Settings.GW2MINION.gEngSK9 == nil ) then
		Settings.GW2MINION.gEngSK9 = "0"
	end
	if ( Settings.GW2MINION.gEngSK10 == nil ) then
		Settings.GW2MINION.gEngSK10 = "0"
	end
	RegisterEventHandler("Module.Initalize",wt_profession_engineer.HandleInit)
	RegisterEventHandler("GUI.Update",wt_profession_engineer.GUIVarUpdate)
	
				
	-- Our C & E´s for Engineer combat:
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua		
	local ke_heal_action = wt_kelement:create("heal_action",wt_profession_engineer.c_heal_action,wt_profession_engineer.e_heal_action, 100 )
	wt_core_state_combat:add(ke_heal_action)

	local ke_MoveClose_action = wt_kelement:create("Move closer",wt_profession_engineer.c_MoveCloser,wt_profession_engineer.e_MoveCloser, 75 )
	wt_core_state_combat:add(ke_MoveClose_action)
		
	local ke_Attack_default = wt_kelement:create("Attack",wt_profession_engineer.c_attack_default,wt_profession_engineer.e_attack_default, 45 )
	wt_core_state_combat:add(ke_Attack_default)
		

	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_engineer
	wt_global_information.AttackRange = 130
end
-----------------------------------------------------------------------------------













