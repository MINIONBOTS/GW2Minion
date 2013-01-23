-- The vendoring State
-- Walking towards nearest Merchant n sell and buy stuff

-- We inherit from wt_core_state, which gives us: function wt_core_state:run(), function wt_core_state:add( kelement ) and function wt_core_state:register()
wt_core_state_vendoring = inheritsFrom(wt_core_state)
wt_core_state_vendoring.name = "Vendoring"
wt_core_state_vendoring.kelement_list = { }
wt_core_state_vendoring.junksold = false
wt_core_state_vendoring.CurrentTargetID = 0


--/////////////////////////////////////////////////////
-- Vendoring over Check
local c_vendordone = inheritsFrom(wt_cause)
local e_vendordone = inheritsFrom(wt_effect)

function c_vendordone:evaluate()
	if ( wt_core_state_vendoring.CurrentTargetID == nil or wt_core_state_vendoring.CurrentTargetID == 0 or wt_core_state_vendoring.junksold) then
		return true
	else		
		local T = MapObjectList:Get(wt_core_state_vendoring.CurrentTargetID)
		if ( T == nil ) then
			-- Try to get the nearest merchant one more time, not sure if that is needed
			local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
			if ( TableSize( EList ) > 0 ) then			
				local nextTarget
				nextTarget, E = next( EList )
				if ( nextTarget ~= nil and nextTarget ~= 0) then
					wt_core_state_vendoring.CurrentTargetID = nextTarget
					return false				
				end
			end			
			return true
		end
	end
	return false
end

function e_vendordone:execute()
	Player:ClearTarget()
	wt_debug("Vendoring finished")
	wt_core_state_vendoring.CurrentTargetID = 0
	wt_core_state_vendoring.junksold = false
	if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_core_state_minion.LeaderID ~= nil and wt_core_state_minion.LeaderID == Player.characterID) then		
		MultiBotSend( "11;none","gw2minion" )
	end
	wt_core_state_minion.MinionNeedsVendor = false
	wt_core_controller.requestStateChange(wt_core_state_idle)
	return
end

--/////////////////////////////////////////////////////
-- Move To Vendor Check
local c_movetovendorcheck = inheritsFrom(wt_cause)
local e_movetovendor = inheritsFrom(wt_effect)
local e_moveto_d_index = nil -- debug index, no reason to print debug message over and over unless you are debugging it

function c_movetovendorcheck:evaluate()
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get(wt_core_state_vendoring.CurrentTargetID)
		if ( T ~= nil and T.distance ~= nil) then
			if ( T.distance > 100 ) then			
				return true
			end
		else
			wt_core_state_vendoring.CurrentTargetID = nil
		end
	end
	return false
end

e_movetovendor.throttle = 500
function e_movetovendor:execute()
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get(wt_core_state_vendoring.CurrentTargetID)
		if ( T ~= nil ) then
			if ( e_moveto_d_index ~= wt_core_state_vendoring.CurrentTargetID ) then
				e_moveto_d_index = wt_core_state_vendoring.CurrentTargetID
				wt_debug( "Vendoring: moving to Vendor..." )		
			end
			local TPOS = T.pos
			if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_core_state_minion.LeaderID ~= nil and wt_core_state_minion.LeaderID ~= Player.characterID and T.distance > 2000) then
				-- follow grp leader until we are close enough to a vendor
				local party = Player:GetPartyMembers()
				if (party ~= nil and wt_core_state_minion.LeaderID ~= nil) then
					local leader = party[tonumber(wt_core_state_minion.LeaderID)]
					if (leader ~= nil) then
						local pos = leader.pos
						--TODO: Getmovementstate of leader, adopt range accordingly
						Player:MoveTo(pos.x,pos.y,pos.z,math.random( 20, 100 ))
						return
					end
				end				
			end
			Player:MoveTo(TPOS.x, TPOS.y, TPOS.z ,50 )
		end
	else
		wt_core_state_vendoring.CurrentTargetID = nil
		wt_error( "Vendoring: No Merchant found oO" )		
	end
end

--/////////////////////////////////////////////////////
-- Open Vendor Cause & Effect
local c_openvendor = inheritsFrom(wt_cause)
local e_openvendor = inheritsFrom(wt_effect)
function c_openvendor:evaluate()
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get(wt_core_state_vendoring.CurrentTargetID)
		if ( T ~= nil and T.distance ~= nil)  then
			if ( T.distance <= 100 ) then				
				local nearestID = Player:GetInteractableTarget()
				if ( nearestID ~= nil and T.characterID ~= nearestID ) then 
					if ( Player:GetTarget() ~= T.characterID) then				
						Player:SetTarget(T.characterID)						
					end
				end
				if ( not Inventory:IsVendorOpened() and  not Player:IsConversationOpen() ) then
					return true
				end
			end
		else
			wt_core_state_vendoring.CurrentTargetID = 0
		end
	end
	return false
end

e_openvendor.throttle = math.random( 500, 2000 )
e_openvendor.delay = math.random( 1000, 2500 )
function e_openvendor:execute()
	Player:StopMoving()
	wt_debug( "Vendoring: Opening Vendor.. " )
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get(wt_core_state_vendoring.CurrentTargetID)
		if ( T ~= nil ) then
			Player:Interact( T.characterID )
			-- tell minions to refresh their vendor, this is needed to prevent fuckups in the lists
			if (gMinionEnabled == "1" and MultiBotIsConnected( ) and wt_core_state_minion.LeaderID ~= nil and wt_core_state_minion.LeaderID == Player.characterID ) then
				MultiBotSend( "12;none","gw2minion" )
			end
		end
	end	
