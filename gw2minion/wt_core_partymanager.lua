
wt_core_partymanager = { }
wt_core_partymanager.wnd = { name = strings[gCurrentLanguage].partyManager, x = 350, y = 100, w = 290, h = 220}
wt_core_partymanager.visible = false
wt_core_partymanager.lasttick = 0
wt_core_partymanager.leaderName = nil
wt_core_partymanager.leaderMapID = nil
wt_core_partymanager.leaderWPID = nil
wt_core_partymanager.MSGblacklist = {}
wt_core_partymanager.WPblacklist = {}

function wt_core_partymanager.membercount()
	local count = 0
	if ( Settings.GW2MINION.Party ) then
		local partylist = Settings.GW2MINION.Party
		if ( TableSize(partylist) > 0 ) then
			local index, player  = next( partylist )
			local myname = Player.name
			while ( index ~= nil and player ~= nil ) do			
				if (player ~= "none" and player ~= "" and player ~= myname) then
					count = count + 1
				end
				index, player  = next( partylist,index )
			end	
		end
	end
	return count
end

function wt_core_partymanager.GetMyListIndex() 
	local count = 0
	if ( Settings.GW2MINION.Party ) then
		local partylist = Settings.GW2MINION.Party
		if ( TableSize(partylist) > 0 ) then
			local index, player  = next( partylist )
			local myname = Player.name
			while ( index ~= nil and player ~= nil ) do			
				count = count + 1
				if (player == myname) then
					break
				end
				index, player  = next( partylist,index )
			end	
		end
	end
	return count
end

function wt_core_partymanager.WeAreInPartyList()
	local found = false
	if ( Settings.GW2MINION.Party ) then
		local partylist = Settings.GW2MINION.Party
		if ( TableSize(partylist) > 0 ) then
			local index, player  = next( partylist )
			local myname = Player.name
			while ( index ~= nil and player ~= nil ) do			
				if (player ~= "none" and player ~= "" and player == myname) then
					found = true
				end
				index, player  = next( partylist,index )
			end	
		end
	end
	return found
end

RegisterEventHandler("Module.Initalize",
	function (PMGR)
		if (Settings.GW2MINION.gPartyMGR == nil) then
			Settings.GW2MINION.gPartyMGR = "0"
		end
		if (Settings.GW2MINION.Party == nil) then
			Settings.GW2MINION.Party = {}
			for id=1,5 do
				if (Settings.GW2MINION.Party[id] == nil) then
					Settings.GW2MINION.Party[id] = "none"
				end				
			end
			Settings.GW2MINION.Party = Settings.GW2MINION.Party
		end		
		
		local wnd = GUI_GetWindowInfo("GW2Minion")
		GUI_NewWindow(wt_core_partymanager.wnd.name,wnd.x+wnd.width,wnd.y,wt_core_partymanager.wnd.w,wt_core_partymanager.wnd.h)
		GUI_NewCheckbox(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].activated,"gPartyMGR",strings[gCurrentLanguage].generalSettings)
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].status,"dParty",strings[gCurrentLanguage].generalSettings)
		GUI_NewLabel(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].enterCharNames,strings[gCurrentLanguage].groupInfo);
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].member1,"dMember1",strings[gCurrentLanguage].groupInfo)
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].member2,"dMember2",strings[gCurrentLanguage].groupInfo)
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].member3,"dMember3",strings[gCurrentLanguage].groupInfo)
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].member4,"dMember4",strings[gCurrentLanguage].groupInfo)
		GUI_NewField(wt_core_partymanager.wnd.name,strings[gCurrentLanguage].member5,"dMember5",strings[gCurrentLanguage].groupInfo)
					
		dParty = "                            "
		gPartyMGR = Settings.GW2MINION.gPartyMGR
		dMember1 = (Settings.GW2MINION.Party[1])
		dMember2 = (Settings.GW2MINION.Party[2])
		dMember3 = (Settings.GW2MINION.Party[3])
		dMember4 = (Settings.GW2MINION.Party[4])
		dMember5 = (Settings.GW2MINION.Party[5])
		
		GUI_WindowVisible(wt_core_partymanager.wnd.name,false)
	end
)

RegisterEventHandler("PartyManager.toggle", 
	function ()
		if (wt_core_partymanager.visible) then
		GUI_WindowVisible(wt_core_partymanager.wnd.name,false)	
		wt_core_partymanager.visible = false
		else
			local wnd = GUI_GetWindowInfo("GW2Minion")	
			GUI_MoveWindow( wt_core_partymanager.wnd.name, wnd.x+wnd.width,wnd.y) 
			GUI_WindowVisible(wt_core_partymanager.wnd.name,true)	
			wt_core_partymanager.visible = true
		end
	end
)

