-- Handles Selling,Buying,Repairing
-- UI is in mc_vendormanager.lua
mc_ai_vendor = {}
mc_ai_vendor.tmr = 0
mc_ai_vendor.threshold = 2000


--************
-- SELLING 
--************
mc_ai_vendor.isSelling = false
function mc_ai_vendor.NeedToSell( vendornearby )	
	if ( mc_ai_vendor.isSelling ) then return true end
	
	if ( vendornearby ) then
		return (TableSize(mc_vendormanager.createItemList()) > 2 and ((Inventory.freeSlotCount*100)/Inventory.slotCount) < 33)
	end
	return TableSize(mc_vendormanager.createItemList()) > 0
end
function mc_ai_vendor.GetClosestVendorMarker()	
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Merchant..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendors"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			return marker
		end
	end
	return nil
end
function mc_ai_vendor.GetClosestVendor()	
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Merchant..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendors"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			local vendor = CharacterList:Get(marker.characterID)
			if ( vendor and vendor.alive and vendor.pathdistance < 4000) then
				return vendor
			end
		end
	end
	return nil
end
--************
-- Close-Range-Sell-Taks
-- For going to vendor when it is not yet needed but since we are nearby, we can as well go pay him a visit
--************
c_quickvendorsell = inheritsFrom( ml_cause )
e_quickvendorsell = inheritsFrom( ml_effect )
c_quickvendorsell.inventoryLimit = math.random(4,6)/10
function c_quickvendorsell:evaluate()	
	return (SellManager_Active == "1" and 
		( 
			( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isSelling) ) -- so we wont leave the vendor after we sold 1 item ;)
			or
			( (Inventory.freeSlotCount / Inventory.slotCount < c_quickvendorsell.inventoryLimit) and mc_ai_vendor.NeedToSell( true ) and TableSize(mc_ai_vendor.GetClosestVendor()) > 0 ) -- Our bags are more than half full and we have stuff to sell 
		)
	)
end
function e_quickvendorsell:execute()
	ml_log("e_quickvendorsell")	
	-- We are already at a vendor
	if ( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isSelling) ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.SellAtVendor( t , true)
		else
			ml_error("We are at a sell-vendor but dont have him targeted!?!")
			mc_ai_vendor.isSelling = false
		end
	else
	
		local vendor = mc_ai_vendor.GetClosestVendor()
		if ( vendor ~= nil ) then	
			
				if ( vendor ) then				
					-- We are close enough and the vendor is in CharList
					if (not vendor.isInInteractRange) then
						-- MoveIntoInteractRange
						local tPos = vendor.pos
						if ( tPos ) then
							if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
							MoveOnlyStraightForward()
							local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
							if (tonumber(navResult) < 0) then
								d("e_quickvendorsell.MoveIntoInteractRange result: "..tonumber(navResult))					
							end
							if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
								mc_ai_vendor.tmr = mc_global.now
								mc_ai_vendor.threshold = math.random(1500,5000)
								mc_skillmanager.HealMe()
							end
							ml_log("MoveToSellVendor..")
							return true
						end
					else
						-- Interact
						Player:StopMovement()
						local t = Player:GetTarget()
						if ( vendor.selectable and (not t or t.id ~= vendor.id )) then
							Player:SetTarget( vendor.id )
						else
							
							if ( not Inventory:IsVendorOpened() and not Player:IsConversationOpen() ) then
								ml_log( " Opening Sell Vendor.. " )
								Player:Interact( vendor.id )
								mc_global.Wait(1500)
								return true
							else
								return mc_ai_vendor.SellAtVendor( vendor, true )
							end					 
						end			
					end
					
				else
					-- We are not close enought, vendor is not yet in Charlist
					local pos = vendor.pos
					if ( pos ) then
						if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
						MoveOnlyStraightForward()
						local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,50,false,true,true))		
						if (tonumber(navResult) < 0) then
							d("e_quickvendorsell.MoveInto Vendor Range result: "..tonumber(navResult))					
						end
						if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
							mc_ai_vendor.tmr = mc_global.now
							mc_ai_vendor.threshold = math.random(1500,5000)
							mc_skillmanager.HealMe()
						end
						ml_log("MoveToSellVendor..")
						return true
					else
						ml_error("Sellvendor Position table of Vendor is empty!")
					end
				end
		else
			ml_error("No Sell Vendor found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)		
end
c_vendorsell = inheritsFrom( ml_cause )
e_vendorsell = inheritsFrom( ml_effect )
function c_vendorsell:evaluate()	
	return (SellManager_Active == "1" and  
		( 
			( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isSelling) )
			or
			( Inventory.freeSlotCount <= 2 and mc_ai_vendor.NeedToSell() and TableSize(mc_ai_vendor.GetClosestVendorMarker()) > 0 )
		)		
	)
