-- Test Commit Change
-- Main config file of GW2Minion

wt_global_information = {}
wt_global_information.path = GetStartupPath()
wt_global_information.Currentprofession = nil
wt_global_information.Now = 0
wt_global_information.MainWindow = { Name = "GW2Minion", x=50, y=50 , width=200, height=240 }
wt_global_information.BtnStart = { Name=strings[gCurrentLanguage].startStop,Event = "GUI_REQUEST_RUN_TOGGLE" }
wt_global_information.BtnPulse = { Name=strings[gCurrentLanguage].doPulse,Event = "Debug.Pulse" }
wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel = 3  
wt_global_information.CurrentMarkerList = nil
wt_global_information.SelectedMarker = nil
wt_global_information.AttackRange = 1200
wt_global_information.MaxLootDistance = 3000 
wt_global_information.MaxReviveDistance = 1500 
wt_global_information.MaxGatherDistance = 4000
wt_global_information.MaxAggroDistanceFar = 1200
wt_global_information.MaxAggroDistanceClose = 500
wt_global_information.MaxSearchEnemyDistance = 2500
wt_global_information.DoAggroCheck = true
wt_global_information.lastrun = 0
wt_global_information.InventoryFull = 0
wt_global_information.FocusTarget = nil
wt_global_information.stats_lastrun = 0
wt_global_information.Charscreen_lastrun = 0
wt_global_information.Cinema_lastrun = 0
wt_global_information.MeshCheck_lastrun = 0
wt_global_information.AutoRun = false
wt_global_information.AutoRun_lastrun = 0
wt_global_information.ChatCheck_lastrun = 0
wt_global_information.OldLastchatline = ""
wt_global_information.OldLastwhisperline = ""
wt_global_information.TargetBlacklist = {}
wt_global_information.TargetBlacklistTmr = 0
wt_global_information.TargetIgnorelist = {}

gw2minion = { }


function wt_global_information.OnUpdate( event, tickcount )
	wt_global_information.Now = tickcount
	if ( (gStats_enabled == "1" or gMinionEnabled == "1") and tickcount - wt_global_information.stats_lastrun > 2000) then
		wt_global_information.stats_lastrun = tickcount	
		wt_global_information.UpdateMultiServerStatus()
	end	
		
	gGW2MiniondeltaT = tostring(tickcount - wt_global_information.lastrun)
	if (tickcount - wt_global_information.lastrun > tonumber(gGW2MinionPulseTime)) then
		wt_global_information.lastrun = tickcount
		
		-- Check if we switched to a new map/zone
		if ( wt_global_information.MeshCheck_lastrun == 0 ) then 
			wt_global_information.MeshCheck_lastrun = tickcount
		elseif( tickcount - wt_global_information.MeshCheck_lastrun > 3000 ) then
			wt_global_information.MeshCheck_lastrun = tickcount
			if ( mm.RefreshCurrentMapData() and gAutostartbot == "1" and wt_core_controller.shouldRun == false) then				
				wt_core_controller.ToggleRun()
				return				
			end
		end
		
		if ( gCheckChat ~= "Off" and wt_global_information.ChatCheck_lastrun == 0 or tickcount - wt_global_information.ChatCheck_lastrun > 3000 ) then
			wt_global_information.ChatCheck_lastrun = tickcount
			wt_global_information.WhisperWarningCheck()
		end
		
		-- I know I'm lazy
		if ( wt_global_information.TargetBlacklistTmr == 0 or tickcount - wt_global_information.TargetBlacklistTmr > 60000 ) then
			wt_global_information.TargetBlacklistTmr = tickcount
			wt_global_information.TargetBlacklist = {}
		end
			
		wt_core_controller.Run()
	end
end



