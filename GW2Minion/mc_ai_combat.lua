mc_ai_combat = {}
mc_ai_combat.combatMoveTmr = 0
mc_ai_combat.combatEvadeTmr = 0
mc_ai_combat.combatEvadeLastHP = 0

-- Attack Task
mc_ai_combatAttack = inheritsFrom(ml_task)
mc_ai_combatAttack.name = "CombatAttack"
function mc_ai_combatAttack.Create()
    --ml_log("combatAttack:Create")
	local newinst = inheritsFrom(mc_ai_combatAttack)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
	newinst.duration = mc_global.now + math.random(60000,240000)
	
    return newinst
end
function mc_ai_combatAttack:Init()
   -- ml_log("combatAttack_Init->")
	
	-- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 225 ), self.process_elements)
	
	-- Downed
	self:add(ml_element:create( "Downed", c_downed, e_downed, 200 ), self.process_elements)
	
	-- AoELooting Characters
	self:add(ml_element:create( "AoELoot", c_AoELoot, e_AoELoot, 175 ), self.process_elements)
		
	-- AoELooting Gadgets/Chests needed ?
		
	-- Partymember Downed/Dead
	self:add(ml_element:create( "RevivePartyMember", c_memberdown, e_memberdown, 172 ), self.process_elements)	
	
	-- Revive Players
	self:add(ml_element:create( "RevivePlayer", c_reviveDownedPlayersInCombat, e_reviveDownedPlayersInCombat, 170 ), self.process_elements)
		
	-- Aggro
	self:add(ml_element:create( "Aggro", c_Aggro, e_Aggro, 165 ), self.process_elements) --reactive queue
			
	-- Dont Dive lol
	self:add(ml_element:create( "SwimUP", c_SwimUp, e_SwimUp, 160 ), self.process_elements)
	
	-- Normal Chests	
	self:add(ml_element:create( "LootingChest", c_LootChests, e_LootChests, 155 ), self.process_elements)
		
	-- Resting
	self:add(ml_element:create( "Resting", c_resting, e_resting, 145 ), self.process_elements)	

	-- Normal Looting
	self:add(ml_element:create( "Looting", c_LootCheck, e_LootCheck, 130 ), self.process_elements) --reactive queue

	-- Deposit Items
	self:add(ml_element:create( "DepositingItems", c_deposit, e_deposit, 120 ), self.process_elements)	
	
	-- Re-Equip Gathering Tools
	self:add(ml_element:create( "EquippingGatherTool", c_GatherToolsCheck, e_GatherToolsCheck, 110 ), self.process_elements)	
	
	-- Salvaging
	self:add(ml_element:create( "Salvaging", c_salvage, e_salvage, 105 ), self.process_elements)
	
	-- Quick-Repair & Vendoring (when a vendor is nearby)	
	self:add(ml_element:create( "QuickSellItems", c_quickvendorsell, e_quickvendorsell, 100 ), self.process_elements)
	self:add(ml_element:create( "QuickBuyItems", c_quickbuy, e_quickbuy, 99 ), self.process_elements)
	self:add(ml_element:create( "QuickRepairItems", c_quickrepair, e_quickrepair, 98 ), self.process_elements)
	
	-- Repair & Vendoring
	self:add(ml_element:create( "SellItems", c_vendorsell, e_vendorsell, 90 ), self.process_elements)	
	self:add(ml_element:create( "BuyItems", c_vendorbuy, e_vendorbuy, 89 ), self.process_elements)
	self:add(ml_element:create( "RepairItems", c_vendorrepair, e_vendorrepair, 88 ), self.process_elements)

	-- DoEvents
	self:add(ml_element:create( "DoEvent", c_doEvents, e_doEvents, 72 ), self.process_elements)
		
	-- ReviveNPCs
	self:add(ml_element:create( "ReviveNPC", c_reviveNPC, e_reviveNPC, 70 ), self.process_elements)	
	
	-- Gathering
	--self:add(ml_element:create( "Gathering", c_Gathering, e_Gathering, 65 ), self.process_elements)
	self:add(ml_element:create( "Gathering", c_gatherTask, e_gatherTask, 65 ), self.process_elements)
	
	
	-- Finish Enemy
	self:add(ml_element:create( "FinishHim", c_FinishHim, e_FinishHim, 60 ), self.process_elements)
	-- Killsomething nearby					
	-- Valid Target
	self:add(ml_element:create( "SearchingTarget", c_NeedValidTarget, e_SearchTarget, 50 ), self.process_elements)
		
	-- Get into Combat Range
	self:add(ml_element:create( "MovingIntoCombatRange", c_MoveIntoCombatRange, e_MoveIntoCombatRange, 25 ), self.process_elements)
	
	-- Kill Target
	self:add(ml_element:create( "KillTarget", c_KillTarget, e_KillTarget, 10 ), self.process_elements)
		
	
    self:AddTaskCheckCEs()
