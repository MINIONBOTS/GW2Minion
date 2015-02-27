-- Moveto task & Follow task
-- For navigating to further away targets or points, do not use this for short range combat navigation, it will be slow, very slow
-- This task should handle movement, antistuck and do basic things to handle stucks, we'll see how it develops
gw2_task_moveto = inheritsFrom(ml_task)
gw2_task_moveto.name = "MoveTo"

function gw2_task_moveto.Create()
	local newinst = inheritsFrom(gw2_task_moveto)

    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}

	newinst.targetPos = nil -- set this when creating the task
	newinst.targetID = nil -- this is optional, will be used to update the targetPos
	newinst.targetType = nil -- SET THIS if targetID should be checked! Valid options: "character" , "gadget", "event"
	newinst.targetRadius = 25
	newinst.stoppingDistance = 25
	newinst.use3d = true

	newinst.useWaypoint = false -- [OPTIONAL] set this when creating the task to use waypoints if closer.
	newinst.followNavSystem = false
	newinst.randomMovement = false
	newinst.alwaysRandomMovement = false
	newinst.smoothTurns = true

	newinst.terminateOnDeath = true
	newinst.terminateInCombat = false
	newinst.terminateOnPlayerHPBelowPercent = 0
	newinst.terminateOnCustomCondition = function()
		return false
	end

	newinst.FailedNavAttemptsCounter = 0

	newinst.onMoveToProcess = function()

	end

	newinst.buffTmr = 0
    return newinst
end