end
function e_vendorsell:execute()
	ml_log("e_vendorsell")
	
	-- We are already at a vendor
	if ( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isSelling) ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.SellAtVendor( t )
		else
			ml_error("We are at a vendor but dont have him targeted!?!")
			mc_ai_vendor.isSelling = false
		end
	else
	
		local vMarker = mc_ai_vendor.GetClosestVendorMarker()		
		if ( vMarker ~= nil ) then	
			if ( vMarker.characterID ~= nil and vMarker.characterID ~= 0 and vMarker.characterID ~= "") then			
				local char = CharacterList:Get(vMarker.characterID)
				if ( char ) then				
					-- We are close enough and the char is in CharList
					if (not char.isInInteractRange) then
						-- MoveIntoInteractRange
						local tPos = char.pos
						if ( tPos ) then
							if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
							MoveOnlyStraightForward()
							local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
							if (tonumber(navResult) < 0) then
								d("e_vendorsell.MoveIntoInteractRange result: "..tonumber(navResult))					
							end
							if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
								mc_ai_vendor.tmr = mc_global.now
								mc_ai_vendor.threshold = math.random(1500,5000)
								mc_skillmanager.HealMe()
							end
							ml_log("MoveToSellVendor..")
							return true
						end
					else
						-- Interact
						Player:StopMovement()
						local t = Player:GetTarget()
						if ( char.selectable and (not t or t.id ~= char.id )) then
							Player:SetTarget( char.id )
						else
							
							if ( not Inventory:IsVendorOpened() and not Player:IsConversationOpen() ) then
								ml_log( " Opening Vendor.. " )
								Player:Interact( char.id )
								mc_global.Wait(1500)
								return true
							else
								return mc_ai_vendor.SellAtVendor( char )
							end					 
						end			
					end
					
				else
					-- We are not close enought, char is not yet in Charlist
					local pos = vMarker.pos
					if ( pos ) then
						if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
						MoveOnlyStraightForward()
						local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,50,false,true,true))		
						if (tonumber(navResult) < 0) then
							d("e_vendorsell.MoveIntovMarkerRange result: "..tonumber(navResult))					
						end
						if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
							mc_ai_vendor.tmr = mc_global.now
							mc_ai_vendor.threshold = math.random(1500,5000)
							mc_skillmanager.HealMe()
						end
						ml_log("MoveToSellVendorMarker..")
						return true
					else
						ml_error("vMarker Position table of VendorMarker is empty!")
					end
				end
			end
		else
			ml_error("No Sell-VendorMarker found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)		
end
function mc_ai_vendor.SellAtVendor( vendor , nearbyvendor)
	-- Sell stuff	
	if ( mc_ai_vendor.NeedToSell() or ( nearbyvendor and mc_ai_vendor.NeedToSell( true ) )) then
		if ( not Inventory:IsVendorOpened() and Player:IsConversationOpen() ) then
			if ( not mc_ai_vendor.OpenSellWindow() ) then
				ml_error( "Vendoring: can't Sell at vendor, please report back to the developers" )
				ml_error("Blacklisted Sell-Vendor"..vendor.name)
				mc_blacklist.AddBlacklistEntry(GetString("vendors"), vendor.id, vendor.name, true)	
			end
		else
			-- SELL HERE
			local sList = mc_vendormanager.createItemList()
			if ( TableSize(sList) > 0 ) then
				local i,item = next (sList)
				if ( i and item ) then
					mc_ai_vendor.isSelling = true
					d("Selling :"..tostring(item.name))
					item:Sell()
					return
				end				
			else
				d("Selling finished..")				
				Inventory:SellJunk()
				mc_ai_vendor.isSelling = false				
			end
		end
	end
end




--************
-- BUY TOOLS
--************
mc_ai_vendor.isBuying = false
function mc_ai_vendor.NeedToBuyGatheringTools( vendornearby )	
	if ( mc_ai_vendor.isBuying ) then return true end
	
	if ( BuyManager_Active == "1") then
		if ( vendornearby ) then
			-- Go to nearby vendor when we have "some" tools left and can use the change to fill up
			
			-- Check for SalvageKits to buy
			local kitsToBuy = mc_vendormanager.NeedSalvageKitInfo()
			if (tonumber(BuyManager_sStacks)/2 >= kitsToBuy.count and Inventory.freeSlotCount >= kitsToBuy.count and TableSize(kitsToBuy.kits)>0 ) then
			-- We have half the Kits left, we should buy some and have enought space in Inv to buy them
				return true			
			end
			
			-- Check for Gatheringtools to buy
			local toolCount = mc_vendormanager.GetGatheringToolsCount()
			if (tonumber(BuyManager_toolStacks)/2 >= toolCount[1] or 
				tonumber(BuyManager_toolStacks)/2 >= toolCount[2] or 
				tonumber(BuyManager_toolStacks)/2 >= toolCount[3]) then
				return true		
			end			
		
		else
			-- Go only to Vendor when we dont have any kit / tools at all
			
			-- Check for SalvageKits to buy
			local kitsToBuy = mc_vendormanager.NeedSalvageKitInfo()
			if ( kitsToBuy.count == 0 and tonumber(BuyManager_sStacks) > 0 and Inventory.freeSlotCount >= kitsToBuy.count and TableSize(kitsToBuy.kits)>0 ) then
			-- We have no Kits left, we should buy some and have enought space in Inv to buy them
				return true					
			end	
			
			-- Check for Gatheringtools to buy
			local toolsToBuy = mc_vendormanager.GetNeededGatheringToolsInfo()
			if ((Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool) == nil and TableSize(toolsToBuy[1])>0 )or 
				(Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool) == nil  and TableSize(toolsToBuy[2])>0 )or 
				(Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool) == nil   and TableSize(toolsToBuy[3])>0 )) then 
				
				return true				
			end			
			
		end
	end
	return false
