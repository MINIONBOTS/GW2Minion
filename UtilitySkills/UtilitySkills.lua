UtilitySkills = inheritsFrom(wt_core_state)

function UtilitySkills.UpdateWindow()
	UtilitySkillsStatus = tostring(UtilitySkillsEnabled)
	GUI_RefreshWindow("UtilitySkills")
end

function UtilitySkills.ToggleUtilitySkills()
	UtilitySkillsEnabled = not UtilitySkillsEnabled
	SaveWindowInfo() -- store changes
	UpdateWindow()  -- repaint GUI and add values
end

function UtilitySkills.ModuleInit()
	if (Settings.UtilitySkills.version == nil ) then
		Settings.UtilitySkills.version = 1.0
	end

	if (Settings.UtilitySkills.version < 1.2 ) then
		Settings.UtilitySkills.version = 1.2
	end
	
	if (Settings.UtilitySkills.x == nil) then
		Settings.UtilitySkills.x = 50
	end
	if (Settings.UtilitySkills.y == nil) then
		Settings.UtilitySkills.y = 50
	end
	if (Settings.UtilitySkills.width == nil) then
		Settings.UtilitySkills.width = 130
	end
	if (Settings.UtilitySkills.height == nil) then
		Settings.UtilitySkills.height = 90
	end

	if (Settings.UtilitySkills.Profession == nil) then
		Settings.UtilitySkills.Profession = Player.profession
	end
	
	for i=7,16 do 
		--d("US_"..tostring(i));
		--initialize vars for gui (thx dToast)
		var1 = "use"..tostring(i).."_enabled"
		var2 = "use"..tostring(i).."_incombat"
		var3 = "use"..tostring(i).."_hp"
		if(Settings.UtilitySkills[tostring(var1)] ==nil) then
			Settings.UtilitySkills[tostring(var1)] ="0"
		end
		if(Settings.UtilitySkills[tostring(var2)] ==nil) then
			Settings.UtilitySkills[tostring(var2)] ="0"
		end
		if(Settings.UtilitySkills[tostring(var3)] ==nil) then
			Settings.UtilitySkills[tostring(var3)] =""
		end
	end
	
	GUI_NewWindow("UtilitySkills",Settings.UtilitySkills.x,Settings.UtilitySkills.y,Settings.UtilitySkills.width,Settings.UtilitySkills.height)
	GUI_NewCheckbox("UtilitySkills","Toggle","UtilitySkillsTOGGLE")

