-- Map & Meshmanager
mm = { }
mm.version = "v1.2";
mm.navmeshfilepath = tostring(GetStartupPath()) .. [[\Navigation\]];
mm.mainwindow = { name = "MeshManager", x = 350, y = 100, w = 220, h = 90}
mm.meshfiles = {}
mm.currentmapdata = {}
mm.visible = false
mm.Zones = {
	[15] = "Queensdale",
	[17] = "HarathiHinterlands",
	[18] = "DivinitysReach",
	[19] = "PlainsofAshford",
	[20] = "BlazeridgeSteppes",
	[21] = "FieldsofRuin",
	[22] = "FireheartRise",
	[23] = "KessexHills",
	[24] = "GendarranFields",
	[25] = "IronMarches",
	[26] = "DredgehauntCliffs",
	[27] = "LornarsPass",
	[28] = "WayfarerFoothills",
	[29] = "TimberlineFalls",
	[30] = "FrostgorgeSound",
	[31] = "SnowdenDrifts",
	[32] = "DiessaPlateau",
	[33] = "AscalonianCatacombs(Story)",
	[34] = "CaledonForest",
	[35] = "MetricaProvince",
	[36] = "AscalonianCatacombs(Explo)",
	[38] = "EternalBattlegrounds",
	[39] = "MountMaelstrom",
	[50] = "LionsArch",
	[51] = "StraitsOfDevastation",
	[53] = "SparkflyFen",
	[54] = "BrisbanWildlands",
	[62] = "CursedShore",
	[65] = "MalchorsLeap",
	[66] = "CitadelOfFlames(Story)",
	[73] = "BloodtideCoast",
	[91] = "TheGrove",
	[94] = "BlueGreenRedBorderlands1",
	[95] = "BlueGreenRedBorderlands2",
	[96] = "BlueGreenRedBorderlands3",
	[139] = "RataSum",
	[218] = "BlackCitadel",
	[326] = "Hoelbrak",
	[873] = "SouthsunCove",
}

function mm.ModuleInit() 	
	if (Settings.GW2MINION.Zones == nil) then
		Settings.GW2MINION.Zones = {}
	end
	if (mm.Zones) then
		local id,name = next(mm.Zones)
		while id~=nil and name~=nil do
			if (Settings.GW2MINION.Zones[tostring(id)] == nil) then
				wt_debug("ADD")
				Settings.GW2MINION.Zones[tostring(id)] = { mapname=tostring(name), meshname="none", waypointid="none"}
			end
			id,name = next(mm.Zones,id)
		end
		Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
	end
	
	if (Settings.GW2MINION.gMeshMGR == nil) then
		Settings.GW2MINION.gMeshMGR = "1"
	end
	
	local wnd = GUI_GetWindowInfo("GW2Minion")
	GUI_NewWindow(mm.mainwindow.name,wnd.x+wnd.width,wnd.y,mm.mainwindow.w,mm.mainwindow.h)
	GUI_NewCheckbox(mm.mainwindow.name,"Activated","gMeshMGR")
	GUI_NewField(mm.mainwindow.name,"Mapname","gmapname")
	GUI_NewField(mm.mainwindow.name,"Navmesh","gmeshname")
	GUI_NewField(mm.mainwindow.name,"Waypoint","gwaypointid")
	local count = 0
	-- Grab all meshfiles in our Navigation directory
	for meshfile in io.popen('dir /b "' .. mm.navmeshfilepath ..'*.obj"'):lines() do
		meshfile = string.gsub(meshfile, ".obj", "")		
		if (io.open(mm.navmeshfilepath..tostring(meshfile)..".obj")) then
			local file = io.open(mm.navmeshfilepath..tostring(meshfile)..".obj", "r")
			if ( file ) then					
				table.insert(mm.meshfiles, meshfile)
				file:flush()
				file:close()
								
				GUI_NewButton(mm.mainwindow.name, tostring(meshfile),tostring(meshfile),"Change_NavMesh_for_Zone")
				RegisterEventHandler(tostring(meshfile),mm.ButtonHandler)						
				count = count + 1
			end
		end
	end
	gmapname = ""
	gmeshname = ""
	gwaypointid = ""
	gMeshMGR = Settings.GW2MINION.gMeshMGR
	GUI_SizeWindow(mm.mainwindow.name,mm.mainwindow.w,mm.mainwindow.h+count*15)
	GUI_FoldGroup( mm.mainwindow.name, "Change_NavMesh_for_Zone" ) 
	mm.visible = false
	GUI_WindowVisible(mm.mainwindow.name,false)	
end

function mm.ButtonHandler(event)			
	-- Set the new mesh for the local map
	local mapID = Player:GetLocalMapID()
	if ( Settings.GW2MINION.Zones[mapID] == nil) then
		if (mm.Zones[mapID] == nil) then
			Settings.GW2MINION.Zones[tostring(mapID)] = { mapname="unknown", meshname=tostring(event), waypointid="none" } 
			gmapname = "Unknown"
			gwaypointid = "none"
		else
			Settings.GW2MINION.Zones[tostring(mapID)] = { mapname=tostring(mm.Zones[mapID]), meshname=tostring(event), waypointid="none" } 
			gmapname = tostring(mm.Zones[mapID])
			gwaypointid = "none"
		end
	else
		Settings.GW2MINION.Zones[tostring(mapID)].meshname = tostring(event)		
		gmapname = Settings.GW2MINION.Zones[tostring(mapID)].mapname
		if (Settings.GW2MINION.Zones[tostring(mapID)].waypointid == nil) then
			Settings.GW2MINION.Zones[tostring(mapID)].waypointid = "none"
			gwaypointid = "none"			
		else
			gwaypointid = tostring(Settings.GW2MINION.Zones[tostring(mapID)].waypointid)
		end
	end		
	gmeshname = tostring(event)
	GUI_FoldGroup( mm.mainwindow.name, "Change_NavMesh_for_Zone" ) 
	Settings.GW2MINION.Zones = Settings.GW2MINION.Zones -- save settings
	gMeshMGR = "1"
	mm.visible = false