function wt_global_information.OnUpdateCharSelect(event, tickcount )
	wt_global_information.Now = tickcount
	if (wt_global_information.Charscreen_lastrun == 0) then
		wt_global_information.Charscreen_lastrun = tickcount
	elseif ( gAutostartbot ~= nil and gAutostartbot == "1" and tickcount - wt_global_information.Charscreen_lastrun > 2500) then
		wt_global_information.Charscreen_lastrun = tickcount
		wt_global_information.Reset()
		wt_global_information.Charscreen_lastrun = 0
		
		if ( gGuestServer ~= nil and gGuestServer ~= "None" ) then
			local serverlist = {}
			local homeserverid = GetHomeServer()
			if ( homeserverid > 1000 and homeserverid < 2000 ) then
				serverlist = wt_global_information.ServersUS
			elseif ( homeserverid > 2000 and homeserverid < 3000 ) then
				serverlist = wt_global_information.ServersEU
			end	
			if ( TableSize(serverlist) > 0) then
				local i,entry = next ( serverlist)
				while i and entry do			
					if ( gGuestServer == entry.name ) then
						SetServer(entry.id)
						d("Selecting Guestserver: "..tostring(entry.name) .." ID: ".. tostring(entry.id))
						break
					end
					i,entry = next ( serverlist,i)
				end
			end
			gGuestServer_listitems = newserverlist
			gGuestServer = Settings.GW2MINION.gGuestServer
			
		end		
		wt_debug("Pressing PLAY")
		PressKey("RETURN")				
	end
end

function wt_global_information.OnUpdateCutscene(event, tickcount )
	wt_global_information.Now = tickcount
	if ( gskipcutscene == "1" and tickcount - wt_global_information.Cinema_lastrun > 2000 ) then
		wt_global_information.Cinema_lastrun = tickcount
		wt_debug("Skipping Cutscene...")
		PressKey("ESC")
	end
end

