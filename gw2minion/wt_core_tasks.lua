-- Holds all available functions that each add a new specific Task to the TaskManager

------------------------------------------------------------------
-- Explore Waypoint Task
function wt_core_taskmanager:addWaypointTask( waypoint )
	if ( waypoint ~= nil and waypoint.pos.x ~= 0 and waypoint.pos.y ~= 0 and waypoint.pos.z ~= 0 ) then
		local newtask = inheritsFrom( wt_task )
		newtask.name = "Explore Waypoint"
		newtask.priority = wt_task.priorities.normal
		newtask.position = waypoint.pos
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 500

		function newtask:execute()
			if ( not wt_core_taskmanager.behavior == "move" ) then
				wt_core_taskmanager:SetMoveToBehavior()
			end
			local mypos = Player.pos
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance > 250 ) then
				--wt_debug( "Walking towards new Waypoint ")
				if ( ( wt_global_information.Now - newtask.last_execution ) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 200 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.done = true
			end
			newtask.name = "Explore Waypoint, dist: " ..( math.floor ( distance ) )
		end

		function newtask:isFinished()
			if ( newtask.done ) then
				wt_core_taskmanager:SetDefaultBehavior()
				return true
			end
			return false
		end
		wt_core_taskmanager:addTask( newtask )
	end
end

------------------------------------------------------------------
-- Explore Point Of Interest Task
function wt_core_taskmanager:addPOITask( poi )
	if ( poi ~= nil and poi.pos.x ~= 0 and poi.pos.y ~= 0 and poi.pos.z ~= 0 ) then
		local newtask = inheritsFrom( wt_task )
		newtask.name = "Explore PointOfInterest"
		newtask.priority = wt_task.priorities.normal
		newtask.position = poi.pos
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 500

		function newtask:execute()
			if ( not wt_core_taskmanager.behavior == "move" ) then
				wt_core_taskmanager:SetMoveToBehavior()
			end
			local mypos = Player.pos
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance > 150 ) then
				--wt_debug( "Walking towards new PointOfInterest ")
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 200 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.done = true
			end
			newtask.name = "Explore PointOfInterest, dist: "..( math.floor( distance ) )
		end

		function newtask:isFinished()
			if ( newtask.done ) then
				wt_core_taskmanager:SetDefaultBehavior()
				return true
			end
			return false
		end
		wt_core_taskmanager:addTask( newtask )
	end
end

