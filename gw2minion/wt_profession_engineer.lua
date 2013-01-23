-- This file contains Engineer specific combat routines

-- load routine only if player is a Engineer
if ( 3 ~= Player.profession ) then
	return
end
-- The following values have to get set ALWAYS for ALL professions!!
wt_profession_engineer  =  inheritsFrom( nil )
wt_profession_engineer.professionID = 3 -- needs to be set
wt_profession_engineer.professionRoutineName = "Engineer"
wt_profession_engineer.professionRoutineVersion = "1.0"
wt_profession_engineer.RestHealthLimit = 70
wt_profession_engineer.MHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
wt_profession_engineer.OHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- NeedHeal Check
wt_profession_engineer.c_heal_action = inheritsFrom(wt_cause)
wt_profession_engineer.e_heal_action = inheritsFrom(wt_effect)

function wt_profession_engineer.c_heal_action:evaluate()
	return (Player.health.percent < 50 and not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_6))
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
	if ( wt_core_state_combat.CurrentTarget ~= 0 ) then
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		local Distance = T ~= nil and T.distance or 0
		local LOS = T~=nil and T.los or false
		if (Distance >= wt_global_information.AttackRange  or LOS~=true) then
			return true
		else
			if( Player:GetTarget() ~= wt_core_state_combat.CurrentTarget) then
				Player:SetTarget(wt_core_state_combat.CurrentTarget)
			end
		end
	end
	return false;
end

function wt_profession_engineer.e_MoveCloser:execute()
	wt_debug("e_MoveCloser ")
	local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
	if ( T ~= nil ) then
		Player:MoveTo(T.pos.x,T.pos.y,T.pos.z,120) -- the last number is the distance to the target where to stop
	end
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Update Weapon Data 
wt_profession_engineer.c_update_weapons = inheritsFrom(wt_cause)
wt_profession_engineer.e_update_weapons = inheritsFrom(wt_effect)

function wt_profession_engineer.c_update_weapons:evaluate()
	wt_profession_engineer.MHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon)
	wt_profession_engineer.OHweapon = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon)
	return false
end

function wt_profession_engineer.e_update_weapons:execute()	
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Attack rifle
wt_profession_engineer.c_attack_rifle = inheritsFrom(wt_cause)
wt_profession_engineer.e_attack_rifle = inheritsFrom(wt_effect)

function wt_profession_engineer.c_attack_rifle:evaluate()
	if (MHweapon ~= nil and OHweapon == nil and MHweapon.weapontype == GW2.WEAPONTYPE.Rifle ) then 
	  return wt_core_state_combat.CurrentTarget ~= 0
	end
	return false
end

wt_profession_engineer.e_attack_rifle.usesAbility = true
function wt_profession_engineer.e_attack_rifle:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then
			wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange and T.distance > 160) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
				end
			end
		end
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Pistol
wt_profession_engineer.c_attack_pistol = inheritsFrom(wt_cause)
wt_profession_engineer.e_attack_pistol = inheritsFrom(wt_effect)

function wt_profession_engineer.c_attack_pistol:evaluate()
	if (MHweapon ~= nil and OHweapon == nil and MHweapon.weapontype == GW2.WEAPONTYPE.Pistol ) then 
	  return wt_core_state_combat.CurrentTarget ~= 0
	end
	return false
end

wt_profession_engineer.e_attack_pistol.usesAbility = true
function wt_profession_engineer.e_attack_pistol:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then
			wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange and T.distance > 160) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
				end
			end
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Attack Pistol Pistol
wt_profession_engineer.c_attack_pistolpistol = inheritsFrom(wt_cause)
wt_profession_engineer.e_attack_pistolpistol = inheritsFrom(wt_effect)

function wt_profession_engineer.c_attack_pistolpistol:evaluate()
	if (MHweapon ~= nil and OHweapon ~= nil and MHweapon.weapontype == GW2.WEAPONTYPE.Pistol and OHweapon.weapontype == GW2.WEAPONTYPE.Pistol ) then 
	  return wt_core_state_combat.CurrentTarget ~= 0
	end
	return false
end

