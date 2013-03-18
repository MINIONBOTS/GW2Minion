-- Custom Code for Ascalonian Catacombs Dungeon, meant to be played with 4-5 bots
dungeonAC = { }
dungeonAC.currentStep = 1

------------------------------------------------------------------------------
-- Teleports the char out of the water 
local c_telewater = inheritsFrom( wt_cause )
local e_telewater = inheritsFrom( wt_effect )
function c_telewater:evaluate()
	local m = Player:GetMovementState()
	if ( m ~=nil and m == 5 or m == 6 or m == 7 or m == 8) then		
		return true
	end	
	return false
end
e_telewater.throttle = 1500
e_telewater.delay = 1500
e_telewater.ported = false
function e_telewater:execute()
	if (not e_telewater.ported) then
		wt_debug("We are in the water..porting back")	
		Player:Teleport(3809,-4740, -1060)	
		e_telewater.ported = true
	else
		wt_debug("Resync..")
		Player:SetMovement(0)
		--Player:StopMoving()
		e_telewater.ported = false
	end	
end

------------------------------------------------------------------------------
-- Opens Big chest
local c_openchest = inheritsFrom( wt_cause )
local e_openchest = inheritsFrom( wt_effect )
function c_openchest:evaluate()
	local mlist = MapMarkerList("type=405,maxdistance=1500")
		if (mlist ~= nil) then
			local i,chest = next(mlist)
			local found = false
			while (i~=nil and chest ~= nil and chest.characterID ~= nil and chest.characterID ~= 0) do
				if (Player:GetTarget() == chest.characterID or Player:SetTarget(chest.characterID)) then
					found = true
					break
				end
				i,g = next(mlist,i)
			end	
			if (found) then
				wt_debug("Chest Found...")
				return true
			end
		end
	return false
end
e_openchest.throttle = 500
function e_openchest:execute()
	local target = nil
	local targetID = nil
	local mlist = MapMarkerList("type=405,maxdistance=1500")
	if (mlist ~= nil) then
		local i,g = next(mlist)
		local found = false
		while (i~=nil and g~=nil and g.characterID ~= nil and g.characterID ~= 0) do
			if (Player:GetTarget() == g.characterID or Player:SetTarget(g.characterID)) then
				target = g
				targetID = g.characterID
				break
			end			
			i,g = next(mlist,i)
		end	
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then			
			if ( target.distance > 120 ) then                                             
				local gpos = target.pos
				Player:MoveTo( gpos.x, gpos.y, gpos.z, 50 )   
			else				
				wt_debug("OpenChest ...")
				Player:Use(targetID)
			end
		end
	end
end


------------------------------------------------------------------------------
-- Disable Trap infight
local c_disabletrap = inheritsFrom( wt_cause )
local e_disabletrap = inheritsFrom( wt_effect )
function c_disabletrap:evaluate()
	local gl = GadgetList("")
	if (gl ~= nil) then
		local i,g = next(gl)
		while (i~=nil and g~=nil) do
			if (g.health == nil and g.type == 7 and g.isselectable == 1 and g.contentID == 89683 and g.los and g.distance < 160) then
				return true
			end			
			i,g = next(gl,i)
		end			
	end
end
e_disabletrap.throttle = 1000
function e_disabletrap:execute()
	Player:PressF()
end

function dungeonAC.ModuleInit() 
	-- Registering our custom code within the wt_core_taskmanager.CustomLuaFunctions table in wt_core_taskmanager.lua	
	if (Player:GetLocalMapID() == 33) then
		if (wt_core_taskmanager ~= nil and wt_core_taskmanager.CustomLuaFunctions ~= nil) then
			wt_debug("Adding Ascalonian Catacombs functions to list")
			table.insert(wt_core_taskmanager.CustomLuaFunctions,dungeonAC.OnUpdate)
		end
		  
		local ke_tele = wt_kelement:create( "IHateWater", c_telewater, e_telewater, 400 )
		wt_core_state_minion:add( ke_tele )
		wt_core_state_leader:add( ke_tele )
		wt_core_state_combat:add( ke_tele )
		
		local ke_openchest = wt_kelement:create( "OpenChest", c_openchest, e_openchest, 390 )
		wt_core_state_minion:add( ke_openchest )
		wt_core_state_leader:add( ke_openchest )
		wt_core_state_combat:add( ke_openchest )
		
		local ke_openchest = wt_kelement:create( "DisableTrap", c_disabletrap, e_disabletrap, 380 )		
		wt_core_state_leader:add( ke_openchest )
		wt_core_state_combat:add( ke_openchest )
	end