end
function mc_ai_combatAttack:task_complete_eval()	
	if ( Player.swimming ~= 0 or mc_global.now - self.duration > 0 or TableSize(CharacterList("attackable,alive,nearest,onmesh,maxdistance=3500,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters")))) == 0) then 
		Player:StopMovement()
		return true
	end
	return false
end
function mc_ai_combatAttack:task_complete_execute()
   self.completed = true
end


------------
c_Aggro = inheritsFrom( ml_cause )
e_Aggro = inheritsFrom( ml_effect )
function c_Aggro:evaluate()
   -- ml_log("c_Aggro")
    return Player.swimming == 0 and TableSize(CharacterList("nearest,alive,aggro,attackable,maxdistance=1200,onmesh")) > 0 and ( Inventory.freeSlotCount > 0 or ( Inventory.freeSlotCount == 0 and not mc_ai_vendor.NeedToSell() or TableSize(mc_ai_vendor.GetClosestVendorMarker()) == 0 ))
end
function e_Aggro:execute()
	ml_log("e_Aggro ")
	Player:StopMovement()
	local newTask = mc_ai_combatDefend.Create()
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
end

c_AggroEx = inheritsFrom( ml_cause )
e_AggroEx = inheritsFrom( ml_effect )
c_AggroEx.threshold = 80
function c_AggroEx:evaluate()
    return Player.swimming == 0 and Player.health.percent < c_AggroEx.threshold and TableSize(CharacterList("nearest,alive,aggro,attackable,maxdistance=1200,onmesh")) > 0 and ( Inventory.freeSlotCount > 0 or ( Inventory.freeSlotCount == 0 and not mc_ai_vendor.NeedToSell() or TableSize(mc_ai_vendor.GetClosestVendorMarker()) == 0 ))
end
function e_AggroEx:execute()
	ml_log("e_AggroEx ")
	c_AggroEx.threshold = math.random(70,100)
	Player:StopMovement()
	local newTask = mc_ai_combatDefend.Create()
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
end


c_SwimUp = inheritsFrom( ml_cause )
e_SwimUp = inheritsFrom( ml_effect )
function c_SwimUp:evaluate()
	local pPos = Player.pos	
	return pPos ~= nil and pPos.z > 60 and Player.swimming == 1
end
function e_SwimUp:execute()
	ml_log("e_SwimUp ")
	Player:SetMovement(10)
end

-- attempt to destroy path-blocking gadgets like doors n stuff while moving
c_DestroyGadget = inheritsFrom( ml_cause )
e_DestroyGadget = inheritsFrom( ml_effect )
function c_DestroyGadget:evaluate()
	if ( Player.swimming == 0 and (mc_ai_unstuck.stuckcounter > 0 or mc_ai_unstuck.stuckcounter2 > 0) )then
		local GList =  GadgetList("nearest,attackable,alive,onmesh,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters")))
		if ( TableSize(GList) > 0 ) then
			local id,gadget = next(GList)		
			if ( gadget and gadget.distance < 200 + gadget.radius ) then
				return true
			end
		end
	end
	return false
end
function e_DestroyGadget:execute()
	local TList = GadgetList("nearest,attackable,alive,onmesh,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters")))
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("Found Blocking Gadget Target: "..(E.name).." ID:"..tostring(id))			
			if ( E.selectable ) then 			
				
				if ( E.distance < 150 + E.radius) then
					Player:StopMovement()
				end
				Player:SetTarget(id)
				local pos = E.pos					
				if ( pos ) then
					Player:SetFacing(pos.x,pos.y,pos.z)
					if ( E.distance < 450 + E.radius and Player:CanCast() ) then
						Player:CastSpell(GW2.SKILLBARSLOT.Slot_1)
					end
					mc_skillmanager.AttackTarget( E.id )
					return ml_log(true)
				end				
			end
		end		
	end
	return ml_log(" Cant destroy Gadget! ")
end

