-- Handles Events
gw2_task_events = inheritsFrom(ml_task)
gw2_task_events.name = GetString("doEvents")

function gw2_task_events.Create()
	local newinst = inheritsFrom(gw2_task_events)

    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {}

	newinst.eventID = nil
	newinst.pos = nil
	newinst.eventReached = false
	newinst.eventRadius = 2500
	newinst.maxeventduration = 900000 --15min
	newinst.cureventduration = 0
	newinst.lastEventActionTmr = 0

    return newinst
end

function gw2_task_events:Init()

	-- Dead & Downed handled by parenttask


	-- Move InRange of Event
	self:add(ml_element:create( "MoveToEvent", c_MoveInEventRange, e_MoveInEventRange, 500 ), self.process_elements)

	-- FightAggro
	self:add(ml_element:create( "FightAggro", c_FightAggro, e_FightAggro, 325 ), self.process_elements) --creates immediate queue task for combat

	-- Resting / Wait to heal
	self:add(ml_element:create( "Resting", c_waitToHeal, e_waitToHeal, 300 ), self.process_elements)

	-- Normal Looting & chests
	self:add(ml_element:create( "Looting", c_Looting, e_Looting, 275 ), self.process_elements)

	-- ReviveNPCs
	self:add(ml_element:create( "ReviveNPC", c_event_reviveNPC, e_reviveNPC, 200 ), self.process_elements) -- creates subtask: moveto

	-- Do EventObjectives
	self:add(ml_element:create( "DoEventObjectives", c_DoEventObjectives, e_DoEventObjectives, 100 ), self.process_elements)


	self:AddTaskCheckCEs()
end
function gw2_task_events:task_complete_eval()
	local eventMaxTaskTimer = ml_task_hub:CurrentTask().eventMaxTaskTimer and tonumber(ml_task_hub:CurrentTask().eventMaxTaskTimer) * 1000 or 0
	-- Event timer check
	if ( ml_task_hub:CurrentTask().cureventduration == 0 ) then
		ml_task_hub:CurrentTask().cureventduration = ml_global_information.Now

	elseif ( ml_global_information.Now - ml_task_hub:CurrentTask().cureventduration > ml_task_hub:CurrentTask().maxeventduration and not ml_task_hub:CurrentTask().isTMTask) then

		d("Event maxduration (15 minutes) have passed...moving on")
		ml_blacklist.AddBlacklistEntry(GetString("event"), ml_task_hub:CurrentTask().eventID, "Event", ml_global_information.Now + 1800000)
		return true

	-- for taskmanager, quit task after the set max time is gone or 15min
	elseif ( eventMaxTaskTimer and ml_global_information.Now - ml_task_hub:CurrentTask().cureventduration > ( eventMaxTaskTimer == 0 and 90000 or eventMaxTaskTimer) and ml_task_hub:CurrentTask().isTMTask) then

		d("Task Event maxduration have passed...finishing task")
		ml_blacklist.AddBlacklistEntry(GetString("event"), ml_task_hub:CurrentTask().eventID, "Event", ml_global_information.Now + 1800000)
		return true
	end

	-- Event gone
	local eID = ml_task_hub:CurrentTask().eventID
	if ( eID == nil or TableSize(MapMarkerList("nearest,onmesh,eventID="..eID..",exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event"))))==0 ) then
		if ( not ml_task_hub:CurrentTask().isTMTask or (ml_task_hub:CurrentTask().isTMTask and ml_task_hub:CurrentTask().eventStarted and ml_task_hub:CurrentTask().eventStarted == true )) then
			d("Event Done..")
			if ( ml_task_hub:CurrentTask().eventReached == true and not Player:IsMoving() )  then
				return true
			end
		end
	end
	return false
end

function gw2_task_events.ModuleInit()
	d("gw2_task_events:ModuleInit")


	ml_task_mgr.AddTaskType(GetString("doEvents"), gw2_task_events) -- Allow this task to be selectable in TaskManager
end
RegisterEventHandler("Module.Initalize",gw2_task_events.ModuleInit)

-- TaskManager functions
function gw2_task_events:UIInit_TM()
	ml_task_mgr.NewNumeric("EventID", "eventID")
	ml_task_mgr.NewNumeric("Waiting for Eventstart (s)", "eventMaxTaskTimer")