end
function mc_ai_vendor.GetClosestBuyVendorMarker()	
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Merchant..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendorsbuy"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			return marker
		end
	end
	return nil
end
function mc_ai_vendor.GetClosestBuyVendor()	
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Merchant..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendorsbuy"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			local vendor = CharacterList:Get(marker.characterID)
			if ( vendor and vendor.alive and vendor.pathdistance < 4000) then
				return vendor
			end
		end
	end
	return nil
end
c_quickbuy = inheritsFrom( ml_cause )
e_quickbuy = inheritsFrom( ml_effect )
function c_quickbuy:evaluate()	
	return (BuyManager_Active == "1" and Inventory.freeSlotCount > 0 and ( 
		( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isBuying ) ) -- so we wont leave the vendor after we sold 1 item ;)
		or 
		( mc_ai_vendor.NeedToBuyGatheringTools( true ) and TableSize(mc_ai_vendor.GetClosestBuyVendor()) > 0) -- We need new gathering tools
		)		
	)
end
function e_quickbuy:execute()
	ml_log("e_quickbuy")	
	-- We are already at a vendor
	if ( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isBuying ) ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.BuyAtVendor( t , true)
		else
			ml_error("We are at a buy-vendor but dont have him targeted!?!")
			mc_ai_vendor.isBuying = false
		end
	else
	
		local vendor = mc_ai_vendor.GetClosestBuyVendor()		
		if ( vendor ~= nil ) then	
			
				if ( vendor ) then				
					-- We are close enough and the vendor is in CharList
					if (not vendor.isInInteractRange) then
						-- MoveIntoInteractRange
						local tPos = vendor.pos
						if ( tPos ) then
							if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
							MoveOnlyStraightForward()
							local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
							if (tonumber(navResult) < 0) then
								d("e_quickbuy.MoveIntoInteractRange result: "..tonumber(navResult))					
							end
							if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
								mc_ai_vendor.tmr = mc_global.now
								mc_ai_vendor.threshold = math.random(1500,5000)
								mc_skillmanager.HealMe()
							end
							ml_log("MoveToBuyVendor..")
							return true
						end
					else
						-- Interact
						Player:StopMovement()
						local t = Player:GetTarget()
						if ( vendor.selectable and (not t or t.id ~= vendor.id )) then
							Player:SetTarget( vendor.id )
						else
							
							if ( not Inventory:IsVendorOpened() and not Player:IsConversationOpen() ) then
								ml_log( "Opening Vendor.. " )
								Player:Interact( vendor.id )
								mc_global.Wait(1500)
								return true
							else
								return mc_ai_vendor.BuyAtVendor( vendor, true )
							end					 
						end			
					end
					
				else
					-- We are not close enought, vendor is not yet in Charlist
					local pos = vendor.pos
					if ( pos ) then
						local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,50,false,true,true))		
						if (tonumber(navResult) < 0) then
							d("e_quickbuy.MoveInto Vendor Range result: "..tonumber(navResult))					
						end
						if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
							mc_ai_vendor.tmr = mc_global.now
							mc_ai_vendor.threshold = math.random(1500,5000)
							mc_skillmanager.HealMe()
						end
						ml_log("MoveToBuyVendor..")
						return true
					else
						ml_error("vendor Position table of Vendor is empty!")
					end
				end
		else
			ml_error("No Vendor found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)		
end
c_vendorbuy = inheritsFrom( ml_cause )
e_vendorbuy = inheritsFrom( ml_effect )
function c_vendorbuy:evaluate()	
	return (BuyManager_Active == "1" and  Inventory.freeSlotCount > 0 and ( 
			( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isBuying ) )
			or 
			( mc_ai_vendor.NeedToBuyGatheringTools() and TableSize(mc_ai_vendor.GetClosestBuyVendorMarker()) > 0)
		)		
	)
