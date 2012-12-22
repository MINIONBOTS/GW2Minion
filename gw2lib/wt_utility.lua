-- All gw2 utility stuff

function IsEquippmentDamaged( )
	local chest = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Chest )
	local boots = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Boots )
	local gloves = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Gloves )
	local headgear = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Headgear )
	local leggings = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Leggings )
	local shoulders = Inventory:GetEquippedItemBySlot( GW2.EQUIPMENTSLOT.Shoulders )
	
	if ( ( chest ~= nil and chest.durability ~= 0 ) or
		( boots ~= nil and boots.durability ~= 0 ) or
		( gloves ~= nil and gloves.durability ~= 0 ) or
		( headgear ~= nil and headgear.durability ~= 0 ) or
		( leggings ~= nil and leggings.durability ~= 0 ) or
		( shoulders ~= nil and shoulders.durability ~= 0 ) ) then
		return true
	end
	return false
end