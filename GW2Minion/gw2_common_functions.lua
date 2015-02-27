gw2_common_functions = {}

function gw2_common_functions.HasBuffs(entity, buffIDs)
    if ( entity ) then
		local buffs = entity.buffs
		if (ValidTable(buffs) == false) then return false end

			for _orids in StringSplit(tostring(buffIDs),",") do
				local found = false
				for _andid in StringSplit(_orids,"+") do
					found = false
					for i, buff in pairs(buffs) do

						if (buff.buffID == tonumber(_andid)) then
							found = true
						end
					end
					if (not found) then
						break
					end
				end
				if (found) then
					return true
				end
			end
	end
    return false
end

function gw2_common_functions.BufflistHasBuffs(bufflist, buffIDs)

	if (ValidTable(bufflist) == false) then return false end

	for _orids in StringSplit(tostring(buffIDs),",") do
		local found = false
		for _andid in StringSplit(_orids,"+") do
				found = false
			for i, buff in pairs(bufflist) do

				if (buff.buffID == tonumber(_andid)) then
					found = true
				end
			end
			if (not found) then
				break
			end
		end
		if (found) then
			return true
		end
	end
    return false
end

function gw2_common_functions.CountConditions(bufflist)
	local count = 0
	if ( bufflist ) then
		for _,buff in pairs(bufflist) do
			local bskID = buff.skillID
			if ( bskID and ml_global_information.ConditionsEnum[bskID] ~= nil) then
				count = count + 1
			end
		end
	end
	return count
end
function gw2_common_functions.CountBoons(bufflist)
	local count = 0
	if ( bufflist ) then
		for _,buff in pairs(bufflist) do
			local bskID = buff.skillID
			if ( bskID and ml_global_information.BoonsEnum[bskID] ~= nil) then
				count = count + 1
			end
		end
	end
	return count
end

function gw2_common_functions.NecroLeaveDeathshroud()
	if (Player.profession == 8 ) then
		local deathshroud = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
		if ( deathshroud ~= nil and deathshroud.skillID == 10585 and Player:CanCast() and Player:GetCurrentlyCastedSpell() == 17 ) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
			return true
		end
	end
	return false
end

function gw2_common_functions.GetPartyMemberByName( name )
	local partylist = ml_global_information.Player_Party
	if ( TableSize(partylist) > 0 ) then
		local index, player  = next( partylist )
		while ( index ~= nil and player ~= nil ) do
			if (player.name == name) then
				return player
			end
			index, player  = next( partylist,index )
		end
	end
	return nil
end

function gw2_common_functions.MoveOnlyStraightForward()
	if ( Player:IsMoving() ) then
		local movdirs = Player:GetMovement()
		if (movdirs.left) then
			Player:UnSetMovement(2)
			return true
		elseif (movdirs.right) then
			Player:UnSetMovement(3)
			return true
		end
	end
	return false
end

function gw2_common_functions.FinishEnemy()
	if ( ml_global_information.Player_IsMoving == false and ml_global_information.Player_Health.percent > 15 ) then
		local EList = CharacterList("nearest,downed,attackable,interactable,selectable,maxdistance=150")
		if ( EList ) then
			local id,entity = next (EList)
			if ( id and entity ) then
				if ( entity.isInInteractRange ) then
					local target = Player:GetTarget()
					if ( not target or target.id ~= entity.id ) then
						Player:SetTarget(entity.id)
					else
						Player:Interact( entity.id )
						ml_log("Finishing Enemy..")
						ml_global_information.Wait(1000)
						return true
					end
				end
			end
		end
	end
	return false
end

function gw2_common_functions.GetClosestWaypointToPos(mapID,pos)
	local waypoint = nil
	local mapData = gw2_datamanager.GetLocalWaypointList(mapID)
	if (ValidTable(mapData)) then
		local closestDist = 999999
		for _,wdata in pairs(mapData) do
			if (wdata.contested == false and wdata.onmesh) then
				local wPos = wdata.pos
				local dist = Distance2D(wPos.x,wPos.y,pos.x,pos.y)
				if (dist < closestDist) then
					waypoint = wdata
					closestDist = dist
				end
			end
		end
	end
	return waypoint
end

-- Tries to get a "best target" to attack
function gw2_common_functions.GetBestCharacterTarget( maxrange )

	local range = maxrange
	if ( range == nil ) then
		range = ml_global_information.AttackRange
	end

	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars

	-- Try to get Aggro Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,lowesthealth,los,maxdistance="..tostring(range))
	-- Try to get Aggro Enemy
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end
	-- Try to get Enemy with los in range
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("lowesthealth,onmesh,los,maxdistance="..tostring(range)) end
	-- Try to get Enemy without los
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("shortestpath,onmesh") end

	if ( target and target.id ) then
		if ( target.distance < 1500 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable and currTarget.alive and currTarget.onmesh) then
			return target
		end
	end
	return nil
end
-- Tries to get a "best target" to attack for assist mode (maxdistance limited)
function gw2_common_functions.GetBestCharacterTargetForAssist()
	-- Try to get Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange)..",los")
	-- Try to get Enemy without los in range
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange)) end
	-- Try to get Enemy without los in range + 250
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange + 250)) end

	if ( target and target.id ) then
		if ( target.distance < 1600 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable ) then
			return target
		end
	end
	return nil
