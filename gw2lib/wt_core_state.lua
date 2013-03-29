-- state base class
-- states have a list of kelements that are evalutated if the state
-- is run
--require "wt_misc_log"
--require "wt_kelement"
--require "wt_core_controller"

wt_core_state = inheritsFrom( nil )

wt_core_state.name = "core_state"
wt_core_state.kelement_list = { }

function wt_core_state:run()
	-- walk the kelements and evalute them
	for k, elem in pairs( self.kelement_list ) do
		--wt_debug( "Evaluating:" .. tostring( elem.name ) )
		local result = elem:evaluate()
		--wt_debug( "Evaluation Result:" .. tostring( result ) )
	end
end

function wt_core_state:add( kelement )
	wt_debug ( "adding kelement " .. tostring( kelement.name ) )
	if ( kelement ~= nil and kelement.isa ~= nil and kelement:isa( wt_kelement ) ) then
		table.insert( self.kelement_list, kelement )
	else
		wt_error( "invalid kelement, not added" )
	end
end

function wt_core_state:remove( kelement )
	-- Added by Zilvermoon
    wt_debug( "removing kelement " .. tostring( kelement.name ) )
	if ( kelement ~= nil and kelement.isa ~= nil and kelement:isa( wt_kelement ) ) then
		for ek, elmt in pairs( self.kelement_list ) do
			if ( elmt.name == kelement.name ) then
				table.remove( self.kelement_list, ek)
				break
			end
		end
	else
		wt_error( "invalid kelement, not removed" )
	end
end

-- register the state with the core
function wt_core_state:register()
	wt_core_controller:addState( self )  --state_list[ tostring( self ) ] = self
end

function wt_core_state:ShowDebugWindow()
	if ( self.DebugWindowCreated == nil ) then
		wt_debug( "Opening State Debug Window" )
		GUI_NewWindow( self.name, 140, 10, 100, 50 + #self.kelement_list * 14 )

		for k, elem in pairs( self.kelement_list ) do
			GUI_NewButton( self.name, elem.name , self.name .."::" .. elem.name )
		end
		self.DebugWindowCreated  = true
	end
end
