mc_skillmanager = {}
-- Skillmanager for adv. skill customization
mc_skillmanager.profilepath = GetStartupPath() .. [[\LuaMods\GW2Minion\SkillManagerProfiles\]];
mc_skillmanager.mainwindow = { name = GetString("skillManager"), x = 350, y = 50, w = 250, h = 350}
mc_skillmanager.editwindow = { name = GetString("skillEditor"), w = 250, h = 550}
mc_skillmanager.visible = false
mc_skillmanager.SkillProfile = {}
mc_skillmanager.SkillRecordingActive = false
mc_skillmanager.RecordSkillTmr = 0
mc_skillmanager.RegisteredButtonEventList = {}
mc_skillmanager.currentskills = {} -- Current List of Skills, gets constantly updated each pulse
mc_skillmanager.prevSkillID = 0
mc_skillmanager.SwapTmr = 0 -- General WeaponSwap Timer
mc_skillmanager.SwapRTmr = 0 -- Random WeaponSwap Timer
mc_skillmanager.SwapWeaponTable = {}

mc_skillmanager.DefaultProfiles = {
	[1] = "Guardian",
	[2] = "Warrior",
	[3] = "Engineer",
	[4] = "Ranger",
	[5] = "Thief",
	[6] = "Elementalist",
	[7] = "Mesmer",
	[8] = "Necromancer",
}

--Enums
mc_skillmanager.EngineerKits = {
	[5812] = "BombKit",
	[5927] = "FlameThrower",
	[6020] = "GrenadeKit",
	[5805] = "GrenadeKit",
	[5904] = "ToolKit",
	[5933] = "ElixirGun",
	--[5802] = "Medkit",
};

mc_skillmanager.ElementarAttunements = {
	["Fire"] = 12,
	["Water"] = 13,
	["Air"] = 14,
	["Earth"] = 15,
};

mc_skillmanager.BuffEnum = {
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

mc_skillmanager.ConditionsEnum = {
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
	
mc_skillmanager.BoonsEnum = {
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




function mc_skillmanager.ModuleInit() 	
	if (Settings.GW2Minion.gSMprofile == nil) then
		Settings.GW2Minion.gSMprofile = "None"
	end
	if (Settings.GW2Minion.gSMSwapR == nil) then
		Settings.GW2Minion.gSMSwapR = "0"
	end
	if (Settings.GW2Minion.gSMSwapCD == nil) then
		Settings.GW2Minion.gSMSwapCD = "1"
	end
	if (Settings.GW2Minion.gSMSwapRange == nil) then
		Settings.GW2Minion.gSMSwapRange = "1"
	end
	if (Settings.GW2Minion.gSMPrioKit == nil) then
		Settings.GW2Minion.gSMPrioKit = "None"
	end
	if (Settings.GW2Minion.gSMPrioAtt == nil) then
		Settings.GW2Minion.gSMPrioAtt = "Fire"
	end	
	if (Settings.GW2Minion.gSMPrioAtt2 == nil) then
		Settings.GW2Minion.gSMPrioAtt2 = "Water"
	end	
	if (Settings.GW2Minion.gSMPrioAtt3 == nil) then
		Settings.GW2Minion.gSMPrioAtt3 = "Air"
	end	
	if (Settings.GW2Minion.gSMPrioAtt4 == nil) then
		Settings.GW2Minion.gSMPrioAtt4 = "Earth"
	end		

		
	GUI_NewWindow(mc_skillmanager.mainwindow.name,mc_skillmanager.mainwindow.x,mc_skillmanager.mainwindow.y,mc_skillmanager.mainwindow.w,mc_skillmanager.mainwindow.h,true)
	GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("profile"),"gSMprofile",GetString("generalSettings"),"None")
		
	GUI_NewCheckbox(mc_skillmanager.mainwindow.name,GetString("SwapR"),"gSMSwapR",GetString("AdvancedSettings"))
	GUI_NewCheckbox(mc_skillmanager.mainwindow.name,GetString("SwapCD"),"gSMSwapCD",GetString("AdvancedSettings"))
	GUI_NewCheckbox(mc_skillmanager.mainwindow.name,GetString("SwapRange"),"gSMSwapRange",GetString("AdvancedSettings"))
	
	if ( Player ) then
		local prof = Player.profession
		if ( prof ~= nil ) then
			if (prof == 3) then	-- Engineer
			GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("PriorizeKit"),"gSMPrioKit",GetString("AdvancedSettings"),"None,BombKit,FlameThrower,GrenadeKit,ToolKit,ElixirGun")
			
			elseif( prof == 6 ) then -- Elementalist
				GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("PriorizeAttunement1"),"gSMPrioAtt",GetString("AdvancedSettings"),"None,Fire,Water,Air,Earth")
				GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("PriorizeAttunement2"),"gSMPrioAtt2",GetString("AdvancedSettings"),"None,Fire,Water,Air,Earth")
				GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("PriorizeAttunement3"),"gSMPrioAtt3",GetString("AdvancedSettings"),"None,Fire,Water,Air,Earth")
				GUI_NewComboBox(mc_skillmanager.mainwindow.name,GetString("PriorizeAttunement4"),"gSMPrioAtt4",GetString("AdvancedSettings"),"None,Fire,Water,Air,Earth")
			end				
		end
	end
	GUI_NewButton(mc_skillmanager.mainwindow.name,GetString("autoetectSkills"),"SMAutodetect",GetString("skillEditor"))
	RegisterEventHandler("SMAutodetect",mc_skillmanager.AutoDetectSkills)	
	GUI_NewButton(mc_skillmanager.mainwindow.name,GetString("saveProfile"),"SMSaveEvent")	
	RegisterEventHandler("SMSaveEvent",mc_skillmanager.SaveProfile)	
	GUI_NewField(mc_skillmanager.mainwindow.name,GetString("newProfileName"),"gSMnewname",GetString("skillEditor"))
	GUI_NewButton(mc_skillmanager.mainwindow.name,GetString("newProfile"),"SMCreateNewProfile",GetString("skillEditor"))
	RegisterEventHandler("SMCreateNewProfile",mc_skillmanager.CreateNewProfile)
			
		
	gSMSwapR = Settings.GW2Minion.gSMSwapR
	gSMSwapCD = Settings.GW2Minion.gSMSwapCD
	gSMSwapRange = Settings.GW2Minion.gSMSwapRange
	gSMPrioKit = Settings.GW2Minion.gSMPrioKit
	gSMPrioAtt = Settings.GW2Minion.gSMPrioAtt
	gSMPrioAtt2 = Settings.GW2Minion.gSMPrioAtt2
	gSMPrioAtt3 = Settings.GW2Minion.gSMPrioAtt3
	gSMPrioAtt4 = Settings.GW2Minion.gSMPrioAtt4	
	gSMprofile = Settings.GW2Minion.gSMprofile
	gSMnewname = ""
  		
	GUI_SizeWindow(mc_skillmanager.mainwindow.name,mc_skillmanager.mainwindow.w,mc_skillmanager.mainwindow.h)
	GUI_UnFoldGroup(mc_skillmanager.mainwindow.name,GetString("generalSettings"))
	GUI_WindowVisible(mc_skillmanager.mainwindow.name,false)
	
	
	-- EDITOR WINDOW
	GUI_NewWindow(mc_skillmanager.editwindow.name,mc_skillmanager.mainwindow.x+mc_skillmanager.mainwindow.w,mc_skillmanager.mainwindow.y,mc_skillmanager.editwindow.w,mc_skillmanager.editwindow.h,true)		
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("maMarkerName"),"SKM_NAME","SkillDetails")
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("maMarkerID"),"SKM_ID","SkillDetails")		
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("prevSkillID"),"SKM_PrevID","SkillDetails");
	GUI_NewCheckbox(mc_skillmanager.editwindow.name,GetString("setsAttackRange"),"SKM_ATKRNG","SkillDetails")	
	GUI_NewCheckbox(mc_skillmanager.editwindow.name,GetString("los"),"SKM_LOS","SkillDetails") -- Needed ?	
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("casttime"),"SKM_CASTTIME","SkillDetails")	
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("smthrottle"),"SKM_THROTTLE","SkillDetails");	
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("minRange"),"SKM_MinR","SkillDetails")
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("maxRange"),"SKM_MaxR","SkillDetails")
	GUI_NewComboBox(mc_skillmanager.editwindow.name,GetString("targetType"),"SKM_TType","SkillDetails","Enemy,Self");
	GUI_NewComboBox(mc_skillmanager.editwindow.name,GetString("useOutOfCombat"),"SKM_OutOfCombat","SkillDetails","No,Yes,Either");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerHPGT"),"SKM_PHPL","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerHPLT"),"SKM_PHPB","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerPowerGT"),"SKM_PPowL","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerPowerLT"),"SKM_PPowB","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerEnduranceGT"),"SKM_PEndL","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("playerEnduranceLT"),"SKM_PEndB","SkillDetails");
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("playerHas"),"SKM_PEff1","SkillDetails");	
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("playerHasNot"),"SKM_PNEff1","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,"Player has #Boons >","SKM_PBoonC","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,"Player has #Conditions >","SKM_PCondC","SkillDetails");	
	GUI_NewComboBox(mc_skillmanager.editwindow.name,GetString("targetMoving"),"SKM_TMove","SkillDetails","Either,Yes,No");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("targetHPGT"),"SKM_THPL","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("targetHPLT"),"SKM_THPB","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("enemiesNearCount"),"SKM_TECount","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("enemiesNearRange"),"SKM_TERange","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("alliesNearCount"),"SKM_TACount","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,GetString("alliesNearRange"),"SKM_TARange","SkillDetails");
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("targetHas"),"SKM_TEff1","SkillDetails");	
	GUI_NewField(mc_skillmanager.editwindow.name,GetString("targetHasNot"),"SKM_TNEff1","SkillDetails");		
	GUI_NewNumeric(mc_skillmanager.editwindow.name,"Target has #Boons >","SKM_TBoonC","SkillDetails");
	GUI_NewNumeric(mc_skillmanager.editwindow.name,"Target has #Conditions >","SKM_TCondC","SkillDetails");	
		
	
	
	GUI_UnFoldGroup(mc_skillmanager.editwindow.name,"SkillDetails")
	GUI_SizeWindow(mc_skillmanager.editwindow.name,mc_skillmanager.editwindow.w,mc_skillmanager.editwindow.h)
	GUI_WindowVisible(mc_skillmanager.editwindow.name,false)
	
	GUI_NewButton(mc_skillmanager.editwindow.name,"DELETE","SMEDeleteEvent")
	RegisterEventHandler("SMEDeleteEvent",mc_skillmanager.EditorButtonHandler)	
	GUI_NewButton(mc_skillmanager.editwindow.name,"CLONE","SMECloneEvent")
	RegisterEventHandler("SMECloneEvent",mc_skillmanager.EditorButtonHandler)	
	GUI_NewButton(mc_skillmanager.editwindow.name,"DOWN","SMESkillDOWNEvent")	
	RegisterEventHandler("SMESkillDOWNEvent",mc_skillmanager.EditorButtonHandler)	
	GUI_NewButton(mc_skillmanager.editwindow.name,"UP","SMESkillUPEvent")
	RegisterEventHandler("SMESkillUPEvent",mc_skillmanager.EditorButtonHandler)
	
	if ( Player ) then
		mc_skillmanager.UpdateProfiles() -- Update the profiles dropdownlist
		GUI_DeleteGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
		mc_skillmanager.UpdateCurrentProfileData()
	end
