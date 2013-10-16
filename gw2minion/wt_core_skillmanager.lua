-- Skillmanager for adv. skill customization
SkillMgr = { }
SkillMgr.version = "v0.4";
SkillMgr.profilepath = GetStartupPath() .. [[\LuaMods\gw2minion\SkillManagerProfiles\]];
SkillMgr.mainwindow = { name = strings[gCurrentLanguage].skillManager, x = 450, y = 50, w = 350, h = 350}
SkillMgr.editwindow = { name = strings[gCurrentLanguage].skillEditor, w = 250, h = 550}
SkillMgr.editorskill = {}
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
SkillMgr.StoopidEventAlreadyRegisteredList = {}

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
	["Air"] = 14,
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
		Settings.GW2MINION.gSMSwapR = "0"
	end
	if (Settings.GW2MINION.gSMSwapCD == nil) then
		Settings.GW2MINION.gSMSwapCD = "1"
	end
	if (Settings.GW2MINION.gSMSwapRange == nil) then
		Settings.GW2MINION.gSMSwapRange = "1"
	end
	if (Settings.GW2MINION.gSMPrioKit == nil) then
		Settings.GW2MINION.gSMPrioKit = "None"
	end
	if (Settings.GW2MINION.gSMPrioAtt == nil) then
		Settings.GW2MINION.gSMPrioAtt = "Fire"
	end	
	if (Settings.GW2MINION.gSMPrioAtt2 == nil) then
		Settings.GW2MINION.gSMPrioAtt2 = "Water"
	end	
	if (Settings.GW2MINION.gSMPrioAtt3 == nil) then
		Settings.GW2MINION.gSMPrioAtt3 = "Air"
	end	
	if (Settings.GW2MINION.gSMPrioAtt4 == nil) then
		Settings.GW2MINION.gSMPrioAtt4 = "Earth"
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
		
	GUI_NewWindow(SkillMgr.mainwindow.name,SkillMgr.mainwindow.x,SkillMgr.mainwindow.y,SkillMgr.mainwindow.w,SkillMgr.mainwindow.h)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].activated,"gSMactive",strings[gCurrentLanguage].generalSettings)
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].profile,"gSMprofile",strings[gCurrentLanguage].generalSettings,"")
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].sMtargetmode,"gsMtargetmode",strings[gCurrentLanguage].generalSettings,"No Autotarget,Autotarget Weakest,Autotarget Closest,Autotarget Biggest Crowd,Least Conditions,Most Conditions,Least Boons,Most Boons");	
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].sMmode,"gSMmode",strings[gCurrentLanguage].generalSettings,"Attack Everything,Attack Players Only")
	
	GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].Fightstyle,"gFightstyle",strings[gCurrentLanguage].AdvancedSettings,"Melee,Range")
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapA,"gSMSwapA",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapR,"gSMSwapR",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapCD,"gSMSwapCD",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].SwapRange,"gSMSwapRange",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].AutoStomp,"gSMAutoStomp",strings[gCurrentLanguage].AdvancedSettings)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].AutoRezz,"gSMAutoRezz",strings[gCurrentLanguage].AdvancedSettings)
	
	if ( wt_global_information.Currentprofession ~= nil ) then
		if (wt_global_information.Currentprofession.professionID == 3) then
		-- Engineer
		GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeKit,"gSMPrioKit",strings[gCurrentLanguage].AdvancedSettings,"None,BombKit,FlameThrower,GrenadeKit,ToolKit,ElixirGun")
		
		elseif( wt_global_information.Currentprofession.professionID == 6 ) then
			-- Elementalist
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeAttunement1,"gSMPrioAtt",strings[gCurrentLanguage].AdvancedSettings,"None,Fire,Water,Air,Earth")
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeAttunement2,"gSMPrioAtt2",strings[gCurrentLanguage].AdvancedSettings,"None,Fire,Water,Air,Earth")
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeAttunement3,"gSMPrioAtt3",strings[gCurrentLanguage].AdvancedSettings,"None,Fire,Water,Air,Earth")
			GUI_NewComboBox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].PriorizeAttunement4,"gSMPrioAtt4",strings[gCurrentLanguage].AdvancedSettings,"None,Fire,Water,Air,Earth")
		end
		
		local SM_Attack_default = wt_kelement:create("Attack(SM)",SkillMgr.c_SMattack_default,SkillMgr.e_SMattack_default, 46 )
		wt_core_state_combat:add(SM_Attack_default)
				
	end
		
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].saveProfile,"SMSaveEvent")
	--GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].refreshProfiles,"SMRefreshEvent",strings[gCurrentLanguage].skillEditor)		
	GUI_NewField(SkillMgr.mainwindow.name,strings[gCurrentLanguage].newProfileName,"gSMnewname",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].newProfile,"newSMProfileEvent",strings[gCurrentLanguage].skillEditor)
	GUI_NewButton(SkillMgr.mainwindow.name,strings[gCurrentLanguage].deleteProfile,"SMDeleteEvent",strings[gCurrentLanguage].skillEditor)
	RegisterEventHandler("SMDeleteEvent",SkillMgr.EditorButtonHandler)
	GUI_NewCheckbox(SkillMgr.mainwindow.name,strings[gCurrentLanguage].autoetectSkills,"gSMRecactive",strings[gCurrentLanguage].skillEditor)
	RegisterEventHandler("SMSaveEvent",SkillMgr.SaveProfile)
	RegisterEventHandler("SMRefreshEvent",SkillMgr.UpdateProfiles)	
	RegisterEventHandler("newSMProfileEvent",SkillMgr.CreateNewProfile)
		
	gSMmode = Settings.GW2MINION.gSMmode
	gsMtargetmode = Settings.GW2MINION.gsMtargetmode
	gSMSwapA = Settings.GW2MINION.gSMSwapA
	gSMSwapR = Settings.GW2MINION.gSMSwapR
	gSMSwapCD = Settings.GW2MINION.gSMSwapCD
	gSMSwapRange = Settings.GW2MINION.gSMSwapRange
	gSMPrioKit = Settings.GW2MINION.gSMPrioKit
	gSMPrioAtt = Settings.GW2MINION.gSMPrioAtt
	gSMPrioAtt2 = Settings.GW2MINION.gSMPrioAtt2
	gSMPrioAtt3 = Settings.GW2MINION.gSMPrioAtt3
	gSMPrioAtt4 = Settings.GW2MINION.gSMPrioAtt4
    gSMactive = Settings.GW2MINION.gSMactive
	gSMAutoStomp = Settings.GW2MINION.gSMAutoStomp
	gSMAutoRezz = Settings.GW2MINION.gSMAutoRezz
	gFightstyle = Settings.GW2MINION.gFightstyle
	
	gSMnewname = ""

  	
	GUI_UnFoldGroup(SkillMgr.mainwindow.name,strings[gCurrentLanguage].generalSettings)
	GUI_WindowVisible(SkillMgr.mainwindow.name,false)
	
	
	-- EDITOR WINDOW
	GUI_NewWindow(SkillMgr.editwindow.name,SkillMgr.mainwindow.x+SkillMgr.mainwindow.w,SkillMgr.mainwindow.y,SkillMgr.editwindow.w,SkillMgr.editwindow.h)		
	GUI_NewField(SkillMgr.editwindow.name,strings[gCurrentLanguage].maMarkerName,"SKM_NAME","SkillDetails")
	--GUI_NewField(SkillMgr.editwindow.name,"PRIO","SKM_Prio","SkillDetails")
	GUI_NewCheckbox(SkillMgr.editwindow.name,strings[gCurrentLanguage].enabled,"SKM_ON","SkillDetails")
	GUI_NewCheckbox(SkillMgr.editwindow.name,strings[gCurrentLanguage].los,"SKM_LOS","SkillDetails")
	GUI_NewCheckbox(SkillMgr.editwindow.name,strings[gCurrentLanguage].channeled,"SKM_CHAN","SkillDetails")
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].minRange,"SKM_MinR","SkillDetails")
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].maxRange,"SKM_MaxR","SkillDetails")
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetType,"SKM_TType","SkillDetails","Enemy,Self");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].useOutOfCombat,"SKM_OutOfCombat","SkillDetails","No,Yes,Either");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerHPGT,"SKM_PHPL","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerHPLT,"SKM_PHPB","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerPowerGT ,"SKM_PPowL","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerPowerLT,"SKM_PPowB","SkillDetails");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerHas,"SKM_PEff1","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].orPlayerHas,"SKM_PEff2","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].orPlayerCond,"SKM_PCondC","SkillDetails");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].playerHasNot,"SKM_PNEff1","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].orPlayerHasNot ,"SKM_PNEff2","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetMoving,"SKM_TMove","SkillDetails","Either,Yes,No");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetHPGT,"SKM_THPL","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetHPLT,"SKM_THPB","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].enemiesNearCount,"SKM_TECount","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].enemiesNearRange,"SKM_TERange","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].alliesNearCount,"SKM_TACount","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,strings[gCurrentLanguage].alliesNearRange,"SKM_TARange","SkillDetails");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetHas,"SKM_TEff1","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].orTargetHas,"SKM_TEff2","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].targetHasNot,"SKM_TNEff1","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewComboBox(SkillMgr.editwindow.name,strings[gCurrentLanguage].orTargetHasNot,"SKM_TNEff2","SkillDetails","None,Bleeding,Blind,Burning,Chilled,Confusion,Crippled,Fear,Immobilized,Vulnerability,Weakness,Poison,Aegis,Fury,Might,Protection,Regeneration,Retaliation,Stability,Swiftness,Vigor,Stealth,Stun");
	GUI_NewNumeric(SkillMgr.editwindow.name,"Target has #Conditions >","SKM_TCondC","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,"Player has #Boons >","SKM_PBoonC","SkillDetails");
	GUI_NewNumeric(SkillMgr.editwindow.name,"Target has #Boons >","SKM_TBoonC","SkillDetails");
	
	GUI_UnFoldGroup(SkillMgr.editwindow.name,"SkillDetails")
	
	SKM_NAME = ""
	SKM_ON = "0"
	SKM_Prio = 0
	SKM_LOS = "1"
	SKM_CHAN = "0"
	SKM_MinR = 0
	SKM_MaxR = 0
	SKM_TType = "Enemy"
	SKM_OutOfCombat = "Either"
	SKM_PHPL = 0
	SKM_PHPB = 0
	SKM_PPowL = 0
	SKM_PPowB = 0
	SKM_PEff1 = "None"
	SKM_PEff2 = "None"
	SKM_PCondC = 0
	SKM_PNEff1 = "None"
	SKM_PNEff2 = "None"
	SKM_TMove = "Either"
	SKM_THPL = 0
	SKM_THPB = 0
	SKM_TECount = 0
	SKM_TERange = 0
	SKM_TACount = 0
	SKM_TARange = 0
	SKM_TEff1 = "None"
	SKM_TEff2 = "None"
	SKM_TNEff1 = "None"
	SKM_TNEff2 = "None"
	SKM_TCondC = 0
	SKM_PBoonC = 0
	SKM_TBoonC = 0
	
	GUI_NewButton(SkillMgr.editwindow.name,"DELETE","SMEDeleteEvent")
	RegisterEventHandler("SMEDeleteEvent",SkillMgr.EditorButtonHandler)	
	GUI_NewButton(SkillMgr.editwindow.name,"CLONE","SMECloneEvent")
	RegisterEventHandler("SMECloneEvent",SkillMgr.EditorButtonHandler)	
	GUI_NewButton(SkillMgr.editwindow.name,"DOWN","SMESkillDOWNEvent")	
	RegisterEventHandler("SMESkillDOWNEvent",SkillMgr.EditorButtonHandler)	
	GUI_NewButton(SkillMgr.editwindow.name,"UP","SMESkillUPEvent")
	RegisterEventHandler("SMESkillUPEvent",SkillMgr.EditorButtonHandler)
		
	SkillMgr.SkillSet = {}
	SkillMgr.UpdateProfiles()	
	GUI_Delete(SkillMgr.mainwindow.name,"SkillList")
	SkillMgr.UpdateCurrentProfileData()	
	GUI_WindowVisible(SkillMgr.editwindow.name,false)
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
			 k == "gSMPrioAtt" or
			 k == "gSMPrioAtt2" or
			 k == "gSMPrioAtt3" or
			 k == "gSMPrioAtt4" or
			 k == "gSMAutoStomp" or
			 k == "gSMAutoRezz" or
			 k == "gFightstyle" or			 
			 k == "gSMPrioKit") then			
			Settings.GW2MINION[tostring(k)] = v
		elseif ( k == "gSMprofile" ) then			
			gSMactive = "0"
			gSMRecactive = "0"				
			GUI_WindowVisible(SkillMgr.editwindow.name,false)
			GUI_Delete(SkillMgr.mainwindow.name,"SkillList")
			SkillMgr.SkillSet = {}
			SkillMgr.UpdateCurrentProfileData()
			Settings.GW2MINION.gSMlastprofile = tostring(v)
		elseif ( k == "SKM_NAME" ) then SkillMgr.SkillSet[SKM_Prio].name = v
		elseif ( k == "SKM_ON" ) then SkillMgr.SkillSet[SKM_Prio].used = v
		elseif ( k == "SKM_LOS" ) then SkillMgr.SkillSet[SKM_Prio].los = v
		elseif ( k == "SKM_INSTA" ) then SkillMgr.SkillSet[SKM_Prio].insta = v
		elseif ( k == "SKM_CHAN" ) then SkillMgr.SkillSet[SKM_Prio].channel = v	
		elseif ( k == "SKM_MinR" ) then SkillMgr.SkillSet[SKM_Prio].minRange = tonumber(v)
		elseif ( k == "SKM_MaxR" ) then SkillMgr.SkillSet[SKM_Prio].maxRange = tonumber(v)
		elseif ( k == "SKM_TType" ) then SkillMgr.SkillSet[SKM_Prio].ttype = v
		elseif ( k == "SKM_OutOfCombat" ) then SkillMgr.SkillSet[SKM_Prio].ooc = v
		elseif ( k == "SKM_PHPL" ) then SkillMgr.SkillSet[SKM_Prio].phpl = tonumber(v)
		elseif ( k == "SKM_PHPB" ) then SkillMgr.SkillSet[SKM_Prio].phpb = tonumber(v)
		elseif ( k == "SKM_PPowL" ) then SkillMgr.SkillSet[SKM_Prio].ppowl = tonumber(v)
		elseif ( k == "SKM_PPowB" ) then SkillMgr.SkillSet[SKM_Prio].ppowb = tonumber(v)
		elseif ( k == "SKM_PEff1" ) then SkillMgr.SkillSet[SKM_Prio].peff1 = v
		elseif ( k == "SKM_PEff2" ) then SkillMgr.SkillSet[SKM_Prio].peff2 = v
		elseif ( k == "SKM_PCondC" ) then SkillMgr.SkillSet[SKM_Prio].pcondc = tonumber(v)
		elseif ( k == "SKM_PNEff1" ) then SkillMgr.SkillSet[SKM_Prio].pneff1 = v
		elseif ( k == "SKM_PNEff2" ) then SkillMgr.SkillSet[SKM_Prio].pneff2 = v
		elseif ( k == "SKM_TMove" ) then SkillMgr.SkillSet[SKM_Prio].tmove = v
		elseif ( k == "SKM_THPL" ) then SkillMgr.SkillSet[SKM_Prio].thpl = tonumber(v)
		elseif ( k == "SKM_THPB" ) then SkillMgr.SkillSet[SKM_Prio].thpb = tonumber(v)
		elseif ( k == "SKM_TECount" ) then SkillMgr.SkillSet[SKM_Prio].tecount = tonumber(v)
		elseif ( k == "SKM_TERange" ) then SkillMgr.SkillSet[SKM_Prio].terange = tonumber(v)
		elseif ( k == "SKM_TACount" ) then SkillMgr.SkillSet[SKM_Prio].tacount = tonumber(v)
		elseif ( k == "SKM_TARange" ) then SkillMgr.SkillSet[SKM_Prio].terange = tonumber(v)
		elseif ( k == "SKM_TEff1" ) then SkillMgr.SkillSet[SKM_Prio].teff1 = v
		elseif ( k == "SKM_TEff2" ) then SkillMgr.SkillSet[SKM_Prio].teff2 = v
		elseif ( k == "SKM_TNEff1" ) then SkillMgr.SkillSet[SKM_Prio].tneff1 = v
		elseif ( k == "SKM_TNEff2" ) then SkillMgr.SkillSet[SKM_Prio].tneff2 = v				
		elseif ( k == "SKM_TCondC" ) then SkillMgr.SkillSet[SKM_Prio].tcondc = tonumber(v)
		elseif ( k == "SKM_PBoonC" ) then SkillMgr.SkillSet[SKM_Prio].pboonc = tonumber(v)
		elseif ( k == "SKM_TBoonC" ) then SkillMgr.SkillSet[SKM_Prio].tboonc = tonumber(v)					
		end
	end