end

function dungeonAC.OnUpdate()	
	-- Here I would do conditional checks and add my Custom Tasks to wt_core_taskmanager.Customtask_list
	if (Player:GetLocalMapID() == 33) then	
		local mlist = MapMarkerList("isevent")
		if (mlist ~= nil) then
			local i,event = next(mlist)
			if (i~=nil and event~=nil) then
				--if (TableSize(mlist) == 1) then
					wt_global_information.MaxAggroDistanceFar = 600
					--TODO: Add ReadyCheck
					if( event.eventID == 2606 and event.type == 159) then -- EventD = 1, charID=346					
						dungeonAC.Step1(event)
					elseif(event.eventID == 2607 and event.type == 159) then -- EventD = 0, charID=347					
						if ( dungeonAC.currentStep == 1 ) then
							dungeonAC.Step2OpenCoffins(event)						
						elseif ( dungeonAC.currentStep == 2) then
							dungeonAC.DeactivateTrap(event)
						elseif (dungeonAC.currentStep == 3 ) then
							dungeonAC.DeactivateTrap2(event)
						elseif (dungeonAC.currentStep == 4 ) then
							dungeonAC.OpenDoor(event)
						elseif (dungeonAC.currentStep == 5 ) then
							dungeonAC.DeactivateTrap3(event)	
						elseif (dungeonAC.currentStep == 6 ) then
							dungeonAC.KillGravelin(event)
						elseif (dungeonAC.currentStep == 7 ) then
							dungeonAC.KillBoss(event)
						end						
					--end	
				--else
					--while (i~=nil and event~=nil) do
					elseif(event.eventID == 2605 and event.type == 163) then --C,D,F = 1 						
						dungeonAC.KillBoss2(event)
						--break
					elseif(event.eventID == 2603 and event.type == 153) then --C,D,F = 1 
						dungeonAC.KillBoss3(event)							
						--break
					elseif(event.eventID == 2604 and event.type == 153) then --C,D,F = 1 
						--if ( dungeonAC.currentStep < 10) then
							dungeonAC.KillBoss4(event)
						--else
						--	dungeonAC.OpenDoor2(event)
						--end
					--break
					elseif(event.eventID == 2601 and event.type == 154) then --C,D,F = 1 
						dungeonAC.KillBoss5(event)							
						--break
					elseif(event.eventID == 2602 and event.type == 154) then --C,D,F = 1 
						dungeonAC.KillKing(event)							
						--break
					end
						--i,event = next(mlist,i)
				--end
				--end
			end
		end
	end	
end


