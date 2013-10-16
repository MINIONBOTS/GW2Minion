wt_core_unstuck = {}
wt_core_unstuck.evaltime = 0
wt_core_unstuck.tasktime = 0
wt_core_unstuck.count = 0

wt_core_unstuck.State = {
	STUCK 	= { id = 0, name = "STUCK" 		, stats = 0, ticks = 0, maxticks = 5  },
	OFFMESH = { id = 1, name = "OFFMESH" 	, stats = 0, ticks = 0, maxticks = 15 },
	IDLE 	= { id = 2, name = "IDLE" 		, stats = 0, ticks = 0, maxticks = 120 },
}

function wt_core_unstuck:Update()
	if 	(wt_core_unstuck.lastpos == nil) or
		(wt_core_unstuck.lastpos and type(wt_core_unstuck.lastpos) ~= "table")
	then
		wt_core_unstuck.lastpos = Player.pos
	end
	wt_core_unstuck.diffX = math.abs(Player.pos.x - wt_core_unstuck.lastpos.x)
	wt_core_unstuck.diffY = math.abs(Player.pos.y - wt_core_unstuck.lastpos.y)
	wt_core_unstuck.diffZ = math.abs(Player.pos.z - wt_core_unstuck.lastpos.z)
	wt_core_unstuck.lastpos = Player.pos
	
	if wt_core_unstuck:IsStuck() then
		wt_core_unstuck.State.STUCK.ticks = wt_core_unstuck.State.STUCK.ticks + 1
	else
		wt_core_unstuck.State.STUCK.ticks = 0
	end
	
	if wt_core_unstuck:IsOffMesh() then
		wt_core_unstuck.State.OFFMESH.ticks = wt_core_unstuck.State.OFFMESH.ticks + 1
	else
		wt_core_unstuck.State.OFFMESH.ticks = 0
	end
	
	if wt_core_unstuck:IsIdle() then
		wt_core_unstuck.State.IDLE.ticks = wt_core_unstuck.State.IDLE.ticks + 1
	else
		wt_core_unstuck.State.IDLE.ticks = 0
	end
	
end

function wt_core_unstuck:IsStuck()
	return 	wt_core_unstuck.diffX > 0 and wt_core_unstuck.diffX <= 75 and
			wt_core_unstuck.diffY > 0 and wt_core_unstuck.diffY <= 75 and
			wt_core_unstuck.diffZ > 0 and wt_core_unstuck.diffZ <= 75 and
			not Player:IsCasting()
end

function wt_core_unstuck:IsOffMesh()
	return not Player.onmesh and not Player:IsCasting()
end

function wt_core_unstuck:IsIdle()
	local isWaiting = false
	if (wt_core_taskmanager.current_task ~= nil) then
		isWaiting = wt_core_taskmanager.current_task.name == "Waiting..."
	end
	return 	wt_core_unstuck.diffX == 0 and
			wt_core_unstuck.diffY == 0 and
			wt_core_unstuck.diffZ == 0 and
			not Player:IsCasting() and
			not Player:IsConversationOpen() and 
			not Inventory:IsVendorOpened() and
			not isWaiting
end

--*************************************************************************************************************
-- Unstuck Stuff
--*************************************************************************************************************

function wt_core_unstuck:CheckStuck()
	if (gDoUnstuck == "0") then
		return
	end
	
	for i,state in pairs(wt_core_unstuck.State) do
		if state.ticks ~= 0 then
			if state.ticks > state.maxticks then
				wt_error(state.name..tostring(state.ticks).." EXCEEDED")
				if not wt_core_unstuck.task then
					wt_core_unstuck.State.STUCK.ticks = 0
					wt_core_unstuck.State.OFFMESH.ticks = 0
					wt_core_unstuck.State.IDLE.ticks = 0
					wt_core_unstuck.State[state.name].stats = wt_core_unstuck.State[state.name].stats + 1
					if (gDoUnstuck == "1") then
						if (Player:RespawnAtClosestResShrine()) then
							wt_core_unstuck.count = wt_core_unstuck.count + 1
						end
					end
					break
				end
			else
				--d(state.name..tostring(state.ticks))
			end
		end
		
	end

end

-- not used right now
function wt_core_unstuck:addTeleportTask(reason)
	local task = {}
	local list = WaypointList("nearest,onmesh,samezone,notcontested")
	if list then
		local i,wp = next(list)
		if i and wp then
			newWP = WaypointList:Get(i)
			task.pos = newWP.pos
			task.wpID = newWP.contentID
		end
	end
	task.steps = {
		function()Player:StopMoving() wt_core_controller.ToggleRun() end,
		function()Player:RespawnAtClosestResShrine() end,
		function()Player:StopMoving() if not wt_core_controller.shouldRun then wt_core_controller.ToggleRun() wt_global_information.Reset() end end,
	}
	task.step = 1
	function task:execute()
		if task.steps[task.step] then
			task.steps[task.step]()
			task.step = task.step + 1
			return
		end
		wt_debug("Teleporting: "..reason.." Completed")
		task.completed = true
		wt_core_unstuck.task = nil
		wt_core_controller.shouldRun = true
		wt_core_unstuck.count = wt_core_unstuck.count + 1
	end
	wt_debug("Teleporting: "..reason)
	return task
end

--*************************************************************************************************************
-- INITIALIZE
--*************************************************************************************************************

RegisterEventHandler(
	"Gameloop.Update",
	function (event,time)
		if 	wt_core_unstuck.task and not wt_core_unstuck.task.completed and
			Player.healthstate == GW2.HEALTHSTATE.Alive
		then
			if time - wt_core_unstuck.tasktime > 333 then
				wt_core_unstuck.tasktime = time
				wt_core_unstuck.task:execute()
			end
		else
			if  time - wt_core_unstuck.evaltime > 1000 and 
				wt_core_controller.shouldRun
			then
				wt_core_unstuck.evaltime = time
				wt_core_unstuck:Update() --stuck/idle/mesh stuff.
				wt_core_unstuck:CheckStuck()
			end
		end
		if (wt_core_unstuck.count > tonumber(gUnstuckCount)) then
			ExitGW()
		end
	end
)