end
function e_vendorbuy:execute()
	ml_log("e_vendorbuy_")
	
	-- We are already at a vendor
	if ( (Inventory:IsVendorOpened() or Player:IsConversationOpen()) and ( mc_ai_vendor.isBuying or mc_ai_vendor.isSelling) ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.BuyAtVendor( t )
		else
			ml_error("We are at a vendor but dont have him targeted!?!")
			mc_ai_vendor.isBuying = false
			mc_ai_vendor.isSelling = false
		end
	else
	
		local vMarker = mc_ai_vendor.GetClosestBuyVendorMarker()		
		if ( vMarker ~= nil ) then	
			if ( vMarker.characterID ~= nil and vMarker.characterID ~= 0 and vMarker.characterID ~= "") then			
				local char = CharacterList:Get(vMarker.characterID)
				if ( char ) then				
					-- We are close enough and the char is in CharList
					if (not char.isInInteractRange) then
						-- MoveIntoInteractRange
						local tPos = char.pos
						if ( tPos ) then
							if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
							MoveOnlyStraightForward()
							local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))		
							if (tonumber(navResult) < 0) then
								d("e_vendorbuy.MoveIntoInteractRange result: "..tonumber(navResult))					
							end
							if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
								mc_ai_vendor.tmr = mc_global.now
								mc_ai_vendor.threshold = math.random(1500,5000)
								mc_skillmanager.HealMe()
							end
							ml_log("MoveToBuyVendor..")
							return true
						end
					else
						-- Interact
						Player:StopMovement()
						local t = Player:GetTarget()
						if ( char.selectable and (not t or t.id ~= char.id )) then
							Player:SetTarget( char.id )
						else
							
							if ( not Inventory:IsVendorOpened() and not Player:IsConversationOpen() ) then
								ml_log( " Opening Vendor.. " )
								Player:Interact( char.id )
								mc_global.Wait(1500)
								return true
							else
								return mc_ai_vendor.BuyAtVendor( char )
							end					 
						end			
					end
					
				else
					-- We are not close enought, char is not yet in Charlist
					local pos = vMarker.pos
					if ( pos ) then
						local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,50,false,true,true))		
						if (tonumber(navResult) < 0) then
							d("e_vendorbuy.MoveIntovMarkerRange result: "..tonumber(navResult))					
						end
						if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
							mc_ai_vendor.tmr = mc_global.now
							mc_ai_vendor.threshold = math.random(1500,5000)
							mc_skillmanager.HealMe()
						end
						ml_log("MoveToVendorBuyMarker..")
						return true
					else
						ml_error("vMarker Position table of VendorMarker is empty!")
					end
				end
			end
		else
			ml_error("No VendorMarker found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)		
end
function mc_ai_vendor.BuyAtVendor( vendor , nearbyvendor)
	
	-- BUY TOOLS
	if ( mc_ai_vendor.NeedToBuyGatheringTools() or ( nearbyvendor and mc_ai_vendor.NeedToBuyGatheringTools( true ) )) then
		if ( not Inventory:IsVendorOpened() and Player:IsConversationOpen() ) then
			if ( not mc_ai_vendor.OpenSellWindow() ) then
				ml_error( "Vendoring: can't Buy Tools at vendor.." )
				ml_error("Blacklisted BuyTools-Vendor"..vendor.name)
				mc_blacklist.AddBlacklistEntry(GetString("vendorsbuy"), vendor.id, vendor.name, true)	
			end
		else
			-- BUY TOOLS HERE
			--set mc_ai_vendor.isBuying treu/false			
			if ( Inventory:GetVendorServiceType() ~= GW2.VENDORSERVICETYPE.VendorBuy ) then
				d("Switching to Buy Window")
				Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorBuy)
				return
			end
			local VList = VendorItemList("")
			if ( TableSize(VList)>0 )then
				local kitsToBuy = mc_vendormanager.NeedSalvageKitInfo()
				local toolCount = mc_vendormanager.GetGatheringToolsCount()
				
				-- Buy SalvageKits				
				-- stop when we have enough tools				
				if ( mc_ai_vendor.isBuying and kitsToBuy.count >= tonumber(BuyManager_sStacks) and 
					tonumber(BuyManager_toolStacks) <= toolCount[1] and 
					tonumber(BuyManager_toolStacks) <= toolCount[2] and 
					tonumber(BuyManager_toolStacks) <= toolCount[3] )
					then
					d("Finished Buying SalvageTools...")
					mc_ai_vendor.isBuying = false
					return
				end				
				
				if ( kitsToBuy.count < tonumber(BuyManager_sStacks)) then
					for i=#kitsToBuy.kits,1,-1 do						
						local id,item = next(VList)
						while (id and item) do
							local itemID = item.itemID							
							if (kitsToBuy.kits[i] == itemID) then
								mc_ai_vendor.isBuying = true
								d("Buying SalvageKit: "..item.name)
								item:Buy()
								return
							end
							id,item = next(VList,id)	
						end
					end
				end
				
				-- Buy GatheringTools
				local toolsToBuy = mc_vendormanager.GetNeededGatheringToolsInfo()
				d("BuyingTools")
				-- Buy FTools
				if ( tonumber(BuyManager_toolStacks) > toolCount[1] and TableSize(toolsToBuy[1])>0) then					
					for i=#mc_vendormanager.tools[0],1,-1 do
						local tid,count = next(toolsToBuy[1])
						while (tid) do						
							if ( mc_vendormanager.tools[0][i] == tid) then
								-- First highest rarity item we should buy
								local index,item = next(VList)
								while (index and item) do
									if ( item.itemID == tid ) then 
										mc_ai_vendor.isBuying = true
										d("Buying HarvestingTool: "..item.name)
										item:Buy()
										mc_global.Wait(math.random(450,850))
										return
									end
									index,item = next(VList,index)
								end
							end
							tid,count = next(toolsToBuy[1],tid)
						end
					end
				end
										
				-- Buy LTools
				if ( tonumber(BuyManager_toolStacks) > toolCount[2] and TableSize(toolsToBuy[2])>0) then
					for i=#mc_vendormanager.tools[1],1,-1 do
						local tid,count = next(toolsToBuy[2])
						while (tid) do						
							if ( mc_vendormanager.tools[1][i] == tid) then
								-- First highest rarity item we should buy
								local index,item = next(VList)
								while (index and item) do
									if ( item.itemID == tid ) then 
										mc_ai_vendor.isBuying = true
										d("Buying LoggingTool: "..item.name)
										item:Buy()
										mc_global.Wait(math.random(450,850))
										return
									end
									index,item = next(VList,index)
								end
							end
							tid,count = next(toolsToBuy[2],tid)
						end
					end
				end

				-- Buy MTools
				if ( tonumber(BuyManager_toolStacks) > toolCount[3] and TableSize(toolsToBuy[3])>0) then
					for i=#mc_vendormanager.tools[2],1,-1 do
						local tid,count = next(toolsToBuy[3])
						while (tid) do						
							if ( mc_vendormanager.tools[2][i] == tid) then
								-- First highest rarity item we should buy
								local index,item = next(VList)
								while (index and item) do
									if ( item.itemID == tid ) then 
										mc_ai_vendor.isBuying = true
										d("Buying MiningTool: "..item.name)
										item:Buy()
										mc_global.Wait(math.random(450,850))
										return
									end
									index,item = next(VList,index)
								end
							end
							tid,count = next(toolsToBuy[3],tid)
						end
					end
				end
								
				-- Seems we cant buy the tools we need at this Vendor, blacklisting him for 60 min
				ml_error( "Vendoring: can't Buy the Tools we want at this vendor.." )
				ml_error("Blacklisted BuyTools-Vendor for 15 min"..vendor.name)
				mc_blacklist.AddBlacklistEntry(GetString("vendorsbuy"), vendor.id, vendor.name, mc_global.now + 900000)	
			
			else
				ml_error( "VendorList Empty??" )
			end			
		end
	end
