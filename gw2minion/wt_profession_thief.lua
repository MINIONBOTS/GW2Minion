--[[
 ***********************************************************************************************************************
 
								21/11/2012  Custom Thief class courtesy of z0mg
 
 ***********************************************************************************************************************
--]]


--[[
********************************************************************************?***************************************
                                                    Loader
********************************************************************************?***************************************
--]]

if (5 ~= Player.profession) then
	return
end

--[[
********************************************************************************?***************************************
                                                    Bot Values
********************************************************************************?***************************************
--]]

DatAss = inheritsFrom(nil)
DatAss.professionID = 5
DatAss.professionRoutineName = "Thief"
DatAss.professionRoutineVersion = "0.1"
DatAss.RestHealthLimit = 65

--[[
********************************************************************************?***************************************
                                                    Local Values
********************************************************************************?***************************************
--]]

DatAss.lastAttacked = 0
DatAss.hasSteal = false
DatAss.attackRange = 128
DatAss.mainWeapon = {}
DatAss.secondaryWeapon = {}
if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon) ~= nil) then
	DatAss.mainWeapon.dataID = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).dataID
	DatAss.mainWeapon.weapontype= Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).weapontype
else 
	DatAss.mainWeapon = nil
end
if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon) ~= nil) then
	DatAss.secondaryWeapon.dataID = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).dataID
	DatAss.secondaryWeapon.weapontype = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).weapontype
else 
	DatAss.secondaryWeapon = nil
end

--[[
********************************************************************************?***************************************
                                                    Helper Functions
********************************************************************************?***************************************
--]]

function DatAss.Log(text)
    d("[DatAss] " .. text)
end

function DatAss.GetNearbyEnemyCount()
    local i = 0
    local t = (CharacterList("alive,attackable,maxdistance=240"))
    if (t ~= nil ) then
        id,v = next(t)
        while ( id ~= nil ) do
            i = i + 1
            id,v = next(t,id)
        end
    end
    return i
end

function DatAss.ShouldAOE()
    local i = 0
    local t = (CharacterList("alive,attackable,maxdistance=240"))
    if (t ~= nil ) then
        id,v = next(t)
        while ( id ~= nil ) do
            if (v.health.percent > 70) then
            	return true
    	    end
            id,v = next(t,id)
        end
    end
    return false
end

function DatAss.GetStringOfWeaponType(weapon)
	if (weapon ~= nil) then
		if (weapon.weapontype == 0) then
			weapon.typename = "Sword"
		elseif (weapon.weapontype == 1) then
			weapon.typename = "Hammer"
		elseif (weapon.weapontype == 2) then
			weapon.typename = "Longbow"
		elseif (weapon.weapontype == 3) then
			weapon.typename = "Shortbow"
		elseif (weapon.weapontype == 4) then
			weapon.typename = "Axe"
		elseif (weapon.weapontype == 5) then
			weapon.typename = "Dagger"
		elseif (weapon.weapontype == 6) then
			weapon.typename = "Greatsword"
		elseif (weapon.weapontype == 7) then
			weapon.typename = "Mace"
		elseif (weapon.weapontype == 8) then
			weapon.typename = "Pistol"
		elseif (weapon.weapontype == 9) then
			weapon.typename = "Rifle"
		elseif (weapon.weapontype == 10) then
			weapon.typename = "Scepter"
		elseif (weapon.weapontype == 11) then
			weapon.typename = "Staff"
		elseif (weapon.weapontype == 12) then
			weapon.typename = "Focus"
		elseif (weapon.weapontype == 13) then
			weapon.typename = "Torch"
		elseif (weapon.weapontype == 14) then
			weapon.typename = "Warhorn"
		elseif (weapon.weapontype == 15) then
			weapon.typename = "Shield"
		elseif (weapon.weapontype == 16) then
			weapon.typename = "Spear"
		elseif (weapon.weapontype == 17) then
			weapon.typename = "Harpoongun"
		elseif (weapon.weapontype == 18) then
			weapon.typename = "Trident"
		end
		return weapon.typename
	else
		return "Empty slot"
	end	
