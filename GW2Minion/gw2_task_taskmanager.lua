-- TM Task , to run it in the main loop
gw2_task_taskmanager = inheritsFrom(ml_task)
gw2_task_taskmanager.name = GetString("customTasks")

function gw2_task_taskmanager.Create()
	local newinst = inheritsFrom(gw2_task_taskmanager)

    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}

	newinst.mytask = nil

    return newinst
end

function gw2_task_taskmanager:Init()
-- ProcessOverWatch() elements
	-- Handle Dead
	self:add(ml_element:create( "Dead", c_Dead, e_Dead, 500 ), self.overwatch_elements)

	-- Downed
	self:add(ml_element:create( "Downed", c_Downed, e_DownedEmpty, 450 ), self.overwatch_elements)

	-- CheckTask - makes sure we have a active task, controls subtask conditions too
	self:add(ml_element:create( "CheckTask", c_CheckTask, e_CheckTask, 350), self.overwatch_elements)

	-- RunTasks - executes/runs the active task
	self:add(ml_element:create( "RunTask", c_RunTask, e_RunTask, 250 ), self.process_elements)

	self:AddTaskCheckCEs()
end

-- Makes sure we have an active task running, else grabs the next one from the TM
c_CheckTask = inheritsFrom( ml_cause )
e_CheckTask = inheritsFrom( ml_effect )
function c_CheckTask:evaluate()

	ml_task_hub:CurrentTask().mytask = ml_task_mgr.GetCurrentTask()

	--d("No current active task or current task doesnt meet the run-conditions anymore, getting the next task")
	if ( not ml_task_hub:CurrentTask().mytask ) then
		return true
	else
		if ( ml_global_information.ShowDebug ) then
			dbTMTask = ml_task_hub:CurrentTask().mytask.name
			if ( ml_task_hub:CurrentTask().mytask.started ) then
				dbTMDuration = tostring(math.floor((ml_global_information.Now - ml_task_hub:ThisTask().mytask.startTimer)/1000)).."s/"..tostring(ml_task_hub:ThisTask().mytask.maxduration).."s"
			else
				dbTMDuration = "0s/"..tostring(ml_task_hub:ThisTask().mytask.maxduration)
			end
		end
	end
	return false
end
function e_CheckTask:execute()
	ml_task_hub:CurrentTask().mytask = ml_task_mgr.GetNextTask()

	if ( not ml_task_hub:CurrentTask().mytask ) then
		d("TaskManager has no startable task left")
		ml_global_information.Stop()
		ml_global_information.Wait(5000)
		gTMCurrentTask = ""
		gTMLastTaskID = 1
	else
		--update current task UI
		gTMCurrentTask = "ID "..ml_task_hub:CurrentTask().mytask.id..": "..string.gsub(ml_task_hub:CurrentTask().mytask.name, ",", "")
		gTMLastTaskID = ml_task_hub:CurrentTask().mytask.id
		Settings.GW2Minion.gTMLastTaskID = gTMLastTaskID

	end
end

c_RunTask = inheritsFrom( ml_cause )
e_RunTask = inheritsFrom( ml_effect )
function c_RunTask:evaluate()

	if ( ml_task_hub:CurrentTask().mytask ~= nil ) then
		return true
	end
	return false

end
function e_RunTask:execute()

	-- New task, move to starting position first
	if ( not ml_task_hub:CurrentTask().mytask.started ) then
		if ( ml_task_hub:CurrentTask().mytask.mapid ~= ml_global_information.CurrentMapID ) then

			local pos = ml_nav_manager.GetNextPathPos(	ml_global_information.Player_Position, ml_global_information.CurrentMapID, ml_task_hub:CurrentTask().mytask.mapid )

			if (ValidTable(pos)) then
				local newTask = gw2_task_navtomap.Create()
				newTask.targetMapID = ml_task_hub:CurrentTask().mytask.mapid
				newTask.name = "MoveTo Task "..ml_task_hub:CurrentTask().mytask.name.." StartMap"
				newTask.targetPos = ml_task_hub:CurrentTask().mytask.pos
				ml_task_hub:CurrentTask():AddSubTask(newTask)

			else
				ml_error("Cannot reach StartMap of Task, disabling Task : "..ml_task_hub:CurrentTask().mytask.name)
				ml_task_mgr.SetTaskDisabled(ml_task_hub:CurrentTask().mytask)

			end

		else
			-- Moving to startposition of task
			local startPos = ml_task_hub:CurrentTask().mytask.pos
			-- Randomize the targetpos a bit, to not make all bots walk to the exact point..
			if ( ml_task_hub:CurrentTask().name == "MoveTo" and ml_task_hub:CurrentTask().mytask.randomTargetPosition and ml_task_hub:CurrentTask().mytask.randomTargetPosition == "1" )  then
				local rPos = NavigationManager:GetRandomPointOnCircle(startPos.x,startPos.y,startPos.z,50,350)
				if ( ValidTable(rPos) ) then
					startPos = rPos
				end
			end

			local dist = Distance3D(startPos.x,startPos.y,startPos.z,ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z)
			d("Distance to TaskStartPosition : "..tostring(dist))
			if ( dist > 50 ) then
				local newTask = gw2_task_moveto.Create()
				newTask.name = "Moving to StartPosition of "..ml_task_hub:CurrentTask().mytask.name
				newTask.targetPos = startPos
				if (ml_task_hub:CurrentTask().mytask.useWaypoint) then
					newTask.useWaypoint = ml_task_hub:CurrentTask().mytask.useWaypoint == "1"
				end
				if (ml_task_hub:CurrentTask().mytask.randomMovement) then
					newTask.randomMovement = ml_task_hub:CurrentTask().mytask.randomMovement == "1"
				end
				if (ml_task_hub:CurrentTask().mytask.smoothTurns) then
					newTask.smoothTurns = ml_task_hub:CurrentTask().mytask.smoothTurns == "1"
				end
				ml_task_hub:CurrentTask():AddSubTask(newTask)

			else
				d("Task Startposition reached, starting task...")
				ml_task_mgr.SetActiveTaskStarted()
			end

		end

	else
		-- Do task
		ml_task_hub:CurrentTask():AddSubTask(ml_task_hub:CurrentTask().mytask)

	end
