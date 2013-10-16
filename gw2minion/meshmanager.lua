-- Map & Meshmanager
mm = { }
mm.version = "v1.2";
mm.navmeshfilepath = GetStartupPath() .. [[\Navigation\]];
mm.mainwindow = { name = strings[gCurrentLanguage].meshManager, x = 350, y = 100, w = 220, h = 250}
mm.meshfiles = {}
mm.currentmapdata = {} 
mm.visible = false
mm.switchTime = 0
mm.Zones = {
	[15] = strings[gCurrentLanguage].queensdale,
	[17] = strings[gCurrentLanguage].harathiHinterlands,
	[18] = strings[gCurrentLanguage].divinitysReach,
	[19] = strings[gCurrentLanguage].plainsOfAshford,
	[20] = strings[gCurrentLanguage].blazeridgeSteppes,
	[21] = strings[gCurrentLanguage].fieldsOfRuin,
	[22] = strings[gCurrentLanguage].fireheartRise,
	[23] = strings[gCurrentLanguage].kessexHills,
	[24] = strings[gCurrentLanguage].gendarranFields,
	[25] = strings[gCurrentLanguage].ironMarches,
	[26] = strings[gCurrentLanguage].dredgehauntCliffs,
	[27] = strings[gCurrentLanguage].lornarsPass,
	[28] = strings[gCurrentLanguage].wayfarerFoothills,
	[29] = strings[gCurrentLanguage].timberlineFalls,
	[30] = strings[gCurrentLanguage].frostgorgeSound,
	[31] = strings[gCurrentLanguage].snowdenDrifts,
	[32] = strings[gCurrentLanguage].diessaPlateau,
	[33] = strings[gCurrentLanguage].ascalonianCatacombsStory,
	[34] = strings[gCurrentLanguage].caledonForest,
	[35] = strings[gCurrentLanguage].metricaProvince,
	[36] = strings[gCurrentLanguage].ascalonianCatacombsExp,
	[38] = strings[gCurrentLanguage].eternalBattlegrounds,
	[39] = strings[gCurrentLanguage].mountMaelstrom,
	[50] = strings[gCurrentLanguage].lionsArch,
	[51] = strings[gCurrentLanguage].straightsOfDevastation,
	[53] = strings[gCurrentLanguage].sparkflyFen,
	[54] = strings[gCurrentLanguage].brisbanWildlands,
	[62] = strings[gCurrentLanguage].cursedShore,
	[65] = strings[gCurrentLanguage].malchorsLeap,
	[66] = strings[gCurrentLanguage].citadelOfFlamesStory,
	[69] = strings[gCurrentLanguage].citadelOfFlamesExp,
	[73] = strings[gCurrentLanguage].bloodtideCoast,
	[91] = strings[gCurrentLanguage].theGrove,
	[94] = strings[gCurrentLanguage].borderlands1,
	[95] = strings[gCurrentLanguage].borderlands2,
	[96] = strings[gCurrentLanguage].borderlands3,
	[139] = strings[gCurrentLanguage].rataSum,
	[218] = strings[gCurrentLanguage].blackCitadel,
	[326] = strings[gCurrentLanguage].hoelbrak ,
	[795] = strings[gCurrentLanguage].legacyofthefoefire,
	[873] = strings[gCurrentLanguage].southsunCove,
	[894] = strings[gCurrentLanguage].spiritwatch,
	[929] = "Pavillion",
}

