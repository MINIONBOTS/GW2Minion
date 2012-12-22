-- Gathering for all professions

wt_core_state_gathering = inheritsFrom( wt_core_state )
wt_core_state_gathering.name = "Gathering"
wt_core_state_gathering.kelement_list = { }
wt_core_state_gathering.CurrentTargetID = 0

--/////////////////////////////////////////////////////
-- Gathering over Check
local c_Gathering_over = inheritsFrom( wt_cause )
local e_Gathering_over = inheritsFrom( wt_effect )

function c_Gathering_over:evaluate()
	--local CurrentTarget = Player:GetTarget()
	if ( wt_core_state_gathering.CurrentTargetID == nil or wt_core_state_gathering.CurrentTargetID == 0 ) then
		return true
	else
		local T = GadgetList:Get( wt_core_state_gathering.CurrentTargetID )
		if ( T == nil or not T.gatherable ) then
			return true
		end
	end
	return false
end

function e_Gathering_over:execute()
	Player:StopMoving()
	Player:ClearTarget()
	wt_debug( "Gathering finished" )
	wt_core_state_gathering.CurrentTargetID = 0
	wt_core_controller.requestStateChange( wt_core_state_idle )
	return
end

--/////////////////////////////////////////////////////
-- Move To Check
local c_movetogatherable = inheritsFrom( wt_cause )
local e_movetogatherable = inheritsFrom( wt_effect )
local e_gather_d_index = nil -- debug index, no reason to print debug message over and over unless you are debugging it

function c_movetogatherable:evaluate()
	if ( wt_core_state_gathering.CurrentTargetID ~= nil and wt_core_state_gathering.CurrentTargetID ~= 0 ) then
		local T = GadgetList:Get( wt_core_state_gathering.CurrentTargetID )
		if ( T ~= nil ) then
			if ( T.distance > 100 ) then
				return true
			end
		end
	end
	return false
end

e_movetogatherable.throttle = 500
function e_movetogatherable:execute()
	if ( wt_core_state_gathering.CurrentTargetID ~= nil and wt_core_state_gathering.CurrentTargetID ~= 0 ) then
		local T = GadgetList:Get( wt_core_state_gathering.CurrentTargetID )
		if ( T ~= nil ) then
			if ( e_gather_d_index ~= wt_core_state_gathering.CurrentTargetID ) then
				e_gather_d_index = wt_core_state_gathering.CurrentTargetID
				wt_debug( string.format( "Gather: moving to gatherable...%u", T.distance ) )
			end
			local TPOS = T.pos
			Player:MoveTo( TPOS.x, TPOS.y, TPOS.z ,50 )
		end
	else
		wt_core_state_gathering.CurrentTargetID = nil
		wt_error( "Gather: No Target to gather" )
	end
end

--/////////////////////////////////////////////////////
-- Gathering Check
local c_gather = inheritsFrom( wt_cause )
local e_gather = inheritsFrom( wt_effect )

function c_gather:evaluate()
	if ( wt_core_state_gathering.CurrentTargetID ~= nil and wt_core_state_gathering.CurrentTargetID ~= 0 ) then
		local T = GadgetList:Get( wt_core_state_gathering.CurrentTargetID )
		if ( T ~= nil ) then
			if ( T.distance <= 100 ) then
				local nearestID = Player:GetInteractableTarget()
				if ( nearestID ~= nil and wt_core_state_gathering.CurrentTargetID ~= nearestID ) then
					if ( Player:GetTarget() ~= wt_core_state_gathering.CurrentTargetID ) then
						Player:SetTarget( wt_core_state_gathering.CurrentTargetID )
					end
				end
				return true
			end
		end
	end
	return false
end

e_gather.throttle = 200
function e_gather:execute()
	Player:StopMoving()
	if ( wt_core_state_gathering.CurrentTargetID ~= nil and wt_core_state_gathering.CurrentTargetID ~= 0 ) then
		local T = GadgetList:Get( wt_core_state_gathering.CurrentTargetID )
		if ( T ~= nil and T.gatherable ) then
			if ( e_gather_d_index ~= wt_core_state_gathering.CurrentTargetID ) then
				e_gather_d_index = wt_core_state_gathering.CurrentTargetID
				wt_debug( "Gather: gathering..." ..wt_core_state_gathering.CurrentTargetID )
			end
			if ( Player:GetCurrentlyCastedSpell() == 17 ) then
				--wt_debug( "Picking up "..wt_core_state_gathering.CurrentTargetID)
				Player:Use( wt_core_state_gathering.CurrentTargetID )
			end
			return
		end
	end
	wt_core_state_gathering.CurrentTargetID = nil
	wt_error( "Idle: No Target to gather" )
end

--/////////////////////////////////////////////////////
-- Sets our target for this Gatheringstate
function wt_core_state_gathering.setTarget( CurrentTarget )
	if ( CurrentTarget ~= nil and CurrentTarget ~= 0 ) then
		wt_core_state_gathering.CurrentTargetID = CurrentTarget
	else
		wt_core_state_gathering.CurrentTargetID = 0
	end
end

--/////////////////////////////////////////////////////
function wt_core_state_gathering:initialize()

	local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
	wt_core_state_gathering:add( ke_died )

	local ke_aggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
	wt_core_state_gathering:add( ke_aggro )

	local ke_rest = wt_kelement:create( "Rest", c_rest, e_rest, 75 )
	wt_core_state_gathering:add( ke_rest )

	local ke_Gathering_over = wt_kelement:create( "Gathering_over", c_Gathering_over, e_Gathering_over, 50 )
	wt_core_state_gathering:add( ke_Gathering_over )

	local ke_movetogatherable = wt_kelement:create( "MoveToGatherable", c_movetogatherable, e_movetogatherable, 25 )
	wt_core_state_gathering:add( ke_movetogatherable )

	local ke_gather = wt_kelement:create( "Gathering", c_gather, e_gather, 5 )
	wt_core_state_gathering:add( ke_gather )

end

-- setup kelements for the state
wt_core_state_gathering:initialize()
-- register the State with the system
wt_core_state_gathering:register()