end

------------------------------------------------------------------------------
-- Do Conversation with Vendor Cause & Effect
local c_conversation = inheritsFrom( wt_cause )
local e_conversation = inheritsFrom( wt_effect )

function c_conversation:evaluate()
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 and Player:IsConversationOpen() and not wt_core_state_vendoring.junksold ) then
		return true
	end
	return false
end

e_conversation.throttle = math.random( 1000, 2500 )
e_conversation.delay = math.random( 1000, 2500 )
function e_conversation:execute()
	wt_debug( "Vendoring: Chatting with Vendor..." )
	if ( Player:IsConversationOpen() ) then
		local options = Player:GetConversationOptions()
		nextOption, entry  = next( options )
		local found = false
		while ( nextOption ~= nil ) do
			if( entry == GW2.CONVERSATIONOPTIONS.Shop ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Shop )
				found = true
				break
			elseif( entry == GW2.CONVERSATIONOPTIONS.KarmaShop ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.KarmaShop )
				found = true
				break
			end
			nextOption, entry  = next( options, nextOption )
		end

		if ( not found ) then
			nextOption, entry  = next( options )
			while ( nextOption ~=nil ) do
				if( entry == GW2.CONVERSATIONOPTIONS.Continue ) then
					Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
					found = true
					break
				elseif( entry == GW2.CONVERSATIONOPTIONS.Story ) then
					Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Story )
					found = true
					break
				end
				nextOption, entry  = next( options, nextOption )
			end
		end

		if ( not found ) then
			wt_debug( "Vendoring: can't handle vendor, please report back to the developers" )
			wt_debug( "Vendoring: vendoring disabled" )
			wt_global_information.HasVendor = false
		end

	end
end

------------------------------------------------------------------------------
-- Selling Items To Vendor Cause & Effect
local c_selltovendor = inheritsFrom( wt_cause )
local e_selltovendor = inheritsFrom( wt_effect )

function c_selltovendor:evaluate()
	if ( wt_core_state_vendoring.CurrentTargetID ~= nil and wt_core_state_vendoring.CurrentTargetID ~= 0 and Inventory:IsVendorOpened() and not wt_core_state_vendoring.junksold ) then
		return true
	end
	return false
end

e_selltovendor.throttle = math.random( 1000, 1500 )
e_selltovendor.delay = math.random( 500, 1500 )
function e_selltovendor:execute()	
	if ( Inventory:IsVendorOpened() ) then
		-- 1st Sell Weapons
		local tmpR = tonumber(gMaxItemSellRarity)		
		local sold = false		
		while ( tmpR > 0 and sold == false) do
			local sweapons = ItemList("itemtype=18,rarity="..tmpR)	
			id,item = next(sweapons)
			if (id ~=nil and item ~= nil ) then					
				wt_debug( "Vendoring: Selling Weapon... ")
				item:Sell()
				sold = true				
			end
			tmpR = tmpR - 1
		end
		
		-- 2nd Sell Armor
		if ( not sold ) then
			tmpR = tonumber(gMaxItemSellRarity)	
			while ( tmpR > 0 and sold == false) do
				local sarmor = ItemList("itemtype=0,rarity="..tmpR)					
				id,item = next(sarmor)
				if (id ~=nil and item ~= nil ) then					
					wt_debug( "Vendoring: Selling Armor... ")
					item:Sell()
					sold = true				
				end
				tmpR = tmpR - 1
			end		
		end		
		
		-- 3rd Sell Junk
		if ( not sold ) then
			wt_debug( "Vendoring: Selling Junk..." )
			Inventory:SellJunk()
			wt_core_state_vendoring.junksold = true
		end
	end
end


--/////////////////////////////////////////////////////
-- Sets our target for this state
function wt_core_state_vendoring.setTarget(CurrentTarget)
	if (CurrentTarget ~= nil and CurrentTarget ~= 0) then
		wt_core_state_vendoring.CurrentTargetID = CurrentTarget
	else
		wt_core_state_vendoring.CurrentTargetID = 0
	end
end

-------------------------------------------------------------

function wt_core_state_vendoring:initialize()

	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_vendoring:add( ke_died )

	local ke_aggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_vendoring:add( ke_aggro )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_vendoring:add( ke_rest )
	
	local ke_vendordone = wt_kelement:create( "VendorDone", c_vendordone, e_vendordone, 50 )
	wt_core_state_vendoring:add( ke_vendordone )
	
	local ke_movetovendor = wt_kelement:create( "MoveToVendor", c_movetovendorcheck, e_movetovendor, 45 )
	wt_core_state_vendoring:add( ke_movetovendor )

	local ke_openvendor = wt_kelement:create( "OpenVendor", c_openvendor, e_openvendor, 35 )
	wt_core_state_vendoring:add( ke_openvendor )
	
	local ke_doconversation = wt_kelement:create( "Conversation", c_conversation, e_conversation, 25 )
	wt_core_state_vendoring:add( ke_doconversation )
	
	local ke_selltovendor = wt_kelement:create( "SellItems", c_selltovendor, e_selltovendor, 15 )
	wt_core_state_vendoring:add( ke_selltovendor )
end

-- setup kelements for the state
wt_core_state_vendoring:initialize()
-- register the State with the system
wt_core_state_vendoring:register()
