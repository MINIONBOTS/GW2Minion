-- Tasks that can be added to the taskmanager


--**********************************************************************************
-- DEFAULT TASKS ( Prio 0-999)
--**********************************************************************************
------------------------------------------------------------------
-- Explore Waypoint Task
function wt_core_taskmanager:addWaypointTask( waypoint )
	if ( waypoint ~= nil and waypoint.pos.x ~= 0 and waypoint.pos.y ~= 0 and waypoint.pos.z ~= 0 ) then 
		local newtask = inheritsFrom( wt_task )
		newtask.UID = "WP"..tostring(math.floor(waypoint.pos.x))
		newtask.timestamp = wt_global_information.Now		
		newtask.name = "Explore Waypoint"
		newtask.priority = 650
		newtask.position = waypoint.pos
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 500

		function newtask:execute()
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance > 250 ) then
				--wt_debug("Walking towards new Waypoint ")	
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 200 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.done = true
			end		
			newtask.name = "Explore Waypoint, dist: "..(math.floor(distance))
		end

		function newtask:isFinished()
			if ( newtask.done ) then 
				return true
			end
			return false
		end
		wt_core_taskmanager:addCustomtask( newtask )
	end
end

------------------------------------------------------------------
-- Explore Point Of Interest Task
function wt_core_taskmanager:addPOITask( poi )
	if ( poi ~= nil and poi.pos.x ~= 0 and poi.pos.y ~= 0 and poi.pos.z ~= 0 ) then 
		local newtask = inheritsFrom( wt_task )
		newtask.UID = "PoI"..tostring(math.floor(poi.pos.x))
		newtask.timestamp = wt_global_information.Now				
		newtask.name = "Explore PointOfInterest"
		newtask.priority = 600
		newtask.position = poi.pos
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 500
		
		function newtask:execute()
			local mypos = Player.pos
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
			if ( distance > 220 ) then
				--wt_debug("Walking towards new PointOfInterest ")	
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 200 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.done = true
			end
			newtask.name = "Explore PointOfInterest, dist: "..(math.floor(distance))
		end

		function newtask:isFinished()
			if ( newtask.done ) then
				return true
			end
			return false
		end	
		wt_core_taskmanager:addCustomtask( newtask )
	end
end