end

function UpdateWeaponInfo()
	if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon) ~= nil) then
		DatAss.mainWeapon = {}
		DatAss.mainWeapon.dataID = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).dataID
		DatAss.mainWeapon.name = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).name
		DatAss.mainWeapon.weapontype= Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).weapontype
	else
		DatAss.secondaryWeapon = {}
	end
	if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon) ~= nil) then
		DatAss.secondaryWeapon = {}
		DatAss.secondaryWeapon.dataID = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).dataID
		DatAss.secondaryWeapon.name = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).name
		DatAss.secondaryWeapon.weapontype= Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).weapontype			
	else
		DatAss.secondaryWeapon = nil
	end	
end

--[[
********************************************************************************?***************************************
                                                    Ability Class
********************************************************************************?***************************************
--]]

DatAss.Ability = {}
DatAss.Ability.__index = DatAss.Ability

function DatAss.Ability.Construct(name, id, slot, range, initiative, isArea)
    local ability = {}
    setmetatable(ability, DatAss.Ability)
    ability.id = id
    ability.initiative = initiative
    ability.isArea = isArea
    ability.name = name
    ability.range = range
    ability.slot = slot
    return ability
end

function DatAss.Ability:CanCast()
    return not Player:IsSpellOnCooldown(self.slot)
end

function DatAss.Ability:TryCast(TID)
    if (self:CanCast()) then
        if ( TID ~= 0 ) then
            local T = CharacterList:Get(TID)
            if ( T ~= nil ) then
                if (T.distance < self.range) then
                    if (Player:IsProfessionPowerLargerThan(self.initiative)) then
                        if (not self.isArea) then                            
                            Player:CastSpell(self.slot,TID)
                            return true                                                          
                        end
                    end
                end
            end
        end
    end
    return false
end

function DatAss.Ability:TryCastSelf()
    if (self:CanCast()) then
        if (Player:IsProfessionPowerLargerThan(self.initiative)) then
            if (not self.isArea) then                
                Player:CastSpell(self.slot,TID)
                return true
            end
        end
    end
    return false
end

--[[
********************************************************************************?***************************************
                                                    Spellbook Class
********************************************************************************?***************************************
--]]

DatAss.Spellbook = {}
DatAss.Spellbook.Spells = {}
DatAss.Spellbook.Slots = {}
DatAss.Spellbook.Counter = 0

