-- Grind
gw2_task_grind = inheritsFrom(ml_task)
gw2_task_grind.name = GetString("grindMode")

function gw2_task_grind.Create()
	local newinst = inheritsFrom(gw2_task_grind)

    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}

	-- custom fields
	newinst.maxGrindTmr = nil
	newinst.markerTime = 0
	newinst.currentMarker = false
	newinst.filterLevel = true

	newinst.maxKills = 0 -- Amount of enemies to kill before task is completed, gets set by TaskManager Custom Conditions
	newinst.currentKills = 0 -- Counter of current task
	newinst.lastTargetID = nil -- set this value on each addsubtask(combat), this is used to determine if we killed one or not
	newinst.lastTargetType = "character" -- same as above

    return newinst
end

function gw2_task_grind:Init()

	-- ProcessOverWatch() elements

	-- Handle Dead
	self:add(ml_element:create( "Dead", c_Dead, e_Dead, 500 ), self.overwatch_elements)

	-- Downed
	self:add(ml_element:create( "Downed", c_Downed, e_DownedEmpty, 450 ), self.overwatch_elements)

	-- Handle Rezz-Target is alive again or gone, deletes the subtask moveto in case it is needed
	self:add(ml_element:create( "RevivePartyMemberOverWatch", c_RezzOverWatchCheck, e_RezzOverWatchCheck, 400 ), self.overwatch_elements)

	-- Normal elements
	-- Revive Downed/Dead Partymember
	self:add(ml_element:create( "RevivePartyMember", c_RezzPartyMember, e_RezzPartyMember, 375 ), self.process_elements)	-- creates subtask: moveto
	-- Revive other Players
	self:add(ml_element:create( "RevivePlayer", c_reviveDownedPlayersInCombat, e_reviveDownedPlayersInCombat, 350 ), self.process_elements)	-- creates subtask: moveto
	-- FightAggro
	self:add(ml_element:create( "FightAggro", c_FightAggro, e_FightAggro, 325 ), self.process_elements) --creates immediate queue task for combat

	-- Resting / Wait to heal
	self:add(ml_element:create( "Resting", c_waitToHeal, e_waitToHeal, 300 ), self.process_elements)

	-- Normal Looting & chests
	self:add(ml_element:create( "Looting", c_Looting, e_Looting, 275 ), self.process_elements)

	-- Buy & Repair & Vendoring
	self:add(ml_element:create( "VendorRepair", c_createVendorRepairTask, e_createVendorRepairTask, 260 ), self.process_elements)
	self:add(ml_element:create( "VendorSell", c_createVendorSellTask, e_createVendorSellTask, 250 ), self.process_elements)
	self:add(ml_element:create( "VendorBuy", c_createVendorBuyTask, e_createVendorBuyTask, 240 ), self.process_elements)

	-- DoEvents
	self:add(ml_element:create( "DoEvent", c_doEvents, e_doEvents, 215 ), self.process_elements)

	-- ReviveNPCs
	self:add(ml_element:create( "ReviveNPC", c_reviveNPC, e_reviveNPC, 200 ), self.process_elements) -- creates subtask: moveto

	-- Gathering
	self:add(ml_element:create( "Gathering", c_GatherTask, e_GatherTask, 175 ), self.process_elements) -- creates subtask: gatheringTask

	-- Finish Enemy
	self:add(ml_element:create( "FinishEnemy", c_FinishEnemy, e_FinishEnemy, 150 ), self.process_elements)

	-- Fight in a smaller radius towards the current marker ( this takes care of reaching it and also when running outside the markerradius and we need to move back to marker)
	-- Only for GrindMarkers!
	self:add(ml_element:create( "FightTowardsGrindMarker", c_FightToGrindMarker, e_FightToGrindMarker, 125 ), self.process_elements)--creates immediate queue task for combat

	-- Pick the next/new Marker and makes sure we are staying near the current Marker
	self:add( ml_element:create( "NextMarker", c_MoveToMarker, e_MoveToMarker, 75 ), self.process_elements)

	-- Check for attackable Targets
	self:add(ml_element:create( "GetNextTarget", c_CombatTask, e_CombatTask, 50 ), self.process_elements)

	-- Move to a Randompoint if there is nothing to fight around us
	self:add( ml_element:create( "movetorandom", c_movetorandom, e_movetorandom, 25 ), self.process_elements)


	self:AddTaskCheckCEs()
