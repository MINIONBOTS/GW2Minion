-- the cause is evalutated by the the kelement
-- it dictates if the associated effect will be executed

--require 'wt_misc_OO'

wt_cause  =  inheritsFrom( nil )
wt_cause.throttle = 0 -- Make sure to use this ONLY for C&E's that change the State on a successfull Check in the Effect! 
wt_cause.last_execution = 0	

function wt_cause:SafetyCheck()
	if ( self.throttle > 0 ) then
		if (wt_global_information.Now - self.last_execution > self.throttle) then	
			self.last_execution = wt_global_information.Now
			return true
		end
		return false
	end	
	return true
end

function wt_cause:evaluate()
	return false
end