end

function mc_skillmanager.UpdateCurrentProfileData()
    if ( gSMprofile ~= nil and gSMprofile ~= "" and gSMprofile ~= "None" ) then
        local profile = fileread(mc_skillmanager.profilepath..gSMprofile..".lua")
        if ( TableSize(profile) > 0) then
            local unsortedSkillList = {}			
            local newskill = {}            
			local i, line = next (profile)
            
			-- Profession Check			
			local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
            if ( tostring(key) == "Profession" and tonumber(id) == Player.profession) then
                d("Skillprofile Profession matches Playerprofession, loading profile")
				
				if ( line ) then                
					while i and line do
						local _, key, value = string.match(line, "(%w+)_(%w+)=(.*)")
						--d("key: "..tostring(key).." value:"..tostring(value))
						
						if ( key and value ) then
							value = string.gsub(value, "\r", "")					
							if ( key == "END" ) then
								--d("Adding Skill :"..newskill.name.."Prio:"..tostring(newskill.prio))
								table.insert(unsortedSkillList,tonumber(newskill.prio),newskill)						
								newskill = {}
								elseif ( key == "NAME" )then newskill.name = value
								elseif ( key == "ID" )then newskill.skillID = tonumber(value)
								elseif ( key == "PrevID" )then newskill.previd = tonumber(value)								
								elseif ( key == "ATKRNG" )then newskill.atkrng = tostring(value)
								elseif ( key == "Prio" )then newskill.prio = tonumber(value)
								elseif ( key == "LOS" )then newskill.los = tostring(value)
								elseif ( key == "CASTTIME" )then newskill.casttime = tonumber(value)
								elseif ( key == "THROTTLE" )then newskill.throttle = tonumber(value)								
								elseif ( key == "MinR" )then newskill.minRange = tonumber(value)
								elseif ( key == "MaxR" )then newskill.maxRange = tonumber(value)
								elseif ( key == "TType" )then newskill.ttype = tostring(value)
								elseif ( key == "OutOfCombat" )then newskill.ooc = tostring(value)
								elseif ( key == "PHPL" )then newskill.phpl = tonumber(value)
								elseif ( key == "PHPB" )then newskill.phpb = tonumber(value)
								elseif ( key == "PPowL" )then newskill.ppowl = tonumber(value)
								elseif ( key == "PPowB" )then newskill.ppowb = tonumber(value)
								elseif ( key == "PEndL" )then newskill.pendl = tonumber(value)
								elseif ( key == "PEndB" )then newskill.pendb = tonumber(value)								
								elseif ( key == "PEff1" )then newskill.peff1 = tostring(value)
								elseif ( key == "PNEff1" )then newskill.pneff1 = tostring(value)
								elseif ( key == "PCondC" )then newskill.pcondc = tonumber(value)
								elseif ( key == "PBoonC" )then newskill.pboonc = tonumber(value)								
								elseif ( key == "TMove" )then newskill.tmove = tostring(value)
								elseif ( key == "THPL" )then newskill.thpl = tonumber(value)
								elseif ( key == "THPB" )then newskill.thpb = tonumber(value)						
								elseif ( key == "TECount" )then newskill.tecount = tonumber(value)
								elseif ( key == "TERange" )then newskill.terange = tonumber(value)
								elseif ( key == "TACount" )then newskill.tacount = tonumber(value)
								elseif ( key == "TARange" )then newskill.tarange = tonumber(value)
								elseif ( key == "TEff1" )then newskill.teff1 = tostring(value)
								elseif ( key == "TNEff1" )then newskill.tneff1 = tostring(value)						
								elseif ( key == "TCondC" )then newskill.tcondc = tonumber(value)								
								elseif ( key == "TBoonC" )then newskill.tboonc = tonumber(value)										
							end
						else
							ml_error("Error loading inputline: Key: "..(tostring(key)).." value:"..tostring(value))
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
							mc_skillmanager.CreateNewSkillEntry(sortedSkillList[i])
						end
					end
				end			
				
			else
				d("Skillprofile Profession DOES NOT match Playerprofession")
				d("key: "..tostring(key).." id:"..tostring(id))
            end            
        else
            d("Profile is empty..")			
        end		
    else
        d("No new SkillProfile selected!")
		gSMprofile = "None"
    end
    GUI_UnFoldGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
