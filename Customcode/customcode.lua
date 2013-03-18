-- This is an example how to add custom tasks to the bot routine, for events or mapspecific things to do
customcode = { }


function customcode.ModuleInit() 
	-- Registering our custom code within the wt_core_taskmanager.CustomLuaFunctions table in wt_core_taskmanager.lua	
	if (wt_core_taskmanager ~= nil and wt_core_taskmanager.CustomLuaFunctions ~= nil) then
		wt_debug("Adding custom functions to list")
		table.insert(wt_core_taskmanager.CustomLuaFunctions,customcode.executemeee)
	end
end

function customcode.executemeee()
	-- Here I would do conditional checks and add my Custom Tasks to wt_core_taskmanager.Customtask_list
	--wt_debug("HOLYCOWITWORKS")
	local EList = GadgetList("contentID=227767, nearest,onmesh")
	if ( TableSize( EList ) > 0 ) then
		local nextTarget
		nextTarget, egg = next( EList )
		if ( nextTarget ~= nil and nextTarget ~= 0) then
			wt_core_taskmanager:addEggTask(egg) 
		end
	end
end



RegisterEventHandler("Module.Initalize",customcode.ModuleInit)