e_SearchTarget = inheritsFrom( ml_effect )
e_SearchTarget.lastID = 0
e_SearchTarget.count = 0
function e_SearchTarget:execute()
	ml_log("e_SearchTarget")
	-- Weakest Aggro in CombatRange first	
	local TList = ( CharacterList("lowesthealth,attackable,alive,aggro,onmesh,maxdistance="..mc_global.AttackRange) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			--d("Found Aggro Target: "..(E.name).." ID:"..tostring(id))
			return ml_log(Player:SetTarget(id))			
		end		
	end
	
	-- Then nearest attackable Gadget
	local TList = ( GadgetList("nearest,attackable,alive,onmesh,maxdistance="..mc_global.AttackRange..",exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters"))) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("Found Gadget Target: "..(E.name).." ID:"..tostring(id))
			return ml_log(Player:SetTarget(id))			
		end		
	end
	
	-- Then nearest attackable Target
	TList = ( CharacterList("attackable,alive,nearest,onmesh,maxdistance=3500,exclude_contentid="..mc_blacklist.GetExcludeString(GetString("monsters"))))
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("New Target: "..(E.name).." ID:"..tostring(id))
			
			-- Blacklist if we cant select it..happens sometimes when it is outside our select range
			if (e_SearchTarget.lastID == id ) then
				e_SearchTarget.count = e_SearchTarget.count+1
				if ( e_SearchTarget.count > 30 ) then
					e_SearchTarget.count = 0
					e_SearchTarget.lastID = 0
					mc_blacklist.AddBlacklistEntry(GetString("monsters"), E.contentID, E.name, mc_global.now + 60000)
					d("Seems we cant select/target/reach our target, blacklisting it for 60seconds..")
				end
			else
				e_SearchTarget.lastID = id
				e_SearchTarget.count = 0
			end
			
			return ml_log(Player:SetTarget(id))
		end		
	end
	return ml_log(false)
end

-- Finish downed enemies
c_FinishHim = inheritsFrom( ml_cause )
e_FinishHim = inheritsFrom( ml_effect )
e_FinishHim.tmr = 0
e_FinishHim.threshold = 2000
function c_FinishHim:evaluate()
    return Player.swimming == 0 and Player.health.percent > 15 and TableSize(CharacterList("nearest,downed,aggro,attackable,maxdistance=1200,onmesh")) > 0
end
function e_FinishHim:execute()
	ml_log("e_FinishHim")
	local EList = CharacterList("nearest,downed,aggro,attackable,maxdistance=1200,onmesh")
	if ( EList ) then
		local id,entity = next (EList)
		if ( id and entity ) then
			
			if (not entity.isInInteractRange) then
				-- MoveIntoInteractRange
				local tPos = entity.pos
				if ( tPos ) then
					if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
					MoveOnlyStraightForward()
					local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
					if (tonumber(navResult) < 0) then
						d("e_FinishHim.MoveIntoCombatRange result: "..tonumber(navResult))					
					end
					
					if ( mc_global.now - e_FinishHim.tmr > e_FinishHim.threshold ) then
						e_FinishHim.tmr = mc_global.now
						e_FinishHim.threshold = math.random(1500,5000)
						mc_skillmanager.HealMe()
					end
					ml_log("MoveTo_FinishHim..")
					return true
				end
			else
				-- Grab that thing
				Player:StopMovement()
				local t = Player:GetTarget()
				if ( entity.selectable and (not t or t.id ~= id )) then
					Player:SetTarget( id )
				else
					
					if (Player.profession == 8 ) then -- Necro, leave shroud
						local deathshroud = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
						if ( deathshroud ~= nil and deathshroud.skillID == 10585 and Player:CanCast() and Player:GetCurrentlyCastedSpell() == 17) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
							mc_global.Wait(500)
							return
						end
					end
					
					-- yeah I know, but this usually doesnt break ;)
					if ( Player:GetCurrentlyCastedSpell() == 17 ) then	
						Player:Interact( id )
						ml_log("Finishing..")						
						mc_global.Wait(1000)
						return true
					end	
				end			
			end
		end
	end
	return ml_log(false)
end




-- Defend Against Aggro Task
mc_ai_combatDefend = inheritsFrom(ml_task)
mc_ai_combatDefend.name = "CombatDefend"
function mc_ai_combatDefend.Create()    
	local newinst = inheritsFrom(mc_ai_combatDefend)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
	
    return newinst
