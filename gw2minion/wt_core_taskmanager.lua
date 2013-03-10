-- Taskmanager

wt_core_taskmanager = { }
wt_core_taskmanager.task_list = { }
wt_core_taskmanager.possible_tasks = { }
wt_core_taskmanager.current_task = nil
wt_core_taskmanager.Partytask_list = { }
wt_core_taskmanager.Customtask_list = { }
wt_core_taskmanager.CustomLuaFunctions = { }  -- Add the functions that fill the Customtask_list with your tasks to this table!
wt_core_taskmanager.markerList = { }
wt_core_taskmanager.behavior = "default"
wt_core_taskmanager.prioTmr = 0

-- To add a new task
function wt_core_taskmanager:addTask( task )
	if ( task ~= nil and  type( task ) == "table") then	
		--wt_debug( "Adding Task to List: " .. task.name .. "(Prio:"..task.priority..")" )
		table.insert( wt_core_taskmanager.task_list, task )
	end
end

-- To add a new party task
function wt_core_taskmanager:addPartytask( task )
	if ( task ~= nil and  type( task ) == "table") then	
		wt_debug( "Adding PartyTask to List: " .. task.name .. "(Prio:"..task.priority..")" )
		table.insert( wt_core_taskmanager.Partytask_list, task )
	end
end

-- To add a new custom task
function wt_core_taskmanager:addCustomtask( task )
	if ( task ~= nil and  type( task ) == "table") then	
		wt_debug( "Adding CustomTask to List: " .. task.name .. "(Prio:"..task.priority..")" )
		table.insert( wt_core_taskmanager.Customtask_list, task )
	end
