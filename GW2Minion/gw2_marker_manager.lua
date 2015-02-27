gw2_marker_manager = {}
gw2_marker_manager.lastMarkerOfType = {}
gw2_marker_manager.tick = 0
gw2_marker_manager.markerinfo = {}
gw2_marker_manager.randompos = nil
function gw2_marker_manager.ModuleInit()
	local dw = WindowManager:GetWindow(gw2minion.DebugWindow.Name)
	if ( dw ) then
		dw:NewField("MarkerName","dbCurrentMarkerName",GetString("markers"))
		dw:NewField("MarkerType","dbMarkerType",GetString("markers"))
		dw:NewField("MarkerTime","dbCurrentMarkerTime",GetString("markers"))
		dw:NewField("MarkerTimeRemaining","dbCurrentMarkerTimeRemaining",GetString("markers"))
		dw:NewField("MarkerReached","dbCurrentMarkerReached",GetString("markers"))
		dw:NewField("MarkerReachedFirsttime","dbCurrentMarkerReachedFirst",GetString("markers"))
		dw:NewField("MarkerAllowedToFight","dbCurrentMarkerAllowedToFight",GetString("markers"))
		dw:NewField("MarkerDistance","dbMarkerDistance",GetString("markers"))
		dw:NewField("MarkerRange","dbMarkerRange",GetString("markers"))
	end
end

function gw2_marker_manager.OnUpdateHandler(Event, ticks)
	if (ticks - gw2_marker_manager.tick > 1000)  then
		gw2_marker_manager.DebugUpdate()

		gw2_marker_manager.tick = ticks
	end
end

function gw2_marker_manager.DebugUpdate()
	if ( ml_global_information.ShowDebug and gBotRunning == "1") then
		local task = gw2_marker_manager.GetPrimaryTask()

		dbCurrentMarkerTime = "novalue"
		dbCurrentMarkerName = "novalue"
		dbCurrentMarkerTimeRemaining = "novalue"
		dbCurrentMarkerReached = "novalue"
		dbCurrentMarkerReachedFirst = "novalue"
		dbMarkerDistance = "novalue"
		dbMarkerType = "novalue"
		dbMarkerRange = "novalue"
		dbCurrentMarkerAllowedToFight = "novalue"


		if(task ~= nil) then
			local marker = gw2_marker_manager.GetCurrentMarker()

			if(gw2_marker_manager.ValidMarker(false)) then
				if(gw2_marker_manager.GetTime(marker)) then
					dbCurrentMarkerTime = math.floor(TimeSince(gw2_marker_manager.GetTime(marker)) / 1000)
					dbCurrentMarkerTimeRemaining = math.floor(marker:GetTime() - dbCurrentMarkerTime)
				end

				local pos = marker:GetPosition()
				local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, pos.x, pos.y)
				dbMarkerDistance = math.floor(dist)
				dbCurrentMarkerName = marker:GetName()
				dbCurrentMarkerReached = tostring(gw2_marker_manager.GetMarkerInfo("markerreached"))
				dbCurrentMarkerReachedFirst = tostring(gw2_marker_manager.GetMarkerInfo("markerreachedfirsttime"))
				dbCurrentMarkerAllowedToFight = tostring(gw2_marker_manager.GetMarkerInfo("allowedtofight"))
				dbMarkerType = marker:GetType()
				dbMarkerRange = marker:GetFieldValue(GetString("maxRange"))
			end
		end
	end
end

function gw2_marker_manager.GetPrimaryTask()
	if(ml_task_mgr.GetCurrentTask() ~= nil) then
		return ml_task_mgr.GetCurrentTask()
	end

	if(TableSize(ml_task_hub.queues) > 0) then
		for i,j in pairs(ml_task_hub.queues) do
			if(j.rootTask ~= nil and j.rootTask ~= false and j.rootTask.name == gBotMode) then
				return j.rootTask
			end
		end
	end

	return nil
end

function gw2_marker_manager.GetCurrentMarker()
	return gw2_marker_manager.GetPrimaryTask().currentMarker or nil
end

function gw2_marker_manager.SetCurrentMarker(marker)
	gw2_marker_manager.GetPrimaryTask().currentMarker = marker
end