function mm.ModuleInit() 	
	if (Settings.GW2MINION.Zones == nil) then
		Settings.GW2MINION.Zones = {}
	end
	if (mm.Zones) then
		local id,name = next(mm.Zones)
		while id~=nil and name~=nil do
			if (Settings.GW2MINION.Zones[tostring(id)] == nil) then
				--wt_debug("ADD")
				Settings.GW2MINION.Zones[tostring(id)] = { mapname=tostring(name), meshname="none", waypointid="none", useinswitcher = "0"}
            elseif (Settings.GW2MINION.Zones[tostring(id)].useinswitcher == nil) then
                Settings.GW2MINION.Zones[tostring(id)].useinswitcher = "0"
            end
			id,name = next(mm.Zones,id)
		end
		Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
	end
	
	if (Settings.GW2MINION.gMeshMGR == nil) then
		Settings.GW2MINION.gMeshMGR = "1"
	end
    if (Settings.GW2MINION.gEnableSwitcher == nil) then
        Settings.GW2MINION.gEnableSwitcher = "0"
    end
    if (Settings.GW2MINION.gminswitchtime == nil) then
        Settings.GW2MINION.gminswitchtime = "1800"
    end
    if (Settings.GW2MINION.gmaxswitchtime == nil) then
        Settings.GW2MINION.gmaxswitchtime = "3600"
    end
    if (Settings.GW2MINION.gparanoiaswitch == nil) then
        Settings.GW2MINION.gparanoiaswitch = "0"
    end
    if (Settings.GW2MINION.gparanoiaswitchcount == nil) then
        Settings.GW2MINION.gparanoiaswitchcount = "3"
    end
    
	local wnd = GUI_GetWindowInfo("GW2Minion")
	GUI_NewWindow(mm.mainwindow.name,wnd.x+wnd.width,wnd.y,mm.mainwindow.w,mm.mainwindow.h)
	GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].activated,"gMeshMGR",strings[gCurrentLanguage].generalSettings)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].mapName,"gmapname",strings[gCurrentLanguage].generalSettings)
	GUI_NewComboBox(mm.mainwindow.name,strings[gCurrentLanguage].navmesh ,"gmeshname",strings[gCurrentLanguage].generalSettings,"")
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].waypoint,"gwaypointid",strings[gCurrentLanguage].generalSettings)
	GUI_NewButton(mm.mainwindow.name,strings[gCurrentLanguage].getWaypoint,"getWaypointEvent",strings[gCurrentLanguage].generalSettings)
    GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].useInSwitcher,"guseinswitcher",strings[gCurrentLanguage].generalSettings)
	GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].enableSwitcher,"gEnableSwitcher",strings[gCurrentLanguage].switcherSettings)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].minSwitchTime,"gminswitchtime",strings[gCurrentLanguage].switcherSettings)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].maxSwitchTime,"gmaxswitchtime",strings[gCurrentLanguage].switcherSettings)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].switchTimer,"gswitchtimer",strings[gCurrentLanguage].switcherSettings)
    GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].enablePSwitch,"gparanoiaswitch",strings[gCurrentLanguage].switcherSettings)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].pSwitchCount,"gparanoiaswitchcount",strings[gCurrentLanguage].switcherSettings)
	
	--Grab all meshfiles in our Navigation directory
	local count = 0
	local meshlist = "none"
	local meshfilelist = dirlist(mm.navmeshfilepath,".*obj")
	if ( TableSize(meshfilelist) > 0) then
		local i,meshname = next ( meshfilelist)
		while i and meshname do
			meshname = string.gsub(meshname, ".obj", "")
			table.insert(mm.meshfiles, meshname)
			meshlist = meshlist..","..meshname
			i,meshname = next ( meshfilelist,i)
		end
	end
			
	gMeshEditor = "0"
	gMeshEditor2 = "0"
	if (Settings.GW2MINION.gnewmeshname == nil) then
		Settings.GW2MINION.gnewmeshname = ""
	end
	GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].showMesh,"gMeshEditor",strings[gCurrentLanguage].editor)
	GUI_NewCheckbox(mm.mainwindow.name,strings[gCurrentLanguage].showrealMesh,"gMeshEditor2",strings[gCurrentLanguage].editor)
	GUI_NewField(mm.mainwindow.name,strings[gCurrentLanguage].newMeshName,"gnewmeshname",strings[gCurrentLanguage].editor)
	GUI_NewButton(mm.mainwindow.name,strings[gCurrentLanguage].newMesh,"newMeshEvent",strings[gCurrentLanguage].editor)
	GUI_NewButton(mm.mainwindow.name,strings[gCurrentLanguage].saveMesh,"saveMeshEvent",strings[gCurrentLanguage].editor)
	GUI_NewButton(mm.mainwindow.name,strings[gCurrentLanguage].buildNAVMesh,"buildMeshEvent",strings[gCurrentLanguage].editor)
	
	
	RegisterEventHandler("newMeshEvent",mm.CreateNewMesh)
	RegisterEventHandler("saveMeshEvent",mm.SaveMesh)
	RegisterEventHandler("buildMeshEvent",mm.BuildMesh)
    RegisterEventHandler("getWaypointEvent",mm.GetWaypoint)


	gmeshname_listitems = meshlist
	gmapname = ""
	gwaypointid = ""
    gEnableSwitcher = Settings.GW2MINION.gEnableSwitcher
    gminswitchtime = Settings.GW2MINION.gminswitchtime
    gmaxswitchtime = Settings.GW2MINION.gmaxswitchtime
    gparanoiaswitch = Settings.GW2MINION.gparanoiaswitch
    gparanoiaswitchcount = Settings.GW2MINION.gparanoiaswitchcount
    gswitchtimer = ""
    guseinswitcher = "0"
	gnewmeshname = ""
	gMeshMGR = Settings.GW2MINION.gMeshMGR
    
