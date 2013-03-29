-- Map & Meshmanager
mm = { }
mm.version = "v1.0";
mm.navmeshfilepath = GetStartupPath() .. [[\Navigation\]];
mm.mainwindow = { name = "NavMeshSwitcher", x = 350, y = 100, w = 200, h = 300}
mm.meshfilelist = {}
mm.currentMapIndex = 0
mm.lastswitchTmr = 0
mm.visible = false

function mm.ModuleInit() 	
	GUI_NewWindow(mm.mainwindow.name,mm.mainwindow.x,mm.mainwindow.y,mm.mainwindow.w,mm.mainwindow.h)	
	GUI_NewLabel(mm.mainwindow.name, "1)Go to the Map you want to add","Add_New_Mesh_To_List")
	GUI_NewLabel(mm.mainwindow.name, "2)Load the NavMesh in NavEditor","Add_New_Mesh_To_List")
	GUI_NewLabel(mm.mainwindow.name, "3)Enter the EXACT NAME of the mesh to field below","Add_New_Mesh_To_List")
	GUI_NewLabel(mm.mainwindow.name, "4)Press the Add current Mesh Button","Add_New_Mesh_To_List")
	GUI_NewLabel(mm.mainwindow.name, "5)Select the new Map entry","Add_New_Mesh_To_List")
	GUI_NewField(mm.mainwindow.name,"Meshname","gnewmeshname","Add_New_Mesh_To_List")
	GUI_NewButton(mm.mainwindow.name,"Add current Mesh","MM.Add","Add_New_Mesh_To_List")
	GUI_NewSeperator(mm.mainwindow.name)
	GUI_NewCheckbox(mm.mainwindow.name,"Enable Switcher","gNavSwitchEnabled")	
	GUI_NewField(mm.mainwindow.name,"Switch after (min)","gNavSwitchTime")
	GUI_NewButton(mm.mainwindow.name,"Refresh List","MM.Refresh")
	GUI_NewSeperator(mm.mainwindow.name)
	GUI_NewButton(mm.mainwindow.name,"Clear List","MM.Clear")
	GUI_NewSeperator(mm.mainwindow.name)
	GUI_NewLabel(mm.mainwindow.name, "Select Maps to use:")
	GUI_FoldGroup(mm.mainwindow.name,"Add_New_Mesh_To_List")
	GUI_WindowVisible(mm.mainwindow.name,false)
	mm.RefreshMeshFileList()
			
	--gNavSwitchEnabled = Settings.GW2MINION.gNavSwitchEnabled
	gNavSwitchEnabled = "0"
	gNavSwitchTime = Settings.GW2MINION.gNavSwitchTime
end

function mm.RefreshMeshFileList()
	wt_debug("Refreshing list")
	for i,meshfile in pairs(mm.meshfilelist) do
		if (i~=nil and meshfile ~= nil) then
			mm.Delete(meshfile.name)
		end
	end	
	for meshfile in io.popen('dir /b "' .. mm.navmeshfilepath ..'*.info"'):lines() do
		meshfile = string.gsub(meshfile, ".info", "")
		
		if (io.open(mm.navmeshfilepath..tostring(meshfile)..".obj")) then
			local file = io.open(mm.navmeshfilepath..tostring(meshfile)..".info", "r")
			if ( file ) then
				meshentry = {}
				meshentry.used = "0"
				meshentry.name = ""
				meshentry.MapID = 0
				meshentry.WPIDList = {}
				meshentry.name = meshfile
				for line in file:lines() do					
					local key, value = string.match(line, "(%w+)=(%w+)")
					if (key == "mapid") then
						meshentry.MapID = value
					elseif (key == "waypoint") then
						table.insert(meshentry.WPIDList,value)
					end
				end
				file:flush()
				file:close()
				
				GUI_NewCheckbox(mm.mainwindow.name,tostring(meshfile),"Mesh_"..tostring(meshfile))						
				if ( Settings.GW2MINION["Mesh_"..tostring(meshfile)] ~= nil) then
					_G[tostring("Mesh_"..tostring(meshfile))] = tostring(Settings.GW2MINION["Mesh_"..tostring(meshfile)])
					meshentry.used = tostring(Settings.GW2MINION["Mesh_"..tostring(meshfile)])					
				end
				table.insert(mm.meshfilelist,meshentry)			
			end
		end
	end		
	
		for i,meshfile in pairs(mm.meshfilelist) do	
			local c = 0
			if (i~=nil and meshfile ~= nil ) then							
				if ( meshfile.WPIDList ~= nil ) then
					for i,wp in pairs(meshfile.WPIDList) do
						if (i~=nil and wp ~= nil) then
							--wt_debug("Ix: "..tostring(i).." X: "..tostring(wp))
							c = c+1
						end
					end						
				end				
			end
			wt_debug("Added Map into Rotation: "..tostring(meshfile.name).. " ID: "..tostring(meshfile.MapID).." WPCount: "..tostring(c))
		end	
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