function dungeonAC.Step1(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC Step1"
    newtask.priority = 50
    newtask.position = event.pos
    newtask.done = false
    newtask.last_execution = 0
    newtask.throttle = 500
	newtask.eventID = event.eventID
	newtask.NPC = event.characterID 
		 
    function newtask:execute()
        local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then                                             
			if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
                newtask.last_execution = wt_global_information.Now
				Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 5 )                
            end
            newtask.name = "Walking to NPC, dist: "..(math.floor(distance))
        else
            if (CharacterList:Get(newtask.NPC) ~= nil ) then				
				if ( Player:GetTarget() ~= newtask.NPC) then
					Player:SetTarget(newtask.NPC)
				elseif(not Player:IsConversationOpen() ) then
					Player:Interact( newtask.NPC )
				elseif(Player:IsConversationOpen()) then
					local options = Player:GetConversationOptions()
					nextOption, entry  = next( options )
					local chosen = false
					while ( nextOption ~= nil and entry ~=nil) do
						if( entry == 13 ) then							
							Player:SelectConversationOption( 13 )
							chosen = true
							break
						elseif( entry == 6) then						
							Player:SelectConversationOption( 6 )
							chosen = true
							break
						end
						nextOption, entry  = next( options, nextOption )
					end
					if (chosen == false) then
						newtask.done = true
					end
				end
			end
            
        end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC Step1 Added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.Step2OpenCoffins(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC Step2 Coffins"
    newtask.priority = 500
    newtask.position = { x =-10568, y =-6930, z=-1950}
    newtask.done = false
    newtask.last_execution = 0	
    newtask.throttle = 500
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 5000
	newtask.eventID = event.eventID
	
    function newtask:execute()
        local target = nil
		local targetID = nil
		local gl = GadgetList("")
		if (gl ~= nil) then
			local i,g = next(gl)
			while (i~=nil and g~=nil) do
				if (g.health ~= nil and g.type == 14 and g.isselectable == 1 and g.distance < 5000) then
					target = g
					targetID = i
					break
				end			
				i,g = next(gl,i)
			end			
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then
			newtask.waitingTmr = 0
			if ( target.distance > 120 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 70 )                
				end
				newtask.name = "Walking to target, dist: "..(math.floor(target.distance))
			else
				if ( Player:GetTarget() ~= targetID ) then
					Player:SetTarget(targetID)
				else
					wt_debug("Opening target...")
					Player:Use(targetID)
					newtask.done = true
				end
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 150) then
				if ( newtask.waitingTmr == 0 ) then
					newtask.waitingTmr = wt_global_information.Now
				elseif ( newtask.waitingTmr ~= 0 and (wt_global_information.Now - newtask.waitingTmr) > newtask.MaxwaitingTmr ) then
					dungeonAC.currentStep = 2
					newtask.done = true
				end
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC Step2 opening coffins added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.DeactivateTrap(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC DeactivateTrap"
    newtask.priority = 500
    newtask.position = { x =-8877, y =-6361, z=-1787}
    newtask.done = false
    newtask.last_execution = 0
    newtask.throttle = 500
	newtask.eventID = event.eventID
	newtask.NPC = event.characterID 
		 
    function newtask:execute()
		local target = nil
		local targetID = nil
		local gl = GadgetList("")
		if (gl ~= nil) then
			local i,g = next(gl)
			while (i~=nil and g~=nil) do
				if (g.health == nil and g.type == 14 and g.isselectable == 1 and g.contentID == 89683 and g.los) then
					target = g
					targetID = i
					break
				end			
				i,g = next(gl,i)
			end			
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then			
			if ( target.distance > 120 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 5 )                
				end
				newtask.name = "Walking to Trap, dist: "..(math.floor(target.distance))
			else
				if ( Player:GetTarget() ~= targetID ) then
					Player:SetTarget(targetID)
				else
					wt_debug("Deactivating Trap...")
					Player:Use(targetID)
					newtask.done = true
				end
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 100) then
				dungeonAC.currentStep = 3
				newtask.done = true				
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	--Set correct Prio
	local target = nil
	local targetID = nil
	local gl = GadgetList("")
	if (gl ~= nil) then
		local i,g = next(gl)
		while (i~=nil and g~=nil) do
			if (g.health == nil and g.type == 14 and g.isselectable == 1 and g.contentID == 89683 and g.los) then
				target = g
				targetID = i
				break
			end			
			i,g = next(gl,i)
		end			
	end
	if (target ~= nil and target.pos ~= nil and targetID ~= nil) then	
		newtask.priority = 10500
	end
	
	wt_debug("AC DeactivateTrap Added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.DeactivateTrap2(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC DeactivateTrap2"
    newtask.priority = 500
    newtask.position = { x =-7661, y =-4261, z=-1885}
    newtask.done = false
    newtask.last_execution = 0
    newtask.throttle = 500
	newtask.eventID = event.eventID
	newtask.NPC = event.characterID 
		 
    function newtask:execute()
		local target = nil
		local targetID = nil
		local gl = GadgetList("")
		if (gl ~= nil) then
			local i,g = next(gl)
			while (i~=nil and g~=nil) do
				if (g.health == nil and g.type == 7 and g.isselectable == 1 and g.contentID == 89683 and g.los == true) then
					target = g
					targetID = i
					break
				end			
				i,g = next(gl,i)
			end			
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then			
			if ( target.distance > 1200 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 5 )                
				end
				newtask.name = "Walking to Trap, dist: "..(math.floor(target.distance))
			elseif ( target.distance < 1200 and target.distance > 120) then
					local gpos = target.pos
					Player:Teleport(gpos.x, gpos.y, gpos.z)
					Player:SetMovement(0)
					--Player:StopMoving()
					Player:Use(targetID)
					Player:PressF()
			elseif( target.distance < 120 ) then
				if ( Player:GetTarget() ~= targetID ) then
					Player:SetTarget(targetID)
				else
					wt_debug("Deactivating Trap...")
					Player:Use(targetID)
					Player:PressF()
					newtask.done = true
				end
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 100) then
				dungeonAC.currentStep = 4
				Player:PressF()
				newtask.done = true				
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	--Set correct Prio
	local gl = GadgetList("")
	if (gl ~= nil) then
		local i,g = next(gl)
		while (i~=nil and g~=nil) do
			if (g.health == nil and g.type == 7 and g.isselectable == 1 and g.contentID == 89683 and g.los == true and g.distance < 1500) then
				newtask.priority = 10500
				break
			end			
			i,g = next(gl,i)
		end			
	end
	
	wt_debug("AC DeactivateTrap2 Added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.OpenDoor(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC Open Door"
    newtask.priority = 500
    newtask.Boulderposition1 = { x =-7508, y =-4703, z=-1815}
	newtask.Boulderposition2 = { x =-8156, y =-4186, z=-1891}
	newtask.Platepos = { x =-6373, y =-6500, z=-1263}
    newtask.done = false
    newtask.last_execution = 0	
    newtask.throttle = 500
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 5000
	newtask.eventID = event.eventID
	
    function newtask:execute()		
		if (Player:GetSpellInfo(5).contentID == 206731) then
			--We have a boulder
			local mypos = Player.pos
			local distance =  Distance3D( newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 15 ) then
				Player:SwapWeaponSet()
				dungeonAC.currentStep = 5
				newtask.done = true	
			elseif ( distance < 15 ) then
				Player:StopMoving()
				--Player:Teleport(newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z)							
			else
				Player:MoveTo( newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z, 5 )
			end
		else
			--We need a boulder
			local mypos = Player.pos
			local distance =  Distance3D( newtask.Boulderposition1.x, newtask.Boulderposition1.y, newtask.Boulderposition1.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 25 ) then
				local boulder = Player:GetInteractableTarget()
				if (boulder ~= nil and CharacterList:Get(boulder) == nil) then
					Player:PressF()					
				end
			else
				Player:MoveTo( newtask.Boulderposition1.x, newtask.Boulderposition1.y, newtask.Boulderposition1.z, 5 )
			end
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC Open Doors added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.DeactivateTrap3(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC DeactivateTrap3"
    newtask.priority = 500
    newtask.position = { x =-4697, y =-4782, z=-1116}
    newtask.done = false
    newtask.last_execution = 0
    newtask.throttle = 500
	newtask.eventID = event.eventID
	newtask.NPC = event.characterID 
		 
    function newtask:execute()
		local target = nil
		local targetID = nil
		local gl = GadgetList("")
		if (gl ~= nil) then
			local i,g = next(gl)
			while (i~=nil and g~=nil) do
				if (g.health == nil and g.type == 7 and g.isselectable == 1 and g.contentID == 89683 and g.los) then
					target = g
					targetID = i
					break
				end			
				i,g = next(gl,i)
			end			
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then			
			if ( target.distance > 1200 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 5 )                
				end
				newtask.name = "Walking to Trap, dist: "..(math.floor(target.distance))
			elseif ( target.distance < 1200 and target.distance > 120) then
					local gpos = target.pos
					Player:Teleport(gpos.x, gpos.y, gpos.z)
					Player:SetMovement(0)
					Player:StopMoving()
					Player:PressF()
			elseif( target.distance < 120 ) then
				if ( Player:GetTarget() ~= targetID ) then
					Player:SetTarget(targetID)
				else
					wt_debug("Deactivating Trap 3...")
					Player:Use(targetID)
					Player:PressF()
					newtask.done = true
				end
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 100) then
				dungeonAC.currentStep = 6
				Player:PressF()
				newtask.done = true				
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	--Set correct Prio
	local gl = GadgetList("")
	if (gl ~= nil) then
		local i,g = next(gl)
		while (i~=nil and g~=nil) do
			if (g.health == nil and g.type == 7 and g.isselectable == 1 and g.contentID == 89683 and g.los) then
				newtask.priority = 10500
				break
			end			
			i,g = next(gl,i)
		end			
	end
	
	wt_debug("AC DeactivateTrap3 Added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillGravelin(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillGravelin"
    newtask.priority = 500
    newtask.position = { x =-1897, y =-6828, z=-468}	
    newtask.done = false
    newtask.last_execution = 0	
    newtask.throttle = 500
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 5000
	newtask.eventID = event.eventID
	
    function newtask:execute()
       local target = nil
		local targetID = nil
		local gl = GadgetList("")
		if (gl ~= nil) then
			local i,g = next(gl)
			while (i~=nil and g~=nil) do
				if (g.health ~= nil and g.type == 1 ) then
					target = g
					targetID = i
					break
				end			
				i,g = next(gl,i)
			end			
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil and target.health ~=nil and target.health.current > 0) then			
			if ( target.distance > 120 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 75 )                
				end
				newtask.name = "Walking to Burrow, dist: "..(math.floor(target.distance))
			else
				--Kill this burrow thing..somehow..
				if (Player:GetTarget() ~= targetID) then
					Player:SetTarget(targetID)
				else
					Player:CastSpell(GW2.SKILLBARSLOT.Slot_1)
				end
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 75 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 100) then
				dungeonAC.currentStep = 7
				newtask.done = true				
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    
	--Set correct Prio
	local gl = GadgetList("")
	if (gl ~= nil) then
		local i,g = next(gl)
		while (i~=nil and g~=nil) do
			if (g.health ~= nil and g.type == 1 and g.pos ~=nil and g.distance < 1200) then
				newtask.priority = 10500
				break
			end			
			i,g = next(gl,i)
		end			
	end
	
	wt_debug("AC KillGravelin added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillBoss(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillBoss"
    newtask.priority = 500
    newtask.position = { x =1755, y =-5192, z=-1051}	
    newtask.done = false
    newtask.last_execution = 0	
    newtask.throttle = 500
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 5000
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then                                             
			if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
                newtask.last_execution = wt_global_information.Now
				Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )                
            end
            newtask.name = "Walking to Boss, dist: "..(math.floor(distance))
		else
			newtask.done = true
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC KillBoss added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillBoss2(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillBoss2"
    newtask.priority = 600
    newtask.position = { x =3832, y =-2534, z=-1710}		
    newtask.done = false
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then 
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )  
            newtask.name = "Walking to Boss2, dist: "..(math.floor(distance))
		else
			newtask.done = true
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC KillBoss2 added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.OpenChest(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC OpenChest"
    newtask.priority = 1000
    newtask.position = { x =3895, y =-2129, z=-1730}
    newtask.done = false
    newtask.last_execution = 0
    newtask.throttle = 500
	newtask.eventID = event.eventID
	newtask.NPC = event.characterID 
		 
    function newtask:execute()
		local target = nil
		local targetID = nil
		local mlist = MapMarkerList("type=405,maxdistance=1500")
		if (mlist ~= nil) then
			local i,g = next(mlist)
			while (i~=nil and g~=nil and g.characterID ~= nil and g.characterID ~= 0) do
				if (Player:GetTarget() == g.characterID or Player:SetTarget(g.characterID)) then
					target = g
					targetID = g.characterID
					break
				end			
				i,g = next(mlist,i)
			end
		end
		if (target ~= nil and target.pos ~= nil and targetID ~= nil) then			
			if ( target.distance > 120 ) then                                             
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					newtask.last_execution = wt_global_information.Now
					local gpos = target.pos
					Player:MoveTo( gpos.x, gpos.y, gpos.z, 5 )                
				end
				newtask.name = "Walking to Chest, dist: "..(math.floor(target.distance))
			else
				wt_debug("OpenChest ...")
				Player:Use(targetID)
				dungeonAC.currentStep = 8
				newtask.done = true
			end
		else
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 100) then
				Player:PressF()
				dungeonAC.currentStep = 8
				newtask.done = true				
			end
		end		
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end 
	wt_debug("AC OpenChest Added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillBoss3(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillBoss3"
    newtask.priority = 700
    newtask.position = { x =13181, y =-2068, z=-776}	
    newtask.done = false
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 30000
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then                                             
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 ) 
            newtask.name = "Walking to Boss, dist: "..(math.floor(distance))
		else
			if (newtask.waitingTmr == 0) then
				newtask.waitingTmr = wt_global_information.Now
			elseif ( (wt_global_information.Now - newtask.waitingTmr) > newtask.MaxwaitingTmr ) then                
				newtask.done = true               
            end
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC KillBoss3 added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.OpenDoor2(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC Open 2 Door"
    newtask.priority = 700
    newtask.Boulderposition1 = { x =12551, y =-484, z=-950}
	newtask.Platepos = { x =13750, y =-642, z=-952}
    newtask.done = false
    newtask.last_execution = 0	
    newtask.throttle = 500
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 5000
	newtask.eventID = event.eventID
	
    function newtask:execute()		
		if (Player:GetSpellInfo(5).contentID == 206731) then
			--We have a boulder
			local mypos = Player.pos
			local distance =  Distance3D( newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 15 ) then
				Player:SwapWeaponSet()				
				newtask.done = true	
			elseif ( distance < 15 ) then
				Player:StopMoving()
				--Player:Teleport(newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z)							
			else
				Player:MoveTo( newtask.Platepos.x, newtask.Platepos.y, newtask.Platepos.z, 5 )
			end
		else
			--We need a boulder
			local mypos = Player.pos
			local distance =  Distance3D( newtask.Boulderposition1.x, newtask.Boulderposition1.y, newtask.Boulderposition1.z, mypos.x, mypos.y, mypos.z )
			if ( distance < 25 ) then
				local boulder = Player:GetInteractableTarget()
				if (boulder ~= nil and CharacterList:Get(boulder) == nil) then
					Player:PressF()					
				end
			else
				Player:MoveTo( newtask.Boulderposition1.x, newtask.Boulderposition1.y, newtask.Boulderposition1.z, 5 )
			end
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC Open Door 2 added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillBoss4(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillBoss4"
    newtask.priority = 950
    newtask.position = { x =13075, y =3397, z=-1280}	
    newtask.done = false
	newtask.waitingTmr = 0
	newtask.MaxwaitingTmr = 30000
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then 
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )                
            newtask.name = "Walking to Boss 4, dist: "..(math.floor(distance))
		else
			if (newtask.waitingTmr == 0) then
				newtask.waitingTmr = wt_global_information.Now
			elseif ( (wt_global_information.Now - newtask.waitingTmr) > newtask.MaxwaitingTmr ) then                
				wt_debug("Waited 30seconds...continuing..")
				newtask.done = true 
				dungeonAC.currentStep = 10
            end			
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC KillBoss4 added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillBoss5(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC KillBoss5" -- Nente
    newtask.priority = 950
    newtask.position2 = event.pos
	newtask.position = { x =-1365, y =-3447, z=-1680}	
    newtask.done = false
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
		local distanceBoss =  Distance3D( newtask.position2.x, newtask.position2.y, newtask.position2.z, mypos.x, mypos.y, mypos.z )
        if (distanceBoss < 950 and distanceBoss > 160) then
			Player:Teleport(newtask.position2.x, newtask.position2.y, newtask.position2.z)
			Player:SetMovement(0)
			Player:StopMoving()
			newtask.done = true
		elseif ( distance > 120 ) then                                             
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
            newtask.name = "Walking to Boss 5, dist: "..(math.floor(distance))
		elseif ( distance < 120 ) then
			newtask.done = true
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC KillBoss5 added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

function dungeonAC.KillKing(event)
	local newtask = inheritsFrom( wt_task )
    newtask.name = "AC Kill King"
    newtask.priority = 950
    newtask.position = event.pos	
    newtask.done = false
	newtask.eventID = event.eventID
	
    function newtask:execute()
		local mypos = Player.pos
        local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
        if ( distance > 120 ) then
			Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
            newtask.name = "Walking to King , dist: "..(math.floor(distance))
		else
			newtask.done = true
		end
	end
		 
    function newtask:isFinished()
		if ( newtask.done ) then
			return true
		end
		return false
	end    

	wt_debug("AC Kill King added..")
	wt_core_taskmanager:addCustomtask( newtask )
end

RegisterEventHandler("Module.Initalize",dungeonAC.ModuleInit)