end

function mm.CreateNewMesh()
	wt_debug("Creating NEW MESH")
	-- Unload old Mesh
	if (NavigationManager:IsNavMeshLoaded()) then
		wt_debug("Unloading old NavMesh...")
		wt_debug("Result: "..tostring(NavigationManager:UnloadNavMesh()))
	end
	
	if ( gnewmeshname ~= nil and gnewmeshname ~= "" ) then
		-- Make sure file doesnt exist
		local found = false		
		local meshfilelist = dirlist(mm.navmeshfilepath,".*obj")
		if ( TableSize(meshfilelist) > 0) then
			local i,meshname = next ( meshfilelist)
			while i and meshname do
				meshname = string.gsub(meshname, ".obj", "")
				if (meshname == gnewmeshname) then
					wt_error("Mesh with that Name exists already...")
					found = true
					break
				end
				i,meshname = next ( meshfilelist,i)
			end
		end
		if (not found) then
			-- Setup everything for new mesh
			gmeshname_listitems = gmeshname_listitems..","..gnewmeshname
			gmeshname = gnewmeshname
			mm.SaveMesh()
			mm.ChangeNavMesh(gmeshname)
		end
	else
		wt_error("Enter a new MeshName first!")
	end
end

function mm.SaveMesh()
	wt_debug("Saving NavMesh...")
	if (gmeshname ~= nil and gmeshname ~= "" and gmeshname ~= "none") then
		wt_debug("Result: "..tostring(NavigationManager:SaveNavMesh(gmeshname)))
	else
		wt_error("MeshName field is empty!?")
	end	
end

function mm.BuildMesh()
	wt_debug("Building NAV-Meshfile...")
	if (gmeshname ~= nil and gmeshname ~= "" and gmeshname ~= "none") then
		if (NavigationManager:IsNavMeshLoaded()) then			
			wt_debug("Unloading current Navmesh first....")
			NavigationManager:UnloadNavMesh()
		else
			wt_debug("Result: "..tostring(NavigationManager:LoadNavMesh(mm.navmeshfilepath..gmeshname)))
		end
	else
		wt_error("MeshName field is empty!?")
	end
end

