-- Main config file of GW2Minion

wt_global_information = {}
wt_global_information.Currentprofession = nil
wt_global_information.Now = 0
wt_global_information.PVP = false
wt_global_information.MainWindow = { Name = "GW2Minion", x=100, y=120 , width=200, height=220 }
wt_global_information.BtnStart = { Name="StartStop" ,Event = "GUI_REQUEST_RUN_TOGGLE" }
wt_global_information.BtnPulse = { Name="Pulse" ,Event = "Debug.Pulse" }
wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel = 3  
wt_global_information.CurrentMarkerList = nil
wt_global_information.SelectedMarker = nil
wt_global_information.AttackRange = 1200
wt_global_information.MaxLootDistance = 1200 -- Now used by "c_check_loot::evaluate()" in "wt_core_state_idle.lua"
wt_global_information.MaxReviveDistance = 800 -- New global used by "c_check_revive:evaluate()" in "wt_core_state_idle.lua"
wt_global_information.MaxGatherDistance = 4000
wt_global_information.MaxAggroDistanceFar = 1200
wt_global_information.MaxAggroDistanceClose = 500
wt_global_information.MaxSearchEnemyDistance = 2500
wt_global_information.lastrun = 0
wt_global_information.InventoryFull = 0
wt_global_information.HasVendor = true
wt_global_information.HasRepairMerchant = true

gw2minion = { }

if (Settings.GW2MINION.version == nil ) then
	-- Init Settings for Version 1
	Settings.GW2MINION.version = 1.0
	Settings.GW2MINION.gEnableLog = "0"
end

if (Settings.GW2MINION.version <= 1.32 ) then
	Settings.GW2MINION.version = 1.33
	Settings.GW2MINION.gGW2MinionPulseTime = "150"
	Settings.GW2MINION.gEnableRepair = "0"
	Settings.GW2MINION.gIgnoreMarkerCap = "0"	
	Settings.GW2MINION.gMaxItemSellRarity = "2"
end

function wt_global_information.OnUpdate( event, tickcount )
	wt_global_information.Now = tickcount

	gGW2MiniondeltaT = tostring(tickcount - wt_global_information.lastrun)
	if (tickcount - wt_global_information.lastrun > tonumber(gGW2MinionPulseTime)) then
		wt_global_information.lastrun = tickcount	
		wt_core_controller.Run()
		--GUI_RefreshWindow(wt_global_information.MainWindow.Name)
	end	
	
end

-- Module Event Handler
function gw2minion.HandleInit()
	wt_debug("received Module.Initalize")
	GUI_NewWindow(wt_global_information.MainWindow.Name,wt_global_information.MainWindow.x,wt_global_information.MainWindow.y,wt_global_information.MainWindow.width,wt_global_information.MainWindow.height)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnStart.Name , wt_global_information.BtnStart.Event)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnPulse.Name , wt_global_information.BtnPulse.Event)
	GUI_NewSeperator(wt_global_information.MainWindow.Name);	
	GUI_NewField(wt_global_information.MainWindow.Name,"Pulse Time (ms)","gGW2MinionPulseTime","BotStatus");	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Log","gEnableLog","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"State","gGW2MinionState","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"Effect","gGW2MinionEffect","BotStatus");	
	GUI_NewField(wt_global_information.MainWindow.Name,"MainTask","gGW2MinionTask","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"dT","gGW2MiniondeltaT","BotStatus");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Ignore Marker Level Cap","gIgnoreMarkerCap","Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Repair Equippment","gEnableRepair","Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Max ItemSell Rarity","gMaxItemSellRarity","Settings");
	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"BotStatus");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"Settings");
	
	
	gEnableLog = Settings.GW2MINION.gEnableLog
	gGW2MinionPulseTime = Settings.GW2MINION.gGW2MinionPulseTime 
	gEnableRepair = Settings.GW2MINION.gEnableRepair
	gIgnoreMarkerCap = Settings.GW2MINION.gIgnoreMarkerCap
	gMaxItemSellRarity = Settings.GW2MINION.gMaxItemSellRarity
	wt_debug("GUI Setup done")
	wt_core_controller.requestStateChange(wt_core_state_idle)
end

function gw2minion.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gEnableLog" or k == "gGW2MinionPulseTime" or k == "gEnableRepair" or k == "gIgnoreMarkerCap" or k == "gMaxItemSellRarity" ) then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end

function wt_global_information.Reset()
	Player:StopMoving()
	wt_core_controller.requestStateChange(wt_core_state_idle)
	wt_global_information.CurrentMarkerList = nil
	wt_global_information.SelectedMarker = nil
	wt_global_information.AttackRange = 1200
	wt_global_information.MaxLootDistance = 1200
	wt_global_information.lastrun = 0
	wt_global_information.InventoryFull = 0
	wt_global_information.HasVendor = true
	wt_global_information.HasRepairMerchant = true
	wt_core_state_vendoring.junksold = false 
	wt_core_state_combat.CurrentTarget = 0
	c_aggro.TargetList = {}
	wt_core_taskmanager.task_list = { }
	wt_core_taskmanager.possible_tasks = { }
	wt_core_taskmanager.current_task = nil
	wt_core_taskmanager.markerList = { }
	wt_core_state_minion.LeaderID = nil
end


-- Register Event Handlers
RegisterEventHandler("Module.Initalize",gw2minion.HandleInit)
RegisterEventHandler("Gameloop.Update",wt_global_information.OnUpdate)
RegisterEventHandler("GUI.Update",gw2minion.GUIVarUpdate)
