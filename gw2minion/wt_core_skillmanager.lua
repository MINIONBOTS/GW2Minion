-- Skillmanager for adv. skill customization
SkillMgr = { }
SkillMgr.version = "v0.4";
SkillMgr.profilepath = GetStartupPath() .. [[\LuaMods\gw2minion\SkillManagerProfiles\]];
SkillMgr.mainwindow = { name = strings[gCurrentLanguage].skillManager, x = 450, y = 50, w = 350, h = 350}
SkillMgr.RecordSkillTmr = 0
SkillMgr.SkillMgrTmr = 0
SkillMgr.DoActionTmr = 0
SkillMgr.SwapTmr = 0
SkillMgr.SwapRTmr = 0
SkillMgr.SwapWeaponTable = {}
SkillMgr.SpellIsCast = false
SkillMgr.UIRefreshTmr = 0
SkillMgr.UIneedsRefresh = false
SkillMgr.visible = false
SkillMgr.SkillSet = {}
SkillMgr.cskills = {}
SkillMgr.SkillStuckTmr = 0
SkillMgr.SkillStuckSlot = 0
SkillMgr.poll = 150
--SkillMgr.skills = {}

SkillMgr.EngineerKits = {
	[38304] = "BombKit",
	[38472] = "FlameThrower",
	[38289] = "GrenadeKit",
	[38448] = "ToolKit",
	[38486] = "ElixirGun",
	--[240025] = "Medkit",
};
SkillMgr.ElementarAttunements = {
	["Fire"] = 12,
	["Water"] = 13,
	["Ait"] = 14,
	["Earth"] = 15,
};

SkillMgr.BuffEnum = {
		-- All Hail to Havoc :D
		--conditions
		["Bleeding"] = 736,
		["Blind"] = 720,
		["Burning"] = 737,
		["Chilled"] = 722,
		["Confusion"] = 861,
		["Crippled"] = 721,
		["Fear"] = 791,
		["Immobilized"] = 727,
		["Vulnerability"] = 738,
		["Weakness"] = 742,
		["Poison"] = 723,
		["Any Condition"] = 99999,
		--boons
		["Aegis"] = 743,
		["Fury"] = 725,
		["Might"] = 740,
		["Protection"] = 717,
		["Regeneration"] = 718,
		["Retaliation"] = 873,
		["Stability"] = 1122,
		["Swiftness"] = 719,
		["Vigor"] = 726,
		--effects
		["Blur"] = 10335,
		["Determined"] = 11641,
		["Distortion"] = 10371,
		["Elixir S"] = 5863,
		["Frenzy"] = 14456,
		["Haste"] = 13067,
		["Invulnerability"] = 848,
		["Mist Form Buff 1"] = 3686,
		["Mist Form Buff 2"] = 5543,
		["Petrified"] = 15090,
		["Quickening Zephyr"] = 12551,
		["Quickness"] = 1187,
		["Renewed Focus"] = 9255,
		["Revealed"] = 890,
		["Stealth"] = 13017,
		["Stun"] = 872,
		["Svanir Ice Block"] = 9636,
	};

SkillMgr.ConditionsEnum = {
		[736] = "Bleeding",
		[720] = "Blind",
		[737] = "Burning",
		[722] = "Chilled",
		[861] = "Confusion",
		[721] = "Crippled",
		[791] = "Fear",
		[727] = "Immobilized",
		[738] = "Vulnerability",
		[742] = "Weakness",
		[723] = "Poison",
	};

SkillMgr.BoonsEnum = {
		[743] = "Aegis",
		[725] = "Fury",
		[740] = "Might",
		[717] = "Protection",
		[718] = "Regeneration",
		[873] = "Retaliation",
		[1122] = "Stability",
		[719] = "Swiftness",
		[726] = "Vigor",
		[762] = "Determined",
	};

function SkillMgr.ModuleInit()
	if (Settings.GW2MINION.gSMactive == nil) then
		Settings.GW2MINION.gSMactive = "0"
	end
	if (Settings.GW2MINION.gSMlastprofile == nil) then
		Settings.GW2MINION.gSMlastprofile = "None"
	end
	if (Settings.GW2MINION.gSMRecactive == nil) then
		Settings.GW2MINION.gSMRecactive = "0"
	end
	if (Settings.GW2MINION.gSMmode == nil) then
		Settings.GW2MINION.gSMmode = "Attack Everything"
	end
	if (Settings.GW2MINION.gsMtargetmode == nil) then
		Settings.GW2MINION.gsMtargetmode = "No Autotarget"
	end
	if (Settings.GW2MINION.gSMSwapA == nil) then
		Settings.GW2MINION.gSMSwapA = "1"
	end
	if (Settings.GW2MINION.gSMSwapR == nil) then
		Settings.GW2MINION.gSMSwapR = "1"
	end
	if (Settings.GW2MINION.gSMSwapCD == nil) then
		Settings.GW2MINION.gSMSwapCD = "1"
	end
	if (Settings.GW2MINION.gSMSwapRange == nil) then
		Settings.GW2MINION.gSMSwapRange = "1"
	end
	if (Settings.GW2MINION.gSMSwapOOC == nil) then
		Settings.GW2MINION.gSMSwapOOC = "1"
	end
	if (Settings.GW2MINION.gSMSwapAE == nil) then
		Settings.GW2MINION.gSMSwapAE = "0"
	end
	if (Settings.GW2MINION.gSMSwapAEskill == nil) then
		Settings.GW2MINION.gSMSwapAEskill = "0"
	end
	if (Settings.GW2MINION.gSMSwapAEenemies == nil) then
		Settings.GW2MINION.gSMSwapAEenemies = "3=240"
	end
	if (Settings.GW2MINION.gSMSwapAEwho == nil) then
		Settings.GW2MINION.gSMSwapAEwho = "Enemy"
	end
	if (Settings.GW2MINION.gSMPrioKit == nil) then
		Settings.GW2MINION.gSMPrioKit = "None"
	end
	if (Settings.GW2MINION.gSMPrioAtt == nil) then
		Settings.GW2MINION.gSMPrioAtt = "Fire"
	end
	if (Settings.GW2MINION.gSMAutoStomp == nil) then
		Settings.GW2MINION.gSMAutoStomp = "1"
	end
	if (Settings.GW2MINION.gSMAutoRezz == nil) then
		Settings.GW2MINION.gSMAutoRezz = "1"
	end
	if (Settings.GW2MINION.gFightstyle == nil) then
		Settings.GW2MINION.gFightstyle = "Melee"
	end
	if (Settings.GW2MINION.gSMtargetpriority == nil) then
		Settings.GW2MINION.gSMtargetpriority = "Veteran"
	end

	if (Settings.GW2MINION.gSMATautoTargetDistance == nil) then
		Settings.GW2MINION.gSMATautoTargetDistance = "auto"
	end
	if (Settings.GW2MINION.gSMATautoTargetLowestMax == nil) then
		Settings.GW2MINION.gSMATautoTargetLowestMax = "0"
	end
	if (Settings.GW2MINION.gSMATautoTargetCombat == nil) then
		Settings.GW2MINION.gSMATautoTargetCombat = "0"
	end
	if (Settings.GW2MINION.gSMATautoTargetPlayers == nil) then
		Settings.GW2MINION.gSMATautoTargetPlayers = "0"
	end
	if (Settings.GW2MINION.gSMATautoTargetRezDistance == nil) then
		Settings.GW2MINION.gSMATautoTargetRezDistance = "0"
	end
	if (Settings.GW2MINION.gSMATautoTargetRezSlot == nil) then
		Settings.GW2MINION.gSMATautoTargetRezSlot = "0"
	end	
	
	local wnd = GUI_GetWindowInfo("GW2Minion")
	GUI_NewWindow(SkillMgr.mainwindow.name,SkillMgr.mainwindow.x,SkillMgr.mainwindow.y,SkillMgr.mainwindow.w,SkillMgr.mainwindow.h)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].activated,"gSMactive",strings[gCurrentLanguage].generalSettings)
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].profile,"gSMprofile",strings[gCurrentLanguage].generalSettings,"")
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].sMtargetmode,"gsMtargetmode",strings[gCurrentLanguage].generalSettings,"No Autotarget,Autotarget Weakest,Autotarget Closest,Autotarget Biggest Crowd,Least Conditions,Most Conditions,Least Boons,Most Boons,Assisted Targeting");
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].sMmode,"gSMmode",strings[gCurrentLanguage].generalSettings,"Attack Everything,Attack Players Only")

	GUI_NewField(SkillMgr.mainwindow.name,"Auto Target Distance (auto, #)","gSMATautoTargetDistance","Assisted Targeting")
	GUI_NewCheckbox(SkillMgr.mainwindow.name,"Auto Target Lowest Maximum","gSMATautoTargetLowestMax","Assisted Targeting")
	GUI_NewCheckbox(SkillMgr.mainwindow.name,"Auto Target Combat Lock","gSMATautoTargetCombat","Assisted Targeting")
	GUI_NewCheckbox(SkillMgr.mainwindow.name,"Auto Target Players Only","gSMATautoTargetPlayers","Assisted Targeting")
	GUI_NewNumeric(SkillMgr.mainwindow.name,"Auto Target Rez Distance","gSMATautoTargetRezDistance","Assisted Targeting")
	GUI_NewNumeric(SkillMgr.mainwindow.name,"Auto Target Rez Slot","gSMATautoTargetRezSlot","Assisted Targeting")
	
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].Fightstyle,"gFightstyle",strings[gCurrentLanguage].AdvancedSettings,"Melee,Range")
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapA,"gSMSwapA",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapR,"gSMSwapR",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapCD,"gSMSwapCD",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapRange,"gSMSwapRange",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapOOC,"gSMSwapOOC",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,"Swap AE","gSMSwapAE",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewField(SkillMgr.mainwindow.name,"Swap AE: Skill ID (contentID#slot)","gSMSwapAEskill",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewField(SkillMgr.mainwindow.name,"Swap AE: #enemies=#range","gSMSwapAEenemies",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewComboBox(SkillMgr.mainwindow.name,"Swap AE: player/enemy","gSMSwapAEwho",strings[gCurrentLanguage].AdvancedSettings,"Player,Enemy")
	
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].AutoStomp,"gSMAutoStomp",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].AutoRezz,"gSMAutoRezz",strings[gCurrentLanguage].AdvancedSettings)

	GUI_NewComboBox(SkillMgr.mainwindow.name,"Target Priority (for Boon or Cond targeting)","gSMtargetpriority",strings[gCurrentLanguage].AdvancedSettings,"Normal,Veteran,Champion");

	if ( wt_global_information.Currentprofession ~= nil ) then
		if (wt_global_information.Currentprofession.professionID == 3) then
		-- Engineer
		GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeKit,"gSMPrioKit",strings[gCurrentLanguage].AdvancedSettings,"None,BombKit,FlameThrower,GrenadeKit,ToolKit,ElixirGun")

		elseif( wt_global_information.Currentprofession.professionID == 6 ) then
			-- Elementalist
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeAttunement,"gSMPrioAtt",strings[gCurrentLanguage].AdvancedSettings,"Fire,Water,Air,Earth")
		end

		local SM_Attack_default = wt_kelement:create("Attack(SM)",SkillMgr.c_SMattack_default,SkillMgr.e_SMattack_default, 46 )
		wt_core_state_combat:add(SM_Attack_default)

	end

	--GUI_UnFoldGroup(SkillMgr.mainwindow.name,strings[gCurrentLanguage].generalSettings) crashes still

	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].saveProfile,"SMSaveEvent",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].refreshProfiles,"SMRefreshEvent",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].deleteProfile,"SMDeleteEvent",strings[gCurrentLanguage].skillEditor)
	GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].newProfileName,"gSMnewname",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].newProfile,"newSMProfileEvent",strings[gCurrentLanguage].skillEditor)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].autoetectSkills,"gSMRecactive",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].refreshSkillList,"refreshSMSkillListEvent",strings[gCurrentLanguage].skillEditor)

	gSMmode = Settings.GW2MINION.gSMmode
	gsMtargetmode = Settings.GW2MINION.gsMtargetmode
	gSMSwapA = Settings.GW2MINION.gSMSwapA
	gSMSwapR = Settings.GW2MINION.gSMSwapR
	gSMSwapCD = Settings.GW2MINION.gSMSwapCD
	gSMSwapRange = Settings.GW2MINION.gSMSwapRange
	gSMSwapOOC = Settings.GW2MINION.gSMSwapOOC
	gSMSwapAE = Settings.GW2MINION.gSMSwapAE
	gSMSwapAEskill = Settings.GW2MINION.gSMSwapAEskill
	gSMSwapAEenemies = Settings.GW2MINION.gSMSwapAEenemies
	gSMSwapAEwho = Settings.GW2MINION.gSMSwapAEwho
	gSMPrioKit = Settings.GW2MINION.gSMPrioKit
	gSMPrioAtt = Settings.GW2MINION.gSMPrioAtt
	gSMactive = Settings.GW2MINION.gSMactive
	gSMAutoStomp = Settings.GW2MINION.gSMAutoStomp
	gSMAutoRezz = Settings.GW2MINION.gSMAutoRezz
	gFightstyle = Settings.GW2MINION.gFightstyle
	gSMtargetpriority = Settings.GW2MINION.gSMtargetpriority

	gSMATautoTargetDistance = Settings.GW2MINION.gSMATautoTargetDistance
	gSMATautoTargetLowestMax = Settings.GW2MINION.gSMATautoTargetLowestMax
	gSMATautoTargetCombat = Settings.GW2MINION.gSMATautoTargetCombat
	gSMATautoTargetPlayers = Settings.GW2MINION.gSMATautoTargetPlayers
	gSMATautoTargetRezDistance = Settings.GW2MINION.gSMATautoTargetRezDistance
	gSMATautoTargetRezSlot = Settings.GW2MINION.gSMATautoTargetRezSlot

	gSMnewname = ""

	SkillMgr.UpdateProfiles()

	SkillMgr.UpdateCurrentProfileData()

	RegisterEventHandler("SMSaveEvent",SkillMgr.SaveProfile)
	RegisterEventHandler("SMRefreshEvent",SkillMgr.UpdateProfiles)
	RegisterEventHandler("SMDeleteEvent",SkillMgr.DeleteCurrentProfile)
	RegisterEventHandler("newSMProfileEvent",SkillMgr.CreateNewProfile)
	RegisterEventHandler("refreshSMSkillListEvent",SkillMgr.RefreshCurrentSkillList)

	GUI_WindowVisible(SkillMgr.mainwindow.name,false)
	SetZoom(3000)