function DatAss.Spellbook.Initialize()
	-- Slot 1
	DatAss.Backstab = DatAss.Ability.Construct("Backstab", 13004, GW2.SKILLBARSLOT.Slot_1, 130, 0, false) -- Dagger mainhand
	DatAss.SneakAttack = DatAss.Ability.Construct("Sneak Attack", 13084, GW2.SKILLBARSLOT.Slot_1, 900, 0, false) -- Pistol mainhand
	DatAss.TacticalStrike = DatAss.Ability.Construct("Tactical Strike", 13009, GW2.SKILLBARSLOT.Slot_1, 130, 0, false) -- Sword mainhand

	-- Slot 2
	DatAss.Heartseeker = DatAss.Ability.Construct("Heartseeker", 13097, GW2.SKILLBARSLOT.Slot_2, 450, 3, false) -- Dagger mainhand

	-- Slot 3
	DatAss.DeathBlossom = DatAss.Ability.Construct("Death Blossom", 13006, GW2.SKILLBARSLOT.Slot_3, 240, 5, false) -- Dagger mainhand, dagger offhand
	DatAss.PistolWhip = DatAss.Ability.Construct("Pistol Whip", 13031, GW2.SKILLBARSLOT.Slot_3, 130, 5, false) -- Sword mainhand, pistol offhand
	DatAss.Unload = DatAss.Ability.Construct("Unload", 13011, GW2.SKILLBARSLOT.Slot_3, 900, 5, false) -- Pistol mainhand, pistol offhand
	DatAss.FlankingStrike = DatAss.Ability.Construct("Flanking Strike", 13016, GW2.SKILLBARSLOT.Slot_3, 130, 4, false) -- Sword mainhand, dagger offhand
	DatAss.ShadowStrike = DatAss.Ability.Construct("Shadow Strike", 13010, GW2.SKILLBARSLOT.Slot_3, 130, 3, false) -- Pistol mainhand, dagger offhand
	DatAss.Repeater = DatAss.Ability.Construct("Repeater", 13111, GW2.SKILLBARSLOT.Slot_3, 900, 5, false) -- Pistol mainhand, no offhand
	DatAss.Stab = DatAss.Ability.Construct("Stab", 13112, GW2.SKILLBARSLOT.Slot_3, 130, 4, false) -- Sword mainhand, no offhand
	DatAss.TwistingFangs = DatAss.Ability.Construct("Twisting Fangs", 13110, GW2.SKILLBARSLOT.Slot_3, 130, 4, false) -- Dagger mainhand, no offhand

	-- Slot 4
	DatAss.DancingDagger = DatAss.Ability.Construct("Dancing Dagger", 13019, GW2.SKILLBARSLOT.Slot_4, 900, 4, false) -- Dagger mainhand

	-- Slot 5
	DatAss.CloakAndDagger = DatAss.Ability.Construct("Cloak and Dagger", 13013, GW2.SKILLBARSLOT.Slot_5, 130, 6, false)    -- Dagger mainhand
	DatAss.BlackPowder = DatAss.Ability.Construct("Black Powder", 13113, GW2.SKILLBARSLOT.Slot_5, 900, 6, false) -- Pistol mainhand

	-- Slot 6
	DatAss.HideInShadows = DatAss.Ability.Construct("Hide in Shadows", 13027, GW2.SKILLBARSLOT.Slot_6, 8192, 0, false) -- Slot skill

	-- Slot 9
	DatAss.Caltrops = DatAss.Ability.Construct("Caltrops", 13028, GW2.SKILLBARSLOT.Slot_9, 8192, 0, false) -- Slot skill

	-- Slot 10
	DatAss.ThievesGuild = DatAss.Ability.Construct("Thieves Guild", 13082, GW2.SKILLBARSLOT.Slot_10, 8192, 0, false) -- Slot skill

	-- Slot 13
	DatAss.Steal = DatAss.Ability.Construct("Steal", 13014, GW2.SKILLBARSLOT.Slot_13, 900, 0, false) -- Profession mechanic

	-- Set Weapons
	UpdateWeaponInfo()

	-- Update Spellbook content
	DatAss.Spellbook.Update()
end

function DatAss.Spellbook.AddToList(ability)
    DatAss.Spellbook.Counter = DatAss.Spellbook.Counter + 1
    DatAss.Spellbook.Spells[ability.slot] = ability
    DatAss.Spellbook.Slots[DatAss.Spellbook.Counter] = ability.slot
end

function DatAss.Spellbook.GetAbilityBySlot(slot)
    return setmetatable(DatAss.Spellbook.Spells[slot], DatAss.Ability)
end

function DatAss.Spellbook.GetAbilityByPosition(position)
    return setmetatable(DatAss.Spellbook.Spells[DatAss.Spellbook.Slots[position]], DatAss.Ability)
end

function DatAss.Spellbook.GetVisualSlotBySlot(slot)
    if (slot >= 5 and slot <= 10) then
        return slot - 4
    elseif (slot >= 12) then
        return "F" .. slot - 12 + 1
    end
    return slot + 6
end

