-- For Auto-Switching Meshes 

wt_core_state_navswitch = inheritsFrom( wt_core_state )
wt_core_state_navswitch.name = "NavMeshSwitch"
wt_core_state_navswitch.step = 0


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Set new Mesh
local c_set = inheritsFrom( wt_cause )
local e_set = inheritsFrom( wt_effect )
function c_set:evaluate()
	if ( NavigationManager:IsNavMeshLoaded() and NavigationManager:GetTargetMapID() == 0 and mm.GetmeshfilelistSize() > 1) then	
		return true
	end	
	return false
end
function e_set:execute()
	wt_debug( "Selecting Next Map..." )
	local mapindex = math.random(0,mm.GetmeshfilelistSize())
	local lmapid = Player:GetLocalMapID()
	for i,meshfile in pairs(mm.meshfilelist) do			
		if (i~=nil and meshfile ~= nil and i == mapindex and lmapid ~= nil and tonumber(meshfile.MapID) ~= lmapid  ) then							
			if ( meshfile.WPIDList ~= nil ) then
				for i,wp in pairs(meshfile.WPIDList) do
					if (i~=nil and wp ~= nil) then
						if (math.random(0,2) == 1) then
							wt_global_information.TargetWaypointID = wp								
							wt_debug("Next Map selected, ID: "..tostring(meshfile.MapID))	
							NavigationManager:SetTargetMapID(tonumber(meshfile.MapID))
							if (gMinionEnabled == "1" and wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID) then								 
								MultiBotSend( "21;"..meshfile.MapID,"gw2minion" )
								MultiBotSend( "20;"..wt_global_information.TargetWaypointID,"gw2minion" )
							end								
							wt_debug("Next WaypointID: "..tostring(wt_global_information.TargetWaypointID))					
							return true
						end
					end
				end						
			end				
		end
	end
end

 
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Teleport to new mesh
local c_teleport = inheritsFrom( wt_cause )
local e_teleport = inheritsFrom( wt_effect )
function c_teleport:evaluate()
	if ( NavigationManager:IsNavMeshLoaded() and NavigationManager:GetTargetMapID() ~= 0 and NavigationManager:GetTargetMapID() ~= Player:GetLocalMapID() and mm.GetmeshfilelistSize() > 1 ) then		
		for i,meshfile in pairs(mm.meshfilelist) do			
			if (i~=nil and meshfile ~= nil and tonumber(meshfile.MapID) == NavigationManager:GetTargetMapID() ) then
				wt_debug("Targeted MapID: "..tostring(NavigationManager:GetTargetMapID()))
				wt_debug("Targeted WaypointID : " ..tostring( wt_global_information.TargetWaypointID))
				if ( meshfile.WPIDList ~= nil ) then
					for i,wp in pairs(meshfile.WPIDList) do
						wt_debug("WP: " ..tostring(wp).. " Wanted: "..tostring( wt_global_information.TargetWaypointID))
						if (i~=nil and wp ~= nil and tonumber(wp) == tonumber(wt_global_information.TargetWaypointID)) then						
							return true
						end
					end
				end				
			end		
		end
		NavigationManager:SetTargetMapID(0)
	end
	return false
end
e_teleport.throttle = 2500
function e_teleport:execute()
	wt_debug("Teleporting now to WaypointID: "..tostring(wt_global_information.TargetWaypointID))
	wt_global_information.CurrentMarkerList = nil
	wt_global_information.SelectedMarker = nil
	wt_global_information.AttackRange = 1200
	wt_global_information.MaxLootDistance = 1200
	wt_global_information.lastrun = 0
	wt_global_information.InventoryFull = 0
	wt_core_state_vendoring.junksold = false 
	wt_core_state_combat.CurrentTarget = 0
	wt_core_taskmanager.task_list = { }
	wt_core_taskmanager.possible_tasks = { }
	wt_core_taskmanager.current_task = nil
	wt_core_taskmanager.markerList = { }
	wt_global_information.PartyAggroTargets = {}
	wt_global_information.FocusTarget = nil
	wt_global_information.HasRepairMerchant = 0
	wt_global_information.HasVendor = 0
	Player:TeleportToWaypoint(tonumber(wt_global_information.TargetWaypointID))	
end


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Unload Mesh
local c_unload = inheritsFrom( wt_cause )
local e_unload = inheritsFrom( wt_effect )
function c_unload:evaluate()
	if (NavigationManager:IsNavMeshLoaded() and NavigationManager:GetTargetMapID() ~= 0 and NavigationManager:GetTargetMapID() == Player:GetLocalMapID()) then	
		return true
	end	
	return false
end
e_unload.throttle = 2000
e_unload.delay = 3000
function e_unload:execute()
	wt_debug( "Unloading current NavMesh" )
	mm.UnloadNavMesh()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Load new Mesh
local c_load = inheritsFrom( wt_cause )
local e_load = inheritsFrom( wt_effect )
c_load.throttle = 2000
function c_load:evaluate()
	if (not NavigationManager:IsNavMeshLoaded() and NavigationManager:GetTargetMapID() ~= 0 and NavigationManager:GetTargetMapID() == Player:GetLocalMapID()) then
		wt_debug("Waiting a bit before reloading new Mesh...")
		return true
	end
	return false
end
e_load.throttle = 3000
e_load.delay = 5000
function e_load:execute()
	local wps = WaypointList("nearest,samezone")
	if ( TableSize(wps) > 0) then
		local i,wp = next(wps)
		if (i ~= nil and wp ~= nil) then
			for i,meshfile in pairs(mm.meshfilelist) do
				if (i~=nil and meshfile ~= nil and table.contains(meshfile.WPIDList, wp.contentID)) then			
					if (tonumber(meshfile.MapID) == Player:GetLocalMapID()) then
						wt_debug("Loading new Mesh:" ..tostring(meshfile.name))
						if (mm.LoadNavMesh(meshfile.name)) then
							NavigationManager:SetTargetMapID(0)
							wt_global_information.TargetWaypointID = 0
							wt_global_information.LeaderID = nil
							wt_core_controller.requestStateChange( wt_core_state_idle )
						end					
					end
				end
			end	
		end
	end
end


--/////////////////////////////////////////////////////
function wt_core_state_navswitch:initialize()

		local ke_died = wt_kelement:create( "Died", c_died, e_died, wt_effect.priorities.interrupt )
		wt_core_state_navswitch:add( ke_died )

		local ke_maggro = wt_kelement:create( "AggroCheck", c_aggro, e_aggro, 100 )
		wt_core_state_navswitch:add( ke_maggro )
		
		local ke_setTarget = wt_kelement:create( "SelectNewMap", c_set, e_set, 75 )
		wt_core_state_navswitch:add( ke_setTarget )
		
		local ke_teleport = wt_kelement:create( "Teleport", c_teleport, e_teleport, 75 )
		wt_core_state_navswitch:add( ke_teleport )		
		
		local ke_unload = wt_kelement:create( "UnloadMesh", c_unload, e_unload, 50 )
		wt_core_state_navswitch:add( ke_unload )
		
		local ke_load = wt_kelement:create( "LoadMesh", c_load, e_load, 25 )
		wt_core_state_navswitch:add( ke_load )		
end

-- setup kelements for the state
wt_core_state_navswitch:initialize()
-- register the State with the system
wt_core_state_navswitch:register()
