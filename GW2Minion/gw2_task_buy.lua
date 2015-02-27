-- Salvaging + Settings
gw2_task_buy = inheritsFrom(ml_task)
gw2_task_buy.name = GetString("vendorsbuy")

function gw2_task_buy.Create()
	local newinst = inheritsFrom(gw2_task_buy)

	--ml_task members
	newinst.valid = true
	newinst.completed = false
	newinst.subtask = nil
	newinst.process_elements = {}
	newinst.overwatch_elements = {}

	return newinst
end

function gw2_task_buy:Init()
	-- ml_log("gw2_task_buy:Init")
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
	self:add(ml_element:create("VendorBuy",c_vendorbuy,e_vendorbuy,100),self.process_elements)
	self:add(ml_element:create("QuickVendorBuy",c_quickvendorbuy,e_quickvendorbuy,110),self.process_elements)
	self:add(ml_element:create("MoveToVendorMarker",c_MoveToVendorMarker,e_MoveToVendorMarker,50),self.process_elements)


	self:AddTaskCheckCEs()
end
function gw2_task_buy:task_complete_eval()
	c_MoveToVendorMarker.vendormanager = BuyManager_Active
	if (c_vendorbuy:evaluate() == false and c_quickvendorbuy:evaluate() == false and c_MoveToVendorMarker:evaluate() == false) then
		return true
	end
	c_MoveToVendorMarker.vendormanager = false
	return false
end

function gw2_task_buy:UIInit()
	d("gw2_task_buy:UIInit")
	return true
end
function gw2_task_buy:UIDestroy()
	d("gw2_task_buy:UIDestroy")
end

function gw2_task_buy:RegisterDebug()
    d("gw2_task_buy:RegisterDebug")
end

-- Check for creating a VendorTask
c_createVendorBuyTask = inheritsFrom( ml_cause )
e_createVendorBuyTask = inheritsFrom( ml_effect )
c_createVendorBuyTask.throttle = 5000
function c_createVendorBuyTask:evaluate()
	if (BuyManager_Active == "1" ) then

		if ((gw2_buy_manager.NeedToBuySalvageKits() or gw2_buy_manager.NeedToBuyGatheringTools()) or c_vendorbuy.buying) and ( TableSize(gw2_buy_manager.getClosestBuyMarker())>0 or gw2_marker_manager.GetNextVendorMarker()) then
			return true
		end

		if ((gw2_buy_manager.NeedToBuySalvageKits(true) or gw2_buy_manager.NeedToBuyGatheringTools(true)) or c_quickvendorbuy.buying) and ( TableSize(gw2_buy_manager.getClosestBuyMarker(true))>0 or gw2_marker_manager.GetNextVendorMarker()) then
			return true
		end
	end
	return false
end
function e_createVendorBuyTask:execute()
	ml_log("e_createVendorBuyTask")

	c_quickvendorbuy.buying = false
	local newTask = gw2_task_buy.Create()
	ml_task_hub:Add(newTask.Create(), REACTIVE_GOAL, TP_ASAP)

	return ml_log(true)
end


c_vendorbuy = inheritsFrom( ml_cause )
e_vendorbuy = inheritsFrom( ml_effect )
c_vendorbuy.buying = false
function c_vendorbuy:evaluate()
	if (BuyManager_Active == "1" and ((gw2_buy_manager.NeedToBuySalvageKits() or gw2_buy_manager.NeedToBuyGatheringTools()) or c_vendorbuy.buying) and TableSize(gw2_buy_manager.getClosestBuyMarker())>0) then
		return true
	end
	return false
end
function e_vendorbuy:execute()
	ml_log("e_vendorbuy")
	local merchantMarker = gw2_buy_manager.getClosestBuyMarker()
	-- We have a real MapMarker
	if (merchantMarker and merchantMarker.characterID) then
		if (gw2_buy_manager.buyAtMerchant(merchantMarker)) then
			c_vendorbuy.buying = true
			return ml_log(true)
		end
	end
	c_vendorbuy.buying = false
	return ml_log(false)
end

c_quickvendorbuy = inheritsFrom( ml_cause )
e_quickvendorbuy = inheritsFrom( ml_effect )
c_quickvendorbuy.buying = false
function c_quickvendorbuy:evaluate()
	if (BuyManager_Active == "1" and ((gw2_buy_manager.NeedToBuySalvageKits(true) or gw2_buy_manager.NeedToBuyGatheringTools(true)) or c_quickvendorbuy.buying) and TableSize(gw2_buy_manager.getClosestBuyMarker(true))>0) then
		return true
	end
	return false
end
function e_quickvendorbuy:execute()
	ml_log("e_quickvendorbuy")
	local merchantMarker = gw2_buy_manager.getClosestBuyMarker(true)
	if (merchantMarker and merchantMarker.characterID) then
		if (gw2_buy_manager.buyAtMerchant(merchantMarker)) then
			c_quickvendorbuy.buying = true
			return ml_log(true)
		end
	end
	c_quickvendorbuy.buying = false
	return ml_log(false)
end