end



--************
-- REPAIR
--************
function mc_ai_vendor.NeedToRepair( vendornearby )
	
	local damaged = 0
	local broken = 0
	for i=1 ,24 ,1  do 
		if ( i < 8 or i > 18 ) then -- no need to check other slots but those who can break
			local eqItem = Inventory:GetEquippedItemBySlot( i )
			if ( eqItem ~= nil ) then
				local dur = eqItem.durability 
				if ( dur == GW2.ITEMDURABILITY.Broken) then broken = broken + 1 damaged = damaged + 1 end
				if ( dur == GW2.ITEMDURABILITY.Damaged) then damaged = damaged + 1 end
			end
		end
	end
	
	if ( vendornearby ) then
		return broken > tonumber(gRepairBrokenLimit)/2 or damaged > tonumber(gRepairDamageLimit)/2 --half the settings in case we are nearby a repairguy
	end
	
	return broken > tonumber(gRepairBrokenLimit) or damaged > tonumber(gRepairDamageLimit)
end
function mc_ai_vendor.GetClosestRepairVendorMarker()
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Repair..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendors"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			return marker
		end
	end
	return nil
end
function mc_ai_vendor.GetClosestRepairVendor()	
	if ( mc_ai_vendor.isSelling ) then return true end
	local mList = MapMarkerList("nearest,onmesh,contentID="..GW2.MAPMARKER.Repair..",exclude_characterid="..mc_blacklist.GetExcludeString(GetString("vendors"))) 
	if ( TableSize(mList) > 0 )  then
		local i,marker = next (mList)
		if ( i and marker) then
			local vendor = CharacterList:Get(marker.characterID)
			if ( vendor and vendor.alive and vendor.pathdistance < 4000) then
				return vendor
			end
		end
	end
	return nil
