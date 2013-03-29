-- This file contains Necromancer specific combat routines

-- load routine only if player is a Necromancer
if ( 8 ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_necromancer  =  inheritsFrom( nil )
wt_profession_necromancer.professionID = 8 -- needs to be set
wt_profession_necromancer.professionRoutineName = "Necromancer"
wt_profession_necromancer.professionRoutineVersion = "1.0"
wt_profession_necromancer.switchweaponTmr = 0

wt_profession_necromancer.petIDs = {
    10547, -- Blood Fiend
    10589, -- Shadow Fiend
    10533, -- Bone Fiend
    10541, -- Bone Minions
    10646, -- Flesh Golem
}
wt_profession_necromancer.Slots = {
	GW2.SKILLBARSLOT.Slot_6,
	GW2.SKILLBARSLOT.Slot_7,
	GW2.SKILLBARSLOT.Slot_8,
	GW2.SKILLBARSLOT.Slot_9,
	GW2.SKILLBARSLOT.Slot_10,
}


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- pet Check
wt_profession_necromancer.c_pets = inheritsFrom(wt_cause)
wt_profession_necromancer.e_pets = inheritsFrom(wt_effect)

function wt_profession_necromancer.c_pets:evaluate()	
	if (gAutoUsePets == "1") then
		if (Player.health.percent > 15 ) then 
			for index1, ID in pairs(wt_profession_necromancer.petIDs) do
				for index2, slot in pairs(wt_profession_necromancer.Slots) do
					SpellInfo = Player:GetSpellInfo(slot)
					if (SpellInfo ~= nil) then
						if (ID == SpellInfo.skillID and not Player:IsSpellOnCooldown(slot)) then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

wt_profession_necromancer.e_pets.usesAbility = true
wt_profession_necromancer.e_pets.throttle = math.random( 500, 1000 )
function wt_profession_necromancer.e_pets:execute()
	for index1, ID in pairs(wt_profession_necromancer.petIDs) do
		for index2, slot in pairs(wt_profession_necromancer.Slots) do
			SpellInfo = Player:GetSpellInfo(slot)
			if (SpellInfo ~= nil) then
				if (ID == SpellInfo.skillID and not Player:IsSpellOnCooldown(slot)) then
					Player:CastSpell(slot)
					return true
				end
			end
		end
	end
end


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- Use Traitskills Check
wt_profession_necromancer.c_use_slot_skills = inheritsFrom(wt_cause)
wt_profession_necromancer.e_use_slot_skills = inheritsFrom(wt_effect)
wt_profession_necromancer.e_slotToCast = nil

function wt_profession_necromancer.c_use_slot_skills:evaluate()	
	if (wt_core_state_combat.CurrentTarget ~= 0 ) then 
		TID = wt_core_state_combat.CurrentTarget
		if ( TID ~= 0 ) then
			local T = CharacterList:Get(TID)
			if ( T ~= nil and T.distance ~= nil and T.distance < 1200) then
				for index, slot in pairs(wt_profession_necromancer.Slots) do
					SpellInfo = Player:GetSpellInfo(slot)
					if (SpellInfo ~= nil and not Player:IsSpellOnCooldown(slot)) then
						if (SpellInfo.skillID == 10570 and T.health.percent > 50) then -- Bone Minion's skill
							wt_profession_necromancer.e_slotToCast = slot
							return true
						elseif (SpellInfo.skillID == 10590 and T.health.percent > 50) then -- Shadown Minion's skill
							wt_profession_necromancer.e_slotToCast = slot
							return true
						elseif (SpellInfo.skillID == 10647 and T.health.percent > 50) then -- Flesh Minion's skill
							wt_profession_necromancer.e_slotToCast = slot
							return true
						end
					end
				end	
			end
		end
	end
	return false
end

wt_profession_necromancer.e_use_slot_skills.throttle = math.random( 250, 550 )
function wt_profession_necromancer.e_use_slot_skills:execute()
	if (wt_core_state_combat.CurrentTarget ~= 0 ) then 
		TID = wt_core_state_combat.CurrentTarget
		if ( TID ~= 0 ) then
			local T = CharacterList:Get(TID)
			if ( T ~= nil and T.distance ~= nil and T.distance < 1200) then
				if (wt_profession_necromancer.e_slotToCast ~= nil) then
					SpellInfo = Player:GetSpellInfo(wt_profession_necromancer.e_slotToCast)
					if (SpellInfo ~= nil) then
						if (not Player:IsSpellOnCooldown(wt_profession_necromancer.e_slotToCast)) then
							Player:CastSpell(wt_profession_necromancer.e_slotToCast,TID)
						end
					end	
				end
			end
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Determine our weapons
function wt_profession_necromancer.GetMainHandWeapon(MainHand)
	--d(Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID)
	if (MainHand ~= nil ) then
		if     (MainHand.skillID == 10561 ) then return ("Axe") 
		elseif (MainHand.skillID == 10702 ) then return ("Dagger") 
		elseif (MainHand.skillID == 10698 ) then return ("Scepter")
		elseif (MainHand.skillID == 10596 ) then return ("Staff")	
		elseif (MainHand.skillID == 10554 ) then return ("Shroud")
		end
	end
	return "default"
end
-- Determine our weapon
function wt_profession_necromancer.GetOffHandWeapon(OffHand)
	if (OffHand ~= nil ) then
		if     (OffHand.skillID == 10705 ) then return ("Dagger") 
		elseif (OffHand.skillID == 10568 ) then return ("Staff") 
		elseif (OffHand.skillID == 10707 ) then return ("Focus")
		elseif (OffHand.skillID == 10556 ) then return ("Warhorn")
		elseif (OffHand.skillID == 10594 ) then return ("Shroud")
		end
	end
	return "default"
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Randomly switch Weaponset
function wt_profession_necromancer.SwitchWeapon(current)
	if (wt_profession_necromancer.switchweaponTmr == 0 or wt_global_information.Now - wt_profession_necromancer.switchweaponTmr > math.random(1500,5000)) then	
		wt_profession_necromancer.switchweaponTmr = wt_global_information.Now
		if ( gNecroSwapWeapons == "1" and Player:CanSwapWeaponSet() ) then
			Player:SwapWeaponSet()
			return true
		end
	end
	return false 
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Default Attack 
wt_profession_necromancer.c_attack_default = inheritsFrom(wt_cause)
wt_profession_necromancer.e_attack_default = inheritsFrom(wt_effect)

function wt_profession_necromancer.c_attack_default:evaluate()
	  return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_necromancer.e_attack_default.usesAbility = true
function wt_profession_necromancer.e_attack_default:execute()
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
						
			if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_13) and F1~=nil and F1.skillID == 10574 and Player:GetProfessionPowerPercentage() > 25 and Player.health.percent < math.random(1,55)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
				return
			end
			
			-- Skill 7,8,9,Elite
			if ( tonumber(gNecSK7) > 0 ) then
				local SK7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
				if ( SK7 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7) and Player.health.percent < randomize(tonumber(gNecSK7)) and (T.distance < SK7.maxRange or T.distance < 140 or SK7.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_7)
					return
				end
			end
			if ( tonumber(gNecSK8) > 0 ) then
				local SK8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
				if ( SK8 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8) and Player.health.percent < randomize(tonumber(gNecSK8)) and (T.distance < SK8.maxRange or T.distance < 140 or SK8.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_8)
					return
				end
			end
			if ( tonumber(gNecSK9) > 0 ) then
				local SK9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
				if ( SK9 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9) and Player.health.percent < randomize(tonumber(gNecSK9)) and (T.distance < SK9.maxRange or T.distance < 140 or SK9.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_9)
					return
				end
			end
			if ( tonumber(gNecSK10) > 0 ) then
				local SK10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10)
				if ( SK10 ~= nil and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_10) and Player.health.percent < randomize(tonumber(gNecSK10)) and (T.distance < SK10.maxRange or T.distance < 140 or SK10.maxRange < 100)) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_10)
					return
				end
			end

			
			local myMHWeap = wt_profession_necromancer.GetMainHandWeapon(s1)
			local myOHWeap = wt_profession_necromancer.GetOffHandWeapon(s4)
			
			if ( myOHWeap == "Dagger" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return
					end
				end
			end
			if ( myOHWeap == "Warhorn") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange and T.distance > 300) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return				
					end
				end	
			end	
			if ( myOHWeap == "Staff") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end
			end	
			if ( myOHWeap == "Focus") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID) return
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end				
			end
			if ( myOHWeap == "Shroud") then	
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID) return					
					end
				end				
			end			
			------
			if ( myMHWeap == "Dagger" ) then			
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID) 
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_necromancer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end
			elseif ( myMHWeap == "Axe") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_necromancer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end			
			elseif ( myMHWeap == "Staff") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange and T.movementstate ~= GW2.MOVEMENTSTATE.GroundMoving) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < 160) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_necromancer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end	
			elseif ( myMHWeap == "Scepter") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_necromancer.SwitchWeapon()) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
						end
					end
				end			
			elseif ( myMHWeap == "Shroud") then				
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
						if (not wt_profession_necromancer.SwitchWeapon()) then
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
function wt_profession_necromancer.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gNecroSwapWeapons" or k == "gAutoUsePets" or k == "gNecSK7" or k == "gNecSK8" or k == "gNecSK9" or k == "gNecSK10") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
end

