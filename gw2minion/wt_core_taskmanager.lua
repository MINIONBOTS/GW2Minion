-- Taskmanager

wt_core_taskmanager = { }
wt_core_taskmanager.current_task = nil
wt_core_taskmanager.Customtask_list = { }
wt_core_taskmanager.Customtask_history = {}
wt_core_taskmanager.CustomLuaFunctions = { }
wt_core_taskmanager.UpdateTaskListTmr = 0
wt_core_taskmanager.markerList = { }


-- Add new Tasks or refresh lifetime of existing Tasks
function wt_core_taskmanager:addCustomtask( task )
	if ( task ~= nil and  type( task ) == "table") then	
		--wt_debug( "Updated Task: " ..tostring(task.name).. "(UID: "..tostring(task.UID).." Prio: "..tostring(task.priority).." LifeTime: "..tostring(task.lifetime).."")
		if (wt_core_taskmanager.Customtask_list[task.UID] == nil or wt_core_taskmanager.Customtask_list[task.UID].lifetime < task.lifetime or wt_core_taskmanager.Customtask_list[task.UID].priority < task.priority) then
			wt_core_taskmanager.Customtask_list[task.UID] = task
		end
	end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- checks if a point on the worldmap is in levelrange of the player by trying to utilize the min/maxlevel of nearby placed Markers
-- ********TODO: make a lua list with markerdata, update the list with GameLoop.MapChanged Event only once after a new map has been loaded!********
function wt_core_taskmanager:checkLevelRange( posX, posY, posZ )
	local we = Player

	if ( wt_core_taskmanager.markerList ~= nil and we ~= nil and posX ~= 0 and posY ~= 0 and posZ ~= 0 ) then
		if ( gIgnoreMarkerCap == "1") then
			return true
		end
		j, marker = next( wt_core_taskmanager.markerList )
		while ( j ~= nil and marker ~= nil ) do			
			distance =  Distance3D( marker.x, marker.y, marker.z, posX, posY, posZ )
			--wt_debug( "Dist to marker : " .. distance )
			if ( distance <= 10000 ) then
				if ( we.level >= marker.minlevel and we.level <= marker.maxlevel ) then
					return true
				end
			end
			j, marker = next( wt_core_taskmanager.markerList, j )
		end
		wt_debug( "WARNING: No Marker nearby found, check your NavMesh and add a Marker Nearby to set the levelrange!" )
	end
	return false
end


-- Selects the next task from our Customtask_list
function wt_core_taskmanager.SelectNextTask()
	local highestPriority = 0
	local highestPrioTask = nil
	local i, task  = next( wt_core_taskmanager.Customtask_list )
	while ( i ~= nil and task ~= nil) do			
		if ( highestPriority < task.priority ) then
			highestPriority = task.priority
			highestPrioTask = task
		end
		i, task  = next( wt_core_taskmanager.Customtask_list, i )
	end
	
	if ( highestPrioTask ~= nil ) then
		if ( wt_core_taskmanager.current_task == nil or wt_core_taskmanager.current_task.priority < highestPrioTask.priority or wt_core_taskmanager.current_task.isFinished() or wt_core_taskmanager.current_task.expired()) then
			wt_core_taskmanager.current_task = highestPrioTask
			wt_debug( "New Task selected: " ..tostring(highestPrioTask.name).. "(UID: "..tostring(highestPrioTask.UID).." Prio: "..tostring(highestPrioTask.priority).." LifeTime: "..tostring(highestPrioTask.lifetime).."")
		end
	else
		gGW2MinionTask = "None"
		wt_core_taskmanager.current_task = nil
	end	
end