end

function gw2_task_grind:UIInit()
	local mw = WindowManager:GetWindow(gw2minion.MainWindow.Name)
	if ( mw ) then
		mw:NewCheckBox(GetString("doEvents"),"gDoEvents",GetString("grindMode"))

		mw:UnFold( GetString("grindMode") );
	end

	Settings.GW2Minion.gDoEvents = Settings.GW2Minion.gDoEvents or "1"

	gDoEvents = Settings.GW2Minion.gDoEvents
	return true
end
function gw2_task_grind:UIDestroy()
	d("gw2_task_grind:UIDestroy")
	GUI_DeleteGroup(gw2minion.MainWindow.Name, GetString("grindMode"))
end

function gw2_task_grind.ModuleInit()
	d("gw2_task_grind:ModuleInit")

	-- Setup Debug fields
	local dw = WindowManager:GetWindow(gw2minion.DebugWindow.Name)
	if ( dw ) then
		dw:NewField("KillCount","dbGrindKillcount","Task_Grind")
		dw:NewField("DoEvents","dbDoEvents","Task_Grind")
	end

	ml_task_mgr.AddTaskType(GetString("grindMode"), gw2_task_grind) -- Allow this task to be selectable in TaskManager
end

-- TaskManager functions
function gw2_task_grind:UIInit_TM()
	ml_task_mgr.NewNumeric("Max Kills", "maxKills")
	ml_task_mgr.NewCheckBox("Do events", "doEvents")
	ml_task_mgr.NewCheckBox("Use waypoint to reach start", "useWaypoint")
end

-- TaskManager function: Checks for custom conditions to start this task
function gw2_task_grind.CanTaskStart_TM()
	return true
end
-- TaskManager function: Checks for custom conditions to keep this task running
function gw2_task_grind.CanTaskRun_TM()

	if(ml_task_hub:CurrentTask().doEvents ~= nil) then
		gDoEvents = tostring(ml_task_hub:CurrentTask().doEvents)
		dbDoEvents = gDoEvents
	end

	-- Check the maxkill counter
	if ( ml_task_hub:CurrentTask().maxKills ~= nil and ml_task_hub:CurrentTask().maxKills ~= 0 ) then

		if ( ml_global_information.ShowDebug ) then
			dbGrindKillcount = tostring(ml_task_hub:CurrentTask().currentKills).."/"..tostring(ml_task_hub:CurrentTask().maxKills).." Kills"
		end

		ml_log(" "..tostring(ml_task_hub:CurrentTask().currentKills).."/"..tostring(ml_task_hub:CurrentTask().maxKills).." Kills")
		-- We killed enough
		if ( tonumber(ml_task_hub:CurrentTask().maxKills) <=  ml_task_hub:CurrentTask().currentKills ) then return false end

		-- Check if a targeted enemy got killed meanwhile
		if ( ml_task_hub:CurrentTask().lastTargetID ~= nil and tonumber(ml_task_hub:CurrentTask().lastTargetID) ~= nil) then
			local target = nil

			if ( ml_task_hub:CurrentTask().lastTargetType == "character" ) then
				target = CharacterList:Get(tonumber(ml_task_hub:CurrentTask().lastTargetID))
			else
				target = GadgetList:Get(tonumber(ml_task_hub:CurrentTask().lastTargetID))
			end

			if ( not target or not target.alive ) then
				ml_task_hub:CurrentTask().currentKills = tonumber(ml_task_hub:CurrentTask().currentKills) + 1
				ml_task_hub:CurrentTask().lastTargetID = nil
			end
		end
	end
	return true
end

--------- Creates a new IMMEDIATE_GOAL task to kill an enemy when we are fighting our way towards the current grindmarker
c_FightToGrindMarker = inheritsFrom( ml_cause )
e_FightToGrindMarker = inheritsFrom( ml_effect )
c_FightToGrindMarker.target = nil
c_FightToGrindMarker.maxtick = math.random(10, 30)
c_FightToGrindMarker.tick = 0
function c_FightToGrindMarker:evaluate()
	return gw2_marker_manager.CanFightToMarker(c_FightToGrindMarker, GetString("grindMarker"))