function gw2_task_moveto:Process()

	-- terminate condition check
	if ( ml_task_hub:CurrentTask().terminateOnDeath and not ml_global_information.Player_Alive ) then ml_log("Terminate MoveTo because Player is dead!") ml_task_hub:CurrentTask().completed = true Player:StopMovement() end
	if ( ml_task_hub:CurrentTask().terminateInCombat and ml_global_information.Player_InCombat ) then ml_log("Terminate MoveTo because InCombat!") ml_task_hub:CurrentTask().completed = true Player:StopMovement() end
	if ( ml_task_hub:CurrentTask().terminateOnPlayerHPBelowPercent > 0 and ml_global_information.Player_Health < ml_task_hub:CurrentTask().terminateOnPlayerHPBelowPercent ) then ml_log("Terminate MoveTo because PlayerHP low!") ml_task_hub:CurrentTask().completed = true Player:StopMovement() end
	if (type(ml_task_hub:CurrentTask().terminateOnCustomCondition) == "function" and ml_task_hub:CurrentTask().terminateOnCustomCondition() ) then ml_log("Terminate MoveTo because the custom terminate function returned true!") ml_task_hub:CurrentTask().completed = true Player:StopMovement() end

	if ( ValidTable(ml_task_hub:CurrentTask().targetPos) ) then

		local dist = nil
		if ( not ml_task_hub:CurrentTask().use3d ) then
			dist = Distance2D(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_global_information.Player_Position.x,ml_global_information.Player_Position.y)
		else
			dist = Distance3D(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z)
		end

		-- Check for valid targetID only when in <2500 range, because gamedata tends to fade at distances. Update data in case it finds the target.
		if ( dist < 3500 ) then

			if ( ml_task_hub:CurrentTask().targetID ) then

				if ( ml_task_hub:CurrentTask().targetType == "character" ) then
					local character = CharacterList:Get(ml_task_hub:CurrentTask().targetID)
					if ( character ~= nil and character.onmesh) then
						ml_task_hub:CurrentTask().targetPos = character.pos

					else
						d("MoveTo:Update Characterdata failed, no character with targetID found!")
						ml_task_hub:CurrentTask().completed = true
					end

				elseif ( ml_task_hub:CurrentTask().targetType == "gadget" ) then

					local gadget = GadgetList:Get(ml_task_hub:CurrentTask().targetID)
					if ( gadget ~= nil and gadget.onmesh) then
						ml_task_hub:CurrentTask().targetPos = gadget.pos

					else
						d("MoveTo:Update Gadgetdata failed, no gadget with targetID found!")
						ml_task_hub:CurrentTask().completed = true
					end

				elseif ( ml_task_hub:CurrentTask().targetType == "event" ) then

					local eID = tonumber(ml_task_hub:CurrentTask().targetID) or 0
					local evList = MapMarkerList("nearest,onmesh,eventID="..eID..",exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
					if ( evList ) then
						local i,event = next(evList)
						if ( i and event ) then
							ml_task_hub:CurrentTask().targetPos = event.pos
						end
					else
						d("MoveTo:Update Eventdata failed, no event with targetID found!")
						ml_task_hub:CurrentTask().completed = true
					end
				end
			end
			-- check for closest point on mesh to compensate for 3D vs mesh differences

		end


		if ( dist <= ml_task_hub:CurrentTask().stoppingDistance + ml_task_hub:CurrentTask().targetRadius ) then
			ml_task_hub:CurrentTask().completed = true
		else

			-- Waypoint Usage
			if (ml_task_hub:CurrentTask().useWaypoint == true and ml_global_information.Player_InCombat == false and Player.healthstate == GW2.HEALTHSTATE.Alive and dist > 15000 and Player:GetWalletEntry(1) > 500) then
				local waypoint = gw2_common_functions.GetClosestWaypointToPos(ml_global_information.CurrentMapID,ml_task_hub:CurrentTask().targetPos)
				if (ValidTable(waypoint)) then
					local wDist = Distance2D(waypoint.pos.x,waypoint.pos.y,ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y)
					if (wDist < (dist/2)) then
						Player:TeleportToWaypoint(waypoint.id)
						ml_global_information.Wait(5000)
						ml_task_hub:CurrentTask().useWaypoint = false
						return ml_log(true)
					end
				end
				ml_task_hub:CurrentTask().useWaypoint = false
			end

			-- HandleStuck
			if ( not gw2_unstuck.HandleStuck() ) then

				-- randomize the randomized movement (lol)
				local randommovement = ml_task_hub:CurrentTask().randomMovement == true
				if ( randommovement and not ml_task_hub:CurrentTask().alwaysRandomMovement and math.random(1,2) == 1) then
					randommovement = false
				end
				local newnodecount = Player:MoveTo(ml_task_hub:CurrentTask().targetPos.x,ml_task_hub:CurrentTask().targetPos.y,ml_task_hub:CurrentTask().targetPos.z,ml_task_hub:CurrentTask().stoppingDistance+ml_task_hub:CurrentTask().targetRadius,ml_task_hub:CurrentTask().followNavSystem,randommovement,ml_task_hub:CurrentTask().smoothTurns)

				if ( ml_global_information.ShowDebug and newnodecount ~= dbPNodes ) then
					dbPNodesLast = dbPNodes
					dbPNodes = newnodecount
				end
				-- Check for increased node count when the targetpos is the same to prevent back n forth twisting and stuck


				-- Errorhandling
				if ( newnodecount < 0 ) then
				--[[
				-1 : Startpoint not on navmesh
				-2 : Endpoint not on navmesh
				-3 : No path between start and endpoint found
				-4 : Path between start and endpoint has a lenght of 0
				-5 : No path between start and endpoint found
				-6 : Couldn't find a path
				-7 : Distance Playerpos-Targetpos < stoppingthreshold
				-8 : NavMesh is not ready/loaded
				-9 : Player object not valid
				-10 : Moveto coordinates are crap
				]]

					if ( newnodecount == -1 ) then
						ml_error(" -1: Player not on navmesh")
						-- try to get to the closest point on the navmesh first
						-- NavigationManager:GetPointToMeshDistance(x,y,z)
						-- NavigationManager:GetClosestPointOnMesh(x,y,z)
					elseif ( newnodecount == -2 ) then
						ml_error(" -2: Endpoint not on navmesh")
						-- try to get instead to the closest point near the endpoint on the navmesh
						-- NavigationManager:GetPointToMeshDistance(x,y,z)
						-- NavigationManager:GetClosestPointOnMesh(x,y,z)
					elseif ( newnodecount == -7 ) then
						ml_error(" -7: Distance Playerpos-Targetpos < stoppingthreshold")
						-- try to lower the targetRadius & stoppingDistance
						if ( ml_task_hub:CurrentTask().targetRadius > 0 ) then
							ml_task_hub:CurrentTask().targetRadius = 0

						elseif ( ml_task_hub:CurrentTask().targetRadius == 0 and ml_task_hub:CurrentTask().stoppingDistance > 0 ) then
							ml_task_hub:CurrentTask().stoppingDistance = 10

						elseif ( ml_task_hub:CurrentTask().targetRadius == 0 and ml_task_hub:CurrentTask().stoppingDistance <= 10 ) then
							ml_log("gw2_task_moveto: Distance Playerpos-Targetpos < stoppingthreshold : "..tostring(newnodecount))
							ml_task_hub:CurrentTask().completed = true
						end
					else
						d("No Valid Path Found, Result: "..tostring(newnodecount).." To:"..tostring(math.floor(ml_task_hub:CurrentTask().targetPos.x)).."/"..tostring(math.floor(ml_task_hub:CurrentTask().targetPos.y)).."/"..tostring(math.floor(ml_task_hub:CurrentTask().targetPos.z)))
						ml_log("gw2_task_moveto: No Valid Path : "..tostring(newnodecount))
						--ml_task_hub:CurrentTask().completed = true

					end

					ml_task_hub:CurrentTask().FailedNavAttemptsCounter = ml_task_hub:CurrentTask().FailedNavAttemptsCounter + 10

					if ( ml_task_hub:CurrentTask().FailedNavAttemptsCounter > 10 ) then
						d("10 x No Valid Path Found, terminating moveto task")
						ml_task_hub:CurrentTask().completed = true
					end

				else
					if(type(ml_task_hub:CurrentTask().onMoveToProcess) == "function") then
						ml_task_hub:CurrentTask().onMoveToProcess()
					end

					ml_task_hub:CurrentTask().FailedNavAttemptsCounter = 0
					ml_log(true)
				end
			end
		end

		if ( ml_global_information.ShowDebug ) then
			dbTPos = (math.floor(ml_task_hub:CurrentTask().targetPos.x * 10) / 10).." / "..(math.floor(ml_task_hub:CurrentTask().targetPos.y * 10) / 10).." / "..(math.floor(ml_task_hub:CurrentTask().targetPos.z * 10) / 10)
			dbTDist = dist
			dbPStopDist = ml_task_hub:CurrentTask().stoppingDistance
			dbTID = tostring(ml_task_hub:CurrentTask().targetID)
			dbStuckCount = gw2_unstuck.stuckCount
			dbStuckTmr = TimeSince(gw2_unstuck.stuckTimer)
			dbJumpCount = gw2_unstuck.jumpCount
			dbLastOnMesh = TimeSince(gw2_unstuck.lastOnMeshTime)
			if ( ValidTable(gw2_unstuck.stuckRandomPos) ) then
				dbStuckRPos = (math.floor(gw2_unstuck.stuckRandomPos.x * 10) / 10).." / "..(math.floor(gw2_unstuck.stuckRandomPos.y * 10) / 10).." / "..(math.floor(gw2_unstuck.stuckRandomPos.z * 10) / 10)
			else
				dbStuckRPos = "0/0/0"
			end
		end


	else
		ml_log("gw2_task_moveto: No Valid targetPos!")
		ml_task_hub:CurrentTask().completed = true
	end

	-- Blocked by gadget check
	-- Water check
	-- Stuck check

end

function gw2_task_moveto.ModuleInit()
	ml_task_mgr.AddTaskType(GetString("taskMoveTo"), gw2_task_moveto) -- Allow this task to be selectable in TaskManager
end

-- TaskManager functions
function gw2_task_moveto:UIInit_TM()
	ml_task_mgr.NewCheckBox(GetString("useWaypoint"), "useWaypoint", "1")
	ml_task_mgr.NewCheckBox(GetString("randomPaths"), "randomMovement", "0")
	ml_task_mgr.NewCheckBox(GetString("taskSmoothTurn"), "smoothTurns", "1")
	ml_task_mgr.NewCheckBox(GetString("taskRandomPos"), "randomTargetPosition", "0")
end
-- TaskManager function: Checks for custom conditions to start this task
function gw2_task_moveto.CanTaskStart_TM()
	return true
end
-- TaskManager function: Checks for custom conditions to keep this task running
function gw2_task_moveto.CanTaskRun_TM()

	return true
end

RegisterEventHandler("Module.Initalize",gw2_task_moveto.ModuleInit)