-- Dead State for all professions
-- Fights downed and respawns at nearby waypoint

--[[
==Skills by profession==
====1 Guardian====
1 Wrath
2 Wave of Light
3 Symbol of Judgment

====2 Warrior====
1 Throw Rock
2 Hammer Toss
3 Vengeance

====3 Engineer====
1 Throw Junk
2 Grappling Line
3 Booby Trap

====4 Ranger====
1 Throw Dirt
2 Thunderclap
3 Lick Wounds

====5 Thief====
1 Trail of Knives
1 (stealth) Venomous Knife
2 Shadow Escape
3 Smoke Bomb (thief skill)

====6 Elementalist====
1 Discharge Lightning
2 Vapor Form
3 Grasping Earth

====7 Mesmer====
1 Mind Blast
2 Deception (mesmer)
3 Phantasmal Rogue

====8 Necromancer====
1 Life Leech
2 Fear (necromancer skill)
3 Fetid Ground

====all Common====
4 Bandage
--]]

wt_core_state_dead = inheritsFrom( wt_core_state )
wt_core_state_dead.name = "Dead"
wt_core_state_dead.kelement_list = { }
wt_core_state_dead.CurrentTarget = 0

------------------------------------------------------------------------------
-- Alive again Check
local cd_check_alive = inheritsFrom( wt_cause )
local ed_alive = inheritsFrom( wt_effect )

function cd_check_alive:evaluate()
	if ( not wt_core_taskmanager.behavior == "default" ) then
		wt_core_taskmanager:SetDefaultBehavior()
	end
	if ( Player.alive == true ) then
		return true
	end
	return false
end

function ed_alive:execute()
	wt_core_controller.requestStateChange( wt_core_state_idle )
end

------------------------------------------------------------------------------
-- Downed Combat Check
local c_downed_combat = inheritsFrom( wt_cause )
local e_downed_combat = inheritsFrom( wt_effect )

e_downed_combat.dMaster = true -- Master switch for debug messages
e_downed_combat.Lslot = nil -- debug index, no reason to print debug message over and over unless you are debugging ite_downed_combat.Lslot = nil
e_downed_combat.dSpam = false -- true == active running debugging on this specific code

function c_downed_combat:evaluate()
	if ( Player.healthstate == GW2.HEALTHSTATE.Downed ) then
		return true
	end
	if ( e_downed_combat.Lslot ~= nil ) then e_downed_combat.Lslot = nil end
	return false
end

