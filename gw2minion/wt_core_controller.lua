-- the core of the cause and effect engine

wt_core_controller = { }
wt_core_controller.effect_queue = { }
wt_core_controller.execution_queue = { }

-- List of all States in the system
wt_core_controller.state_list = { }
-- Queue of States to identify the next state
wt_core_controller.state_queue = { }
-- The current state the system is in
wt_core_controller.state = nil
wt_core_controller.shouldRun = false

-- To add a new state
function wt_core_controller:addState( state )
	if safe_isA( wt_core_state, state ) then
		wt_core_controller.state_list[ tostring( state ) ] = state
	end
end

-- Queue effect. depending on the priority the effect will be executed
function wt_core_controller:queue_effect( effect )

	if safe_isA( wt_effect, effect ) then
		wt_core_controller.effect_queue[ tostring( effect ) ] = effect
	else
		wt_error( "effect is not wt_effect based" )
	end

end

-- add a effect to be executed
function wt_core_controller:queue_to_execute( )

	local highestPriority = 0
	-- Get the hightest priority in the effect_queue
	for k, effect in pairs( wt_core_controller.effect_queue ) do
		if ( highestPriority < effect.priority ) then
				highestPriority = effect.priority
		end
	end
	--wt_debug( "Highest Priority:" .. highestPriority )
	-- All effect in the execution que with a priority lower then the hightest in the effect cue are removed
	if ( highestPriority > 0 ) then
		for k, effect in pairs( wt_core_controller.execution_queue ) do
			if( effect.priority < highestPriority ) then
				--wt_debug( "Removing:"..effect.name .. "(P:"..effect.priority..")" )
				effect:interrupt()
				wt_core_controller.execution_queue[ k ] = nil
			end
		end
		-- All effects with the hightest priority will be added to the execution que
		for k, effect in pairs( wt_core_controller.effect_queue ) do
			if ( highestPriority == effect.priority ) then
				--wt_debug( "Scheduling:" .. effect.name .. "(P:"..effect.priority..")" )
				effect.execution_count = 0
				wt_core_controller.execution_queue[ tostring( effect ) ] = effect
			end
		end
	end
end

-- Main function that evaluates and executes states
function wt_core_controller.DoState()
	if ( wt_core_controller.state ~= nil ) then
		if ( gGW2MinionState ~= nil ) then
			gGW2MinionState = wt_core_controller.state.name
		end
		--wt_debug( "doing state " .. wt_core_controller.state.name )
		wt_core_controller.effect_queue = { }
		--wt_debug( "calling run " )
		wt_core_controller.state:run() 
		--wt_debug( "calling queue_to_execute" )
		wt_core_controller:queue_to_execute() 
		--wt_debug( "calling execute" )
		wt_core_controller:execute()
	end
end

function wt_core_controller:execute()
	for k, effect in pairs( wt_core_controller.execution_queue ) do
		if ( effect:isvalid() and effect:SafetyCheck() ) then
			effect.execution_count = effect.execution_count + 1
			wt_global_information.LastEffect = effect
			effect.last_execution = wt_global_information.Now
			effect.first_execution = 0					
			if ( gGW2MinionEffect ~= nil ) then
			gGW2MinionEffect = effect.name
			end
			--wt_debug( "execute:" .. effect.name .. " (P:"..effect.priority..")" )
			effect:execute()
		else
			--wt_debug( "removing:" .. effect.name .. " KEY:" ..k .. " (P:"..effect.priority..")" )
			wt_core_controller.execution_queue[ k ] = nil
		end
	end
end

-- requesting a statechange
function wt_core_controller.requestStateChange( toState )

	if safe_isA( wt_core_state, toState ) then
		wt_core_controller.state = toState
		wt_core_controller.execution_queue = { }
		wt_core_controller.effect_queue = { }
	end
end

-- run the statemachine
function wt_core_controller.Run()
	if ( wt_core_controller.shouldRun ) then
		wt_core_controller.DoState()
	end
end

-- on/off switch
function wt_core_controller.ToggleRun()
	wt_core_controller.shouldRun = not wt_core_controller.shouldRun
	wt_global_information.Reset()
	d( "Core Run State:", wt_core_controller.shouldRun )
end

function wt_core_controller:ShowDebugWindow()
	if ( self.DebugWindowCreated == nil ) then
		wt_debug( "Opening Core Debug Window" )
		GUI_NewWindow( "WT_CORE_STATES", 10, 10, 100, 50 + TableSize( self.state_list ) * 14)

		for k, state in pairs( self.state_list ) do
			GUI_NewButton( "WT_CORE_STATES", state.name, "WT_CORE_STATES" .."::" .. state.name )
		end
		self.DebugWindowCreated  = true
	end
end

function wt_core_controller.HandleStateDebugButtons( Event, Button )
	if ( Event == "GUI.Item" ) then
		for k, v in string.gmatch( Button, "(.-)::(.+)") do
			wt_debug( "A:" .. k .. " B:" .. v )
			if ( k == "WT_CORE_STATES" ) then
				for statekey, state in pairs( wt_core_controller.state_list ) do
					if (state.name == v ) then
						state:ShowDebugWindow()
					end
				end
			else
				for statekey, state in pairs( wt_core_controller.state_list ) do
					if ( state.name == k ) then
						for ek, elmt in pairs( state.kelement_list ) do
							if ( elmt.name == v ) then
								wt_debug( "Executing elmt:evaluate() = " .. tostring( elmt:evaluate() ) )
								wt_debug( "Executing effect" )
								elmt.effect:execute()
							end
						end
					end
				end
			end
		end
	end
end

RegisterEventHandler( "GUI.Item", wt_core_controller.HandleStateDebugButtons )
RegisterEventHandler( "Debug.Pulse", wt_core_controller.DoState )
RegisterEventHandler( "GUI_REQUEST_RUN_TOGGLE", wt_core_controller.ToggleRun )
