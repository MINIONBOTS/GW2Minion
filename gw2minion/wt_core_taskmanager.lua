-- the core of the cause and effect engine


wt_core_taskmanager = { }
wt_core_taskmanager.task_list = { }
wt_core_taskmanager.possible_tasks = { }
wt_core_taskmanager.current_task = nil
wt_core_taskmanager.markerList = { }
wt_core_taskmanager.behavior = "default"

-- To add a new task
function wt_core_taskmanager:addTask( task )
	if ( task ~= nil and  type( task ) == "table") then
	--TODO: Add checks for more task values
		--wt_debug( "Adding Task to List: " .. task.name .. "(Prio:"..task.priority..")" )
		table.insert( wt_core_taskmanager.task_list, task )
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
-- Possible Tasks
function wt_core_taskmanager:update_tasks( )

	wt_core_taskmanager.task_list = { }

	-- Updating MarkerList-data if needed
	if ( wt_core_taskmanager.markerList == nil or TableSize( wt_core_taskmanager.markerList ) == 0 or MarkersNeedUpdate() ) then
		--wt_debug( "TaskManager: Updating MarkerList" )
		wt_core_taskmanager.markerList = MarkerList()
	end

	-- Add Search and Kill enemies
	wt_core_taskmanager:addSearchAndKillTask(  )

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
			wt_debug( "FarmSpot Marker on NavMesh found.." )
			local myPos = we.pos
			distance =  Distance3D( marker.x, marker.y, marker.z, myPos.x, myPos.y, myPos.z )
			if ( distance > 500 and marker.type == 0 and ( ( we.level >= marker.minlevel and we.level <= marker.maxlevel ) or gIgnoreMarkerCap == "1" ) ) then  --type 0 is farmspot
				wt_debug( "FarmSpot Marker Added to Tasklist.." )
				wt_core_taskmanager:addFarmSpotTask( marker )
			end
			j, marker = next( wt_core_taskmanager.markerList, j )
		end

	end

	-- Add Xmas Presents
	local t_object = MapObjectList( "onmesh,type=593" ) --593 = Presents
	if ( TableSize( t_object ) > 0 ) then
		i, entry = next( t_object )
		while ( i ~= nil and entry ~= nil ) do
			local mPos = entry.pos
			if ( gHuntPresents == "1" and wt_core_taskmanager:checkLevelRange( mPos.x, mPos.y, mPos.z ) ) then
				wt_debug( "Add PresentHuntTask" )
				wt_core_taskmanager:addPresentHuntTask( entry )
			end
			i, entry = next( t_object, i )
		end
	end

	-- Add Random point to goto
	-- Add ???

end
-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- set the next task
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

-- Main function that evaluates and executes the tasks
function wt_core_taskmanager:DoTask()
	if ( wt_core_taskmanager.current_task ~= nil and not wt_core_taskmanager.current_task.isFinished() ) then
		if (gGW2MinionTask ~= nil ) then
			gGW2MinionTask = wt_core_taskmanager.current_task.name
		end
		--wt_debug( "Doing task " .. wt_core_taskmanager.current_task.name )
		wt_core_taskmanager.current_task.execute()
	else
		wt_core_taskmanager:SetNewTask()
	end
end

-- Different Behavior for different Tasks
function wt_core_taskmanager:SetDefaultBehavior()
	wt_core_taskmanager.behavior = "default"
	wt_global_information.MaxLootDistance = 1200
	wt_global_information.MaxGatherDistance = 4000
	wt_global_information.MaxAggroDistanceFar = 1200
	wt_global_information.MaxAggroDistanceClose = 500
	wt_global_information.MaxSearchEnemyDistance = 2500
end
function wt_core_taskmanager:SetMoveToBehavior()
	wt_core_taskmanager.behavior = "move"
	wt_global_information.MaxLootDistance = math.random( 800, 1400 )
	wt_global_information.MaxGatherDistance = math.random( 1200, 4000 )
	wt_global_information.MaxAggroDistanceFar = math.random( 500, 1200 )
	wt_global_information.MaxAggroDistanceClose = math.random( 300, 500 )
	wt_global_information.MaxSearchEnemyDistance = math.random( 600, 1200 )
end