end

function mc_skillmanager.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		--d(tostring(k).." = "..tostring(v))
		if ( k == "gSMSwapR" or 
			 k == "gSMSwapCD" or 
			 k == "gSMSwapRange" or 
			 k == "gSMPrioAtt" or
			 k == "gSMPrioAtt2" or
			 k == "gSMPrioAtt3" or
			 k == "gSMPrioAtt4" or			 			 
			 k == "gSMPrioKit") then			
			Settings.GW2Minion[tostring(k)] = v
		elseif ( k == "gSMprofile" ) then			
			mc_skillmanager.SkillRecordingActive = false				
			GUI_WindowVisible(mc_skillmanager.editwindow.name,false)
			GUI_DeleteGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
			mc_skillmanager.SkillProfile = {}
			mc_skillmanager.UpdateCurrentProfileData()
			Settings.GW2Minion.gSMprofile = tostring(v)
		elseif ( k == "SKM_PrevID" ) then mc_skillmanager.SkillProfile[SKM_Prio].previd = tonumber(v)
		elseif ( k == "SKM_NAME" ) then mc_skillmanager.SkillProfile[SKM_Prio].name = v
		elseif ( k == "SKM_ATKRNG" ) then mc_skillmanager.SkillProfile[SKM_Prio].atkrng = tostring(v)
		elseif ( k == "SKM_LOS" ) then mc_skillmanager.SkillProfile[SKM_Prio].los = tostring(v)
		elseif ( k == "SKM_CASTTIME" ) then mc_skillmanager.SkillProfile[SKM_Prio].casttime = tonumber(v)
		elseif ( k == "SKM_THROTTLE" ) then mc_skillmanager.SkillProfile[SKM_Prio].throttle = tonumber(v)		
		elseif ( k == "SKM_MinR" ) then mc_skillmanager.SkillProfile[SKM_Prio].minRange = tonumber(v)
		elseif ( k == "SKM_MaxR" ) then mc_skillmanager.SkillProfile[SKM_Prio].maxRange = tonumber(v)
		elseif ( k == "SKM_TType" ) then mc_skillmanager.SkillProfile[SKM_Prio].ttype = v
		elseif ( k == "SKM_OutOfCombat" ) then mc_skillmanager.SkillProfile[SKM_Prio].ooc = v
		elseif ( k == "SKM_PHPL" ) then mc_skillmanager.SkillProfile[SKM_Prio].phpl = tonumber(v)
		elseif ( k == "SKM_PHPB" ) then mc_skillmanager.SkillProfile[SKM_Prio].phpb = tonumber(v)
		elseif ( k == "SKM_PPowL" ) then mc_skillmanager.SkillProfile[SKM_Prio].ppowl = tonumber(v)
		elseif ( k == "SKM_PPowB" ) then mc_skillmanager.SkillProfile[SKM_Prio].ppowb = tonumber(v)
		elseif ( k == "SKM_PEndL" ) then mc_skillmanager.SkillProfile[SKM_Prio].pendl = tonumber(v)
		elseif ( k == "SKM_PEndB" ) then mc_skillmanager.SkillProfile[SKM_Prio].pendb = tonumber(v)
		elseif ( k == "SKM_PEff1" ) then mc_skillmanager.SkillProfile[SKM_Prio].peff1 = v
		elseif ( k == "SKM_PCondC" ) then mc_skillmanager.SkillProfile[SKM_Prio].pcondc = tonumber(v)
		elseif ( k == "SKM_PNEff1" ) then mc_skillmanager.SkillProfile[SKM_Prio].pneff1 = v
		elseif ( k == "SKM_TMove" ) then mc_skillmanager.SkillProfile[SKM_Prio].tmove = v
		elseif ( k == "SKM_THPL" ) then mc_skillmanager.SkillProfile[SKM_Prio].thpl = tonumber(v)
		elseif ( k == "SKM_THPB" ) then mc_skillmanager.SkillProfile[SKM_Prio].thpb = tonumber(v)
		elseif ( k == "SKM_TECount" ) then mc_skillmanager.SkillProfile[SKM_Prio].tecount = tonumber(v)
		elseif ( k == "SKM_TERange" ) then mc_skillmanager.SkillProfile[SKM_Prio].terange = tonumber(v)
		elseif ( k == "SKM_TACount" ) then mc_skillmanager.SkillProfile[SKM_Prio].tacount = tonumber(v)
		elseif ( k == "SKM_TARange" ) then mc_skillmanager.SkillProfile[SKM_Prio].tarange = tonumber(v)
		elseif ( k == "SKM_TEff1" ) then mc_skillmanager.SkillProfile[SKM_Prio].teff1 = v
		elseif ( k == "SKM_TNEff1" ) then mc_skillmanager.SkillProfile[SKM_Prio].tneff1 = v				
		elseif ( k == "SKM_TCondC" ) then mc_skillmanager.SkillProfile[SKM_Prio].tcondc = tonumber(v)
		elseif ( k == "SKM_PBoonC" ) then mc_skillmanager.SkillProfile[SKM_Prio].pboonc = tonumber(v)
		elseif ( k == "SKM_TBoonC" ) then mc_skillmanager.SkillProfile[SKM_Prio].tboonc = tonumber(v)			
		end
	end
end