function DatAss.Spellbook.DumpSpellbook()
    local i = DatAss.Spellbook.Counter
    d("")
    while i > 0 do
        local ability = DatAss.Spellbook.GetAbilityByPosition(i)
        DatAss.Log("[" .. i .. "] " .. ability.name .. " with spellID " .. ability.id.. " in engine slot " .. ability.slot .. ", visual slot " .. DatAss.Spellbook.GetVisualSlotBySlot(ability.slot))
        i = i - 1
    end
    DatAss.Log("Dumping spellbook:")	
	if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon) ~= nil) then
		UpdateWeaponInfo()
		DatAss.secondaryWeapon.typename = DatAss.GetStringOfWeaponType(DatAss.secondaryWeapon)
		DatAss.Log("Current Secondary Weapon: " .. DatAss.secondaryWeapon.typename)
	end
	if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon) ~= nil) then
		UpdateWeaponInfo()
		DatAss.mainWeapon.typename = DatAss.GetStringOfWeaponType(DatAss.mainWeapon)
		DatAss.Log("Current Primary Weapon: " .. DatAss.mainWeapon.typename)	
	end
end

function DatAss.Spellbook.Update()
	DatAss.Spellbook.Counter = 0
	
	-- Slot 1
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_1)) then
		if (DatAss.mainWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.Backstab)
		elseif (DatAss.mainWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then
			DatAss.Spellbook.AddToList(DatAss.SneakAttack)
		elseif (DatAss.mainWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword) then
			DatAss.Spellbook.AddToList(DatAss.TacticalStrike)
		end
	end

	-- Slot 2
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_2)) then
		if (DatAss.mainWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.Heartseeker)
		end
	end
	 
	-- Slot 3
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_3)) then
		if (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon == nil) then
			DatAss.Spellbook.AddToList(DatAss.Repeater)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword and DatAss.secondaryWeapon == nil) then
			DatAss.Spellbook.AddToList(DatAss.Stab)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon == nil) then
			DatAss.Spellbook.AddToList(DatAss.TwistingFangs)		
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.DeathBlossom)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then
			DatAss.Spellbook.AddToList(DatAss.PistolWhip)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then
			DatAss.Spellbook.AddToList(DatAss.Unload)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.FlankingStrike)
		elseif (DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.ShadowStrike)		
		end
	end

	-- Slot 4
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_4)) then
		if (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.DancingDagger)
		end
	end
	
	-- Slot 5
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_5)) then
		if (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then
			DatAss.Spellbook.AddToList(DatAss.CloakAndDagger)
		elseif (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then
			DatAss.Spellbook.AddToList(DatAss.BlackPowder)
		elseif (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then
			DatAss.Spellbook.AddToList(DatAss.BlackPowder)
		end
	end
	
	-- Slot 6
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_6) and Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_6).skillID == 13027) then
		DatAss.Spellbook.AddToList(DatAss.HideInShadows)
	end
	
	-- Slot 9
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_9) and Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9).skillID == 13028) then
		DatAss.Spellbook.AddToList(DatAss.Caltrops)
	end
	
	-- Slot 10
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_10) and Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10).skillID == 13082) then
		DatAss.Spellbook.AddToList(DatAss.ThievesGuild)
	end
		
	-- Slot 13
	if (Player:IsSpellUnlocked(GW2.SKILLBARSLOT.Slot_13) and Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13).skillID == 13014) then
		DatAss.Spellbook.AddToList(DatAss.Steal)
	end
	
	DatAss.Spellbook.DumpSpellbook()
end

--[[
********************************************************************************?***************************************
                                                    Weapon Update
********************************************************************************?***************************************
--]]

DatAss.cUpdateWeapons = inheritsFrom(wt_cause)
DatAss.eUpdateWeapons = inheritsFrom(wt_effect)

function DatAss.cUpdateWeapons:evaluate()	
	if (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon) ~= nil) then
		if (DatAss.mainWeapon == nil or DatAss.mainWeapon.weapontype ~= Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MainHandWeapon).weapontype) then
		return true
		end
	else
		DatAss.mainWeapon = nil
	end
	if  (Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon) ~= nil) then
		if (DatAss.secondaryWeapon == nil or DatAss.secondaryWeapon.weapontype ~= Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.OffHandWeapon).weapontype) then		
		return true
		end
	else
		DatAss.secondaryWeapon = nil
	end
	return false