---[[	
	local s7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7);
	if (s7 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","7 "..tostring(s7.name),"use7_enabled");
		GUI_NewCheckbox("UtilitySkills","7     In Combat","use7_incombat");
		GUI_NewField("UtilitySkills","7     @Health %","use7_hp");
	end

	local s8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8);
	if (s8 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","8 "..tostring(s8.name),"use8_enabled");
		GUI_NewCheckbox("UtilitySkills","8     In Combat","use8_incombat");
		GUI_NewField("UtilitySkills","8     @Health %","use8_hp");
	end

	local s9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9);
	if (s9 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","9 "..tostring(s9.name),"use9_enabled");
		GUI_NewCheckbox("UtilitySkills","9     In Combat","use9_incombat");
		GUI_NewField("UtilitySkills","9     @Health %","use9_hp");
	end
	
	local s10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10);
	if (s10 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","10 "..tostring(s10.name),"use10_enabled");
		GUI_NewCheckbox("UtilitySkills","10     In Combat","use10_incombat");
		GUI_NewField("UtilitySkills","10     @Health %","use10_hp");
	end

	local s11 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_11);
	if (s11~=nil) then
		GUI_NewCheckbox("UtilitySkills","11 "..tostring(s11.name),"use11_enabled");
		GUI_NewCheckbox("UtilitySkills","11     In Combat","use11_incombat");
		GUI_NewField("UtilitySkills","11     @Health %","use11_hp");
	end

	local s12 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_12);
	if (s12 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","12 "..tostring(s12.name),"use12_enabled");
		GUI_NewCheckbox("UtilitySkills","12     In Combat","use12_incombat");
		GUI_NewField("UtilitySkills","12     @Health %","use12_hp");
	end

	local s13 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13);
	if (s13 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","13 "..tostring(s13.name),"use13_enabled");
		GUI_NewCheckbox("UtilitySkills","13     In Combat","use13_incombat");
		GUI_NewField("UtilitySkills","13     @Health %","use13_hp");
	end


	local s14 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_14);
	if (s14 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","14 "..tostring(s14.name),"use14_enabled");
		GUI_NewCheckbox("UtilitySkills","14     In Combat","use14_incombat");
		GUI_NewField("UtilitySkills","14     @Health %","use14_hp");
	end
	
	local s15 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_15);
	if (s15 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","15 "..tostring(s15.name),"use15_enabled");
		GUI_NewCheckbox("UtilitySkills","15     In Combat","use15_incombat");
		GUI_NewField("UtilitySkills","15     @Health %","use15_hp");
	end
	
	local s16 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_16);
	if (s16 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","16 "..tostring(s16.name),"use16_enabled");
		GUI_NewCheckbox("UtilitySkills","16     In Combat","use16_incombat");
		GUI_NewField("UtilitySkills","16     @Health %","use16_hp");
	end
	--]]

	-- Add to other states only after all files have been loaded
	local ke_utility_cast = wt_kelement:create("UtilityCast",UtilitySkills.c_utility_cast,UtilitySkills.e_utility_cast, 55 )
	wt_core_state_combat:add(ke_utility_cast)

	-- Only load saved values if they are from the same profession as the current one, otherwise its pointless
	if (Settings.UtilitySkills.Profession == Player.profession) then
		use7_enabled = Settings.UtilitySkills.use7_enabled;
		use7_incombat = Settings.UtilitySkills.use7_incombat;
		use7_hp = Settings.UtilitySkills.use7_hp;
		
		use8_enabled = Settings.UtilitySkills.use8_enabled;
		use8_incombat = Settings.UtilitySkills.use8_incombat;
		use8_hp = Settings.UtilitySkills.use8_hp;

		use9_enabled = Settings.UtilitySkills.use9_enabled;
		use9_incombat = Settings.UtilitySkills.use9_incombat;
		use9_hp = Settings.UtilitySkills.use9_hp;
		
		use10_enabled = Settings.UtilitySkills.use10_enabled;
		use10_incombat = Settings.UtilitySkills.use10_incombat;
		use10_hp = Settings.UtilitySkills.use10_hp;
		
		use11_enabled = Settings.UtilitySkills.use11_enabled;
		use11_incombat = Settings.UtilitySkills.use11_incombat;
		use11_hp = Settings.UtilitySkills.use11_hp;	
		
		use12_enabled = Settings.UtilitySkills.use12_enabled;
		use12_incombat = Settings.UtilitySkills.use12_incombat;
		use12_hp = Settings.UtilitySkills.use12_hp;
		
		use13_enabled = Settings.UtilitySkills.use13_enabled;
		use13_incombat = Settings.UtilitySkills.use13_incombat;
		use13_hp = Settings.UtilitySkills.use13_hp;
		
		use14_enabled = Settings.UtilitySkills.use14_enabled;
		use14_incombat = Settings.UtilitySkills.use14_incombat;
		use14_hp = Settings.UtilitySkills.use14_hp;
		
		use15_enabled = Settings.UtilitySkills.use15_enabled;
		use15_incombat = Settings.UtilitySkills.use15_incombat;
		use15_hp = Settings.UtilitySkills.use15_hp;
		
		use16_enabled = Settings.UtilitySkills.use16_enabled;
		use16_incombat = Settings.UtilitySkills.use16_incombat;
		use16_hp = Settings.UtilitySkills.use16_hp;
	end
	
	GUI_RefreshWindow("UtilitySkills")  -- repaint GUI and add values
end

function UtilitySkills.SaveWindowInfo()
	W = GUI_GetWindowInfo("UtilitySkills")
	if (Settings.UtilitySkills.y ~= W.y) then
		Settings.UtilitySkills.y = W.y
	end
	if (Settings.UtilitySkills.x ~= W.x) then
		Settings.UtilitySkills.x = W.x
	end
	if (Settings.UtilitySkills.width ~= W.width) then
		Settings.UtilitySkills.width = W.width
	end
	if (Settings.UtilitySkills.height ~= W.height) then
		Settings.UtilitySkills.height = W.height
	end
	--Settings.UtilitySkills.Profession = Player.profession
end

function UtilitySkills.GUIVarUpdate(Event, NewVals, OldVals)
	if  (NewVals ~=nil) then
		for k,v in pairs(NewVals) do	
			--if (string.find(tostring(k), "use", 1) ~= nil) then   --this only saves if it contains the "use" string 
				d("UtilitySkill:"..tostring(k).." | "..tostring(v))
				Settings.UtilitySkills[tostring(k)] = v
			--end
		end
	end
	UtilitySkills.SaveWindowInfo()
end