function mc_skillmanager.EditorButtonHandler(event)
	mc_skillmanager.SkillRecordingActive = false
	if ( event == "SMECloneEvent") then
		local clone = deepcopy(mc_skillmanager.SkillProfile[SKM_Prio])
		clone.prio = table.maxn(mc_skillmanager.SkillProfile)+1
		mc_skillmanager.CreateNewSkillEntry(clone)
		
	elseif ( event == "SMEDeleteEvent") then				
		if ( TableSize(mc_skillmanager.SkillProfile) > 0 ) then
			GUI_Delete(mc_skillmanager.mainwindow.name,"ProfileSkills")
			local i,s = next ( mc_skillmanager.SkillProfile, SKM_Prio)
			while i and s do
				s.prio = s.prio - 1
				mc_skillmanager.SkillProfile[SKM_Prio] = s
				SKM_Prio = i
				i,s = next ( mc_skillmanager.SkillProfile, i)
			end
			mc_skillmanager.SkillProfile[SKM_Prio] = nil
			mc_skillmanager.RefreshSkillList()	
			GUI_WindowVisible(mc_skillmanager.editwindow.name,false)
		end
		
	elseif (event == "SMESkillUPEvent") then		
		if ( TableSize(mc_skillmanager.SkillProfile) > 0 ) then
			if ( SKM_Prio > 1) then
				GUI_Delete(mc_skillmanager.mainwindow.name,"ProfileSkills")
				local tmp = mc_skillmanager.SkillProfile[SKM_Prio-1]
				mc_skillmanager.SkillProfile[SKM_Prio-1] = mc_skillmanager.SkillProfile[SKM_Prio]
				mc_skillmanager.SkillProfile[SKM_Prio-1].prio = mc_skillmanager.SkillProfile[SKM_Prio-1].prio - 1
				mc_skillmanager.SkillProfile[SKM_Prio] = tmp
				mc_skillmanager.SkillProfile[SKM_Prio].prio = mc_skillmanager.SkillProfile[SKM_Prio].prio + 1
				SKM_Prio = SKM_Prio-1
				mc_skillmanager.RefreshSkillList()				
			end
		end
		
	elseif ( event == "SMESkillDOWNEvent") then			
		if ( TableSize(mc_skillmanager.SkillProfile) > 0 ) then
			if ( SKM_Prio < TableSize(mc_skillmanager.SkillProfile)) then
				GUI_Delete(mc_skillmanager.mainwindow.name,"ProfileSkills")		
				local tmp = mc_skillmanager.SkillProfile[SKM_Prio+1]
				mc_skillmanager.SkillProfile[SKM_Prio+1] = mc_skillmanager.SkillProfile[SKM_Prio]
				mc_skillmanager.SkillProfile[SKM_Prio+1].prio = mc_skillmanager.SkillProfile[SKM_Prio+1].prio + 1
				mc_skillmanager.SkillProfile[SKM_Prio] = tmp
				mc_skillmanager.SkillProfile[SKM_Prio].prio = mc_skillmanager.SkillProfile[SKM_Prio].prio - 1
				SKM_Prio = SKM_Prio+1
				mc_skillmanager.RefreshSkillList()						
			end
		end
	end
end

function mc_skillmanager.RefreshSkillList()	
	if ( TableSize( mc_skillmanager.SkillProfile ) > 0 ) then
		local i,s = next ( mc_skillmanager.SkillProfile )
		while i and s do
			mc_skillmanager.CreateNewSkillEntry(s)
			i,s = next ( mc_skillmanager.SkillProfile , i )
		end
	end
	GUI_UnFoldGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
end

function mc_skillmanager.SaveProfile()
	local filename = ""
    local isnew = false
    -- Save under new name if one was entered
    if ( gSMnewname ~= "" ) then
        filename = gSMnewname
        gSMnewname = ""
        isnew = true
    elseif (gSMprofile ~= nil and gSMprofile ~= "None" and gSMprofile ~= "") then
        filename = gSMprofile
        gSMnewname = ""		
    end
	
	 -- Save current Profiledata into the Profile-file 
    if ( filename ~= "" ) then
		d("Saving Profile Data into File: "..filename)
		local profession = Player.profession
		local string2write = "SKM_Profession_"..tostring(profession).."="..tostring(profession).."\n"
		local skID,skill = next (mc_skillmanager.SkillProfile)
		while skID and skill do
			string2write = string2write.."SKM_NAME="..skill.name.."\n"
			string2write = string2write.."SKM_ID="..skill.skillID.."\n"
			string2write = string2write.."SKM_PrevID="..skill.previd.."\n"
			string2write = string2write.."SKM_ATKRNG="..skill.atkrng.."\n"			
			string2write = string2write.."SKM_Prio="..skill.prio.."\n"
			string2write = string2write.."SKM_LOS="..skill.los.."\n"
			string2write = string2write.."SKM_CASTTIME="..skill.casttime.."\n"
			string2write = string2write.."SKM_THROTTLE="..skill.throttle.."\n"
			string2write = string2write.."SKM_MinR="..skill.minRange.."\n"
			string2write = string2write.."SKM_MaxR="..skill.maxRange.."\n" 
			string2write = string2write.."SKM_TType="..skill.ttype.."\n"
			string2write = string2write.."SKM_OutOfCombat="..skill.ooc.."\n"
			string2write = string2write.."SKM_PHPL="..skill.phpl.."\n" 
			string2write = string2write.."SKM_PHPB="..skill.phpb.."\n" 
			string2write = string2write.."SKM_PPowL="..skill.ppowl.."\n" 
			string2write = string2write.."SKM_PPowB="..skill.ppowb.."\n"
			string2write = string2write.."SKM_PEndL="..skill.pendl.."\n" 
			string2write = string2write.."SKM_PEndB="..skill.pendb.."\n" 
			string2write = string2write.."SKM_PEff1="..skill.peff1.."\n" 
			string2write = string2write.."SKM_PCondC="..skill.pcondc.."\n" 
			string2write = string2write.."SKM_PNEff1="..skill.pneff1.."\n" 								
			string2write = string2write.."SKM_TMove="..skill.tmove.."\n" 
			string2write = string2write.."SKM_THPL="..skill.thpl.."\n" 
			string2write = string2write.."SKM_THPB="..skill.thpb.."\n" 
			string2write = string2write.."SKM_TECount="..skill.tecount.."\n" 
			string2write = string2write.."SKM_TERange="..skill.terange.."\n" 
			string2write = string2write.."SKM_TACount="..skill.tacount.."\n" 
			string2write = string2write.."SKM_TARange="..skill.tarange.."\n" 	
			string2write = string2write.."SKM_TEff1="..skill.teff1.."\n" 
			string2write = string2write.."SKM_TNEff1="..skill.tneff1.."\n" 
			string2write = string2write.."SKM_TCondC="..skill.tcondc.."\n" 
			string2write = string2write.."SKM_PBoonC="..skill.pboonc.."\n" 
			string2write = string2write.."SKM_TBoonC="..skill.tboonc.."\n"						
			string2write = string2write.."SKM_END=0\n"
		
			skID,skill = next (mc_skillmanager.SkillProfile,skID)
		end	
		d(filewrite(mc_skillmanager.profilepath ..filename..".lua",string2write))
		
		if ( isnew ) then
            gSMprofile_listitems = gSMprofile_listitems..","..filename
            gSMprofile = filename
            Settings.GW2Minion.gSMprofile = filename
        end
	else
		ml_error("You need to enter a new Filename first!!")
	end
end

function mc_skillmanager.CreateNewProfile()
	-- Delete existing Skills
    GUI_DeleteGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
    gSMprofile = "None"
    Settings.GW2Minion.gSMprofile = gSMprofile
    gSMnewname = ""	
	mc_skillmanager.SkillProfile = {}