end

function DatAss.eUpdateWeapons:execute()	
	UpdateWeaponInfo()
	
	DatAss.Spellbook.Update()
end

--[[
********************************************************************************?***************************************
                                                    Attack
********************************************************************************?***************************************
--]]

DatAss.cAttack = inheritsFrom(wt_cause)
DatAss.eAttack = inheritsFrom(wt_effect)

function DatAss.cAttack:evaluate()
    return wt_core_state_combat.CurrentTarget ~= 0
end

function DatAss.eAttack:execute()
    Player:StopMoving()
    TID = wt_core_state_combat.CurrentTarget
    if ( TID ~= 0 ) then
        local T = CharacterList:Get(TID)
        if ( T ~= nil ) then
			local TPos = T.pos
			Player:SetFacing(TPos.x, TPos.y, TPos.z)
            if (TID ~= DatAss.lastAttacked) then
                DatAss.Log("Attacking " .. TID .. " --> Health: " .. T.health.percent .. "/" .. 100 .. ", Level: " ..
                        T.level .. ", Distance: " .. string.format("%.2f", T.distance) .. "")
                DatAss.lastAttacked = TID
            end
			-- Someone please clean this up. I don't really have any decent ideas on how to improve the appearance of the following lines of code.
			if (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.ShouldAOE() or not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.ShouldAOE() and DatAss.Caltrops:TryCast(TID)) then
				elseif (T.health.percent > 40 and DatAss.DeathBlossom:TryCast(TID)) then
				elseif (T.health.percent <= 40 and DatAss.Heartseeker:TryCast(TID)) then            
				elseif (DatAss.Backstab:TryCast(TID)) then
				else
				end			
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) or (DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon == nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger)) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.Heartseeker:TryCast(TID)) then            
				elseif (DatAss.Backstab:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.Unload:TryCast(TID)) then            
				elseif (DatAss.SneakAttack:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (Player.health.percent <= 60 and DatAss.BlackPowder:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.ShadowStrike:TryCast(TID)) then            
				elseif (DatAss.SneakAttack:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon == nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.Repeater:TryCast(TID)) then            
				elseif (DatAss.SneakAttack:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.FlankingStrike:TryCast(TID)) then            
				elseif (DatAss.TacticalStrike:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon ~= nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword and DatAss.secondaryWeapon.weapontype == GW2.WEAPONTYPE.Pistol) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.PistolWhip:TryCast(TID)) then            
				elseif (DatAss.TacticalStrike:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon == nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Sword) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (DatAss.Stab:TryCast(TID)) then            
				elseif (DatAss.TacticalStrike:TryCast(TID)) then
				else
				end
			elseif (Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1).skillID ~= 13022 and DatAss.mainWeapon ~= nil and DatAss.secondaryWeapon == nil and DatAss.mainWeapon.weapontype == GW2.WEAPONTYPE.Dagger) then 
				if (DatAss.GetNearbyEnemyCount() > 1 and (DatAss.Caltrops:CanCast() or DatAss.ThievesGuild:CanCast())) then
					if (not DatAss.Caltrops:TryCast(TID)) then
						DatAss.ThievesGuild:TryCast(TID)
					end
				elseif (Player.health.percent <= 60 and DatAss.ThievesGuild:TryCast(TID)) then
				elseif (not DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = true
				elseif (DatAss.hasSteal and DatAss.Steal:TryCast(TID)) then
					DatAss.hasSteal = false
				elseif (DatAss.Caltrops:TryCast(TID)) then				
				elseif (T.health.percent > 40 and DatAss.TwistingFangs:TryCast(TID)) then
				elseif (T.health.percent <= 40 and DatAss.Heartseeker:TryCast(TID)) then             
				elseif (DatAss.Backstab:TryCast(TID)) then
				else
				end
			else
				local s1 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
				local s2 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_2)
				local s3 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_3)
				local s4 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)
				local s5 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_5)
				if (s1 ~= nil) then
					wt_global_information.AttackRange = s1.maxRange
					if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_2) and s2~=nil and (T.distance < s2.maxRange or s2.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_2,wt_core_state_combat.CurrentTarget)					
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_4) and s4~=nil and (T.distance < s4.maxRange or s4.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_4,wt_core_state_combat.CurrentTarget)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3) and s3~=nil and (T.distance < s3.maxRange or s3.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_3,wt_core_state_combat.CurrentTarget)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_5) and s5~=nil and (T.distance < s5.maxRange or s5.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_5,wt_core_state_combat.CurrentTarget)
					elseif (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_1) and s1~=nil and (T.distance < s1.maxRange or s1.maxRange < 100)) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1,wt_core_state_combat.CurrentTarget)					
					end
				end
			end					
        end
    end
