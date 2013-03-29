--/////////////////////////////////////////////////////////////////////////////////
-- This file contains ranger specific combat routines modified by Zilvermoon
--/////////////////////////////////////////////////////////////////////////////////

--/////////////////////////////////////////////////////////////////////////////////
-- load routine only if player is a ranger
--/////////////////////////////////////////////////////////////////////////////////
if ( 4 ~= Player.profession ) then
	return
end

--/////////////////////////////////////////////////////////////////////////////////
-- The following values have to get set ALWAYS for ALL professions!!
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger = inheritsFrom( nil )
wt_profession_ranger.professionID = 4 -- needs to be set
wt_profession_ranger.professionRoutineName = "Ranger"
wt_profession_ranger.professionRoutineVersion = "1.0"
wt_profession_ranger.RestHealthLimit = 70

--/////////////////////////////////////////////////////////////////////////////////
--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.PetLowHPSwitch = 25  -- At what percent to switch pet if possible
wt_profession_ranger.PetHeal = 65 -- At what percent to use heal to aid pet
wt_profession_ranger.Heal = 60 -- At what percent to use heal to aid ranger
wt_profession_ranger.Move = { TID = 0, Dist = 0 } -- Used in Move Closer to control debug message flooding
wt_profession_ranger.Queue = { slot = 0, CIP = false}
wt_profession_ranger.Casting = { tick = 0, Changed = false, TID = 0 }
wt_profession_ranger.Ranger = { }
wt_profession_ranger.AttackRange = wt_global_information.AttackRange
wt_profession_ranger.MHweapon = { weapontype = nil }
wt_profession_ranger.OHweapon = { weapontype = nil }
wt_profession_ranger.DebugModes = { SwitchDead = true, SwitchHP = true, HealPet = true, HealRanger = true, Move = false, Attack = true, Critter = true, AttackRange = true, CIP = false }

--/////////////////////////////////////////////////////////////////////////////////
-- GetRangerVer() -- Print default Ranger Module version to console
--/////////////////////////////////////////////////////////////////////////////////
Rangerver = "1.05"
function GetRangerVer()
	d( "default Ranger Module, Ver: " .. Rangerver .. ". Modded by Zilvermoon" )
end

--/////////////////////////////////////////////////////////////////////////////////
-- Create Storage for Current Skill slot's, Names of skillID's and HM / OH weapon info
-- wt_global_information.Currentprofession.CC_C_Weapon()
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.CC_C_Weapon()
wt_profession_ranger.Ranger.skill = { }
wt_profession_ranger.Ranger.Weapon = { MH = nil, OH = nil }
	for i = 1, 10 do
		wt_profession_ranger.Ranger.Weapon[ i ] = { }
		wt_profession_ranger.Casting[ "s" .. i ] = false
	end
end
wt_profession_ranger.CC_C_Weapon()