function e_downed_combat:execute()
	-- wt_debug( "e_downed_combat" )
	for i = 4, 1, -1 do
		if ( type( e_downed_combat[ "s" .. i ] ) ~= "table" ) then
			e_downed_combat[ "s" .. i ] = { }
		end
		local slot = Player:GetSpellInfo( GW2.SKILLBARSLOT["Slot_" .. i] )
		if ( not e_downed_combat[ "s" .. i ].skillID ) then
			while ( slot.name == "" ) do
				slot = Player:GetSpellInfo( GW2.SKILLBARSLOT["Slot_" .. i] )
			end
			local sname, _ = string.gsub( tostring( slot.name ), "\"", "" )
			if ( sname ~= nil ) then slot.name = sname else slot.name = tostring( slot.name ) end
			slot.msg = string.format( "Downed: Use %s (s%u) on ", slot.name, tostring( i ) )
			e_downed_combat[ "s" .. i ] = slot
		end
	end

	local function D_Msg( i, E, OoC )
		if ( e_downed_combat.dMaster ) then
			local msg = e_downed_combat[ "s" .. i ].msg
			if ( i < 4 ) then msg = msg .. E.name
			elseif ( i == 4 ) then msg = msg .. "Ranger" end
			if ( OoC ) then msg = msg .. " .. OutOfCombat" end
			if ( e_downed_combat.dSpam ) then wt_debug( msg )
			else if ( e_downed_combat.Lslot ~= i ) then wt_debug( msg ) end
			end
		end
	end

	if ( Player.inCombat ) then
		-- wt_debug( "e_downed_combat Player.inCombat = true" )
		TargetList = ( CharacterList( "lowesthealth,los,attackable,alive,incombat,noCritter,maxdistance=" .. wt_global_information.MaxAggroDistanceFar ) )
		if ( TableSize( TargetList ) > 0 ) then
			targetID, E  = next( TargetList )
			E.name = tostring( E.name )
			if ( targetID ~= nil ) then
				if ( Player:GetTarget() ~= targetID ) then Player:SetTarget( targetID ) end
				if ( not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_4 ) ) then
					-- Ranger: Bandage
					D_Msg( 4, E, false )
					Player:CastSpell( GW2.SKILLBARSLOT.Slot_4 ) -- No need for TargetID player is the target
					e_downed_combat.Lslot = 4
					return
				-- Slot 4

				elseif ( not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_3 ) ) and ( Player:GetCurrentlyCastedSpell() ~= GW2.SKILLBARSLOT.Slot_4 ) and ( Player.profession ~= 4 )  and ( Player.profession ~= 2 )then
					-- Ranger skill slot_3 is disabled until pet attack (F1) have been fixed
					-- Ranger: Lick Wounds
					D_Msg( 3, E, false )
					Player:CastSpell( GW2.SKILLBARSLOT.Slot_3, targetID )
					e_downed_combat.Lslot = 3
					return
				-- Slot 3

				elseif ( not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_2 ) ) and ( Player:GetCurrentlyCastedSpell() ~= GW2.SKILLBARSLOT.Slot_4 ) then
					-- Ranger: Thunderclap
					D_Msg( 2, E, false )
					Player:CastSpell( GW2.SKILLBARSLOT.Slot_2, targetID )
					e_downed_combat.Lslot = 2
					return
				-- Slot 2

				elseif ( not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_1 ) ) and ( Player:GetCurrentlyCastedSpell() ~= GW2.SKILLBARSLOT.Slot_4 ) then
					-- Ranger: Throw Dirt
					D_Msg( 1, E, false )
					Player:CastSpell( GW2.SKILLBARSLOT.Slot_1, targetID )
					e_downed_combat.Lslot = 1
					return
				-- Slot 1
				end
			-- targetID = nil
			end
		-- TableSize( TargetList ) > 0
		end
	-- Player.inCombat
	end
	if ( not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_4 ) ) then
		-- Ranger: Bandage
		D_Msg( 4, E, true )
		Player:CastSpell( GW2.SKILLBARSLOT.Slot_4 ) -- No need for TargetID player is the target
		e_downed_combat.Lslot = nil
		return
	-- Slot 4
	end
	return
end

------------------------------------------------------------------------------
-- Dead Check
local cd_dead_check = inheritsFrom( wt_cause )
local ed_dead = inheritsFrom( wt_effect )

function cd_dead_check:evaluate()	
	if ( Player.healthstate == GW2.HEALTHSTATE.Defeated ) then
		return true
	end
	return false
end

ed_dead.delay = math.random( 5000, 10000 )
ed_dead.throttle = math.random( 8000, 16000 )
function ed_dead:execute()
	if (gMinionEnabled == "1" and MultiBotIsConnected( )) then
		local party = Player:GetPartyMembers()
		if (party ~= nil and wt_core_state_minion.LeaderID ~= nil) then
			local index, player  = next( party )
			while ( index ~= nil and player ~= nil ) do			
				if (player.distance < 4000 and player.alive and player.onmesh) then						
					wt_debug( "Waiting for a partymember to rezz me..")
					return
				end
				index, player  = next( party,index )
			end		
		end
	end
	wt_debug( "Downed: RESPAWN AT NEAREST WAYPOINT " )
	wt_debug( Player:RespawnAtClosestResShrine() )
end

------------------------------------------------------------------------------
function wt_core_state_dead:initialize()

		local ke_alive = wt_kelement:create( "Alive", cd_check_alive, ed_alive, 1000 )
		wt_core_state_dead:add( ke_alive )

		local ke_dead = wt_kelement:create( "Respawn", cd_dead_check, ed_dead, 200 )
		wt_core_state_dead:add( ke_dead )

		local ke_downed_combat = wt_kelement:create( "DownedCombat", c_downed_combat, e_downed_combat, 150 )
		wt_core_state_dead:add( ke_downed_combat )

end

wt_core_state_dead:initialize()
wt_core_state_dead:register()