end

function mc_skillmanager.AutoDetectSkills()
	mc_skillmanager.RecordSkillTmr = mc_global.now
	mc_skillmanager.SkillRecordingActive = true
end

function mc_skillmanager.UpdateProfiles()
	-- Grab all Profiles and enlist them in the dropdown field
	local profiles = "None"
	local found = "None"	
	local profilelist = dirlist(mc_skillmanager.profilepath,".*lua")
	if ( TableSize(profilelist) > 0) then			
		local i,profile = next ( profilelist)
		while i and profile do				
			profile = string.gsub(profile, ".lua", "")
			--d("Skillprofile: "..tostring(profile).." == "..tostring(gSMnewname))
			
			-- Make sure it matches our profession
			local file = fileread(mc_skillmanager.profilepath..profile..".lua")
			if ( TableSize(file) > 0) then
				local i, line = next (file)					
				local _, key, id, value = string.match(line, "(%w+)_(%w+)_(%d+)=(.*)")
				if ( tostring(key) == "Profession" and tonumber(id) == Player.profession) then
					profiles = profiles..","..profile
					if ( Settings.GW2Minion.gSMprofile ~= nil and Settings.GW2Minion.gSMprofile == profile ) then
						d("Last Profile found : "..profile)
						found = profile					
					end					
				end
			end
			i,profile = next ( profilelist,i)
		end		
	else
		ml_error("No Skillmanager profiles for our current Profession found")		
	end
	gSMprofile_listitems = profiles
	
	-- try to load default profiles
	if ( found == "None" ) then
		local defaultprofile = mc_skillmanager.DefaultProfiles[tonumber(Player.profession)]
		if ( defaultprofile ) then
			d("Loading default Profile for our profession")	
			mc_skillmanager.SkillRecordingActive = false				
			GUI_WindowVisible(mc_skillmanager.editwindow.name,false)
			GUI_DeleteGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
			mc_skillmanager.SkillProfile = {}
			mc_skillmanager.UpdateCurrentProfileData()
			Settings.GW2Minion.gSMprofile = tostring(defaultprofile)
			gSMprofile = defaultprofile
			return
		end
	end
	
	gSMprofile = found
end

function mc_skillmanager.CheckForNewSkills()
	for i = 1, 16, 1 do
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then
			local skID = skill.skillID
			if ( skID ) then
				local found = false
				if ( TableSize( mc_skillmanager.SkillProfile ) > 0 ) then
					local i,s = next ( mc_skillmanager.SkillProfile )
					while i and s do
						if s.skillID == skID then
							found = true
							break
						end
						i,s = next ( mc_skillmanager.SkillProfile , i )
					end
				end
				if not found then
					mc_skillmanager.CreateNewSkillEntry(skill)
				end
			end			
		end
	end
	GUI_UnFoldGroup(mc_skillmanager.mainwindow.name,"ProfileSkills")
end

function mc_skillmanager.CreateNewSkillEntry(skill)	
	if (skill ~= nil ) then
		local skname = skill.name
		local skID = skill.skillID		
		if (skname ~= "" and skID ) then
			local newskillprio = skill.prio or table.maxn(mc_skillmanager.SkillProfile)+1
			local bevent = tostring(newskillprio)
			
			GUI_NewButton(mc_skillmanager.mainwindow.name, tostring(bevent)..": "..skname, bevent,"ProfileSkills")
			if ( mc_skillmanager.RegisteredButtonEventList[newskillprio] == nil ) then
				RegisterEventHandler(bevent,mc_skillmanager.EditSkill)
				mc_skillmanager.RegisteredButtonEventList[newskillprio] = 1
			end	
			
			mc_skillmanager.SkillProfile[newskillprio] = {		
				skillID = skID,
				prio = newskillprio,
				name = skname,
				previd = skill.previd or "",
				atkrng = skill.atkrng or "1",		
				los = skill.los or "1",				
				casttime = skill.casttime or 250,
				throttle = skill.throttle or 0,
				minRange = skill.minRange or 0,
				maxRange = skill.maxRange or 0,
				if ( maxRange > 0 and maxRange < 150 ) then
					maxRange = 150
				end
				ttype = skill.ttype or "Enemy",
				ooc = skill.ooc or "Either",
				phpl = skill.phpl or 0,
				phpb = skill.phpb or 0,
				ppowl = skill.ppowl or 0,
				ppowb = skill.ppowb or 0,
				pendl = skill.pendl or 0,
				pendb = skill.pendb or 0,
				peff1 = skill.peff1 or "",
				pcondc = skill.pcondc or 0,
				pneff1 = skill.pneff1 or "",
				tmove = skill.tmove or "Either",
				thpl = skill.thpl or 0,
				thpb = skill.thpb or 0,
				tecount = skill.tecount or 0,
				terange = skill.terange or 0,
				tacount = skill.tacount or 0,
				tarange = skill.tarange or 0,
				teff1 = skill.teff1 or "",
				tneff1 = skill.tneff1 or "",
				tcondc = skill.condc or 0,
				pboonc = skill.pboonc or 0,
				tboonc = skill.tboonc or 0,						
			}		
		end		
	end
end

function mc_skillmanager.EditSkill(event)
	local wnd = GUI_GetWindowInfo(mc_skillmanager.mainwindow.name)	
	GUI_MoveWindow( mc_skillmanager.editwindow.name, wnd.x+wnd.width,wnd.y) 
	GUI_WindowVisible(mc_skillmanager.editwindow.name,true)
	-- Update EditorData
	local skill = mc_skillmanager.SkillProfile[tonumber(event)]	
	if ( skill ) then		
		SKM_NAME = skill.name or ""
		SKM_ID = skill.skillID or ""
		SKM_PrevID = skill.previd or ""
		SKM_ATKRNG = skill.atkrng or "1"
		SKM_Prio = tonumber(event)
		SKM_LOS = skill.los or "1"
		SKM_CASTTIME = skill.casttime or 250
		SKM_THROTTLE = skill.throttle or 0
		SKM_MinR = tonumber(skill.minRange) or 0
		SKM_MaxR = tonumber(skill.maxRange) or 160
		SKM_TType = skill.ttype or "Either"
		SKM_OutOfCombat = skill.ooc or "No"
		SKM_PHPL = tonumber(skill.phpl) or 0
		SKM_PHPB = tonumber(skill.phpb) or 0
		SKM_PPowL = tonumber(skill.ppowl) or 0
		SKM_PPowB = tonumber(skill.ppowb) or 0
		SKM_PEndL = tonumber(skill.pendl) or 0
		SKM_PEndB = tonumber(skill.pendb) or 0
		SKM_PEff1 = skill.peff1 or ""
		SKM_PCondC = tonumber(skill.pcondc) or 0
		SKM_PNEff1 = skill.pneff1 or ""
		SKM_TMove = skill.tmove or "Either"
		SKM_THPL = tonumber(skill.thpl) or 0
		SKM_THPB = tonumber(skill.thpb) or 0
		SKM_TECount = tonumber(skill.tecount) or 0
		SKM_TERange = tonumber(skill.terange) or 0
		SKM_TACount = tonumber(skill.tacount) or 0
		SKM_TARange = tonumber(skill.tarange) or 0
		SKM_TEff1 = skill.teff1 or ""
		SKM_TNEff1 = skill.tneff1 or ""
		SKM_TCondC = tonumber(skill.tcondc) or 0
		SKM_PBoonC = tonumber(skill.pboonc) or 0
		SKM_TBoonC = tonumber(skill.tboonc) or 0		
	end