end


function gw2_task_taskmanager:UIInit()
	d("gw2_task_taskmanager:UIInit")
	local mw = WindowManager:GetWindow(gw2minion.MainWindow.Name)
	if ( mw ) then
		mw:NewButton(GetString("taskSetupTasks"),"gw2_task_taskmanager.Toggle",GetString("taskManager"))
		mw:NewComboBox(GetString("taskCurrentTask"),"gTMCurrentTask",GetString("taskManager"),"")
		RegisterEventHandler("gw2_task_taskmanager.Toggle", ml_task_mgr.ToggleMenu)
		mw:UnFold(GetString("taskManager"))
	end

	-- Setup Debug fields
	local dw = WindowManager:GetWindow(gw2minion.DebugWindow.Name)
	if ( dw ) then
		dw:NewField("Active Task","dbTMTask","Task_Manager")
		dw:NewField("Duration","dbTMDuration","Task_Manager")
	end
	return true
end
function gw2_task_taskmanager:UIDestroy()
	d("gw2_task_taskmanager:UIDestroy")
	GUI_DeleteGroup(gw2minion.MainWindow.Name, GetString("taskManager"))
end

function gw2_task_taskmanager.ModuleInit()
	d("gw2_task_taskmanager:ModuleInit")
	gw2_task_taskmanager.UpdateCurrentTaskUI()

	Settings.GW2Minion.gTMLastTaskID = Settings.GW2Minion.gTMLastTaskID or 1
	gTMLastTaskID = Settings.GW2Minion.gTMLastTaskID

	-- try to load the last task we had running
	gw2_task_taskmanager.UpdateCurrentTaskUI()

end

-- gets called after the ml_task_mgr updates the main UI window, so we need to refresh our current task dropdown field
function gw2_task_taskmanager.UpdateCurrentTaskUI()

	-- Update dropdown field entries
	local tasks = ml_task_mgr.GetTaskList()
	local tasklist = ""
	if ( tasks ) then
		for prio,task in pairs( tasks )do
			tasklist = tasklist..",".."ID "..task.id..": "..string.gsub(task.name, ",", "")
		end
	end
	gTMCurrentTask_listitems = tasklist

	-- Select/Set our last used/current task
	local task = ml_task_mgr.GetTaskByID(tonumber(gTMLastTaskID))
	if ( task ) then

		if ( not ml_task_mgr.SetNextTaskByID(tonumber(gTMLastTaskID)) ) then

			local currentTask = ml_task_mgr.GetCurrentTask()
			if ( not currentTask ) then
				gTMCurrentTask = ""
			else
				gTMCurrentTask = "ID "..currentTask.id..": "..string.gsub(currentTask.name, ",", "")
			end

		else

			gTMCurrentTask = "ID "..task.id..": "..string.gsub(task.name, ",", "")

		end
	end
end

function gw2_task_taskmanager.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if (k == "gTMCurrentTask" ) then
			ml_global_information.Stop()
			ml_global_information.Reset()
			v = string.gsub(v, "ID ", "")
			local sPos = string.find( v, ": " )
			local id = 1
			if ( sPos ) then
				id = string.sub(v,0,sPos-1)
			end
			id = tonumber(id) or 1
			Settings.GW2Minion["gTMLastTaskID"] = id
			ml_task_mgr.SetNextTaskByID(id)
		end
	end
end



RegisterEventHandler("GUI.Update",gw2_task_taskmanager.GUIVarUpdate)
ml_global_information.AddBotMode(GetString("customTasks"), gw2_task_taskmanager)
RegisterEventHandler("Module.Initalize",gw2_task_taskmanager.ModuleInit)
RegisterEventHandler("ml_task_mgr.UpdateMainWindow",gw2_task_taskmanager.UpdateCurrentTaskUI)