-- Main config file of GW2Minion

wt_global_information = {}
wt_global_information.Currentprofession = nil
wt_global_information.Now = 0

wt_global_information.PVP = false
wt_global_information.MainWindow = { Name = "GW2Minion", x=100, y=320 , width=200, height=220 }
wt_global_information.BtnStart = { Name="StartStop" ,Event = "GUI_REQUEST_RUN_TOGGLE" }
wt_global_information.BtnPulse = { Name="Pulse(Debug)" ,Event = "Debug.Pulse" }
wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel = 3  
wt_global_information.CurrentMarkerList = nil
wt_global_information.SelectedMarker = nil
wt_global_information.AttackRange = 1200
wt_global_information.MaxLootDistance = 2000 
wt_global_information.MaxReviveDistance = 1500 
wt_global_information.MaxGatherDistance = 4000
wt_global_information.MaxAggroDistanceFar = 1200
wt_global_information.MaxAggroDistanceClose = 500
wt_global_information.MaxSearchEnemyDistance = 2500
wt_global_information.lastrun = 0
wt_global_information.InventoryFull = 0
wt_global_information.FocusTarget = nil
Settings.GW2MINION.TargetWaypointID = 0
wt_global_information.stats_lastrun = 0

gw2minion = { }

if (Settings.GW2MINION.version == nil ) then
	-- Init Settings for Version 1
	Settings.GW2MINION.version = 1.0
	Settings.GW2MINION.gEnableLog = "0"
end

if ( Settings.GW2MINION.gGW2MinionPulseTime == nil ) then
	Settings.GW2MINION.gGW2MinionPulseTime = "150"
end
if ( Settings.GW2MINION.gEnableRepair == nil ) then
	Settings.GW2MINION.gEnableRepair = "1"
end
if ( Settings.GW2MINION.gIgnoreMarkerCap == nil ) then
	Settings.GW2MINION.gIgnoreMarkerCap = "0"
end
if ( Settings.GW2MINION.gMaxItemSellRarity == nil ) then
	Settings.GW2MINION.gMaxItemSellRarity = "2"
end
if ( Settings.GW2MINION.gNavSwitchEnabled == nil ) then
	Settings.GW2MINION.gNavSwitchEnabled = "0"
end
if ( Settings.GW2MINION.gNavSwitchTime == nil ) then
	Settings.GW2MINION.gNavSwitchTime = "20"
end
if ( Settings.GW2MINION.gUseWaypoints == nil ) then
	Settings.GW2MINION.gUseWaypoints = "0"
end
if ( Settings.GW2MINION.gVendor_Weapons == nil ) then
	Settings.GW2MINION.gVendor_Weapons = "1"
end
if ( Settings.GW2MINION.gVendor_Armor == nil ) then
	Settings.GW2MINION.gVendor_Armor = "1"
end
if ( Settings.GW2MINION.gVendor_Junk == nil ) then
	Settings.GW2MINION.gVendor_Junk = "1"
end
if ( Settings.GW2MINION.gVendor_UpgradeComps == nil ) then
	Settings.GW2MINION.gVendor_UpgradeComps = "0"
end
if ( Settings.GW2MINION.gVendor_CraftingMats == nil ) then
	Settings.GW2MINION.gVendor_CraftingMats = "0"
end
if ( Settings.GW2MINION.gVendor_Trinkets == nil ) then
	Settings.GW2MINION.gVendor_Trinkets = "0"
end
if ( Settings.GW2MINION.gVendor_Trophies == nil ) then
	Settings.GW2MINION.gVendor_Trophies = "0"
end
if ( Settings.GW2MINION.gBuyGatheringTools == nil ) then
	Settings.GW2MINION.gBuyGatheringTools = "0"
end
if ( Settings.GW2MINION.gBuySalvageKits == nil ) then
	Settings.GW2MINION.gBuySalvageKits = "0"
end
if ( Settings.GW2MINION.gDoGathering == nil ) then
	Settings.GW2MINION.gDoGathering = "1"