function mm.ChangeNavMesh(newmesh)			
	-- Set the new mesh for the local map
	local mapID = Player:GetLocalMapID()
	if ( Settings.GW2MINION.Zones[tostring(mapID)] == nil) then
		if (mm.Zones[mapID] == nil) then
			Settings.GW2MINION.Zones[tostring(mapID)] = { mapname="unknown", meshname=newmesh, waypointid="none", useinswitcher = "0"} 
			gmapname = "Unknown"
			gwaypointid = "none"
            guseinswitcher = "0"
		else
			Settings.GW2MINION.Zones[tostring(mapID)] = { mapname=mm.Zones[mapID], meshname=newmesh, waypointid="none", useinswitcher = "0" } 
			gmapname = mm.Zones[mapID]
			gwaypointid = "none"
            guseinswitcher = "0"
		end
	else	
		if (Settings.GW2MINION.Zones[tostring(mapID)].meshname ~= newmesh) then
			mm.currentmapdata.mapID = nil -- make it reload the navmesh since it changed
		end
		Settings.GW2MINION.Zones[tostring(mapID)].meshname = newmesh		
		gmapname = Settings.GW2MINION.Zones[tostring(mapID)].mapname
		if (Settings.GW2MINION.Zones[tostring(mapID)].waypointid == nil) then
			Settings.GW2MINION.Zones[tostring(mapID)].waypointid = "none"
			gwaypointid = "none"			
		else
			gwaypointid = tostring(Settings.GW2MINION.Zones[tostring(mapID)].waypointid)
		end
        if (Settings.GW2MINION.Zones[tostring(mapID)].useinswitcher == nil) then
			Settings.GW2MINION.Zones[tostring(mapID)].useinswitcher = "0"
			guseinswitcher = "0"	
		else
			guseinswitcher = tostring(Settings.GW2MINION.Zones[tostring(mapID)].useinswitcher)
		end
	end	
	gmeshname = newmesh	
	Settings.GW2MINION.Zones = Settings.GW2MINION.Zones -- save settings
	
	gMeshMGR = "1"
end

function mm.RefreshCurrentMapData()
	if (gMeshMGR == "1") then 
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
                if (Settings.GW2MINION.Zones[tostring(mapID)].useinswitcher == nil) then
					guseinswitcher = "0"			
				else
					guseinswitcher = tostring(Settings.GW2MINION.Zones[tostring(mapID)].useinswitcher)
				end		
				if (gmeshname ~= nil and gmeshname ~= "" and gmeshname ~= "none") then				
					local path = mm.navmeshfilepath..gmeshname
					if (NavigationManager:IsNavMeshLoaded()) then
						wt_debug("Unloading Old Navmesh...")
						NavigationManager:UnloadNavMesh()
					else
						wt_debug("Auto-Loading Navmesh " ..gmeshname)
						wt_core_state_combat.StopCM()
						wt_global_information.Reset()
						wt_core_taskmanager.ClearTasks()
						if (NavigationManager:LoadNavMesh(path)) then
							mm.currentmapdata.mapID = mapID	
							GUI_CloseMarkerInspector()	
							return true
						else
							wt_error("Error loading Navmesh: "..path)
						end
					end	
				else				
					wt_debug("Please select a NavMesh for this Zone in the MeshManager")
					gmapname = Settings.GW2MINION.Zones[tostring(mapID)].mapname
					gmeshname = "none"
					gwaypointid = "none"
                    guseinswitcher = "0"
				end				
			else
				gmapname = "none"
				gmeshname = "none"
				gwaypointid	= "none"
                guseinswitcher = "0"
			end	
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
	wt_debug("Loading Navmesh: " ..filename)
	local path = mm.navmeshfilepath..filename
	local result = false
	result = NavigationManager:LoadNavMesh(path)
	GUI_CloseMarkerInspector()
	return result
end

function mm.GetWaypoint()
    local wpList = WaypointList("onmesh,nearest")
    if (TableSize(wpList) > 0) then
        local id, wp = next(wpList)
        if (id ~= nil) then
            local newWP = WaypointList:Get(id)
			if ( newWP ) then
				gwaypointid = tostring(newWP.contentID)
				local lmapID = Player:GetLocalMapID()
				if (tonumber(lmapID) ~= nil) then
					if ( Settings.GW2MINION.Zones[tostring(lmapID)] ) then
						Settings.GW2MINION.Zones[tostring(lmapID)].waypointid = gwaypointid
						Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
					else
						Settings.GW2MINION.Zones[tostring(lmapID)] = { mapname="unknown", meshname="none", waypointid=gwaypointid, useinswitcher = "0"}
					end
					Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
				end
			end
        end
    end