-- Module Event Handler
function gw2minion.HandleInit()	
	GUI_SetStatusBar("Initalizing gw2 Module...")
	
	Settings.GW2MINION.TargetWaypointID = 0
	if (Settings.GW2MINION.version == nil ) then
		-- Init Settings for Version 1
		Settings.GW2MINION.version = 1.0
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
	if ( Settings.GW2MINION.gUseWaypointsEvents == nil ) then
		Settings.GW2MINION.gUseWaypointsEvents = "0"
	end
	if ( Settings.GW2MINION.gVendor_Weapons == nil ) then
		Settings.GW2MINION.gVendor_Weapons = "1"
	end
	if ( Settings.GW2MINION.gVendor_Armor == nil ) then
		Settings.GW2MINION.gVendor_Armor = "1"
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
		Settings.GW2MINION.gBuyGatheringTools = "1"
	end
	if ( Settings.GW2MINION.gBuySalvageKits == nil ) then
		Settings.GW2MINION.gBuySalvageKits = "1"
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
		Settings.GW2MINION.gSalvageKitStock = "1"
	end
	if ( Settings.GW2MINION.gSalvageKitQuality == nil ) then
		Settings.GW2MINION.gSalvageKitQuality = "2"
	end
	if ( Settings.GW2MINION.gBuyBestGatheringTool == nil ) then
		Settings.GW2MINION.gBuyBestGatheringTool = "1"
	end
	if ( Settings.GW2MINION.gBuyBestSalvageKit == nil ) then
		Settings.GW2MINION.gBuyBestSalvageKit = "1"
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
	if ( Settings.GW2MINION.gEventTimeout == nil ) then
		Settings.GW2MINION.gEventTimeout = "600"
	end
	if ( Settings.GW2MINION.gEventFarming == nil ) then
		Settings.GW2MINION.gEventFarming = "0"
	end
	if ( Settings.GW2MINION.gPrioritizeRevive == nil ) then
		Settings.GW2MINION.gPrioritizeRevive = "0"
	end
	if ( Settings.GW2MINION.gskipcutscene == nil ) then
		Settings.GW2MINION.gskipcutscene = "1"
	end
	if ( Settings.GW2MINION.gDepositItems == nil ) then
		Settings.GW2MINION.gDepositItems = "1"
	end
	if ( Settings.GW2MINION.gCheckChat == nil ) then
		Settings.GW2MINION.gCheckChat = "Both"
	end
	if ( Settings.GW2MINION.gRandomFarmspot == nil ) then
		Settings.GW2MINION.gRandomFarmspot = "1"
	end
	if ( Settings.GW2MINION.gAttackGadgets == nil ) then
		Settings.GW2MINION.gAttackGadgets = "0"
	end
	if ( Settings.GW2MINION.gGuestServer == nil ) then
		Settings.GW2MINION.gGuestServer = "None"
	end
	
	GUI_NewWindow(wt_global_information.MainWindow.Name,wt_global_information.MainWindow.x,wt_global_information.MainWindow.y,wt_global_information.MainWindow.width,wt_global_information.MainWindow.height)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnStart.Name , wt_global_information.BtnStart.Event)
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].pulseTime,"gGW2MinionPulseTime",strings[gCurrentLanguage].botStatus );	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableLog,"gEnableLog",strings[gCurrentLanguage].botStatus );
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].task,"gGW2MinionTask",strings[gCurrentLanguage].botStatus );
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].state,"gGW2MinionState",strings[gCurrentLanguage].botStatus );
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].effect,"gGW2MinionEffect",strings[gCurrentLanguage].botStatus );		
	--GUI_NewField(wt_global_information.MainWindow.Name,"dT","gGW2MiniondeltaT",strings[gCurrentLanguage].botStatus );
	
	GUI_NewComboBox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].guestingServer,"gGuestServer",strings[gCurrentLanguage].settings,"None")
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].autoStartBot,"gAutostartbot",strings[gCurrentLanguage].settings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].combatMovement,"gCombatmovement",strings[gCurrentLanguage].settings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableEvents,"gdoEvents",strings[gCurrentLanguage].settings);		
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableRepair,"gEnableRepair",strings[gCurrentLanguage].settings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].depositItems,"gDepositItems",strings[gCurrentLanguage].settings);
		
	
	GUI_NewComboBox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].checkChat,"gCheckChat",strings[gCurrentLanguage].advancedSettings,"Off,Whisper,Say,Both");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].randomfarmspot,"gRandomFarmspot",strings[gCurrentLanguage].advancedSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].AttackGadgets,"gAttackGadgets",strings[gCurrentLanguage].advancedSettings);	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].ignoreLevelMarker,"gIgnoreMarkerCap",strings[gCurrentLanguage].advancedSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].wpVendor, "gUseWaypoints",strings[gCurrentLanguage].advancedSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].wpEvents, "gUseWaypointsEvents",strings[gCurrentLanguage].advancedSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableUnstuck, "gDoUnstuck",strings[gCurrentLanguage].advancedSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].unstuckCount,"gUnstuckCount",strings[gCurrentLanguage].advancedSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].eventTimeout, "gEventTimeout",strings[gCurrentLanguage].advancedSettings);
	GUI_NewButton(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].blacklistEvent,"wt_core_taskmanager.blacklistCurrentEvent",strings[gCurrentLanguage].advancedSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].prioEvent,"gEventFarming",strings[gCurrentLanguage].advancedSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].prioRevive,"gPrioritizeRevive",strings[gCurrentLanguage].advancedSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].skipcutscene,"gskipcutscene",strings[gCurrentLanguage].advancedSettings)
	
	
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].vendorRarity,"gMaxItemSellRarity",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellWeapon,"gVendor_Weapons",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellArmor,"gVendor_Armor",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellTrinket,"gVendor_Trinkets",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellUpgrade,"gVendor_UpgradeComps",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellCrafting,"gVendor_CraftingMats",strings[gCurrentLanguage].vendorSettings)
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].sellTrophy,"gVendor_Trophies",strings[gCurrentLanguage].vendorSettings)
	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableGather, "gDoGathering",strings[gCurrentLanguage].gatherSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].buyTools, "gBuyGatheringTools",strings[gCurrentLanguage].gatherSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].buyBestTool, "gBuyBestGatheringTool",strings[gCurrentLanguage].gatherSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].toolRarity,"gGatheringToolQuality",strings[gCurrentLanguage].gatherSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].toolStock,"gGatheringToolStock",strings[gCurrentLanguage].gatherSettings);
	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].enableSalvage, "gDoSalvaging",strings[gCurrentLanguage].salvageSettings);	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].buyKits, "gBuySalvageKits",strings[gCurrentLanguage].salvageSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].buyBestKit, "gBuyBestSalvageKit",strings[gCurrentLanguage].salvageSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].kitRarity,"gSalvageKitQuality",strings[gCurrentLanguage].salvageSettings);
	GUI_NewField(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].kitStock,"gSalvageKitStock",strings[gCurrentLanguage].salvageSettings);
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].salvageTrophy, "gDoSalvageTrophies",strings[gCurrentLanguage].salvageSettings);

	gGW2MinionTask = ""
	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].botStatus );
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].settings);
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].vendorSettings);	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].salvageSettings);
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].gatherSettings);
	GUI_FoldGroup(wt_global_information.MainWindow.Name,strings[gCurrentLanguage].advancedSettings);
	
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
	gUseWaypointsEvents = Settings.GW2MINION.gUseWaypointsEvents
	gVendor_Weapons = Settings.GW2MINION.gVendor_Weapons
	gVendor_Armor = Settings.GW2MINION.gVendor_Armor
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
	gEventTimeout = Settings.GW2MINION.gEventTimeout
	gEventFarming = Settings.GW2MINION.gEventFarming
	gPrioritizeRevive = Settings.GW2MINION.gPrioritizeRevive
	gskipcutscene = Settings.GW2MINION.gskipcutscene
	gDepositItems = Settings.GW2MINION.gDepositItems
	gCheckChat = Settings.GW2MINION.gCheckChat
	gRandomFarmspot = Settings.GW2MINION.gRandomFarmspot
	gAttackGadgets = Settings.GW2MINION.gAttackGadgets
		
	local newserverlist = "None"
	local homeserverid = GetHomeServer()
	local serverlist = {}	
	if ( homeserverid > 1000 and homeserverid < 2000 ) then
		serverlist = wt_global_information.ServersUS
	elseif ( homeserverid > 2000 and homeserverid < 3000 ) then
		serverlist = wt_global_information.ServersEU
	end	
	if ( TableSize(serverlist) > 0) then
		local i,entry = next ( serverlist)
		while i and entry do			
			newserverlist = newserverlist..","..entry.name
			i,entry = next ( serverlist,i)
		end
	end
	gGuestServer_listitems = newserverlist
	gGuestServer = Settings.GW2MINION.gGuestServer
	
	wt_debug("GUI Setup done")
	GUI_SetStatusBar("Ready...")
	wt_core_controller.requestStateChange(wt_core_state_idle)
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
				k == "gUseWaypointsEvents" or 
				k == "gVendor_Weapons" or
				k == "gVendor_Armor" or
				k == "gVendor_Trinkets" or
				k == "gVendor_UpgradeComps" or
				k == "gVendor_CraftingMats" or
				k == "gVendor_Trophies" or
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
				k == "gEventTimeout" or
				k == "gEventFarming" or
				k == "gPrioritizeRevive" or
				k == "gskipcutscene" or		
				k == "gDepositItems" or	
				k == "gCheckChat" or
				k == "gRandomFarmspot" or	
				k == "gAttackGadgets" or
				k == "gGuestServer" or				
				k == "gBuyBestSalvageKit")
		then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end