end
function mc_ai_combatDefend:Init()
    ml_log("combatDef:Init->")
    
    -- Dead?
	self:add(ml_element:create( "Dead", c_dead, e_dead, 225 ), self.process_elements)
	
	-- Downed
	self:add(ml_element:create( "Downed", c_downed, e_downed, 200 ), self.process_elements)
	
	-- AoELooting Characters
	self:add(ml_element:create( "AoELoot", c_AoELoot, e_AoELoot, 125 ), self.process_elements)
		
	-- AoELooting Gadgets/Chests needed
	
	-- Partymember Downed/Dead
	self:add(ml_element:create( "RevivePartyMember", c_memberdown, e_memberdown, 122 ), self.process_elements)
	
	-- Revive Players
	self:add(ml_element:create( "RevivePlayer", c_reviveDownedPlayersInCombat, e_reviveDownedPlayersInCombat, 120 ), self.process_elements)
	    
	-- Deposit Items
	self:add(ml_element:create( "DepositingItems", c_deposit, e_deposit, 90 ), self.process_elements)	
	
	-- Dont Dive lol
	self:add(ml_element:create( "SwimUP", c_SwimUp, e_SwimUp, 80 ), self.process_elements)
	
	-- Finish Enemy
	self:add(ml_element:create( "FinishHim", c_FinishHim, e_FinishHim, 70 ), self.process_elements)
	
	-- Valid Target
	self:add(ml_element:create( "NeedValidTarget", c_NeedValidTarget, e_SetAggroTarget, 60 ), self.process_elements)
		
	-- Get into Combat Range
	self:add(ml_element:create( "MovingIntoCombatRange", c_MoveIntoCombatRange, e_MoveIntoCombatRange, 50 ), self.process_elements)
	
	-- Kill Target
	self:add(ml_element:create( "MovingIntoCombatRange", c_KillTarget, e_KillTarget, 25 ), self.process_elements)
		
  
    self:AddTaskCheckCEs()
end
function mc_ai_combatDefend:task_complete_eval()
	--ml_log("combatDefend:Complete?->")
	if ( Player.swimming ~= 0 or TableSize(CharacterList("nearest,alive,aggro,attackable,maxdistance=1200,onmesh"))== 0) then 
		Player:StopMovement()
		return true
	end
	return false
end

function mc_ai_combatDefend:task_complete_execute()
   self.completed = true
end


c_NeedValidTarget = inheritsFrom( ml_cause )
e_SetAggroTarget = inheritsFrom( ml_effect )
function c_NeedValidTarget:evaluate()
   -- ml_log("c_NeedValidTarget")
	local target = Player:GetTarget()
	if ( TableSize( target ) > 0 ) then	
		--d("NeedValidTarget "..tostring(not target.alive and not target.attackable and not target.onmesh))
		return (Player.swimming == 0 and not target.alive or not target.attackable or not target.onmesh)
	end	
	return true
end
function e_SetAggroTarget:execute()
	ml_log("e_SetAggroTarget")
	
	-- lowesthealth in CombatRange first	
	local TList = ( CharacterList("lowesthealth,attackable,alive,aggro,onmesh,maxdistance="..mc_global.AttackRange) )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("New Aggro Target: "..tostring(E.name).." ID:"..tostring(id))
			Player:SetTarget(id)
			return ml_log(true)	
		end		
	end
		
	-- Then nearest Aggro Target
	TList = ( CharacterList("attackable,alive,aggro,nearest,onmesh") )
	if ( TableSize( TList ) > 0 ) then
		local id, E  = next( TList )
		if ( id ~= nil and id ~= 0 and E ~= nil ) then
			d("New Aggro Target: "..tostring(E.name).." ID:"..tostring(id))
			Player:SetTarget(id)
			return ml_log(true)	
		end		
	end
	
	return ml_log(false)
end

c_MoveIntoCombatRange = inheritsFrom( ml_cause )
e_MoveIntoCombatRange = inheritsFrom( ml_effect )
c_MoveIntoCombatRange.running = false
function c_MoveIntoCombatRange:evaluate()
    --ml_log("c_MoveIntoCombRng")
    local t = Player:GetTarget()
	if ( t and Player.swimming == 0 ) then		
		if (t.distance >= mc_global.AttackRange or (t.isCharacter and not t.los) or (t.isGadget and not t.los and t.distance > mc_global.AttackRange) or (t.isGadget and not t.los and t.distance > 350)) then
			return true
		else
			if ( c_MoveIntoCombatRange.running ) then 
				c_MoveIntoCombatRange.running = false
				Player:StopMovement()
			end
		end
	end
	return false
end