end

function SkillMgr.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		--d(tostring(k).." = "..tostring(v))
		if ( k == "gSMactive" or
			 k == "gSMmode" or
			 k == "gsMtargetmode" or
			 k == "gSMSwapA" or
			 k == "gSMSwapR" or
			 k == "gSMSwapCD" or
			 k == "gSMSwapRange" or
			 k == "gSMSwapOOC" or
			 k == "gSMSwapAE" or
			 k == "gSMSwapAEskill" or
			 k == "gSMSwapAEenemies" or
			 k == "gSMSwapAEwho" or
			 k == "gSMPrioAtt" or
			 k == "gSMAutoStomp" or
			 k == "gSMAutoRezz" or
			 k == "gFightstyle" or
			 k == "gSMPrioKit" or
			 k == "gSMtargetpriority" or
			 k == "gSMATautoTargetDistance" or
			 k == "gSMATautoTargetLowestMax" or
			 k == "gSMATautoTargetCombat" or
			 k == "gSMATautoTargetPlayers" or
			 k == "gSMATautoTargetRezDistance" or
			 k == "gSMATautoTargetRezSlot" ) then
			Settings.GW2MINION[tostring(k)] = v
		elseif ( k == "gSMprofile" ) then
			gSMactive = "0"
			gSMRecactive = "0"
			SkillMgr.RefreshCurrentSkillList()
			Settings.GW2MINION.gSMlastprofile = tostring(v)
		end
	end
	GUI_RefreshWindow(SkillMgr.mainwindow.name)
end

function SkillMgr.OnUpdate( event, tick )
	if ( gSMRecactive == "1" ) then
		if (SkillMgr.RecordSkillTmr == 0 ) then
			SkillMgr.RecordSkillTmr = tick
		else
			if ( tick - SkillMgr.RecordSkillTmr > 60000 or gSMprofile == nil or gSMprofile == "None" or gSMprofile == "") then -- max record 60seconds, to compensate smart users who leave it on -.-
				SkillMgr.RecordSkillTmr = 0
				gSMRecactive = "0"
			elseif ( tick - SkillMgr.SkillMgrTmr > 500 ) then
				SkillMgr.SkillMgrTmr = tick
				SkillMgr.CheckForNewSkills()
			end
		end
	end
	if ( not wt_core_controller.shouldRun and gSMactive == "1" ) then
		if	( tick - SkillMgr.DoActionTmr > SkillMgr.poll ) then
			SkillMgr.DoActionTmr = tick
			if ( Player.healthstate == GW2.HEALTHSTATE.Defeated ) then return end
			SkillMgr.SelectTarget()
			SkillMgr.DoAction()
		end
	end
	if ( SkillMgr.UIneedsRefresh ) then	-- Needed because the UI cant handle clearing + rebuilding of all stuff in the same frame
		if ( SkillMgr.UIRefreshTmr == 0 ) then
			SkillMgr.UIRefreshTmr = tick
		elseif( tick - SkillMgr.UIRefreshTmr > 250 ) then
			--d("Refreshing SkillList...")
			SkillMgr.UIRefreshTmr = 0
			SkillMgr.UpdateCurrentProfileData()
			SkillMgr.UIneedsRefresh = false
		end
	end
end

--**** UI FUNCTIONS ****

function SkillMgr.CreateNewProfile()
	if ( gSMnewname ~= nil and gSMnewname ~= "" and gSMnewname ~= "None") then
		-- Make sure Profile doesnt exist
		local found = false
		local profilelist = dirlist(SkillMgr.profilepath,".*lua")
		if ( TableSize(profilelist) > 0) then
			local i,profile = next ( profilelist)
			while i and profile do
				profile = string.gsub(profile, ".lua", "")
				--d("X: "..tostring(profile).." == "..tostring(gSMnewname))
				if (profile == gSMnewname) then
					wt_error("Profile with that Name exists already...")
					found = true
					break
				end
				i,profile = next ( profilelist,i)
			end
		end

		if not found then
			-- Delete existing Skills
			SkillMgr.ClearCurrentSkills()
			gSMprofile_listitems = gSMprofile_listitems..","..gSMnewname
			gSMprofile = gSMnewname
			-- Create new profile-file TODO: REPLACE WITH HANS's SAVING FUNCTION
			local file = io.open(SkillMgr.profilepath..gSMnewname..".lua", "w")
			if file then
				wt_debug("Creating Profile file..")

				file:flush()
				file:close()
			else
				wt_debug("Error creating new Profile file..")
			end
		end
	end
end

