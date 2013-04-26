-- All gw2 utility stuff
function NeedRepair()
	local chest = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Chest )
	local boots = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Boots )
	local gloves = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Gloves )
	local headgear = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Headgear )
	local leggings = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Leggings )
	local shoulders = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Shoulders )
	
	local damagedCount = 0
	if ( chest ~= nil and chest.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	if	( boots ~= nil and boots.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	if	( gloves ~= nil and gloves.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	if	( headgear ~= nil and headgear.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	if	( leggings ~= nil and leggings.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	if	( shoulders ~= nil and shoulders.durability ~= GW2.ITEMDURABILITY.Ok ) then
		damagedCount = damagedCount + 1
	end
	
	if (damagedCount > 3) then
		return true
	end
	return false
end


function IsEquipmentBroken( )
	local chest = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Chest )
	local boots = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Boots )
	local gloves = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Gloves )
	local headgear = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Headgear )
	local leggings = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Leggings )
	local shoulders = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Shoulders )
	
	if ( ( chest ~= nil and chest.durability == GW2.ITEMDURABILITY.Broken ) or
		( boots ~= nil and boots.durability == GW2.ITEMDURABILITY.Broken ) or
		( gloves ~= nil and gloves.durability == GW2.ITEMDURABILITY.Broken ) or
		( headgear ~= nil and headgear.durability == GW2.ITEMDURABILITY.Broken ) or
		( leggings ~= nil and leggings.durability == GW2.ITEMDURABILITY.Broken ) or
		( shoulders ~= nil and shoulders.durability == GW2.ITEMDURABILITY.Broken ) ) then
		return true
	end
	return false
end

function IsEquipmentDamaged( )
	local chest = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Chest )
	local boots = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Boots )
	local gloves = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Gloves )
	local headgear = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Headgear )
	local leggings = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Leggings )
	local shoulders = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Shoulders )
	
	if ( ( chest ~= nil and chest.durability ~= GW2.ITEMDURABILITY.Ok ) or
		( boots ~= nil and boots.durability ~= GW2.ITEMDURABILITY.Ok ) or
		( gloves ~= nil and gloves.durability ~= GW2.ITEMDURABILITY.Ok ) or
		( headgear ~= nil and headgear.durability ~= GW2.ITEMDURABILITY.Ok ) or
		( leggings ~= nil and leggings.durability ~= GW2.ITEMDURABILITY.Ok ) or
		( shoulders ~= nil and shoulders.durability ~= GW2.ITEMDURABILITY.Ok ) ) then
		return true
	end
	return false
end

-- flips a table so keys become values
function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

-- takes in a % number and gives back a random number near that value, for randomizing skill usage at x% hp
function randomize(val)
	if ( val <= 100 and val > 0) then
		local high,low
		if ( (val + 15) > 100) then
			high = 100			
		else
			high = val + 15
		end
		if ( (val - 15) <= 0) then
			low = 1			
		else
			low = val - 15
		end
		return math.random(low,high)
	end
	return 0
end

