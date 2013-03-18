-- The Repairing State
-- Walking towards nearest Merchant to repair our equippment

wt_core_state_repair = inheritsFrom( wt_core_state )
wt_core_state_repair.name = "Repairing"
wt_core_state_repair.kelement_list = { }
wt_core_state_repair.CurrentTargetID = 0
wt_core_state_repair.repaired = false

--/////////////////////////////////////////////////////
-- Vendoring over Check
local c_vendordoneR = inheritsFrom( wt_cause )
local e_vendordoneR = inheritsFrom( wt_effect )

function c_vendordoneR:evaluate()
	if ( wt_core_state_repair.CurrentTargetID == nil or wt_core_state_repair.CurrentTargetID == 0 or wt_core_state_repair.repaired or not IsEquipmentDamaged() ) then
		return true
	else
		local T = MapObjectList:Get( wt_core_state_repair.CurrentTargetID )
		if ( T == nil ) then
			-- Try to get the nearest merchant one more time, not sure if that is needed
			local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
			if ( TableSize( EList ) > 0 ) then
				local nextTarget
				nextTarget, E = next( EList )
				if ( nextTarget ~= nil and nextTarget ~= 0 ) then
					wt_core_state_repair.CurrentTargetID = nextTarget
					return false
				end
			end
			return true
		end
	end
	return false
end

function e_vendordoneR:execute()
	Player:ClearTarget()
	wt_debug( "Repairing finished" )
	wt_core_state_repair.CurrentTargetID = 0
	wt_core_controller.requestStateChange( wt_core_state_idle )
	return
end

--/////////////////////////////////////////////////////
-- Move To Repairvendor Check
local c_movetovendorcheckR = inheritsFrom( wt_cause )
local e_movetovendorR = inheritsFrom( wt_effect )
local e_moveto_d_indexR = nil -- debug index, no reason to print debug message over and over unless you are debugging it

