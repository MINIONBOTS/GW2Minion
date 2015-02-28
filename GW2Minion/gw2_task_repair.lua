-- Repair
gw2_task_repair = inheritsFrom(ml_task)
gw2_task_repair.name = GetString("vendorEnabled") -- == Sell Items

function gw2_task_repair.Create()
	local newinst = inheritsFrom(gw2_task_repair)

	--ml_task members
	newinst.valid = true
	newinst.completed = false
	newinst.subtask = nil
	newinst.process_elements = {}
	newinst.overwatch_elements = {}

	return newinst
end

function gw2_task_repair:Init()
	-- ml_log("gw2_task_repair:Init")
	-- ProcessOverWatch() elements

	-- Handle Dead
	self:add(ml_element:create( "Dead", c_Dead, e_Dead, 500 ), self.overwatch_elements)

	-- Downed
	self:add(ml_element:create( "Downed", c_Downed, e_DownedEmpty, 450 ), self.overwatch_elements)

	-- Handle Rezz-Target is alive again or gone, deletes the subtask moveto in case it is needed
	self:add(ml_element:create( "RevivePartyMemberOverWatch", c_RezzOverWatchCheck, e_RezzOverWatchCheck, 400 ), self.overwatch_elements)



	-- Normal elements
	-- Revive Downed/Dead Partymember
	self:add(ml_element:create( "RevivePartyMember", c_RezzPartyMember, e_RezzPartyMember, 375 ), self.process_elements)	-- creates subtask: moveto
	self:add(ml_element:create("VendorSell",c_vendorrepair,e_vendorrepair,100),self.process_elements)
	self:add(ml_element:create("QuickVendorSell",c_quickvendorrepair,e_quickvendorrepair,110),self.process_elements)
	--self:add(ml_element:create("MoveToVendorMarker",c_MoveToVendorMarker,e_MoveToVendorMarker,50),self.process_elements)


	self:AddTaskCheckCEs()
end
function gw2_task_repair:task_complete_eval()
	if (c_vendorrepair:evaluate() == false and c_quickvendorrepair:evaluate() == false) then
		return true
	end
	return false
end

function gw2_task_repair:UIInit()
	d("gw2_task_repair:UIInit")
	return true
end
function gw2_task_repair:UIDestroy()
	d("gw2_task_repair:UIDestroy")
end
function gw2_task_repair:RegisterDebug()
    d("gw2_task_repair:RegisterDebug")
end


-- Check for creating a VendorTask
c_createVendorRepairTask = inheritsFrom( ml_cause )
e_createVendorRepairTask = inheritsFrom( ml_effect )
c_createVendorRepairTask.throttle = 5000
function c_createVendorRepairTask:evaluate()
	if (gw2_repair_manager.NeedToRepair() and (TableSize(gw2_repair_manager.getClosestRepairMarker())>0 or gw2_marker_manager.GetNextVendorMarker())) then
		return true
	end

	if (gw2_repair_manager.getClosestRepairMarker(true) and (TableSize(gw2_repair_manager.getClosestRepairMarker(true))>0 or gw2_marker_manager.GetNextVendorMarker())) then
		return true
	end
	return false
end
function e_createVendorRepairTask:execute()
	ml_log("e_createRepairTask")

	local newTask = gw2_task_repair.Create()
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)

	return ml_log(true)
end


c_vendorrepair = inheritsFrom( ml_cause )
e_vendorrepair = inheritsFrom( ml_effect )
function c_vendorrepair:evaluate()
	if (gw2_repair_manager.NeedToRepair() and TableSize(gw2_repair_manager.getClosestRepairMarker()) > 0) then
		return true
	end
	return false
end
function e_vendorrepair:execute()
	ml_log("e_vendorrepair")
	local repairMarker = gw2_repair_manager.getClosestRepairMarker()
	if (repairMarker and repairMarker.characterID) then
		if (gw2_repair_manager.RepairAtVendor(repairMarker)) then
			return true
		end
	end
	return ml_log(false)
end

c_quickvendorrepair = inheritsFrom( ml_cause )
e_quickvendorrepair = inheritsFrom( ml_effect )
function c_quickvendorrepair:evaluate()
	if (gw2_repair_manager.NeedToRepair(true) and TableSize(gw2_repair_manager.getClosestRepairMarker(true)) > 0) then
		return true
	end
	return false
end
function e_quickvendorrepair:execute()
	ml_log("e_quickvendorrepair")
	local repairMarker = gw2_repair_manager.getClosestRepairMarker(true)
	if (repairMarker and repairMarker.characterID) then
		if (gw2_repair_manager.RepairAtVendor(repairMarker)) then
			return true
		end
	end
	return ml_log(false)
end