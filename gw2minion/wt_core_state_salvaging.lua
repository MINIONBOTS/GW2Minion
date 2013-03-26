-- The salvaging State
-- Walking towards nearest Merchant n sell and buy stuff

-- We inherit from wt_core_state, which gives us: function wt_core_state:run(), function wt_core_state:add( kelement ) and function wt_core_state:register()
wt_core_state_salvaging = inheritsFrom(wt_core_state)
wt_core_state_salvaging.name = "Salvaging"
wt_core_state_salvaging.kelement_list = { }



-- utility functions
function wt_core_state_salvaging.ShouldSalvage(item)
	if ( item ~= nil and not item.soulbound and ( item.itemtype ==  GW2.ITEMTYPE.Armor or item.itemtype ==  GW2.ITEMTYPE.Weapon )) then
		salSet = Settings.GW2MINION.salvagesettings[item.rarity]
		if ( salSet~=nil and salSet.salvage == "1" ) then
			return true
		end
	end
	return false
end

function wt_core_state_salvaging.GetSalvageableItems()
	local inventory = ItemList("")
	local salvageItems = {}
	local salvageTools = {}
	id , item = next(inventory)
	while ( id ~= nil ) do
		if ( wt_core_state_salvaging.ShouldSalvage(item) ) then
			table.insert(salvageItems,item)
		elseif ( item.itemtype == GW2.ITEMTYPE.SalvageTool ) then
			table.insert(salvageTools,item)
		end
		id, item  = next(inventory,id)
	end
	return salvageItems,salvageTools
end

-- To be added to the idle state
local c_need_salvage = inheritsFrom(wt_cause)
local e_need_salvage = inheritsFrom(wt_effect)

function c_need_salvage:evaluate()
	
	if ( ItemList.freeSlotCount < 5) then
		local items,tools = wt_core_state_salvaging.GetSalvageableItems()
		if ( TableSize(items) > 0 and TableSize(tools) >0 ) then
			return true
		end
	end
	return false
end

function e_need_salvage:execute()
	wt_core_controller.requestStateChange( wt_core_state_salvaging )
end


local c_salvage = inheritsFrom(wt_cause)
local e_salvage = inheritsFrom(wt_effect)

function c_salvage:evaluate()
	c_salvage.items, c_salvage.tools = wt_core_state_salvaging.GetSalvageableItems()
	if ( TableSize(c_salvage.items) > 0 and TableSize(c_salvage.tools) >0 ) then
		return true
	end
	return false
end

e_salvage.throttle = math.random( 800, 1000 )
function e_salvage:execute()
	id , item = next(c_salvage.items)
	tid , tool = next(c_salvage.tools)
	
	if ( id ~= nil and item ~= nil and tid ~=nil and tool ~= nil ) then
		if ( Player:GetCurrentlyCastedSpell() == 17 ) then
			wt_debug("salvaging item " .. tostring(item.name) .. " with " .. tostring(tool.name))
			tool:Use(item)
			--item:Salvage()
		end
	end
end


local c_salvage_done = inheritsFrom(wt_cause)
local e_salvage_done = inheritsFrom(wt_effect)

function c_salvage_done:evaluate()
	c_salvage.items, c_salvage.tools = wt_core_state_salvaging.GetSalvageableItems()
	if ( TableSize(c_salvage.items) == 0 or TableSize(c_salvage.tools)  == 0 ) then
		return true
	end
	return false
end

function e_salvage_done:execute()
		wt_core_controller.requestStateChange( wt_core_state_idle )
end

-------------------------------------------------------------

function wt_core_state_salvaging.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		
		local delimiter = k:find('_')
		if (delimiter ~= nil and delimiter ~= 0) then
			local control = k:sub(0,delimiter-1)
			local id = k:sub(delimiter+1)
			if ( control == "gSalvage" and id ~= nil) then
				Settings.GW2MINION.salvagesettings[ tonumber(id) ].salvage = v
				Settings.GW2MINION.salvagesettings = Settings.GW2MINION.salvagesettings -- Trigger save
			end
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end


function wt_core_state_salvaging:HandleInit() 
	
	if (Settings.GW2MINION.salvagesettings == nil) then
		Settings.GW2MINION.salvagesettings = {	
		[1] = { desc="Common", salvage="0"},	
		[2] = { desc="Fine", salvage="0"},	
		[3] = { desc="Masterwork", salvage="0"},		
		[4] = { desc="Rare", salvage="0"},		
		--[5] = { desc="Exotic", salvage="0"},
		}
	end
	
	for k,v in pairs(Settings.GW2MINION.salvagesettings) do
		GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Salvage " .. v.desc ,"gSalvage_" .. k,"Settings")
		_G["gSalvage_"..k] = v.salvage
	end
	
	-- Add to other states only after all files have been loaded
	local ke_do_salvage = wt_kelement:create( "Do Salvage", c_need_salvage, e_need_salvage, 89 )
	wt_core_state_idle:add( ke_do_salvage )
	wt_core_state_minion:add( ke_do_salvage )
	wt_core_state_leader:add( ke_do_salvage )
	
end

function wt_core_state_salvaging:initialize()


	RegisterEventHandler("Module.Initalize",wt_core_state_salvaging.HandleInit)
	RegisterEventHandler("GUI.Update",wt_core_state_salvaging.GUIVarUpdate)
	
	-- State C&E
	local ke_died = wt_kelement:create("Died",c_died,e_died, wt_effect.priorities.interrupt )
	wt_core_state_salvaging:add(ke_died)
		
	local ke_aggro = wt_kelement:create("AggroCheck",c_aggro,e_aggro, 100 )
	wt_core_state_salvaging:add(ke_aggro)
			
	local ke_salvage = wt_kelement:create("Salvage",c_salvage,e_salvage,60)
	wt_core_state_salvaging:add(ke_salvage)

	local ke_salvage_done = wt_kelement:create("Salvage done",c_salvage_done,e_salvage_done,50)
	wt_core_state_salvaging:add(ke_salvage_done)
	

end


-- setup kelements for the state
wt_core_state_salvaging:initialize()
-- register the State with the system
wt_core_state_salvaging:register()


