gw2_common_functions = {}

-- Draw Marker function
function gw2_common_functions.DrawMarker( marker )
	local markertype = marker:GetType()
	local pos = marker:GetPosition()

    local color = 0
    local s = 25
    local h = 150
	
    if ( markertype == GetString("grindMarker") ) then
        color = 1 -- red
    elseif ( markertype == GetString("miningMarker") ) then 
        color = 4 --blue
    elseif ( markertype == GetString("fishingMarker") ) then
        color = 7 -- yellow	
    elseif ( markertype == GetString("vendorMarker") ) then
        color = 8 -- orange
    end
    --Building the vertices for the object
    local t = { 
        [1] = { pos.x-s, pos.y+s, pos.z-s-h, color },
        [2] = { pos.x+s, pos.y+s, pos.z-s-h, color  },	
        [3] = { pos.x,   pos.y-s,   pos.z-h, color  },
        
        [4] = { pos.x+s, pos.y+s, pos.z-s-h, color },
        [5] = { pos.x+s, pos.y+s, pos.z+s-h, color  },	
        [6] = { pos.x,   pos.y-s,   pos.z-h, color  },
        
        [7] = { pos.x+s, pos.y+s, pos.z+s-h, color },
        [8] = { pos.x-s, pos.y+s, pos.z+s-h, color  },	
        [9] = { pos.x,   pos.y-s,   pos.z-h, color  },
        
        [10] = { pos.x-s, pos.y+s, pos.z+s-h, color },
        [11] = { pos.x-s, pos.y+s, pos.z-s-h, color  },	
        [12] = { pos.x,   pos.y-s,   pos.z-h, color  },
    }
    local id = RenderManager:AddObject(t)
    return id
end

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
			local bskID = buff.buffID
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
			local bskID = buff.buffID
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
		if ( deathshroud ~= nil and (deathshroud.skillID == 10585 or deathshroud.skillID == 30961 ) and Player:CanCast() and Player:GetCurrentlyCastedSpell() == ml_global_information.MAX_SKILLBAR_SLOTS ) then
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
	local mapData = gw2_datamanager.GetLocalWaypointListByDistance(mapID,pos)
	if (ValidTable(mapData)) then
		local i,wdata = next(mapData)
		while wdata and not waypoint do
			if (wdata.contested == false and wdata.onmesh) then
				waypoint = wdata
			end
			
			i,wdata = next(mapData,i)
		end
	end
	return waypoint
end

function gw2_common_functions.GetClosestWaypointToMap(targetMapID, currentMapID)

	currentMapID = currentMapID ~= nil and currentMapID or ml_global_information.CurrentMapID
	local pos = ml_global_information.Player_Pos

	if(targetMapID ~= nil) then	
		local currNode = ml_nav_manager.GetNode(currentMapID)
		local destNode = ml_nav_manager.GetNode(targetMapID)
		
		if(currNode and destNode) then
			-- Walk the path in reverse to see if any close maps have waypoints
			local navPath = ml_nav_manager.GetPath(destNode, currNode)

			if(ValidTable(navPath)) then
				local prevNode = nil
				local closestWaypoint = nil
				
				local i,node = next(navPath)
				while i and node and not closestWaypoint do
					if(prevNode == nil) then
						-- Target map
						local _,nextNode = next(navPath, i)
						if(nextNode and nextNode.neighbors and ValidTable(nextNode.neighbors[node.id])) then
							local entryPos = nextNode.neighbors[node.id][1]
							local waypointlist = gw2_datamanager.GetLocalWaypointListByDistance(node.id, entryPos)
							if (ValidTable(waypointlist)) then
								closestWaypoint = select(2,next(waypointlist))
							end
						end
					else
						if(node.neighbors and ValidTable(node.neighbors[prevNode.id])) then
							local exitPos = node.neighbors[prevNode.id][1]
							local waypointlist = gw2_datamanager.GetLocalWaypointListByDistance(node.id,exitPos)
							if (ValidTable(waypointlist)) then
								closestWaypoint = select(2,next(waypointlist))
							end
						end
					end
					
					prevNode = node
					i,node = next(navPath, i)
				end
				
				if(ValidTable(closestWaypoint)) then
					return closestWaypoint
				end
			end
		end
	end
	
	return nil
end

