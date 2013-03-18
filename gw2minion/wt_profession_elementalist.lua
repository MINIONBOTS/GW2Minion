-- This file contains Elementalist specific combat routines

-- load routine only if player is a Elementalist
if ( 6 ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_elementalist  =  inheritsFrom( nil )
wt_profession_elementalist.professionID = 6 -- needs to be set
wt_profession_elementalist.professionRoutineName = "Elementalist"
wt_profession_elementalist.professionRoutineVersion = "1.0"
wt_profession_elementalist.RestHealthLimit = 70
wt_profession_elementalist.switchattunementTmr = 0
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
wt_profession_elementalist.c_heal_action = inheritsFrom(wt_cause)
wt_profession_elementalist.e_heal_action = inheritsFrom(wt_effect)

function wt_profession_elementalist.c_heal_action:evaluate()
	return (Player.health.percent < 50 and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6))
end
wt_profession_elementalist.e_heal_action.usesAbility = true

function wt_profession_elementalist.e_heal_action:execute()
	wt_debug("e_heal_action")
	Player:CastSpell(GW2.SKILLBARSLOT.Slot_6)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Move Closer to Target Check
wt_profession_elementalist.c_MoveCloser = inheritsFrom(wt_cause)
wt_profession_elementalist.e_MoveCloser = inheritsFrom(wt_effect)

function wt_profession_elementalist.c_MoveCloser:evaluate()
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

function wt_profession_elementalist.e_MoveCloser:execute()
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
-- Determine our weapon
function wt_profession_elementalist.getWeapons(MainHand,OffHand)
	-- A bit stoopid but failsafe way to always get the correct weapons
	--local MainHand = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
	if (MainHand ~= nil ) then
		if     (MainHand.skillID == 5491 ) then return ("Staff1") --Fire
		elseif (MainHand.skillID == 5549 ) then return ("Staff2") 
		elseif (MainHand.skillID == 5518 ) then return ("Staff3") 
		elseif (MainHand.skillID == 5519 ) then return ("Staff4") 
		end
	end
	
	--local OffHand = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
	if (MainHand ~= nil and OffHand ~= nil ) then
		if     (MainHand.skillID == 15718 and OffHand.skillID == 5691) then return ("DaggerDagger1") 
		elseif (MainHand.skillID == 15716 and OffHand.skillID == 5520) then return ("DaggerDagger2")
		elseif (MainHand.skillID == 5489  and OffHand.skillID == 5529) then return ("DaggerDagger3")
		elseif (MainHand.skillID == 15717 and OffHand.skillID == 5690) then return ("DaggerDagger4")
		
		elseif (MainHand.skillID == 15718 and OffHand.skillID == 5497) then return ("DaggerFocus1")
		elseif (MainHand.skillID == 15716 and OffHand.skillID == 5556) then return ("DaggerFocus2")
		elseif (MainHand.skillID == 5489  and OffHand.skillID == 5530) then return ("DaggerFocus3")
		elseif (MainHand.skillID == 15717 and OffHand.skillID == 5555) then return ("DaggerFocus4")
		
		elseif (MainHand.skillID == 5508 and OffHand.skillID == 5691) then return ("ScepterDagger1")
		elseif (MainHand.skillID == 5693 and OffHand.skillID == 5520) then return ("ScepterDagger2")
		elseif (MainHand.skillID == 5526 and OffHand.skillID == 5529) then return ("ScepterDagger3")
		elseif (MainHand.skillID == 5500 and OffHand.skillID == 5690) then return ("ScepterDagger4")
		
		elseif (MainHand.skillID == 5508 and OffHand.skillID == 5497) then return ("ScepterFocus1")
		elseif (MainHand.skillID == 5693 and OffHand.skillID == 5556) then return ("ScepterFocus2")
		elseif (MainHand.skillID == 5526 and OffHand.skillID == 5530) then return ("ScepterFocus3")
		elseif (MainHand.skillID == 5500 and OffHand.skillID == 5555) then return ("ScepterFocus4")
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Randomly switch attunement
function wt_profession_elementalist.RandomAttunement(current)
	if (gEleSwap == "1" and (wt_profession_elementalist.switchattunementTmr == 0 or wt_global_information.Now - wt_profession_elementalist.switchattunementTmr > math.random(2500,5000))) then	
		wt_profession_elementalist.switchattunementTmr = wt_global_information.Now
		local switch = math.random(12,15)
		if ( switch ~= current and not Player:IsSpellOnCooldown(switch) ) then
			Player:CastSpell(switch)
			return true
		end
	end
	return false 
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Attack 
wt_profession_elementalist.c_attack_default = inheritsFrom(wt_cause)
wt_profession_elementalist.e_attack_default = inheritsFrom(wt_effect)

function wt_profession_elementalist.c_attack_default:evaluate()
	  return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_elementalist.e_attack_default.usesAbility = true