--/////////////////////////////////////////////////////////////////////////////////
-- Return GW2.SKILLBARSLOT.Slot_( slot )
-- wt_global_information.Currentprofession.GetCastSlot( slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetCastSlot( slot )
	if ( ( type( slot ) == "number" ) and ( slot >= 1 ) and ( slot <= 10 ) ) then
		if ( slot == 1 ) then
			return GW2.SKILLBARSLOT.Slot_1
		elseif ( slot == 2 ) then
			return GW2.SKILLBARSLOT.Slot_2
		elseif ( slot == 3 ) then
			return GW2.SKILLBARSLOT.Slot_3
		elseif ( slot == 4 ) then
			return GW2.SKILLBARSLOT.Slot_4
		elseif ( slot == 5 ) then
			return GW2.SKILLBARSLOT.Slot_5
		elseif ( slot == 6 ) then
			return GW2.SKILLBARSLOT.Slot_6
		elseif ( slot == 7 ) then
			return GW2.SKILLBARSLOT.Slot_7
		elseif ( slot == 8 ) then
			return GW2.SKILLBARSLOT.Slot_8
		elseif ( slot == 9 ) then
			return GW2.SKILLBARSLOT.Slot_9
		elseif ( slot == 10 ) then
			return GW2.SKILLBARSLOT.Slot_10
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////////
-- Return Weapon Type ( wType ) as a string or "nil"
-- wt_global_information.Currentprofession.GetWeaponTypeToString( wType )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetWeaponTypeToString( wType )
	for k, v in pairs( GW2.WEAPONTYPE ) do
		if ( v == wType ) then
			return tostring( k )
		end
	end
	return tostring( nil )
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.GetSkill( slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetSkill( slot )
	local index = wt_global_information.Currentprofession.GetCastSlot( slot )
	local skill = Player:GetSpellInfo( index )
	return skill
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.GetSkillID( slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetSkillID( slot )
	local skill = wt_global_information.Currentprofession.GetSkill( slot )
	return skill.skillID
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.FixName( skill )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.FixName( skill )
	if ( type( skill == "table" ) ) then
		local sname, num = string.gsub( tostring( skill.name ), "\"", "" )
		if ( num ~= 0 ) then return tostring( sname ) else return tostring( skill.name ) end
	end
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.GetSkillName( slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetSkillName( slot )
	local name = ""
	local skill = wt_global_information.Currentprofession.GetSkill( slot )
	i = 1
	while ( i < 50000 ) do
		i = i + 1
	end
	skill = wt_global_information.Currentprofession.GetSkill( slot )
	name = tostring( skill.name )
	return tostring( name )
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.IsSlotUnlocked( slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.IsSlotUnlocked( slot )
	if ( Player:IsSpellUnlocked( wt_global_information.Currentprofession.GetCastSlot( slot ) ) ) then
		return true
	end
	return false
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.SlotInRange( slot, tbl, T )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.SlotInRange( slot, tbl, T )
	if ( 10 < slot or slot < 1 or tbl == nil or T == nil ) then
		return false
	end
	if ( tbl.name ~= nil ) then
		if ( tbl.maxRange ~= 0 and tbl.maxRange ~= nil ) then
			if ( wt_global_information.AttackRange <= tbl.maxRange and T.distance <= tbl.maxRange ) or
				( tbl.maxRange <= wt_global_information.AttackRange and T.distance <= tbl.maxRange ) then
				return true
			end
		else
			if ( T.distance < wt_global_information.AttackRange ) then
				return true
			end
		end
	end
	return false
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.GetWeaponRange( wType, slot, tbl )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetWeaponRange( wType, slot, tbl )
	if ( slot == 1 ) then
		if ( wType == GW2.WEAPONTYPE.Sword ) then
			return tbl.maxRange or 130
		end
		if ( wType == GW2.WEAPONTYPE.Longbow ) then
			return tbl.maxRange or 1200
		end
		if ( wType == GW2.WEAPONTYPE.Shortbow ) then
			return tbl.maxRange or 1200
		end
		if ( wType == GW2.WEAPONTYPE.Axe ) then
			return tbl.maxRange or 900
		end
		if ( wType == GW2.WEAPONTYPE.Greatsword ) then
			return tbl.maxRange or 150
		end
		if ( wType == GW2.WEAPONTYPE.Spear ) then
			return tbl.maxRange or 150
		end
		if ( wType == GW2.WEAPONTYPE.HarpoonGun ) then
			return tbl.maxRange or 1200
		end
	end
	if ( slot == 4 ) then
		if ( wType == GW2.WEAPONTYPE.Axe ) then
			return tbl.maxRange or 900
		end
		if ( wType == GW2.WEAPONTYPE.Dagger ) then
			return tbl.maxRange or 250
		end
		if ( wType == GW2.WEAPONTYPE.Torch ) then
			return tbl.maxRange or 900
		end
		if ( wType == GW2.WEAPONTYPE.Warhorn ) then
			return tbl.maxRange or 900
		end
	end
	return false
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.GetWeaponType( skillID, slot )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetWeaponType( skillID, slot )
	local sID = tonumber( skillID )
	if ( slot == 1 ) then
	--[[ MHweapon ]]--
		if ( ( sID == 12473 ) or ( sID == 12472 ) or ( sID == 12471 ) ) then
			return GW2.WEAPONTYPE.Sword
		end
		if ( sID == 12607 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( sID == 12470 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( sID == 12466 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( ( sID == 12474 ) or ( sID == 12487 ) or ( sID == 12488 ) ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( sID == 12553 ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( sID == 12642 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
	end
	if ( slot == 4 ) then
	--[[ OHweapon ]]--
		if ( sID == 12479 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( sID == 12478 ) then
			return GW2.WEAPONTYPE.Dagger
		end
		if ( sID == 12503 ) then
			return GW2.WEAPONTYPE.Torch
		end
		if ( sID == 12506 ) then
			return GW2.WEAPONTYPE.Warhorn
		end
	end
	--[[ no weapon ]]--
	return nil
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ IsCasting ]]--
-- wt_global_information.Currentprofession.IsCastingSingle( slot, special )
-- wt_global_information.Currentprofession.IsCastingMulti( special )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.IsCastingSingle( slot, special )
	if ( ( type( slot ) == "number" ) and ( slot >= 1 ) and ( slot <= 10 ) ) then
		if ( Player:GetCurrentlyCastedSpell() == wt_global_information.Currentprofession.GetCastSlot( slot ) ) then
			if ( special ) then
				if ( wt_global_information.Currentprofession.GetCastSlot( slot ) ~= wt_global_information.Currentprofession.GetCastSlot( 1 ) ) then
					return true
				end
			else return true end
		end
	end
	return false
end

function wt_profession_ranger.IsCastingMulti( special )
	if ( type( special ) ~= "boolean" ) then special = false end
	for i = 1, 10 do
		if ( wt_global_information.Currentprofession.IsCastingSingle( i, special ) ) then
			return true
		end
	end
	return false
end

--/////////////////////////////////////////////////////////////////////////////////
-- Get Weapon From Inventory Slot
-- wt_global_information.Currentprofession..GetWeaponInvetorySlot( slot, wType )
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.GetWeaponInvetorySlot( slot, wType )
	local main = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.MainHandWeapon )
	local altmain = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateMainHandWeapon )
	local aqua = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AquaticWeapon )
	local altaqua = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateAquaticWeapon )
	local off = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.OffHandWeapon )
	local altoff = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateOffHandWeapon )
	if ( slot == 1 ) then
		if ( main ~= nil and main.weapontype == wType ) then
			return main
		elseif ( altmain ~= nil and altmain.weapontype == wType ) then
			return altmain
		elseif ( aqua ~= nil and aqua.weapontype == wType ) then
			return aqua
		elseif ( altaqua ~= nil and altaqua.weapontype == wType ) then
			return altaqua
		end
	elseif ( slot == 4 ) then
		if ( off ~= nil and off.weapontype == wType ) then
			return off
		elseif ( altoff ~= nil and altoff.weapontype == wType ) then
			return altoff
		end
	end
	return { weapontype = wType }
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.CanPetUseHeal()
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.CanPetUseHeal()
	local i = 6
	local nID = 12360
	if ( wt_global_information.Currentprofession.IsSlotUnlocked( i ) ) then
		if ( wt_global_information.Currentprofession.Ranger.Weapon[ i ] ) then
			nID = tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID )
		else
			nID = tonumber( Player:GetSpellInfo( wt_global_information.Currentprofession.GetCastSlot( i ) ).skillID )
		end
		if ( nID == 12360 ) then
			return false
		end
		if ( not Player:IsSpellOnCooldown( wt_global_information.Currentprofession.GetCastSlot( i ) ) ) then
			return true
		end
		return ( not Player:IsSpellOnCooldown( wt_global_information.Currentprofession.GetCastSlot( i ) ) )
	end
	return wt_global_information.Currentprofession.IsSlotUnlocked( i )
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Pet Need Switch Check ]]--
-- wt_global_information.Currentprofession.c_switch_pet_action:evaluate()
-- wt_global_information.Currentprofession.e_switch_pet_action:execute()
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_switch_pet_action = inheritsFrom( wt_cause )
wt_profession_ranger.e_switch_pet_action = inheritsFrom( wt_effect )

function wt_profession_ranger.c_switch_pet_action:evaluate()
	local pet = Player:GetPet()
	if ( Player:CanSwitchPet() ) then
		if ( pet ~= nil ) then
			local PetLowHPSwitch = wt_global_information.Currentprofession.PetLowHPSwitch
			local pet_hp_percent = tonumber( pet.health.percent )
			if ( pet.alive == 0 ) then
				return true
			elseif ( pet_hp_percent < PetLowHPSwitch ) then
				return true
			end
			return false
		end
		return true
	end
	return false
end

wt_profession_ranger.e_switch_pet_action.usesAbility = false

function wt_profession_ranger.e_switch_pet_action:execute()
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		if ( not Player:GetPet().alive ) then
			if ( wt_global_information.Currentprofession.DebugModes.SwitchDead ) then
				wt_debug( "Ranger: Switching Pet - It Died!" )
			end
		elseif ( tonumber( pet.health.percent ) < wt_global_information.Currentprofession.PetLowHPSwitch  ) then
			local Procent = "%"
			if ( wt_global_information.Currentprofession.DebugModes.SwitchHP ) then
				wt_debug( string.format( "Ranger: Switching Pet - Pet HP: %u%s < %u%s", tonumber( pet.health.percent ), Procent, wt_global_information.Currentprofession.PetLowHPSwitch, Procent ) )
			end
		end
	end
	Player:SwitchPet()
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Pet Need Heal Check ]]--
-- wt_global_information.Currentprofession.c_heal_pet_action:evaluate()
-- wt_global_information.Currentprofession.e_heal_pet_action:execute()
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_heal_pet_action = inheritsFrom( wt_cause )
wt_profession_ranger.e_heal_pet_action = inheritsFrom( wt_effect )