end

function mm.RefreshCurrentMapData()
	local mapID = Player:GetLocalMapID()
	if (((mm.currentmapdata.mapID == nil and tonumber(mapID) ~= nil) or mm.currentmapdata.mapID ~= mapID) and tonumber(mapID) ~= nil and TableSize(Player.pos) >0 and tonumber(Player.pos.x) ~= nil) then			
		-- Unload old mesh first
		if (NavigationManager:IsNavMeshLoaded() and mm.currentmapdata.mapID ~= nil and mm.currentmapdata.mapID ~= mapID) then
			wt_debug("Unloading old navmesh...")
			wt_global_information.Reset()
			NavigationManager:UnloadNavMesh()
			mm.currentmapdata.mapID = nil
			return false
		end
		-- Load the mesh for our Map
		if ( tonumber(mapID) ~= nil and Settings.GW2MINION.Zones~=nil and Settings.GW2MINION.Zones[tostring(mapID)] ~= nil ) then
			gmapname = Settings.GW2MINION.Zones[tostring(mapID)].mapname
			gmeshname = Settings.GW2MINION.Zones[tostring(mapID)].meshname
			if (Settings.GW2MINION.Zones[tostring(mapID)].waypointid == nil) then
				gwaypointid = "none"			
			else
				gwaypointid = tostring(Settings.GW2MINION.Zones[tostring(mapID)].waypointid)
			end			
			if (gmeshname ~= nil and tostring(gmeshname) ~= "" and tostring(gmeshname) ~= "none") then				
				local path = GetStartupPath().."\\Navigation\\"..tostring(gmeshname)				
				if (io.open(tostring(path)..".obj")) then
					if (NavigationManager:IsNavMeshLoaded()) then
						wt_debug("Unloading Old Navmesh...")
						NavigationManager:UnloadNavMesh()
					else
						wt_debug("Auto-Loading Navmesh " ..tostring(gmeshname))
						wt_core_state_combat.StopCM()
						wt_global_information.Reset()
						wt_core_taskmanager.ClearTasks()
						if (NavigationManager:LoadNavMesh(towstring(path))) then
							mm.currentmapdata.mapID = mapID	
							GUI_CloseMarkerInspector()	
							return true
						end
					end
				else
					wt_error("ERROR: Can't open the file: "..tostring(gmeshname))
				end	
			else				
				wt_debug("Please select a NavMesh for this Zone in the MeshManager")
				gmapname = tostring(Settings.GW2MINION.Zones[tostring(mapID)].mapname)
				gmeshname = "none"
				gwaypointid = "none"
			end				
		else
			gmapname = "none"
			gmeshname = "none"
			gwaypointid	= "none"
		end	
	end
	return false
end

function mm.ToggleMenu()
	if (mm.visible) then
		GUI_WindowVisible(mm.mainwindow.name,false)	
		mm.visible = false
	else
		local wnd = GUI_GetWindowInfo("GW2Minion")	
		GUI_MoveWindow( mm.mainwindow.name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(mm.mainwindow.name,true)	
		mm.visible = true
	end
end


function mm.UnloadNavMesh()		
	wt_debug("Clearing Current Navmesh Data..")	
	NavigationManager:UnloadNavMesh()
end

function mm.LoadNavMesh(filename)	
	wt_debug("Loading Navmesh " ..tostring(filename))
	local path = GetStartupPath().."\\Navigation\\"..tostring(filename)
	if (io.open(path..".obj")) then
	--	NavigationManager:LoadNavMesh(path)
		GUI_CloseMarkerInspector()
		return true
	end
	return false
end



function mm.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		for i,meshfile in pairs(mm.meshfilelist) do
			if (i~=nil and meshfile ~= nil) then
				if ( k == "Mesh_"..tostring(meshfile.name) ) then
					
					Settings.GW2MINION[tostring(k)] = v
					meshfile.used = v
				end
			end
		end
		if ( k == "gNavSwitchEnabled" or k == "gNavSwitchTime") then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end


function mm.GenerateInfoFile( )	
	if (gnewmeshname ~= nil and NavigationManager:IsNavMeshLoaded()) then
		if (io.open(mm.navmeshfilepath..tostring(gnewmeshname)..".obj")) then
			local file = io.open(mm.navmeshfilepath..tostring(gnewmeshname)..".info", "w")
			if file then
				wt_debug("Generating .info file..")
				local mapID = Player:GetLocalMapID()
				if (mapID ~= nil and mapID~=0) then
					file:write("mapid="..mapID.."\n")
					local wps = WaypointList("samezone,onmesh")
					if(wps~=nil) then
						local i,wp = next(wps)
						while (i~=nil and wp~=nil) do
							file:write("waypoint="..wp.contentID.."\n")
							i,wp = next(wps,i)
						end						
					end
				end				
				file:flush()
				file:close()
				mm.RefreshMeshFileList()
			end
		else
			wt_debug("NO MESHFILE WITH THAT NAME EXISTS")
		end
	else
		wt_debug("YOU NEED TO LOAD THE NAVMESH FIRST, AND LEARN TO READ LOL")
	end
end


RegisterEventHandler("MM.toggle", mm.ToggleMenu)
RegisterEventHandler("Module.Initalize",mm.ModuleInit)