end
if ( Settings.GW2MINION.gDoSalvaging == nil ) then
	Settings.GW2MINION.gDoSalvaging = "1"
end
if ( Settings.GW2MINION.gDoSalvageTrophies == nil ) then
	Settings.GW2MINION.gDoSalvageTrophies = "0"
end
if ( Settings.GW2MINION.gGatheringToolStock == nil ) then
	Settings.GW2MINION.gGatheringToolStock = "1"
end
if ( Settings.GW2MINION.gGatheringToolQuality == nil ) then
	Settings.GW2MINION.gGatheringToolQuality = "5"
end
if ( Settings.GW2MINION.gSalvageKitStock == nil ) then
	Settings.GW2MINION.gSalvageKitStock = "3"
end
if ( Settings.GW2MINION.gSalvageKitQuality == nil ) then
	Settings.GW2MINION.gSalvageKitQuality = "2"
end
if ( Settings.GW2MINION.gBuyBestGatheringTool == nil ) then
	Settings.GW2MINION.gBuyBestGatheringTool = "1"
end
if ( Settings.GW2MINION.gBuyBestSalvageKit == nil ) then
	Settings.GW2MINION.gBuyBestSalvageKit = "0"
end
if ( Settings.GW2MINION.gStats_enabled == nil ) then
	Settings.GW2MINION.gStats_enabled = "0"
end
if ( Settings.GW2MINION.gEnableLog == nil ) then
	Settings.GW2MINION.gEnableLog = "0"
end
if ( Settings.GW2MINION.gAutostartbot == nil ) then
	Settings.GW2MINION.gAutostartbot = "0"
end
if ( Settings.GW2MINION.gCombatmovement == nil ) then
	Settings.GW2MINION.gCombatmovement = "1"
end
if ( Settings.GW2MINION.gdoEvents == nil ) then
	Settings.GW2MINION.gdoEvents = "1"
end
if ( Settings.GW2MINION.gDoUnstuck == nil ) then
	Settings.GW2MINION.gDoUnstuck = "1"
end
if ( Settings.GW2MINION.gUnstuckCount == nil ) then
	Settings.GW2MINION.gUnstuckCount = "10"
end
if ( Settings.GW2MINION.gPlayerRevive == nil ) then
	Settings.GW2MINION.gPlayerRevive = "1"
end
if ( Settings.GW2MINION.gEventTimeout == nil ) then
	Settings.GW2MINION.gEventTimeout = "600"
end
if ( Settings.GW2MINION.gDoPause == nil ) then
	Settings.GW2MINION.gDoPause = "0"
end
--if ( Settings.GW2MINION.gDoWaypoint == nil ) then
--	Settings.GW2MINION.gDoWaypoint = "0"
--end

function wt_global_information.OnUpdate( event, tickcount )
	wt_global_information.Now = tickcount
	
	if ( (gStats_enabled == "1" or gMinionEnabled == "1") and tickcount - wt_global_information.stats_lastrun > 2000) then
		wt_global_information.stats_lastrun = tickcount	
		wt_global_information.UpdateMultiServerStatus()
	end	
	
	gGW2MiniondeltaT = tostring(tickcount - wt_global_information.lastrun)
	if (tickcount - wt_global_information.lastrun > tonumber(gGW2MinionPulseTime)) then
		wt_global_information.lastrun = tickcount
		wt_core_controller.Run()		
	end			
end

