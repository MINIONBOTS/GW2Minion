--**********************************************************
-- HandleMultiBotMessages
--**********************************************************
function HandleMultiBotMessages( event, message, channel )	
--wt_debug("MBM:" .. tostring(message) .. " chan: " .. tostring(channel))
		
	if (tostring(channel) == "gw2minion" ) then
		-- SET CLIENT ROLE, multibotcomserver sends this info when a bot enters/leaves the channel
		if ( message:find('[[Leader]]') ~= nil) then
			Player:SetRole(1)
			wt_debug("WE ARE NOW LEADER")
		elseif ( message:find('[[Minion]]') ~= nil) then
			Player:SetRole(0)
			wt_debug("WE ARE NOW MINION")
		end	
		
		if ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then
			local delimiter = message:find(';')
			if (delimiter ~= nil and delimiter ~= 0) then
				local msgID = message:sub(0,delimiter-1)
				local msg = message:sub(delimiter+1)
				if (tonumber(msgID) ~= nil and msg ~= nil ) then
				--d("msgID:" .. msgID)
				--d("msg:" .. msg)
				
					-- SET LEADER
					if ( tonumber(msgID) == 1 ) then -- Leader sends Minion LeaderID						
						if (tonumber(msg) ~= nil ) then
							--wt_debug("Setting leader :"..tostring(msg))
							Settings.GW2MINION.gLeaderID = tonumber(msg)
                            if ( Player:GetRole() ~= 1) then
                                -- Minion send request for meshswitcher time
                                MultiBotSend( "21;","gw2minion" )
                            end
						end
					
					elseif ( tonumber(msgID) == 2 ) then -- Minion asks for LeaderID
						if ( Player:GetRole() == 1) then
							--wt_debug( "Sending Minions my characterID" )
							if (tonumber(Player.characterID) ~= nil) then
								MultiBotSend( "1;"..tonumber(Player.characterID),"gw2minion" )
							end					
										--wt_debug( "Sending Minions my mapID: "..tostring(Player:GetLocalMapID()) )									
										--wt_debug( "Sending Minions nearest WaypointID: "..tostring(entry.contentID) )
						end				
					
					
					-- PARTYMANAGER
					elseif ( tonumber(msgID) == 300 ) then -- Leader sends Minion his Name						
						if (msg ~= nil and msg ~= "" and Player:GetRole() ~= 1) then
							--wt_debug("Recieved Partyleader Name :"..msg)
							wt_core_partymanager.leaderName = msg					
						end
					
					elseif ( tonumber(msgID) == 301 ) then -- Leader sends Minion his MapID						
						if (tonumber(msg) ~= nil and Player:GetRole() ~= 1 ) then
							--wt_debug("Recieved Partyleader's MapID :"..tostring(msg))
							wt_core_partymanager.leaderMapID = tonumber(msg)							
						end
					
					elseif ( tonumber(msgID) == 302 ) then -- Leader sends Minion his closest WaypointID						
						if (tonumber(msg) ~= nil and Player:GetRole() ~= 1 ) then
							--wt_debug("Recieved Partyleader's WaypointID :"..tostring(msg))
							wt_core_partymanager.leaderWPID = tonumber(msg)							
						end
					elseif ( tonumber(msgID) == 303 ) then -- Leader sends RebuildParty command						
						if (Player:GetRole() ~= 1 ) then
							--wt_debug("Recieved RebuildParty Command")
							wt_core_partymanager.RebuildParty()							
						end						
					
					
					
					-- DUNGEONMANAGER
					elseif ( tonumber(msgID) == 500 ) then -- Leader tells Minions that it's dungeontime ;)
						if (tonumber(msg) ~= nil and Player:GetRole() ~= 1) then
							--wt_debug("Recieved Partyleader Name :"..tostring(msg))
							wt_core_dungeonmanager.ButtonHandler(tonumber(msg))
						end
						
					elseif ( tonumber(msgID) == 501 ) then -- Leader tells Minions to leave dungeon
						if (tonumber(msg) ~= nil and Player:GetRole() ~= 1) then
							--wt_debug("Leader sais to Leave Dungeon..")
							if (Player:GetLocalMapID() == tonumber(msg)) then
								wt_core_dungeonmanager.LeaveDungeon()
							end
						end
					elseif ( tonumber(msgID) == 502 ) then -- Leader tells Minions to leave dungeon
						if ( Player:GetRole() ~= 1) then
							--wt_debug("Leader sais to Stop Dungeon..")
							wt_core_dungeonmanager.StopDungeon()
						end
					end
					
					
					if ( wt_core_controller.shouldRun ) then
						-- SETTING TARGETS
						if ( tonumber(msgID) == 5 ) then -- Leader sets FocusTarget
							if ( Player:GetRole() ~= 1) then
								if (tonumber(msg) ~= nil ) then
									local char = CharacterList:Get(tonumber(msg))
									if (char ~= nil and char.alive and char.distance < 4500 and char.onmesh) then
										wt_core_taskmanager:addKillTask( tonumber(msg) , char, 3450 )
									--[[else  -- CRASHES LIKE SHIT, DONT KNOW WHY
										local gadget = GadgetList:Get(tonumber(msg))
										if (gadget ~= nil and gadget.alive and gadget.distance < 4500 and gadget.onmesh) then
											wt_core_taskmanager:addKillGadgetTask( tonumber(msg), gadget, 3550 )
										end]]
									end
								end
							end
						elseif ( tonumber(msgID) == 6 ) then -- Minion Informs Leader about Aggro Target
							if ( Player:GetRole() == 1) then
								if (tonumber(msg) ~= nil ) then
									local char = CharacterList:Get(tonumber(msg))
									if (char ~= nil and char.alive and char.distance < 4500 and char.onmesh) then
										wt_core_taskmanager:addKillTask( tonumber(msg) , char, 3200 )
									end
								end
							end
						elseif ( tonumber(msgID) == 7 ) then -- Leader sets FocusTarget - Gadget
							if ( Player:GetRole() ~= 1) then
								if (tonumber(msg) ~= nil ) then
									local gadget = GadgetList:Get(tonumber(msg))
									if (gadget ~= nil and gadget.iscombatant and gadget.hashpbar and gadget.distance < 4500 and gadget.onmesh) then
										wt_core_taskmanager:addKillGadgetTask( tonumber(msg) , gadget, 3200 )
									end
								end
							end

						-- VENDORING
						elseif ( tonumber(msgID) == 10 ) then -- A minion needs to Vendor, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								--wt_debug( "A Minion needs to vendor, going to Vendor" )
								wt_core_taskmanager:addVendorTask(4500, nil)
							end
						elseif ( tonumber(msgID) == 11 ) then -- Leader tells Minions to Vendor
							if ( Player:GetRole() ~= 1 ) then
								--wt_debug( "Leader sais we should Vendor now.." )
								wt_core_taskmanager:addVendorTask(4500, nil)
							end
						
						-- VENDORBUY
						elseif ( tonumber(msgID) == 12 ) then -- A minion needs to Vendor, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								if not (wt_core_state_leader:vendorBuyCheck()) then
									local vendor = wt_core_helpers:GetClosestBuyVendor(999999)
									wt_core_taskmanager:addVendorTask(4500, vendor)
								end
								--wt_debug( "A Minion needs to purchase from vendor, going to Vendor" )
							end
						elseif ( tonumber(msgID) == 13 ) then -- Leader tells Minions to Vendor
							if ( Player:GetRole() ~= 1 ) then
								if not (wt_core_state_leader:vendorBuyCheck()) then
									local vendor = wt_core_helpers:GetClosestBuyVendor(999999)
									wt_core_taskmanager:addVendorTask(4500, vendor)
								end
								--wt_debug( "Leader sais we should Vendor now.." )
							end
						
							
						-- REPAIR
						elseif ( tonumber(msgID) == 15 ) then -- A minion needs to Repair, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								--wt_debug( "A Minion needs to repair, going to Merchant" )
								wt_core_taskmanager:addRepairTask(5000, nil)
								wt_core_taskmanager:addVendorTask(4500, nil)
							end
						elseif ( tonumber(msgID) == 16 ) then -- Leader tells Minions to Repair
							if ( gEnableRepair == "1" and NeedRepair() and Player:GetRole() ~= 1 ) then
								--wt_debug( "Leader sais we should Repair now.." )
								wt_core_taskmanager:addRepairTask(5000, nil)
								wt_core_taskmanager:addVendorTask(4500, nil)
							end
						
						-- 	Blacklist Vendor
						elseif ( tonumber(msgID) == 17 and tonumber(msg) ~= nil) then -- A minion wants leader to blacklist vendor
							if ( Player:GetRole() == 1) then
								wt_core_taskmanager.vendorBlacklist[tonumber(msg)] = true
								--wt_debug( "A minion said to blacklist vendor "..msg )
							end
						elseif ( tonumber(msgID) == 18 and tonumber(msg) ~= nil) then -- Leader tells minions to blacklist vendor
							if ( Player:GetRole() ~= 1 ) then
								wt_core_taskmanager.vendorBlacklist[tonumber(msg)] = true
								--wt_debug( "Leader said to blacklist vendor "..msg )
							end		
						
						
						-- SwitcherData
						elseif ( tonumber(msgID) == 20 and tonumber(msg) ~= nil) then
							if ( Player:GetRole() ~= 1) then
								--wt_debug( "Recieved Leader's MeshSwitcher Time: "..tostring(msg) )
								mm.switchTime = tonumber(msg)
                                gEnableSwitcher = "1"
							end
                        elseif ( tonumber(msgID) == 21 ) then
							if ( Player:GetRole() == 1) then
                                if ( gEnableSwitcher == "1" ) then
                                    --wt_debug( "Sending Leader's MeshSwitcher Time: "..tostring(mm.switchTime) )
                                    MultiBotSend( "20;"..tostring(mm.switchTime),"gw2minion" )						
                                end
							end
							
						-- 	Blacklist Event
						elseif ( tonumber(msgID) == 22 and tonumber(msg) ~= nil) then -- A minion wants leader to blacklist event
							if ( Player:GetRole() == 1) then
								wt_core_taskmanager:BlacklistEvent(tonumber(msg))
								--wt_debug( "A minion said to blacklist event "..msg )
							end
						elseif ( tonumber(msgID) == 23 and tonumber(msg) ~= nil) then -- Leader tells minions to blacklist event
							if ( Player:GetRole() ~= 1 ) then
								wt_core_taskmanager:BlacklistEvent(tonumber(msg))
								--wt_debug( "Leader said to blacklist event "..msg )
							end		
							
						--  Do Event
						elseif ( tonumber(msgID) == 24 and tonumber(msg) ~= nil) then -- Leader tells minions to do event
							if ( Player:GetRole() ~= 1 ) then
								local eventList = MapMarkerList("eventID="..tostring(msg))
								if (TableSize(eventList) > 0) then
									local _,event = next(eventList)
									if (event ~= nil) then
										local priority = 2500
										if (gEventFarming == "1") then priority = 4000 end
										wt_core_taskmanager:addEventTask(_,event,priority)
										--wt_debug( "Leader said to blacklist event "..msg )
									end
								end
							end	
							
						-- DEV
						elseif ( tonumber(msgID) == 50 and msg ~= nil) then -- Tell Minions to Load a Mesh
							if ( Player:GetRole() ~= 1 ) then
								--wt_debug( "Leader sais we need should (re)load our navmesh :"..tostring(msg) )
								mm.UnloadNavMesh()
								mm.LoadNavMesh(msg)
							end	
						
						
						-- FOLLOW
						elseif ( tonumber(msgID) == 100 ) then -- Leader tells Minions to follow him
							if ( Player:GetRole() ~= 1 and tonumber(msg) ~= nil ) then
								if not wt_core_taskmanager:CheckTaskQueue("FOLLOW") then
									--wt_debug( "Leader sais we should follow him.." )								
									wt_core_taskmanager:addFollowTask( tonumber(msg), 3750 )
								end
							end
						end
					end
				end
			end
		end
	end
end


RegisterEventHandler("MULTIBOT.Message",HandleMultiBotMessages)