end
-- TaskManager function: Checks for custom conditions to start this task
function gw2_task_events.CanTaskStart_TM()
	return true
end
-- TaskManager function: Checks for custom conditions to keep this task running
function gw2_task_events.CanTaskRun_TM()
	-- check for the wanted eventID ...
	ml_task_hub:CurrentTask().isTMTask = true
	ml_task_hub:CurrentTask().eventID = tonumber(ml_task_hub:CurrentTask().eventID)
	if ( ml_task_hub:CurrentTask().eventID and tonumber(ml_task_hub:CurrentTask().eventID)>0) then
		local evList = MapMarkerList("isevent,onmesh,exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
		local i,e = next(evList)
		while ( i and e ) do
			if ( e.eventID == tonumber(ml_task_hub:CurrentTask().eventID)) then
				ml_task_hub:CurrentTask().eventStarted = true
				return true
			end
			i,e = next(evList,i)
		end

		-- If we are here, our event was not found, if it started already, we can quit the task now
		if ( ml_task_hub:CurrentTask().eventStarted and ml_task_hub:CurrentTask().eventStarted == true ) then
			d("EventTask is done, finishing it.")
			return false

		else
			ml_log("Waiting for event to start "..tostring(ml_task_hub:CurrentTask().eventMaxTaskTimer).."s")

		end
	end

	return true
end


-- For adding a doEvent Subtask
c_doEvents = inheritsFrom( ml_cause )
e_doEvents = inheritsFrom( ml_effect )
e_doEvents.currentEvent = nil
function c_doEvents:evaluate()
	if ( gDoEvents == "1" ) then
		local evList = MapMarkerList("nearest,isevent,onmesh,exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
		local i,e = next(evList)
		if ( i and e ) then
			local evi = e.eventinfo
			if ( evi and evi.level <= Player.level + 3 ) then
				e_doEvents.currentEvent = e
				return true
			end
		end
	end
	e_doEvents.currentEvent = nil
	return false
end
function e_doEvents:execute()
	ml_log("e_doEvents")
	if ( e_doEvents.currentEvent ) then		
		local newTask = gw2_task_events.Create()
		newTask.eventID = e_doEvents.currentEvent.eventID
		newTask.eventPos = e_doEvents.currentEvent.pos
		ml_task_hub:CurrentTask():AddSubTask(newTask)
		return ml_log(true)
	end
	return ml_log(false)
end



c_MoveInEventRange = inheritsFrom( ml_cause )
e_MoveInEventRange = inheritsFrom( ml_effect )
e_MoveInEventRange.currentEvent = nil
function c_MoveInEventRange:evaluate()
	local eID = ml_task_hub:CurrentTask().eventID

	if ( tonumber(eID)~=nil and tonumber(eID)>0 ) then
		local evList = MapMarkerList("nearest,onmesh,eventID="..eID..",exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
		local i,e = next(evList)
		if ( i and e ) then

			e_MoveInEventRange.currentEvent = e
			if ( ml_task_hub:CurrentTask().eventReached == false) then
				return true

			else
				-- Check if we moved too far away from the event
				local ePos = e.pos
				if (ePos) then
					local dist = Distance2D ( ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, ePos.x, ePos.y)
					if ( dist > ml_task_hub:CurrentTask().eventRadius ) then
						return true
					end
				end
			end
		else
			-- event is gone, make sure we can exit this event task
			if ( not ml_task_hub:CurrentTask().isTMTask or ( ml_task_hub:CurrentTask().isTMTask and ml_task_hub:CurrentTask().eventStarted )) then
				ml_task_hub:CurrentTask().eventReached = true
			end
		end
	end
	e_MoveInEventRange.currentEvent = nil
	return false
end

function e_MoveInEventRange:execute()
	ml_log("e_MoveInEventRange")
	if ( e_MoveInEventRange.currentEvent ) then
		local ePos = e_MoveInEventRange.currentEvent.pos
		if (ePos) then
			local dist = Distance2D ( ml_global_information.Player_Position.x, ml_global_information.Player_Position.y, ePos.x, ePos.y)
			ml_log("Distance: "..tostring(math.floor(dist)))

			if ( ml_task_hub:CurrentTask().eventReached == false) then
				-- get into event range
				if ( dist > 350 ) then

					local newTask = gw2_task_moveto.Create()
					newTask.name = "MoveTo Event"
					newTask.targetPos = ePos
					newTask.targetID = e_MoveInEventRange.currentEvent.eventID
					newTask.targetType = "event"
					newTask.stoppingDistance = math.random(100,300)
					newTask.useWaypoint = true
					ml_task_hub:CurrentTask():AddSubTask(newTask)
					return ml_log(true)

				else
					ml_task_hub:CurrentTask().eventReached = true

				end

			else
				-- Check if we moved too far away from the event we are in
				if ( dist > ml_task_hub:CurrentTask().eventRadius ) then
					ml_log("Moving back into event radius : "..tostring(math.floor(dist)).." < "..tostring(ml_task_hub:CurrentTask().eventRadius))
					if ( not gw2_unstuck.HandleStuck() ) then
						local navResult = tostring(Player:MoveTo(ePos.x,ePos.y,ePos.z,125,false,false,true))
						if (tonumber(navResult) < 0) then
							d("gw2_task_events.MoveBackIntoEventRange result: "..tonumber(navResult))
						end
					end

					ml_task_hub:CurrentTask().eventReached = false
					return ml_log(true)
				end
			end
		end
	end
	return ml_log(false)
end


c_DoEventObjectives = inheritsFrom( ml_cause )
e_DoEventObjectives = inheritsFrom( ml_effect )
e_DoEventObjectives.currentEvent = nil
e_DoEventObjectives.PathThrottleTmr = 0
function c_DoEventObjectives:evaluate()
	local eID = ml_task_hub:CurrentTask().eventID
	if ( tonumber(eID)~=nil and tonumber(eID)>0) then
		local evList = MapMarkerList("nearest,onmesh,eventID="..eID..",exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
		if ( TableSize(evList)>0) then
			local i,e = next(evList)
			if ( i and e ) then
				e_DoEventObjectives.currentEvent = e
				return true
			end
		end
	end
	e_DoEventObjectives.currentEvent = nil
	return false
end
function e_DoEventObjectives:execute()
	ml_log("Do Event Objectives")
	if ( e_DoEventObjectives.currentEvent ) then

			--pick out the first objective
		local evoList = e_DoEventObjectives.currentEvent.eventobjectivelist				
			if ( evoList ) then
				local oid,obj = next(evoList)
				if ( oid and obj ) then
					local objType = obj.type
					-- Add seperate SubTasks here...if you want lol
					if ( objType == GW2.OBJECTIVETYPE.BreakMoral ) then
						ml_log("OBJECTIVETYPE.BreakMoral")
						ml_task_hub:CurrentTask().eventRadius = 3000

					elseif ( objType == GW2.OBJECTIVETYPE.CaptureLocation ) then
						ml_log("OBJECTIVETYPE.CaptureLocation")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.CollectItems ) then
						ml_log("OBJECTIVETYPE.CollectItems")
						ml_task_hub:CurrentTask().eventRadius = 4000

						d("Bot cant handle CollectItems-Events, blacklisting it..")
					ml_blacklist.AddBlacklistEntry(GetString("event"), e_DoEventObjectives.currentEvent.eventID, "CollectItems", ml_global_information.Now + 1800000)
						ml_task_hub:CurrentTask().completed = true

					elseif ( objType == GW2.OBJECTIVETYPE.Counter ) then
						ml_log("OBJECTIVETYPE.Counter")
						-- obj.value1 = 0 when multiple enemies, when 1 enemy then it is the ID of that
						-- obj.value2 = countermax
						-- obj.value4 = currentcount
						ml_task_hub:CurrentTask().eventRadius = 3000
						-- Kill Main Boss
						local target = nil
						if ( tonumber(obj.value1)~=nil and obj.value1 ~= 0 ) then
							target = CharacterList:Get(obj.value1)
							if ( not target ) then
								target = GadgetList:Get(obj.value1)
							end
							if ( target ) then
								local t = Player:GetTarget()
								if ( t and t.id ~= target.id ) then

									-- Create new Subtask Combat
									local newTask = gw2_task_combat.Create()
									newTask.targetID = target.id
									newTask.name = "Event Combat"
									ml_task_hub:Add(newTask.Create(), IMMEDIATE_GOAL, TP_IMMEDIATE)
									return
								end
							end
						end

					elseif ( objType == GW2.OBJECTIVETYPE.KillCount ) then
						ml_log("OBJECTIVETYPE.KillCount")
						-- value 4 = kills left ?
						ml_task_hub:CurrentTask().eventRadius = 3000

					elseif ( objType == GW2.OBJECTIVETYPE.Cull ) then
						ml_log("OBJECTIVETYPE.Cull")
						-- valie 1 and 2 , possibly scaling values ?
						-- value 4 = amount of objects/enemies remaining
						ml_task_hub:CurrentTask().eventRadius = 3000

					elseif ( objType == GW2.OBJECTIVETYPE.Defend ) then
						ml_log("OBJECTIVETYPE.Defend")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.DefendGadget ) then
						ml_log("OBJECTIVETYPE.DefendGadget")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.Escort ) then
						ml_task_hub:CurrentTask().eventRadius = 1500
						ml_log("OBJECTIVETYPE.Escort")
						--Value 4 = ID to escort
						if ( tonumber(obj.value4)~=nil and obj.value4 ~= 0 ) then
							target = CharacterList:Get(obj.value4)
							if ( not target ) then
								target = GadgetList:Get(obj.value4)
							end
							if ( target ) then
								-- Make sure our Target is alive, else revive
								if ( (target.downed or target.dead) and Player.health.percent > 50 and target.distance < 3500) then
									if (not target.isInInteractRange) then
										local tPos = target.pos
										if ( tPos ) then
											if ( not gw2_unstuck.HandleStuck() ) then
												Player:MoveTo(tPos.x,tPos.y,tPos.z,130,false,true,true)
												return true
											end
										end
									else
										Player:StopMovement()
										local t = Player:GetTarget()
										if ( not t or t.id ~= id ) then
											Player:SetTarget( id )
										else
											if ( Player:GetCurrentlyCastedSpell() == ml_global_information.MAX_SKILLBAR_SLOTS ) then
												Player:Interact( id )
												ml_log("Reviving EventTarget..")
												ml_global_information.Wait(1000)
												return true
											end
										end
									end
								end
							end
						end

					elseif ( objType == GW2.OBJECTIVETYPE.EventStatus ) then
						ml_log("OBJECTIVETYPE.EventStatus")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.InteractWithGadget ) then
						ml_log("OBJECTIVETYPE.InteractWithGadget")
						ml_task_hub:CurrentTask().eventRadius = 3500

					elseif ( objType == GW2.OBJECTIVETYPE.Intimidate ) then
						ml_log("OBJECTIVETYPE.Intimidate")
						ml_task_hub:CurrentTask().eventRadius = 3500
						-- value1 == ID of enemy to "intimidate" if there is only 1
						-- value2 = amount of enemies to intimidate (?)

					elseif ( objType == GW2.OBJECTIVETYPE.IntimidateScaled ) then
						ml_log("OBJECTIVETYPE.IntimidateScaled")
						ml_task_hub:CurrentTask().eventRadius = 3500

					elseif ( objType == GW2.OBJECTIVETYPE.RepairGadget ) then
						ml_log("OBJECTIVETYPE.RepairGadget")
						ml_task_hub:CurrentTask().eventRadius = 3500

					elseif ( objType == GW2.OBJECTIVETYPE.Timer ) then
						ml_log("OBJECTIVETYPE.Timer")
						ml_task_hub:CurrentTask().eventRadius = 3500

						-- value2 = current timer (counting down from value3 to 0 in ms)
						-- value3 = start timer value

					elseif ( objType == GW2.OBJECTIVETYPE.Tripwire ) then
						ml_log("OBJECTIVETYPE.Tripwire")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.WvwHold ) then
						ml_log("OBJECTIVETYPE.WvwHold")
						ml_task_hub:CurrentTask().eventRadius = 2500

					elseif ( objType == GW2.OBJECTIVETYPE.WvwOrbResetTimer ) then
						ml_log("OBJECTIVETYPE.WvwOrbResetTimer")
						ml_task_hub:CurrentTask().eventRadius = 4500

					elseif ( objType == GW2.OBJECTIVETYPE.WvwUpgrade ) then
						ml_log("OBJECTIVETYPE.WvwUpgrade")
						ml_task_hub:CurrentTask().eventRadius = 4500

					else
						ml_error("Unhandled EventType !!!! : "..tostring(objType))
						d("Bot cant handle this Event, blacklisting it..")
					ml_blacklist.AddBlacklistEntry(GetString("event"), e_DoEventObjectives.currentEvent.eventID, "UnknownName", ml_global_information.Now + 1800000)
						ml_task_hub:CurrentTask().completed = true
						end
					end
				end
			end


	-- Kill enemies around us
	local target = Player:GetTarget()
	if ( TableSize( target ) > 0 ) then
		if (ml_global_information.Player_SwimState == 0 and target.alive and target.attackable and target.onmesh and target.pathdistance <= ml_task_hub:CurrentTask().eventRadius + 250) then

			ml_task_hub:CurrentTask().lastEventActionTmr = 0
			gw2_skill_manager:Use(target.id)
			return true
		end
	end

	-- try to get a new target
	-- Weakest Aggro in CombatRange first
	local target = gw2_common_functions.GetBestAggroTarget()
	if ( target ) then return ml_log(Player:SetTarget(target.id)) end

	-- Then nearest attackable Gadget
	if ( not target ) then
		local TList = ( GadgetList("nearest,attackable,alive,onmesh,maxdistance="..ml_global_information.AttackRange+250 ..",exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))) )
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				return ml_log(Player:SetTarget(id))
			end
		end
	end

	-- Then nearest attackable Target
	if ( ml_global_information.Now - e_DoEventObjectives.PathThrottleTmr > 2500 ) then
		e_DoEventObjectives.PathThrottleTmr = ml_global_information.Now

		local TList = ( CharacterList("attackable,alive,shortestpath,onmesh,maxpathdistance="..ml_task_hub:CurrentTask().eventRadius+500 ..",exclude_contentid="..ml_blacklist.GetExcludeString(GetString("monsters"))))
		if ( TableSize( TList ) > 0 ) then
			local id, E  = next( TList )
			if ( id ~= nil and id ~= 0 and E ~= nil ) then
				return ml_log(Player:SetTarget(id))
			end
		end
	end

	-- Seems there is nothing to attack nearby...
	if ( not ml_task_hub:CurrentTask().isTMTask or ( ml_task_hub:CurrentTask().isTMTask and ml_task_hub:CurrentTask().eventStarted )) then
		if ( ml_task_hub:CurrentTask().lastEventActionTmr == 0 ) then
			ml_task_hub:CurrentTask().lastEventActionTmr = ml_global_information.Now

		else
			ml_log("Idle in Event: "..tostring(math.floor((ml_global_information.Now - ml_task_hub:CurrentTask().lastEventActionTmr)/1000)).."s/60s")
			if ( ml_global_information.Now - ml_task_hub:CurrentTask().lastEventActionTmr > 60000 ) then

				d("Seems there is a problem with the Event, nothing to attack in the last 60sec, blacklisting it..")
				ml_blacklist.AddBlacklistEntry(GetString("event"), ml_task_hub:CurrentTask().eventID, "Event", ml_global_information.Now + 1800000)
				ml_task_hub:CurrentTask().completed = true
				ml_task_hub:CurrentTask().lastEventActionTmr = 0
			end
		end
	end
	return ml_log(false)
end



c_event_reviveNPC = inheritsFrom( ml_cause )
function c_event_reviveNPC:evaluate()
	if ( Player.inCombat == false ) then
		local CList = CharacterList("shortestpath,selectable,interactable,dead,friendly,npc,onmesh,maxdistance=2500")
		if ( TableSize(CList) > 0 ) then
			local eID = ml_task_hub:CurrentTask().eventID
			if ( tonumber(eID)~=nil and tonumber(eID)>0) then
				local evList = MapMarkerList("nearest,onmesh,eventID="..eID..",exclude_eventid="..ml_blacklist.GetExcludeString(GetString("event")))
				local i,e = next(evList)
				if ( i and e ) then
					local ePos = e.pos
					if (ePos) then

						local id, entity = next( CList )
						while ( id ~= nil and entity~=nil ) do
							local gPos = entity.pos
							if ( gPos ) then
								if ( ml_task_hub:CurrentTask().eventRadius < 1200 ) then
									if ( Distance2D( gPos.x, gPos.y, ePos.x, ePos.y) < 1500) then
										return true
									end
								else
									if ( Distance2D( gPos.x, gPos.y, ePos.x, ePos.y) < ml_task_hub:CurrentTask().eventRadius) then
										return true
									end
								end
							end
							id, entity = next( CList,id )
						end
					end
				end
			end
		end
	end
	return false
end