end

function mm.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do		
		if ( k == "gmeshname") then
			mm.ChangeNavMesh(v)
		elseif( k == "gMeshEditor") then
			if (v == "1") then
				NavigationManager:ToggleNavEditor(true)
			else
				NavigationManager:ToggleNavEditor(false)
			end
		elseif( k == "gMeshEditor2") then
			if (v == "1") then
				NavigationManager:ShowNavMesh(true)
			else
				NavigationManager:ShowNavMesh(false)
			end
		elseif( k == "gMeshMGR" or k == "gnewmeshname" or k == "gEnableSwitcher" or
                k == "gminswitchtime" or k == "gmaxswitchtime" or k == "gparanoiaswitch" or 
                k == "gparanoiaswitchcount" ) then
			Settings.GW2MINION[tostring(k)] = v
        elseif( k == "guseinswitcher" ) then
            Settings.GW2MINION.Zones[tostring(Player:GetLocalMapID())].useinswitcher = guseinswitcher
            Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
        elseif( k == "gwaypointid" ) then
            Settings.GW2MINION.Zones[tostring(Player:GetLocalMapID())].waypointid = gwaypointid
            Settings.GW2MINION.Zones = Settings.GW2MINION.Zones
        end
	end
	GUI_RefreshWindow(mm.mainwindow.name)
end

--[[ not used anymore 
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
end]]

--*************************************************************************************************************
-- ChangeMap Cause/Effect
--*************************************************************************************************************
c_mapchange = inheritsFrom( wt_cause )
e_mapchange = inheritsFrom( wt_effect )

c_mapchange.nextMap         = 0
c_mapchange.nextWp          = 0
c_mapchange.playerCount     = 0
c_mapchange.doSwitch		= false
c_mapchange.tickCount       = 0
c_mapchange.throttle		= 2000
e_mapchange.throttle 		= 5000
e_mapchange.attempts 		= 0