end
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- checks if a point on the worldmap is in levelrange of the player by trying to utilize the min/maxlevel of nearby placed Markers
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
			if ( distance <= 5000 ) then
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
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Possible default Tasks
function wt_core_taskmanager:update_tasks( )

	if (wt_core_taskmanager.task_list ~= nil) then
		wt_core_taskmanager.ClearTaskList(wt_core_taskmanager.task_list)
	end

	
	-- Add Search and Kill enemies
	if (Player:GetLocalMapID() ~= 33) then --dont do this in dungeons
		wt_core_taskmanager:addSearchAndKillTask(  )
	end
	
	-- Updating MarkerList-data if needed
	if ( wt_core_taskmanager.markerList == nil or TableSize( wt_core_taskmanager.markerList ) == 0 or MarkersNeedUpdate() ) then
		--wt_debug( "TaskManager: Updating MarkerList" )
		wt_core_taskmanager.markerList = MarkerList()
	end

	-- Add Waypoints to explore
	local t_waypoints = MapObjectList( "onmesh,type="..GW2.MAPOBJECTTYPE.WayPointLocked )
	if ( TableSize( t_waypoints ) > 0 ) then
		i, entry = next( t_waypoints )
		while ( i ~= nil and entry ~= nil ) do
			--wt_debug( "Unexplored Waypoint on NavMesh found.." )
			-- Search a nearby Marker to check if that area is suited for our current playerlevel
			local mPos = entry.pos
			if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
				--wt_debug( "LevelArea of that Waypoint fits to our PlayerLevel..adding it to the list" )
				wt_core_taskmanager:addWaypointTask( entry )
			end
			i, entry = next( t_waypoints, i )
		end
	end

	-- Add Points of Interest to explore
	local t_poi = MapObjectList( "onmesh,type="..GW2.MAPOBJECTTYPE.UndiscoveredPointOfInterest )
	if ( TableSize( t_poi ) > 0 ) then
		i, entry = next( t_poi )
		while ( i ~= nil and entry ~= nil ) do
			--wt_debug( "Unexplored PointOfInterest on NavMesh found.." )
			-- Search a nearby Marker to check if that area is suited for our current playerlevel
			local mPos = entry.pos
			if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
				--wt_debug( "LevelArea of that PointOfInterest fits to our PlayerLevel..adding it to the list" )
				wt_core_taskmanager:addPOITask( entry )
			end
			i, entry = next( t_poi, i )
		end
	end

	-- Add HeartQuests
	local t_object = MapObjectList( "onmesh,type="..GW2.MAPOBJECTTYPE.HeartQuestUnfinished )
	if ( TableSize( t_object ) > 0 ) then
		i, entry = next( t_object )
		while ( i ~= nil and entry ~= nil ) do
			--wt_debug( "Unfinished HeartQuest on NavMesh found.." )
			-- Search a nearby Marker to check if that area is suited for our current playerlevel
			local mPos = entry.pos
			if ( wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
				--wt_debug( "LevelArea of that HeartQuest fits to our PlayerLevel..adding it to the list" )
				wt_core_taskmanager:addHeartQuestTask( entry )
			end
			i, entry = next( t_object, i )
		end
	end

	-- Add FarmSpot Markers
	if ( wt_core_taskmanager.markerList ~= nil ) then
		local we = Player
		j, marker = next( wt_core_taskmanager.markerList )
		while ( j ~= nil and marker ~= nil ) do
			--wt_debug( "FarmSpot Marker on NavMesh found.." )
			local myPos = we.pos
			distance =  Distance3D( marker.x, marker.y, marker.z, myPos.x, myPos.y, myPos.z )
			if ( distance > 500 and marker.type == 0 and ( ( we.level >= marker.minlevel and we.level <= marker.maxlevel ) or gIgnoreMarkerCap == "1" ) ) then  --type 0 is farmspot
				--wt_debug( "FarmSpot Marker Added to Tasklist.." )
				wt_core_taskmanager:addFarmSpotTask( marker )
			end
			j, marker = next( wt_core_taskmanager.markerList, j )
		end
	end

	
	-- if we have no task because the playerlevel is above the maplevel and the user forgot to check the ignore marker cap button:
	if ( TableSize(wt_core_taskmanager.task_list) <= 1 and gIgnoreMarkerCap == "0") then
		gIgnoreMarkerCap = "1"
		wt_core_taskmanager:update_tasks( )
	end
	

	-- Add Random point to goto
	-- Add ???

end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-- Set the next default task
function wt_core_taskmanager:SetNewTask()
	local highestPriority = 0
	wt_core_taskmanager:update_tasks( )
	wt_core_taskmanager.possible_tasks = { }
	wt_core_taskmanager.current_task = nil

	
	-- enlist all possible tasks
	for k, task in pairs( wt_core_taskmanager.task_list ) do
		if ( task ~= nil and  type( task ) == "table" and task:canRun() and highestPriority <= task.priority ) then
			if ( task.priority > highestPriority ) then
				highestPriority = task.priority
			end
			table.insert( wt_core_taskmanager.possible_tasks, task )
		end
	end

	-- remove all tasks with lower priority
	if ( highestPriority > 0 ) then
		for k, task in pairs( wt_core_taskmanager.possible_tasks ) do
			if( task.priority < highestPriority ) then
				wt_debug( "TM_Removing:"..task.name .. "(Prio:" .. task.priority .. ")" .. " highest Prio:" .. highestPriority )
				table.remove( wt_core_taskmanager.possible_tasks, k )
			end
		end
		-- Select randomly a task from all remaining tasks in the list
		if ( #wt_core_taskmanager.possible_tasks > 0 ) then
			local taskindex = math.random( 1, #wt_core_taskmanager.possible_tasks )

			wt_debug( "Selecting Task:" .. taskindex.. " out of " .. #wt_core_taskmanager.possible_tasks .. " possible Tasks" )
			for k, task in pairs( wt_core_taskmanager.possible_tasks ) do
				if ( k == taskindex ) then
					wt_debug( "New task selected: " .. task.name .. "(Prio:" .. task.priority .. ")" )
					wt_core_taskmanager.current_task = task
				end
			end
		end
	end
end


function CheckPriorityTasks()
	if (wt_global_information.Now - wt_core_taskmanager.prioTmr > 1000) then
		wt_core_taskmanager.prioTmr = wt_global_information.Now
		local possiblePrioTaskList = {}
		highestPriority = 0
		
		-- Add all tasks from the wt_core_taskmanager.Partytask_list			
		for k, task in pairs( wt_core_taskmanager.Partytask_list ) do
			if ( task ~= nil and  type( task ) == "table" and highestPriority < task.priority and task:canRun() ) then
				highestPriority = task.priority
				table.insert( possiblePrioTaskList, task )
			end
		end
		
		-- Add Custom tasks here
		wt_core_taskmanager.AddCustomTasks()
		for k, task in pairs( wt_core_taskmanager.Customtask_list ) do
			if ( task ~= nil and  type( task ) == "table" and highestPriority < task.priority and task:canRun() ) then
				highestPriority = task.priority
				table.insert( possiblePrioTaskList, task )
			end
		end
		
		-- remove all tasks with lower priority
		if ( highestPriority > 0 ) then
			for k, task in pairs( possiblePrioTaskList ) do
				if( task.priority < highestPriority ) then
					wt_debug( "TM_Removing:"..task.name .. "(Prio:" .. task.priority .. ")" .. " highest Prio:" .. highestPriority )
					table.remove( possiblePrioTaskList, k )
				end
			end
			
			-- set new task if prio is higher than our current task
			if ( TableSize(possiblePrioTaskList) > 0 ) then
				for k, task in pairs( possiblePrioTaskList ) do
					if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and wt_core_taskmanager.current_task.priority >= task.priority ) then					
					--keep current task				
					else						
						wt_debug( "New Prio-Task selected: " .. task.name .. "(Prio:" .. task.priority .. ")" )
						wt_core_taskmanager.current_task = task
					end
				end
			end
		end	
		
		-- Reset the lists; leave tasks with "keep_in_queue" set in the task list for the next rotation
		if (wt_core_taskmanager.Partytask_list ~= nil) then
			wt_core_taskmanager.ClearTaskList(wt_core_taskmanager.Partytask_list)
		end
		if(wt_core_taskmanager.Customtask_list ~= nil) then
			wt_core_taskmanager.ClearTaskList(wt_core_taskmanager.Customtask_list)
		end
	end
end

function wt_core_taskmanager.AddCustomTasks()
-- This function adds custom tasks to the wt_core_taskmanager.Customtask_list, for dungeons and map specific events
-- Add functions from your own code to the wt_core_taskmanager.CustomLuaFunctions table, these will be called and should in return fill the 
-- wt_core_taskmanager.Customtask_list with tasks that have to be executed	
	for k, func in pairs( wt_core_taskmanager.CustomLuaFunctions ) do
		if ( func ~= nil and  type( func ) == "function" ) then			
			func()			
		end
	end
end
 
-- Main function that evaluates and executes the normal primary target tasks (goto, vendor, repair etc.)
function wt_core_taskmanager:DoTask()
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() ) then
		if (gGW2MinionTask ~= nil ) then
			gGW2MinionTask = wt_core_taskmanager.current_task.name
		end
		wt_core_taskmanager.current_task.execute()
	else
		--clear tasks from the "queue" if they were being kept in list until executed
		if wt_core_taskmanager.current_task ~= nil then
			if wt_core_taskmanager.current_task.keep_in_queue ~= nil then
				if wt_core_taskmanager.current_task.keep_in_queue == true then
					wt_core_taskmanager.ClearTask(wt_core_taskmanager.current_task)
				end
			end
		end
		wt_core_taskmanager:SetNewTask()
	end
end


-- Check if a task with priority > 10000 popped up (they are getting executed BEFORE aggrocheck)
function wt_core_taskmanager:CheckEmergencyTask()
	CheckPriorityTasks()
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and wt_core_taskmanager.current_task.priority > 10000) then
		return true
	end	
	return false
end
function wt_core_taskmanager:DoEmergencyTask()
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and wt_core_taskmanager.current_task.priority > 10000) then
		if (gGW2MinionTask ~= nil ) then
			gGW2MinionTask = wt_core_taskmanager.current_task.name
		end
		wt_core_taskmanager.current_task.execute()
	end	
