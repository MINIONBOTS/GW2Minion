-- AutoMeshLoader
-- Here you can define the navmesh that will automatically get loaded once you enter a zone or move to a new zone when you have autostartbot enabled

wt_meshloader = { }

-- Write the navmeshname you want to use for each zone behind the map where you want it to be automatically loaded
wt_meshloader.meshlist = {
	--Queensdale:
	[15] = "",
	--HarathiHinterlands:
	[17] = "",
	--DivinitysReach:
	[18] = "",
	--PlainsofAshford:
	[19] = "[1-15]AshfordPlains",
	--BlazeridgeSteppes:
	[20] = "",
	--FieldsofRuin:
	[21] = "",
	--FireheartRise:
	[22] = "",
	--KessexHills:
	[23] = "",
	--GendarranFields:
	[24] = "",
	--IronMarches:
	[25] = "",
	--DredgehauntCliffs:
	[26] = "",
	--LornarsPass:
	[27] = "",
	--WayfarerFoothills:
	[28] = "",
	--TimberlineFalls:
	[29] = "",
	--FrostgorgeSound:
	[30] = "",
	--SnowdenDrifts:
	[31] = "",
	--DiessaPlateau:
	[32] = "",
	--AscalonianCatacombs:
	[33] = "AC",
	--CaledonForrest:
	[34] = "",
	--MetricaProvince:
	[35] = "",
	--EternalBattlegrounds:
	[38] = "",
	--MountMaelstrom:
	[39] = "",
	--LionsArch:
	[50] = "",
	--StraitsofDevastation:
	[51] = "",
	--SparkflyFen:
	[53] = "",
	--BrisbanWildlands:
	[54] = "",
	--CursedShore:
	[62] = "",
	--MalchorsLeap:
	[65] = "",
	--BloodtideCoast:
	[73] = "",
	--TheGrove:
	[91] = "",
	--BlueGreenRedBorderlands1:
	[94] = "",
	--BlueGreenRedBorderlands2:
	[95] = "",
	--BlueGreenRedBorderlands3:
	[96] = "",
	--RataSum:
	[139] = "",
	--BlackCitadel:
	[218] = "",
	--Hoelbrak:
	[326] = "",
	--SouthsunCove:
	[873] = ""
}


function wt_meshloader.LoadMesh()
	local mapID = Player:GetLocalMapID()
	if (mapID ~= nil) then
		local meshname = wt_meshloader.meshlist[mapID]
		if (meshname ~= nil and meshname ~= "") then
			wt_debug("Auto-Loading Navmesh " ..tostring(meshname))
			local path = GetStartupPath().."\\Navigation\\"..tostring(meshname)
			if (io.open(path..".obj")) then
				NavigationManager:UnloadNavMesh()				
				NavigationManager:LoadNavMesh(path)
				GUI_CloseMarkerInspector()
			else
				wt_debug("ERROR: Can't open or find the file: "..tostring(meshname))
				wt_debug("CHECK if you have the correct navmesh setup in wt_core_automeshloader.lua file!!")
			end		
		end	
	end
end

RegisterEventHandler("Gameloop.MapChanged",wt_meshloader.LoadMesh)