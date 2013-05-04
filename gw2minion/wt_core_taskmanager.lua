-- Taskmanager

wt_core_taskmanager = { }
wt_core_taskmanager.current_task = nil
wt_core_taskmanager.last_task = nil
wt_core_taskmanager.Customtask_list = { }
wt_core_taskmanager.Customtask_history = {}
wt_core_taskmanager.CustomLuaFunctions = { }
wt_core_taskmanager.UpdateTaskListTmr = 0
wt_core_taskmanager.markerList = { }


-- Add new Tasks or refresh lifetime of existing Tasks
function wt_core_taskmanager:addCustomtask( task )
	if ( task ~= nil and  type( task ) == "table") then
		if (tostring(task.name) ~= "FarmSpot ") then
			--wt_debug( "Updated Task: " ..tostring(task.name).. "(UID: "..tostring(task.UID).." Prio: "..tostring(task.priority).." LifeTime: "..tostring(task.lifetime).."")
		end
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
		--wt_debug( "WARNING: No Marker Near Task-Objective found, check your NavMesh and add a Marker near each Waypoint,PoI and Heartquest to set the levelrange!" )
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
		
		-- If we had a default task before, try to continue that instead of choosing a new one
		if (highestPrioTask.priority <= 999 and wt_core_taskmanager.last_task ~= nil and highestPrioTask.priority <= wt_core_taskmanager.last_task.priority and not wt_core_taskmanager.last_task.isFinished() and not wt_core_taskmanager.last_task.expired() ) then
			if (gGW2MinionTask ~= nil ) then
				gGW2MinionTask = wt_core_taskmanager.last_task.name
			end
			wt_debug( "Resuming last Task: " ..tostring(wt_core_taskmanager.last_task.name).. "(UID: "..tostring(wt_core_taskmanager.last_task.UID).." Prio: "..tostring(wt_core_taskmanager.last_task.priority).." LifeTime: "..tostring(wt_core_taskmanager.last_task.lifetime).."")
			wt_core_taskmanager.current_task = wt_core_taskmanager.last_task
			wt_core_taskmanager.last_task = nil
			return
		end
		
		-- randomize selected task when it is a farmspot (aka lowest possible prio task )
		if ( highestPrioTask.priority == 400) then
			wt_core_taskmanager.possible_tasks = { }
			local i, task  = next( wt_core_taskmanager.Customtask_list )	
			while ( i ~= nil and task ~= nil) do			
				if ( task.priority == 400) then
					table.insert( wt_core_taskmanager.possible_tasks, task )
				end
				i, task  = next( wt_core_taskmanager.Customtask_list, i )
			end
			-- Select randomly a task from all remaining tasks in the list
			if ( #wt_core_taskmanager.possible_tasks > 0 ) then
				local newtask = wt_core_taskmanager.possible_tasks[ math.random( #wt_core_taskmanager.possible_tasks ) ]
				if (newtask ~= nil) then
					highestPrioTask = newtask
				end
			end
		end		
		
		if ( wt_core_taskmanager.current_task == nil or wt_core_taskmanager.current_task.priority < highestPrioTask.priority or wt_core_taskmanager.current_task.isFinished() or wt_core_taskmanager.current_task.expired()) then
			-- Save our current task if it is a default task
			if ( wt_core_taskmanager.current_task ~= nil and wt_core_taskmanager.current_task.priority <= 999 and not wt_core_taskmanager.current_task.isFinished() and not wt_core_taskmanager.current_task.expired() ) then
				wt_debug( "Saving last Task: " ..tostring(wt_core_taskmanager.current_task.name).. "(UID: "..tostring(wt_core_taskmanager.current_task.UID).." Prio: "..tostring(wt_core_taskmanager.current_task.priority).." LifeTime: "..tostring(wt_core_taskmanager.current_task.lifetime).."")
				wt_core_taskmanager.last_task = wt_core_taskmanager.current_task
			end
			-- Set new task
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
		
		-- CLEAN BLACKLIST, Kick out objects whose blacklist time rhas expired
		wt_core_taskmanager.CleanBlacklist()
		
		
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
				
				local MMList = MapMarkerList( "worldmarkertype=20" )
				if ( TableSize( MMList ) > 0 ) then
					i, entry = next( MMList )
					while ( i ~= nil and entry ~= nil ) do
						local etype = entry.type
						local mtype = entry.markertype
						
							-- Locked Waypoints
							if ( mtype==15 and etype == 36 and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									wt_core_taskmanager:addWaypointTask( entry )
								end
								
							-- Point Of Interest
							elseif( etype == 458 and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									wt_core_taskmanager:addPOITask( entry )
								end
							
							-- Unfinished HeartQuests
							elseif ( mtype==8 and (etype == 146 or etype == 143) and entry.onmesh) then
								local mPos = entry.pos
								if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
									local lastrun = wt_core_taskmanager.Customtask_history["HeartQuest"..tostring(math.floor(entry.pos.x))] or 0
									if ((wt_global_information.Now - lastrun) > 650000) then
										wt_core_taskmanager:addHeartQuestTask( entry )
									end
								end
								
							-- Events
							elseif ( gdoEvents == "1" and mtype==6 and entry.onmesh and entry.eventID ~= 0 and 
										wt_core_taskmanager.eventBlacklist[entry.eventID] == nil and 
										wt_core_taskmanager.userEventBlacklist[entry.eventID] == nil) 
							then
								local lastrun = wt_core_taskmanager.Customtask_history["Event"..tostring(entry.eventID)] or 0
								if ((wt_global_information.Now - lastrun) > 450000) then
									wt_core_taskmanager:addEventTask( i, entry , 4000)
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
						if ( distance > 1000 and marker.type == 0 and ( ( we.level >= marker.minlevel and we.level <= marker.maxlevel ) or gIgnoreMarkerCap == "1" ) ) then  --type 0 is farmspot						
							wt_core_taskmanager:addFarmSpotTask( marker )
						end
						j, marker = next( wt_core_taskmanager.markerList, j )
					end
				end
				
				-- if we have no task because the playerlevel is above the maplevel and the user forgot to check the ignore marker cap button:
				if ( TableSize(wt_core_taskmanager.Customtask_list) == 0 and gIgnoreMarkerCap == "0") then
					gIgnoreMarkerCap = "1"
				end
				if ( TableSize(wt_core_taskmanager.Customtask_list) == 0 and gIgnoreMarkerCap == "1") then
					wt_error("No Tasks availiable! Check your navmesh! You need more than 1 Red Marker!")
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
		-- last_task is holding the last normal task (prio 0-999), this is needed so the bot doesnt switch the direction after each kill		
		if ( wt_core_taskmanager.last_task ~= nil and not wt_core_taskmanager.last_task.isFinished() and not wt_core_taskmanager.last_task.expired() ) then
			if (gGW2MinionTask ~= nil ) then
				gGW2MinionTask = wt_core_taskmanager.last_task.name
			end
			wt_core_taskmanager.last_task.execute()
		else
			-- Try to get next task in the List	
			wt_core_taskmanager.CleanTasklist()
			wt_core_taskmanager.SelectNextTask()
		end
	end
end

function wt_core_taskmanager.ClearTasks()
	wt_core_taskmanager.current_task = nil
	wt_core_taskmanager.last_task = nil
	wt_core_taskmanager.Customtask_list = { }
	wt_core_taskmanager.Customtask_history = {}
	--wt_core_taskmanager.CustomLuaFunctions = { }
	wt_core_taskmanager.markerList = { }
	wt_debug("All Tasks cleared...")
end