end

-- Clears the task list but leaves "keep_in_queue" tasks in the list
function wt_core_taskmanager.ClearTaskList(task_list)
	for index, task in pairs(task_list) do
		if task.keep_in_queue ~= nil then
			--wt_debug("Task still in queue: "..task.name)
			if task.keep_in_queue == false then
				--wt_debug("Task removed from queue: "..tostring(task_name))
				table.remove(task_list, index)
			end
		else
			--wt_debug("Task removed from queue: "..tostring(task_name))
			table.remove(task_list, index)
		end
	end
end

-- Check if a task with priority >1000 and < 10000 popped up (they are getting executed AFTER aggrocheck)
function wt_core_taskmanager:CheckPrioTask()
	CheckPriorityTasks()	
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and wt_core_taskmanager.current_task.priority > 1000 and wt_core_taskmanager.current_task.priority < 10000) then
		return true
	end	
	return false
end
function wt_core_taskmanager:DoPrioTask()
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() and wt_core_taskmanager.current_task.priority > 1000 and wt_core_taskmanager.current_task.priority < 10000) then
		if (gGW2MinionTask ~= nil ) then
			gGW2MinionTask = wt_core_taskmanager.current_task.name
		end
		wt_core_taskmanager.current_task.execute()
	end
end

--Once task.finished() returns true DoTask() calls this to remove the task from the appropriate list
--This iterates through all task_lists to remove the appropriate task
function wt_core_taskmanager.ClearTask(finished_task)
	for index, task in pairs(wt_core_taskmanager.Customtask_list) do
		if task.name == finished_task.name then
			wt_debug("Removing "..task.name.." from the task queue")
			task.keep_in_queue = false
		end
	end
	for index, task in pairs(wt_core_taskmanager.Partytask_list) do
		if task.name == finished_task.name then
			wt_debug("Removing "..task.name.." from the task queue")
			task.keep_in_queue = false
		end
	end
	for index, task in pairs(wt_core_taskmanager.task_list) do
		if task.name == finished_task.name then
			wt_debug("Removing "..task.name.." from the task queue")
			task.keep_in_queue = false
		end
	end
end

-- Different Behavior for different Tasks
function wt_core_taskmanager:SetDefaultBehavior()
	wt_core_taskmanager.behavior = "default"	
	wt_global_information.MaxGatherDistance = 4000
	wt_global_information.MaxAggroDistanceFar = 1200
	wt_global_information.MaxAggroDistanceClose = 500
	wt_global_information.MaxSearchEnemyDistance = 2500
end
function wt_core_taskmanager:SetMoveToBehavior()
	wt_core_taskmanager.behavior = "move"	
	wt_global_information.MaxGatherDistance = math.random( 1200, 4000 )
	wt_global_information.MaxAggroDistanceFar = math.random( 500, 1200 )
	wt_global_information.MaxAggroDistanceClose = math.random( 300, 500 )
	wt_global_information.MaxSearchEnemyDistance = math.random( 600, 1200 )
end
