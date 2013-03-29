-- effect trigger actions

--require 'wt_misc_OO'

wt_effect = inheritsFrom( nil )

wt_effect.name = "wt_effect"

wt_effect.priorities = {
	normal = 1,
	high = 1000,
	interrupt = 10000
}

wt_effect.types = {
	once = 1,
	repeating = 2
}

wt_effect.throttle = 0
wt_effect.last_execution = 0
wt_effect.delay = 0
wt_effect.first_execution = 0
wt_effect.type = wt_effect.types.once
wt_effect.priority = wt_effect.priorities.normal
wt_effect.execution_count = 0
wt_effect.max_execution_count = 0

wt_effect.usesAbility = false

-- Checked by the wt_core_controller before the effect is executed , failing the check will not remove the effect from the queue
function wt_effect:SafetyCheck()

	-- If the effect is flagged to use an ability, we check that we are not casting, interacting or the global cooldown is in effect.
	-- If the effect priority is interrupt, we will ignore that fact that we are casting already.
	--wt_debug( "safety_check" )
	if ( self.usesAbility == true ) then
			--if ( wt_global_information:GetGCD() > 0 or wt_global_information.isInteracting() == true or ( wt_global_information.isCasting() and self.priority < wt_effect.priorities.interrupt ) ) then
				--wt_debug( "SafetyCheck false, GCD not ready" )
				--return false
			--end
	end
	
	-- delays the execution, so that some actions performed are able to wait for the game to react proper	
	if ( self.delay > 0 ) then
		if ( self.first_execution == 0 ) then		
			self.first_execution = wt_global_information.Now			
			return false
		else			
			return ( wt_global_information.Now - self.first_execution ) > self.delay
		end		
	end

	if ( self.throttle > 0 ) then
		local Elapsed = ( wt_global_information.Now - self.last_execution )
		--wt_debug( "Elapsed: ".. tostring( Elapsed ) .. " - " .. tostring( self.throttle ) )
		return Elapsed >  self.throttle
	end
	
	return true
end

-- called when the effect should take place.
function wt_effect:execute()

end

-- called before execute is called. the execution of the effect depends
-- on the result of isvalid(). If false the effect is not be executed and removed from the queue
-- the effect should clean up if the result of isvalid() will be false.
function wt_effect:isvalid()

	--wt_debug( "isvalid" )

	if ( self.type == wt_effect.types.once and self.execution_count > 0 ) then
			return false
	end

	if ( self.type == wt_effect.types.repeating and self.max_execution_count > 0 and self.execution_count > self.max_execution_count ) then
			return false
	end

	return true
end

-- called when the effect is interrupted by another effect of a higher priority.
-- the effect can clean up here.
function wt_effect:interrupt()

end
