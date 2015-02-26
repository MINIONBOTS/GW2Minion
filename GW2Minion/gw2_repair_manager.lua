gw2_repair_manager = {}
gw2_repair_manager.damagedLimit = 4
gw2_repair_manager.brokenLimit = 1

-- Non selectable anvils
gw2_repair_manager.nonselectable_contentID = {}
gw2_repair_manager.nonselectable_contentID2 = {135266304}

function gw2_repair_manager.getClosestRepairMarker(nearby)
	local closestLocation = nil
	local listArg = (nearby == true and ",maxdistance=4000" or "")
	local markers = MapMarkerList("onmesh,nearest,worldmarkertype=24,markertype=25,contentID="..GW2.MAPMARKER.Repair..listArg..",exclude_characterid="..ml_blacklist.GetExcludeString(GetString("vendorsbuy")))
	for _,repair in pairs(markers) do
		if (closestLocation == nil or closestLocation.distance > repair.distance) then
			if (nearby == true and repair.pathdistance < 4000) then
				closestLocation = repair
			elseif (nearby ~= true) then
				closestLocation = repair
			end
		end
	end
	return closestLocation
end

function gw2_repair_manager.NeedToRepair(nearby)
	local damaged = 0
	local broken = 0
	for i=0,7 do
		local equipedItem = Inventory:GetEquippedItemBySlot(i)
		if (equipedItem) then
			local durability = equipedItem.durability
			if (durability == GW2.ITEMDURABILITY.Broken) then broken = broken + 1 damaged = damaged + 1 end
			if (durability == GW2.ITEMDURABILITY.Damaged) then damaged = damaged + 1 end
		end
	end

	if (nearby) then
		return broken > 0 or damaged > 0
	end

	return broken >= gw2_repair_manager.brokenLimit or damaged >= gw2_repair_manager.damagedLimit
end

function gw2_repair_manager.RepairAtVendor(marker)
	if (marker) then
		repair = CharacterList:Get(marker.characterID)

		if(repair == nil) then
			repair = GadgetList:Get(marker.characterID)
		end

		if (repair and repair.isInInteractRange and repair.distance < 100) then
			Player:StopMovement()
			local target = Player:GetTarget()
			if (gw2_repair_manager.IsSelectable(repair) and (not target or target.id ~= repair.id)) then
				Player:SetTarget(repair.id)
			else
				if (Inventory:IsVendorOpened() == false and Player:IsConversationOpen() == false) then
					ml_log(" Opening Repair.. ")
					Player:Interact(repair.id)
					ml_global_information.Wait(1500)
					return true
				else
					local result = gw2_common_functions.handleConversation("repair")
					if (result == false) then
						d("Repair blacklisted, cant handle opening conversation.")
						if(gw2_repair_manager.IsSelectable(repair)) then
							ml_blacklist.AddBlacklistEntry(GetString("vendorsrepair"), repair.id, repair.name, true)
						else
							-- Only temporarily blacklist gadgets, we might just have interacted with the wrong object
							ml_blacklist.AddBlacklistEntry(GetString("vendorsrepair"), repair.id, repair.name, ml_global_information.Now + 300000)
						end

						return false
					elseif (result == nil) then
						ml_global_information.Wait(math.random(520,1200))
						return true
					end
				end

			end
		else
			local pos = marker.pos
			if ( pos ) then
				local newTask = gw2_task_moveto.Create()
				newTask.targetPos = pos
				newTask.targetID = marker.characterID
				newTask.targetType = "character"
				newTask.name = "MoveTo Vendor(Repair)"
				newTask.useWaypoint = true
				ml_task_hub:CurrentTask():AddSubTask(newTask)
				return true
			end
		end
	end
	return false
end

function gw2_repair_manager.IsSelectable(target)
	if(target and target.isGadget) then
		if(ValidTable(gw2_repair_manager.nonselectable_contentID)) then
			for _,id in pairs(gw2_repair_manager.nonselectable_contentID) do
				if(id == target.contentID) then
					return false
				end
			end
		end

		if(ValidTable(gw2_repair_manager.nonselectable_contentID2)) then
			for _,id in pairs(gw2_repair_manager.nonselectable_contentID2) do
				if(id == target.contentID2) then
					return false
				end
			end
		end
	end

	return true
end