-- Module Event Handler
function gw2minion.HandleInit()
	wt_debug("received Module.Initalize")
	GUI_NewWindow(wt_global_information.MainWindow.Name,wt_global_information.MainWindow.x,wt_global_information.MainWindow.y,wt_global_information.MainWindow.width,wt_global_information.MainWindow.height)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnStart.Name , wt_global_information.BtnStart.Event)
	GUI_NewButton(wt_global_information.MainWindow.Name,"ToolBox","TB.toggle")
	GUI_NewButton(wt_global_information.MainWindow.Name,"NavMeshSwitcher","MM.toggle")
	GUI_NewField(wt_global_information.MainWindow.Name,"MyTask","gGW2MinionTask");
	GUI_NewSeperator(wt_global_information.MainWindow.Name);
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnPulse.Name , wt_global_information.BtnPulse.Event,"BotStatus")
	GUI_NewField(wt_global_information.MainWindow.Name,"Pulse Time (ms)","gGW2MinionPulseTime","BotStatus");	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Log","gEnableLog","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"State","gGW2MinionState","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"Effect","gGW2MinionEffect","BotStatus");		
	GUI_NewField(wt_global_information.MainWindow.Name,"dT","gGW2MiniondeltaT","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"MapSwitch in","gMapswitch","BotStatus");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"AutoStartBot","gAutostartbot","Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"CombatMovement","gCombatmovement","Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Do Events","gdoEvents","Settings");	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Ignore Marker Level Cap","gIgnoreMarkerCap","Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Repair Equippment","gEnableRepair","Settings");
	--GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Use WP Vendor/Repair", "gUseWaypoints","Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Max ItemSell Rarity","gMaxItemSellRarity","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Weapons","gVendor_Weapons","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Armor","gVendor_Armor","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Trinkets","gVendor_Trinkets","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Upgrade Components","gVendor_UpgradeComps","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Crafting Materials","gVendor_CraftingMats","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Trophies","gVendor_Trophies","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Sell Junk","gVendor_Junk","VendorSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Do Gathering", "gDoGathering","GatherSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Buy Gathering Tools", "gBuyGatheringTools","GatherSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Buy Best Tool Available", "gBuyBestGatheringTool","GatherSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Set Tool Quality","gGatheringToolQuality","GatherSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Gathering Tool Stock","gGatheringToolStock","GatherSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Do Salvaging", "gDoSalvaging","SalvageSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Salvage Trophies", "gDoSalvageTrophies","SalvageSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Buy Salvage Kits", "gBuySalvageKits","SalvageSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Buy Best Kit Available", "gBuyBestSalvageKit","SalvageSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Set Kit Quality","gSalvageKitQuality","SalvageSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Salvage Kit Stock","gSalvageKitStock","SalvageSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Unstuck", "gDoUnstuck","AdvancedSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Exit GW2 StuckCount","gUnstuckCount","AdvancedSettings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Revive Other Players", "gPlayerRevive","AdvancedSettings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Event Timeout", "gEventTimeout","AdvancedSettings");
	GUI_NewButton(wt_global_information.MainWindow.Name,"Blacklist Current Event","wt_core_taskmanager.blacklistCurrentEvent","AdvancedSettings")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Random Pause", "gDoPause","AdvancedSettings");
	--GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Use Waypoints (SOLO)", "gDoWaypoint","AdvancedSettings");
	gGW2MinionTask = "            "
	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"BotStatus");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"Settings");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"VendorSettings");	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"SalvageSettings");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"GatherSettings");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"AdvancedSettings");
	
	gEnableLog = Settings.GW2MINION.gEnableLog
	gGW2MinionPulseTime = Settings.GW2MINION.gGW2MinionPulseTime 
	gEnableRepair = Settings.GW2MINION.gEnableRepair
	gIgnoreMarkerCap = Settings.GW2MINION.gIgnoreMarkerCap
	gMaxItemSellRarity = Settings.GW2MINION.gMaxItemSellRarity
	gAutostartbot = Settings.GW2MINION.gAutostartbot
	gCombatmovement = Settings.GW2MINION.gCombatmovement
	gdoEvents = Settings.GW2MINION.gdoEvents	
	gMapswitch = 0
	gUseWaypoints = Settings.GW2MINION.gUseWaypoints
	gVendor_Weapons = Settings.GW2MINION.gVendor_Weapons
	gVendor_Armor = Settings.GW2MINION.gVendor_Armor
	gVendor_Junk = Settings.GW2MINION.gVendor_Junk
	gVendor_UpgradeComps = Settings.GW2MINION.gVendor_UpgradeComps
	gVendor_CraftingMats = Settings.GW2MINION.gVendor_CraftingMats
	gVendor_Trinkets = Settings.GW2MINION.gVendor_Trinkets
	gVendor_Trophies = Settings.GW2MINION.gVendor_Trophies
	gBuyGatheringTools = Settings.GW2MINION.gBuyGatheringTools
	gBuySalvageKits = Settings.GW2MINION.gBuySalvageKits
	gDoGathering = Settings.GW2MINION.gDoGathering
	gDoSalvaging = Settings.GW2MINION.gDoSalvaging
	gDoSalvageTrophies = Settings.GW2MINION.gDoSalvageTrophies
	gGatheringToolStock = Settings.GW2MINION.gGatheringToolStock
	gGatheringToolQuality = Settings.GW2MINION.gGatheringToolQuality
	gSalvageKitStock = Settings.GW2MINION.gSalvageKitStock
	gSalvageKitQuality = Settings.GW2MINION.gSalvageKitQuality
	gBuyBestGatheringTool = Settings.GW2MINION.gBuyBestGatheringTool
	gBuyBestSalvageKit = Settings.GW2MINION.gBuyBestSalvageKit
	gDoUnstuck = Settings.GW2MINION.gDoUnstuck
	gUnstuckCount = Settings.GW2MINION.gUnstuckCount
	gPlayerRevive = Settings.GW2MINION.gPlayerRevive
	gEventTimeout = Settings.GW2MINION.gEventTimeout
	gDoPause = Settings.GW2MINION.gDoPause
	--gDoWaypoint = Settings.GW2MINION.gDoWaypoint
	
	wt_debug("GUI Setup done")
	wt_core_controller.requestStateChange(wt_core_state_idle)
	
	if (gAutostartbot == "1") then
		wt_core_controller.ToggleRun()
	end