e_MoveIntoCombatRange.tmr = 0
e_MoveIntoCombatRange.threshold = 2000
function e_MoveIntoCombatRange:execute()
	ml_log("e_MoveIntoCombRng")
	local t = Player:GetTarget()
	if ( t ) then	
		if ( t.distance >= mc_global.AttackRange or not t.los)then
			local tPos = t.pos
			-- moveto(x,y,z,stoppingdistance,navsystem(normal/follow),navpath(straight/random),smoothturns)		
			if ( tPos ) then
				--d("MoveIntoCombatRange..Running")
				if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
				MoveOnlyStraightForward()
				local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,100+t.radius,false,false,true))		
				if (tonumber(navResult) < 0) then					
					d("mc_ai_combat.MoveIntoCombatRange result: "..tonumber(navResult))					
				end
				
				if ( mc_global.now - e_MoveIntoCombatRange.tmr > e_MoveIntoCombatRange.threshold ) then
					e_MoveIntoCombatRange.tmr = mc_global.now
					e_MoveIntoCombatRange.threshold = math.random(1000,5000)
					mc_skillmanager.HealMe()
				end	
				c_MoveIntoCombatRange.running = true
				return true
			end
		end
	end	
	return ml_log(false)
end


c_KillTarget = inheritsFrom( ml_cause )
e_KillTarget = inheritsFrom( ml_effect )
e_KillTarget.lastID = 0
e_KillTarget.lastHP = 0
e_KillTarget.Tmr = 0
function c_KillTarget()
	return Player.swimming == 0
end
function e_KillTarget:execute()
	ml_log("e_KillTarget")
	local t = Player:GetTarget()
	if ( t and t.alive and t.attackable) then
		local pos = t.pos
		if ( pos ) then
			Player:SetFacing(pos.x,pos.y,pos.z)
			mc_skillmanager.AttackTarget( t.id )
			
			DoCombatMovement()
			
			-- Check for determined/unkillable targets
			if ( e_KillTarget.lastID ~= t.id ) then
				e_KillTarget.lastID = t.id
			else
				if ( mc_global.now - e_KillTarget.Tmr > 5000 ) then
					e_KillTarget.Tmr = mc_global.now
					if ( e_KillTarget.lastHP ~= t.health.current ) then
						e_KillTarget.lastHP = t.health.current
					else
						local tbuffs = t.buffs
						if ( mc_helper.BufflistHasBuffs(tbuffs, "762") == true) then-- determined
							d("Enemy has determined buff, blacklisting it for 15min")
							mc_blacklist.AddBlacklistEntry(GetString("monsters"), t.contentID, t.name, mc_global.now + 900000)							
						end
					end
				end
			end
			
			return ml_log(true)
		end
	else
		Player:StopMovement()		 
	end	
	return ml_log(false)
end


c_resting = inheritsFrom( ml_cause )
e_resting = inheritsFrom( ml_effect )
c_resting.hpPercent = math.random(45,85)
function c_resting:evaluate()
	if ( Player.swimming == 0 and Player.inCombat == false and Player.health.percent < c_resting.hpPercent ) then		
		local mybuffs = Player.buffs
		return not mc_helper.BufflistHasBuffs(mybuffs, "737,723,736") --burning,poison,bleeding		
	end	
	return false
end
function e_resting:execute()
	ml_log("e_resting")
	c_resting.hpPercent = math.random(45,85)
	if (Player.profession == 8 ) then -- Necro, leave shroud
		local deathshroud = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
		if ( deathshroud ~= nil and deathshroud.skillID == 10585 and Player:CanCast() and Player:GetCurrentlyCastedSpell() == 17) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
			mc_global.Wait(500)
			return
		end
	end
	
	if ( Player:IsMoving() ) then
		Player:StopMovement()
	end
	
	-- check Skillmanager if he can heal first
	if not mc_skillmanager.HealMe() then
	
		-- else cast our normal heal skill if possible
		local s6 = Player:GetSpellInfo( GW2.SKILLBARSLOT.Slot_6 )
		if( s6 and Player:GetCurrentlyCastedSpell() == 17 and s6.cooldown == 0 ) then
			Player:CastSpell( GW2.SKILLBARSLOT.Slot_6 )
			mc_global.Wait(750)
		end		
	end
	return
end


-- Revive Task
mc_ai_combatRevive = inheritsFrom(ml_task)
mc_ai_combatRevive.name = "CombatRevive"
function mc_ai_combatRevive.Create()
    --ml_log("combatAttack:Create")
	local newinst = inheritsFrom(mc_ai_combatRevive)
    
    --ml_task members
    newinst.valid = true
    newinst.completed = false
    newinst.subtask = nil
    newinst.process_elements = {}
    newinst.overwatch_elements = {} 
	newinst.targetID = 0
    return newinst
end
function mc_ai_combatRevive:Init()
	
	-- ReviveNPCs
	self:add(ml_element:create( "ReviveNPC", c_revive, e_revive, 70 ), self.process_elements)	
		
    self:AddTaskCheckCEs()
