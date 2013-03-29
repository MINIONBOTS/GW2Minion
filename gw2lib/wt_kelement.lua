-- The knowledge element consists of:
-- cause: is evaluated and should be true or false
-- effect: is executed if the cause is true
-- priority : defines the priority of the effect. used to determine what effects will be executed

--require 'wt_misc_OO'
--require 'wt_cause'
--require 'wt_effect'
--require 'wt_core_controller'

wt_kelement =  inheritsFrom( nil )
wt_kelement.cause = inheritsFrom( wt_cause )
wt_kelement.effect = inheritsFrom( wt_effect )

wt_kelement.name = "wt_kelement"

function wt_kelement:evaluate()
	if ( type( self.cause ) == "function" ) then
		if ( self:cause() == true ) then
			 wt_core_controller:queue_effect( self.effect )
			 return true
		end
	elseif ( self.cause:SafetyCheck() and self.cause:evaluate() == true ) then
			 wt_core_controller:queue_effect( self.effect )
			 return true
	end

	return false
end

function wt_kelement:create( name, cause, effect, priority )
        local newinst = inheritsFrom( wt_kelement )
        newinst.name = name
        newinst.cause = cause
        newinst.effect = effect
		newinst.effect.name = name
        newinst.effect.priority = priority == nil and wt_effect.priorities.normal or priority
        return newinst
end