function wt_global_information.Reset()
	wt_core_state_combat.StopCM()
	wt_core_taskmanager.ClearTasks()
	wt_global_information.CurrentMarkerList = nil
	wt_global_information.SelectedMarker = nil
	wt_global_information.AttackRange = 1200
	wt_global_information.MaxLootDistance = 4000
	wt_global_information.lastrun = 0
	wt_global_information.InventoryFull = 0
	wt_core_state_combat.CurrentTarget = 0
	wt_global_information.FocusTarget = nil
	gMapswitch = 0	
	
	NavigationManager:SetTargetMapID(0)
	wt_core_controller.requestStateChange(wt_core_state_idle)
end

function wt_global_information.UpdateMultiServerStatus() 
	if ( MultiBotIsConnected()) then
		if (gStats_enabled == "1") then
			MultiBotSend("name=" .. (Player.name) .."("..tostring(Player.level)..")","setval");
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
					MultiBotSend("target=" ..(Target.name) .."("..tostring(Target.health.percent).."%)","setval");
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

wt_global_information.ServersUS = {		
	{id=1010,name="Ehmry Bay"},
	{id=1018,name="Northern Shiverpeaks"},
	{id=1002,name="Borlis Pass"},
	{id=1008,name="Jade Quarry"},
	{id=1005,name="Maguuma"},
	{id=1015,name="Isle of Janthir"},
	{id=1009,name="Fort Aspenwood"},
	{id=1013,name="Sanctum of Rall"},
	{id=1007,name="Gate of Madness"},
	{id=1006,name="Sorrow's Furnace"},
	{id=1019,name="Blackgate"},
	{id=1021,name="Dragonbrand"},
	{id=1012,name="Darkhaven"},
	{id=1003,name="Yak's Bend"},
	{id=1014,name="Crystal Desert"},
	{id=1001,name="Anvil Rock"},
	{id=1011,name="Stormbluff Isle"},
	{id=1020,name="Ferguson's Crossing"},
	{id=1016,name="Sea of Sorrows"},
	{id=1022,name="Kaineng"},
	{id=1023,name="Devona's Rest"},
	{id=1017,name="Tarnished Coast"},
	{id=1024,name="Eredon Terrace"},
	{id=1004,name="Henge of Denravi"}
	}	