end
function mc_ai_combatRevive:task_complete_eval()
	if ( c_dead:evaluate() or c_downed:evaluate() or c_AggroEx:evaluate() or ml_task_hub:CurrentTask().targetID == 0 or CharacterList:Get(ml_task_hub:CurrentTask().targetID) == nil or CharacterList:Get(ml_task_hub:CurrentTask().targetID).alive == true ) then 
		Player:StopMovement()
		return true
	end
	return false
end
function mc_ai_combatRevive:task_complete_execute()
   self.completed = true
end

------------
c_reviveNPC = inheritsFrom( ml_cause )
e_reviveNPC = inheritsFrom( ml_effect )
function c_reviveNPC:evaluate()
   -- ml_log("c_reviveNPC")
    return (gRevive == "1" and not Player.inCombat and c_AggroEx:evaluate() == false and TableSize(CharacterList("shortestpath,selectable,interactable,dead,friendly,npc,onmesh,maxdistance=2500,exclude="..mc_blacklist.GetExcludeString(GetString("monsters")))) > 0)
end
function e_reviveNPC:execute()
	ml_log("e_reviveNPC")
	local CList = CharacterList("shortestpath,selectable,interactable,dead,friendly,npc,onmesh,maxdistance=2500,exclude="..mc_blacklist.GetExcludeString(GetString("monsters")))
	if ( TableSize(CList) > 0 ) then
		local id,e = next(CList)
		if ( id and e ) then
			Player:StopMovement()
			local newTask = mc_ai_combatRevive.Create()	
			newTask.targetID = id
			ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)
			return ml_log(true)
		end
	end
	return ml_log(false)
end

------------
c_revive = inheritsFrom( ml_cause )
e_revive = inheritsFrom( ml_effect )
function c_revive:evaluate()
    return true
end
e_revive.lastID = 0
e_revive.counter = 0
function e_revive:execute()
	ml_log("e_revive")
	local id = nil
	local entity = nil
	
	if ( ml_task_hub:CurrentTask().targetID ~= nil and ml_task_hub:CurrentTask().targetID > 0 ) then 
		entity = CharacterList:Get(ml_task_hub:CurrentTask().targetID)
		if ( entity == nil ) then
			local CharList = CharacterList("shortestpath,selectable,interactable,dead,friendly,npc,onmesh,exclude="..mc_blacklist.GetExcludeString(GetString("monsters")))
			if ( TableSize(CharList) > 0 ) then
				id,entity = next (CharList)			
			end
		else
			id = entity.id
		end
	end
	
	
	if ( id and entity ) then
			
		if (not entity.isInInteractRange) then
			-- MoveIntoInteractRange
			local tPos = entity.pos
			if ( tPos ) then
				if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
				local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
				if (tonumber(navResult) < 0) then
					d("e_revive.MoveInToCombatRange result: "..tonumber(navResult))
					if ( e_revive.lastID ~= entity.id ) then
						e_revive.lastID = entity.id
						e_revive.counter = 0
					else
						if ( e_revive.counter > 15 ) then
							d("Blacklisting "..entity.name)
							mc_blacklist.AddBlacklistEntry(GetString("monsters"), entity.contentID, entity.name, mc_global.now + 60000)
						else
							e_revive.counter = e_revive.counter + 1
						end
					end
					return ml_log(false)
				end
				e_revive.lastID = 0
				e_revive.counter = 0					
				ml_log("MoveToRevive..")
				return true
			end
		else
			-- Grab that thing
			Player:StopMovement()
			local t = Player:GetTarget()
			if ( not t or t.id ~= id ) then
				Player:SetTarget( id )
			else
				-- yeah I know, but this usually doesnt break ;)											
				if ( Player.profession == 8 ) then
					local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
					if ( skill ~= nil ) then
						if ( skill.skillID == 10554 ) then
							Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) -- Leave Death Shroud
							return
						-- add more here if needed
						end
					end
				end
				Player:Interact( id )
				ml_log("Reviving..")
				mc_global.Wait(1000)
				return true
			end
		end
	end
	return ml_log(false)	
end

c_reviveDownedPlayersInCombat = inheritsFrom( ml_cause )
e_reviveDownedPlayersInCombat = inheritsFrom( ml_effect )
function c_reviveDownedPlayersInCombat:evaluate()
	if ( gRevive == "1" and Player.health.percent > 50 ) then		
		return TableSize(CharacterList("shortestpath,selectable,interactable,downed,friendly,player,onmesh,maxdistance=2000")) > 0
	end
	return false