end

--[[
********************************************************************************?***************************************
                                                    Heal
********************************************************************************?***************************************
--]]

DatAss.cHeal = inheritsFrom(wt_cause)
DatAss.eHeal = inheritsFrom(wt_effect)

function DatAss.cHeal:evaluate()
    return Player.health.percent < DatAss.RestHealthLimit and DatAss.HideInShadows:CanCast()
end

function DatAss.eHeal:execute()
    DatAss.HideInShadows:TryCastSelf()
end

--[[
********************************************************************************?***************************************
                                                    MoveCloser
********************************************************************************?***************************************
--]]

DatAss.cMoveCloser = inheritsFrom(wt_cause)
DatAss.eMoveCloser = inheritsFrom(wt_effect)

function DatAss.cMoveCloser:evaluate()
    if ( wt_core_state_combat.CurrentTarget ~= 0 ) then
        local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
        local Distance = T ~= nil and T.distance or 0
        local LOS = T~=nil and T.los or false
        if (Distance >= DatAss.attackRange  or LOS~=true) then
            return true
        else
            if( Player:GetTarget() ~= wt_core_state_combat.CurrentTarget) then
                Player:SetTarget(wt_core_state_combat.CurrentTarget)
            end
        end
    end
    return false
end

function DatAss.eMoveCloser:execute()
    wt_debug("e_MoveCloser ")
    local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
    if ( T ~= nil ) then
        Player:MoveTo(T.pos.x, T.pos.y, T.pos.z, 96)
    end
end

--[[
********************************************************************************?***************************************
                                                    Bot Helpers
********************************************************************************?***************************************
--]]

if (DatAss.professionID >= 0 and DatAss.professionID == Player.profession) then
    DatAss.eAttack.usesAbility = true
    DatAss.eHeal.usesAbility = true
    DatAss.eMoveCloser.usesAbility = true	    
	
	-- Initialize Spells
    DatAss.Spellbook.Initialize()

	-- Update Weapons
	local combatUpdateWeapons = wt_kelement:create("UpdateWeapons", DatAss.cUpdateWeapons, DatAss.eUpdateWeapons, 55)
	wt_core_state_combat:add(combatUpdateWeapons)
	
    -- Heal
    local combatHeal = wt_kelement:create("Heal", DatAss.cHeal, DatAss.eHeal, 100)
    wt_core_state_combat:add(combatHeal)

    -- Move Closer
    local combatMoveCloser = wt_kelement:create("MoveCloser", DatAss.cMoveCloser, DatAss.eMoveCloser, 75)
    wt_core_state_combat:add(combatMoveCloser)

    -- Combat
    local combatAttack = wt_kelement:create("Attack", DatAss.cAttack, DatAss.eAttack, 50)
    wt_core_state_combat:add(combatAttack)

    -- Set profession
    wt_global_information.Currentprofession = DatAss
	wt_global_information.AttackRange = DatAss.attackRange
end