wt_global_information.ServersEU = {
	{id=2012,name="Piken Square"},
	{id=2003,name="Gandara"},
	{id=2007,name="Far Shiverpeaks"},
	{id=2204,name="Abaddon's Mouth [DE]"},
	{id=2201,name="Kodash [DE]"},
	{id=2010,name="Seafarer's Rest"},
	{id=2301,name="Baruch Bay [SP]"},
	{id=2205,name="Drakkar Lake [DE]"},
	{id=2002,name="Desolation"},
	{id=2202,name="Riverside [DE]"},
	{id=2008,name="Whiteside Ridge"},
	{id=2203,name="Elona Reach [DE]"},
	{id=2206,name="Miller's Sound [DE]"},
	{id=2004,name="Blacktide"},
	{id=2207,name="Dzagonur [DE]"},
	{id=2105,name="Arborstone [FR]"},
	{id=2101,name="Jade Sea [FR]"},
	{id=2013,name="Aurora Glade"},
	{id=2103,name="Augury Rock [FR]"},
	{id=2102,name="Fort Ranik [FR]"},
	{id=2104,name="Vizunah Square [FR]"},
	{id=2009,name="Ruins of Surmia"},
	{id=2014,name="Gunnar's Hold"},
	{id=2005,name="Ring of Fire"},
	{id=2006,name="Underworld"},
	{id=2011,name="Vabbi"},
	{id=2001,name="Fissure of Woe"}
}


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

-- Whisperwarning, thanks Jorith :)
function wt_global_information.WhisperWarningCheck()
	if ( gCheckChat == "Whisper" or gCheckChat == "Both" ) then
		local NewWhisper = GetChatMsg(14, 100) --14 = Whisperchannel
		if ( TableSize(NewWhisper) > 0 ) then
			if (NewWhisper[1] ~= wt_global_information.OldLastwhisperline) and not (wt_global_information.OldLastwhisperline == "") then
				PlaySound(wt_global_information.path.."\\LuaMods\\gw2lib\\Alarm1.wav")
			end
			wt_global_information.OldLastwhisperline = NewWhisper[1]
		end
	end	
	if ( gCheckChat == "Say" or gCheckChat == "Both" ) then
		local NewWhisper = GetChatMsg(19, 100) --9 = Saychannel
		if ( TableSize(NewWhisper) > 0 ) then
			if (NewWhisper[1] ~= wt_global_information.OldLastchatline) and not (wt_global_information.OldLastchatline == "") then
				PlaySound(wt_global_information.path.."\\LuaMods\\gw2lib\\Alarm1.wav")
			end
			wt_global_information.OldLastchatline = NewWhisper[1]
		end
	end
end


-- Register Event Handlers
RegisterEventHandler("Module.Initalize",gw2minion.HandleInit)
RegisterEventHandler("Gameloop.Update",wt_global_information.OnUpdate)
RegisterEventHandler("Gameloop.CharSelectUpdate",wt_global_information.OnUpdateCharSelect)
RegisterEventHandler("Gameloop.CutsceneUpdate",wt_global_information.OnUpdateCutscene)
RegisterEventHandler("GUI.Update",gw2minion.GUIVarUpdate)
RegisterEventHandler("MULTIBOT.Message",wt_global_information.HandleCMDMultiBotMessages)
