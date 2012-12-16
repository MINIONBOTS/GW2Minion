-- Combat State for all professions
-- Holds "basic" combat routines, every profession has to add it´s own combat cause&effects to this combatstate

wt_core_state_combat = inheritsFrom(wt_core_state)
wt_core_state_combat.name = "Combat"
wt_core_state_combat.kelement_list = { }
wt_core_state_combat.CurrentTarget = 0

--/////////////////////////////////////////////////////
-- Combat over Check
local c_combat_over = inheritsFrom(wt_cause)
local e_combat_over = inheritsFrom(wt_effect)

function c_combat_over:evaluate()
	--local CurrentTarget = Player:GetTarget()
	if ( wt_core_state_combat.CurrentTarget == nil or wt_core_state_combat.CurrentTarget == 0 ) then
		return true
	else
		local T = CharacterList:Get(wt_core_state_combat.CurrentTarget)
		if ( T == nil or not T.alive or (T.attitude == 0 or T.attitude == 3) ) then
			return true
		end
	end
	return false
end

function e_combat_over:execute()
	Player:StopMoving()
	Player:ClearTarget()
	wt_debug("Combat finished")
	wt_core_state_combat.CurrentTarget = 0
	wt_core_controller.requestStateChange(wt_core_state_idle)
	return
end

--/////////////////////////////////////////////////////
-- Search for a better target Check
local c_better_target_search = inheritsFrom(wt_cause)
local e_better_target_search = inheritsFrom(wt_effect)

function c_better_target_search:evaluate()
		c_better_target_search.TargetList = CharacterList("lowesthealth,noCritter,onmesh,attackable,alive,maxdistance="..wt_global_information.AttackRange..",exclude="..wt_core_state_combat.CurrentTarget)
		return (TableSize(c_better_target_search.TargetList) > 0)
end

function e_better_target_search:execute()
	nextTarget , E  = next(c_better_target_search.TargetList)
	if (nextTarget ~=nil) then
		wt_debug("Combat: Switching to better target "..nextTarget)
		Player:StopMoving()
		wt_core_state_combat.setTarget(nextTarget)
	end
end

--/////////////////////////////////////////////////////
-- Sets our target for this combatstate
function wt_core_state_combat.setTarget(CurrentTarget)
	if (CurrentTarget ~= nil and CurrentTarget ~= 0) then
		wt_core_state_combat.CurrentTarget = CurrentTarget
	else
		wt_core_state_combat.CurrentTarget = 0
	end
end

--/////////////////////////////////////////////////////
function wt_core_state_combat:initialize()

		local ke_died = wt_kelement:create("Died",c_died,e_died, wt_effect.priorities.interrupt )
		wt_core_state_combat:add(ke_died)

		local ke_combat_over = wt_kelement:create("combat_over",c_combat_over,e_combat_over, 150 )
		wt_core_state_combat:add(ke_combat_over)

		local ke_quickloot = wt_kelement:create("QuickLoot",c_quickloot,e_quickloot,145)
		wt_core_state_combat:add(ke_quickloot)
		
		local ke_better_target_search = wt_kelement:create("better_target_search",c_better_target_search,e_better_target_search, 125 )
		wt_core_state_combat:add(ke_better_target_search)
end

wt_core_state_combat:initialize()
wt_core_state_combat:register()
