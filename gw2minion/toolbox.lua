-- TOolbox 
tb = { }
tb.running = false
tb.visible = false
tb.lastrun = 0

function tb.ModuleInit() 	
	GUI_NewWindow("ToolBox", 450, 100, 200, 300)	
	GUI_NewButton("ToolBox","AutoUnpackAllBags","TB.unpack")
	GUI_NewSeperator("ToolBox")	
	GUI_NewButton("ToolBox","AutoSalvageAllItems","TB.salvage")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","EventMonitor","TB.eventmon")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","Minions,(Re)load Mesh","TB.reload")
	GUI_NewField("ToolBox","Meshname:","greloadmesh");
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","PrintItemDataID","TB.printID")
	GUI_NewField("ToolBox","ItemName:","tb_itemname")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","SupplyRun","TB.supplyRun")
	GUI_NewButton("ToolBox","TestFunction","TB.testfx")
	GUI_WindowVisible("ToolBox",false)
	tb_itemname = "          "

end

function tb.ToggleMenu()
	if (tb.visible) then
		GUI_WindowVisible("ToolBox",false)	
		tb.visible = false
	else
		GUI_WindowVisible("ToolBox",true)	
		tb.visible = true
	end
end

function tb.TestFunction()
	item = ItemList:Get(1)
	d(item.dataID)
end

function tb.PrintDataID()
	for id, item in pairs(ItemList("")) do
		if(tostring(item.name) == tb_itemname) then
			d(tostring(id))
			d(item.name..": "..item.dataID)
		end
	end
end

function tb.OnUpdate( event, tickcount )
	if (tb.running ) then
		if (tickcount - tb.lastrun > 150) then
			tb.lastrun = tickcount	
			if (not wt_core_taskmanager:CheckPrioTask()) then
				tb.running = false
			else
				wt_core_taskmanager:DoPrioTask()
			end			
		end	
	end
end

function tb.UnpackBags()
	if (wt_core_taskmanager.current_task == nil) then
		local newtask = inheritsFrom( wt_task )
		newtask.name = "Opening Bags"
		newtask.priority = 1500
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 150
		newtask.deposited = false
		
		function newtask:execute()
			local opened = false
			if (ItemList.freeSlotCount > 1) then
				newtask.deposited = false
				local inv = ItemList("")	
				id,item = next(inv)
				if (id ~=nil and item ~= nil ) then	
					local itemid = item.dataID
					if ( itemid == 10169 or itemid == 21867 
					or itemid == 11542 or itemid == 11540 or itemid == 11540 
					or itemid == 11455 or itemid == 11455 or itemid == 11456 
					or itemid == 11456 or itemid == 11519 or itemid == 11509 
					or itemid == 11496 or itemid == 11472 or itemid == 11504 
					or itemid == 11483) then --ADD MORE IDs HERE
						wt_debug( "Opening Bag..")
						opened = true					
						item:Use()
					end
				end
			else 
				if (not newtask.deposited) then
					Inventory:DepositCollectables()
					newtask.deposited = true
					opened = true
				end
			end
			
			if(not opened) then
				newtask.done = true
			end
		end
				
		function newtask:isFinished()
			if ( newtask.done ) then				
				wt_core_taskmanager.current_task = nil
				return true
			end
			return false
		end	
		
		wt_core_taskmanager.current_task = newtask
		tb.running = true
	else
		wt_core_taskmanager.current_task = nil
		tb.running = false
	end
end

function tb.AutoSalvage()	
	if (wt_core_taskmanager.current_task == nil) then	
		local newtask = inheritsFrom( wt_task )
		newtask.name = "Salvage All Items"
		newtask.priority = 1500
		newtask.done = false
		newtask.last_execution = 0
		newtask.throttle = 150
		newtask.deposited = false
		newtask.lastitemID = 0
		newtask.lastitemstacksize = 0
		newtask.ignorelist = {}
		
		function newtask:execute()
			local taskran = false
			if (ItemList.freeSlotCount > 1) then
				newtask.deposited = false
				local inventory = ItemList("")
				local salvageItems = {}
				local salvageTools = {}
				id , item = next(inventory)
				while ( id ~= nil ) do
					if ( item ~= nil and not item.soulbound and item.rarity < 4 and ( item.itemtype == GW2.ITEMTYPE.Armor or item.itemtype == GW2.ITEMTYPE.Weapon or item.itemtype == GW2.ITEMTYPE.Trophy ) and not table.contains(newtask.ignorelist, item.dataID)) then						
						table.insert(salvageItems,item)
					elseif ( item.itemtype == GW2.ITEMTYPE.SalvageTool ) then
						table.insert(salvageTools,item)
					end
					id, item  = next(inventory,id)
				end				
				if ( TableSize(salvageItems) > 0 and TableSize(salvageTools) >0 ) then
					id , item = next(salvageItems)
					tid , tool = next(salvageTools)
					if ( id ~= nil and item ~= nil and tid ~=nil and tool ~= nil ) then
						if ( Player:GetCurrentlyCastedSpell() == 17 ) then
							wt_debug("Salvaging item " .. tostring(item.name) .. " with " .. tostring(tool.name))
							tool:Use(item)
							taskran = true
							if (newtask.lastitemID == 0 or newtask.lastitemID ~= item.dataID or (newtask.lastitemID == item.dataID and item.stackcount < newtask.lastitemstacksize)) then
								newtask.lastitemID = item.dataID
								newtask.lastitemstacksize = item.stackcount
							else
								wt_debug("Cannot Salvage item: "..tostring(item.name).." ignoring it")
								table.insert(newtask.ignorelist,item.dataID)
							end
						end
					end
				end
			else 
				if (not newtask.deposited) then
					Inventory:DepositCollectables()
					newtask.deposited = true
					taskran = true
				end
			end
			
			if(not taskran) then
				newtask.done = true
			end
		end
				
		function newtask:isFinished()
			if ( newtask.done ) then
				wt_core_taskmanager.current_task = nil
				return true
			end
			return false
		end	
		wt_debug("Salvaging Task Added..")
		wt_core_taskmanager.current_task = newtask
		tb.running = true
	else
		wt_core_taskmanager.current_task = nil
		tb.running = false
	end