end

--+
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
		if	( tick - SkillMgr.DoActionTmr > 150 ) then
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
			SkillMgr.UIRefreshTmr = 0			
			SkillMgr.RefreshSkillList()	
			SkillMgr.UIneedsRefresh = false
		end
	end
end

--+
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
			GUI_Delete(SkillMgr.mainwindow.name,"SkillList")
			gSMprofile_listitems = gSMprofile_listitems..","..gSMnewname
			gSMprofile = gSMnewname	
			-- Create new profile-file TODO: REPLACE WITH HANS's SAVING FUNCTION
			local file = io.open(SkillMgr.profilepath..gSMnewname..".lua", "w")
			if file then
				wt_debug("Creating Profile file..")	
								
				file:flush()
				file:close()
			else
				wt_error("Error creating new Profile file..")					
			end
		end		
	end
end

--+
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
				wt_debug("Last Profile found : "..profile)
				found = profile
			end
			i,profile = next ( profilelist,i)
		end
		
	else
		wt_error("No Skillmanager profiles found")
	end
	gSMprofile_listitems = profiles
	gSMprofile = found
end

--+
function SkillMgr.SaveProfile()
	-- Save current Profiledata into the Profile-file 
	if (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
	
		wt_debug("Saving Profile Data into File: "..gSMprofile)
		local string2write = "SKM_SMVersion_2=2\n"
		local skID,skill = next (SkillMgr.SkillSet)
		while skID and skill do
			string2write = string2write.."SKM_NAME="..skill.name.."\n"
			string2write = string2write.."SKM_ID="..skill.contentID.."\n"
			string2write = string2write.."SKM_ON="..skill.used.."\n"			
			string2write = string2write.."SKM_Prio="..skill.prio.."\n"
			string2write = string2write.."SKM_LOS="..skill.los.."\n"
			string2write = string2write.."SKM_CHAN="..skill.channel.."\n"			
			string2write = string2write.."SKM_MinR="..skill.minRange.."\n"
			string2write = string2write.."SKM_MaxR="..skill.maxRange.."\n" 
			string2write = string2write.."SKM_TType="..skill.ttype.."\n"
			string2write = string2write.."SKM_OutOfCombat="..skill.ooc.."\n"
			string2write = string2write.."SKM_PHPL="..skill.phpl.."\n" 
			string2write = string2write.."SKM_PHPB="..skill.phpb.."\n" 
			string2write = string2write.."SKM_PPowL="..skill.ppowl.."\n" 
			string2write = string2write.."SKM_PPowB="..skill.ppowb.."\n" 
			string2write = string2write.."SKM_PEff1="..skill.peff1.."\n" 
			string2write = string2write.."SKM_PEff2="..skill.peff2.."\n" 
			string2write = string2write.."SKM_PCondC="..skill.pcondc.."\n" 
			string2write = string2write.."SKM_PNEff1="..skill.pneff1.."\n" 
			string2write = string2write.."SKM_PNEff2="..skill.pneff2.."\n" 								
			string2write = string2write.."SKM_TMove="..skill.tmove.."\n" 
			string2write = string2write.."SKM_THPL="..skill.thpl.."\n" 
			string2write = string2write.."SKM_THPB="..skill.thpb.."\n" 
			string2write = string2write.."SKM_TECount="..skill.tecount.."\n" 
			string2write = string2write.."SKM_TERange="..skill.terange.."\n" 
			string2write = string2write.."SKM_TACount="..skill.tacount.."\n" 
			string2write = string2write.."SKM_TARange="..skill.terange.."\n" 	
			string2write = string2write.."SKM_TEff1="..skill.teff1.."\n" 
			string2write = string2write.."SKM_TEff2="..skill.teff2.."\n" 
			string2write = string2write.."SKM_TNEff1="..skill.tneff1.."\n" 
			string2write = string2write.."SKM_TNEff2="..skill.tneff2.."\n" 
			string2write = string2write.."SKM_TCondC="..skill.tcondc.."\n" 
			string2write = string2write.."SKM_PBoonC="..skill.pboonc.."\n" 
			string2write = string2write.."SKM_TBoonC="..skill.tboonc.."\n"					
			string2write = string2write.."SKM_END=0\n"
		
			skID,skill = next (SkillMgr.SkillSet,skID)
		end	
		wt_debug(filewrite(SkillMgr.profilepath ..gSMprofile..".lua",string2write))
	end	
end

--+
function SkillMgr.UpdateCurrentProfileData()
	if ( gSMprofile ~= nil and gSMprofile ~= "" and gSMprofile ~= "None" ) then
		local profile = fileread(SkillMgr.profilepath..gSMprofile..".lua")
		if ( TableSize(profile) > 0) then
			local unsortedSkillList = {}			
			local newskill = {}	
			local i, line = next (profile)
			
			if ( line ) then
				local version
				-- Check for backwards compatib.shit
				local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
				if ( tostring(key) == "SMVersion" and tostring(id) == "2") then
					version = 2
					parser = "(%w+)_(%w+)_(%d+)=(.*)"
				else
					version = 1					
					parser = "(%w+)_(%w+)=(.*)"
				end
				while i and line do
					local key, value
					if ( version == 1 ) then 
						_, key, _, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
					elseif ( version == 2) then
						_, key, value = string.match(line, "(%w+)_(%w+)=(.*)")
					end
					--d("key: "..tostring(key).." value:"..tostring(value))
					if ( key and value ) then
						value = string.gsub(value, "\r", "")					
						if ( key == "END" ) then
							--d("Adding Skill :"..newskill.name.."Prio:"..tostring(newskill.prio))
							table.insert(unsortedSkillList,tonumber(newskill.prio),newskill)						
							newskill = {}
							elseif ( key == "ID" )then newskill.contentID = tonumber(value)
							elseif ( key == "NAME" )then newskill.name = value
							elseif ( key == "ON" )then newskill.used = tostring(value)
							elseif ( key == "Prio" )then newskill.prio = tonumber(value)
							elseif ( key == "LOS" )then 
								if ( tostring(value) == "Yes" ) then newskill.los = "1" 
								elseif ( tostring(value) == "No" ) then newskill.los = "0" 
								else	newskill.los = tostring(value)
								end
							elseif ( key == "CHAN" )then newskill.channel = tostring(value)	
							elseif ( key == "MinR" )then newskill.minRange = tonumber(value)
							elseif ( key == "MaxR" )then newskill.maxRange = tonumber(value)
							elseif ( key == "TType" )then newskill.ttype = tostring(value)
							elseif ( key == "OutOfCombat" )then newskill.ooc = tostring(value)
							elseif ( key == "PHPL" )then newskill.phpl = tonumber(value)
							elseif ( key == "PHPB" )then newskill.phpb = tonumber(value)
							elseif ( key == "PPowL" )then newskill.ppowl = tonumber(value)
							elseif ( key == "PPowB" )then newskill.ppowb = tonumber(value)
							elseif ( key == "PEff1" )then newskill.peff1 = tostring(value)
							elseif ( key == "PEff2" )then newskill.peff2 = tostring(value)
							elseif ( key == "PNEff1" )then newskill.pneff1 = tostring(value)
							elseif ( key == "PNEff2" )then newskill.pneff2 = tostring(value)
							elseif ( key == "PCondC" )then newskill.pcondc = tonumber(value)												
							elseif ( key == "TMove" )then newskill.tmove = tostring(value)
							elseif ( key == "THPL" )then newskill.thpl = tonumber(value)
							elseif ( key == "THPB" )then newskill.thpb = tonumber(value)						
							elseif ( key == "TECount" )then newskill.tecount = tonumber(value)
							elseif ( key == "TERange" )then newskill.terange = tonumber(value)
							elseif ( key == "TACount" )then newskill.tacount = tonumber(value)
							elseif ( key == "TARange" )then newskill.tarange = tonumber(value)
							elseif ( key == "TEff1" )then newskill.teff1 = tostring(value)
							elseif ( key == "TEff2" )then newskill.teff2 = tostring(value)
							elseif ( key == "TNEff1" )then newskill.tneff1 = tostring(value)
							elseif ( key == "TNEff2" )then newskill.tneff2 = tostring(value)						
							elseif ( key == "TCondC" )then newskill.tcondc = tonumber(value)
							elseif ( key == "PBoonC" )then newskill.pboonc = tonumber(value)
							elseif ( key == "TBoonC" )then newskill.tboonc = tonumber(value)	
						end
					else
						wt_error("Error loading inputline: Key: "..(tostring(key)).." value:"..tostring(value))
					end				
					i, line = next (profile,i)
				end
			end
			-- Create UI Fields
			local sortedSkillList = {}
			if ( TableSize(unsortedSkillList) > 0 ) then
				local i,skill = next (unsortedSkillList)
				while i and skill do
					sortedSkillList[#sortedSkillList+1] = skill
					i,skill = next (unsortedSkillList,i)
				end
				table.sort(sortedSkillList, function(a,b) return a.prio < b.prio end )	
				for i = 1,TableSize(sortedSkillList),1 do					
					if (sortedSkillList[i] ~= nil ) then
						sortedSkillList[i].prio = i
						SkillMgr.CreateNewSkillEntry(sortedSkillList[i])
					end
				end
			end
		else
			wt_error("Profile is empty..")
		end		
	else
		wt_debug("No new SkillProfile selected!")		
	end
end

--+
function SkillMgr.EditorButtonHandler(event)
	gSMRecactive = "0"
	if ( event == "SMDeleteEvent" ) then
		-- Delete the currently selected Profile - file from the HDD
		if (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
			wt_debug("Deleting current Profile: "..gSMprofile)
			os.remove(SkillMgr.profilepath ..gSMprofile..".lua")	
			SkillMgr.UpdateProfiles()	
		end		
	elseif ( event == "SMECloneEvent") then
		local clone = deepcopy(SkillMgr.SkillSet[SKM_Prio])
		clone.prio = table.maxn(SkillMgr.SkillSet)+1
		SkillMgr.CreateNewSkillEntry(clone)
	elseif ( event == "SMEDeleteEvent") then				
		if ( TableSize(SkillMgr.SkillSet) > 0 ) then
			GUI_Delete(SkillMgr.mainwindow.name,"SkillList")
			local i,s = next ( SkillMgr.SkillSet, SKM_Prio)
			while i and s do
				s.prio = s.prio - 1
				SkillMgr.SkillSet[SKM_Prio] = s
				SKM_Prio = i
				i,s = next ( SkillMgr.SkillSet, i)
			end
			SkillMgr.SkillSet[SKM_Prio] = nil
			SkillMgr.RefreshSkillList()	
			GUI_WindowVisible(SkillMgr.editwindow.name,false)
		end
	elseif (event == "SMESkillUPEvent") then		
		if ( TableSize(SkillMgr.SkillSet) > 0 ) then
			if ( SKM_Prio > 1) then
				GUI_Delete(SkillMgr.mainwindow.name,"SkillList")
				local tmp = SkillMgr.SkillSet[SKM_Prio-1]
				SkillMgr.SkillSet[SKM_Prio-1] = SkillMgr.SkillSet[SKM_Prio]
				SkillMgr.SkillSet[SKM_Prio-1].prio = SkillMgr.SkillSet[SKM_Prio-1].prio - 1
				SkillMgr.SkillSet[SKM_Prio] = tmp
				SkillMgr.SkillSet[SKM_Prio].prio = SkillMgr.SkillSet[SKM_Prio].prio + 1
				SKM_Prio = SKM_Prio-1
				SkillMgr.RefreshSkillList()				
			end
		end
	elseif ( event == "SMESkillDOWNEvent") then			
		if ( TableSize(SkillMgr.SkillSet) > 0 ) then
			if ( SKM_Prio < TableSize(SkillMgr.SkillSet)) then
				GUI_Delete(SkillMgr.mainwindow.name,"SkillList")		
				local tmp = SkillMgr.SkillSet[SKM_Prio+1]
				SkillMgr.SkillSet[SKM_Prio+1] = SkillMgr.SkillSet[SKM_Prio]
				SkillMgr.SkillSet[SKM_Prio+1].prio = SkillMgr.SkillSet[SKM_Prio+1].prio + 1
				SkillMgr.SkillSet[SKM_Prio] = tmp
				SkillMgr.SkillSet[SKM_Prio].prio = SkillMgr.SkillSet[SKM_Prio].prio - 1
				SKM_Prio = SKM_Prio+1
				SkillMgr.RefreshSkillList()						
			end
		end
	end
end

--+
function SkillMgr.RefreshSkillList()	
	if ( TableSize( SkillMgr.SkillSet ) > 0 ) then
		local i,s = next ( SkillMgr.SkillSet )
		while i and s do
			SkillMgr.CreateNewSkillEntry(s)
			i,s = next ( SkillMgr.SkillSet , i )
		end
	end
	GUI_UnFoldGroup(SkillMgr.mainwindow.name,"SkillList")
end

--+
function SkillMgr.CheckForNewSkills()
	for i = 1, 16, 1 do
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then
			local skID = skill.contentID
			if ( skID ) then
				local found = false
				if ( TableSize(  SkillMgr.SkillSet ) > 0 ) then
					local i,s = next ( SkillMgr.SkillSet )
					while i and s do
						if s.contentID == skID then
							found = true
							break
						end
						i,s = next ( SkillMgr.SkillSet , i )
					end
				end
				if not found then
					SkillMgr.CreateNewSkillEntry(skill)
				end
			end			
		end
	end
	GUI_UnFoldGroup(SkillMgr.mainwindow.name,"SkillList")
end

--+
function SkillMgr.CreateNewSkillEntry(skill)	
	if (skill ~= nil ) then
		local skname = skill.name
		local skID = skill.contentID		
		if (skname ~= "" and skID ) then
			local newskillprio = skill.prio or table.maxn(SkillMgr.SkillSet)+1
			local bevent = tostring(newskillprio)
			GUI_NewButton(SkillMgr.mainwindow.name, tostring(bevent)..": "..skname, bevent,"SkillList")
			if ( SkillMgr.StoopidEventAlreadyRegisteredList[newskillprio] == nil ) then
				RegisterEventHandler(bevent,SkillMgr.EditSkill)
				SkillMgr.StoopidEventAlreadyRegisteredList[newskillprio] = 1
			end			
			SkillMgr.SkillSet[newskillprio] = {		
				contentID = skID,
				prio = newskillprio,
				name = skname,
				used = skill.used or "1",		
				los = skill.los or "1",
				channel = skill.channel or "0",
				minRange = skill.minRange or 0,
				maxRange = skill.maxRange or 0,
				ttype = skill.ttype or "Enemy",
				ooc = skill.ooc or "Either",
				phpl = skill.phpl or 0,
				phpb = skill.phpb or 0,
				ppowl = skill.ppowl or 0,
				ppowb = skill.ppowb or 0,
				peff1 = skill.peff1 or "None",
				peff2 = skill.peff2 or "None",
				pcondc = skill.pcondc or 0,
				pneff1 = skill.pneff1 or "None",
				pneff2 = skill.pneff2 or "None",
				tmove = skill.tmove or "Either",
				thpl = skill.thpl or 0,
				thpb = skill.thpb or 0,
				tecount = skill.tecount or 0,
				terange = skill.terange or 0,
				tacount = skill.tacount or 0,
				tarange = skill.tarange or 0,
				teff1 = skill.teff1 or "None",
				teff2 = skill.teff2 or "None",
				tneff1 = skill.tneff1 or "None",
				tneff2 = skill.tneff2 or "None",
				tcondc = skill.condc or 0,
				pboonc = skill.pboonc or 0,
				tboonc = skill.tboonc or 0
			}		
		end		
	end
end
	
--+	
function SkillMgr.EditSkill(event)
	local wnd = GUI_GetWindowInfo(SkillMgr.mainwindow.name)	
	GUI_MoveWindow( SkillMgr.editwindow.name, wnd.x+wnd.width,wnd.y) 
	GUI_WindowVisible(SkillMgr.editwindow.name,true)
	-- Update EditorData
	local skill = SkillMgr.SkillSet[tonumber(event)]	
	if ( skill ) then		
		SKM_NAME = skill.name or ""
		SKM_ON = skill.used or "1"
		SKM_Prio = tonumber(event)
		SKM_LOS = skill.los or "1"
		SKM_CHAN = skill.channel or "0"
		SKM_MinR = tonumber(skill.minRange) or 0
		SKM_MaxR = tonumber(skill.maxRange) or 160
		SKM_TType = skill.ttype or "Either"
		SKM_OutOfCombat = skill.ooc or "Either"
		SKM_PHPL = tonumber(skill.phpl) or 0
		SKM_PHPB = tonumber(skill.phpb) or 0
		SKM_PPowL = tonumber(skill.ppowl) or 0
		SKM_PPowB = tonumber(skill.ppowb) or 0
		SKM_PEff1 = skill.peff1 or "None"
		SKM_PEff2 = skill.peff2 or "None"
		SKM_PCondC = tonumber(skill.pcondc) or 0
		SKM_PNEff1 = skill.pneff1 or "None"
		SKM_PNEff2 = skill.pneff2 or "None"
		SKM_TMove = skill.tmove or "Either"
		SKM_THPL = tonumber(skill.thpl) or 0
		SKM_THPB = tonumber(skill.thpb) or 0
		SKM_TECount = tonumber(skill.tecount) or 0
		SKM_TERange = tonumber(skill.terange) or 0
		SKM_TACount = tonumber(skill.tacount) or 0
		SKM_TARange = tonumber(skill.terange) or 0
		SKM_TEff1 = skill.teff1 or "None"
		SKM_TEff2 = skill.teff2 or "None"
		SKM_TNEff1 = skill.tneff1 or "None"
		SKM_TNEff2 = skill.tneff2 or "None"
		SKM_TCondC = tonumber(skill.tcondc) or 0
		SKM_PBoonC = tonumber(skill.pboonc) or 0
		SKM_TBoonC = tonumber(skill.tboonc) or 0
	end
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
					compare_to = compare_with
                end
            elseif (gsMtargetmode == "Most Conditions" or gsMtargetmode == "Most Boons") then
                if (compare_to <= compare_with) then
                    chosen_tid = tid
                    chosen_target = target
					compare_to = compare_with
                end
            end            
            tid,target = next(TargetList, tid)
        end
		
        target_list[chosen_tid] = chosen_target
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
	
	if ( gsMtargetmode ~= "No Autotarget" ) then
		
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

function SkillMgr.DoAction()

	SkillMgr.cskills = {}
	local fastcastcount = 0
	local maxrange = nil
	for i = 1, 15, 1 do
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then			
			SkillMgr.cskills[i] = skill
			SkillMgr.cskills[i].slot = GW2.SKILLBARSLOT["Slot_" .. i]
			--Find this skill in our SkillMgr.SkillSet
			for k,v in pairs(SkillMgr.SkillSet) do
				if v.contentID == SkillMgr.cskills[i].contentID then
					SkillMgr.cskills[i].prio = v.prio
					break
				end
			end
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
		if (Player.inCombat and wt_core_controller.shouldRun)then
			SkillMgr.SwapWeaponCheck("Pulse")		
		end
	end

	local mybuffs = Player.buffs
	local targetbuffs
	if ( target ) then
		targetbuffs = target.buffs
	end
		
	SkillMgr.SpellIsCast = SkillMgr.IsOtherSpellCurrentlyCast()
	--d(tostring(Player:GetCurrentlyCastedSpell()).." IC: "..tostring(Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3)).." IS1cast: "..tostring(Player:IsSpellCurrentlyCast(GW2.SKILLBARSLOT.Slot_3)).." X:"..tostring(Player:IsCasting()))
					
	if ( TableSize(SkillMgr.SkillSet) > 0 ) then
		for prio,skill in pairs(SkillMgr.SkillSet) do
			if ( skill.used == "1" ) then
				if ( skill.slot ) then
					if ( SkillMgr.cskills[skill.slot] and SkillMgr.cskills[skill.slot].contentID == skill.contentID) then
						local castable = true
							
						-- COOLDOWN CHECK
						if ( SkillMgr.cskills[skill.slot].slot ~= GW2.SKILLBARSLOT.Slot_1 and Player:IsSpellOnCooldown(SkillMgr.cskills[skill.slot].slot)) then castable = false end
						-- USEOUTOFCOMBAT CHECK
						if ( castable and (
							(skill.ooc == "No" and not Player.inCombat)
							or (skill.ooc == "Yes" and Player.inCombat)
							))then castable = false end
						-- TARGETTYPE + LOS + RANGE + MOVEMENT + HEALTH CHECK						
						if ( castable and skill.ttype == "Enemy" 
							and (not target
								or (skill.los == "Yes" and not target.los)
								or (skill.minRange > 0 and target.distance < skill.minRange)
								or (skill.maxRange > 0 and target.distance > skill.maxRange)
								or (skill.tmove == "No" and target.movementstate == GW2.MOVEMENTSTATE.GroundMoving)
								or (skill.tmove == "Yes" and target.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving)
								or (skill.thpl > 0 and skill.thpl > target.health.percent)
								or (skill.thpb > 0 and skill.thpb < target.health.percent)
								)) then castable = false end	
						-- PLAYER HEALTH,POWER,ENDURANCE CHECK				
						if ( castable and (
							(skill.phpl > 0 and skill.phpl > Player.health.percent)
							or (skill.phpb > 0 and skill.phpb < Player.health.percent)
							or (skill.ppowl > 0 and skill.ppowl > Player:GetProfessionPowerPercentage())
							or (skill.ppowb > 0 and skill.ppowb < Player:GetProfessionPowerPercentage())					
							)) then castable = false end	
						-- PLAYER BUFF CHECKS
						if ( castable and (skill.peff1 ~= "None" or skill.peff2 ~= "None" or skill.pneff1 ~= "None" or skill.pneff2 ~= "None") )then 							
							if ( mybuffs ) then
								local E1 = SkillMgr.BuffEnum[skill.peff1]
								local E2 = SkillMgr.BuffEnum[skill.peff2]
								local NE1 = SkillMgr.BuffEnum[skill.pneff1]
								local NE2 = SkillMgr.BuffEnum[skill.pneff2]								
								local bufffound = false
								local i,buff = next(mybuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID == NE1 or bskID == NE2 or bskID == E1 or bskID == E2 ) then
										bufffound = true
										break
									end
									i,buff = next(mybuffs,i)
								end
								if (not bufffound and (E1 or E2))then castable = false end
								if (bufffound and (NE1 or NE2))then castable = false end											
							end					
						end
						if ( castable and skill.pcondc > 0 ) then
							if ( mybuffs ) then												
								local condcount = 0
								local i,buff = next(mybuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID and SkillMgr.ConditionsEnum[bskID] ~= nil) then
										condcount = condcount + 1
										if (condcount > skill.pcondc) then
											break
										end
									end
									i,buff = next(mybuffs,i)
								end
								if (condcount <= skill.pcondc) then castable = false end
							end						
						end
						--ALLIE AE CHECK
						if ( castable and (skill.tacount > 0 and skill.tarange > 0)) then
							if ( not target 
								or not target.id
								or ( TableSize(CharacterList("friendly,maxdistance="..skill.tarange..",distanceto="..target.id)) < skill.tacount)) then
								castable = false
							end
						end						
						-- TARGET BUFF CHECKS 
						if ( castable and target and (skill.teff1 ~= "None" or skill.teff2 ~= "None" or skill.tneff1 ~= "None" or skill.tneff2 ~= "None") )then 
							if ( targetbuffs ) then
								local E1 = SkillMgr.BuffEnum[skill.teff1]
								local E2 = SkillMgr.BuffEnum[skill.teff2]
								local NE1 = SkillMgr.BuffEnum[skill.tneff1]
								local NE2 = SkillMgr.BuffEnum[skill.tneff2]						
								local bufffound = false
								local i,buff = next(targetbuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID == NE1 or bskID == NE2 or bskID == E1 or bskID == E2) then
										bufffound = true
										break
									end
									i,buff = next(targetbuffs,i)
								end
								if (not bufffound and (E1 or E2))then castable = false end
								if (bufffound and (NE1 or NE2))then castable = false end											
							end					
						end
						-- TARGET AE CHECK
						if ( castable and skill.tecount > 0 and skill.terange > 0) then
							if ( not target 
								or not target.id
								or ( TableSize(CharacterList("alive,attackable,maxdistance="..skill.terange..",distanceto="..target.id)) < skill.tecount)) then
								castable = false
							end
						end
						-- TARGET #CONDITIONS CHECK
						if ( castable and target and skill.tcondc > 0 ) then
							if ( targetbuffs ) then												
								local condcount = 0
								local i,buff = next(targetbuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID and SkillMgr.ConditionsEnum[bskID] ~= nil) then
										condcount = condcount + 1
										if (condcount > skill.tcondc) then
											break
										end
									end
									i,buff = next(targetbuffs,i)
								end
								if (condcount <= skill.tcondc) then castable = false end
							end						
						end										
						-- PLAYER #BOON CHECK
						if ( castable and skill.pboonc > 0 ) then
							if ( mybuffs ) then												
								local booncount = 0
								local i,buff = next(mybuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID and SkillMgr.BoonsEnum[bskID] ~= nil) then
										booncount = booncount + 1
										if (booncount > skill.pboonc) then
											break
										end
									end
									i,buff = next(mybuffs,i)
								end
								if (booncount <= skill.pboonc) then castable = false end
							end						
						end
						-- TARGET #BOON CHECK
						if ( castable and target and skill.tboonc > 0 ) then
							if ( targetbuffs ) then												
								local booncount = 0
								local i,buff = next(targetbuffs)
								while i and buff do							
									local bskID = buff.skillID
									if ( bskID and SkillMgr.BoonsEnum[bskID] ~= nil) then
										booncount = booncount + 1
										if (booncount > skill.tboonc) then
											break
										end
									end
									i,buff = next(targetbuffs,i)
								end
								if (booncount <= skill.tboonc) then castable = false end
							end						
						end		
												
						if ( castable ) then
							
							-- Swap Weapon check
							if ( SkillMgr.cskills[skill.slot].slot == GW2.SKILLBARSLOT.Slot_1 ) then
								SkillMgr.SwapWeaponCheck("CoolDown")
							end

							-- CAST Self check
							if ( skill.ttype == "Self" ) then						
								if (SkillMgr.CanCast()) then
									--[[if ( SkillMgr.SkillStuckSlot ~= SkillMgr.cskills[i].slot ) then
										SkillMgr.SkillStuckSlot == SkillMgr.cskills[i].slot
									else
										if (SkillMgr.SkillStuckTmr == 0 or wt_core_information.Now - SkillMgr.SkillStuckTmr > 4000 ) then
											
										end
									end	]]													
									Player:CastSpellNoChecks(SkillMgr.cskills[skill.slot].slot)							
									--d("Casting on Self: "..tostring(SkillMgr.cskills[i].name))
									return
									--	Player:LeaveCombatState()
								end		
							else
								if ( target and target.id ) then							
									if (SkillMgr.CanCast() ) then--sp ~= SkillMgr.cskills[i].slot ) then							

										if ( SkillMgr.cskills[skill.slot].isGroundTargeted ) then											
											if ( target.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving ) then

												Player:CastSpellNoChecks(SkillMgr.cskills[skill.slot].slot,target.id)
											else							
												-- some simple movement prediction
												-- TODO: add chilled modificator
												local tpos = target.pos
												tpos.x = tpos.x + tpos.hx * target.distance / 4.5
												tpos.y = tpos.y + tpos.hy * target.distance / 4.5

												Player:CastSpellNoChecks(SkillMgr.cskills[skill.slot].slot,tpos.x,tpos.y,tpos.z)
											end									
										else
										
											Player:CastSpellNoChecks(SkillMgr.cskills[skill.slot].slot,target.id)								
											--d("Casting on Enemy: "..tostring(SkillMgr.cskills[i].name))									
										end
										if ( skill.channel == "1" ) then
											-- Add a tiny delay so "iscasting" gets true for this spell, not interrupting it on the next pulse
											SkillMgr.DoActionTmr = SkillMgr.DoActionTmr + 1000
											wt_global_information.lastrun = wt_global_information.lastrun + 1000
											return
										else										
											fastcastcount = fastcastcount + 1 
											if ( fastcastcount > 2) then
												return
											end
										end
									end		
								end
							end					
						end						
					end
				else
				-- Try to save the slot the skill is used from...		
					for i = 16, 1, -1 do
						if ( SkillMgr.cskills[i] and SkillMgr.cskills[i].contentID == skill.contentID) then
							skill.slot = i
							break
						end
					end
				end
			end
		end
		
		-- swap weapons if target but out of range
		--if ( target and target.distance > wt_global_information.AttackRange and target.attitude ~= GW2.ATTITUDE.Friendly) then
		if ( target and target.attitude ~= GW2.ATTITUDE.Friendly) then
			SkillMgr.SwapWeaponCheck("Range")
		end
	else
		wt_error("LOL U HAVE NO SKILLPROFILE LOADED GO READ THE MANUAL ;D !")
	end
end

function SkillMgr.CanCast()
	local currspellslot = Player:GetCurrentlyCastedSpell()	
	if ( (not Player:IsCasting() or currspellslot == GW2.SKILLBARSLOT.Slot_1 or currspellslot == GW2.SKILLBARSLOT.None) and currspellslot ~= GW2.SKILLBARSLOT.Slot_6 and currspellslot ~= GW2.SKILLBARSLOT.Slot_16 and not SkillMgr.SpellIsCast) then 
		return true
	end	
	return false
end

-- This is needed b/c this check is more precise than Player:IsCasting()
function SkillMgr.IsOtherSpellCurrentlyCast()	
	for i = 0, 15, 1 do
		if ( i ~= 5 and Player:IsSpellCurrentlyCast(i)) then		
		--if ( Player:IsSpellCurrentlyCast(i)) then		
			return true
		end
	end
	return false
end

function SkillMgr.SwapWeaponCheck(swaptype)
	if ( gSMSwapA == "1" and (SkillMgr.SwapTmr == 0 or SkillMgr.DoActionTmr - SkillMgr.SwapTmr > 500) ) then -- prevent hammering
				
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
		
	end	
end

function SkillMgr.SwapWeapon(swaptype)	
	if ( wt_global_information.Currentprofession.professionID == 6 ) then 
		--Elementalist		
		local switch
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
		if ( skill ~= nil ) then
			local sID = skill.skillID			
			local currentAttunement
			if ( sID==5491 or sID==15718 or sID==5508 ) then
				currentAttunement = 12
			elseif (sID==5549 or sID==15716 or sID==5693) then
				currentAttunement = 13
			elseif (sID==5489 or sID==5518 or sID==5526 ) then
				currentAttunement = 14
			elseif (sID==15717 or sID==5519 or sID==5500 ) then
				currentAttunement = 15
			end
			if ( currentAttunement ) then
				if ( tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)]) and currentAttunement ~= tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)]) and not Player:IsSpellOnCooldown(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)]))) then
					switch = tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt)])
				elseif ( tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt2)]) and currentAttunement ~= tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt2)]) and not Player:IsSpellOnCooldown(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt2)]))) then
					switch = tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt2)])
				elseif ( tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt3)]) and currentAttunement ~= tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt3)]) and not Player:IsSpellOnCooldown(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt3)]))) then
					switch = tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt3)])
				elseif ( tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt4)]) and currentAttunement ~= tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt4)]) and not Player:IsSpellOnCooldown(tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt4)]))) then
					switch = tonumber(SkillMgr.ElementarAttunements[tostring(gSMPrioAtt4)])
				end				
			else
				wt_error("WHOOOPPSS, You have a unknown weapon! Please report back to us what kind of weapon you are using!")
			end					
			--d("TEST:"..tostring(switch) .. " " ..tostring(sID))
			if ( switch ) then
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
		GUI_WindowVisible(SkillMgr.mainwindow.name,true)	
		SkillMgr.visible = true
	end
end

RegisterEventHandler("Gameloop.Update",SkillMgr.OnUpdate)
RegisterEventHandler("SkillManager.toggle", SkillMgr.ToggleMenu)
RegisterEventHandler("GUI.Update",SkillMgr.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",SkillMgr.ModuleInit)