end
-- Tries to get a "best aggro target" to attack
function gw2_common_functions.GetBestAggroTarget()
	local range = ml_global_information.AttackRange
	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars
	if ( range > 1000 ) then range = 1000 end -- limit search range a bit for ranged chars

	-- Try to get Aggro Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,lowesthealth,los,maxdistance="..tostring(range))
	-- Try to get Aggro Enemy
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end

	if ( target and target.id ) then
		if ( target.distance < 1500 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable ) then
			return target
		end
	end
	return nil
end
function gw2_common_functions.GetCharacterTargetExtended( filterstring )
    if ( filterstring ) then
		filterstring = filterstring..",attackable,alive,noCritter,exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))
	else
		filterstring = "attackable,alive,noCritter,exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))
	end

	-- Only in AssistMode we want to allow these settings
	if (gBotMode == GetString("assistMode")) then
		if (sMmode == "Players Only") then filterstring = filterstring..",player" end
		if (sMtargetmode == "LowestHealth") then filterstring = filterstring..",lowesthealth" end
		if (sMtargetmode == "Closest") then filterstring = filterstring..",nearest" end
		if (sMtargetmode == "Biggest Crowd") then filterstring = filterstring..",clustered=600" end
	end

	local TargetList = CharacterList(filterstring)
	if ( TargetList ) then
		local id,entry = next(TargetList)
		if (id and entry ) then
			return entry
		end
	end
	return nil
end

gw2_common_functions.lastVendorID = nil
gw2_common_functions.lastVendorConversationHistory = { Repair=0, Shop=0, KarmaShop=0, Continue=0, Story=0, Return=0 } -- holds the already tried conversation IDs
function gw2_common_functions.handleConversation(result)
	if (Player:IsConversationOpen() and (Inventory:IsVendorOpened() == false or result == "repair") and ValidString(result)) then
		local curVendor = Player:GetTarget()
		-- Reset the conversationHistory when we got a new or different vendorMarker
		if ( curVendor and curVendor.id ) then
			if ( gw2_common_functions.lastVendorID == nil or gw2_common_functions.lastVendorID ~= curVendor.id ) then
				gw2_common_functions.lastVendorID = curVendor.id
				gw2_common_functions.lastVendorConversationHistory = { Repair=0, Shop=0, KarmaShop=0, Continue=0, Story=0, Return=0}
			end
		end

		local options = Player:GetConversationOptions()
		if (options) then
			-- for sell&buy order: #shop , #karmashop, #repair, #Story, #Continue, #Back, #Close
			-- for repair order: #repair, #Story, #Continue, #Back, #Close
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and result == "repair" and gw2_common_functions.lastVendorConversationHistory["Repair"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					gw2_common_functions.lastVendorConversationHistory["Repair"] = gw2_common_functions.lastVendorConversationHistory["Repair"] + 1
					return true
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Shop and (result == "sell" or result == "buy") and gw2_common_functions.lastVendorConversationHistory["Shop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Shop)
					gw2_common_functions.lastVendorConversationHistory["Shop"] = gw2_common_functions.lastVendorConversationHistory["Shop"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.KarmaShop and result == "sell" and gw2_common_functions.lastVendorConversationHistory["KarmaShop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.KarmaShop)
					gw2_common_functions.lastVendorConversationHistory["KarmaShop"] = gw2_common_functions.lastVendorConversationHistory["KarmaShop"] + 1
					return
				end
			end
			for index=0, #options do -- this is needed because NPCs often have the GW2.CONVERSATIONOPTIONS.Repair ID although they are offering vendoring
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and (result == "sell" or result == "buy") and gw2_common_functions.lastVendorConversationHistory["Repair"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					gw2_common_functions.lastVendorConversationHistory["Repair"] = gw2_common_functions.lastVendorConversationHistory["Repair"] + 1
					return
				end
			end
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Continue and gw2_common_functions.lastVendorConversationHistory["Continue"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Continue)
					gw2_common_functions.lastVendorConversationHistory["Continue"] = gw2_common_functions.lastVendorConversationHistory["Continue"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Story and gw2_common_functions.lastVendorConversationHistory["Story"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Story)
					gw2_common_functions.lastVendorConversationHistory["Story"] = gw2_common_functions.lastVendorConversationHistory["Story"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Return and gw2_common_functions.lastVendorConversationHistory["Return"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Return)
					gw2_common_functions.lastVendorConversationHistory["Return"] = gw2_common_functions.lastVendorConversationHistory["Return"] + 1
					return
				end
			end
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Close) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Close)
					return false
				end
			end
		end
	elseif (Inventory:IsVendorOpened() and ValidString(result)) then
		if (result == "buy") then
			if (Inventory:GetVendorServiceType() == GW2.VENDORSERVICETYPE.VendorBuy) then
				return true
			else
				Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorBuy)
			end
		elseif (result == "sell") then
			if (Inventory:GetVendorServiceType() == GW2.VENDORSERVICETYPE.VendorSell) then
				return true
			else
				Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorSell)
			end
		end
	end
end