end


function mc_skillmanager.OnUpdate( tick )
	
	if ( mc_skillmanager.SkillRecordingActive ) then
		if ( tick - mc_skillmanager.RecordSkillTmr > 30000) then -- max record 30seconds
			mc_skillmanager.RecordSkillTmr = 0
			mc_skillmanager.SkillRecordingActive = false
		elseif ( tick - mc_skillmanager.RecordSkillTmr > 500 ) then
			mc_skillmanager.RecordSkillTmr = tick
			mc_skillmanager.CheckForNewSkills()
		end		
	end
	
end

function mc_skillmanager.ToggleMenu()
	if (mc_skillmanager.visible) then
		GUI_WindowVisible(mc_skillmanager.mainwindow.name,false)	
		GUI_WindowVisible(mc_skillmanager.editwindow.name,false)
		
		mc_skillmanager.visible = false
	else
		local wnd = GUI_GetWindowInfo("MinionBot")	
		GUI_MoveWindow( mc_skillmanager.mainwindow.name, wnd.x+wnd.width,wnd.y) 
		GUI_WindowVisible(mc_skillmanager.mainwindow.name,true)	
		mc_skillmanager.visible = true
	end
end


-- Updates the MaxAttackRange and our currentskills List which is used in attack and heal
function mc_skillmanager.GetAttackRange()
	local maxrange = 150
	local tempskilllist = {}
	
	-- Clear list
	mc_skillmanager.currentskills = {}	
	
	-- Go through all our 16 skills once
	for i = 1, 16, 1 do	
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT["Slot_" .. i])
		if ( skill ~= nil ) then			
			if ( i == 1 ) then
				if( skill.maxRange < 150 ) then
					maxrange = 150
				else
					maxrange = skill.maxRange
				end
			end			
			-- Save the skillptr in tempskillist with the skillID beeing the index. By not accessing the skillptr's ID member but the table index instead, this improves heavily the performance
			tempskilllist[skill.skillID] = skill
		end		
	end
			
	-- Go through the SkillProfile and check if we currently have this skill in our slotbar, then add this skill to our currently castable "currentskills" table sorted by cast priority	
	if ( TableSize(mc_skillmanager.SkillProfile) > 0 and TableSize(tempskilllist) > 0 ) then
		for prio,skill in pairs(mc_skillmanager.SkillProfile) do
				
			for tmpSkillID,skillptr in pairs(tempskilllist) do
					
				if ( tmpSkillID == skill.skillID and skillptr.cooldown == 0 ) then-- skill is in our profile + current castbar
						
					-- Add this skill to the currentskills list for use in Attack/Heal, we save the SkillProfile data in currentskills and set the slot where this spell is available
					local currentslot = skillptr.slot
					mc_skillmanager.currentskills[prio] = skill
					mc_skillmanager.currentskills[prio].slot = currentslot
					mc_skillmanager.currentskills[prio].isGroundTargeted = skillptr.isGroundTargeted
					mc_skillmanager.currentskills[prio].stupidlua = prio
					--d("ADDING: " ..skill.name.." P: "..tostring(skill.prio).." S"..tostring(currentslot))
					
					-- Get Max Attack Range for global use
					if (skill.atkrng == "1" and currentslot > 5 and currentslot < 10 ) then -- Only use Skill 2-5 for Attackrange check
						--d(skill.name.." "..tostring(skill.maxRange).." "..tostring(skill.name).." "..tostring(skill.maxRange))
						if ( skill.maxRange > maxrange) then
							maxrange = skill.maxRange
						end							
					end						
					break
				end
			end
		end
	end	
	return maxrange
end

-- Checks if the passed skillmanager-skill can be cast at the passed target
function mc_skillmanager.CanCast( target, skill , playerbufflist, targetbufflist )
	
	-- Check general conditions
	if ( skill.throttle	> 0 and skill.timelastused and mc_global.now - skill.timelastused < skill.throttle)  then return false end
	if ( skill.previd ~= "" and not StringContains(skill.previd, mc_skillmanager.prevSkillID)) then return false end
	if ( skill.ooc == "Yes" and ml_global_information.Player_InCombat == true ) then return false end
	--if ( skill.ooc == "No" and ml_global_information.Player_InCombat == false and ( skill.slot ~= 1 or ( target and target.attackable ))) then return false end
		
	-- Check Player related conditions				
	if ( skill.phpl		> 0 and skill.phpl > ml_global_information.Player_Health.percent)  then return false end
	if ( skill.phpb 	> 0 and skill.phpb < ml_global_information.Player_Health.percent)  then return false end
	if ( skill.ppowl	> 0 and skill.ppowl> ml_global_information.Player_Power)  then return false end
	if ( skill.ppowb 	> 0 and skill.ppowb< ml_global_information.Player_Power)  then return false end
	if ( skill.pendl	> 0 and skill.pendl> ml_global_information.Player_Endurance)  then return false end
	if ( skill.pendb 	> 0 and skill.pendb< ml_global_information.Player_Endurance)  then return false end
	--Possible buffcheck values: "134,245+123,552+123+531"
	if ( skill.peff1 ~= ""  and playerbufflist and not mc_helper.BufflistHasBuffs(playerbufflist, skill.peff1) ) then return false end
	if ( skill.pneff1 ~= "" and playerbufflist and mc_helper.BufflistHasBuffs(playerbufflist, skill.pneff1) ) then return false end
	if ( skill.pcondc > 0   and playerbufflist and CountConditions(playerbufflist) <= skill.pcondc) then return false end
	if ( skill.pboonc > 0   and playerbufflist and CountBoons(playerbufflist) <= skill.pboonc) then return false end
					

	-- Check Target related conditions
	if ( target and skill.ttype == "Enemy" ) then		
		if ( skill.los == "Yes" and target.los == false ) then return false end
		if ( skill.minRange > 0 and target.distance < skill.minRange) then return false end
		if ( skill.maxRange > 0 and target.distance > skill.maxRange) then return false end
		if ( skill.thpl		> 0 and skill.thpl > target.health.percent) then return false end
		if ( skill.thpb 	> 0 and skill.thpb < target.health.percent) then return false end
		if ( skill.tmove=="Yes" and target.isCharacter and target.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving )then return false end
		if ( skill.tmove=="No" and target.isCharacter and target.movementstate == GW2.MOVEMENTSTATE.GroundMoving )then return false end
		--Possible buffcheck values: "134,245+123,552+123+531"
		if ( skill.teff1 ~= ""  and targetbufflist and not mc_helper.BufflistHasBuffs(targetbufflist, skill.teff1) ) then return false end
		if ( skill.tneff1 ~= "" and targetbufflist and mc_helper.BufflistHasBuffs(targetbufflist, skill.tneff1) ) then return false end
		if ( skill.tcondc > 0   and targetbufflist and CountConditions(targetbufflist) <= skill.tcondc) then return false end
		if ( skill.tboonc > 0   and targetbufflist and CountBoons(targetbufflist) <= skill.tboonc) then return false end			
	end
	
	if ( target ) then
		-- Friends around Target check
		if ( skill.tacount > 0 and skill.tarange > 0) then
			if ( TableSize(CharacterList("friendly,maxdistance="..skill.tarange..",distanceto="..target.id)) < skill.tacount) then return false end
		end	
		-- Enemies around Target check
		if ( skill.tecount > 0 and skill.terange > 0) then
			if ( TableSize(CharacterList("alive,attackable,maxdistance="..skill.terange..",distanceto="..target.id)) < skill.tecount) then return false end
		end
	end		  
	
	-- We are still here, we should be able to cast this spell
	return true
