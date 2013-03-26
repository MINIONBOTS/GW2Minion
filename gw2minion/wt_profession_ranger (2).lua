--/////////////////////////////////////////////////////////////////////////////////
--[[ This file contains ranger specific combat routines modified by Zilvermoon ]]--
--/////////////////////////////////////////////////////////////////////////////////

--[[ load routine only if player is a ranger ]]--
--/////////////////////////////////////////////////////////////////////////////////
if ( 4 ~= Player.profession ) then
	Ranger = nil
	return
end

--[[ The following values have to get set ALWAYS for ALL professions!! ]]--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger  =  inheritsFrom( nil )
wt_profession_ranger.professionID = 4 -- needs to be set
wt_profession_ranger.professionRoutineName = "Ranger"
wt_profession_ranger.professionRoutineVersion = "1.0"

--[[ The following values get set for the Ranger Module ]]--
--/////////////////////////////////////////////////////////////////////////////////
Ranger = { }
Ranger.ModuleVersion = "1.06"
wt_profession_ranger.professionRoutineVersion = Ranger.ModuleVersion

--[[ Ranger.Pet ]]--
Ranger.Pet = {
			HpSwitch = 25,
			Heal = 65
			}

--[[Ranger.Char ]]--
Ranger.Char = {
		Heal = 60,
		Move = {
			TID = 0,
			Dist = 0
		},
		Queue = {
			Slot = 0,
			AttackRange = 0,
			CIP = false
		},
		Cast = {
			tick = 0,
			changed = false,
			TID = 0
		},
		Sks = { },
		SkBar = { },
		Wpns = {
			MH = nil,
			altMH = nil,
			Aqua = nil,
			altAqua = nil,
			OH = nil,
			altOH = nil,
			EquipedMH = { weapontype = nil },
			EquipedOH = { weapontype = nil }
		}
	}

--[[ Ranger.ModuleDebug ]]--
Ranger.ModuleDebug = {
		Pet = {
			Dead = true,
			HP = true,
			Heal = true
		},
		Char = {
			Heal = true,
			Move = true,
			LOS = true,
			Attack = true,
			CIP = false
		},
		Wpn = {
			Range = true
		}
	}