function c_mapchange:evaluate()
	if (gEnableSwitcher == "0") then
		return false
	end
    -- If we are minion then our min/max switch time is irrelevant and we do not control switching
	if  (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() ~= 1) then
        gminswitchtime = "***"
        gmaxswitchtime = "***"
        return false
    elseif (gminswitchtime == "***" or gmaxswitchtime == "***") then
        gminswitchtime = tonumber(Settings.GW2MINION.gminswitchtime)
        gmaxswitchtime = tonumber(Settings.GW2MINION.gmaxswitchtime)
    end
    
    if 	(gEnableSwitcher == "1" and mm.switchTime == 0) then
        mm.switchTime = wt_global_information.Now + (math.random(tonumber(gminswitchtime),tonumber(gmaxswitchtime)) * 1000)
        if (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1) then
            MultiBotSend( "20;"..tostring(mm.switchTime),"gw2minion" )
        end
	end
	
    if (c_mapchange.doSwitch) then
		if 	c_mapchange.nextMap and
			c_mapchange.nextMap ~= 0 and
			c_mapchange.nextWp and
			c_mapchange.nextWp ~= 0
		then
			return true
		else
			local maps = {}
			if (Settings.GW2MINION.Zones ~= nil and TableSize(Settings.GW2MINION.Zones) > 0) then
				mapid, zone = next(Settings.GW2MINION.Zones)
				while (mapid ~= nil and zone ~= nil) do
					if (zone.useinswitcher == "1" and zone.waypointid ~= nil and zone.waypointid ~= "") then
						table.insert(maps, {wpid=tonumber(zone.waypointid),mapid=tonumber(mapid)})
					end
					mapid, zone = next(Settings.GW2MINION.Zones,mapid)
				end
			end
			local rnd = math.random(1,#maps)
			local map = maps[rnd]
			if 	map.mapid and map.wpid and
				map.mapid ~= Player:GetLocalMapID()
			then
				wt_debug("Selecting New Map")
				c_mapchange.nextMap = map.mapid
				c_mapchange.nextWp = map.wpid
				return true
			end
		end
	end
	
	if (gEnableSwitcher == "1" and mm.switchTime ~= 0) then
        local ticksLeft = mm.switchTime - wt_global_information.Now
        if (ticksLeft <= 0) then
			c_mapchange.doSwitch = true
		end
	end
	
	if (not c_mapchange.doSwitch and gparanoiaswitch == "1") then
		-- Check to see if other players are on the map
		if (c_mapchange.tickCount == 0 or (c_mapchange.tickCount ~= 0 and wt_global_information.Now > c_mapchange.tickCount)) then
			local charList = CharacterList("onmesh,player,maxdistance=3000")
			if (TableSize(charList) > 0) then
				local id, char = next(charList)
				while (id ~= nil and char ~= nil) do
					if not (wt_core_helpers:IsInPartyList(char.name)) then
						c_mapchange.tickCount = math.random(30000,90000) + wt_global_information.Now
                        c_mapchange.playerCount = c_mapchange.playerCount + 1
                        --wt_debug("Player detected: "..char.name.. " - Count: "..tostring(c_mapchange.playerCount))
                        if (c_mapchange.playerCount >= tonumber(gparanoiaswitchcount)) then
                            wt_debug("Paranoia count exceeded - switching maps")
                            c_mapchange.doSwitch = true
                            c_mapchange.playerCount = 0
                            c_mapchange.tickCount = 0
                        end
						break
					end
					id, char = next(charList, id)
				end
			end
        end
	end

	return false
end

function e_mapchange:execute()
	if Player.inCombat then
		wt_debug("inCombat")
		return
	end
	
	if 	c_mapchange.nextMap and
		c_mapchange.nextMap ~= 0 and
		c_mapchange.nextWp and
		c_mapchange.nextWp ~= 0 and
		e_mapchange.attempts < 10 and
		Inventory:GetInventoryMoney() > 500
	then
		if c_mapchange.nextMap ~= Player:GetLocalMapID() then
			wt_debug("Attempt to Change Map: " ..tostring(c_mapchange.nextMap).." | "..tostring(c_mapchange.nextWp))
			Player:StopMoving()
			Player:TeleportToWaypoint(c_mapchange.nextWp)
			e_mapchange.attempts = e_mapchange.attempts + 1
			return
		else
            mm.switchTime = 0
			c_mapchange.doSwitch = false
			wt_debug("Success Changing Map: " ..tostring(c_mapchange.nextMap).." | "..tostring(c_mapchange.nextWp))
		end
	else
		wt_debug("Error Changing Map: " ..tostring(c_mapchange.nextMap).." | "..tostring(c_mapchange.nextWp))
	end
	
	c_mapchange.nextMap = 0
	c_mapchange.nextWp = 0
	e_mapchange.attempts = 0

end

local ke_mapchange = wt_kelement:create( "MapChange", c_mapchange, e_mapchange, 86 )
wt_core_state_idle:add( ke_mapchange )
wt_core_state_leader:add( ke_mapchange )
wt_core_state_minion:add( ke_mapchange )

RegisterEventHandler( "Gameloop.Update",
	function(module, tickcount)
		if (gEnableSwitcher == "1" and mm.switchTime ~= 0) then
            gswitchtimer = tostring(math.floor((tonumber(mm.switchTime) - tickcount) / 1000))
        elseif (gEnableSwitcher == "0") then
            gswitchtimer = ""
        end
	end
)

RegisterEventHandler("NavigationManager.toggle", mm.ToggleMenu)
RegisterEventHandler("GUI.Update",mm.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",mm.ModuleInit)

