-- common causes uses by the system
-- those can easily be used in compound cause objects to check
-- for multiple causes at once

-- Death Check
c_died = inheritsFrom( wt_cause )
e_died = inheritsFrom( wt_effect )

function c_died:evaluate()
	if ( not wt_core_taskmanager.behavior == "default" ) then
		wt_core_taskmanager:SetDefaultBehavior()
	end
	if ( Player.alive ~= true ) then
		return true
	end
	return false
end

function e_died:execute()
	wt_core_controller.requestStateChange( wt_core_state_dead )
end

--------------------------------------------------------------------------------
-- QuickLoot Cause & Effect (looting just the things that are in range already, this we can do while beeing infight)
c_quickloot = inheritsFrom( wt_cause )
e_quickloot = inheritsFrom( wt_effect )

function c_quickloot:evaluate()
	if ( ItemList.freeSlotCount > 0 ) then
		c_quickloot.EList = CharacterList( "nearest,lootable,onmesh,maxdistance=120" )
		NextIndex, LootTarget = next( c_quickloot.EList )
		if ( NextIndex ~= nil ) then
			if ( NextIndex == Player:GetInteractableTarget() ) then
				return true
			end
		end
		--stupidcheck since some enemies are not marked as lootable but they are lootable
		local e = Player:GetInteractableTarget()
		if ( e ~= nil ) then
			etable = CharacterList:Get( e )
			if ( etable ~= nil ) then
				if ( etable.healthstate == GW2.HEALTHSTATE.Defeated and ( etable.attitude == GW2.ATTITUDE.Hostile or etable.attitude == GW2.ATTITUDE.Neutral ) and etable.isMonster ) then
					return true
				end
			end
		end
	end
	return false
end

e_quickloot.n_index = nil
e_quickloot.throttle = math.random( 50, 450 )
e_quickloot.delay = math.random( 50, 150 )
function e_quickloot:execute()
 	local NextIndex = 0
	local LootTarget = nil
	NextIndex, LootTarget = next( c_quickloot.EList )
	if ( NextIndex ~= nil and NextIndex == Player:GetInteractableTarget() ) then
		if ( e_quickloot.n_index  ~= NextIndex ) then
			e_quickloot.n_index  = NextIndex
			wt_debug( "QuickLooting" )
		end
		Player:Interact( NextIndex )
	else
		local e = Player:GetInteractableTarget()
		if ( e ~= nil ) then
			etable = CharacterList:Get( e )
			if ( etable ~= nil ) then
				if ( etable.healthstate == GW2.HEALTHSTATE.Defeated and ( etable.attitude == GW2.ATTITUDE.Hostile or etable.attitude == GW2.ATTITUDE.Neutral ) and etable.isMonster ) then
					if ( e_quickloot.n_index  ~= e ) then
						e_quickloot.n_index  = e
						wt_debug( "QuickLooting" )
					end
					Player:Interact( e )
					return
				end
			end
		end
	end
	wt_error( "No Target to Quick-Loot" )
end

----------------------------------------------------------------------------------
-- Aggro Cause & Effect
c_aggro = inheritsFrom( wt_cause )
e_aggro = inheritsFrom( wt_effect )

function c_aggro:evaluate()
	if ( Player.inCombat ) then
		c_aggro.TargetList = ( CharacterList( "nearest,attackable,alive,incombat,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceFar ) )
		if ( TableSize( c_aggro.TargetList ) > 0 ) then
			nextTarget, E  = next( c_aggro.TargetList )
			if ( nextTarget ~= nil ) then
				return true
			end
		end
	end

	c_aggro.TargetList = ( CharacterList( "nearest,los,attackable,alive,noCritter,onmesh,maxdistance="..wt_global_information.MaxAggroDistanceClose ) )
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		return true
	end
	return false
end

function e_aggro:execute()
	if ( TableSize( c_aggro.TargetList ) > 0 ) then
		nextTarget, E  = next( c_aggro.TargetList )
		if ( nextTarget ~= nil ) then
			wt_debug( "Begin Combat, Possible aggro target found" )
			wt_core_state_combat.setTarget( nextTarget )
			wt_core_controller.requestStateChange( wt_core_state_combat )
		end
	end
end

---------------------------------------------------------------------
-- Rest Cause & Effect
c_rest = inheritsFrom( wt_cause )
e_rest = inheritsFrom( wt_effect )

function c_rest:evaluate()
	local HP = Player.health.percent
	if ( HP < wt_global_information.Currentprofession.RestHealthLimit ) then
		return true
	end
	return false
end

e_quickloot.throttle = math.random( 500, 2500 )
function e_rest:execute()
	local s6 = Player:GetSpellInfo( GW2.SKILLBARSLOT.Slot_6 )
	if( Player:GetCurrentlyCastedSpell() == 17 and Player.health.percent < 65 and not Player:IsSpellOnCooldown( GW2.SKILLBARSLOT.Slot_6 ) ) then
		if ( c_rest_heal ) then
			c_rest_heal = not c_rest_heal
			if ( s6 ~= nil ) then
				wt_debug( "Using "..tostring( s6.name ).." to heal ("..Player.health.percent.."%)" )
			end
		end
		Player:CastSpell( GW2.SKILLBARSLOT.Slot_6 )
	end
	return
end
