
wt_core_partymanager = { }
wt_core_partymanager.wnd = { name = "PartyManager", x = 350, y = 100, w = 290, h = 180}
wt_core_partymanager.visible = false
wt_core_partymanager.lasttick = 0
wt_core_partymanager.leaderName = nil
wt_core_partymanager.leaderMapID = nil
wt_core_partymanager.leaderWPID = nil
wt_core_partymanager.MSGblacklist = {}
wt_core_partymanager.WPblacklist = {}

function wt_core_partymanager.membercount()
	local count = 0
	local index, player  = next( Settings.GW2MINION.Party )
	local myname = Player.name
	while ( index ~= nil and player ~= nil ) do			
		if (tostring(player) ~= "none" and tostring(player) ~= "" and tostring(player) ~= tostring(myname)) then
			count = count + 1
		end
		index, player  = next( Settings.GW2MINION.Party,index )
	end	
	return count
end

function wt_core_partymanager.WeAreInPartyList()
	local found = false
	local index, player  = next( Settings.GW2MINION.Party )
	local myname = Player.name
	while ( index ~= nil and player ~= nil ) do			
		if (tostring(player) ~= "none" and tostring(player) ~= "" and tostring(player) == tostring(myname)) then
			found = true
		end
		index, player  = next( Settings.GW2MINION.Party,index )
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
		GUI_NewCheckbox(wt_core_partymanager.wnd.name,"Activated","gPartyMGR")
		GUI_NewField(wt_core_partymanager.wnd.name,"Status","dParty")
		GUI_NewLabel(wt_core_partymanager.wnd.name,"Enter Character Names:","GroupInfo");
		GUI_NewField(wt_core_partymanager.wnd.name,"Member1","dMember1","GroupInfo")
		GUI_NewField(wt_core_partymanager.wnd.name,"Member2","dMember2","GroupInfo")
		GUI_NewField(wt_core_partymanager.wnd.name,"Member3","dMember3","GroupInfo")
		GUI_NewField(wt_core_partymanager.wnd.name,"Member4","dMember4","GroupInfo")
		GUI_NewField(wt_core_partymanager.wnd.name,"Member5","dMember5","GroupInfo")
					
		dParty = "                            "
		gPartyMGR = Settings.GW2MINION.gPartyMGR
		dMember1 = tostring(Settings.GW2MINION.Party[1])
		dMember2 = tostring(Settings.GW2MINION.Party[2])
		dMember3 = tostring(Settings.GW2MINION.Party[3])
		dMember4 = tostring(Settings.GW2MINION.Party[4])
		dMember5 = tostring(Settings.GW2MINION.Party[5])
		
		GUI_WindowVisible(wt_core_partymanager.wnd.name,false)
	end
)

RegisterEventHandler("wt_core_partymanager.toggle", 
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
					if ( MultiBotIsConnected( ) )then
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
			wt_debug("Removing "..tostring(playername).." from the MessageBlacklist")
			wt_core_partymanager.MSGblacklist[tostring(playername)] = nil
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
		if (tostring(myname) ~= "" and tostring(myname) ~= "nil") then
			MultiBotSend( "300;"..tostring(myname),"gw2minion" )
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
				if (tostring(pname) ~= tostring(myname) and tostring(pname) ~= "none" and tostring(pname) ~= "") then
					local index, player  = next( party )
					while ( index ~= nil and player ~= nil ) do			
						if (tostring(player.name) == tostring(pname)) then
							found = true
							break
						end
						index, player  = next( party,index )
					end
					if ( not found and wt_core_partymanager.MSGblacklist[tostring(pname)] == nil) then	
						SendChatMsg(8,"/invite "..tostring(pname))
						dParty = tostring("Inviting "..tostring(pname))
						wt_debug("Inviting "..tostring(pname))
						wt_core_partymanager.MSGblacklist[tostring(pname)] = wt_core_partymanager.lasttick
						return 
					end
				end
				idx, pname  = next( setupparty,idx )
			end	
			dParty = tostring("Partymember missing..")
			return 
		else
			-- We are Minion, trying to join our party		
			if ( wt_core_partymanager.leaderName ~= nil and wt_core_partymanager.leaderName ~= "" ) then
				if ( wt_core_partymanager.leaderMapID ~= nil ) then		
					if ( Player:GetPartySize() == 0 ) then
						if ( wt_core_partymanager.leaderMapID == Player:GetLocalMapID() ) then
							wt_debug("Trying to join "..tostring(wt_core_partymanager.leaderName).."'s Party...")
							SendChatMsg(8,"/join "..tostring(wt_core_partymanager.leaderName))
							dParty = tostring("Joining Party..")
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
							local wpname = tostring(wt_core_mapdata[tonumber(wt_core_partymanager.leaderMapID)].waypoint[tonumber(wt_core_partymanager.leaderWPID)].name)
							wt_debug("Porting to Waypoint :"..tostring(wpname))
							dParty = tostring("Porting to Waypoint :"..tostring(wpname))
							wt_core_partymanager.MSGblacklist[tostring(wt_core_partymanager.leaderWPID)] = wt_core_partymanager.lasttick
							Player:TeleportToWaypoint(tonumber(wt_core_partymanager.leaderWPID))
						end
					else
						wt_debug("Unknown MapID found :"..tostring(wt_core_partymanager.leaderMapID))
						dParty = tostring("Porting to Unknown Waypoint :"..tostring(wpname))
						wt_core_partymanager.MSGblacklist[tostring(wt_core_partymanager.leaderWPID)] = wt_core_partymanager.lasttick
						Player:TeleportToWaypoint(tonumber(wt_core_partymanager.leaderWPID))
					end	
				else
					wt_debug("WaypointID was blacklisted, trying to Porting to random Waypoint near Leader")
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