end

function tb.DoSupplyRun()
	wt_core_taskmanager:addVendorTask({keep_in_queue = true, priority = 10001, task_type = "custom"})
	wt_core_taskmanager:addRepairTask({keep_in_queue = true, priority = 10001, task_type = "custom"})
end

function tb:repairNowTask()
	local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
	if ( TableSize( EList ) > 0 ) then
		local nextTarget
		nextTarget, E = next( EList )
		if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
			local newtask = inheritsFrom( wt_task )
			newtask.name = "GoTo Repair"
			newtask.priority = wt_task.priorities.repair
			newtask.position = E.pos
			newtask.done = false
			newtask.last_execution = 0
			newtask.throttle = 500
			
			local mypos = Player.pos
			local wps = WaypointList("samezone,onmesh")
			local bestWP = nil
			if(newtask.last_execution == 0) then
				if(wps~=nil) then
					local bestDistance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z)
					local i,wp = next(wps)
					while (i~=nil and wp~=nil) do
						local tempDistance = Distance3D( wp.pos.x, wp.pos.y, wp.pos.z, newtask.position.x, newtask.position.y, newtask.position.z )
						if tempDistance < bestDistance then
							bestDistance = tempDistance
							bestWP = wp
						end
						i,wp = next(wps,i)
					end
				end
				if bestWP ~= nil then
					d("teleporting to repair at"..tostring(bestWP.name))
					Player:TeleportToWaypoint(bestWP.contentID)
				end
			end
	
			function newtask:execute()
				mypos = Player.pos
				distance = Distance3D( newtask.position.x, newtask.position.y, newtask.position.z, mypos.x, mypos.y, mypos.z)
				if ( distance > 150 ) then
						--wt_debug("Walking towards new PointOfInterest ")	
					if ( (wt_global_information.Now - newtask.last_execution) > newtask.throttle ) then
						Player:MoveTo( newtask.position.x, newtask.position.y, newtask.position.z, 50 )
						newtask.last_execution = wt_global_information.Now
					end
					newtask.name = "GoTo Repair, dist: "..(math.floor(distance))
				else
					local EList = MapObjectList( "onmesh,nearest,type="..GW2.MAPOBJECTTYPE.RepairMerchant )
					if ( TableSize( EList ) > 0 ) then
						local nextTarget
						nextTarget, E = next( EList )
						if ( nextTarget ~= nil and nextTarget ~= 0 ) then				
							wt_debug( "RepairMerchant nearby.." )
							wt_core_state_repair.setTarget( nextTarget )
							MultiBotSend( "16;"..nextTarget,"gw2minion" )
							wt_core_controller.requestStateChange( wt_core_state_repair )
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
			if not newtask.done then
				wt_core_taskmanager:addCustomtask(newtask)
			end
		end
	end
end

function tb.MinionsloadMesh()
	wt_debug("Telling Minions to (re)load mesh: "..tostring(greloadmesh))
	if (greloadmesh ~= nil and greloadmesh ~= "" and gMinionEnabled == "1" and MultiBotIsConnected( )) then
		MultiBotSend( "50;"..greloadmesh,"gw2minion" )
	end
end

RegisterEventHandler("TB.printID", tb.PrintDataID)
RegisterEventHandler("TB.toggle", tb.ToggleMenu)
RegisterEventHandler("TB.unpack", tb.UnpackBags)
RegisterEventHandler("TB.salvage", tb.AutoSalvage)
RegisterEventHandler("TB.reload", tb.MinionsloadMesh)
RegisterEventHandler("TB.eventmon", eventmonitor.ToggleMenu)
RegisterEventHandler("TB.supplyRun", tb.DoSupplyRun)
RegisterEventHandler("TB.testfx", tb.TestFunction)
RegisterEventHandler("Gameloop.Update",tb.OnUpdate)
RegisterEventHandler("Module.Initalize",tb.ModuleInit)
