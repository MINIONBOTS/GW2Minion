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
								if ( gNavSwitchEnabled == "1" ) then									
									local wp = WaypointList("nearest,samezone,notcontested,onmesh")									
									if ( TableSize( wp ) > 0 ) then
										i, entry = next( wp )
										if ( i ~= nil and entry~= nil) then
											wt_debug( "Sending Minions my mapID: "..tostring(Player:GetLocalMapID()) )									
											MultiBotSend( "21;"..tostring(Player:GetLocalMapID()),"gw2minion" )
											wt_debug( "Sending Minions nearest WaypointID: "..tostring(entry.contentID) )
											MultiBotSend( "20;"..tostring(entry.contentID),"gw2minion" )											
										end
									end
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
						
						-- VENDORBUY
						elseif ( tonumber(msgID) == 12 ) then -- A minion needs to Vendor, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								local taskSet = false
								if (gBuyGatheringTools == "1" and wt_core_items:NeedGatheringTools() and ItemList.freeSlotCount > tonumber(gGatheringToolStock)) then
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.ftool, tonumber(gGatheringToolStock),gGatheringToolQuality)
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.ltool, tonumber(gGatheringToolStock),gGatheringToolQuality)
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.mtool, tonumber(gGatheringToolStock),gGatheringToolQuality)
									taskSet = true
								end
								if (gBuySalvageKits == "1" and wt_core_items:NeedSalvageKits() and ItemList.freeSlotCount > tonumber(gSalvageKitStock)) then
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.skit, tonumber(gSalvageKitStock),gSalvageKitQuality)
									taskSet = true
								end
								-- add a vendor task anyway so that the bot will run to vendor
								if (not taskSet) then
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.skit, tonumber(gSalvageKitStock),gSalvageKitQuality)
								end
								wt_debug( "A Minion needs to purchase from vendor, going to Vendor" )
							end
						elseif ( tonumber(msgID) == 13 ) then -- Leader tells Minions to Vendor
							if ( Player:GetRole() ~= 1 ) then
								if (gBuyGatheringTools == "1" and wt_core_items:NeedGatheringTools() and ItemList.freeSlotCount > tonumber(gGatheringToolStock)) then
										wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.ftool, tonumber(gGatheringToolStock),gGatheringToolQuality)
										wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.ltool, tonumber(gGatheringToolStock),gGatheringToolQuality)
										wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.mtool, tonumber(gGatheringToolStock),gGatheringToolQuality)
								end
								if (gBuySalvageKits == "1" and wt_core_items:NeedSalvageKits() and ItemList.freeSlotCount > tonumber(gSalvageKitStock)) then
									wt_core_taskmanager:addVendorBuyTask(4750, wt_core_items.skit, tonumber(gSalvageKitStock),gSalvageKitQuality)
								end
								wt_debug( "Leader sais we should Vendor now.." )
							end
						
							
						-- REPAIR
						elseif ( tonumber(msgID) == 15 ) then -- A minion needs to Repair, set our Primary task accordingly
							if ( Player:GetRole() == 1) then
								wt_debug( "A Minion needs to repair, going to Merchant" )
								wt_core_taskmanager:addRepairTask(4500)
							end
						elseif ( tonumber(msgID) == 16 ) then -- Leader tells Minions to Repair
							if ( gEnableRepair == "1" and NeedRepair() and Player:GetRole() ~= 1 ) then
								wt_debug( "Leader sais we should Repair now.." )
								wt_core_taskmanager:addRepairTask(4500)		
							end
						
						-- 	Blacklist Vendor
						elseif ( tonumber(msgID) == 17 and tonumber(msg) ~= nil) then -- A minion wants leader to blacklist vendor
							if ( Player:GetRole() == 1) then
								wt_core_taskmanager.vendorBlacklist[tonumber(msg)] = true
								wt_debug( "A minion said to blacklist vendor "..msg )
							end
						elseif ( tonumber(msgID) == 18 and tonumber(msg) ~= nil) then -- Leader tells minions to blacklist vendor
							if ( Player:GetRole() ~= 1 ) then
								wt_core_taskmanager.vendorBlacklist[tonumber(msg)] = true
								wt_debug( "Leader said to blacklist vendor "..msg )
							end		
						
						
						-- NAVMESHSWITCH
						elseif ( tonumber(msgID) == 20 and tonumber(msg) ~= nil) then -- Tell Minions to Teleport - Set TargetWaypointID
							if ( Player:GetRole() ~= 1) then
								wt_debug( "Recieved Leader's TargetWaypointID : "..tostring(msg) )
								Settings.GW2MINION.TargetWaypointID = tonumber(msg)
							end
						elseif ( tonumber(msgID) == 21 and tonumber(msg) ~= nil) then -- Tell Minions to Teleport - Set TargetMapID
							if ( Player:GetRole() ~= 1) then
								wt_debug( "Recieved Leader's MapID : "..tostring(msg) )
								NavigationManager:SetTargetMapID(tonumber(msg))
							end
							
						-- 	Blacklist Event
						elseif ( tonumber(msgID) == 22 and tonumber(msg) ~= nil) then -- A minion wants leader to blacklist event
							if ( Player:GetRole() == 1) then
								wt_core_taskmanager:BlacklistEvent(tonumber(msg))
								wt_debug( "A minion said to blacklist event "..msg )
							end
						elseif ( tonumber(msgID) == 23 and tonumber(msg) ~= nil) then -- Leader tells minions to blacklist event
							if ( Player:GetRole() ~= 1 ) then
								wt_core_taskmanager:BlacklistEvent(tonumber(msg))
								wt_debug( "Leader said to blacklist event "..msg )
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