-- Tries to get a "best target" to attack
function gw2_common_functions.GetBestCharacterTarget( maxrange )

	local range = maxrange
	if ( range == nil ) then
		range = ml_global_information.AttackRange
	end

	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars

--[[
	-- Try to get Aggro Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,lowesthealth,los,maxdistance="..tostring(range))
	-- Try to get Aggro Enemy
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end
	-- Try to get Enemy with los in range
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("lowesthealth,onmesh,los,maxdistance="..tostring(range)) end
	-- Try to get Enemy without los
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("shortestpath,onmesh") end
]]

	local hostileCheck = gIgnoreYellowMob == "1" and "hostile," or ""
	-- 
	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest,los,maxdistance="..tostring(range))
	-- 
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh," .. hostileCheck .. "nearest,los,maxdistance="..tostring(range)) end
	-- 
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end
	-- 
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh," .. hostileCheck .. "nearest") end
	-- 
	if (target == nil and gIgnoreYellowMob == "1") then target = gw2_common_functions.GetCharacterTargetExtended("onmesh,nearest,los,maxlevel=15") end
	-- 
	if (target == nil and gIgnoreYellowMob == "1") then target = gw2_common_functions.GetCharacterTargetExtended("onmesh,nearest,maxlevel=15") end

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
	-- Ignore yellow check.
	local hostileCheck = gIgnoreYellowMob == "1" and ",hostile" or ""
	-- Try to get Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange).. hostileCheck .. ",los")
	
	-- Try to get downed enemy
	if(target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange).. hostileCheck .. ",los", GW2.HEALTHSTATE.Downed) end	
	-- Try to get Enemy without los in range
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. hostileCheck) end
	-- Try to get Enemy without los in range + 250
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange + 250) .. hostileCheck) end
	-- 
	if (target == nil and gIgnoreYellowMob == "1") then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. "onmesh,nearest,los,maxlevel=15") end
	-- 
	if (target == nil and gIgnoreYellowMob == "1") then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. "onmesh,nearest,maxlevel=15") end

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
function gw2_common_functions.GetBestAggroTarget(healthstate)
	local range = ml_global_information.AttackRange
	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars
	if ( range > 1000 ) then range = 1000 end -- limit search range a bit for ranged chars
	
	-- Try to get Aggro Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,lowesthealth,los,maxdistance="..tostring(range), healthstate)

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
function gw2_common_functions.GetCharacterTargetExtended( filterstring, healthstate )
    if ( filterstring ) then
		filterstring = filterstring..",attackable,noCritter,exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))
	else
		filterstring = "attackable,noCritter,exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))
	end
	
	if(healthstate == nil or healthstate == GW2.HEALTHSTATE.Alive) then
		filterstring = filterstring..",alive"
	elseif(healthstate == GW2.HEALTHSTATE.Downed) then
		filterstring = filterstring..",downed"
	end

	-- Only in AssistMode we want to allow these settings
	if (sMmode == "Players Only") then filterstring = filterstring..",player" end
	if (gBotMode == GetString("assistMode") or gBotMode == GetString("taskspvp")) then
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