wt_profession_engineer.e_attack_pistolpistol.usesAbility = true
function wt_profession_engineer.e_attack_pistolpistol:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then
			wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < s5.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and T.distance < s4.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange and T.distance > 160) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
				end
			end
		end
	end
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Combat Pistol Shield
wt_profession_engineer.c_attack_pistolshield = inheritsFrom(wt_cause)
wt_profession_engineer.e_attack_pistolshield = inheritsFrom(wt_effect)

function wt_profession_engineer.c_attack_pistolshield:evaluate()
	if (MHweapon ~= nil and OHweapon ~= nil and MHweapon.weapontype == GW2.WEAPONTYPE.Pistol and OHweapon.weapontype == GW2.WEAPONTYPE.Shield ) then 
	  return wt_core_state_combat.CurrentTarget ~= 0
	end
	return false
end

wt_profession_engineer.e_attack_pistolshield.usesAbility = true
function wt_profession_engineer.e_attack_pistolshield:execute()
	Player:StopMoving()
	TID = wt_core_state_combat.CurrentTarget
	if ( TID ~= 0 ) then
		local T = CharacterList:Get(TID)
		if ( T ~= nil ) then
			wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
			if (s1 ~= nil) then
				wt_global_information.AttackRange = s1.maxRange
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and T.distance < s3.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and T.distance < s2.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and T.distance < 160) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s2~=nil and T.distance < s4.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,TID)
				elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and T.distance < s1.maxRange) then
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,TID)
				end
			end
		end
	end
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
			wt_debug("attacking " .. TID .. " Distance " .. T.distance)
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
			local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
			local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
			local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
			local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
			local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
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
-----------------------------------------------------------------------------------
-- Registration and setup of causes and effects to the different states
-----------------------------------------------------------------------------------

-- We need to check if the players current profession is ours to only add our profession specific routines
if ( wt_profession_engineer.professionID > -1 and wt_profession_engineer.professionID == Player.profession) then

	wt_debug("Initalizing profession routine for Engineer")
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua
	
	
	-- Our C & E´s for Engineer combat:
	local ke_heal_action = wt_kelement:create("heal_action",wt_profession_engineer.c_heal_action,wt_profession_engineer.e_heal_action, 100 )
		wt_core_state_combat:add(ke_heal_action)
		
	local ke_MoveClose_action = wt_kelement:create("Move closer",wt_profession_engineer.c_MoveCloser,wt_profession_engineer.e_MoveCloser, 75 )
		wt_core_state_combat:add(ke_MoveClose_action)
	
	local ke_Update_weapons = wt_kelement:create("UpdateWeaponData",wt_profession_engineer.c_update_weapons,wt_profession_engineer.e_update_weapons, 55 )
		wt_core_state_combat:add(ke_Update_weapons)
		
	local ke_Attack_rifle = wt_kelement:create("AttackRifle",wt_profession_engineer.c_attack_rifle,wt_profession_engineer.e_attack_rifle, 50 )
		wt_core_state_combat:add(ke_Attack_rifle)
		
	local ke_Attack_pistol = wt_kelement:create("AttackPistol",wt_profession_engineer.c_attack_pistol,wt_profession_engineer.e_attack_pistol, 50 )
		wt_core_state_combat:add(ke_Attack_pistol)	

	local ke_Attack_pistolpistol = wt_kelement:create("AttackPistolPistol",wt_profession_engineer.c_attack_pistolpistol,wt_profession_engineer.e_attack_pistolpistol, 50 )
		wt_core_state_combat:add(ke_Attack_pistolpistol)	
	
	local ke_Attack_pistolshield = wt_kelement:create("AttackPistolShield",wt_profession_engineer.c_attack_pistolshield,wt_profession_engineer.e_attack_pistolshield, 50 )
		wt_core_state_combat:add(ke_Attack_pistolshield)
		
	local ke_Attack_default = wt_kelement:create("Attackdefault",wt_profession_engineer.c_attack_default,wt_profession_engineer.e_attack_default, 45 )
		wt_core_state_combat:add(ke_Attack_default)
		
	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_engineer
	wt_global_information.AttackRange = 900
end
-----------------------------------------------------------------------------------