function wt_profession_ranger.c_heal_pet_action:evaluate()
	local i = 6
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		if ( wt_global_information.Currentprofession.CanPetUseHeal() ) then
			if ( tonumber( pet.health.percent ) < wt_global_information.Currentprofession.PetHeal ) then
				if ( Player:GetCurrentlyCastedSpell() ~= wt_global_information.Currentprofession.GetCastSlot( i ) ) then
					return true
				end
				return false
			end
			return false
		end
		return false
	end
	return false
end

wt_profession_ranger.e_heal_pet_action.usesAbility = true

function wt_profession_ranger.e_heal_pet_action:execute()
	local i = 6
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		local Procent = "%"
		if ( wt_global_information.Currentprofession.DebugModes.HealPet ) then
			if ( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) then
				wt_debug( string.format( "Ranger: Use %s(%u) slot %u - Pet HP %u%s", wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ].name, wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i, tonumber( pet.health.percent ), Procent ) )
			else
				wt_debug( string.format( "Ranger: Use %s(%u) slot %u - Pet HP %u%s", "Healing", 0, i, tonumber( pet.health.percent ), Procent ) )
			end
		end
		Player:CastSpell( wt_global_information.Currentprofession.GetCastSlot( i ) )
	end
end


--/////////////////////////////////////////////////////////////////////////////////
-- Update Weapon Data
-- wt_global_information.Currentprofession.c_update_weapons:evaluate()
-- wt_global_information.Currentprofession.e_update_weapons:execute()
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_update_weapons = inheritsFrom( wt_cause )
wt_profession_ranger.e_update_weapons = inheritsFrom( wt_effect )

