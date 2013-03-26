-- TOolbox 
tb = { }
tb.running = false
tb.visible = false
tb.lastrun = 0

function tb.ModuleInit() 	
	GUI_NewWindow("ToolBox", 450, 100, 200, 300)	
	GUI_NewButton("ToolBox","AutoUnpackAllBags","TB.unpack", "Bags_Supplies")
	GUI_NewButton("ToolBox","AutoSalvageAllItems","TB.salvage", "Bags_Supplies")
	GUI_NewButton("ToolBox","SupplyRun","TB.supplyRun","Bags_Supplies")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","devmonitor","TB.eventmon","Dev")
	GUI_NewButton("ToolBox","Minions,(Re)load Mesh","TB.reload","Dev")
	GUI_NewField("ToolBox","Meshname:","greloadmesh", "Dev");
	GUI_NewButton("ToolBox","PrintItemDataID","TB.printID","Dev")
	GUI_NewField("ToolBox","ItemName:","tb_itemname","Dev")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","GetInteractableTarget","TB.getInteractableTarget","NPC")
	GUI_NewButton("ToolBox","GetTarget","TB.getTarget","NPC")
	GUI_NewButton("ToolBox","SetTarget","TB.setTarget","NPC")
	GUI_NewButton("ToolBox","InteractTarget","TB.interactTarget","NPC")
	GUI_NewField("ToolBox","Target: ","tb_target","NPC")
	GUI_NewButton("ToolBox","GetConversationOptions","TB.getConversationOptions","NPC")
	GUI_NewButton("ToolBox","SelectConversationOption","TB.selectConversationOption","NPC")
	GUI_NewField("ToolBox","Option Number:","tb_option","NPC")
	GUI_NewSeperator("ToolBox")
	GUI_NewButton("ToolBox","PlayerPosition","TB.playerPosition","Movement")
	GUI_NewButton("ToolBox","MoveTo","TB.moveTo","Movement")
	GUI_NewButton("ToolBox","Teleport","TB.teleport","Movement")
	GUI_NewField("ToolBox","X: ","tb_xPos","Movement")
	GUI_NewField("ToolBox","Y: ","tb_yPos","Movement")
	GUI_NewField("ToolBox","Z: ","tb_zPos","Movement")
	GUI_FoldGroup("ToolBox","Movement")
	GUI_FoldGroup("ToolBox","Dev")
	GUI_FoldGroup("ToolBox","NPC")
	GUI_WindowVisible("ToolBox",false)
	tb_itemname = "          "
	tb_target = "            "

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

function tb.GetInteractableTarget()
	local t = Player:GetInteractableTarget()
	if t ~= 0 then
		local char = CharacterList:Get(t)
		tb_target = tostring(t)
		GUI_RefreshWindow()
		d("Interactable Target: "..tostring(char.name).." "..tostring(t))
	else
		d("No Interactable Target")
	end
end

function tb.GetTarget()
	local t = Player:GetTarget()
	if t ~= 0 then
		local char = CharacterList:Get(t)
		tb_target = tostring(t)
		GUI_RefreshWindow()
		d("Current Target: "..tostring(char.name).." "..tostring(t))
	else
		d("No Current Target")
	end
end

function tb.SetTarget()
	local t = Player:SetTarget(tonumber(tb_target))
	if t == true then
		local char = CharacterList:Get(tb_target)
		d("Target Set: "..tostring(char.name).. " "..tostring(tb_target))
	elseif t == false then
		d("Target Set Error")
	else
		d("t = nil")
	end
end

function tb.InteractTarget()
	local t = Player:Interact(tonumber(tb_target))
	local char = CharacterList:Get(tb_target)
	if t == true and char ~= nil then
		d("Interact with: "..tostring(char.name).." "..tb_target.." successful")
	elseif t == false and char ~= nil then
		d("Interact with: "..tostring(char.name).." "..tb_target.." failed")
	else
		d("No target selected or could not get target")
	end
end

function tb.GetConversationOptions()
	local t = Player:GetConversationOptions()
	if t ~= nil then
		for key, option in pairs(t) do
			d("Option Index (For Selection): "..tostring(key)..", Option Number (GW2.Enum): "..tostring(option))
		end
	else
		d("No conversation options")
	end
end