end



mc_skillmanager.PetTmr = 0
mc_skillmanager.lastcastTmr = 0
mc_skillmanager.lastTarget = {}
function mc_skillmanager.AttackTarget( TargetID )	
	local fastcastcount = 0
	
	-- ranger wanting extracode lol
	if ( Player.profession == 4 and mc_global.now - mc_skillmanager.PetTmr > 2500) then 
		mc_skillmanager.PetTmr = mc_global.now
		local pet = Player:GetPet()
		if ( pet ~= nil and Player:CanSwitchPet() == true and Player.healthstate == GW2.HEALTHSTATE.Alive and (pet.alive == false or pet.health.percent < 10)) then	
			d("Switching Pet..")
			Player:SwitchPet()		
		end
	end
	
	-- Throttle to not cast too fast & interrupt channeling spells
	if ( mc_global.now - mc_skillmanager.lastcastTmr < 250 ) then return false end
	
	--Valid Target?
	local target
	if ( TargetID == nil or TargetID == 0) then
		target = Player:GetTarget()
		if ( target ) then TargetID = target.id end
	else
		target = CharacterList:Get(TargetID)
		if ( not target ) then 			 
			target = GadgetList:Get(TargetID)
		end		
	end
	
		
	if ( target and TargetID and target.attackable ) then	
		local playerbufflist = Player.buffs		
		local targetbufflist = nil
		if ( target.isCharacter) then
			targetbufflist = target.buffs
		end
		
		local cast = false
		
		if ( TableSize(mc_skillmanager.currentskills) > 0 ) then
			mc_skillmanager.SwapWeaponCheck("Pulse")
			
			local cancast = Player:CanCast() -- some skills like grenades can be cast faster without that check
			
			for prio,skill in pairsByKeys(mc_skillmanager.currentskills) do
				
				--d("CASTCHECK: " ..skill.name.." P: "..tostring(prio).." Sx: "..tostring(skill.slot).." CanCast: "..tostring(mc_skillmanager.CanCast( target, skill , playerbufflist, targetbufflist)))
				
				if ( (cancast or (not cancast and skill.throttle == 0)) and mc_skillmanager.CanCast( target, skill , playerbufflist, targetbufflist) ) then
									
					--d("Cast Slot "..tostring(skill.slot))
					cast = false
					if ( skill.ttype == "Self" ) then
						if ( Player:CastSpell(skill.slot) ) then							
							cast = true
							return true
						end
					else					
						
						if ( mc_skillmanager.currentskills[prio].isGroundTargeted ) then
							
							if ( (target.isCharacter and target.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) or target.isGadget) then
							if ( Player:CastSpell(skill.slot,TargetID) ) then									
									cast = true
								end
							else							
								-- movement prediction
								if ( mc_skillmanager.lastTarget.id and mc_skillmanager.lastTarget.id == TargetID and mc_skillmanager.lastTarget.pos) then
									local tpos = target.pos
									local pPos = Player.pos
									local dx = tpos.x-mc_skillmanager.lastTarget.pos.x
									local dy = tpos.y-mc_skillmanager.lastTarget.pos.y
									local targetSpeed = math.sqrt(dx*dx + dy*dy)									
									local targetHeading = math.atan2(dx, dy)
																			
									--d("Speed: " .. tostring(targetSpeed).." Heading "..tostring(targetHeading))
									tpos.x = tpos.x + math.sin(targetHeading) * targetSpeed/5 * (1 + target.distance / 30)
									tpos.y = tpos.y + math.cos(targetHeading) * targetSpeed/5 * (1 + target.distance / 30)
									
									local dist = Distance3D(pPos.x,pPos.y,pPos.z,tpos.x,tpos.y,tpos.z)
									--d("Dist : "..tostring(dist))
									if dist <= 1575 then											
										Player:CastSpell(skill.slot,tpos.x,tpos.y,tpos.z) 
										--d("Casting AE on moving Target (predicted pos): "..tostring(mc_skillmanager.currentskills[prio].name))
										cast = true
									else
										--d("Predicted location was too far.")
										if ( Player:CastSpell(skill.slot,tpos.x,tpos.y,tpos.z) ) then									
											--d("Casting AE on moving Target: "..tostring(mc_skillmanager.currentskills[prio].name))
											cast = true
										end
									end
									
								else
									mc_skillmanager.lastTarget.id = TargetID									
								end
								mc_skillmanager.lastTarget.pos = target.pos
																			
							end									
						else
							if ( Player:CastSpell(skill.slot,TargetID) ) then
								--d("Casting on Target: "..tostring(mc_skillmanager.currentskills[prio].name))
								cast = true								
							end									
						end											
					end
					
					if ( cast == true ) then
						if (prio ~= 1 ) then mc_skillmanager.prevSkillID = mc_skillmanager.currentskills[prio].skillID end
						mc_skillmanager.SkillProfile[prio].timelastused = mc_global.now
						
						if ( skill.casttime > 0 ) then							
							mc_skillmanager.lastcastTmr = mc_global.now + skill.casttime
						else
							mc_skillmanager.lastcastTmr = mc_global.now
						end
						
						if ( skill.slot == 5 ) then						
							mc_skillmanager.SwapWeapCheck(target)
						end						
						return true					
					else
						if ( skill.slot == 5 ) then
							mc_skillmanager.SwapWeapCheck(target)
						end
					end
				end				
			end
		end
		mc_skillmanager.SwapWeapCheck(target)
	end
	return false
end

function mc_skillmanager.SwapWeapCheck( target )
	-- Swap Weapon check
	if ( ml_global_information.AttackRange < 300 and target.distance > ml_global_information.AttackRange ) then
		mc_skillmanager.SwapWeaponCheck("Range")
	else	 
		mc_skillmanager.SwapWeaponCheck("CoolDown")
	end	
end