RegisterEventHandler("GUI.Update",
	function(pEvent, pNewVals, pOldVals)
		for k,v in pairs(pNewVals) do
			if ( k == "gPartyMGR" )	then Settings.GW2MINION[tostring(k)] = v
				
			elseif (k == "dMember1") then Settings.GW2MINION.Party[1] = v Settings.GW2MINION.Party = Settings.GW2MINION.Party
			elseif (k == "dMember2") then Settings.GW2MINION.Party[2] = v Settings.GW2MINION.Party = Settings.GW2MINION.Party
			elseif (k == "dMember3") then Settings.GW2MINION.Party[3] = v Settings.GW2MINION.Party = Settings.GW2MINION.Party
			elseif (k == "dMember4") then Settings.GW2MINION.Party[4] = v Settings.GW2MINION.Party = Settings.GW2MINION.Party
			elseif (k == "dMember5") then Settings.GW2MINION.Party[5] = v Settings.GW2MINION.Party = Settings.GW2MINION.Party
			end
		end
		GUI_RefreshWindow(wt_core_partymanager.wnd.name)
	end
)

RegisterEventHandler("Gameloop.Update",
	function ( PMGR, tick )
		if ( tick - wt_core_partymanager.lasttick > 3000 ) then
			wt_core_partymanager.lasttick = tick
			
			wt_core_partymanager.UpdateBlacklists()
			
			if (gPartyMGR == "1") then
				if ( gMinionEnabled == "1" ) then
					if ( MultiBotIsConnected() )then
						wt_core_partymanager.SendGroupInfo()
						wt_core_partymanager.CheckGroupStatus()
					else
						dParty = tostring("No Connection to Multibotserver..")
					end
				else
					dParty = tostring("Groupbotting Disabled..")
				end
			else
				dParty = tostring("Disabled..")
			end	
		end
	end
)

function wt_core_partymanager.UpdateBlacklists()
	-- Blacklist for sending Invites
	local playername, timestamp  = next( wt_core_partymanager.MSGblacklist )	
	while ( playername ~= nil and tonumber(timestamp) ~= nil ) do			
		if ( wt_core_partymanager.lasttick - tonumber(timestamp) > math.random(45000,75000)) then
			wt_debug("Removing "..playername.." from the MessageBlacklist")
			wt_core_partymanager.MSGblacklist[playername] = nil
		end
		playername, timestamp  = next( wt_core_partymanager.MSGblacklist,playername )
	end	
	-- Blacklist for throttling Teleport to waypoint	
	local id, timestamp  = next( wt_core_partymanager.WPblacklist )	
	while ( tonumber(id) ~= nil and tonumber(timestamp) ~= nil ) do			
		if ( wt_core_partymanager.lasttick - tonumber(timestamp) > 60000 ) then
			wt_debug("Removing "..tostring(id).." from the WaypointBlacklist")
			wt_core_partymanager.WPblacklist[tostring(id)] = nil
		end
		id, timestamp  = next( wt_core_partymanager.WPblacklist,id )
	end	
end

function wt_core_partymanager.SendGroupInfo()
	-- Send Minions the Leader data
	if (Player:GetRole() == 1 ) then		
		local myname = Player.name
		myname = Player.name
		if (myname ~= nil and myname ~= "") then
			MultiBotSend( "300;"..myname,"gw2minion" )
		end
		local mymapID = Player:GetLocalMapID()
		if (tonumber(mymapID) ~= nil) then
			MultiBotSend( "301;"..tostring(mymapID),"gw2minion" )
		end	
		local myWP = WaypointList("nearest,samezone,notcontested,onmesh")
		if (TableSize(myWP) == 0) then
			myWP = WaypointList("nearest,samezone,notcontested")
		end
		if (TableSize(myWP) == 1) then
			local id,e = next (myWP)
			if ( id ~= nil) then
				local WP = WaypointList:Get(id)
				if (WP ~= nil) then
					local wpID = WP.contentID
					if ( tonumber(wpID) ~= nil) then
						MultiBotSend( "302;"..tostring(wpID),"gw2minion" )
					end
				end
			end
		end	
	end
end