------------------------------------------------------------------
-- Kill stuff nearby Task
function wt_core_taskmanager:addSearchAndKillTask(  )

	local newtask = inheritsFrom( wt_task )
	newtask.name = "Search And Kill"
	newtask.priority = wt_task.priorities.normal
	newtask.startingTime = wt_global_information.Now
	newtask.maxduration = math.random( 60000, 600000 )
	newtask.done = false

	function newtask:execute()
		if ( not wt_core_taskmanager.behavior == "default" ) then
			wt_core_taskmanager:SetDefaultBehavior()
		end
		TargetList = ( CharacterList( "shortestpath,onmesh,noCritter,attackable,alive,maxdistance=4000,maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
		if ( TargetList ~= nil ) then
			nextTarget, E = next( TargetList )
			if ( nextTarget ~= nil and ( wt_global_information.Now - newtask.startingTime ) < newtask.maxduration ) then
				--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )
				wt_core_state_combat.setTarget( nextTarget )
				wt_core_controller.requestStateChange( wt_core_state_combat )
			else
				Player:StopMoving()
				newtask.done = true
			end
		else
			Player:StopMoving()
			newtask.done = true
		end
		newtask.name = "Search And Kill "..( math.floor( ( newtask.maxduration - ( wt_global_information.Now - newtask.startingTime ) ) / 1000 ) ) .. " sec"
	end

	function newtask:isFinished()
		if ( newtask.done ) then
			wt_core_taskmanager:SetDefaultBehavior()
			return true
		end
		return false
	end
	wt_core_taskmanager:addTask( newtask )

end

------------------------------------------------------------------
-- Fight at FarmSpot Task
function wt_core_taskmanager:addFarmSpotTask( marker )

	local newtask = inheritsFrom( wt_task )
	newtask.name = "Fight at FarmSpot "
	newtask.priority = wt_task.priorities.normal
	newtask.spotreached = false
	newtask.startingTime = 0
	newtask.position = {}
	newtask.position.x = marker.x
	newtask.position.y = marker.y
	newtask.position.z = marker.z
	newtask.maxduration = math.random( 60000, 600000 )
	newtask.done = false
	newtask.last_execution = 0
	newtask.throttle = 500

	function newtask:execute()
		if ( not newtask.spotreached ) then
			if ( not wt_core_taskmanager.behavior == "move" ) then
				wt_core_taskmanager:SetMoveToBehavior()
			end
			local me = Player
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 350 ) then
				--wt_debug( "Walking towards FarmSpot Marker ")
				if ( ( wt_global_information.Now - newtask.last_execution ) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 100 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.spotreached = true
				newtask.startingTime = wt_global_information.Now
			end
			newtask.name = "MoveTo FarmSpot, dist: "..( math.floor( distance ) )
		else
			if ( not wt_core_taskmanager.behavior == "default" ) then
				wt_core_taskmanager:SetDefaultBehavior()
			end
			TargetList = ( CharacterList( "shortestpath,onmesh,noCritter,attackable,alive,maxdistance="..wt_global_information.MaxSearchEnemyDistance..",maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
			if ( TargetList ~= nil ) then
				nextTarget, E = next( TargetList )
				if ( nextTarget ~= nil and ( wt_global_information.Now - newtask.startingTime ) < newtask.maxduration ) then
					--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )
					wt_core_state_combat.setTarget( nextTarget )
					wt_core_controller.requestStateChange( wt_core_state_combat )
				else
					Player:StopMoving()
					newtask.done = true
				end
			else
				Player:StopMoving()
				newtask.done = true
			end
			newtask.name = "Fight at FarmSpot "..( math.floor( ( newtask.maxduration - ( wt_global_information.Now - newtask.startingTime ) ) / 1000 ) ) .. " sec"
		end
	end

	function newtask:isFinished()
		if ( newtask.done ) then
			wt_core_taskmanager:SetDefaultBehavior()
			return true
		end
		return false
	end
	wt_core_taskmanager:addTask( newtask )

end

------------------------------------------------------------------
-- Fight at HeartQuest Task
function wt_core_taskmanager:addHeartQuestTask( quest )

	local newtask = inheritsFrom( wt_task )
	newtask.name = "Fight at HeartQuest"
	newtask.priority = wt_task.priorities.normal
	newtask.spotreached = false
	newtask.startingTime = 0
	newtask.position = quest.pos
	newtask.maxduration = math.random( 60000, 600000 )
	newtask.done = false
	newtask.last_execution = 0
	newtask.throttle = 500

	function newtask:canRun()
		return true
	end

	function newtask:execute()
		if ( not newtask.spotreached ) then
			if ( not wt_core_taskmanager.behavior == "move" ) then
				wt_core_taskmanager:SetMoveToBehavior()
			end
			local me = Player
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 350 ) then
				--wt_debug("Walking towards FarmSpot Marker ")
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 100 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.spotreached = true
				newtask.startingTime = wt_global_information.Now
			end
			newtask.name = "Fight at HeartQuest, dist: "..(math.floor(distance))
		else
			if ( not wt_core_taskmanager.behavior == "default" ) then
				wt_core_taskmanager:SetDefaultBehavior()
			end
			local me = Player
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 4000 ) then
				--wt_debug("Walking towards FarmSpot Marker ")
				Player:MoveTo(  newtask.position.x, newtask.position.y, newtask.position.z, 1000 )
			else
				TargetList = ( CharacterList( "shortestpath,onmesh,noCritter,attackable,alive,maxdistance="..wt_global_information.MaxSearchEnemyDistance..",maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
				if ( TargetList ~= nil ) then
					nextTarget, E = next( TargetList )
					if ( nextTarget ~= nil and (wt_global_information.Now - newtask.startingTime) < newtask.maxduration) then
						--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )
						wt_core_state_combat.setTarget( nextTarget )
						wt_core_controller.requestStateChange( wt_core_state_combat )
					else
						Player:StopMoving()
						newtask.done = true
					end
				else
					Player:StopMoving()
					newtask.done = true
				end
			end
			newtask.name = "Fight at FarmSpot "..(math.floor((newtask.maxduration-(wt_global_information.Now - newtask.startingTime))/1000)).." sec"
		end
	end

	function newtask:isFinished()
		if ( newtask.done ) then
			wt_core_taskmanager:SetDefaultBehavior()
			return true
		end
		return false
	end
	wt_core_taskmanager:addTask( newtask )

end

------------------------------------------------------------------
-- Hunt Presents Task
function wt_core_taskmanager:addPresentHuntTask( entry )
	if ( entry ~= nil and entry.pos.x ~= 0 and entry.pos.y ~= 0 and entry.pos.z ~= 0 ) then
		local newtask = inheritsFrom( wt_task )
		newtask.name = "Hunting Present"
		newtask.priority = wt_task.priorities.high
		newtask.position = entry.pos
		newtask.done = false
		newtask.spotreached = false
		newtask.last_execution = 0
		newtask.throttle = 500

	function newtask:execute()
		if ( not newtask.spotreached ) then
			if ( not wt_core_taskmanager.behavior == "move" ) then
				wt_core_taskmanager:SetMoveToBehavior()
			end
			local me = Player
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 100 ) then
				--wt_debug("Walking towards FarmSpot Marker ")
				if ( ( wt_global_information.Now - newtask.last_execution ) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.spotreached = true
				newtask.startingTime = wt_global_information.Now
			end
			newtask.name = "Hunting Present, dist: " .. ( math.floor( distance ) )
		else
			if ( not wt_core_taskmanager.behavior == "default" ) then
				wt_core_taskmanager:SetDefaultBehavior()
			end
			local me = Player
			local distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			local t = Player:GetInteractableTarget()
			if ( t ~= nil and t ~= 0  ) then
				local present = GadgetList:Get(t)
				if ( present ~= nil and present ~= 0 and ( present.contentID == 230215 or present.contentID == 228283 ) ) then
					Player:Interact( t )
					Player:StopMoving()
					newtask.done = true
				end
			end
			Player:StopMoving()
			newtask.done = true
		end
	end

		function newtask:isFinished()
			if ( newtask.done ) then
				wt_core_taskmanager:SetDefaultBehavior()
				return true
			end
			return false
		end
		wt_core_taskmanager:addTask( newtask )
	end
end