end

function gw2minion.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( 	k == "gEnableLog" or 
				k == "gGW2MinionPulseTime" or 
				k == "gEnableRepair" or 
				k == "gIgnoreMarkerCap" or 
				k == "gMaxItemSellRarity" or 
				k == "gAutostartbot" or
				k == "gUseWaypoints" or 
				k == "gVendor_Weapons" or
				k == "gVendor_Armor" or
				k == "gVendor_Trinkets" or
				k == "gVendor_UpgradeComps" or
				k == "gVendor_CraftingMats" or
				k == "gVendor_Trophies" or
				k == "gVendor_Junk" or
				k == "gCombatmovement" or
				k == "gdoEvents" or
				k == "gBuyGatheringTools" or
				k == "gBuySalvageKits" or
				k == "gDoGathering" or
				k == "gDoSalvaging" or
				k == "gDoSalvageTrophies" or
				k == "gGatheringToolStock" or
				k == "gGatheringToolQuality" or
				k == "gSalvageKitStock" or
				k == "gSalvageKitQuality" or
				k == "gBuyBestGatheringTool" or
				k == "gDoUnstuck" or
				k == "gUnstuckCount" or
				k == "gPlayerRevive" or
				k == "gEventTimeout" or
				k == "gDoPause" or
				--k == "gDoWaypoint" or
				k == "gBuyBestSalvageKit")
		then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end

function wt_global_information.Reset()
	Player:StopMoving()	
	wt_global_information.CurrentMarkerList = nil
	wt_global_information.SelectedMarker = nil
	wt_global_information.AttackRange = 1200
	wt_global_information.MaxLootDistance = 1200
	wt_global_information.lastrun = 0
	wt_global_information.InventoryFull = 0
	wt_core_state_combat.CurrentTarget = 0
	wt_core_taskmanager.Customtask_list = { }
	wt_core_taskmanager.current_task = nil
	wt_core_taskmanager.markerList = { }
	wt_global_information.FocusTarget = nil
	gMapswitch = 0	
	
	NavigationManager:SetTargetMapID(0)
	wt_core_controller.requestStateChange(wt_core_state_idle)
