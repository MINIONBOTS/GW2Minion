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
							wt_debug("Setting leader :"..tostring(msg))
							Settings.GW2MINION.gLeaderID = tonumber(msg)							
						end
					
					elseif ( tonumber(msgID) == 2 ) then -- Minion asks for LeaderID
							if ( Player:GetRole() == 1) then
								wt_debug( "Sending Minions my characterID" )
								if (tonumber(Player.characterID) ~= nil) then
									MultiBotSend( "1;"..tonumber(Player.characterID),"gw2minion" )
								end
							end						
					end
					
					
					
					if ( wt_core_controller.shouldRun ) then
						-- SETTING TARGETS
						if ( tonumber(msgID) == 5 ) then -- Leader sets FocusTarget
							if ( Player:GetRole() ~= 1) then
								if (tonumber(msg) ~= nil ) then
									local char = CharacterList:Get(tonumber(msg))
									if (char ~= nil and char.alive and char.distance < 4500 and char.onmesh) then
										wt_core_taskmanager:addKillTask( tonumber(msg) , char, 3500 )
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
							

						-- VENDORING
						elseif ( tonumber(msgID) == 10 ) then -- A minion needs to Vendor, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								wt_debug( "A Minion needs to vendor, going to Vendor" )
								wt_core_taskmanager:addVendorTask(5000)
							end
						elseif ( tonumber(msgID) == 11 ) then -- Leader tells Minions to Vendor
							if ( Player:GetRole() ~= 1 ) then
								wt_debug( "Leader sais we should Vendor now.." )
								wt_core_taskmanager:addVendorTask(5000)		
							end

							
						-- REPAIR
						elseif ( tonumber(msgID) == 15 ) then -- A minion needs to Repair, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								wt_debug( "A Minion needs to repair, going to Merchant" )
								wt_core_taskmanager:addRepairTask(4500)
							end
						elseif ( tonumber(msgID) == 16 ) then -- Leader tells Minions to Repair
							if ( gEnableRepair == "1" and IsEquipmentDamaged() and Player:GetRole() ~= 1 ) then
								wt_debug( "Leader sais we should Repair now.." )
								wt_core_taskmanager:addRepairTask(4500)		
							end
							
						
						-- SET MAP
						elseif ( tonumber(msgID) == 20 ) then -- Leader sets TargetMapID
							if (tonumber(msg) ~= nil ) then
								
								local char = CharacterList:Get(tonumber(msg))
								if (char ~= nil) then
									Settings.GW2MINION.gLeaderID = tonumber(msg)
									wt_core_controller.requestStateChange( wt_core_state_idle )
								end
							end
						
						
						-- NAVMESHSWITCH
						elseif ( tonumber(msgID) == 20 and tonumber(msg) ~= nil) then -- Tell Minions to Teleport - Set TargetWaypointID
							if ( Player:GetRole() ~= 1) then
								wt_debug( "Recieved Leader's TargetWaypointID" )
								Settings.GW2MINION.TargetWaypointID = tonumber(msg)
							end
						elseif ( tonumber(msgID) == 21 and tonumber(msg) ~= nil) then -- Tell Minions to Teleport - Set TargetMapID
							if ( Player:GetRole() ~= 1) then
								wt_debug( "Recieved Leader's MapID : "..tostring(msg) )
								NavigationManager:SetTargetMapID(tonumber(msg))
							end
							
							
						-- DEV
						elseif ( tonumber(msgID) == 50 ) then -- Tell Minions to Load a Mesh
							if ( Player:GetRole() ~= 1 ) then
								wt_debug( "Leader sais we need should (re)load our navmesh :"..tostring(msg) )
								mm.UnloadNavMesh()
								mm.LoadNavMesh(tostring(msg))
							end	
						
						
						-- FOLLOW
						elseif ( tonumber(msgID) == 100 ) then -- Leader tells Minions to follow him
							if ( Player:GetRole() ~= 1 and tonumber(msg) ~= nil ) then								
								wt_debug( "Leader sais we should follow him.." )								
								wt_core_taskmanager:addFollowTask( tonumber(msg), 3750 )
							end
						end
					end
				end
			end
		end
	end
end


RegisterEventHandler("MULTIBOT.Message",HandleMultiBotMessages)