function wt_profession_ranger.c_update_weapons:evaluate()
	for i = 10, 1, -1 do
		if ( wt_global_information.Currentprofession.IsSlotUnlocked( i ) ) then
			if ( wt_global_information.Currentprofession.GetSkillID( i ) ~= wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) then
				return true
			end
		end
	end
	return false
end

function wt_profession_ranger.e_update_weapons:execute()
	wt_global_information.Currentprofession.UpdateWeapon()
end

--/////////////////////////////////////////////////////////////////////////////////
-- wt_global_information.Currentprofession.UpdateWeapon()
--/////////////////////////////////////////////////////////////////////////////////
function wt_profession_ranger.UpdateWeapon()
	for i = 10, 1, -1 do
		if ( wt_global_information.Currentprofession.IsSlotUnlocked( i ) ) then
			if ( wt_global_information.Currentprofession.GetSkillID( i ) ~= wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) then
				wt_global_information.Currentprofession.Ranger.Weapon[ i ] = wt_global_information.Currentprofession.GetSkill( i )
				if ( i == 1 or i == 4) then
					if ( i == 1 ) then
						if ( wt_global_information.Currentprofession.Ranger.Weapon.MH ~= wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ) ) then
							wt_global_information.Currentprofession.Ranger.Weapon.MH = wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i )
						end
						if ( wt_global_information.Currentprofession.MHweapon.weapontype ~= wt_global_information.Currentprofession.Ranger.Weapon.MH ) then
							-- wt_global_information.Currentprofession.MHweapon = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.MainHandWeapon )
							wt_global_information.Currentprofession.MHweapon = wt_global_information.Currentprofession.GetWeaponInvetorySlot( i, wt_global_information.Currentprofession.Ranger.Weapon.MH )
							wt_global_information.Currentprofession.MHweapon.weapontype = wt_global_information.Currentprofession.Ranger.Weapon.MH
							wt_debug( "Ranger: Changed Mainhand weapon: " .. wt_global_information.Currentprofession.GetWeaponTypeToString( wt_global_information.Currentprofession.Ranger.Weapon.MH ) )
						end
						if ( wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] ) ) then
							if ( wt_global_information.AttackRange ~= wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] ) ) then
								wt_global_information.AttackRange = wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] )
								wt_global_information.Currentprofession.AttackRange = wt_global_information.AttackRange
								if ( wt_global_information.Currentprofession.DebugModes.AttackRange ) then
									wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
								end
							end
						end
					else
						if ( wt_global_information.Currentprofession.Ranger.Weapon.OH ~= wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ) ) then
							wt_global_information.Currentprofession.Ranger.Weapon.OH = wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i )
						end
						if ( wt_global_information.Currentprofession.OHweapon.weapontype ~= wt_global_information.Currentprofession.Ranger.Weapon.OH ) then
							-- wt_global_information.Currentprofession.OHweapon = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.OffHandWeapon )
							wt_global_information.Currentprofession.OHweapon = wt_global_information.Currentprofession.GetWeaponInvetorySlot( i, wt_global_information.Currentprofession.Ranger.Weapon.OH )
							wt_global_information.Currentprofession.OHweapon.weapontype = wt_global_information.Currentprofession.Ranger.Weapon.OH
							wt_debug( "Ranger: Changed Offhand weapon: " .. wt_global_information.Currentprofession.GetWeaponTypeToString( wt_global_information.Currentprofession.Ranger.Weapon.OH ) )
						end
						if ( wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] ) and wt_global_information.Currentprofession.Ranger.Weapon.MH == nil ) then
							if ( wt_global_information.AttackRange ~= wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] ) ) then
								wt_global_information.AttackRange = wt_global_information.Currentprofession.GetWeaponRange( wt_global_information.Currentprofession.GetWeaponType( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID, i ), i, wt_global_information.Currentprofession.Ranger.Weapon[ i ] )
								wt_global_information.Currentprofession.AttackRange = wt_global_information.AttackRange
								if ( wt_global_information.Currentprofession.DebugModes.AttackRange ) then
									wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
								end
							end
						end
					end
				end
				if ( type( wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ] ) ~= "table" ) then
					wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ] = wt_global_information.Currentprofession.GetSkill( i )
					wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ].name = wt_global_information.Currentprofession.GetSkillName( i )
					wt_debug( "Ranger: Skill: " .. wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ].name .. " Slot: " .. i .. " Stored" )
				end
			end
			if ( wt_global_information.Currentprofession.Ranger.Weapon.MH == GW2.WEAPONTYPE.Sword and wt_global_information.Currentprofession.Ranger.Weapon[ 2 ].skillID == 12622 ) then
				--[[ Monarch's Leap ]]--
				if ( wt_global_information.AttackRange ~= wt_global_information.Currentprofession.Ranger.Weapon[ 2 ].maxRange ) then
					wt_global_information.Currentprofession.AttackRange = wt_global_information.AttackRange
					wt_global_information.AttackRange = wt_global_information.Currentprofession.Ranger.Weapon[ 2 ].maxRange
					wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
				end
				if ( wt_global_information.Currentprofession.Queue.slot ~= 2 ) then
					wt_global_information.Currentprofession.Queue.slot = 2
				end
			elseif ( wt_global_information.Currentprofession.Ranger.Weapon.MH == GW2.WEAPONTYPE.Sword and wt_global_information.Currentprofession.Ranger.Weapon[ 2 ].skillID == 12482 ) then
				--[[ Hornet Sting ]]--
				if ( wt_global_information.Currentprofession.Queue.slot == 2 ) then
					wt_global_information.Currentprofession.Queue.slot = 0
				end
				if ( wt_global_information.AttackRange ~= wt_global_information.Currentprofession.AttackRange ) then
					wt_global_information.AttackRange = wt_global_information.Currentprofession.AttackRange
					wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
				end
			elseif ( wt_global_information.Currentprofession.Ranger.Weapon.MH == GW2.WEAPONTYPE.Shortbow and wt_global_information.Currentprofession.Ranger.Weapon[ 3 ].skillID == 12517 ) then
				--[[ Quick Shot ]]--
				if ( wt_global_information.Currentprofession.Ranger.Weapon[ 3 ].maxRange ~= 900 ) then
					wt_global_information.Currentprofession.Ranger.Weapon[ 3 ].maxRange = 900
				end
			elseif ( wt_global_information.Currentprofession.Ranger.Weapon.OH == GW2.WEAPONTYPE.Torch and wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].skillID == 12504 ) then
				--[[ Bonfire ]]--
				if ( wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].maxRange ~= 120 ) then
					wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].maxRange = 120
				end
			elseif ( wt_global_information.Currentprofession.Ranger.Weapon.OH == GW2.WEAPONTYPE.Axe and wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].skillID == 12467 ) then
				--[[ Whirling Defense ]]--
				if ( wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].maxRange ~= 150 ) then
					wt_global_information.Currentprofession.Ranger.Weapon[ 5 ].maxRange = 150
				end
			end
		end
		if ( Player:GetCurrentlyCastedSpell() ~= wt_global_information.Currentprofession.GetCastSlot( i ) ) then
			if ( wt_global_information.Currentprofession.Casting[ "s" .. tostring( i ) ] ~= false ) then
				wt_global_information.Currentprofession.Casting[ "s" .. tostring( i ) ] = false
			end
		end
	end
	if ( wt_global_information.Currentprofession.Ranger.Weapon.MH == nil and wt_global_information.Currentprofession.Ranger.Weapon.OH == nil ) then
		if ( wt_global_information.AttackRange ~= 0 ) then
			wt_global_information.AttackRange = 0
			wt_global_information.Currentprofession.AttackRange = 0
			wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
		end
	end
	local L2AR = ( wt_global_information.AttackRange > 1200 )
	if ( ( L2AR and wt_global_information.MaxLootDistance ~= wt_global_information.AttackRange ) or
		(not L2AR and wt_global_information.MaxLootDistance ~= 1200 ) ) then
		if ( L2AR ) then
			wt_global_information.MaxLootDistance = wt_global_information.AttackRange
			wt_debug( "Ranger: New MaxLootDistance: " .. wt_global_information.MaxLootDistance )
		else
			wt_global_information.MaxLootDistance = 1200
			wt_debug( "Ranger: New MaxLootDistance: " .. wt_global_information.MaxLootDistance )
		end
	end
	if ( wt_global_information.MaxReviveDistance ) then
		local R2AR = ( wt_global_information.AttackRange > 800 )
		if ( ( R2AR and wt_global_information.MaxReviveDistance ~= wt_global_information.AttackRange ) or
			( not R2AR and wt_global_information.MaxReviveDistance ~= 800 ) ) then
			if ( R2AR ) then
				wt_global_information.MaxReviveDistance = wt_global_information.AttackRange
			wt_debug( "Ranger: New MaxReviveDistance: " .. wt_global_information.MaxReviveDistance )
			else
				wt_global_information.MaxReviveDistance = 800
			wt_debug( "Ranger: New MaxReviveDistance: " .. wt_global_information.MaxReviveDistance )
			end
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Combat Default Attack ]]--
-- wt_global_information.Currentprofession.c_attack_default:evaluate()
-- wt_global_information.Currentprofession.e_attack_default:execute()
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_attack_default = inheritsFrom( wt_cause )
wt_profession_ranger.e_attack_default = inheritsFrom( wt_effect )