---[[
UtilitySkills.c_utility_cast = inheritsFrom(wt_cause)
UtilitySkills.e_utility_cast = inheritsFrom(wt_effect)
UtilitySkills.CastSlot = nil

function UtilitySkills.c_utility_cast:evaluate()
	  if (UtilitySkillsTOGGLE == "1") then 
			local s7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7)
			local s8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8)
			local s9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9)
			local s10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10)
			local s11 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_11)
			local s12 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_12)
			local s13 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
			local s14 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_14)
			local s15 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_15)
			local s16 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_16)

			if (s7 ~= nil) and (use7_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_7)) and (s7~=nil) and (use7_hp=="" or Player.health.percent < tonumber(use7_hp)) then
					debug_msg( nil, nil, 7, s7.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_7
					return true
				end
			end

			if (s8 ~= nil) and (use8_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_8)) and (s8~=nil) and (use8_hp=="" or Player.health.percent < tonumber(use8_hp)) then
					debug_msg( nil, nil, 8, s8.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_8
					return true
				end
			end		

			if (s9 ~= nil) and (use9_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_9)) and (s9~=nil) and (use9_hp=="" or Player.health.percent < tonumber(use9_hp)) then
					debug_msg( nil, nil, 9, s9.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_9
					return true

				end
			end		

			if (s10 ~= nil) and (use10_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_10)) and (s10~=nil) and (use10_hp=="" or Player.health.percent < tonumber(use10_hp)) then
					debug_msg( nil, nil, 10, s10.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_10
					return true
				end
			end	

			if (s11 ~= nil) and (use11_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_11)) and (s11~=nil) and (use11_hp=="" or Player.health.percent < tonumber(use11_hp)) then
					debug_msg( nil, nil, 11, s11.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_11
					return true
				end
			end	

			if (s12 ~= nil) and (use12_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_12)) and (s12~=nil) and (use12_hp=="" or Player.health.percent < tonumber(use12_hp)) then
					debug_msg( nil, nil, 12, s12.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_12
					return true
				end
			end		

			if (s13 ~= nil) and (use13_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_13)) and (s13~=nil) and (use13_hp=="" or Player.health.percent < tonumber(use13_hp)) then
					debug_msg( nil, nil, 13, s13.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_13
					return true
				end
			end		

			if (s14 ~= nil) and (use14_incombat=="1") then
				if (not Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_14)) and (s14~=nil) and (use14_hp=="" or Player.health.percent < tonumber(use14_hp)) then
					debug_msg( nil, nil, 14, s14.name )
					UtilitySkills.CastSlot = GW2.SKILLBARSLOT.Slot_14
					return true
				end
			end		

	  end
	  return false
end

UtilitySkills.e_utility_cast.usesAbility = true
function UtilitySkills.e_utility_cast:execute()
	if (UtilitySkills.CastSlot~=nil) then
		Player:CastSpell(UtilitySkills.CastSlot)
	end
end

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
local debug_slot, debug_tid = nil, nil
local debug_attack, debug_move, debug_heal = true, true, true

local debug_attack_msg_format	= "UtilitySkill: Use %s (Slot %u) on %s (%u) - Dist %.f"
local debug_move_msg_format		= "UtilitySkill: Move to %s (%u) - Dist %.f"
local debug_heal_msg_format		= "UtilitySkill: Use %s - Slot %u - %u"

function debug_msg( tid, t, slot, name )
	if ( slot ~= nil ) then
		if ( debug_attack  and tid ~= nil ) then
			if ( debug_slot ~= slot ) then
				wt_debug( string.format( debug_attack_msg_format, tostring( name ) or "", slot, t.name or "MOB", tid, t.distance ) )
				debug_slot = slot
			end
		elseif ( debug_heal and tid == nil ) then
			if ( debug_slot ~= slot ) then
				wt_debug( string.format(  debug_heal_msg_format, tostring( name ) or "", slot, Player.health.percent ).."% health" )
				debug_slot = slot
			end
		end
		if ( debug_tid ~= tid ) then
			debug_tid = tid
		end
	else
		if ( debug_move ) then
			if ( debug_tid ~= tid ) then
				wt_debug( string.format( debug_move_msg_format, t.name or "MOB", tid, t.distance ) )
				debug_tid = tid
			end
		end
		debug_slot = nil
	end
end


--RegisterEventHandler("Gameloop.Update",UtilitySkills.OnUpdateHandler)
RegisterEventHandler("Module.Initalize",UtilitySkills.ModuleInit)
RegisterEventHandler("UtilitySkills.UtilitySkillsTOGGLE", UtilitySkills.ToggleUtilitySkills)
RegisterEventHandler("GUI.Update",UtilitySkills.GUIVarUpdate)