end
function e_reviveDownedPlayersInCombat:execute()
	ml_log("e_reviveDownedPlayersInCombat")
	local CharList = CharacterList("shortestpath,selectable,interactable,downed,friendly,player,onmesh,maxdistance=1500")
	if ( TableSize(CharList) > 0 ) then
		local id,entity = next (CharList)
		if ( id and entity ) then
			
			if (not entity.isInInteractRange) then
				-- MoveIntoInteractRange
				local tPos = entity.pos
				if ( tPos ) then
					if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
					MoveOnlyStraightForward()
					local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
					if (tonumber(navResult) < 0) then
						d("e_revive.MoveintoCombatRange result: "..tonumber(navResult))					
					end
					ml_log("MoveToRevive..")
					return true
				end
			else
				-- Grab that thing
				Player:StopMovement()
				local t = Player:GetTarget()
				if ( not t or t.id ~= id ) then
					Player:SetTarget( id )
				else
					
					-- yeah I know, but this usually doesnt break ;)											
					if ( Player.profession == 8 ) then
						local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
						if ( skill ~= nil ) then
							if ( skill.skillID == 10554 ) then
								Player:CastSpell(GW2.SKILLBARSLOT.Slot_13) -- Leave Death Shroud
								return
							-- add more here if needed
							end
						end
					end
					
					Player:Interact( id )
					ml_log("Reviving..")
					mc_global.Wait(1000)
					return true						
				end
			end
		end
	end
	return ml_log(false)	
end