gw2_common_functions.vendorHistory = {
	LastID = 0,
	EntryTime = 0,
	repair = 0,
	Shop=0,
	KarmaShop=0,
	Continue=0,
	Story=0,
	Return=0,
}
function gw2_common_functions.handleConversation(result)
	if (Player:IsConversationOpen() and (Inventory:IsVendorOpened() == false or result == "repair") and ValidString(result)) then
		local curVendor = Player:GetTarget()
		-- Reset the conversationHistory when we got a new or different vendorMarker
		if (curVendor and curVendor.id and (gw2_common_functions.vendorHistory.LastID ~= curVendor.id or TimeSince(gw2_common_functions.vendorHistory.EntryTime) > 60000)) then
			gw2_common_functions.vendorHistory = {
				LastID = curVendor.id,
				EntryTime = ml_global_information.Now,
				Repair = 0,
				Shop=0,
				KarmaShop=0,
				Continue=0,
				Story=0,
				Return=0,
			}
		end

		local options = Player:GetConversationOptions()
		if (options) then
			-- for sell&buy order: #shop , #karmashop, #repair, #Story, #Continue, #Back, #Close
			-- for repair order: #repair, #Story, #Continue, #Back, #Close
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and result == "repair" and gw2_common_functions.vendorHistory["Repair"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					gw2_common_functions.vendorHistory["Repair"] = gw2_common_functions.vendorHistory["Repair"] + 1
					return true
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Shop and (result == "sell" or result == "buy") and gw2_common_functions.vendorHistory["Shop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Shop)
					gw2_common_functions.vendorHistory["Shop"] = gw2_common_functions.vendorHistory["Shop"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.KarmaShop and result == "sell" and gw2_common_functions.vendorHistory["KarmaShop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.KarmaShop)
					gw2_common_functions.vendorHistory["KarmaShop"] = gw2_common_functions.vendorHistory["KarmaShop"] + 1
					return
				end
			end
			for index=0, #options do -- this is needed because NPCs often have the GW2.CONVERSATIONOPTIONS.Repair ID although they are offering vendoring
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and (result == "sell" or result == "buy") and gw2_common_functions.vendorHistory["Repair"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					gw2_common_functions.vendorHistory["Repair"] = gw2_common_functions.vendorHistory["Repair"] + 1
					return
				end
			end
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Continue and gw2_common_functions.vendorHistory["Continue"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Continue)
					gw2_common_functions.vendorHistory["Continue"] = gw2_common_functions.vendorHistory["Continue"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Story and gw2_common_functions.vendorHistory["Story"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Story)
					gw2_common_functions.vendorHistory["Story"] = gw2_common_functions.vendorHistory["Story"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Return and gw2_common_functions.vendorHistory["Return"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Return)
					gw2_common_functions.vendorHistory["Return"] = gw2_common_functions.vendorHistory["Return"] + 1
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



-- Try to get the next custom VendorMarker in our map where a vendor should be nearby, used by buy and sell task
function gw2_common_functions.GetNextVendorMarker(oldmarker)
			
	local filterLevel = false
	local vendormarker = ml_marker_mgr.GetNextMarker(GetString("vendorMarker"), filterLevel)
	
	-- get a different marker
	if (vendormarker and oldmarker ~= nil and oldmarker:GetName() == vendormarker:GetName()) then	
		vendormarker = ml_marker_mgr.GetNextMarker(GetString("vendorMarker"), filterLevel)
	end
		
	return vendormarker
end

function gw2_common_functions.GetTargetByID(targetID)
	return CharacterList:Get(targetID) or GadgetList:Get(targetID)
end

function gw2_common_functions.GetProfessionName(profession)
	profession = profession or Player.profession or 10
	if (type(profession) == "number" and profession < 10) then
		local name = table_invert(GW2.CHARCLASS)[profession]
		if (ValidString(name)) then
			return name
		end
	end
	return "NoClass"
end

-- return true/false if player is in an instance (only works for dungeons and normal instances, not while using "home instance stone" or "hall of monuments portal stone") 
function gw2_common_functions.PlayerInInstance()
	local partyInfo = ml_global_information.Player_Party
	if (ValidTable(partyInfo)) then
		for _,member in pairs(partyInfo) do
			if (member.id == Player.id and member.isUnknown1 ~= nil and member.isUnknown1 ~= 0) then
				return true
			end
		end
	end
	return false
end

-- Can move in direction(dir=0->7).
function gw2_common_functions.CanMoveDirection(direction,distance)
	if (direction and type(direction) == "number") then
		local forwardLeft,forwardRight,backwardLeft,backwardRight = 4,5,6,7
		local directionToDegree = {[GW2.MOVEMENTTYPE.Forward] = 0, [GW2.MOVEMENTTYPE.Backward] = 180, [GW2.MOVEMENTTYPE.Left] = 270, [GW2.MOVEMENTTYPE.Right] = 90, [forwardLeft] = 315, [forwardRight] = 45, [backwardLeft] = 225, [backwardRight] = 135,}
		local stepSize = 25
		local steps = distance / stepSize
		for step=1,steps do
			if (Player:CanMoveDirection(directionToDegree[direction],(stepSize*step)) == false) then
				return false
			end
		end
		return true
	end
	return false
end

-- Can evade in direction(dir=0->7).
function gw2_common_functions.CanEvadeDirection(direction)
	if (direction and type(direction) == "number") then
		local stepSize = 15
		local steps = 350 / stepSize
		for step=1,steps do
			if (Player:CanEvade(direction,(stepSize*step)) == false) then
				return false
			end
		end
		return true
	end
	return false
end

-- Evade(dir=0->7).
gw2_common_functions.lastEvade = 0
function gw2_common_functions.Evade(direction)
	if (ml_global_information.Player_Endurance >= 50) then
		local evadeTarget = false
		if (type(direction) ~= "number") then
			local aggroTargets = CharacterList("aggro,alive,maxdistance=3000")
			if (ValidTable(aggroTargets)) then
				for _,target in pairs(aggroTargets) do
					local cinfo = target.castinfo
					if (ValidTable(cinfo) and cinfo.targetID == Player.id and Player.castinfo.duration == 0 and TimeSince(gw2_common_functions.lastEvade) > 1500) then
						evadeTarget = true
					end
				end
			end
		end
		if (type(direction) == "number" or evadeTarget) then
			direction = tonumber(direction) or math.random(0,7)
			if (gw2_common_functions.CanEvadeDirection(direction)) then
				Player:Evade(direction)
				gw2_common_functions.lastEvade = ml_global_information.Now
				return true
			end
		end
		return false
	end
end

-- heading to radian.
function gw2_common_functions.headingToRadian(pos)
	if (ValidTable(pos)) then
		local radian = math.atan2(pos.hx,pos.hy)
		if (radian < 0) then radian = radian + math.pi * 2 end
		return radian
	end
end

-- radian to degrees.
function gw2_common_functions.radianToDegrees(radian)
	local degrees = ((radian * 180) / math.pi) + 90
	if (degrees > 360) then
		degrees = degrees - 360
	end
	return degrees
end

-- get differance in degrees.
function gw2_common_functions.getDegreeDiffTargets(targetIDA,targetIDB) -- gw2_common_functions.getDegreeDiffTargets(targetID,Player.id) player relative to target.
	local targetA = CharacterList:Get(targetIDA) or GadgetList:Get(targetIDA)
	local targetB = CharacterList:Get(targetIDB) or GadgetList:Get(targetIDB)
	if (ValidTable(targetA) and ValidTable(targetB)) then
		local radianA = gw2_common_functions.headingToRadian(targetA.pos)
		local degreeA = gw2_common_functions.radianToDegrees(radianA)
		local radianB = math.atan2(targetB.pos.x - targetA.pos.x, targetB.pos.y - targetA.pos.y)
		local degreeB = gw2_common_functions.radianToDegrees(radianB)
		local diffDegree = degreeB - degreeA
		if (targetA.isGadget or targetB.isGadget) then diffDegree = diffDegree - 90 end
		if (diffDegree < 0) then diffDegree = 360 + diffDegree end
		return diffDegree
	end
end

-- Filter entity list by relative position.
function gw2_common_functions.filterRelativePostion(entityList,dir)
	local returnList = {}
	if (ValidTable(entityList)) then
		local playerID = Player.id
		for _,entity in pairs(entityList) do
			if (ValidTable(entity.pos)) then
				local diffDegree = gw2_common_functions.getDegreeDiffTargets(playerID, entity.id)
				--local degrees = {[0] = 0, [1] = 45, [2] = 90, [3] = 135, [4] = 180, [5] = 225, [6] = 270, [7] = 315,}
				local forwardLeft,forwardRight,backwardLeft,backwardRight = 4,5,6,7
				local directionToDegree = {[GW2.MOVEMENTTYPE.Forward] = 0, [GW2.MOVEMENTTYPE.Backward] = 180, [GW2.MOVEMENTTYPE.Left] = 270, [GW2.MOVEMENTTYPE.Right] = 90, [forwardLeft] = 315, [forwardRight] = 45, [backwardLeft] = 225, [backwardRight] = 135,}
				local minDegree = directionToDegree[dir] - 22.5 < 0 and 360 - 22.5 or directionToDegree[dir] - 22.5
				local maxDegree = directionToDegree[dir] + 22.5 > 360 and 0 + 22.5 or directionToDegree[dir] + 22.5
				if (tonumber(minDegree) < tonumber(maxDegree) and tonumber(diffDegree) >= tonumber(minDegree) and tonumber(diffDegree) <= tonumber(maxDegree)) then
					table.insert(returnList,entity)
				elseif (tonumber(minDegree) > tonumber(maxDegree) and (tonumber(diffDegree) >= tonumber(minDegree) or tonumber(diffDegree) <= tonumber(maxDegree))) then
					table.insert(returnList,entity)
				end
			end
		end
	end
	return returnList
end