end
c_quickrepair = inheritsFrom( ml_cause )
e_quickrepair = inheritsFrom( ml_effect )
function c_quickrepair:evaluate()
	return (  mc_ai_vendor.NeedToRepair( true ) and TableSize(mc_ai_vendor.GetClosestRepairVendor()) > 0)
end
function e_quickrepair:execute()
	ml_log("e_quickrepair")
	-- We are already at a vendor
	if ( Player:IsConversationOpen() ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.RepairAtVendor( t , true)
		else
			ml_error("We are at a vendor but dont have him targeted!?!")
		end
	else
		local vendor = mc_ai_vendor.GetClosestRepairVendor()
		if ( vendor ~= nil ) then
			-- We are close enough and the vendor is in CharList
			if (not vendor.isInInteractRange) then
				-- MoveIntoInteractRange
				local tPos = vendor.pos
				if ( tPos ) then
					if ( c_DestroyGadget:evaluate() ) then e_DestroyGadget:execute() end
					local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))
					if (tonumber(navResult) < 0) then
						d("e_quickrepair.MoveIntoInteractRange result: "..tonumber(navResult))
					end
					if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
						mc_ai_vendor.tmr = mc_global.now
						mc_ai_vendor.threshold = math.random(1500,5000)
						mc_skillmanager.HealMe()
					end
					ml_log("MoveToRepairVendor..")
					return true
				end
			else
				-- Interact
				Player:StopMovement()
				local t = Player:GetTarget()
				if ( vendor.selectable and (not t or t.id ~= vendor.id )) then
					Player:SetTarget( vendor.id )
				else
					
					--if ( not Inventory:IsVendorOpened() and not Player:IsConversationOpen() ) then
					if ( not Player:IsConversationOpen() ) then
						ml_log( " Opening Vendor.. " )
						Player:Interact( vendor.id )
						mc_global.Wait(1500)
						return true
					else
						return mc_ai_vendor.RepairAtVendor( vendor, true )
					end
				end
			end
		else
			ml_error("No Repair Vendor found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)
end
c_vendorrepair = inheritsFrom( ml_cause )
e_vendorrepair = inheritsFrom( ml_effect )
function c_vendorrepair:evaluate()
	return ( mc_ai_vendor.NeedToRepair() and  TableSize(mc_ai_vendor.GetClosestRepairVendorMarker()) > 0)
end
function e_vendorrepair:execute()
	ml_log("e_vendorrepair")
	
	-- We are already at a vendor
	if ( Player:IsConversationOpen() ) then
		local t = Player:GetTarget()
		if ( t ) then
			return mc_ai_vendor.RepairAtVendor( t )
		else
			ml_error("We are at a vendor but dont have him targeted!?!")
		end
	else
	
		local vMarker = mc_ai_vendor.GetClosestRepairVendorMarker()
		if ( vMarker ~= nil ) then
			if ( vMarker.characterID ~= nil and vMarker.characterID ~= 0 and vMarker.characterID ~= "") then
				local char = CharacterList:Get(vMarker.characterID)
				if ( char ) then
					-- We are close enough and the char is in CharList
					if (not char.isInInteractRange) then
						-- MoveIntoInteractRange
						local tPos = char.pos
						if ( tPos ) then
							local navResult = tostring(Player:MoveTo(tPos.x,tPos.y,tPos.z,50,false,true,true))
							if (tonumber(navResult) < 0) then
								ml_error("e_vendorrepair.MoveIntoInteractRange result: "..tonumber(navResult))
							end
							if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
								mc_ai_vendor.tmr = mc_global.now
								mc_ai_vendor.threshold = math.random(1500,5000)
								mc_skillmanager.HealMe()
							end
							ml_log("MoveToRepairVendor..")
							return true
						end
					else
						-- Interact
						Player:StopMovement()
						local t = Player:GetTarget()
						if ( char.selectable and (not t or t.id ~= char.id )) then
							Player:SetTarget( char.id )
						else
							
							if ( not Player:IsConversationOpen() ) then
								ml_log( " Opening Repair Vendor.. " )
								Player:Interact( char.id )
								mc_global.Wait(1500)
								return true
							else
								return mc_ai_vendor.RepairAtVendor( char )
							end
						end
					end
					
				else
					-- We are not close enought, char is not yet in Charlist
					local pos = vMarker.pos
					if ( pos ) then
						local navResult = tostring(Player:MoveTo(pos.x,pos.y,pos.z,50,false,true,true))
						if (tonumber(navResult) < 0) then
							d("e_vendorrepair.MoveIntovMarkerRange result: "..tonumber(navResult))
						end
						if ( mc_global.now - mc_ai_vendor.tmr > mc_ai_vendor.threshold ) then
							mc_ai_vendor.tmr = mc_global.now
							mc_ai_vendor.threshold = math.random(1500,5000)
							mc_skillmanager.HealMe()
						end
						ml_log("MoveToRepairVendorMarker..")
						return true
					else
						ml_error("vMarker Position table of VendorMarker is empty!")
					end
				end
			end
		else
			ml_error("No VendorMarker found! TODO: Get Vendor from MapData List")
			
		end
	end
	return ml_log(false)
end
function mc_ai_vendor.RepairAtVendor( vendor , nearbyvendor)
	-- REPAIR
	if ( mc_ai_vendor.NeedToRepair() or ( nearbyvendor and mc_ai_vendor.NeedToRepair( true ) ) ) then
		if ( Player:IsConversationOpen() ) then
			local options = Player:GetConversationOptions()
			if ( TableSize(options) > 0 ) then
				nextOption, entry  = next( options )
				local found = false
				while ( nextOption and entry ) do
					--d(entry.type)
					if( entry.type == GW2.CONVERSATIONOPTIONS.Repair ) then
						Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Repair )
						mc_global.Wait(math.random(500,1000))
						found = true
						break
					elseif( entry.type == GW2.CONVERSATIONOPTIONS.Continue ) then
						Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
						mc_global.Wait(math.random(150,400))
						found = true
						break
					elseif( entry.type == GW2.CONVERSATIONOPTIONS.Return ) then
						Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Return )
						mc_global.Wait(math.random(150,400))
						found = true
						break
						end
					nextOption, entry  = next( options, nextOption )
				end
			
				if ( not found ) then
					ml_error( "Vendoring: can't Repair at vendor, please report back to the developers" )
					ml_error("Blacklisted RepairVendor"..vendor.name)
					mc_blacklist.AddBlacklistEntry(GetString("vendors"), vendor.id, vendor.name, true)	
				end
			else
				ml_error("No conversation options ???")
			end
		end	
	end