function tb.SelectConversationOption()
	local t = nil
	t = Player:SelectConversationOptionByIndex(tonumber(tb_option))
	if t ~=  false then
		d("Conversation option "..tb_option.." selected")
	else
		d("Could not select conversation option")
	end
end

function tb.PlayerPosition()
	d(Player.pos)
	tb_xPos = tostring(Player.pos.x)
	tb_yPos = tostring(Player.pos.y)
	tb_zPos = tostring(Player.pos.z)
	GUI_RefreshWindow()
end

function tb.MoveTo()
	wt_debug("Moving to target..")
	Player:MoveTo(tonumber(tb_xPos),tonumber(tb_yPos),tonumber(tb_zPos))
end

function tb.Teleport()
	Player:Teleport(tonumber(tb_xPos),tonumber(tb_yPos),tonumber(tb_zPos))
end

function tb.PrintDataID()
	for id, item in pairs(ItemList("")) do
		if(tostring(item.name) == tb_itemname) then
			d(tostring(id))
			d(item.name..": "..tostring(item.dataID))
		end
	end
end

function tb.OnUpdate( event, tickcount )
	if (tb.running ) then	
		if (tickcount - tb.lastrun > 150) then
			tb.lastrun = tickcount				
			if (wt_core_taskmanager.current_task ~= nil) then
				wt_core_taskmanager:DoTask()								
			else			
				tb.running = false				
			end			
		end	
	end
end

function tb.UnpackBags()
	if (wt_core_taskmanager.current_task == nil) then
		local newtask = inheritsFrom( wt_task )
		newtask.UID = "UNPACKBAG"
		newtask.name = "Opening Bags"
		newtask.timestamp = 0
		newtask.lifetime = 0
		newtask.priority = 15000
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
				while (id ~=nil and item ~= nil ) do	
					local itemid = item.dataID
					if ( itemid == 10169 or itemid == 21867 
					or itemid == 11542 or itemid == 11540 or itemid == 11540 
					or itemid == 11455 or itemid == 11455 or itemid == 11456 
					or itemid == 11456 or itemid == 11519 or itemid == 11509 
					or itemid == 11496 or itemid == 11472 or itemid == 11504 
					or itemid == 11483 or itemid == 11454) then --ADD MORE IDs HERE
						wt_debug( "Opening Bag..")
						opened = true					
						item:Use()
					end
					id,item = next(inv,id)
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
		wt_debug("Unpack Bag Task added..")
	else
		wt_core_taskmanager.current_task = nil
		tb.running = false
	end
end

function tb.AutoSalvage()	
	if (wt_core_taskmanager.current_task == nil) then	
		local newtask = inheritsFrom( wt_task )
		newtask.UID = "AUTOSALVAGE"
		newtask.timestamp = 0
		newtask.lifetime = 0
		newtask.name = "Salvage All Items"
		newtask.priority = 15000
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
	if (wt_core_taskmanager.current_task == nil) then
		wt_core_taskmanager:addVendorTask(15000)
		tb.running = true		
		wt_debug("Doing Supply Run")
		if (TableSize(wt_core_taskmanager.Customtask_list) == 1) then
			i,wt_core_taskmanager.current_task = next(wt_core_taskmanager.Customtask_list)
			wt_core_taskmanager.Customtask_list = {}
		end
	else
		wt_core_taskmanager.current_task = nil
		tb.running = false
		wt_debug("Stopping Supply Run")
	end	
	--wt_core_taskmanager:addRepairTask(15000)
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
RegisterEventHandler("TB.eventmon", devmonitor.ToggleMenu)
RegisterEventHandler("TB.supplyRun", tb.DoSupplyRun)
RegisterEventHandler("TB.getInteractableTarget", tb.GetInteractableTarget)
RegisterEventHandler("TB.getTarget", tb.GetTarget)
RegisterEventHandler("TB.setTarget", tb.SetTarget)
RegisterEventHandler("TB.interactTarget", tb.InteractTarget)
RegisterEventHandler("TB.getConversationOptions", tb.GetConversationOptions)
RegisterEventHandler("TB.selectConversationOption", tb.SelectConversationOption)
RegisterEventHandler("TB.playerPosition",tb.PlayerPosition)
RegisterEventHandler("TB.moveTo", tb.MoveTo)
RegisterEventHandler("TB.teleport", tb.Teleport)
RegisterEventHandler("Gameloop.Update",tb.OnUpdate)
RegisterEventHandler("Module.Initalize",tb.ModuleInit)