function DoCombatMovement()
	if ( mc_helper.HasBuffs(Player, "791,727") ) then return false end
	local T = Player:GetTarget()
	if ( T and Player.health.percent < 98 ) then
			local Tdist = T.distance
			local playerHP = Player.health.percent
			local movedir = Player:GetMovement()
			
			-- EVADE
			if (mc_global.now - mc_ai_combat.combatEvadeTmr > 2000) then
				mc_ai_combat.combatEvadeTmr = mc_global.now
				mc_ai_combat.combatEvadeLastHP = 0
			end
			if (mc_ai_combat.combatEvadeLastHP > 0 ) then
				if (mc_ai_combat.combatEvadeLastHP <= playerHP) then
					mc_ai_combat.combatEvadeLastHP = playerHP
				elseif (mc_ai_combat.combatEvadeLastHP - playerHP > math.random(5,10) and Player.endurance >= 50 ) then
				-- we lost 5-10% hp in the last 2,5seconds, evade!
					for tries=0,3 do
						local direction = math.random(0,7)
						if (Player:CanEvade(direction,100)) then
							d("Evade! :"..tostring(Player:Evade(direction)));
							mc_ai_combat.combatEvadeLastHP = 0
							return
						end
					end
				end
			else 
				mc_ai_combat.combatEvadeLastHP = playerHP
			end
		
		--CONTROL CURRENT COMBAT MOVEMENT
			if ( Player:IsMoving() ) then
			
				if ( not Player.onmeshexact and (movedir.backward or movedir.left or movedir.right) ) then
					d("We ran outside the NavMesh!")
					Player:UnSetMovement(1)
					Player:UnSetMovement(2)
					Player:UnSetMovement(3)
					local pPos = Player.pos
					if (pPos) then
						local mPos = NavigationManager:GetClosestPointOnMesh(pPos)
						if ( mPos ) then
							--d("Moving back onto the NavMesh..")
							Player:MoveTo(mPos.x,mPos.y,mPos.z,50,false,false,false)
						end
					end
					return
				end
				
				if (tonumber(Tdist) ~= nil) then
					if (mc_global.AttackRange > 300) then
						-- RANGE
						if (Tdist < (mc_global.AttackRange / 2) and movedir.forward ) then -- we are too close and moving towards enemy
							Player:UnSetMovement(0)	-- stop moving forward
						elseif ( Tdist > mc_global.AttackRange and movedir.backward ) then -- we are too far away and moving backwards
							Player:UnSetMovement(1)	-- stop moving backward
						elseif (Tdist > mc_global.AttackRange and (movedir.left or movedir.right)) then -- we are strafing outside the maxrange
							if ( movedir.left ) then
								Player:UnSetMovement(2) -- stop moving Left
							elseif( movedir.right) then
								Player:UnSetMovement(3) -- stop moving Right
							end
						end
					else
						-- MELEE
						if ( Tdist < 85 and movedir.forward) then -- we are too close and moving towards enemy
							Player:UnSetMovement(0)	-- stop moving forward
						elseif (Tdist > mc_global.AttackRange and movedir.backward) then -- we are too far away and moving backwards
							Player:UnSetMovement(1)	-- stop moving backward
						elseif ((Tdist > mc_global.AttackRange + 50 or Tdist < 50) and (movedir.left or movedir.right)) then -- we are strafing outside the maxrange
							if ( movedir.left ) then
								Player:UnSetMovement(2) -- stop moving Left
							elseif( movedir.right) then
								Player:UnSetMovement(3) -- stop moving Right
							end
						end
					end
				end
			end
			
			--Set New Movement
			--d("PRECHECK "..tostring(Tdist ~= nil) .." Timer"..tostring(mc_global.now - mc_ai_combat.combatMoveTmr > 0) .."  cancast: "..tostring(Player:CanCast()).."  oOM: "..tostring(Player.onmesh).." Tlos: "..tostring(T.los) .."  Icom: "..tostring(Player.inCombat and T.inCombat))
			if ( Tdist ~= nil and mc_global.now - mc_ai_combat.combatMoveTmr > 0 and Player:CanCast() and Player.onmesh and T.los and Player.inCombat and T.inCombat) then
			
				mc_ai_combat.combatMoveTmr = mc_global.now + math.random(1000,2000)
				--tablecount:  1, 2, 3, 4, 5   --Table index starts at 1, not 0 
				local dirs = { 0, 1, 2, 3, 4 } --Forward = 0, Backward = 1, Left = 2, Right = 3, + stop
				
				if (mc_global.AttackRange > 300 ) then
					-- RANGE
					if (Tdist < mc_global.AttackRange ) then
						if (Tdist > (mc_global.AttackRange * 0.90)) then 
							table.remove(dirs,2) -- We are too far away to walk backward
						end
						if (Tdist < 600) then 
							table.remove(dirs,1) -- We are too close to walk forward
						end	
						if (Tdist < 250) then 
							table.remove(dirs,5) -- We are too close, remove "stop"
							if (movedir.left ) then 
								table.remove(dirs,3) -- We are moving left, so don't try to go left
							end
							if (movedir.right ) then
								table.remove(dirs,4) -- We are moving right, so don't try to go right
							end
						end
					end
					
				else
					-- MELEE
					if (Tdist < mc_global.AttackRange ) then
						if (Tdist > 200) then 
							table.remove(dirs,2) -- We are too far away to walk backwards
						end
						if (Tdist < 100) then 
							table.remove(dirs,1) -- We are too close to walk forwards
						end
						if (movedir.left ) then 
							--table.remove(dirs,4) -- We are moving left, so don't try to go right
						end
						if (movedir.right ) then
							--table.remove(dirs,3) -- We are moving right, so don't try to go left
						end
					end
				end
				-- Forward = 0, Backward = 1, Left = 2, Right = 3, + stop
				-- F = 3, B = 0, L = 6, R = 7, LF = 4, RF = 5, LB = 1, RB = 2
				if (Player:CanMoveDirection(3,400) == false or Player:CanMoveDirection(4,350) == false or Player:CanMoveDirection(5,350) == false) then 
					Player:UnSetMovement(0)
					table.remove(dirs,1)
				end
				if (Player:CanMoveDirection(0,400) == false or Player:CanMoveDirection(1,350) == false or Player:CanMoveDirection(2,350) == false) then 
					Player:UnSetMovement(1)
					table.remove(dirs,2)
				end
				if (Player:CanMoveDirection(6,400) == false or Player:CanMoveDirection(4,350) == false or Player:CanMoveDirection(1,350) == false) then 
					Player:UnSetMovement(2)
					table.remove(dirs,3)
				end
				if (Player:CanMoveDirection(7,400) == false or Player:CanMoveDirection(5,350) == false or Player:CanMoveDirection(2,350) == false) then 
					Player:UnSetMovement(3)
					table.remove(dirs,4)
				end
				
				-- MOVE
				local dir = dirs[ math.random( #dirs ) ]
				if (dir ~= 4) then
					Player:SetMovement(dir)
				else 
					Player:StopMovement()
				end
			end
	else
		Player:StopMovement()
	end
	return false
end
						
-- The bot sometimes is "stuck" on strafing left or right after combat, this fixes it
function MoveOnlyStraightForward()
	if ( Player:IsMoving() ) then
		local movdirs = Player:GetMovement()		
		if (movdirs.left) then
			Player:UnSetMovement(2)
			return true
		elseif (movdirs.right) then 
			Player:UnSetMovement(3)
			return true
		end
	end
	return false
end