end

function wt_global_information.UpdateMultiServerStatus() 
	if ( MultiBotIsConnected()) then
		if (gStats_enabled == "1") then
			MultiBotSend("name=" .. tostring(Player.name) .."("..tostring(Player.level)..")","setval");
			MultiBotSend("health=" .. tostring(math.floor(Player.health.current)),"setval");
			MultiBotSend("maxhealth=" .. tostring(Player.health.max),"setval");
			MultiBotSend("healthstate=" .. tostring(Player.healthstate),"setval");
			MultiBotSend("endurance=" .. tostring(Player.endurance),"setval");
			MultiBotSend("money=" .. tostring(Inventory:GetInventoryMoney()),"setval");
			MultiBotSend("freeslots=" .. tostring(ItemList.freeSlotCount),"setval");
			MultiBotSend("onmesh=" .. tostring(Player.onmesh),"setval");		
			local pPos = Player.pos
			MultiBotSend("pos=" .. tostring(math.floor(pPos.x).. "|" ..math.floor(pPos.y).. "|" ..math.floor(pPos.z)),"setval");		
			
			local TID = Player:GetTarget()
			if (TID ~= nil and TID ~= 0 and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
				local Target = CharacterList:Get(TID)
				if ( Target ~= nil ) then
					MultiBotSend("target=" ..tostring(Target.name) .."("..tostring(Target.health.percent).."%)","setval");
				end			
			else
				MultiBotSend("target=None","setval");
			end	
			
			if (gGW2MinionState ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
				MultiBotSend("state=" ..tostring(gGW2MinionState),"setval");
			else
				MultiBotSend("state=None","setval");
			end	
			
			if (gGW2MinionEffect ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
				MultiBotSend("effect=" ..tostring(gGW2MinionEffect),"setval");
			else
				MultiBotSend("effect=None","setval");
			end	
				
			if (wt_core_controller ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
				MultiBotSend("running=true","setval");
			else
				MultiBotSend("running=false","setval");
			end
			
			if (Player:GetRole() == 1) then
				MultiBotSend("role=Leader","setval");
			else
				MultiBotSend("role=Minion","setval");
			end
		end		
	else
		wt_debug("Trying to connect to MultibotComServer....")
		if ( not MultiBotConnect( gIP , tonumber(gPort) , gPw) ) then
			gStats_enabled = "0"
			gMinionEnabled = "0"
			wt_error("*****Groupbotting & Stats DISABLED*****")
			wt_error("Cannot reach MultibotComServer... ")
			wt_error("Start the MultibotComServer.exe and setup the correct Password,IP and Port!")
		else			
			MultiBotJoinChannel("remotecmd")
			MultiBotJoinChannel("gw2minion")
			wt_debug("Successfully Joined MultiBotServer channels !")			
		end	
	end
end

-- Handler for the Buttons in the GW2 Minion Server Browser
function wt_global_information.HandleCMDMultiBotMessages( event, message,channel )
	if ( channel ~= nil and channel == "remotecmd" ) then
		d("Command Message:" .. tostring(channel) .. "->" .. tostring(message))
		if( tostring(message) == "Stop" ) then
			wt_debug("StartStop Button Pressed")
			wt_core_controller.ToggleRun()			
		elseif (tostring(message) == "Teleport" ) then
			wt_debug("Teleport Button Pressed")
			Player:RespawnAtClosestResShrine()			
		elseif (tostring(message) == "ExitGW2" ) then			
			wt_debug("ExitGW2 Button Pressed")
			ExitGW()
		end
	end
end


-- Register Event Handlers
RegisterEventHandler("Module.Initalize",gw2minion.HandleInit)
RegisterEventHandler("Gameloop.Update",wt_global_information.OnUpdate)
RegisterEventHandler("GUI.Update",gw2minion.GUIVarUpdate)
RegisterEventHandler("MULTIBOT.Message",wt_global_information.HandleCMDMultiBotMessages)