function gw2_marker_manager.GetMarkerInfo(key, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	if(marker ~= nil) then
		return gw2_marker_manager.markerinfo[marker:GetName()][key] or false
	end
end

function gw2_marker_manager.SetMarkerInfo(key, value, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	if(marker ~= nil) then
		gw2_marker_manager.markerinfo[marker:GetName()][key] = value
	end
end

function gw2_marker_manager.SetTime(time, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	time = time or ml_global_information.Now

	gw2_marker_manager.GetPrimaryTask().markerTime = time
	ml_global_information.MarkerTime = time
end

function gw2_marker_manager.GetTime(marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()

	return gw2_marker_manager.GetPrimaryTask().markerTime or ml_global_information.MarkerTime
end

function gw2_marker_manager.GetNextMarker(markerType, filterLevel)
	-- Reset manager marker
	ml_marker_mgr.currentMarker = gw2_marker_manager.lastMarkerOfType[markerType] or nil

	local marker = ml_marker_mgr.GetNextMarker(markerType, filterLevel)
	gw2_marker_manager.lastMarkerOfType[markerType] = marker

	if(marker ~= nil and gw2_marker_manager.markerinfo[marker:GetName()] == nil) then
		gw2_marker_manager.markerinfo[marker:GetName()] = marker
	end
	return marker
end

-- Try to get the next custom VendorMarker in our map where a vendor should be nearby, used by buy and sell task
function gw2_marker_manager.GetNextVendorMarker(oldmarker)

	local filterLevel = false
	local vendormarker = gw2_marker_manager.GetNextMarker(GetString("vendorMarker"), filterLevel)

	-- get a different marker
	if (vendormarker and oldmarker ~= nil and oldmarker:GetName() == vendormarker:GetName()) then
		vendormarker = gw2_marker_manager.GetNextMarker(GetString("vendorMarker"), filterLevel)
	end

	return vendormarker
end

function gw2_marker_manager.GetClosestVendorMarker(range)
	if(range == nil) then
		range = 30000
	end

	return ml_marker_mgr.GetClosestMarker( ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, ml_global_information.Player_Position.z, range, GetString("vendorMarker")) or nil
end

function gw2_marker_manager.MoveToMarker(cause, randomize, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	local maxRange = marker:GetFieldValue(GetString("maxRange")) or 250
	local markerRange = math.min(200, maxRange)
	local maxRadius = math.max(300, math.abs(maxRange*0.4))
	local markerpos = marker:GetPosition()
	local pos = nil
	local userandom = (randomize == true and cause.markerreachedfirsttime == true)

	-- Don't go back to the exact same spot every time
	if(userandom and gw2_marker_manager.randompos == nil) then
		pos = NavigationManager:GetRandomPointOnCircle(markerpos.x, markerpos.y, markerpos.z, markerRange, maxRadius)
		gw2_marker_manager.randompos = pos
	end

	if(gw2_marker_manager.randompos ~= nil) then
		pos = gw2_marker_manager.randompos
	end

	if(pos == nil) then
		pos = markerpos
		userandom = false
	end


	local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, pos.x, pos.y)

	-- Allow fighting when we are far away from the "outside radius of the marker" , else the bot goes back n forth spinning trying to reach the target outside n going back inside right after
	if (dist < maxRadius and cause.markerreachedfirsttime == true) then
		cause.allowedToFight = true
		gw2_marker_manager.SetMarkerInfo("allowedToFight", true)
	else
		cause.allowedToFight = false
		gw2_marker_manager.SetMarkerInfo("allowedToFight", false)
	end

	if  ((userandom and dist < maxRadius) or dist < markerRange) then
		Player:StopMovement()
		-- We reached our Marker
		cause.markerreached = true
		cause.markerreachedfirsttime = true
		cause.allowedToFight = false
		gw2_marker_manager.randompos = nil
		gw2_marker_manager.SetMarkerInfo("markerreached", true)
		gw2_marker_manager.SetMarkerInfo("allowedToFight", false)
		gw2_marker_manager.SetMarkerInfo("markerreachedfirsttime", true)

		d("Reached current Marker...")

		return ml_log(true)
	else
		-- We need to reach our Marker yet
		-- make sure the next marker is reachable & onmesh
		if ( ValidTable(NavigationManager:GetPath(ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z,pos.x,pos.y,pos.z))) then
			local markertime = TimeSince(gw2_marker_manager.GetTime())

			local newTask = gw2_task_moveto.Create()
			newTask.name = "MoveTo " .. marker:GetName() .. " (" .. marker:GetType() .. ")"
			newTask.targetPos = pos
			newTask.useWaypoint = true
			newTask.randomMovement = true

			newTask.onMoveToProcess = function()
				-- Pause the timer while moving to the marker
				gw2_marker_manager.SetTime(ml_global_information.Now - markertime)
			end

			newTask.terminateOnCustomCondition = function()
				local dist = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, pos.x, pos.y)

				if(cause.markerreachedfirsttime == true and ((userandom and dist < maxRadius) or dist < markerRange)) then
					d("We are inside the marker range again")
					if(ml_global_information.Player_InCombat and type(cause.allowedToFight) == "boolean") then
						cause.allowedToFight = true
					end

					return true
				end

				return false
			end

			gw2_marker_manager.GetPrimaryTask():AddSubTask(newTask)
			return ml_log(true)

		else
			d("WARNING: Cannot reach next Marker, trying to pick another one...")
			gw2_marker_manager.SetCurrentMarker(nil)
		end
	end

	return false
end

function gw2_marker_manager.ReturnToMarker(botmode, cause, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	local pos = marker:GetPosition()
	local distance = Distance2D(ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, pos.x, pos.y)

	if  (gw2_marker_manager.GetPrimaryTask() ~= nil and (botmode == nil or gBotMode == botmode or gw2_marker_manager.GetPrimaryTask().type == botmode) and distance > marker:GetFieldValue(GetString("maxRange"))) then
		d("We need to move back to our current Marker!")
		cause.markerreached = false
		cause.allowedToFight = false
		gw2_marker_manager.SetMarkerInfo("markerreached", false)
		gw2_marker_manager.SetMarkerInfo("allowedToFight", false)
		return true
	end

	return false
end

function gw2_marker_manager.CreateMarker(type, cause)
	local marker = gw2_marker_manager.GetNextMarker(type, gw2_marker_manager.GetPrimaryTask().filterLevel)

	-- disable the levelfilter in case we didnt find any other marker
	if (gw2_marker_manager.ValidMarker(type, marker) == false) then
		marker = gw2_marker_manager.GetNextMarker(type, false)
	end

	if (gw2_marker_manager.ValidMarker(type, marker)) then
		d("New " .. marker:GetType() .. " set!")
		gw2_marker_manager.GetPrimaryTask().markerTime = ml_global_information.Now -- Are BOTH needed to get updated ?
		ml_global_information.MarkerTime = ml_global_information.Now     -- This needs to be global else we cannot access the stuff in parent or subtasks
		ml_global_information.MarkerMinLevel = marker:GetMinLevel()
		ml_global_information.MarkerMaxLevel = marker:GetMaxLevel()
		cause.markerreached = false
		cause.markerreachedfirsttime = false
		gw2_marker_manager.SetMarkerInfo("markerreached", false)
		gw2_marker_manager.SetMarkerInfo("markerreachedfirsttime", false)
	end

	return marker
end

function gw2_marker_manager.CanFightToMarker(cause, markermode)
	local maxtick = cause.maxtick or math.random(10, 30)
	if ( cause.markerreached == false and cause.allowedToFight == true) then
		local target = gw2_common_functions.GetBestCharacterTarget( 1250 ) -- maxrange 2000 where enemies should be searched for
		if ( target  and (gw2_marker_manager.ValidMarker(markermode)
				and gw2_marker_manager.MarkerExpired(markermode) == false and cause.tick < maxtick)) then
			cause.target = target
			return ml_global_information.Player_SwimState == GW2.SWIMSTATE.NotInWater and cause.target ~= nil
		end
	end

	cause.target = nil
	cause.tick = 0
	cause.maxtick = maxtick
	return false
end

function gw2_marker_manager.FightToMarker(cause, markermode)
	if (cause.target ~= nil) then
		Player:StopMovement()
		local newTask = gw2_task_combat.Create()
		newTask.targetID = c_FightToGatherMarker.target.id
		ml_task_hub:Add(newTask.Create(), IMMEDIATE_GOAL, TP_IMMEDIATE)
		cause.target = nil
		cause.tick = cause.tick + 1
	else
		ml_log("gw2_marker_manager.FightToMarker found no target")
	end

	return ml_log(false)
end

function gw2_marker_manager.MarkerExpired(markerType, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	return gw2_marker_manager.GetPrimaryTask() ~= nil and gw2_marker_manager.ValidMarker(markerType, marker) and marker:GetTime() and marker:GetTime() ~= 0 and TimeSince(gw2_marker_manager.GetTime()) > marker:GetTime() * 1000
end

function gw2_marker_manager.MarkerInLevelRange(markerType, marker)
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	return gw2_marker_manager.GetPrimaryTask() ~= nil and gw2_marker_manager.ValidMarker(markerType, marker) and gw2_marker_manager.GetPrimaryTask().filterLevel and marker:GetMinLevel() and marker:GetMaxLevel() and (ml_global_information.Player_Level < marker:GetMinLevel() or ml_global_information.Player_Level > marker:GetMaxLevel())
end

function gw2_marker_manager.ValidMarker(markerType, marker)
	markerType = markerType or nil
	marker = marker or gw2_marker_manager.GetCurrentMarker()
	return (gw2_marker_manager.GetPrimaryTask() ~= nil and marker ~= nil and marker ~= false and (markerType == nil or marker:GetType() == markerType))
end

function gw2_marker_manager.MarkerMode(botmode)
	return (botmode == nil or gBotMode == botmode or gw2_marker_manager.GetPrimaryTask().type == botmode)
end

RegisterEventHandler("Module.Initalize",gw2_marker_manager.ModuleInit)
RegisterEventHandler("Gameloop.Update",gw2_marker_manager.OnUpdateHandler)