function wt_profession_ranger.c_attack_default:evaluate()
--	if ( wt_core_state_combat.CurrentTarget ~= 0 ) then
--		local T = CharacterList:Get( wt_core_state_combat.CurrentTarget )
--		if ( T ~= nil and not T.los ) then return T.los end
--	end
	return wt_core_state_combat.CurrentTarget ~= 0
end

wt_profession_ranger.e_attack_default.usesAbility = true

function wt_profession_ranger.e_attack_default:execute()
	local TID, T = nil, nil
	for i = 10, 1, -1 do
		if ( TID ~= wt_core_state_combat.CurrentTarget ) then
			TID = wt_core_state_combat.CurrentTarget
		end
		if ( TID ~= 0 ) then
			if ( TID ~= wt_global_information.Currentprofession.Casting.TID ) then
				wt_global_information.Currentprofession.Casting.TID = TID
				wt_global_information.Currentprofession.Casting.tick = 0
				wt_global_information.Currentprofession.Queue.slot = 1
			end
			if ( T ~= CharacterList:Get( TID ) ) then
				T = CharacterList:Get( TID )
			end
			if ( T ~= nil) then
				Player:StopMoving()
				wt_global_information.Currentprofession.UpdateWeapon()
				Player:SetFacing( T.pos.x, T.pos.y, T.pos.z )
				if ( T.name ~= tostring ( T.name ) ) then
					T.name = tostring( T.name )
				end
				if ( i == 6 ) then i = i - 1 end -- Dont cast Heal
				if ( ( T.health.max / T.level ) <= 2 ) then
					if ( i ~= 1 ) then
						i = 1
					end
				end -- Target is a Critter
				if ( Player:IsSpellUnlocked( wt_global_information.Currentprofession.GetCastSlot( i ) ) ) then
					if ( not Player:IsSpellOnCooldown( wt_global_information.Currentprofession.GetCastSlot( i ) ) ) then
						local Casting = false
						for x = 10, 1, -1 do
							if ( Player:GetCurrentlyCastedSpell() == wt_global_information.Currentprofession.GetCastSlot( x ) ) then
								if ( x ~= 1 ) then Casting = x end
								if ( wt_global_information.Currentprofession.Casting[ "s" .. tostring( x ) ] == false ) then
									wt_global_information.Currentprofession.Casting.Changed = true
									wt_global_information.Currentprofession.Casting[ "s" .. tostring( x ) ] = true
								end
							end
						end
						if ( wt_global_information.Currentprofession.DebugModes.CIP ) then
							d( wt_global_information.Currentprofession.Casting.tick )
						end
						if ( wt_global_information.Currentprofession.Casting.tick >= 70 ) then
							if ( wt_global_information.Currentprofession.Casting.Changed == false and Casting ) then
								wt_global_information.Currentprofession.Queue.slot = 1 wt_global_information.Currentprofession.Queue.CIP = true
							end
							wt_global_information.Currentprofession.Casting.Changed = false
							wt_global_information.Currentprofession.Casting.tick = 0
						end
						if ( wt_global_information.Currentprofession.Queue.slot ~= 0 ) then
							i = tonumber( wt_global_information.Currentprofession.Queue.slot )
						end
						if ( i == 1 and wt_global_information.Currentprofession.Queue.slot == 1 and wt_global_information.Currentprofession.Queue.CIP ) then
							 wt_global_information.Currentprofession.Queue.CIP = not wt_global_information.Currentprofession.Queue.CIP
							wt_debug( "Casting Issue Prevention(" .. Casting .. "), Casting Slot 1" )
							if ( wt_global_information.Currentprofession.Queue.slot ~= 0 )then
								wt_global_information.Currentprofession.Queue.slot = 0
							end
							Player:CastSpell( wt_global_information.Currentprofession.GetCastSlot( i ), TID )
							wt_global_information.Currentprofession.UpdateWeapon()
							return
						end
						if ( Player:GetCurrentlyCastedSpell() ~= wt_global_information.Currentprofession.GetCastSlot( i ) ) then
							if ( wt_global_information.Currentprofession.Casting[ "s" .. tostring( i ) ] ~= false ) then
								wt_global_information.Currentprofession.Casting[ "s" .. tostring( i ) ] = false
							end
							wt_global_information.Currentprofession.Casting.tick = wt_global_information.Currentprofession.Casting.tick + 1
							if ( wt_global_information.Currentprofession.SlotInRange( i, wt_global_information.Currentprofession.Ranger.Weapon[ i ], T ) and not Casting ) then
								if ( ( T.health.max / T.level ) <= 2 ) then
									if ( wt_global_information.Currentprofession.DebugModes.Critter ) then
										wt_debug( "Critter Target" )
									end
								end -- Target is a Critter
								if ( wt_global_information.Currentprofession.DebugModes.Attack ) then
									wt_debug( string.format( "Ranger: Use %s (Slot %u) on %s (%u) - Dist %.f", wt_global_information.Currentprofession.Ranger.skill[ tonumber( wt_global_information.Currentprofession.Ranger.Weapon[ i ].skillID ) ].name, i, T.name, TID, T.distance ) )
								end
								Player:CastSpell( wt_global_information.Currentprofession.GetCastSlot( i ), TID )
								if ( wt_global_information.Currentprofession.Queue.slot ~= 0 ) then
									wt_global_information.Currentprofession.Queue.slot = 0
								end
								wt_global_information.Currentprofession.UpdateWeapon()
								return
							end
						end
					end
				end
			end
		end
	end
	return
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Registration and setup of causes and effects to the different states ]]--
--/////////////////////////////////////////////////////////////////////////////////