function wt_core_partymanager.CheckGroupStatus()		
	local party = Player:GetPartyMembers()	
	if (party ~= nil and TableSize(party) < wt_core_partymanager.membercount() and wt_core_partymanager.WeAreInPartyList()) then					
		-- We are not in a Party
		if (Player:GetRole() == 1 ) then
			-- We are Leader, invite all members
			local myname = Player.name			
			local setupparty = Settings.GW2MINION.Party
			local idx, pname  = next( setupparty )
			while ( idx ~= nil and pname ~= nil ) do
				local found = false
				if ((pname) ~= (myname) and (pname) ~= "none" and (pname) ~= "") then
					local index, player  = next( party )
					while ( index ~= nil and player ~= nil ) do			
						if ((player.name) == (pname)) then
							found = true
							break
						end
						index, player  = next( party,index )
					end
					if ( not found and wt_core_partymanager.MSGblacklist[(pname)] == nil) then	
						SendChatMsg(19,"/invite "..pname)
						dParty = "Inviting "..pname
						wt_debug("Inviting "..pname)
						wt_core_partymanager.MSGblacklist[pname] = wt_core_partymanager.lasttick
						return 
					end
				end
				idx, pname  = next( setupparty,idx )
			end	
			dParty = "Partymember missing.."
			return 
		else
			-- We are Minion, trying to join our party	
			if ( wt_core_partymanager.leaderName ~= nil and wt_core_partymanager.leaderName ~= "" ) then
				if ( wt_core_partymanager.leaderMapID ~= nil ) then		
					if (not wt_core_dungeonmanager.MapIsDungeon(tonumber(wt_core_partymanager.leaderMapID))) then
						if ( Player:GetPartySize() == 0 ) then
							if ( wt_core_partymanager.leaderMapID == Player:GetLocalMapID() ) then
								wt_debug("Trying to join "..wt_core_partymanager.leaderName.."'s Party...")
								SendChatMsg(19,"/join "..wt_core_partymanager.leaderName)
								dParty = "Joining Party.."
								return
							else
								-- Follow Leader to his Map & nearest Waypoint if possible
								dParty = tostring("Following Leader to his Map..")
								wt_core_partymanager.WaypointToLeadersMap()								
							end
						else
							-- We are in a Party, follow the Leader..
							if ( wt_core_partymanager.leaderMapID == Player:GetLocalMapID() ) then
								dParty = tostring("In a Party")
							else
								-- Follow Leader to his Map & nearest Waypoint if possible
								dParty = tostring("Following Leader to his Map..")
								wt_core_partymanager.WaypointToLeadersMap()							
							end						
						end
					else
						dParty = tostring("Leader is in a Dungeon..")
						if (Player:GetPartySize() == 0) then
							wt_debug("Trying to Join "..wt_core_partymanager.leaderName.."'s Party...")
							SendChatMsg(19,"/join "..wt_core_partymanager.leaderName)
						end
					end
				else
					dParty = tostring("Waiting for LeaderMapID")
				end
			else
				dParty = tostring("Waiting for LeaderName")
			end			
		end			
	else
		dParty = tostring("Party Complete")
	end
end

function wt_core_partymanager.WaypointToLeadersMap()
	if ( tonumber(wt_core_partymanager.leaderWPID) ~= nil ) then
		if (not Player.inCombat) then
			if (Inventory:GetInventoryMoney() > 500) then
				if (wt_core_partymanager.MSGblacklist[tostring(wt_core_partymanager.leaderWPID)] == nil) then
					if ( wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)] ~= nil ) then
						if ( wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)].waypoint[tonumber(wt_core_partymanager.leaderWPID)] ~= nil) then
							local wpname = (wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)].waypoint[tonumber(wt_core_partymanager.leaderWPID)].name)
							wt_debug("Porting to Waypoint :"..(wpname))
							dParty = ("Porting to Waypoint :"..(wpname))
							wt_core_partymanager.MSGblacklist[tostring(wt_core_partymanager.leaderWPID)] = wt_core_partymanager.lasttick
							Player:TeleportToWaypoint(tonumber(wt_core_partymanager.leaderWPID))
						end
					else
						wt_debug("Unknown MapID found :"..tostring(wt_core_partymanager.leaderMapID))
						dParty = ("Porting to Unknown Waypoint :"..(wpname))
						wt_core_partymanager.MSGblacklist[tostring(wt_core_partymanager.leaderWPID)] = wt_core_partymanager.lasttick
						Player:TeleportToWaypoint(tonumber(wt_core_partymanager.leaderWPID))
					end	
				else
					wt_debug("WaypointID was blacklisted, trying to Porting to random Waypoint near Leader")
					if ( wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)] ~= nil ) then
						local id,name = next (wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)].waypoint)
						while (id ~= nil and name ~= nil) do
							if (wt_core_partymanager.MSGblacklist[tostring(id)] == nil ) then											
								wt_core_partymanager.MSGblacklist[tostring(id)] = wt_core_partymanager.lasttick
								dParty = tostring("Porting to random Waypoint near Leader")
								Player:TeleportToWaypoint(tonumber(id))									
								break																																
							end
							id,name = next (wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)].waypoint,id)
						end
					end
					dParty = tostring("No random Waypoint near Leader found..")
				end
			else
				dParty = tostring("Not enough MONEY to Port :(..")
			end
		else
			dParty = tostring("Player in Combat, waiting..")
		end
	else
		dParty = tostring("Waiting for Leaders WaypointID")
	end	
end

function wt_core_partymanager.RebuildParty()
	if (Player:GetRole() == 1) then
		MultiBotSend( "303;none","gw2minion" )
	end
	wt_debug("Leaving Party...")
	SendChatMsg(19,"/leave")
	wt_core_partymanager.lasttick = wt_core_partymanager.lasttick + 5000
end






