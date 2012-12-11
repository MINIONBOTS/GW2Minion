UtilitySkills = inheritsFrom(wt_core_state)
UtilitySkills.lastticks = 0;

function UtilitySkills.UpdateWindow()
	UtilitySkillsStatus = tostring(UtilitySkillsEnabled)
	GUI_RefreshWindow("UtilitySkills")
end

function UtilitySkills.ToggleUtilitySkills()
	UtilitySkillsEnabled = not UtilitySkillsEnabled
	UpdateWindow()  -- repaint GUI and add values
end

function UtilitySkills.ModuleInit()
	if (Settings.UtilitySkills.version == nil ) then
		Settings.UtilitySkills.version = 1.0
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
	

	
	GUI_NewWindow("UtilitySkills",Settings.UtilitySkills.x,Settings.UtilitySkills.y,Settings.UtilitySkills.width,Settings.UtilitySkills.height)
	GUI_NewCheckbox("UtilitySkills","Toggle","UtilitySkillsTOGGLE")

---[[	
	use7_enabled = Settings.UtilitySkills.use7_enabled;
	use7_incombat = Settings.UtilitySkills.use7_incombat;
	use7_hp = Settings.UtilitySkills.use7_hp;
	local s7 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_7);
	if (s7 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","7 "..tostring(s7.name),"use7_enabled");
		GUI_NewCheckbox("UtilitySkills","7     In Combat","use7_incombat");
		GUI_NewField("UtilitySkills","7     @Health %","use7_hp");
	end
	
	use8_enabled = Settings.UtilitySkills.use8_enabled;
	use8_incombat = Settings.UtilitySkills.use8_incombat;
	use8_hp = Settings.UtilitySkills.use8_hp;
	local s8 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_8);
	if (s8 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","8 "..tostring(s8.name),"use8_enabled");
		GUI_NewCheckbox("UtilitySkills","8     In Combat","use8_incombat");
		GUI_NewField("UtilitySkills","8     @Health %","use8_hp");
	end
	
	use9_enabled = Settings.UtilitySkills.use9_enabled;
	use9_incombat = Settings.UtilitySkills.use9_incombat;
	use9_hp = Settings.UtilitySkills.use9_hp;
	local s9 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_9);
	if (s9 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","9 "..tostring(s9.name),"use9_enabled");
		GUI_NewCheckbox("UtilitySkills","9     In Combat","use9_incombat");
		GUI_NewField("UtilitySkills","9     @Health %","use9_hp");
	end
	
	use10_enabled = Settings.UtilitySkills.use10_enabled;
	use10_incombat = Settings.UtilitySkills.use10_incombat;
	use10_hp = Settings.UtilitySkills.use10_hp;
	local s10 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_10);
	if (s10 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","10 "..tostring(s10.name),"use10_enabled");
		GUI_NewCheckbox("UtilitySkills","10     In Combat","use10_incombat");
		GUI_NewField("UtilitySkills","10     @Health %","use10_hp");
	end
	
	use11_enabled = Settings.UtilitySkills.use11_enabled;
	use11_incombat = Settings.UtilitySkills.use11_incombat;
	use11_hp = Settings.UtilitySkills.use11_hp;
	local s11 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_11);
	if (s11~=nil) then
		GUI_NewCheckbox("UtilitySkills","11 "..tostring(s11.name),"use11_enabled");
		GUI_NewCheckbox("UtilitySkills","11     In Combat","use11_incombat");
		GUI_NewField("UtilitySkills","11     @Health %","use11_hp");
	end
	
	use12_enabled = Settings.UtilitySkills.use12_enabled;
	use12_incombat = Settings.UtilitySkills.use12_incombat;
	use12_hp = Settings.UtilitySkills.use12_hp;
	local s12 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_12);
	if (s12 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","12 "..tostring(s12.name),"use12_enabled");
		GUI_NewCheckbox("UtilitySkills","12     In Combat","use12_incombat");
		GUI_NewField("UtilitySkills","12     @Health %","use12_hp");
	end

	use13_enabled = Settings.UtilitySkills.use13_enabled;
	use13_incombat = Settings.UtilitySkills.use13_incombat;
	use13_hp = Settings.UtilitySkills.use13_hp;
	local s13 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13);
	if (s13 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","13 "..tostring(s13.name),"use13_enabled");
		GUI_NewCheckbox("UtilitySkills","13     In Combat","use13_incombat");
		GUI_NewField("UtilitySkills","13     @Health %","use13_hp");
	end
	
	use14_enabled = Settings.UtilitySkills.use14_enabled;
	use14_incombat = Settings.UtilitySkills.use14_incombat;
	use14_hp = Settings.UtilitySkills.use14_hp;
	local s14 = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_14);
	if (s14 ~= nil) then
		GUI_NewCheckbox("UtilitySkills","14 "..tostring(s14.name),"use14_enabled");
		GUI_NewCheckbox("UtilitySkills","14     In Combat","use14_incombat");
		GUI_NewField("UtilitySkills","14     @Health %","use14_hp");
	end
	--]]
	
	-- Add to other states only after all files have been loaded
	local ke_utility_cast = wt_kelement:create("UtilityCast",UtilitySkills.c_utility_cast,UtilitySkills.e_utility_cast, 55 )
	wt_core_state_combat:add(ke_utility_cast)
	
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
end

function UtilitySkills.OnUpdateHandler( Event, ticks )
	if ( ticks - UtilitySkills.lastticks > 1000 ) then
		UtilitySkills.lastticks = ticks

		UtilitySkills.UpdateWindow()
	end
end

function UtilitySkills.GUIVarUpdate(Event,NewVals, OldVals)
	for k,v in pairs(NewVals) do
		d(tostring(k).." | "..tostring(v))
		Settings.UtilitySkills[tostring(k)] = v
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
	--Player:StopMoving()
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