function mm.GetmeshfilelistSize()
	local count = 0
	for i,meshfile in pairs(mm.meshfilelist) do
		if (i~=nil and meshfile ~= nil and meshfile.used == "1") then
			count = count + 1
		end
	end	
	return count
end

function mm.LoadNavMesh(filename)	
	wt_debug("Loading Navmesh " ..tostring(filename))
	local path = GetStartupPath().."\\Navigation\\"..tostring(filename)
	if (io.open(path..".obj")) then
		NavigationManager:LoadNavMesh(path)
		GUI_CloseMarkerInspector()
		return true
	end
	return false
end

function mm.UnloadNavMesh()		
	wt_debug("Clearing Current Navmesh Data..")	
	NavigationManager:UnloadNavMesh()
	GUI_CloseMarkerInspector()
	wt_debug("Done")	
end

function mm.ClearList()
	wt_debug("Deleting all .info files...")
	for i,meshfile in pairs(mm.meshfilelist) do
		if (i~=nil and meshfile ~= nil) then
			mm.Delete(meshfile.name)
		end
	end	
	mm.meshfilelist = {}
	GUI_RefreshWindow(mm.mainwindow.name)
	for meshfile in io.popen('dir /b "' .. mm.navmeshfilepath ..'*.info"'):lines() do
		os.remove(mm.navmeshfilepath..tostring(meshfile))
	end		
end

function mm.Delete(name)
	GUI_Delete(mm.mainwindow.name,name)
	GUI_RefreshWindow(mm.mainwindow.name)	
end

function mm.ToggleMenu()
	if (mm.visible) then
		GUI_WindowVisible(mm.mainwindow.name,false)	
		mm.visible = false
	else
		GUI_WindowVisible(mm.mainwindow.name,true)	
		mm.visible = true
	end
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


function mm.LoadMesh()
	local mapID = Player:GetLocalMapID()
	if (mapID ~= nil) then
		local meshname = wt_meshloader.meshlist[mapID]
		if (meshname ~= nil and meshname ~= "") then
			wt_debug("Auto-Loading Navmesh " ..tostring(meshname))
			local path = GetStartupPath().."\\Navigation\\"..tostring(meshname)
			if (io.open(path..".obj")) then
				if (NavigationManager:UnloadNavMesh()) then
					NavigationManager:LoadNavMesh(path)
				end
				GUI_CloseMarkerInspector()
			else
				wt_debug("ERROR: Can't open or find the file: "..tostring(meshname))
				wt_debug("CHECK if you have the correct navmesh setup in wt_core_automeshloader.lua file!!")
			end		
		end	
	end
	if ( MultiBotIsConnected( ) ) then		
		MultiBotJoinChannel("gw2minion")
		wt_debug("Successfully Re-Joined MultiBotServer channels !")			
	end	
end

RegisterEventHandler("Gameloop.MapChanged",mm.LoadMesh)
RegisterEventHandler("MM.toggle", mm.ToggleMenu)
RegisterEventHandler("MM.Add", mm.GenerateInfoFile)
RegisterEventHandler("MM.Refresh", mm.RefreshMeshFileList)
RegisterEventHandler("MM.Clear", mm.ClearList)
RegisterEventHandler("GUI.Update",mm.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",mm.ModuleInit)