function wt_profession_elementalist.e_attack_default:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then						
			--wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			--local f1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
			--local f2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_14)
			--local f3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_15)
			--local f4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_16)
			-- Determine the Weapons we have by checking what spell is in slot1 and 4
			
			-- Skill 7,8,9,Elite
			if ( tonumber(gEleSK7) > 0 ) then
				local SK7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
				if ( SK7 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7) and Player.health.percent < randomize(tonumber(gEleSK7)) and (T.distance < SK7.maxRange or T.distance < 140 or SK7.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
					return
				end
			end
			if ( tonumber(gEleSK8) > 0 ) then
				local SK8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
				if ( SK8 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8) and Player.health.percent < randomize(tonumber(gEleSK8)) and (T.distance < SK8.maxRange or T.distance < 140 or SK8.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
					return
				end
			end
			if ( tonumber(gEleSK9) > 0 ) then
				local SK9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
				if ( SK9 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9) and Player.health.percent < randomize(tonumber(gEleSK9)) and (T.distance < SK9.maxRange or T.distance < 140 or SK9.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
					return
				end
			end
			if ( tonumber(gEleSK10) > 0 ) then
				local SK10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10)
				if ( SK10 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_10) and Player.health.percent < randomize(tonumber(gEleSK10)) and (T.distance < SK10.maxRange or T.distance < 140 or SK10.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_10)
					return
				end
			end
			
			local myWeap = wt_profession_elementalist.getWeapons(s1,s4)
						
			if ( myWeap == "Staff1" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange) and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					--elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						--Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(12)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "Staff2") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(13)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
				elseif ( myWeap == "Staff3") then
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < 400 or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(14)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "Staff4") then
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and Player.health.percent < math.random(10,70) and(T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100) and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(15)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerDagger1") then --fire
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(12)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerDagger2") then --water
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and Player.health.percent < math.random(50,75)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(13)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerDagger3") then --lightning
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 180 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(14)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerDagger4") then -- earth
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 350 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 230 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < 240) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(15)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end			
			elseif ( myWeap == "ScepterDagger1") then --fire
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(12)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterDagger2") then --water
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and Player.health.percent < math.random(50,75)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(13)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterDagger3") then --lightning
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 180 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(14)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterDagger4") then -- earth
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 350 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 230 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(15)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterFocus1") then --fire
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(12)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterFocus2") then --water
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(13)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterFocus3") then --lightning
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 300 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(14)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "ScepterFocus4") then -- earth
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 180 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(15)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerFocus1") then --fire
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(12)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerFocus2") then --water
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and Player.health.percent < math.random(50,75)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(13)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerFocus3") then --lightning
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 180 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(14)) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myWeap == "DaggerFocus4") then -- earth
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 350 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < 230 ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						if (not wt_profession_elementalist.RandomAttunement(15)) then
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
-- Registration and setup of causes and effects to the different states
-----------------------------------------------------------------------------------
function wt_profession_elementalist.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gEleSwap" or k == "gEleSK7" or k == "gEleSK8" or k == "gEleSK9" or k == "gEleSK10") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_profession_elementalist:HandleInit() 	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoSwapAttunements","gEleSwap","Elementalist-Settings");
	GUI_NewLabel(wt_global_information.MainWindow.Name,"Allowed Range [0-100], 0=Disabled","Elementalist-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill7 at HP%","gEleSK7","Elementalist-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill8 at HP%","gEleSK8","Elementalist-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill9 at HP%","gEleSK9","Elementalist-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Elite  at HP%","gEleSK10","Elementalist-Settings");
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	
	
	gEleSwap = Settings.GW2MINION.gEleSwap
	gEleSK7 = Settings.GW2MINION.gEleSK7
	gEleSK8 = Settings.GW2MINION.gEleSK8
	gEleSK9 = Settings.GW2MINION.gEleSK9
	gEleSK10 = Settings.GW2MINION.gEleSK10
	
end
-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_elementalist.professionID > -1 and wt_profession_elementalist.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Elementalist")
	
	-- GUI Elements
	if ( Settings.GW2MINION.gEleSwap == nil ) then
		Settings.GW2MINION.gEleSwap = "0"
	end
	if ( Settings.GW2MINION.gEleSK7 == nil ) then
		Settings.GW2MINION.gEleSK7 = "0"
	end
	if ( Settings.GW2MINION.gEleSK8 == nil ) then
		Settings.GW2MINION.gEleSK8 = "0"
	end
	if ( Settings.GW2MINION.gEleSK9 == nil ) then
		Settings.GW2MINION.gEleSK9 = "0"
	end
	if ( Settings.GW2MINION.gEleSK10 == nil ) then
		Settings.GW2MINION.gEleSK10 = "0"
	end
	RegisterEventHandler("Module.Initalize",wt_profession_elementalist.HandleInit)
	RegisterEventHandler("GUI.Update",wt_profession_elementalist.GUIVarUpdate)
	
	
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua
	
	
	-- Our C & E´s for Elementalist combat:
	local ke_heal_action = wt_kelement:create("heal_action",wt_profession_elementalist.c_heal_action,wt_profession_elementalist.e_heal_action, 100 )
		wt_core_state_combat:add(ke_heal_action)
		
	local ke_MoveClose_action = wt_kelement:create("Move closer",wt_profession_elementalist.c_MoveCloser,wt_profession_elementalist.e_MoveCloser, 75 )
		wt_core_state_combat:add(ke_MoveClose_action)

		
	local ke_Attack_default = wt_kelement:create("Attack",wt_profession_elementalist.c_attack_default,wt_profession_elementalist.e_attack_default, 45 )
		wt_core_state_combat:add(ke_Attack_default)
		

	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_elementalist
	wt_global_information.AttackRange = 900
end
-----------------------------------------------------------------------------------