--Kick out finished and expired Tasks
function wt_core_taskmanager.CleanTasklist()
	local i, task  = next( wt_core_taskmanager.Customtask_list )
	while ( i ~= nil and task ~= nil) do			
		if ( task:isFinished() or task:expired() ) then
			wt_debug( "Removing Task: " ..tostring(task.name).. " (UID: "..tostring(task.UID).." Prio: "..tostring(task.priority).." LifeTime: "..tostring(task.lifetime).."")
			wt_core_taskmanager.Customtask_list[i] = nil
		end
		i, task  = next( wt_core_taskmanager.Customtask_list, i )
	end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function wt_core_taskmanager:Update_Tasks( )
	if (wt_core_taskmanager.UpdateTaskListTmr == 0 or wt_global_information.Now - wt_core_taskmanager.UpdateTaskListTmr > 1000) then
		wt_core_taskmanager.UpdateTaskListTmr = 0
				
		-- CLEAN TASKLIST, Kick out finished and expired Tasks
		wt_core_taskmanager.CleanTasklist()
		
		
		-- ADD NEW TASKS & Refresh existing Tasks
			-- Add Zone specific Tasks		
		--TODO: See if it makes sense to queue up CustomTasks for the minions too:
		wt_core_taskmanager.AddCustomTasks()
			
			if (gMinionEnabled == "0" or (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1)) then
				-- Add all default Tasks			
				-- Updating Red-MarkerList-data if needed
				if ( wt_core_taskmanager.markerList == nil or TableSize( wt_core_taskmanager.markerList ) == 0 or MarkersNeedUpdate() ) then				
					wt_core_taskmanager.markerList = MarkerList()
				end
				
				local MMList = MapMarkerList( "" )
				if ( TableSize( MMList ) > 0 ) then
					i, entry = next( MMList )
					while ( i ~= nil and entry ~= nil ) do
						local etype = entry.type
						local mtype = entry.markertype
						local wtype = entry.worldmarkertype
						if ( wtype == 20) then -- 20 means it is in our zone	
						
							-- Locked Waypoints
							if ( mtype==14 and etype == 30 and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									wt_core_taskmanager:addWaypointTask( entry )
								end
								
							-- Point Of Interest
							elseif( etype == 452 and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									wt_core_taskmanager:addPOITask( entry )
								end
							
							-- Unfinished HeartQuests
							elseif ( mtype==7 and (etype == 137 or etype == 140) and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									local lastrun = wt_core_taskmanager.Customtask_history["HeartQuest"..tostring(math.floor(entry.pos.x))] or 0
									if ((wt_global_information.Now - lastrun) > 650000) then
										wt_core_taskmanager:addHeartQuestTask( entry )
									end
								end
								
							-- Events
							elseif ( mtype==5 and entry.onmesh and entry.eventID ~= 0) then
								local lastrun = wt_core_taskmanager.Customtask_history["Event"..tostring(entry.eventID)] or 0
								if ((wt_global_information.Now - lastrun) > 450000) then
									wt_core_taskmanager:addEventTask( i, entry , 1200)
								end						
							end
						end
						i, entry = next( MMList, i )
					end
				end
				
				-- Red Markers as Farmspot
				if ( wt_core_taskmanager.markerList ~= nil ) then
					local we = Player
					j, marker = next( wt_core_taskmanager.markerList )
					while ( j ~= nil and marker ~= nil ) do
						local myPos = we.pos
						distance =  Distance3D( marker.x, marker.y, marker.z, myPos.x, myPos.y, myPos.z )
						if ( distance > 500 and marker.type == 0 and ( ( we.level >= marker.minlevel and we.level <= marker.maxlevel ) or gIgnoreMarkerCap == "1" ) ) then  --type 0 is farmspot						
							wt_core_taskmanager:addFarmSpotTask( marker )
						end
						j, marker = next( wt_core_taskmanager.markerList, j )
					end
				end
				
				-- if we have no task because the playerlevel is above the maplevel and the user forgot to check the ignore marker cap button:
				if ( TableSize(wt_core_taskmanager.Customtask_list) == 0 and gIgnoreMarkerCap == "0") then
					gIgnoreMarkerCap = "1"
				end
			end
		
		-- Pick Task with highest Prio
		wt_core_taskmanager.SelectNextTask()
	end	
	
	
	--wt_debug( "TasksInList : " .. TableSize( wt_core_taskmanager.Customtask_list))
	--[[--------------------OLD:
	-- Add Search and Kill enemies
	if (Player:GetLocalMapID() ~= 33) then -- dont do this in dungeons
		wt_core_taskmanager:addSearchAndKillTask(  )
	end	
]]	
end




function wt_core_taskmanager.AddCustomTasks()
-- This function adds custom tasks to the wt_core_taskmanager.Customtask_list, for dungeons and map specific tasks
-- Add functions from your own code to the wt_core_taskmanager.CustomLuaFunctions table, these will be called and should in return fill the 
-- wt_core_taskmanager.Customtask_list with tasks that have to be executed	
	for k, func in pairs( wt_core_taskmanager.CustomLuaFunctions ) do
		if ( func ~= nil and  type( func ) == "function" ) then			
			func()			
		end
	end
end


function wt_core_taskmanager:DoTask( )
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and not wt_core_taskmanager.current_task.expired() ) then
		if (gGW2MinionTask ~= nil ) then
			gGW2MinionTask = wt_core_taskmanager.current_task.name
		end
		wt_core_taskmanager.current_task.execute()
	else
		-- Try to get next task in the List, to speed up the fighting (redudant code ahoi!)	
		wt_core_taskmanager.CleanTasklist()
		wt_core_taskmanager.SelectNextTask()
	end
end