function SkillMgr.UpdateProfiles()
	-- Grab all Profiles and enlist them in the dropdown field
	local profiles = "None"
	local found = "None"
	local profilelist = dirlist(SkillMgr.profilepath,".*lua")
	if ( TableSize(profilelist) > 0) then
		local i,profile = next ( profilelist)
		while i and profile do
			profile = string.gsub(profile, ".lua", "")
			--d("X: "..tostring(profile).." == "..tostring(gSMnewname))
			profiles = profiles..","..profile
			if ( Settings.GW2MINION.gSMlastprofile ~= nil and Settings.GW2MINION.gSMlastprofile == profile ) then
				d("Last Profile found : "..profile)
				found = profile
				break
			end
			i,profile = next ( profilelist,i)
		end

	else
		d("No Skillmanager profiles found")
	end
	gSMprofile_listitems = profiles
	gSMprofile = found
end

function SkillMgr.SaveProfile()
--TODO: SAVE FILE WITH C++
	-- Save current Profiledata into the Profile-file
	if (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then

		d("Saving Profile Data into File: "..gSMprofile)
			local string2write = ""
			local skID,skill = next (SkillMgr.SkillSet)
			while skID and skill do
				--d("Saving SkillID :"..tostring(skID))
				--[[if (SkillMgr.skills[skID]) then
					if (SkillMgr.skills[skID].name) then string2write = string2write..("SKM_NAME_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].name).."\n") end
					if (SkillMgr.skills[skID].contentID) then string2write = string2write..("SKM_ID_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].contentID).."\n") end
					if (SkillMgr.skills[skID].ON) then string2write = string2write..("SKM_ON_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].ON).."\n") end
					if (SkillMgr.skills[skID].Prio) then string2write = string2write..("SKM_Prio_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].Prio).."\n") end
					if (SkillMgr.skills[skID].los) then string2write = string2write..("SKM_LOS_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].los).."\n") end
					if (SkillMgr.skills[skID].minRange) then string2write = string2write..("SKM_MinR_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].minRange).."\n") end
					if (SkillMgr.skills[skID].MaxRange) then string2write = string2write..("SKM_MaxR_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].MaxRange).."\n") end
					if (SkillMgr.skills[skID].isGroundTargeted) then string2write = string2write..("SKM_GT_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].isGroundTargeted).."\n") end
					if (SkillMgr.skills[skID].TType) then string2write = string2write..("SKM_TType_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TType).."\n") end
					if (SkillMgr.skills[skID].OutOfCombat) then string2write = string2write..("SKM_OutOfCombat_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].OutOfCombat).."\n") end
					if (SkillMgr.skills[skID].PMove) then string2write = string2write..("SKM_PMove_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PMove).."\n") end
					if (SkillMgr.skills[skID].phpl) then string2write = string2write..("SKM_PHPL_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].phpl).."\n") end
					if (SkillMgr.skills[skID].phpb) then string2write = string2write..("SKM_PHPB_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].phpb).."\n") end
					if (SkillMgr.skills[skID].PPowL) then string2write = string2write..("SKM_PPowL_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PPowL).."\n") end
					if (SkillMgr.skills[skID].PEff1) then string2write = string2write..("SKM_PEff1_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PEff1).."\n") end
					if (SkillMgr.skills[skID].PEff2) then string2write = string2write..("SKM_PEff2_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PEff2).."\n") end
					if (SkillMgr.skills[skID].PCondC) then string2write = string2write..("SKM_PCondC_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PCondC).."\n") end
					if (SkillMgr.skills[skID].PNEff1) then string2write = string2write..("SKM_PNEff1_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PNEff1).."\n") end
					if (SkillMgr.skills[skID].PNEff2) then string2write = string2write..("SKM_PNEff2_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PNEff2).."\n") end
					if (SkillMgr.skills[skID].PPowB) then string2write = string2write..("SKM_PPowB_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PPowB).."\n") end
					if (SkillMgr.skills[skID].TMove) then string2write = string2write..("SKM_TMove_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TMove).."\n") end
					if (SkillMgr.skills[skID].thpl) then string2write = string2write..("SKM_THPL_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].thpl).."\n") end
					if (SkillMgr.skills[skID].thpb) then string2write = string2write..("SKM_THPB_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].thpb).."\n") end
					if (SkillMgr.skills[skID].TECount) then string2write = string2write..("SKM_TECount_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TECount).."\n") end
					if (SkillMgr.skills[skID].TERange) then string2write = string2write..("SKM_TERange_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TERange).."\n") end
					if (SkillMgr.skills[skID].TACount) then string2write = string2write..("SKM_TACount_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TACount).."\n") end
					if (SkillMgr.skills[skID].TARange) then string2write = string2write..("SKM_TARange_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TARange).."\n") end
					if (SkillMgr.skills[skID].TEff1) then string2write = string2write..("SKM_TEff1_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TEff1).."\n") end
					if (SkillMgr.skills[skID].TEff2) then string2write = string2write..("SKM_TEff2_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TEff2).."\n") end
					if (SkillMgr.skills[skID].TNEff1) then string2write = string2write..("SKM_TNEff1_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TNEff1).."\n") end
					if (SkillMgr.skills[skID].TNEff2) then string2write = string2write..("SKM_TNEff1_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TNEff2).."\n") end
					if (SkillMgr.skills[skID].TCondC) then string2write = string2write..("SKM_TCondC_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TCondC).."\n") end
					if (SkillMgr.skills[skID].PBoonC) then string2write = string2write..("SKM_PBoonC_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].PBoonC).."\n") end
					if (SkillMgr.skills[skID].TBoonC) then string2write = string2write..("SKM_TBoonC_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].TBoonC).."\n") end
					if (SkillMgr.skills[skID].SPoll) then string2write = string2write..("SKM_SPoll_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].SPoll).."\n") end
					if (SkillMgr.skills[skID].notContentID) then string2write = string2write..("SKM_notContentID_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].notContentID).."\n") end
					if (SkillMgr.skills[skID].skillExists) then string2write = string2write..("SKM_skillExists_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].skillExists).."\n") end
					if (SkillMgr.skills[skID].skillReady) then string2write = string2write..("SKM_skillReady_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].skillReady).."\n") end
					if (SkillMgr.skills[skID].skillNotReady) then string2write = string2write..("SKM_skillNotReady_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].skillNotReady).."\n") end
					if (SkillMgr.skills[skID].incomingDamageMin) then string2write = string2write..("SKM_incomingDamageMin_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].incomingDamageMin).."\n") end
					if (SkillMgr.skills[skID].incomingDamageMax) then string2write = string2write..("SKM_incomingDamageMax_"..tostring(skID).."="..tostring(SkillMgr.skills[skID].incomingDamageMax).."\n") end
				end]]
				
				if (_G["SKM_NAME_"..tostring(skID)] ) then string2write = string2write..("SKM_NAME_"..tostring(skID).."="..tostring(_G["SKM_NAME_"..tostring(skID)]).."\n") end
				if (_G["SKM_ID_"..tostring(skID)] ) then string2write = string2write..("SKM_ID_"..tostring(skID).."="..tostring(_G["SKM_ID_"..tostring(skID)]).."\n") end
				if (_G["SKM_ON_"..tostring(skID)] ) then string2write = string2write..("SKM_ON_"..tostring(skID).."="..tostring(_G["SKM_ON_"..tostring(skID)]).."\n") end
				if (_G["SKM_Prio_"..tostring(skID)] ) then string2write = string2write..("SKM_Prio_"..tostring(skID).."="..tostring(_G["SKM_Prio_"..tostring(skID)]).."\n") end
				if (_G["SKM_LOS_"..tostring(skID)] ) then string2write = string2write..("SKM_LOS_"..tostring(skID).."="..tostring(_G["SKM_LOS_"..tostring(skID)]).."\n") end
				if (_G["SKM_MinR_"..tostring(skID)] ) then string2write = string2write..("SKM_MinR_"..tostring(skID).."="..tostring(_G["SKM_MinR_"..tostring(skID)]).."\n") end
				if (_G["SKM_MaxR_"..tostring(skID)] ) then string2write = string2write..("SKM_MaxR_"..tostring(skID).."="..tostring(_G["SKM_MaxR_"..tostring(skID)]).."\n") end
				if (_G["SKM_GT_"..tostring(skID)] ) then string2write = string2write..("SKM_GT_"..tostring(skID).."="..tostring(_G["SKM_GT_"..tostring(skID)]).."\n") end
				if (_G["SKM_TType_"..tostring(skID)] ) then string2write = string2write..("SKM_TType_"..tostring(skID).."="..tostring(_G["SKM_TType_"..tostring(skID)]).."\n") end
				if (_G["SKM_OutOfCombat_"..tostring(skID)] ) then string2write = string2write..("SKM_OutOfCombat_"..tostring(skID).."="..tostring(_G["SKM_OutOfCombat_"..tostring(skID)]).."\n") end

				if (_G["SKM_PMove_"..tostring(skID)] ) then string2write = string2write..("SKM_PMove_"..tostring(skID).."="..tostring(_G["SKM_PMove_"..tostring(skID)]).."\n") end
				if (_G["SKM_PHPL_"..tostring(skID)] ) then string2write = string2write..("SKM_PHPL_"..tostring(skID).."="..tostring(_G["SKM_PHPL_"..tostring(skID)]).."\n") end
				if (_G["SKM_PHPB_"..tostring(skID)] ) then string2write = string2write..("SKM_PHPB_"..tostring(skID).."="..tostring(_G["SKM_PHPB_"..tostring(skID)]).."\n") end
				if (_G["SKM_PPowL_"..tostring(skID)] ) then string2write = string2write..("SKM_PPowL_"..tostring(skID).."="..tostring(_G["SKM_PPowL_"..tostring(skID)]).."\n") end
				if (_G["SKM_PEff1_"..tostring(skID)] ) then string2write = string2write..("SKM_PEff1_"..tostring(skID).."="..tostring(_G["SKM_PEff1_"..tostring(skID)]).."\n") end
				if (_G["SKM_PEff2_"..tostring(skID)] ) then string2write = string2write..("SKM_PEff2_"..tostring(skID).."="..tostring(_G["SKM_PEff2_"..tostring(skID)]).."\n") end
				if (_G["SKM_PCondC_"..tostring(skID)] ) then string2write = string2write..("SKM_PCondC_"..tostring(skID).."="..tostring(_G["SKM_PCondC_"..tostring(skID)]).."\n") end
				if (_G["SKM_PNEff1_"..tostring(skID)] ) then string2write = string2write..("SKM_PNEff1_"..tostring(skID).."="..tostring(_G["SKM_PNEff1_"..tostring(skID)]).."\n") end
				if (_G["SKM_PNEff2_"..tostring(skID)] ) then string2write = string2write..("SKM_PNEff2_"..tostring(skID).."="..tostring(_G["SKM_PNEff2_"..tostring(skID)]).."\n") end
				if (_G["SKM_PPowB_"..tostring(skID)] ) then string2write = string2write..("SKM_PPowB_"..tostring(skID).."="..tostring(_G["SKM_PPowB_"..tostring(skID)]).."\n") end

				if (_G["SKM_TMove_"..tostring(skID)] ) then string2write = string2write..("SKM_TMove_"..tostring(skID).."="..tostring(_G["SKM_TMove_"..tostring(skID)]).."\n") end
				if (_G["SKM_THPL_"..tostring(skID)] ) then string2write = string2write..("SKM_THPL_"..tostring(skID).."="..tostring(_G["SKM_THPL_"..tostring(skID)]).."\n") end
				if (_G["SKM_THPB_"..tostring(skID)] ) then string2write = string2write..("SKM_THPB_"..tostring(skID).."="..tostring(_G["SKM_THPB_"..tostring(skID)]).."\n") end
				if (_G["SKM_TECount_"..tostring(skID)] ) then string2write = string2write..("SKM_TECount_"..tostring(skID).."="..tostring(_G["SKM_TECount_"..tostring(skID)]).."\n") end
				if (_G["SKM_TERange_"..tostring(skID)] ) then string2write = string2write..("SKM_TERange_"..tostring(skID).."="..tostring(_G["SKM_TERange_"..tostring(skID)]).."\n") end
				if (_G["SKM_TACount_"..tostring(skID)] ) then string2write = string2write..("SKM_TACount_"..tostring(skID).."="..tostring(_G["SKM_TACount_"..tostring(skID)]).."\n") end
				if (_G["SKM_TARange_"..tostring(skID)] ) then string2write = string2write..("SKM_TARange_"..tostring(skID).."="..tostring(_G["SKM_TARange_"..tostring(skID)]).."\n") end
				if (_G["SKM_TEff1_"..tostring(skID)] ) then string2write = string2write..("SKM_TEff1_"..tostring(skID).."="..tostring(_G["SKM_TEff1_"..tostring(skID)]).."\n") end
				if (_G["SKM_TEff2_"..tostring(skID)] ) then string2write = string2write..("SKM_TEff2_"..tostring(skID).."="..tostring(_G["SKM_TEff2_"..tostring(skID)]).."\n") end
				if (_G["SKM_TNEff1_"..tostring(skID)] ) then string2write = string2write..("SKM_TNEff1_"..tostring(skID).."="..tostring(_G["SKM_TNEff1_"..tostring(skID)]).."\n") end
				if (_G["SKM_TNEff2_"..tostring(skID)] ) then string2write = string2write..("SKM_TNEff2_"..tostring(skID).."="..tostring(_G["SKM_TNEff2_"..tostring(skID)]).."\n") end
				if (_G["SKM_TCondC_"..tostring(skID)] ) then string2write = string2write..("SKM_TCondC_"..tostring(skID).."="..tostring(_G["SKM_TCondC_"..tostring(skID)]).."\n") end
				if (_G["SKM_PBoonC_"..tostring(skID)] ) then string2write = string2write..("SKM_PBoonC_"..tostring(skID).."="..tostring(_G["SKM_PBoonC_"..tostring(skID)]).."\n") end
				if (_G["SKM_TBoonC_"..tostring(skID)] ) then string2write = string2write..("SKM_TBoonC_"..tostring(skID).."="..tostring(_G["SKM_TBoonC_"..tostring(skID)]).."\n") end
				if (_G["SKM_SPoll_"..tostring(skID)] ) then string2write = string2write..("SKM_SPoll_"..tostring(skID).."="..tostring(_G["SKM_SPoll_"..tostring(skID)]).."\n") end
				if (_G["SKM_notContentID_"..tostring(skID)] ) then string2write = string2write..("SKM_notContentID_"..tostring(skID).."="..tostring(_G["SKM_notContentID_"..tostring(skID)]).."\n") end
				if (_G["SKM_skillExists_"..tostring(skID)] ) then string2write = string2write..("SKM_skillExists_"..tostring(skID).."="..tostring(_G["SKM_skillExists_"..tostring(skID)]).."\n") end
				if (_G["SKM_skillReady_"..tostring(skID)] ) then string2write = string2write..("SKM_skillReady_"..tostring(skID).."="..tostring(_G["SKM_skillReady_"..tostring(skID)]).."\n") end
				if (_G["SKM_skillNotReady_"..tostring(skID)] ) then string2write = string2write..("SKM_skillNotReady_"..tostring(skID).."="..tostring(_G["SKM_skillNotReady_"..tostring(skID)]).."\n") end
				if (_G["SKM_incomingDamageMin_"..tostring(skID)] ) then string2write = string2write..("SKM_incomingDamageMin_"..tostring(skID).."="..tostring(_G["SKM_incomingDamageMin_"..tostring(skID)]).."\n") end
				if (_G["SKM_incomingDamageMax_"..tostring(skID)] ) then string2write = string2write..("SKM_incomingDamageMax_"..tostring(skID).."="..tostring(_G["SKM_incomingDamageMax_"..tostring(skID)]).."\n") end


				string2write = string2write..("SKM_END_"..tostring(skID).."="..tostring(0).."\n")
				skID,skill = next (SkillMgr.SkillSet,skID)
			end
			d(filewrite(SkillMgr.profilepath ..gSMprofile..".lua",string2write))

	end
end

function SkillMgr.DeleteCurrentProfile()
	-- Delete the currently selected Profile - file from the HDD
	if (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
		d("Deleting current Profile: "..gSMprofile)
		os.remove(SkillMgr.profilepath ..gSMprofile..".lua")
		SkillMgr.UpdateProfiles()
	end
end

function SkillMgr.UpdateCurrentProfileData()
	if ( gSMprofile ~= nil and gSMprofile ~= "" and gSMprofile ~= "None" ) then --and (tostring(gSMprofile) ~= tostring(Settings.GW2MINION.gSMlastprofile) or TableSize(SkillMgr.SkillSet) == 0)) then

		local profile = fileread(SkillMgr.profilepath..gSMprofile..".lua")
		if ( TableSize(profile) > 0) then
			local unsortedSkillList = {}
			local newskill = {}

			local i, line = next (profile)
			while i and line do
				local _, key, skillID, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
				--d("key: "..tostring(key).." skillID:"..tostring(skillID) .." value:"..tostring(value))
				if ( key and skillID and value ) then
					value = string.gsub(value, "\r", "")
					if ( key == "END" ) then
						--d("Adding Skill :"..newskill.name.."Prio:"..tostring(newskill.Prio))
						table.insert(unsortedSkillList,tonumber(newskill.Prio),newskill)
						newskill = {}
					elseif ( key == "ID" )then newskill.contentID = tonumber(value)
					elseif ( key == "NAME" )then newskill.name = value
					elseif ( key == "ON" )then newskill.ON = tostring(value)
					elseif ( key == "Prio" )then newskill.Prio = tonumber(value)
					elseif ( key == "LOS" )then newskill.los = tostring(value)
					elseif ( key == "MinR" )then newskill.minRange = tonumber(value)
					elseif ( key == "MaxR" )then newskill.maxRange = tonumber(value)
					elseif ( key == "GT" )then newskill.isGroundTargeted = tostring(value)
					elseif ( key == "TType" )then newskill.TType = tostring(value)
					elseif ( key == "OutOfCombat" )then newskill.OutOfCombat = tostring(value)
					elseif ( key == "PMove" )then newskill.PMove = tostring(value)
					elseif ( key == "PHPL" )then newskill.PHPL = tonumber(value)
					elseif ( key == "PHPB" )then newskill.PHPB = tonumber(value)
					elseif ( key == "PPowL" )then newskill.PPowL = tonumber(value)
					elseif ( key == "PEff1" )then newskill.PEff1 = tostring(value)
					elseif ( key == "PEff2" )then newskill.PEff2 = tostring(value)
					elseif ( key == "PNEff1" )then newskill.PNEff1 = tostring(value)
					elseif ( key == "PNEff2" )then newskill.PNEff2 = tostring(value)
					elseif ( key == "PCondC" )then newskill.PCondC = tostring(value)

					elseif ( key == "PPowB" )then newskill.PPowB = tonumber(value)
					elseif ( key == "TMove" )then newskill.TMove = tostring(value)
					elseif ( key == "THPL" )then newskill.THPL = tonumber(value)
					elseif ( key == "THPB" )then newskill.THPB = tonumber(value)

					elseif ( key == "TECount" )then newskill.TECount = tonumber(value)
					elseif ( key == "TERange" )then newskill.TERange = tonumber(value)
					elseif ( key == "TACount" )then newskill.TACount = tonumber(value)
					elseif ( key == "TARange" )then newskill.TARange = tonumber(value)
					elseif ( key == "TEff1" )then newskill.TEff1 = tostring(value)
					elseif ( key == "TEff2" )then newskill.TEff2 = tostring(value)
					elseif ( key == "TNEff1" )then newskill.TNEff1 = tostring(value)
					elseif ( key == "TNEff2" )then newskill.TNEff2 = tostring(value)

					elseif ( key == "TCondC" )then newskill.TCondC = tostring(value)
					elseif ( key == "PBoonC" )then newskill.PBoonC = tostring(value)
					elseif ( key == "TBoonC" )then newskill.TBoonC = tostring(value)
					elseif ( key == "SPoll" )then newskill.SPoll = tostring(value)
					elseif ( key == "notContentID" )then newskill.notContentID = tostring(value)
					elseif ( key == "skillExists" )then newskill.skillExists = tostring(value)
					elseif ( key == "skillReady" )then newskill.skillReady = tostring(value)
					elseif ( key == "skillNotReady" )then newskill.skillNotReady = tostring(value)
					elseif ( key == "incomingDamageMin" )then newskill.incomingDamageMin = tostring(value)
					elseif ( key == "incomingDamageMax" )then newskill.incomingDamageMax = tostring(value)

					end
				else
					d("Error loading inputline: Key: "..(key).." skillID:"..tostring(skillID) .." value:"..tostring(value))
				end

				i, line = next (profile,i)
			end

			-- Create UI Fields
			local sortedSkillList = {}
			if ( TableSize(unsortedSkillList) > 0 ) then
				local i,skill = next (unsortedSkillList)
				while i and skill do
					sortedSkillList[#sortedSkillList+1] = skill
					i,skill = next (unsortedSkillList,i)
				end
				table.sort(sortedSkillList, function(a,b) return a.Prio < b.Prio end )

				for i = 1,TableSize(sortedSkillList),1 do
					if (sortedSkillList[i] ~= nil ) then
						SkillMgr.CreateNewSkillEntry(sortedSkillList[i])
					end
				end
			end
		else
			d("Profile is empty..")
		end
	else
		d("No new SkillProfile selected!")
	end
end

function SkillMgr.RefreshCurrentSkillList()
	SkillMgr.ClearCurrentSkills()
	SkillMgr.UIneedsRefresh = true
	--d("Clearing SkillList...")
end

function SkillMgr.CheckForNewSkills()
	for i = 1, 16, 1 do
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then
			if ( SkillMgr.SkillSet[skill.contentID] == nil ) then
				SkillMgr.CreateNewSkillEntry(skill)
			end
		end
	end
end
--TODO: CHANGE GUI ELEMENT FUNCTIONS TO WSTRING!
function SkillMgr.CreateNewSkillEntry(skill)
	if (skill ~= nil ) then
		local skname
		if ( tonumber(skill.Prio) ~= nil and SkillMgr.CheckIfPriorityExists(skill.Prio) ) then
			skname = "PRIORITY CONFLICT!!: "..tostring(skill.Prio or TableSize(SkillMgr.SkillSet)*100)..": "..skill.name
		else
			skname = "Priority: "..tostring(skill.Prio or TableSize(SkillMgr.SkillSet)*100)..": "..skill.name
		end

		local skID = skill.contentID
		if ( skill.name ~= "" and tonumber(skID) ~= nil) then

			GUI_NewField(SkillMgr.mainwindow.name,"ID","SKM_ID_"..tostring(skID),skname)
			_G["SKM_ID_"..tostring(skID)] = skID

			-- NAME,
			--GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].enabled,"SKM_NAME_"..tostring(skID),tostring(skname))
			_G["SKM_NAME_"..tostring(skID)] = skill.name

			-- ENABLED
			local skON = skill.ON or "1"
			GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].enabled,"SKM_ON_"..tostring(skID),skname)
			_G["SKM_ON_"..tostring(skID)] = tostring(skON)

			-- PRIORITY
			local skPrio = skill.Prio or TableSize(SkillMgr.SkillSet)*100
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].priority,"SKM_Prio_"..tostring(skID),skname)
			_G["SKM_Prio_"..tostring(skID)] = skPrio

			-- REQUIRES LOS
			local skLOS = skill.los or "Yes"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].los,"SKM_LOS_"..tostring(skID),skname,"Yes,No");
			_G["SKM_LOS_"..tostring(skID)] = tostring(skLOS)

			-- MINRANGE
			local skMinR = skill.minRange
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].minRange,"SKM_MinR_"..tostring(skID),skname)
			_G["SKM_MinR_"..tostring(skID)] = skMinR

			-- MAXRANGE
			local skMaxR = skill.maxRange
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].maxRange,"SKM_MaxR_"..tostring(skID),skname)
			_G["SKM_MaxR_"..tostring(skID)] = skMaxR

			-- IS GROUND TARGETED
			local skGT = skill.isGroundTargeted
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].isGroundTargeted,"SKM_GT_"..tostring(skID),skname,"false,true");
			_G["SKM_GT_"..tostring(skID)] = tostring(skGT)

			-- TARGETTYPE
			local skTType = skill.TType or "Enemy"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetType,"SKM_TType_"..tostring(skID),skname,"Enemy,Self");
			_G["SKM_TType_"..tostring(skID)] = tostring(skTType)

			-- USEOUTOFCOMBAT
			local skOutOfCombat = skill.OutOfCombat or "Either"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].useOutOfCombat,"SKM_OutOfCombat_"..tostring(skID),skname,"No,Yes,Either");
			_G["SKM_OutOfCombat_"..tostring(skID)] = tostring(skOutOfCombat)

			-- PLAYER MOVING
			local skPMove = skill.PMove or "Either"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerMoving,"SKM_PMove_"..tostring(skID),skname,"Either,Yes,No");
			_G["SKM_PMove_"..tostring(skID)] = tostring(skPMove)

			-- PLAYER >HEALTH PERCENT
			local skPHPLarger = skill.PHPL or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerHPGT,"SKM_PHPL_"..tostring(skID),skname);
			_G["SKM_PHPL_"..tostring(skID)] = skPHPLarger

			-- PLAYER <HEALTH PERCENT
			local skPHPBelow = skill.PHPB or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerHPLT,"SKM_PHPB_"..tostring(skID),skname);
			_G["SKM_PHPB_"..tostring(skID)] = skPHPBelow

			-- PLAYER >POWER PERCENT
			local skPPOWLarger = skill.PPowL or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerPowerGT ,"SKM_PPowL_"..tostring(skID),skname);
			_G["SKM_PPowL_"..tostring(skID)] = skPPOWLarger

			-- PLAYER <POWER PERCENT
			local skPPOWBelow = skill.PPowB or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerPowerLT,"SKM_PPowB_"..tostring(skID),skname);
			_G["SKM_PPowB_"..tostring(skID)] = skPPOWBelow

			-- PLAYER HAS ANY EFFECT1
			local skPEff1 = skill.PEff1 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerHas,"SKM_PEff1_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_PEff1_"..tostring(skID)] = tostring(skPEff1)
			-- PLAYER HAS ANY EFFECT2
			local skPEff2 = skill.PEff2 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].orPlayerHas,"SKM_PEff2_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_PEff2_"..tostring(skID)] = tostring(skPEff2)
			-- PLAYER HAS #CONDITIONS
			local skPCondC = skill.PCondC or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].orPlayerCond,"SKM_PCondC_"..tostring(skID),skname);
			_G["SKM_PCondC_"..tostring(skID)] = skPCondC

			-- PLAYER HAS NOT EFFECT1
			local skPNEff1 = skill.PNEff1 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].playerHasNot,"SKM_PNEff1_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_PNEff1_"..tostring(skID)] = tostring(skPNEff1)
			-- PLAYER HAS NOT EFFECT2
			local skPNEff2 = skill.PNEff2 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].orPlayerHasNot ,"SKM_PNEff2_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_PNEff2_"..tostring(skID)] = tostring(skPNEff2)

			-- TARGET MOVING
			local skTMove = skill.TMove or "Either"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetMoving,"SKM_TMove_"..tostring(skID),skname,"Either,Yes,No");
			_G["SKM_TMove_"..tostring(skID)] = tostring(skTMove)

			-- TARGET >HEALTH PERCENT
			local skTHPLarger = skill.THPL or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetHPGT,"SKM_THPL_"..tostring(skID),skname);
			_G["SKM_THPL_"..tostring(skID)] = skTHPLarger

			-- TARGET <HEALTH PERCENT
			local skTHPBelow = skill.THPB or 0
			GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetHPLT,"SKM_THPB_"..tostring(skID),skname);
			_G["SKM_THPB_"..tostring(skID)] = skTHPBelow

			-- NEAR TARGET ENEMIES COUNT
			local skTECount = skill.TECount or 0
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].enemiesNearCount,"SKM_TECount_"..tostring(skID),skname,"0,1,2,3,4,5,6");
			_G["SKM_TECount_"..tostring(skID)] = tostring(skTECount)

			-- NEAR TARGET ENEMIES RANGE
			local skTERange = skill.TERange or 0
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].enemiesNearRange,"SKM_TERange_"..tostring(skID),skname,"0,100,150,200,250,350,500,750");
			_G["SKM_TERange_"..tostring(skID)] = tostring(skTERange)

			-- NEAR TARGET ALLIES COUNT
			local skTACount = skill.TACount or 0
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].alliesNearCount,"SKM_TACount_"..tostring(skID),skname,"0,1,2,3,4,5,6");
			_G["SKM_TACount_"..tostring(skID)] = tostring(skTACount)

			-- NEAR TARGET ALLIES RANGE
			local skTARange = skill.TARange or 0
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].alliesNearRange,"SKM_TARange_"..tostring(skID),skname,"0,100,200,300,400,500,600");
			_G["SKM_TARange_"..tostring(skID)] = tostring(skTARange)

			-- TARGET HAS ANY EFFECT1
			local skTEff1 = skill.TEff1 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetHas,"SKM_TEff1_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_TEff1_"..tostring(skID)] = tostring(skTEff1)
			-- TARGET HAS ANY EFFECT2
			local skTEff2 = skill.TEff2 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].orTargetHas,"SKM_TEff2_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_TEff2_"..tostring(skID)] = tostring(skTEff2)

			-- TARGET HAS NOT EFFECT1
			local skTNEff1 = skill.TNEff1 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].targetHasNot,"SKM_TNEff1_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_TNEff1_"..tostring(skID)] = tostring(skTNEff1)
			-- TARGET HAS NOT EFFECT2
			local skTNEff2 = skill.TNEff2 or "None"
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].orTargetHasNot,"SKM_TNEff2_"..tostring(skID),skname,"None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
			_G["SKM_TNEff2_"..tostring(skID)] = tostring(skTNEff2)

			-- TARGET HAS #CONDITIONS
			local skTCondC = skill.TCondC or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Target has #Conditions >","SKM_TCondC_"..tostring(skID),skname);
			_G["SKM_TCondC_"..tostring(skID)] = skTCondC


			-- ADD MORE HERE

			-- PLAYER HAS #BOONS
			local skPBoonC = skill.PBoonC or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Player has #Boons >","SKM_PBoonC_"..tostring(skID),skname);
			_G["SKM_PBoonC_"..tostring(skID)] = skPBoonC

			-- TARGET HAS #BOONS
			local skTBoonC = skill.TBoonC or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Target has #Boons >","SKM_TBoonC_"..tostring(skID),skname);
			_G["SKM_TBoonC_"..tostring(skID)] = skTBoonC

			-- SKILL POLL TIME IN MS
			local skTSPoll = skill.SPoll or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Poll (milliseconds)","SKM_SPoll_"..tostring(skID),skname);
			_G["SKM_SPoll_"..tostring(skID)] = skTSPoll

			-- NOT CONTENT ID
			local skTnotContentID = skill.notContentID or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Not Content ID (contentID, contentID#slot)","SKM_notContentID_"..tostring(skID),skname);
			_G["SKM_notContentID_"..tostring(skID)] = skTnotContentID

			-- SKILL EXISTS
			local skTskillExists = skill.skillExists or 0
			GUI_NewField(SkillMgr.mainwindow.name,"Skill exists (contentID#slot)","SKM_skillExists_"..tostring(skID),skname);
			_G["SKM_skillExists_"..tostring(skID)] = skTskillExists

			-- SKILL READY
			local skTskillReady = skill.skillReady or 0
			GUI_NewField(SkillMgr.mainwindow.name,'Any skills ready (e.g. "5801#1 5816@2")',"SKM_skillReady_"..tostring(skID),skname);
			_G["SKM_skillReady_"..tostring(skID)] = skTskillReady

			-- SKILL NOT READY
			local skTskillNotReady = skill.skillNotReady or 0
			GUI_NewField(SkillMgr.mainwindow.name,'All skills not ready (e.g. "5801#1 5816@2")',"SKM_skillNotReady_"..tostring(skID),skname);
			_G["SKM_skillNotReady_"..tostring(skID)] = skTskillNotReady

			-- SKILL NOT READY
			local skTincomingDamageMin = skill.incomingDamageMin or 0
			GUI_NewField(SkillMgr.mainwindow.name,'>= Incoming (damage/milliseconds)',"SKM_incomingDamageMin_"..tostring(skID),skname);
			_G["SKM_incomingDamageMin_"..tostring(skID)] = skTincomingDamageMin

			-- SKILL NOT READY
			local skTincomingDamageMax = skill.incomingDamageMax or 0
			GUI_NewField(SkillMgr.mainwindow.name,'<= Incoming (damage/milliseconds)',"SKM_incomingDamageMax_"..tostring(skID),skname);
			_G["SKM_incomingDamageMax_"..tostring(skID)] = skTincomingDamageMax
			
			SkillMgr.SkillSet[skID] = { name = skname , prio = skPrio}
		end
	end
end

function SkillMgr.CheckIfPriorityExists(prio)
	local id,skill = next (SkillMgr.SkillSet)
	while id and skill do
		if ( tonumber(skill.prio) == tonumber(prio) ) then
			return true
		end
		id,skill = next (SkillMgr.SkillSet,id)
	end
	return false
end

function SkillMgr.ClearCurrentSkills()
	local id,skill = next (SkillMgr.SkillSet)
	while id and skill do
		--d("Removing :"..(skill.name))
		GUI_Delete("SkillManager",skill.name)
		id,skill = next (SkillMgr.SkillSet,id)
	end
	SkillMgr.SkillSet = {}
end

function SkillMgr.CountCondition(target)
	local tbuffs = target.buffs
	if ( tbuffs ) then
		local condcount = 0
		local i,buff = next(tbuffs)
		while i and buff do
			local bskID = buff.skillID
			if ( bskID and SkillMgr.ConditionsEnum[bskID] ~= nil) then
				condcount = condcount + 1
			end
			i,buff = next(tbuffs,i)
		end
		return condcount
	else
		return 0
	end
end

function SkillMgr.CountBoon(target)
	local tbuffs = target.buffs
	if ( tbuffs ) then
		local booncount = 0
		local i,buff = next(tbuffs)
		while i and buff do
			local bskID = buff.skillID
			if ( bskID and SkillMgr.BoonsEnum[bskID] ~= nil) then
				booncount = booncount + 1
			end
			i,buff = next(tbuffs,i)
		end
		return booncount
	else
		return 0
	end
end

function SkillMgr.SelectTargetExtended(check_range, need_los, only_players)
	local TargetList
	if (need_los == "1" and only_players == "1") then
		TargetList = CharacterList( "attackable,los,player,alive,noCritter,maxdistance="..check_range)
	elseif (need_los == "0" and only_players == "0") then
		TargetList = CharacterList( "attackable,alive,noCritter,maxdistance="..check_range)
	elseif (need_los == "0" and only_players == "1") then
		TargetList = CharacterList( "attackable,player,alive,noCritter,maxdistance="..check_range)
	elseif (need_los == "1" and only_players == "0") then
		TargetList = CharacterList( "attackable,los,alive,noCritter,maxdistance="..check_range)
	end

	if ( TableSize ( TargetList ) > 0 )then
		local target_list
		target_list = {}
		local compare_to
		local chosen_tid
		local chosen_target
		local v_ch_tid
		local v_ch_target
		local v_ch_found
		local c_ch_tid
		local c_ch_target
		local c_ch_found
		local n_ch_tid
		local n_ch_target
		local n_ch_found
		v_ch_found = false
		c_ch_found = false
		n_ch_found = false

		if (gsMtargetmode == "Least Conditions" or gsMtargetmode == "Least Boons") then
			compare_to = 9999
		elseif (gsMtargetmode == "Most Conditions" or gsMtargetmode == "Most Boons") then
			compare_to = 0
		end

		local tid, target
		tid,target = next(TargetList)
		while ( tid ~= nil and target ~= nil) do
			local compare_with

			if (gsMtargetmode == "Least Conditions" or gsMtargetmode == "Most Conditions") then
				compare_with = SkillMgr.CountCondition(target)
			elseif (gsMtargetmode == "Least Boons" or gsMtargetmode == "Most Boons") then
				compare_with = SkillMgr.CountBoon(target)
			end

			if (gsMtargetmode == "Least Conditions" or gsMtargetmode == "Least Boons") then
				if (compare_to >= compare_with) then
					chosen_tid = tid
					chosen_target = target

					if (target.isChampion) then
						c_ch_tid = tid
						c_ch_target = target
						c_ch_found = true
					elseif (target.isVeteran) then
						v_ch_tid = tid
						v_ch_target = target
						v_ch_found = true
					else
						n_ch_tid = tid
						n_ch_target = target
						n_ch_found = true
					end
					compare_to = compare_with
				end
			elseif (gsMtargetmode == "Most Conditions" or gsMtargetmode == "Most Boons") then
				if (compare_to <= compare_with) then
					chosen_tid = tid
					chosen_target = target

					if (target.isChampion) then
						c_ch_tid = tid
						c_ch_target = target
						c_ch_found = true
					elseif (target.isVeteran) then
						v_ch_tid = tid
						v_ch_target = target
						v_ch_found = true
					else
						n_ch_tid = tid
						n_ch_target = target
						n_ch_found = true
					end
					compare_to = compare_with
				end
			end

			tid,target = next(TargetList, tid)
		end
		if (gSMtargetpriority == "Champion" and c_ch_found == true) then
			target_list[c_ch_tid] = c_ch_target
		elseif (gSMtargetpriority == "Veteran" and v_ch_found == true) then
			target_list[v_ch_tid] = v_ch_target
		elseif (gSMtargetpriority == "Normal" and n_ch_found == true) then
			target_list[n_ch_tid] = n_ch_target
		else
			target_list[chosen_tid] = chosen_target
		end
		return target_list
	else
		return TargetList
	end
end

function SkillMgr.SelectTarget()

	local TargetList

	-- Stomp/Rezz nearby players
	if ( gSMAutoStomp == "1" or gSMAutoRezz == "1") then
		if (Player.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
			TargetList = CharacterList("downed,player,maxdistance=180")
			if ( TableSize ( TargetList ) > 0 )then
				local TID, Target = next ( TargetList )
				if ( TID and TID ~= 0 and Target ) then
					if ( Player:GetTarget() ~= TID ) then
						Player:SetTarget(TID)
						return
					else
						Player:Interact(TID)
						return
					end
				end
			end
		end
	end

	if ( gsMtargetmode == "Assisted Targeting" ) then
		SkillMgr.AssistedTargeting()
	elseif ( gsMtargetmode ~= "No Autotarget" ) then

		if (gSMmode == "Attack Everything") then
			if ( gsMtargetmode == "Autotarget Weakest" )then
				TargetList = CharacterList( "lowesthealth,los,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
			elseif( gsMtargetmode == "Autotarget Closest" ) then
				TargetList = CharacterList( "nearest,los,attackable,alive,noCritter,maxdistance=1500")--..wt_global_information.AttackRange)
			elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
				TargetList = CharacterList( "clustered=300,los,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
			else
				TargetList = SkillMgr.SelectTargetExtended(wt_global_information.AttackRange, "1", "0")
			end
		else
			if ( gsMtargetmode == "Autotarget Weakest" )then
				TargetList = CharacterList( "lowesthealth,los,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
			elseif( gsMtargetmode == "Autotarget Closest" ) then
				TargetList = CharacterList( "nearest,los,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
			elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
				TargetList = CharacterList( "clustered=300,los,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
			else
				TargetList = SkillMgr.SelectTargetExtended(wt_global_information.AttackRange, "1", "1")
			end
		end
		if ( TableSize ( TargetList ) > 0 )then
			local TID, Target = next ( TargetList )
			if ( TID and TID ~= 0 and Target ) then
				if ( Player:GetTarget() ~= TID ) then
					Player:SetTarget(TID)
				end
			end
		else
			-- Increased Range
			if (gSMmode == "Attack Everything") then
				if ( gsMtargetmode == "Autotarget Weakest" )then
					TargetList = CharacterList( "lowesthealth,los,attackable,alive,noCritter,maxdistance=1500")
				elseif( gsMtargetmode == "Autotarget Closest" ) then
					TargetList = CharacterList( "nearest,los,attackable,alive,noCritter,maxdistance=1500")
				elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
					TargetList = CharacterList( "clustered=300,los,attackable,alive,noCritter,maxdistance=1500")
				else
					TargetList = SkillMgr.SelectTargetExtended("1500", "1", "0")
				end
			else
				if ( gsMtargetmode == "Autotarget Weakest" )then
					TargetList = CharacterList( "lowesthealth,los,player,attackable,alive,noCritter,maxdistance=1500")
				elseif( gsMtargetmode == "Autotarget Closest" ) then
					TargetList = CharacterList( "nearest,los,player,attackable,alive,noCritter,maxdistance=1500")
				elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
					TargetList = CharacterList( "clustered=300,los,player,attackable,alive,noCritter,maxdistance=1500")
				else
					TargetList = SkillMgr.SelectTargetExtended("1500", "1", "1")
				end
			end
			if ( TableSize ( TargetList ) > 0 )then
				local TID, Target = next ( TargetList )
				if ( TID and TID ~= 0 and Target ) then
					if ( Player:GetTarget() ~= TID ) then
						Player:SetTarget(TID)
					end
				end
			else
				-- No LOS
				if (gSMmode == "Attack Everything") then
					if ( gsMtargetmode == "Autotarget Weakest" )then
						TargetList = CharacterList( "lowesthealth,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
					elseif( gsMtargetmode == "Autotarget Closest" ) then
						TargetList = CharacterList( "nearest,attackable,alive,noCritter,maxdistance=1500")--..wt_global_information.AttackRange)
					elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
						TargetList = CharacterList( "clustered=300,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
					else
						TargetList = SkillMgr.SelectTargetExtended(wt_global_information.AttackRange, "0", "0")
					end
				else
					if ( gsMtargetmode == "Autotarget Weakest" )then
						TargetList = CharacterList( "lowesthealth,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
					elseif( gsMtargetmode == "Autotarget Closest" ) then
						TargetList = CharacterList( "nearest,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
					elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
						TargetList = CharacterList( "clustered=300,player,attackable,alive,noCritter,maxdistance="..wt_global_information.AttackRange)
					else
						TargetList = SkillMgr.SelectTargetExtended(wt_global_information.AttackRange, "0", "1")
					end
				end
				if ( TableSize ( TargetList ) > 0 )then
					local TID, Target = next ( TargetList )
					if ( TID and TID ~= 0 and Target ) then
						if ( Player:GetTarget() ~= TID ) then
							Player:SetTarget(TID)
						end
					end
				else
					-- Increased Range + No LOS
					if (gSMmode == "Attack Everything") then
						if ( gsMtargetmode == "Autotarget Weakest" )then
							TargetList = CharacterList( "lowesthealth,attackable,alive,noCritter,maxdistance=1500")
						elseif( gsMtargetmode == "Autotarget Closest" ) then
							TargetList = CharacterList( "nearest,attackable,alive,noCritter,maxdistance=1500")
						elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
							TargetList = CharacterList( "clustered=300,attackable,alive,noCritter,maxdistance=1500")
						else
							TargetList = SkillMgr.SelectTargetExtended("1500", "0", "0")
						end
					else
						if ( gsMtargetmode == "Autotarget Weakest" )then
							TargetList = CharacterList( "lowesthealth,player,attackable,alive,noCritter,maxdistance=1500")
						elseif( gsMtargetmode == "Autotarget Closest" ) then
							TargetList = CharacterList( "nearest,player,attackable,alive,noCritter,maxdistance=1500")
						elseif( gsMtargetmode == "Autotarget Biggest Crowd" ) then
							TargetList = CharacterList( "clustered=300,player,attackable,alive,noCritter,maxdistance=1500")
						else
							TargetList = SkillMgr.SelectTargetExtended("1500", "0", "1")
						end
					end
					if ( TableSize ( TargetList ) > 0 )then
						local TID, Target = next ( TargetList )
						if ( TID and TID ~= 0 and Target ) then
							if ( Player:GetTarget() ~= TID ) then
								Player:SetTarget(TID)
							end
						end
					end
				end
			end
		end
	end
end

function SkillMgr.SlotForSkill(skillID)
	for i = 16, 1, -1 do
		if (SkillMgr.cskills[i] and SkillMgr.cskills[i].contentID == tonumber(skillID)) then
			return i
		end
	end
	return -1
end

function SkillMgr.DoAction()

	SkillMgr.cskills = {}
	local maxrange = nil
	for i = 1, 16, 1 do
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then
			SkillMgr.cskills[i] = skill
			SkillMgr.cskills[i].slot = GW2.SKILLBARSLOT["Slot_" .. i]
			if ( gFightstyle == "Range" ) then
				if ( i > 0 and i < 6 ) then
					local smaxR = skill.maxRange
					if ( not maxrange or smaxR > maxrange) then
						maxrange = smaxR
					end
				end
			else
				if ( i == 1 ) then
					maxrange = skill.maxRange or 180
				end
			end
		end
	end
	wt_global_information.AttackRange = maxrange or 180


	local target, tid = nil, Player:GetTarget()
	if tid and tid ~= 0 then
		target = CharacterList:Get(tid)
		if target then
			target.id = tid
		else
			target = GadgetList:Get(tid)
			if target then
				target.id = tid
			end
		end
	end

	if ( target and (target.attitude == GW2.ATTITUDE.Friendly or target.attitude == GW2.ATTITUDE.Unattackable)) then
		target = nil
	else
		SkillMgr.SwapWeaponCheck("Pulse")
		SkillMgr.SwapWeaponCheck("AE")
	end

	local skillID = SkillMgr.GetNextBestSkillID(-999999)
	local mybuffs = Player.buffs
	SkillMgr.SpellIsCast = SkillMgr.IsOtherSpellCurrentlyCast()

	while not SkillMgr.SpellIsCast and skillID do
		for i = 16, 1, -1 do
			if (SkillMgr.cskills[i] and SkillMgr.cskills[i].contentID == tonumber(skillID) and tostring(_G["SKM_ON_"..tostring(skillID)]) == "1" ) then -- we have the skill in our current skilldeck
				local castable = SkillMgr.ValidateSkill(skillID, SkillMgr.cskills[i].slot, target, tid, maxrange, mybuffs, true)
				if tonumber(_G["SKM_SPoll_"..tostring(skillID)]) > 0 then
					_G["SKM_SPollTime_"..tostring(skillID)] = SkillMgr.DoActionTmr
				end
				if ( castable ) then
					-- Swap Weapon check
					if ( SkillMgr.cskills[i].slot == GW2.SKILLBARSLOT.Slot_1 ) then
						SkillMgr.SwapWeaponCheck("CoolDown")
					end

					-- CAST Self check
					if ( tostring(_G["SKM_TType_"..tostring(skillID)]) == "Self" ) then
						if (SkillMgr.CanCast() and SkillMgr.cskills[i].slot ) then
							--[[if ( SkillMgr.SkillStuckSlot ~= SkillMgr.cskills[i].slot ) then
								SkillMgr.SkillStuckSlot == SkillMgr.cskills[i].slot
							else
								if (SkillMgr.SkillStuckTmr == 0 or wt_core_information.Now - SkillMgr.SkillStuckTmr > 4000 ) then

								end
							end	]]
							Player:CastSpellNoChecks(SkillMgr.cskills[i].slot)
							--d("Casting on Self: "..tostring(SkillMgr.cskills[i].name))
							return
							--	Player:LeaveCombatState()
						end
					else
						if ( target and target.id ) then
							if (SkillMgr.CanCast()) then--sp ~= SkillMgr.cskills[i].slot ) then
								Player:CastSpellNoChecks(SkillMgr.cskills[i].slot,target.id)
								--d("Casting on Enemy: "..tostring(SkillMgr.cskills[i].name))
								return
							end
						end
					end
				end
			end
		end
		skillID = SkillMgr.GetNextBestSkillID(tonumber(_G["SKM_Prio_"..tostring(skillID)]))
	end
	-- swap weapons if target but out of range
	if ( target and target.distance > wt_global_information.AttackRange and target.attitude ~= GW2.ATTITUDE.Friendly) then
		SkillMgr.SwapWeaponCheck("Range")
	end
end

function SkillMgr.CanCast()
	local currspellslot = Player:GetCurrentlyCastedSpell()
	if ( (not Player:IsCasting() or currspellslot == GW2.SKILLBARSLOT.Slot_1 or currspellslot == GW2.SKILLBARSLOT.None) and currspellslot ~= GW2.SKILLBARSLOT.Slot_6 and not SkillMgr.SpellIsCast) then
		return true
	end
	return false
end

-- This is needed b/c this check is more precise than Player:IsCasting()
function SkillMgr.IsOtherSpellCurrentlyCast()
	for i = 0, 15, 1 do
		--if ( i ~= 5 and Player:IsSpellCurrentlyCast(i)) then
		if ( Player:IsSpellCurrentlyCast(i)) then
			return true
		end
	end
	return false
end

function SkillMgr.SwapWeaponCheck(swaptype)
	if ( gSMSwapA == "1" and (SkillMgr.SwapTmr == 0 or SkillMgr.DoActionTmr - SkillMgr.SwapTmr > 500) and (Player.inCombat or gSMSwapOOC == "1" ) ) then -- prevent hammering

		-- Swap after random Time
		if ( swaptype == "Pulse" and gSMSwapR == "1" and (SkillMgr.SwapRTmr == 0 or SkillMgr.DoActionTmr - SkillMgr.SwapRTmr > math.random(3000,6000)) and SkillMgr.CanCast()) then
			SkillMgr.SwapRTmr = SkillMgr.DoActionTmr
			SkillMgr.SwapTmr = SkillMgr.DoActionTmr
			SkillMgr.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end

		-- Swap when skills 2-5 are on CD
		if ( swaptype == "CoolDown" and gSMSwapCD == "1" and math.random(0,1) == 1 and SkillMgr.CanCast())  then
			SkillMgr.SwapTmr = SkillMgr.DoActionTmr
			SkillMgr.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end

		-- Swap when our target is out of range for the current weapon
		if ( swaptype == "Range" and gSMSwapRange == "1" and SkillMgr.CanCast()) then
			SkillMgr.SwapTmr = SkillMgr.DoActionTmr
			SkillMgr.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end
		
		if ( swaptype == "AE" and gSMSwapAE == "1") then
			if (tonumber(gSMSwapAEskill) ~= "0") then
				local skill_id, slot = string.match(gSMSwapAEskill, "^(%d+)#(%d+)$")
				if (skill_id and slot) then
					local spell = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. slot])
					skill_id = tonumber(skill_id)

					if spell then
						local min_enemies, distance = string.match(gSMSwapAEenemies, "^(%d+)=(%d+)$")
						min_enemies = tonumber(min_enemies)

						local filters = {"noCritter,attackable,alive"}
						table.insert(filters, "maxdistance=" .. distance)

						if gSMSwapAEwho == "Enemy" then
							local tid = Player:GetTarget()

							if not tid and tid == 0 then
								return
							end

							local target = CharacterList:Get(tid)
							table.insert(filters, "distanceto=" .. tid)
						end

						local t = CharacterList(table.concat(filters, ","))

						if t then
							local num = TableSize(t)

							if (spell.contentID == skill_id and num < min_enemies) or (spell.contentID ~= skill_id and num >= min_enemies) then
								SkillMgr.SwapTmr = SkillMgr.DoActionTmr
								SkillMgr.SwapWeapon(swaptype)
								--d(swaptype)
								return
							end
						end
					end
				end
			end	
		end
	end
end

function SkillMgr.SwapWeapon(swaptype)
	if ( wt_global_information.Currentprofession.professionID == 6 ) then
		--Elementalist
		if ( swaptype == "Pulse" and gSMPrioAtt and tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)])~= nil and not Player:IsSpellOnCooldown(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)]))) then
			--d("Switching to our prio attunement: "..tostring(gSMPrioAtt))
			Player:CastSpell(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)]))
			SkillMgr.SwapTmr = SkillMgr.DoActionTmr
		else
			local switch = math.random(12,15)
			if ( not Player:IsSpellOnCooldown(switch) ) then
				Player:CastSpell(switch)
				SkillMgr.SwapTmr = SkillMgr.DoActionTmr
			end
		end

	elseif( wt_global_information.Currentprofession.professionID == 3 ) then
		-- Engineer
		local availableKits = { [1] = 0 }-- Leave Kit Placeholder
		for i = 1, 16, 1 do
			if (SkillMgr.cskills[i]) then
				if ( SkillMgr.EngineerKits[SkillMgr.cskills[i].contentID] ~= nil and not Player:IsSpellOnCooldown(SkillMgr.cskills[i].slot)) then
					if ( SkillMgr.SwapWeaponTable[SkillMgr.cskills[i].slot] == nil or (SkillMgr.DoActionTmr - SkillMgr.SwapWeaponTable[SkillMgr.cskills[i].slot].lastused or 0) > 1000) then
						availableKits[#availableKits+1] = SkillMgr.cskills[i].slot
					end
				end
			end
		end
		local key = math.random(#availableKits)
		--d("KEYSIZE "..tostring(#availableKits).. " choosen: "..tostring(key))
		--d("Slot: " ..tostring(availableKits[key]))
		if ( key ~= 1 ) then
			Player:CastSpell(availableKits[key])
			if (gSMPrioKit ~= "None" and tostring(SkillMgr.EngineerKits[Player:GetSpellInfo(availableKits[key]).contentID]) ~= tostring(gSMPrioKit))then
				--d(tostring(SkillMgr.EngineerKits[Player:GetSpellInfo(availableKits[key]).contentID]).." is not our priokit: "..tostring(gSMPrioKit).." extending time")
				SkillMgr.SwapWeaponTable[availableKits[key]] = { lastused = SkillMgr.DoActionTmr + 5000 }
			else
				SkillMgr.SwapWeaponTable[availableKits[key]] = { lastused = SkillMgr.DoActionTmr }
			end
		else
			if ( Player:CanSwapWeaponSet() ) then
				if (gSMPrioKit == "None" or swaptype == "Pulse") then
					Player:SwapWeaponSet()
					SkillMgr.SwapTmr = SkillMgr.DoActionTmr
				end
			end
		end
	else
		-- All other professions
		if ( Player:CanSwapWeaponSet() ) then
			Player:SwapWeaponSet()
			SkillMgr.SwapTmr = SkillMgr.DoActionTmr
		end
	end
end

function SkillMgr.GetNextBestSkillID(startingprio)
	local prio, skillID
	local skID,_ = next (SkillMgr.SkillSet)
	while skID do
		if ( (tonumber(_G["SKM_Prio_"..tostring(skID)]) and tonumber(_G["SKM_Prio_"..tostring(skID)]) > startingprio ) and (not prio or tonumber(_G["SKM_Prio_"..tostring(skID)]) < prio )) then
			prio = tonumber(_G["SKM_Prio_"..tostring(skID)])
			skillID = skID
		end
		skID,_ = next (SkillMgr.SkillSet,skID)
	end
	return skillID
end

-- C&E for usage with normal bot
SkillMgr.c_SMattack_default = inheritsFrom(wt_cause)
SkillMgr.e_SMattack_default = inheritsFrom(wt_effect)
function SkillMgr.c_SMattack_default:evaluate()
	if ( wt_core_controller.shouldRun and gSMactive == "1" ) then
		return wt_core_state_combat.CurrentTarget ~= 0
	end
	return false
end
function SkillMgr.e_SMattack_default:execute()
	--SkillMgr.SelectTarget() TODO: handle multibottargetselect, Player:SetFacing(TPos.x, TPos.y, TPos.z) `??
	SkillMgr.DoActionTmr = wt_global_information.Now
	SkillMgr.DoAction()
end


function SkillMgr.ToggleMenu()
	if (SkillMgr.visible) then
		GUI_WindowVisible(SkillMgr.mainwindow.name,false)
		SkillMgr.visible = false
	else
		local wnd = GUI_GetWindowInfo("GW2Minion")
		--GUI_MoveWindow( SkillMgr.mainwindow.name, wnd.x+wnd.width,wnd.y)
		GUI_WindowVisible(SkillMgr.mainwindow.name,true)
		SkillMgr.visible = true
	end
end

RegisterEventHandler("Gameloop.Update",SkillMgr.OnUpdate)
RegisterEventHandler("SkillManager.toggle", SkillMgr.ToggleMenu)
RegisterEventHandler("GUI.Update",SkillMgr.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",SkillMgr.ModuleInit)