function wt_profession_necromancer:HandleInit() 	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoSwapWeaponSets","gNecroSwapWeapons","Necromancer-Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoUsePets","gAutoUsePets","Necromancer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill7 at HP%","gNecSK7","Necromancer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill8 at HP%","gNecSK8","Necromancer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Skill9 at HP%","gNecSK9","Necromancer-Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Use Elite  at HP%","gNecSK10","Necromancer-Settings");	
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	
	
	gNecroSwapWeapons = Settings.GW2MINION.gNecroSwapWeapons
	gAutoUsePets = Settings.GW2MINION.gAutoUsePets
	gNecSK7 = Settings.GW2MINION.gNecSK7
	gNecSK8 = Settings.GW2MINION.gNecSK8
	gNecSK9 = Settings.GW2MINION.gNecSK9
	gNecSK10 = Settings.GW2MINION.gNecSK10
end
-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_necromancer.professionID > -1 and wt_profession_necromancer.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Necromancer")
	
	-- GUI Elements
	if ( Settings.GW2MINION.gNecroSwapWeapons == nil ) then
		Settings.GW2MINION.gNecroSwapWeapons = "0"
	end
	if ( Settings.GW2MINION.gAutoUsePets == nil ) then
		Settings.GW2MINION.gAutoUsePets = "1"
	end
		if ( Settings.GW2MINION.gNecSK7 == nil ) then
		Settings.GW2MINION.gNecSK7 = "0"
	end
	if ( Settings.GW2MINION.gNecSK8 == nil ) then
		Settings.GW2MINION.gNecSK8 = "0"
	end
	if ( Settings.GW2MINION.gNecSK9 == nil ) then
		Settings.GW2MINION.gNecSK9 = "0"
	end
	if ( Settings.GW2MINION.gNecSK10 == nil ) then
		Settings.GW2MINION.gNecSK10 = "0"
	end
	
	RegisterEventHandler("Module.Initalize",wt_profession_necromancer.HandleInit)
	RegisterEventHandler("GUI.Update",wt_profession_necromancer.GUIVarUpdate)
	
				
	-- Our C & E´s for Necromancer combat:
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua		
		
	local ke_Use_Slot_skills = wt_kelement:create("UseSlotSkills",wt_profession_necromancer.c_use_slot_skills,wt_profession_necromancer.e_use_slot_skills, 55 )
	wt_core_state_combat:add(ke_Use_Slot_skills)
	
	local ke_summonPets = wt_kelement:create("Summon Pets",wt_profession_necromancer.c_pets,wt_profession_necromancer.e_pets, 50 )
	wt_core_state_combat:add(ke_summonPets)
		
	local ke_Attack_default = wt_kelement:create("Attack",wt_profession_necromancer.c_attack_default,wt_profession_necromancer.e_attack_default, 45 )
	wt_core_state_combat:add(ke_Attack_default)
		
		
	-- C & E`s for Idle state	
	local ke_checkPets = wt_kelement:create("Summon Pets",wt_profession_necromancer.c_pets,wt_profession_necromancer.e_pets, 95 )
	wt_core_state_idle:add(ke_checkPets)
	wt_core_state_minion:add(ke_checkPets)
	
	
	
		
	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_necromancer
	wt_global_information.AttackRange = 450
end