-- We need to check if the players Ranger profession is ours to only add our profession specific routines
if ( wt_profession_ranger.professionID > -1 and wt_profession_ranger.professionID == Player.profession ) then

	wt_debug( "Initalizing profession routine for Ranger" )
	-- Default Causes & Effects that are already in the wt_core_state_combat for all classes:
	-- Death Check 				- Priority 10000   --> Can change state to wt_core_state_dead.lua
	-- Combat Over Check 		- Priority 500      --> Can change state to wt_core_state_idle.lua

	--[[ Our C & E´s for Ranger combat: ]]--
		--[[ Switch Pet ]]--
	local ke_switch_pet_action = wt_kelement:create( "Switch Pet", wt_profession_ranger.c_switch_pet_action, wt_profession_ranger.e_switch_pet_action, 155 )
		wt_core_state_combat:add( ke_switch_pet_action )
		wt_core_state_dead:add( ke_switch_pet_action ) -- Adding this to Downed state

		--[[ Heal Pet ]]--
	local ke_heal_pet_action = wt_kelement:create( "Heal Pet", wt_profession_ranger.c_heal_pet_action, wt_profession_ranger.e_heal_pet_action, 100 )
		wt_core_state_combat:add( ke_heal_pet_action )

		--[[ Update Weapons ]]--
	local ke_Update_weapons = wt_kelement:create( "UpdateWeaponData", wt_profession_ranger.c_update_weapons, wt_profession_ranger.e_update_weapons, 80 )
		wt_core_state_combat:add( ke_Update_weapons )
		wt_core_state_idle:add( ke_Update_weapons ) -- Adding this to Idle state

		--[[ Attack ]]--
	local ke_Attack_default = wt_kelement:create( "Attackdefault", wt_profession_ranger.c_attack_default, wt_profession_ranger.e_attack_default, 45 )
		wt_core_state_combat:add( ke_Attack_default )

	-- We need to set the Currentprofession to our profession , so that other parts of the framework can use it.
	wt_global_information.Currentprofession = wt_profession_ranger

	wt_global_information.AttackRange = 900
end

--/////////////////////////////////////////////////////////////////////////////////

--[[
function Ranger.Init()
	TmpInit()
	GUI_NewField(wt_global_information.MainWindow.Name,"Module Version","gRangerVer","Ranger");
	GUI_NewField(wt_global_information.MainWindow.Name,"Switch Pet","gRangerSwitch","Ranger");
	GUI_NewField(wt_global_information.MainWindow.Name,"Heal Pet","gRangerHeal","Ranger");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Heal Slot 10", "gRangerHealSlot10","Ranger");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"Ranger");
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
	gRangerVer = Ranger.ModuleVersion
	gRangerSwitch = Ranger.Pet.HpSwitch
	gRangerHeal = Ranger.Pet.Heal
	gRangerHealSlot10 = false
end
]]--