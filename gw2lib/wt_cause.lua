-- the cause is evalutated by the the kelement
-- it dictates if the associated effect will be executed

--require 'wt_misc_OO'

wt_cause  =  inheritsFrom( nil )

function wt_cause:evaluate()
	return false
end