--[[ Ranger.CreateSkillBar() ]]--
--[[ Create skillbar storage space ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.CreateSkillBar()
	for i = 1, 10 do
		if ( type( Ranger.Char.SkBar[ "s" .. i ] ) ~= "table" ) then
			Ranger.Char.SkBar[ "s" .. i ] = { }
			Ranger.Char.Cast[ "s" .. i ] = false
		end
	end
end

--[[ Ranger.ResetSkillBar() ]]--
--[[ Reset skillbar storage space ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.ResetSkillBar()
	Ranger.Char.SkBar = { }
end

--[[ Ranger.GetCastSlot( slot ) ]]--
--[[ Return GW2.SKILLBARSLOT.Slot_( slot ) ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetCastSlot( slot )
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

--[[ Ranger.GetWeaponTypeToString( wType ) ]]--
--[[ Return Weapon Type ( wType ) as a string or "nil" ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetWeaponTypeToString( wType )
	for k, v in pairs( GW2.WEAPONTYPE ) do
		if ( v == wType ) then
			return tostring( k )
		end
	end
	return tostring( nil )
end

--[[ Ranger.GetSkill( slot ) ]]--
--[[ Return Skill ( slot ) ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetSkill( slot )
	local index = Ranger.GetCastSlot( slot )
	local skill = Player:GetSpellInfo( index )
	return skill
end

--[[ Ranger.GetcontentID( slot ) ]]--
--[[ Return contentID of skill ( slot ) ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetcontentID( slot )
	local skill = Ranger.GetSkill( slot )
	return skill.contentID
end

--[[ Ranger.GetSkillName( slot ) ]]--
--[[ Return "fixed" name ( slot ) ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetSkillName( slot )
	local name = ""
	local skill = Ranger.GetSkill( slot )
	i = 1
	while ( i < 50000 ) do
		i = i + 1
	end
	skill = Ranger.GetSkill( slot )
	local sname, num = string.gsub( tostring( skill.name ), "\"", "" )
	if ( num ~= 0 ) then
		name = tostring( sname )
	else
		name = tostring( skill.name )
	end
	return tostring( name )
end

--[[ Ranger.IsSlotUnlocked( slot ) ]]--
--[[ Return true or false ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.IsSlotUnlocked( slot )
	local index = Ranger.GetCastSlot( slot )
	if ( Player:IsSpellUnlocked( index ) ) then
		return true
	end
	return false
end

--[[ Ranger.SlotInRange( slot, tbl, T ) ]]--
--[[ Return true or false ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.SlotInRange( slot, tbl, T )
	if ( 10 < slot or slot < 1 or tbl == nil or T == nil ) then return false end
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

--[[ Ranger.GetWeaponRange( wType, slot, tbl ) ]]--
--[[ Return max range or false ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetWeaponRange( wType, slot, tbl )
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
	if ( slot == 2 ) then
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
	if ( slot == 3 ) then
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
	if ( slot == 5 ) then
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

--[[ Ranger.GetWeaponType( skillID, slot ) ]]--
--[[ Return WEAPONTYPE or nil ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetWeaponType( contentID, slot )
	local cID = tonumber( contentID )
	if ( slot == 1 ) then
	--[[ MHweapon ]]--
		if ( ( cID == 232575 ) or ( cID == 35659 ) or ( cID == 41408 ) ) then
			return GW2.WEAPONTYPE.Sword
		end
		if ( cID == 37273 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( cID == 37799 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( cID == 37586 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( ( cID == 232575 ) or ( cID == 44852 ) or ( cID == 132269 ) ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( ( cID == 215175 ) or (cID == 341122 ) or ( cID == 181863 ) ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( cID == 232928 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
	end
	if ( slot == 2 ) then
		if ( ( cID == 224481 ) or ( cID == 146601 ) ) then
			return GW2.WEAPONTYPE.Sword
		end
		if ( cID == 35827 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( cID == 41399 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( cID == 144226 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( cID == 71678 ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( cID == 263756 ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( cID == 41517 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
	end
	if ( slot == 3 ) then
		if ( cID == 268340 ) then
			return GW2.WEAPONTYPE.Sword
		end
		if ( cID == 41584 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( cID == 41497 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( cID == 41438 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( cID == 232922 ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( cID == 36822 ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( cID == 130900 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
	end
	if ( slot == 4 ) then
	--[[ OHweapon ]]--
		if ( cID == 37134 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( cID == 36447 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( ( cID == 36492 ) or ( cID == 36933 ) ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( ( cID == 41567 ) or ( cID == 190425 ) ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( cID == 132196 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
		if ( cID == 263745 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( cID == 41416 ) then
			return GW2.WEAPONTYPE.Dagger
		end
		if ( cID == 17978 ) then
			return GW2.WEAPONTYPE.Torch
		end
		if ( cID == 44821 ) then
			return GW2.WEAPONTYPE.Warhorn
		end
	end
	if ( slot == 5 ) then
		if ( cID == 245509 ) then
			return GW2.WEAPONTYPE.Longbow
		end
		if ( cID == 37418 ) then
			return GW2.WEAPONTYPE.Shortbow
		end
		if ( cID == 36826 ) then
			return GW2.WEAPONTYPE.Axe
		end
		if ( cID == 190276 ) then
			return GW2.WEAPONTYPE.Greatsword
		end
		if ( cID == 41554 ) then
			return GW2.WEAPONTYPE.Spear
		end
		if ( cID == 41519 ) then
			return GW2.WEAPONTYPE.HarpoonGun
		end
		if ( cID == 34154 ) then
			return GW2.WEAPONTYPE.Dagger
		end
		if ( cID == 215182 ) then
			return GW2.WEAPONTYPE.Torch
		end
		if ( cID == 195333 ) then
			return GW2.WEAPONTYPE.Warhorn
		end
	end
	--[[ no weapon ]]--
	return nil
end

--[[ Ranger.IsCasting( slot ) ]]--
--[[ Return true or false ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.IsCasting( slot )
	if ( ( slot) and ( type( slot ) == "number") and ( 1 <= slot <= 10 ) ) then
		local index = Ranger.GetCastSlot( slot )
		if ( Player:GetCurrentlyCastedSpell() ~= 16 ) then
			--[[ Auto Cast slot 1 check ]]--
			if ( index == Ranger.GetCastSlot( 1 ) ) then
				if ( slot ~= 1 ) then
					return false
				else
					return true
				end
			else
				return true
			end
		else
			return false
		end
	end
end

--[[ Ranger.GetWeaponInvetorySlot( slot, wType ) ]]--
--[[ Return WeaponType from InventorySlot using ( slot and wType ) ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.GetWeaponInvetorySlot( slot, wType )
	Ranger.Char.Wpns.HM = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.MainHandWeapon )
	Ranger.Char.Wpns.altHM = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateMainHandWeapon )
	Ranger.Char.Wpns.Aqua = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AquaticWeapon )
	Ranger.Char.Wpns.altAqua = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateAquaticWeapon )
	Ranger.Char.Wpns.OH = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.OffHandWeapon )
	Ranger.Char.Wpns.altOH = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.AlternateOffHandWeapon )
	if ( slot == 1 ) then
		if ( Ranger.Char.Wpns.HM ~= nil and Ranger.Char.Wpns.HM.weapontype == wType ) then
			return Ranger.Char.Wpns.HM
		elseif ( Ranger.Char.Wpns.altHM ~= nil and Ranger.Char.Wpns.altHM.weapontype == wType ) then
			return Ranger.Char.Wpns.altHM
		elseif ( Ranger.Char.Wpns.Aqua ~= nil and Ranger.Char.Wpns.Aqua.weapontype == wType ) then
			return Ranger.Char.Wpns.Aqua
		elseif ( Ranger.Char.Wpns.altAqua ~= nil and Ranger.Char.Wpns.altAqua.weapontype == wType ) then
			return Ranger.Char.Wpns.altAqua
		end
	elseif ( slot == 4 ) then
		if ( Ranger.Char.Wpns.OH ~= nil and Ranger.Char.Wpns.OH.weapontype == wType ) then
			return Ranger.Char.Wpns.OH
		elseif ( Ranger.Char.Wpns.altOH ~= nil and Ranger.Char.Wpns.altOH.weapontype == wType ) then
			return Ranger.Char.Wpns.altOH
		end
	end
	return { weapontype = wType }
end

--[[ Ranger.CanPetUseHeal( slot ) ]]--
--[[ Return true or false ]]--
--/////////////////////////////////////////////////////////////////////////////////
function Ranger.CanPetUseHeal( slot )
	local cID = 12360 -- this contentID can't heal pet
	local CastSlot = Ranger.GetCastSlot( slot )
	if ( Ranger.IsSlotUnlocked( slot ) ) then
		if ( Ranger.Char.SkBar[ "s" .. slot ] ) then
			cID = tonumber( Ranger.Char.SkBar[ "s" .. slot ].contentID )
		else
			cID = tonumber( Player:GetSpellInfo( CastSlot ).contentID )
		end
		if ( cID == 12360 ) then
			return false -- current skill can't heal pet
		end
		if ( not Player:IsSpellOnCooldown( CastSlot ) ) then
			return true
		end
	end
	return false -- slot is locked
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Pet Need Switch Check ]]--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_switch_pet_action = inheritsFrom( wt_cause )
wt_profession_ranger.e_switch_pet_action = inheritsFrom( wt_effect )

function wt_profession_ranger.c_switch_pet_action:evaluate()
	local pet = Player:GetPet()
	if ( Player:CanSwitchPet() ) then
		if ( pet ~= nil ) then
			local PetLowHPSwitch = Ranger.Pet.HpSwitch
			local pet_hp_percent = tonumber( pet.health.percent )
			if ( pet.alive == 0 ) then
				return true -- pet is dead
			elseif ( pet_hp_percent < PetLowHPSwitch ) then
				return true -- hp below switch threshold
			end
			return false
		end
		return true -- pet == nil ?
	end
	return false -- can't switch
end

wt_profession_ranger.e_switch_pet_action.usesAbility = false

function wt_profession_ranger.e_switch_pet_action:execute()
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		if ( not Player:GetPet().alive ) then
			if ( Ranger.ModuleDebug.Pet.Dead ) then
				wt_debug( "Ranger: Switching Pet - It Died!" )
			end
		elseif ( tonumber( pet.health.percent ) < Ranger.Pet.HpSwitch  ) then
			local Procent = "%"
			if ( Ranger.ModuleDebug.Pet.HP ) then
				local Switch_Msg = "Ranger: Switching Pet - Pet HP: %u%s < %u%s"
				wt_debug( string.format( Switch_Msg, tonumber( pet.health.percent ), Procent, Ranger.Pet.HpSwitch, Procent ) )
			end
		end
	end
	Player:SwitchPet()
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Pet Need Heal Check ]]--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_heal_pet_action = inheritsFrom( wt_cause )
wt_profession_ranger.e_heal_pet_action = inheritsFrom( wt_effect )

function wt_profession_ranger.c_heal_pet_action:evaluate()
	local slot = 6
	local CastSlot = Ranger.GetCastSlot( slot )
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		if ( Ranger.CanPetUseHeal( slot ) ) then
			if ( tonumber( pet.health.percent ) < Ranger.Pet.Heal ) then
				if ( Player:GetCurrentlyCastedSpell() ~= CastSlot ) then
					return true
				end
				return false -- already casting
			end
			return false -- pet don't need heal
		end
		return false -- pet can't use heal or skill is on cooldown
	end
	return false -- pet == nil ?
end

wt_profession_ranger.e_heal_pet_action.usesAbility = true

function wt_profession_ranger.e_heal_pet_action:execute()
	local slot = 6
	local CastSlot = Ranger.GetCastSlot( slot )
	local pet = Player:GetPet()
	if ( pet ~= nil ) then
		local Procent = "%"
		if ( Ranger.ModuleDebug.Pet.Heal ) then
			local cID = tonumber( Ranger.Char.SkBar[ "s" .. slot ].contentID )
			local name = Ranger.Char.Sks[ cID ].name
			local Heal_Msg = "Ranger: Use %s(%u) slot %u - Pet HP %u%s"
			wt_debug( string.format( Heal_Msg, name, cID, slot, tonumber( pet.health.percent ), Procent ) )
		end
		Player:CastSpell( CastSlot )
	end
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Update Weapon Data ]]--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_update_weapons = inheritsFrom( wt_cause )
wt_profession_ranger.e_update_weapons = inheritsFrom( wt_effect )

function wt_profession_ranger.c_update_weapons:evaluate()
	-- Ranger.CreateSkillBar()
	Ranger.CreateSkillBar()
	for slot = 10, 1, -1 do
		if ( Ranger.IsSlotUnlocked( slot ) ) then
			local SkBarcID = tonumber( Ranger.Char.SkBar[ "s" .. slot ].contentID ) or 0
			local cID = Ranger.GetcontentID( slot )
			if ( cID ~= SkBarcID ) then
				return true
			end
		end
	end
	return false
end

function wt_profession_ranger.e_update_weapons:execute()
--[[ wt_global_information.Currentprofession.e_update_weapons:execute() ]]--
	for slot = 10, 1, -1 do
		if ( Ranger.IsSlotUnlocked( slot ) ) then
		--[[ SkillBarSlot Unlocked ]]--
			local SkBarcID = tonumber( Ranger.Char.SkBar[ "s" .. slot ].contentID )
			local Skill = Ranger.GetSkill( slot ) --[[ Table ]]--
			local cID = tonumber( Ranger.GetcontentID( slot ) )
			local SkscID = tonumber( Ranger.Char.Sks[ SkBarcID ] )
			local skname = tostring( Ranger.GetSkillName( slot ) )
			local wType = tonumber( Ranger.GetWeaponType( cID, slot ) )
			local InvWtype = Ranger.GetWeaponInvetorySlot( slot, wType ) --[[ Table ]]--
			local wType2String = tostring( Ranger.GetWeaponTypeToString( wType ) )
			local CastSlot = Ranger.GetCastSlot( slot )
			local Range = tonumber( Ranger.GetWeaponRange( wType, slot, Skill ) )
			local L2AR = ( wt_global_information.AttackRange > 1200 )
			local R2AR = ( wt_global_information.AttackRange > 800 )

			if ( SkBarcID ~= cID ) then
			--[[ cID have changed or is new ]]--

				if ( 1 <= slot and slot >= 5 ) then
				--[[ Update weapon data ]]--

					if ( slot == 1 or slot == 4 ) then
					--[[ Update Weapon type ]]--
						if ( wType ~= Ranger.Char.Wpns.EquipedOH.weapontype and slot == 4 ) or
							( wType ~= Ranger.Char.Wpns.EquipedMH.weapontype and slot == 1 ) then
							if ( slot == 4 ) then
								Ranger.Char.Wpns.EquipedOH = wInvWtype
								wt_debug( "Ranger: Changed Offhand weapon: " .. wType2String )
							elseif ( slot == 1 ) then
								Ranger.Char.Wpns.EquipedMH = InvWtype
								wt_debug( "Ranger: Changed Mainhand weapon: " .. wType2String )
							end
						end
					end

					if ( slot == 5 ) then
					--[[ Special case slot 5 --> Modification of skill data ]]--
						if ( wType == GW2.WEAPONTYPE.Torch and cID == 12504 ) then
							--[[ Bonfire ]]--
							if ( Ranger.Char.Sks[ cID ].maxRange ~= 120 ) then
								Ranger.Char.Sks[ cID ].maxRange = 120
							end
						elseif ( wType == GW2.WEAPONTYPE.Axe and cID == 12467 ) then
							--[[ Whirling Defense ]]--
							if ( Ranger.Char.Sks[ cID ].maxRange ~= 150 ) then
								Ranger.Char.Sks[ cID ].maxRange = 150
							end
						end
					elseif ( slot == 4 ) then
					--[[ Special case slot 4 --> Modification of skill data ]]--
					elseif ( slot == 3 ) then
					--[[ Special case slot 3 --> Modification of skill data ]]--
						if ( wType == GW2.WEAPONTYPE.Shortbow and cID == 12517 ) then
							--[[ Quick Shot ]]--
							if ( Ranger.Char.Sks[ cID ].maxRange ~= 900 ) then
								Ranger.Char.Sks[ cID ].maxRange = 900
							end
						end
					elseif ( slot == 2 ) then
					--[[ Special case slot 2 --> Modification of skill data ]]--
						if ( wType == GW2.WEAPONTYPE.Sword and cID == 12622 ) then
							--[[ Monarch's Leap ]]--
							if ( wt_global_information.AttackRange ~= Ranger.Char.Sks[ cID ].maxRange ) then
								Ranger.Char.Queue.AttackRange = wt_global_information.AttackRange
								wt_global_information.AttackRange = Ranger.Char.Sks[ cID ].maxRange
							end
							wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
							if ( Ranger.Char.Queue.Slot ~= 2 ) then
								Ranger.Char.Queue.Slot = 2
							end
						end
						if ( wType == GW2.WEAPONTYPE.Sword and cID == 12622 ) then
							--[[ Hornet Sting ]]--
							if ( wt_global_information.AttackRange ~= Ranger.Char.Queue.AttackRange ) then
								wt_global_information.AttackRange = Ranger.Char.Queue.AttackRange
							end
							if ( Ranger.Char.Queue.Slot == 2 ) then
								Ranger.Char.Queue.Slot = 0
							end
						end
					elseif ( slot == 1 ) then
					--[[ Special case slot 1 --> Modification of skill data ]]--
					end
				end

				if ( SkscID ~= cID ) then
				--[[ Store skill data in skill storage ]]--
					Ranger.Char.Sks[ cID ] = Skill
					--[[ Get name and fix it if needed ]]--
					Ranger.Char.Sks[ cID ].name = skname
					wt_debug( "Ranger: Skill: " .. skname .. " Slot: " .. slot .. " Stored" )
				-- else
				--[[ copy skill data from skill storage to skillbar storage ]]--
					Ranger.Char.SkBar[ "s" .. slot ] = Ranger.Char.Sks[ cID ]
				end

				if ( Range ) then
				--[[ Update Weapon Range ]]--
					local changed = false
					if ( Ranger.Char.Wpns.EquipedMH.weapontype ~= nil and slot == 1 ) or
						( Ranger.Char.Wpns.EquipedMH.weapontype == nil and slot == 4 ) then
						if ( wt_global_information.AttackRange ~= Range ) then
							wt_global_information.AttackRange = Range
							changed = true
						end
					end
					if ( changed ) then
						if ( Ranger.ModuleDebug.Wpn.Range ) then
							wt_debug( "Ranger: New Attack Range: " .. wt_global_information.AttackRange )
						end
					end
				end
			end

			if ( ( L2AR and wt_global_information.MaxLootDistance ~= wt_global_information.AttackRange ) or
				(not L2AR and wt_global_information.MaxLootDistance ~= 1200 ) ) then
			--[[ Loot Distance ]]--
				if ( L2AR ) then
					wt_global_information.MaxLootDistance = wt_global_information.AttackRange
					wt_debug( "Ranger: New MaxLootDistance: " .. wt_global_information.MaxLootDistance )
				else
					wt_global_information.MaxLootDistance = 1200
					wt_debug( "Ranger: New MaxLootDistance: " .. wt_global_information.MaxLootDistance )
				end
			end

			if ( ( R2AR and wt_global_information.MaxReviveDistance ~= wt_global_information.AttackRange ) or
				( not R2AR and wt_global_information.MaxReviveDistance ~= 800 ) ) then
			--[[ Revive Distance ]]--
				if ( R2AR ) then
					wt_global_information.MaxReviveDistance = wt_global_information.AttackRange
					wt_debug( "Ranger: New MaxReviveDistance: " .. wt_global_information.MaxReviveDistance )
				else
					wt_global_information.MaxReviveDistance = 800
					wt_debug( "Ranger: New MaxReviveDistance: " .. wt_global_information.MaxReviveDistance )
				end
			end

			if ( Player:GetCurrentlyCastedSpell() ~= CastSlot ) then
			--[[ Casting Issue Prevention ( CIP) ]]--
				if ( Ranger.Char.Cast[ "s" .. slot ] ~= false ) then
					Ranger.Char.Cast[ "s" .. slot ] = false
				end
			end
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////////
--[[ Combat Default Attack ]]--
--/////////////////////////////////////////////////////////////////////////////////
wt_profession_ranger.c_attack_default = inheritsFrom( wt_cause )
wt_profession_ranger.e_attack_default = inheritsFrom( wt_effect )

function wt_profession_ranger.c_attack_default:evaluate()
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
			if ( TID ~= Ranger.Char.Cast.TID ) then
				Ranger.Char.Cast.TID = TID
				Ranger.Char.Cast.tick = 0
				Ranger.Char.Queue.slot = 1
			end
			if ( T ~= CharacterList:Get( TID ) ) then
				T = CharacterList:Get( TID )
			end
			if ( T ~= nil) then
				Player:SetFacing( T.pos.x, T.pos.y, T.pos.z )
				if ( T.name ~= tostring ( T.name ) ) then
					T.name = tostring( T.name )
				end
				if ( i == 6 ) then
					i = i - 1
				end -- Dont cast Heal
				if ( Player:IsSpellUnlocked( Ranger.GetCastSlot( i ) ) ) then
					if ( not Player:IsSpellOnCooldown( Ranger.GetCastSlot( i ) ) ) then
						local Casting = false
						for x = 10, 1, -1 do
							if ( Player:GetCurrentlyCastedSpell() == Ranger.GetCastSlot( x ) ) then
								if ( x ~= 1 ) then
									Casting = x
								end
								if ( Ranger.Char.Cast[ "s" .. tostring( x ) ] == false ) then
									Ranger.Char.Cast.Changed = true
									Ranger.Char.Cast[ "s" .. tostring( x ) ] = true
								end
							end
						end
						if ( Ranger.ModuleDebug.Char.CIP ) then
							d( Ranger.Char.Cast.tick )
						end
						if ( Ranger.Char.Cast.tick >= 70 ) then
							if ( Ranger.Char.Cast.Changed == false and Casting ) then
								Ranger.Char.Queue.slot = 1 Ranger.Char.Queue.CIP = true
							end
							Ranger.Char.Cast.Changed = false
							Ranger.Char.Cast.tick = 0
						end
						if ( Ranger.Char.Queue.slot ~= 0 ) then
							i = tonumber( Ranger.Char.Queue.slot )
						end
						if ( i == 1 and Ranger.Char.Queue.slot == 1 and Ranger.Char.Queue.CIP ) then
							Ranger.Char.Queue.CIP = not Ranger.Char.Queue.CIP
							wt_debug( "Casting Issue Prevention(" .. Casting .. "), Casting Slot 1" )
							if ( Ranger.Char.Queue.slot ~= 0 )then Ranger.Char.Queue.slot = 0 end
							Player:CastSpell( Ranger.GetCastSlot( i ), TID )
							return
						end
						if ( Player:GetCurrentlyCastedSpell() ~= Ranger.GetCastSlot( i ) ) then
							if ( Ranger.Char.Cast[ "s" .. tostring( i ) ] ~= false ) then
								Ranger.Char.Cast[ "s" .. tostring( i ) ] = false
							end
							Ranger.Char.Cast.tick = Ranger.Char.Cast.tick + 1
							if ( Ranger.SlotInRange( i, Ranger.Char.SkBar[ "s" .. i ], T ) and not Casting ) then
								if ( Ranger.ModuleDebug.Char.Attack ) then
									local Attack_Msg = "Ranger: Use %s (Slot %u) on %s (%u) - Dist %.f"
									wt_debug( string.format( Ranger.Attack_Msg, Ranger.Char.SkBar[ "s" .. i ].name, i, T.name, TID, T.distance ) )
								end
								Player:CastSpell( Ranger.GetCastSlot( i ), TID )
								if ( Ranger.Char.Queue.slot ~= 0 ) then
									Ranger.Char.Queue.slot = 0
								end
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

-- We need to check if the players current profession is ours to only add our profession specific routines
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

		--[[ Heal Ranger ]]--
	local ke_heal_action = wt_kelement:create( "Heal Ranger", wt_profession_ranger.c_heal_action, wt_profession_ranger.e_heal_action, 100 )
		wt_core_state_combat:add( ke_heal_action )

		--[[ Move Closer ]]--
	local ke_MoveClose_action = wt_kelement:create( "Move closer", wt_profession_ranger.c_MoveCloser, wt_profession_ranger.e_MoveCloser, 75 )
		wt_core_state_combat:add( ke_MoveClose_action )

	local ke_Update_weapons = wt_kelement:create( "UpdateWeaponData", wt_profession_ranger.c_update_weapons, wt_profession_ranger.e_update_weapons, 55 )
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