function c_movetovendorcheckR:evaluate()
	if ( wt_core_state_repair.CurrentTargetID ~= nil and wt_core_state_repair.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get( wt_core_state_repair.CurrentTargetID )
		if ( T ~= nil and T.distance ~= nil )  then
			if ( T.distance > 100 ) then
				return true
			end
		else
			wt_core_state_repair.CurrentTargetID = nil
		end
	end
	return false
end

e_movetovendorR.throttle = 500
function e_movetovendorR:execute()
	if ( wt_core_state_repair.CurrentTargetID ~= nil and wt_core_state_repair.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get( wt_core_state_repair.CurrentTargetID )
		if ( T ~= nil ) then
			if ( e_moveto_d_indexR ~= wt_core_state_repair.CurrentTargetID ) then
				e_moveto_d_indexR = wt_core_state_repair.CurrentTargetID
				wt_debug( "Repair: moving to Vendor..." )
			end
			local TPOS = T.pos
			Player:MoveTo( TPOS.x, TPOS.y, TPOS.z ,50 )
		end
	else
		wt_core_state_repair.CurrentTargetID = nil
		wt_error( "Repair: No Merchant found oO" )
	end
end

--/////////////////////////////////////////////////////
-- Open Vendor Cause & Effect
local c_openvendorR = inheritsFrom( wt_cause )
local e_openvendorR = inheritsFrom( wt_effect )
function c_openvendorR:evaluate()
	if ( wt_core_state_repair.CurrentTargetID ~= nil and wt_core_state_repair.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get( wt_core_state_repair.CurrentTargetID )
		if ( T ~= nil and T.distance ~= nil )  then
			if ( T.distance <= 100 ) then
				local nearestID = Player:GetInteractableTarget()
				if ( nearestID ~= nil and T.characterID ~= nearestID ) then
					if ( Player:GetTarget() ~= T.characterID ) then
						wt_debug( "Repair: Selecting Vendor.. " )
						Player:SetTarget( T.characterID )
					end
				end
				if ( not Player:IsConversationOpen() ) then
					return true
				end
			end
		else
			wt_core_state_repair.CurrentTargetID = 0
		end
	end
	return false
end

e_openvendorR.throttle = math.random( 500, 2000 )
e_openvendorR.delay = math.random( 1000, 2500 )
e_openvendorR.switch = false
function e_openvendorR:execute()
	Player:StopMoving()
	wt_debug( "Repair: Opening Vendor.. " )
	if ( wt_core_state_repair.CurrentTargetID ~= nil and wt_core_state_repair.CurrentTargetID ~= 0 ) then
		local T = MapObjectList:Get( wt_core_state_repair.CurrentTargetID )
		if ( T ~= nil and T.characterID ~= nil and T.characterID ~= 0 and e_openvendorR.switch == false) then			
			Player:Interact( T.characterID )
			e_openvendorR.switch = true
			-- Tell all minions nearby to vendor
			if ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
				MultiBotSend( "16;0","gw2minion" )
			end	
		elseif ( T ~= nil and T.characterID ~= nil and T.characterID ~= 0 and e_openvendorR.switch == true) then			
			Player:Use( T.characterID )
			e_openvendorR.switch = false
			-- Tell all minions nearby to vendor
			if ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
				MultiBotSend( "16;0","gw2minion" )
			end	
		else
			wt_core_state_repair.CurrentTargetID = 0
		end
	end
end

------------------------------------------------------------------------------
-- Do Conversation with Vendor Cause & Effect
local c_conversationR = inheritsFrom( wt_cause )
local e_conversationR = inheritsFrom( wt_effect )

function c_conversationR:evaluate()
	if ( wt_core_state_repair.CurrentTargetID ~= nil and wt_core_state_repair.CurrentTargetID ~= 0 and Player:IsConversationOpen() and not wt_core_state_repair.repaired ) then
		return true
	end
	return false
end

e_conversationR.throttle = math.random( 1000, 2500 )
e_conversationR.delay = math.random( 1000, 2500 )
function e_conversationR:execute()
	wt_debug( "Repair: Chatting with Vendor..." )
	if ( Player:IsConversationOpen() ) then
		local options = Player:GetConversationOptions()
		nextOption, entry  = next( options )
		local found = false
		while ( nextOption ~= nil ) do
			if( entry == GW2.CONVERSATIONOPTIONS.Repair ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Repair )
				found = true
				break
			elseif( entry == GW2.CONVERSATIONOPTIONS.Continue ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
				found = true
				break
			elseif( entry == GW2.CONVERSATIONOPTIONS.Return ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Return )
				wt_core_state_repair.repaired = true
				found = true
				break
			end
			nextOption, entry  = next( options, nextOption )
		end

		if ( not found ) then
			wt_debug( "Repair: can't handle repairvendor, please report back to the developers" )
		end

	end
end

--/////////////////////////////////////////////////////
-- Sets our target for this state
function wt_core_state_repair.setTarget( CurrentTarget )
	if ( CurrentTarget ~= nil and CurrentTarget ~= 0 ) then
		wt_core_state_repair.CurrentTargetID = CurrentTarget
	else
		wt_core_state_repair.CurrentTargetID = 0
	end
end

function wt_core_state_repair:initialize()

	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_repair:add( ke_died )

	local ke_aggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_repair:add( ke_aggro )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_repair:add( ke_rest )

	local ke_vendordone = wt_kelement:create( "RepairDone", c_vendordoneR, e_vendordoneR, 50 )
	wt_core_state_repair:add( ke_vendordone )

	local ke_movetovendor = wt_kelement:create( "MoveToRepair", c_movetovendorcheckR, e_movetovendorR, 25 )
	wt_core_state_repair:add( ke_movetovendor )

	local ke_openvendor = wt_kelement:create( "OpenRepairVendor", c_openvendorR, e_openvendorR, 10 )
	wt_core_state_repair:add( ke_openvendor )

	local ke_doconversation = wt_kelement:create( "Conversation", c_conversationR, e_conversationR, 5 )
	wt_core_state_repair:add( ke_doconversation )

end

-- setup kelements for the state
wt_core_state_repair:initialize()
-- register the State with the system
wt_core_state_repair:register()