function mc_skillmanager.HealMe()	
	
	-- ranger wanting extracode lol
	if ( Player.profession == 4 and mc_global.now - mc_skillmanager.PetTmr > 2500) then 
		mc_skillmanager.PetTmr = mc_global.now
		local pet = Player:GetPet()
		if ( pet ~= nil and Player:CanSwitchPet() == true and Player.healthstate == GW2.HEALTHSTATE.Alive and pet.alive == false) then	
			d("Switching Pet..")
			Player:SwitchPet()		
		end
	end

	-- Throttle to not cast too fast & interrupt channeling spells
	if ( mc_global.now - mc_skillmanager.lastcastTmr < 250 ) then return false end
	
	--Valid Target?
	local playerbufflist = Player.buffs	
	if ( playerbufflist ) then
				
		if ( TableSize(mc_skillmanager.currentskills) > 0 and Player:CanCast() ) then -- disable CanCast for fastcasting here ?
			mc_skillmanager.SwapWeaponCheck("Pulse")
			
			for prio,skill in pairs(mc_skillmanager.currentskills) do
				
				if (skill.ttype == "Self" and mc_skillmanager.CanCast( nil, skill , playerbufflist, nil) ) then
					
					if ( skill.ooc ~= "No" or (skill.ooc == "No" and ml_global_information.Player_InCombat == true ) ) then
						if ( Player:CastSpell(skill.slot) ) then
							--d("Cast Healing Slot "..tostring(skill.slot))					
							--d("Casting on Self: "..tostring(mc_skillmanager.currentskills[prio].name))
							if (prio ~= 1 ) then mc_skillmanager.prevSkillID = mc_skillmanager.currentskills[prio].skillID end
							mc_skillmanager.SkillProfile[prio].timelastused = mc_global.now
							
							if ( skill.casttime > 0 ) then							
								mc_skillmanager.lastcastTmr = mc_global.now + skill.casttime
							else
								mc_skillmanager.lastcastTmr = mc_global.now
							end			
							
							return true
						end
					end
				end				
			end
		end
	end
	return false
end


function CountConditions(bufflist)
	local count = 0
	if ( bufflist ) then	
		local i,buff = next(bufflist)
		while i and buff do							
			local bskID = buff.skillID
			if ( bskID and mc_skillmanager.ConditionsEnum[bskID] ~= nil) then
				count = count + 1
			end
			i,buff = next(bufflist,i)
		end		
	end
	return count
end
function CountBoons(bufflist)
	local count = 0
	if ( bufflist ) then	
		local i,buff = next(bufflist)
		while i and buff do							
			local bskID = buff.skillID
			if ( bskID and mc_skillmanager.BoonsEnum[bskID] ~= nil) then
				count = count + 1
			end
			i,buff = next(bufflist,i)
		end		
	end
	return count
end

function mc_skillmanager.SwapWeaponCheck(swaptype)
	if ( mc_global.now - mc_skillmanager.SwapTmr > 750 ) then
				
		-- Swap after random Time (not used right now)
		if ( swaptype == "Pulse" and gSMSwapR == "1" and (mc_global.now - mc_skillmanager.SwapRTmr > math.random(4000,7000))) then
			mc_skillmanager.SwapRTmr = mc_global.now
			mc_skillmanager.SwapTmr = mc_global.now			
			mc_skillmanager.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end
		
		-- Swap when skills 2-5 are on CD
		if ( swaptype == "CoolDown" and gSMSwapCD == "1" and math.random(0,1) == 1)  then
			mc_skillmanager.SwapTmr = mc_global.now
			mc_skillmanager.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end
		
		-- Swap when our target is out of range for the current weapon
		if ( swaptype == "Range" and gSMSwapRange == "1") then
			mc_skillmanager.SwapTmr = mc_global.now
			mc_skillmanager.SwapWeapon(swaptype)
			--d(swaptype)
			return
		end		
	end	
end

function mc_skillmanager.SwapWeapon(swaptype)	
	if ( Player.profession == 6 ) then 
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
			elseif (sID==5518 or sID==5489 or sID==5526 ) then
				currentAttunement = 14
			elseif (sID==5519 or sID==15717 or sID==5500 ) then
				currentAttunement = 15
			end
			if ( currentAttunement ) then
				if ( tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt)]) and currentAttunement ~= tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt)]) and not Player:IsSpellOnCooldown(tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt)]))) then
					switch = tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt)])
				elseif ( tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt2)]) and currentAttunement ~= tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt2)]) and not Player:IsSpellOnCooldown(tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt2)]))) then
					switch = tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt2)])
				elseif ( tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt3)]) and currentAttunement ~= tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt3)]) and not Player:IsSpellOnCooldown(tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt3)]))) then
					switch = tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt3)])
				elseif ( tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt4)]) and currentAttunement ~= tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt4)]) and not Player:IsSpellOnCooldown(tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt4)]))) then
					switch = tonumber(mc_skillmanager.ElementarAttunements[tostring(gSMPrioAtt4)])
				end				
			else
				--ml_error("WHOOOPPSS, You have a unknown weapon! Please report back to us what kind of weapon you are using! "..sID)
			end					
			--d("TEST:"..tostring(switch) .. " " ..tostring(sID))
			if ( switch ) then
				Player:CastSpell(switch)
				mc_skillmanager.SwapTmr = mc_global.now		
			end
		end
		
	elseif( Player.profession == 3 ) then 		
		-- Engineer	
		local availableKits = { [1] = 0 }-- Leave Kit Placeholder					
		for prio,skill in pairsByKeys(mc_skillmanager.currentskills) do
			--d(tostring(skill.skillID) .. " / "..tostring(mc_skillmanager.EngineerKits[skill.skillID]))
			if ( mc_skillmanager.EngineerKits[skill.skillID] ~= nil and not Player:IsSpellOnCooldown(skill.slot)) then
				if ( mc_skillmanager.SwapWeaponTable[skill.slot] == nil or (mc_global.now - mc_skillmanager.SwapWeaponTable[skill.slot].lastused or 0) > 1500) then
					--d("ADDING: "..tostring(skill.skillID) .. " / "..tostring(mc_skillmanager.EngineerKits[skill.skillID]))
					availableKits[#availableKits+1] = skill.slot												
				end
			end				
		end		
		local key = math.random(#availableKits)		
		--d("MAx "..tostring(#availableKits).."..KEYSIZE "..tostring(#availableKits).. " choosen: "..tostring(key))
		--d("Slot: " ..tostring(availableKits[key]))
		if ( key ~= 1 ) then
			Player:CastSpell(availableKits[key])
			if (gSMPrioKit ~= "None" and tostring(mc_skillmanager.EngineerKits[Player:GetSpellInfo(availableKits[key]).skillID]) ~= tostring(gSMPrioKit))then
				--d(tostring(mc_skillmanager.EngineerKits[Player:GetSpellInfo(availableKits[key]).skillID]).." is not our priokit: "..tostring(gSMPrioKit).." delaying next use")
				mc_skillmanager.SwapWeaponTable[availableKits[key]] = { lastused = mc_global.now + 15000 }
			else
				mc_skillmanager.SwapWeaponTable[availableKits[key]] = { lastused = mc_global.now }
			end
		else			
			if ( Player:CanSwapWeaponSet() ) then
				if (gSMPrioKit == "None" or swaptype == "Pulse" or swaptype == "Range") then
					Player:SwapWeaponSet()
					mc_skillmanager.SwapTmr = mc_global.now
				end
			end
		end
	else 
		-- All other professions
		if ( Player:CanSwapWeaponSet() ) then
			Player:SwapWeaponSet()
			mc_skillmanager.SwapTmr = mc_global.now
		end
	end	
end


RegisterEventHandler("SkillManager.toggle", mc_skillmanager.ToggleMenu)
RegisterEventHandler("GUI.Update",mc_skillmanager.GUIVarUpdate)
RegisterEventHandler("Module.Initalize",mc_skillmanager.ModuleInit)