------------------------------------------------------------------
-- Fight at HeartQuest Task
function wt_core_taskmanager:addHeartQuestTask( quest )
	
	local newtask = inheritsFrom( wt_task )
	newtask.UID = "HeartQuest"..tostring(math.floor(quest.pos.x))
	newtask.timestamp = wt_global_information.Now				
	newtask.name = "HeartQuest"
	--[[if (quest.type == 137) then -- currently active/nearby HeartQuest
		newtask.priority = 600
	else
		newtask.priority = 500
	end]]
	newtask.priority = 500
	newtask.spotreached = false
	newtask.startingTime = 0
	newtask.position = quest.pos
	newtask.maxduration = math.random(60000,600000)
	newtask.done = false
	newtask.last_execution = 0
	newtask.throttle = 500
	
	function newtask:canRun()			
		return true
	end
		
	function newtask:execute()
		if ( not newtask.spotreached ) then
			local me = Player
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 350 ) then
				--wt_debug("Walking towards FarmSpot Marker ")	
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveToRandomPointAroundCircle( newtask.position.x, newtask.position.y, newtask.position.z, 500 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.spotreached = true
				newtask.startingTime = wt_global_information.Now
			end
			newtask.name = "HeartQuest: "..(math.floor(distance))
		else
			local me = Player
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 5000 ) then
				--wt_debug("Walking towards FarmSpot Marker ")	
				Player:MoveToRandomPointAroundCircle(  newtask.position.x, newtask.position.y, newtask.position.z, 1000 )
			else
				TargetList = ( CharacterList( "noCritter,attackable,alive,maxdistance="..wt_global_information.MaxSearchEnemyDistance..",onmesh,maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
				if ( TargetList ~= nil ) then 	
					nextTarget, E  = next( TargetList )
					if ( nextTarget ~= nil and (wt_global_information.Now - newtask.startingTime) < newtask.maxduration) then
						--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )						
						wt_core_state_combat.setTarget( nextTarget )
						wt_core_controller.requestStateChange( wt_core_state_combat )
					else
						Player:StopMoving()
						newtask.done = true	
					end
				else
					Player:StopMoving()
					newtask.done = true
				end
			end
			newtask.name = "Do HeartQuest "..(math.floor((newtask.maxduration-(wt_global_information.Now - newtask.startingTime))/1000)).." sec"
		end		
	end

	function newtask:isFinished()
		if ( newtask.done ) then
			wt_core_taskmanager.Customtask_history[tostring(newtask.UID)] = wt_global_information.Now
			return true
		end
		return false
	end	
	wt_core_taskmanager:addCustomtask( newtask )
	
end

------------------------------------------------------------------
-- Fight at Event Task
function wt_core_taskmanager:addEventTask( ID,event, prio )

	local newtask = inheritsFrom( wt_task )
	newtask.UID = "Event"..tostring(event.eventID)
	newtask.timestamp = wt_global_information.Now				
	newtask.name = "Event"	
	newtask.priority = prio
	newtask.eventID = ID
	newtask.spotreached = false
	newtask.startingTime = 0
	newtask.position = event.pos
	newtask.maxduration = math.random(60000,600000) --max 10 min
	newtask.done = false
	newtask.last_execution = 0
	newtask.throttle = 500
	newtask.needUpdate = false
	newtask.needPause = false
	newtask.pausestartingTime = 0
	newtask.pausemaxduration = math.random(10000,60000) --max 1 min
	
	
	function newtask:execute()
		local MMList = MapMarkerList("isevent,eventid="..tonumber(newtask.eventID)..",onmesh")
		if ( MMList ~= nil ) then
			local index, event = next(MMList)
			--[[local charfound = false
			 each EventID has min. two entries in the list
			while (index ~= nil and event ~= nil) do
				 if (event.characterID ~= 0 and event.pos ~= nil) then
					newtask.position = event.pos
					charfound = true
					break
				 end				
				index, event = next(MMList,index)
			end
			if ( not charfound) then
					newtask.position = event.pos
				end	]]
			
			if ( event ~= nil and event.pos ~= nil) then
				newtask.position = event.pos
				if ( not newtask.spotreached ) then
				
					if ( event.distance > 350 ) then
						if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
							
							Player:MoveToRandomPointAroundCircle( newtask.position.x, newtask.position.y, newtask.position.z, 500 )
							newtask.last_execution = wt_global_information.Now
						end
					else
						newtask.spotreached = true
						newtask.startingTime = wt_global_information.Now
					end
					newtask.name = "Event: "..(math.floor(distance))
					
				else
					if ( newtask.needPause and (wt_global_information.Now - newtask.pausestartingTime) < newtask.pausemaxduration) then
						newtask.name = "Event: Waiting.."
						--if (Player.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
						--	Player:MoveToRandomPointAroundCircle(  newtask.position.x, newtask.position.y, newtask.position.z, 2500 )
						--end
					else
						if ((wt_global_information.Now - newtask.startingTime) < newtask.maxduration) then
						
							if ( event.distance > 2500 ) then	
								Player:MoveToRandomPointAroundCircle(  newtask.position.x, newtask.position.y, newtask.position.z, 500 )
							else
								TargetList = ( CharacterList( "noCritter,attackable,alive,maxdistance=2500,onmesh") )
								if ( TargetList ~= nil ) then 	
									nextTarget, E  = next( TargetList )
									if ( nextTarget ~= nil ) then
										wt_core_state_combat.setTarget( nextTarget )
										wt_core_controller.requestStateChange( wt_core_state_combat )
									else
										newtask.needPause = true
										newtask.pausestartingTime = wt_global_information.Now
									end
								else
									newtask.needPause = true
									newtask.pausestartingTime = wt_global_information.Now
								end
							end
							newtask.name = "Do Event "..(math.floor((newtask.maxduration-(wt_global_information.Now - newtask.startingTime))/1000)).." sec"
						else
							newtask.needUpdate = true
						end
					end
				end
			else
				newtask.needUpdate = true
			end
		end
			
		if (newtask.needUpdate) then
			local event = MapMarkerList("isevent,nearest,eventID=" .. newtask.eventID)
			if event then
				local i,e = next(event)
				if i and e then
					newtask.needUpdate = false
					newtask.startingTime = wt_global_information.Now
					return
				end
			end
			-- chain event check
			if (newtask.needUpdate) then
				local event = MapMarkerList("isevent,nearest,eventID=" .. newtask.eventID+1)
				if event then
					local i,e = next(event)
					if i and e then
						wt_core_taskmanager:addEventTask( i, e , 1250)						
					end
				end
			end
			newtask.done = true
		end
	end

	function newtask:isFinished()
		if ( newtask.done ) then 
			wt_core_taskmanager.Customtask_history[tostring(newtask.UID)] = wt_global_information.Now
			return true
		end
		return false
	end		
	wt_core_taskmanager:addCustomtask( newtask )	
end

------------------------------------------------------------------
-- Fight at FarmSpot Task
function wt_core_taskmanager:addFarmSpotTask( marker )
	
	local newtask = inheritsFrom( wt_task )	
	newtask.UID = "FARM"..tostring(math.floor(marker.x))
	newtask.name = "FarmSpot "
	newtask.timestamp = wt_global_information.Now
	newtask.priority = 400
	newtask.spotreached = false
	newtask.startingTime = 0
	newtask.position = {}
	newtask.position.x = marker.x
	newtask.position.y = marker.y
	newtask.position.z = marker.z
	newtask.maxduration = math.random(60000,600000)
	newtask.done = false
	newtask.last_execution = 0
	newtask.throttle = 500
		
	function newtask:execute()
		if ( not newtask.spotreached ) then
			local me = Player
			local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, me.pos.x, me.pos.y, me.pos.z )
			if ( distance > 350 ) then
				--wt_debug("Walking towards FarmSpot Marker ")	
				if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 100 )
					newtask.last_execution = wt_global_information.Now
				end
			else
				newtask.spotreached = true
				newtask.startingTime = wt_global_information.Now
			end
			newtask.name = "FarmSpot: "..(math.floor(distance))
		else
			TargetList = ( CharacterList( "shortestpath,onmesh,noCritter,attackable,alive,maxdistance="..wt_global_information.MaxSearchEnemyDistance..",maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
			if ( TargetList ~= nil ) then 	
				nextTarget, E  = next( TargetList )
				if ( nextTarget ~= nil and (wt_global_information.Now - newtask.startingTime) < newtask.maxduration) then
					--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )					
					wt_core_state_combat.setTarget( nextTarget )
					wt_core_controller.requestStateChange( wt_core_state_combat )
				else
					Player:StopMoving()
					newtask.done = true
				end
			else
				Player:StopMoving()
				newtask.done = true
			end
			newtask.name = "Fight FarmSpot "..(math.floor((newtask.maxduration-(wt_global_information.Now - newtask.startingTime))/1000)).." sec"	
		end		
	end

	function newtask:isFinished()
		if ( newtask.done ) then 
			return true
		end
		return false
	end	
	wt_core_taskmanager:addCustomtask( newtask )
	
end

------------------------------------------------------------------
-- Kill stuff nearby Task - NOTUSEDRIGHTNOW
function wt_core_taskmanager:addSearchAndKillTask(  )
	 
	local newtask = inheritsFrom( wt_task )
	newtask.name = "Search And Kill"
	newtask.priority = wt_task.priorities.normal
	newtask.startingTime = wt_global_information.Now
	newtask.maxduration = math.random(60000,600000)
	newtask.done = false
	
	function newtask:execute()
		TargetList = ( CharacterList( "shortestpath,onmesh,noCritter,attackable,alive,maxdistance=4000,maxlevel="..( Player.level + wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel ) ) )
		if ( TargetList ~= nil ) then 	
			nextTarget, E  = next( TargetList )
			if ( nextTarget ~= nil and (wt_global_information.Now - newtask.startingTime) < newtask.maxduration) then
				--wt_debug( "TaskManager: Begin Combat, Found target "..nextTarget )				
				wt_core_state_combat.setTarget( nextTarget )
				wt_core_controller.requestStateChange( wt_core_state_combat )
			else
				Player:StopMoving()
				newtask.done = true
			end
		else
			Player:StopMoving()
			newtask.done = true
		end
		newtask.name = "Search And Kill "..(math.floor((newtask.maxduration-(wt_global_information.Now - newtask.startingTime))/1000)).." sec"
	end

	function newtask:isFinished()
		if ( newtask.done ) then 
			return true
		end
		return false
	end	
	wt_core_taskmanager:addCustomtask( newtask )
	
end




--**********************************************************************************
-- PRIORITY TASKS ( Prio 1000-9999)
--**********************************************************************************

-- Kill Enemy Character Task - P:3000
function wt_core_taskmanager:addKillTask( ID, character, Prio )
	local newtask = inheritsFrom( wt_task )
	newtask.UID = "KILL"..tostring(ID)
	newtask.timestamp = wt_global_information.Now
	newtask.lifetime = 20000
	newtask.name = "Attacking "..tostring(character.name)
	newtask.priority = tonumber(Prio)
	newtask.position = character.pos
	newtask.done = false
	newtask.ID = ID			
			
	function newtask:execute()				
		local ntarget = CharacterList:Get(tonumber(newtask.ID))
		if ( ntarget ~= nil and ntarget.distance < 4000 and ntarget.alive and ntarget.onmesh) then
			wt_debug(tostring(newtask.name))
			if (tonumber(newtask.ID) ~= nil) then
				MultiBotSend( "5;"..tonumber(newtask.ID),"gw2minion" ) -- Set FocusTarget for Minions
				wt_core_state_combat.setTarget( tonumber(newtask.ID) )
				wt_core_controller.requestStateChange( wt_core_state_combat )
				return
			end				
			newtask.done = true
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
			
	wt_core_taskmanager:addCustomtask( newtask )
end


-- Go To Vendor Task - P:5000
function wt_core_taskmanager:addVendorTask( priority )
	local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
	if ( TableSize( EList ) > 0 ) then
		local nextTarget, E = next( EList )
		if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
			
			local newtask = inheritsFrom( wt_task )
			newtask.UID = "VENDOR"
			newtask.timestamp = wt_global_information.Now
			newtask.name = "GoTo Vendor"
			newtask.priority = tonumber(priority)
			newtask.position = E.pos
			newtask.done = false
			newtask.NPC = nextTarget
			newtask.throttle = 500
			newtask.last_execution = 0
			newtask.junksold = false
			
			
			function newtask:execute()				
				mypos = Player.pos
				local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
				if ( distance > 150 ) then
					-- MAKE SURE ALL MINIONS ARE NEARBY
					if (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1) then	
						local party = Player:GetPartyMembers()
						if (party ~= nil ) then
							local index, player  = next( party )
							while ( index ~= nil and player ~= nil ) do			
								if (player.distance > 1200 and player.onmesh) then
									if (player.distance > 2000 ) then
										local pos = player.pos
										--TODO: Getmovementstate of player, adopt range accordingly
										Player:MoveTo(pos.x,pos.y,pos.z,math.random( 20, 350 ))
										return
									elseif(player.distance <= 2000 and player.distance > 1200) then
										wt_debug("Waiting for Partymembers to get to us")
										Player:StopMoving()
										return
									end
								else
									Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 75 )
									return
								end
								index, player  = next( party,index )
							end		
						end
					else
						Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 75 )
					end
					newtask.name = "Vendor: "..(math.floor(distance))
				else
					if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
						newtask.last_execution = wt_global_information.Now
						--MAKE SURE ALL MINIONS ARE NEARBY WHEN IN GROUP
						if (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1) then	
							local party = Player:GetPartyMembers()
							local canvendor = true							
							if (party ~= nil) then
								local i,p = next (party)
								while (i~= nil and p~= nil) do
									if (p.distance > 1500) then
										canvendor = false
									end
									i,p = next(party,i)
								end
							end
							if (not canvendor) then
								wt_debug("Waiting for our whole party to get to me....")
								return
							else
								wt_debug("Telling Minions to vendor")
								MultiBotSend( "11;0","gw2minion" )
							end
						end						
						
						local vendor = MapObjectList:Get(newtask.NPC)
						if ( vendor ~= nil and vendor.distance < 150 and vendor.characterID ~= nil and vendor.characterID ~= 0) then
							--TODO: LEADER SEND VENDOR MSG TO MINIONS							
							-- TARGET VENDOR
							local nearestID = Player:GetInteractableTarget()
							if ( vendor.characterID ~= nil and vendor.characterID ~= 0 and nearestID ~= nil and vendor.characterID ~= nearestID ) then 
								if ( Player:GetTarget() ~= vendor.characterID) then				
									Player:SetTarget(vendor.characterID)
									return
								end
							end
							-- INTERACT WITH VENDOR
							if ( not Inventory:IsVendorOpened() and  not Player:IsConversationOpen() ) then
								wt_debug( "Vendoring: Opening Vendor.. " )
								Player:Interact( vendor.characterID )
								return
							end
							-- CHAT WITH VENDOR
							if ( not Inventory:IsVendorOpened() and Player:IsConversationOpen() and not newtask.junksold ) then
								wt_debug( "Vendoring: Chatting with Vendor..." )							
								local options = Player:GetConversationOptions()
								nextOption, entry  = next( options )
								local found = false
								while ( nextOption ~= nil ) do
									if( entry == GW2.CONVERSATIONOPTIONS.Shop ) then
										Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Shop )
										found = true
										break
									elseif( entry == GW2.CONVERSATIONOPTIONS.KarmaShop ) then
										Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.KarmaShop )
										found = true
										break
									end
									nextOption, entry  = next( options, nextOption )
								end
								if ( not found ) then
									nextOption, entry  = next( options )
									while ( nextOption ~=nil ) do
										if( entry == GW2.CONVERSATIONOPTIONS.Continue ) then
											Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
											found = true
											break
										elseif( entry == GW2.CONVERSATIONOPTIONS.Story ) then
											Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Story )
											found = true
											break
										end
										nextOption, entry  = next( options, nextOption )
									end
								end
								if ( not found ) then
									wt_debug( "Vendoring: can't handle vendor, please report back to the developers" )
								end
								return
							end
							-- SELL ITEMS
							if (Inventory:IsVendorOpened() and not Player:IsConversationOpen() and not newtask.junksold) then
								local sold = false			
								if ( gVendor_Weapons == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Weapons	
									while ( tmpR > 0 and sold == false) do
										local sweapons = ItemList("itemtype=18,notsoulbound,rarity="..tmpR)	
										id,item = next(sweapons)
										if (id ~=nil and item ~= nil ) then					
											wt_debug( "Vendoring: Selling Weapon... ")
											item:Sell()
											sold = true				
										end
										tmpR = tmpR - 1
									end
								end
								
								if ( gVendor_Armor == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Armor
									if ( not sold ) then
										while ( tmpR > 0 and sold == false) do
											local sarmor = ItemList("itemtype=0,notsoulbound,rarity="..tmpR)					
											id,item = next(sarmor)
											if (id ~=nil and item ~= nil ) then					
												wt_debug( "Vendoring: Selling Armor... ")
												item:Sell()
												sold = true				
											end
											tmpR = tmpR - 1
										end		
									end	
								end
								
								if ( gVendor_Trinkets == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Trinkets
									if ( not sold ) then
										while ( tmpR > 0 and sold == false) do
											local strinket = ItemList("itemtype=15,notsoulbound,rarity="..tmpR)					
											id,item = next(strinket)
											if (id ~=nil and item ~= nil ) then					
												wt_debug( "Vendoring: Selling Trinket... ")
												item:Sell()
												sold = true				
											end
											tmpR = tmpR - 1
										end		
									end		
								end
								
								if ( gVendor_UpgradeComps == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Upgrade Components
									if ( not sold ) then
										while ( tmpR > 0 and sold == false) do
											local supgrade = ItemList("itemtype=17,notsoulbound,rarity="..tmpR)					
											id,item = next(supgrade)
											if (id ~=nil and item ~= nil ) then					
												wt_debug( "Vendoring: Selling Upgrade Component... ")
												item:Sell()
												sold = true				
											end
											tmpR = tmpR - 1
										end		
									end		
								end
								
								if ( gVendor_CraftingMats == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Crafting Mats
									if ( not sold ) then
										while ( tmpR > 0 and sold == false) do
											local scraftmats = ItemList("itemtype=5,notsoulbound,rarity="..tmpR)				
											id,item = next(scraftmats)
											if (id ~=nil and item ~= nil ) then					
												wt_debug( "Vendoring: Selling Crafting Material... ")
												item:Sell()
												sold = true				
											end
											tmpR = tmpR - 1
										end		
									end		
								end
								
								if ( gVendor_Trophies == "1") then
								local tmpR = tonumber(gMaxItemSellRarity)	
									-- Sell Trophies
									if ( not sold ) then
										while ( tmpR > 0 and sold == false) do
											local strophies = ItemList("itemtype=16,notsoulbound,rarity="..tmpR)					
											id,item = next(strophies)
											if (id ~=nil and item ~= nil ) then					
												wt_debug( "Vendoring: Selling Trohpies... ")
												item:Sell()
												sold = true				
											end
											tmpR = tmpR - 1
										end		
									end		
								end
								
								if ( gVendor_Junk == "1") then
									-- Sell Junk
									if ( not sold ) then
										wt_debug( "Vendoring: Selling Junk..." )
										Inventory:SellJunk()
										newtask.junksold = true
									end
								end
								newtask.throttle = math.random(500,1500)
							end
							-- DONE LOL
							if (newtask.junksold) then
								newtask.done = true
							end							
						else
							-- Reget closest Vendor
							local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.Merchant )
							if ( TableSize( EList ) > 0 ) then
								local nextTarget, E = next( EList )
								if ( nextTarget ~= nil and nextTarget ~= 0 ) then
									newtask.position = E.pos
									newtask.NPC = nextTarget
								end
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
			
			wt_core_taskmanager:addCustomtask( newtask )
		end
	end
end


-- Go To Repair Task - P:4500
function wt_core_taskmanager:addRepairTask( priority )
	local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
	if ( TableSize( EList ) > 0 ) then
		local nextTarget, E = next( EList )
		if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
			
			local newtask = inheritsFrom( wt_task )			
			newtask.UID = "REPAIR"
			newtask.timestamp = wt_global_information.Now
			newtask.name = "Goto Repair"
			newtask.priority = tonumber(priority)
			newtask.position = E.pos
			newtask.done = false
			newtask.NPC = nextTarget
			newtask.throttle = 500
			newtask.last_execution = 0			
			newtask.repaired = false
			
			function newtask:execute()				
				mypos = Player.pos
				local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
				if ( distance > 150 ) then
					Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 75 )
					newtask.name = "Vendor: "..(math.floor(distance))
				else
					if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
						newtask.last_execution = wt_global_information.Now
						
						--MAKE SURE ALL MINIONS ARE NEARBY WHEN IN GROUP
						if (gMinionEnabled == "1" and MultiBotIsConnected( ) and Player:GetRole() == 1) then	
							local party = Player:GetPartyMembers()
							local canvendor = true							
							if (party ~= nil) then
								local i,p = next (party)
								while (i~= nil and p~= nil) do
									if (p.distance > 1500) then
										canvendor = false
									end
									i,p = next(party,i)
								end
							end
							if (not canvendor) then
								wt_debug("Waiting for our whole party to get to me....")
								return
							else
								wt_debug("Telling Minions to repair")
								MultiBotSend( "16;0","gw2minion" )
							end
						end
						
						local vendor = MapObjectList:Get(newtask.NPC)
						if ( vendor ~= nil and vendor.distance < 150 and vendor.characterID ~= nil and vendor.characterID ~= 0) then
							--TODO: LEADER SEND VENDOR MSG TO MINIONS							
							-- TARGET VENDOR
							local nearestID = Player:GetInteractableTarget()
							if ( vendor.characterID ~= nil and vendor.characterID ~= 0 and nearestID ~= nil and vendor.characterID ~= nearestID ) then 
								if ( Player:GetTarget() ~= vendor.characterID) then				
									Player:SetTarget(vendor.characterID)
									return
								end
							end
							-- INTERACT WITH VENDOR
							if ( not Player:IsConversationOpen() and newtask.repaired == false) then
								wt_debug( "Repair: Opening Vendor.. " )
								Player:Interact( vendor.characterID )
								return
							end
							-- CHAT WITH VENDOR
							wt_debug( "Repair: Chatting with Vendor..." )
							if ( Player:IsConversationOpen() and newtask.repaired == false) then
								local options = Player:GetConversationOptions()
								nextOption, entry  = next( options )
								local found = false
								while ( nextOption ~= nil ) do
									if( entry == GW2.CONVERSATIONOPTIONS.Repair ) then
										Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Repair )
										newtask.repaired = true
										found = true
										break
									elseif( entry == GW2.CONVERSATIONOPTIONS.Continue ) then
										Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
										found = true
										break
									elseif( entry == GW2.CONVERSATIONOPTIONS.Return ) then
										Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Return )
										wt_core_state_repair.repaired = true
										found = true
										break
									end
									nextOption, entry  = next( options, nextOption )
								end
								if ( not found ) then
									wt_debug( "Repair: can't handle repairvendor, please report back to the developers" )
								end
							end							
							-- DONE LOL
							if (newtask.repaired) then
								newtask.done = true
							end							
						else
							-- Reget closest Vendor
							local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
							if ( TableSize( EList ) > 0 ) then
								local nextTarget, E = next( EList )
								if ( nextTarget ~= nil and nextTarget ~= 0 ) then
									newtask.position = E.pos
									newtask.NPC = nextTarget
								end
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
			
			wt_core_taskmanager:addCustomtask( newtask )
		end
	end
end





-- Special task to open eggs
function wt_core_taskmanager:addEggTask(egg)     
                 --[[       local newtask = inheritsFrom( wt_task )
                        newtask.name = "KillEggs"
                        newtask.priority = 300
                        newtask.position = egg.pos
                        newtask.done = false
                        newtask.last_execution = 0
                        newtask.throttle = 500
                       
                        function newtask:execute()
                                local mypos = Player.pos
                                local distance =  Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z )
                                if ( distance > 100 ) then                                             
                                        if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
                                                Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
                                                newtask.last_execution = wt_global_information.Now
                                        end
                                        newtask.name = "SquishEgg, dist: "..(math.floor(distance))
                                else
                                        local EList = GadgetList("contentID=227767, nearest,onmesh")
                                        if ( TableSize( EList ) > 0 ) then
                                                local nextTarget
                                                nextTarget, E = next( EList )
                                                if ( nextTarget ~= nil and nextTarget ~= 0 and E.distance < 150) then   
													Player:Use( nextTarget )                                                                          
                                                else
													newtask.done = true
                                                end
                                        end
                                        newtask.done = true
                                end
                        end
                       
                        function newtask:isFinished()
                                if ( newtask.done ) then
                                    return true
                                end
                                return false
                        end    
						wt_debug("ADDED EGG")
                        wt_core_taskmanager:addCustomtask( newtask )]]
end