end



function mc_ai_vendor.OpenSellWindow()
	
	ml_log( "Chatting with Vendor.." )	
	local found = false	
	local options = Player:GetConversationOptions()
	if ( TableSize(options) > 0 ) then
		nextOption, entry  = next( options )
		
		while ( nextOption and entry ) do
			if( entry.type == GW2.CONVERSATIONOPTIONS.Shop ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Shop )
				found = true
				break
			elseif( entry.type == GW2.CONVERSATIONOPTIONS.KarmaShop ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.KarmaShop )
				found = true
				break
			elseif( entry.type == 13 ) then
				Player:SelectConversationOption( 13 )
				found = true
				break
			elseif( entry.type == GW2.CONVERSATIONOPTIONS.Continue ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Continue )
				found = true
				break
			elseif( entry.type == GW2.CONVERSATIONOPTIONS.Story ) then
				Player:SelectConversationOption( GW2.CONVERSATIONOPTIONS.Story )
				found = true
				break
			elseif( entry.type == 20 ) then
				Player:SelectConversationOption( 20 )
				found = true
				break
			end		
			nextOption, entry  = next( options, nextOption )
		end			
	else
		ml_error("No Conversation Options at Vendor")
	end	
		
	if ( found == false ) then
		return ml_log(false)
	end
	mc_global.Wait(2500)
	return ml_log(true)
end