end

function e_FightToGrindMarker:execute()
	return gw2_marker_manager.FightToMarker(c_FightToGrindMarker, GetString("grindMarker"))
end

---------
-- Moves player towards the current marker and makes sure we are still inside the radius around the marker, moves the player randomly around the maker to kill n find stuff
-- If Markertime is up, it will pick also the next marker
-- If there are no Maker in the current mesh, it will pick a random point and go there
c_MoveToMarker = inheritsFrom( ml_cause )
e_MoveToMarker = inheritsFrom( ml_effect )
c_MoveToMarker.markerreachedfirsttime = false
c_MoveToMarker.markerreached = false
c_MoveToMarker.allowedToFight = false -- this sh*t is needed else he will go back n forth on the outer side of the marker's min radius if an enemy sits at larger-min-dist behind that radius -.-
function c_MoveToMarker:evaluate()
	if(gw2_marker_manager.MarkerMode(GetString("grindMode"))) then
		-- Get a new/next Marker if we need one ( no marker , out of level, time up )
		if (gw2_marker_manager.ValidMarker(GetString("grindMarker")) == false
			or gw2_marker_manager.MarkerInLevelRange(GetString("grindMarker"))
			or (c_MoveToMarker.markerreachedfirsttime == true and gw2_marker_manager.MarkerExpired(GetString("grindMarker")))) then

			gw2_marker_manager.SetCurrentMarker(gw2_marker_manager.CreateMarker(GetString("grindMarker"), c_MoveToMarker))
		end

		-- We have a valid current Grindmarker
		if (gw2_marker_manager.ValidMarker(GetString("grindMarker"))) then

			-- Reset the Markertime until we actually reached the marker the first time and then let it count down
			if (c_MoveToMarker.markerreachedfirsttime == false ) then
				gw2_marker_manager.SetTime()
			end

			-- We haven't reached the currentMarker or ran outside its radius
			if ( c_MoveToMarker.markerreached == false) then
				return true
			else
				return gw2_marker_manager.ReturnToMarker(GetString("grindMode"), c_MoveToMarker)
			end
		end
	end
    return false
end

function e_MoveToMarker:execute()
	-- Move to our current marker
	if (gw2_marker_manager.ValidMarker()) then
		ml_log(" e_MoveToMarker ")
		return gw2_marker_manager.MoveToMarker(c_MoveToMarker, true)
	end
	return ml_log(false)
end

--------- Creates a new IMMEDIATE_GOAL task to kill an enemy
c_CombatTask = inheritsFrom( ml_cause )
e_CombatTask = inheritsFrom( ml_effect )
c_CombatTask.target = nil
function c_CombatTask:evaluate()
	local target = gw2_common_functions.GetBestCharacterTarget( 9999 ) -- maxrange where enemies should be searched for
	if ( target ) then
		c_CombatTask.target = target
		return ml_global_information.Player_SwimState == GW2.SWIMSTATE.NotInWater and c_CombatTask.target ~= nil
	end
	c_CombatTask.target = nil
	return false
end

function e_CombatTask:execute()
	ml_log("CombatTask ")

	if (c_CombatTask.target ~= nil) then
		--Player:StopMovement()
		-- For TM Conditions
		ml_task_hub:CurrentTask().lastTargetID = c_CombatTask.target.id

		-- Create new Subtask Combat
		local newTask = gw2_task_combat.Create()
		newTask.targetID = c_CombatTask.target.id
		newTask.terminateOnAggro = true
		ml_task_hub:Add(newTask.Create(), IMMEDIATE_GOAL, TP_IMMEDIATE)
		c_CombatTask.target = nil
	else
		ml_log("gw2_task_grind.CombatTask found no target")
	end
	return ml_log(false)
end


ml_global_information.AddBotMode(GetString("grindMode"), gw2_task_grind)
RegisterEventHandler("Module.Initalize",gw2_task_grind.ModuleInit)
