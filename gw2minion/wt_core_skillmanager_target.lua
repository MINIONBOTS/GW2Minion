function SkillMgr.AssistedTargeting()
	if gSMactive ~= "1"
		or Player.healthstate == GW2.HEALTHSTATE.Defeated
		or wt_core_controller.shouldRun
		or gsMtargetmode ~= "Assisted Targeting"
	then
		return
	end 

	local distance = gSMATautoTargetDistance

	if distance == "auto" then
		distance = 0

		for i = 1, 5 do
			local spell = Player:GetSpellInfo(GW2.SKILLBARSLOT['Slot_' .. i])

			if spell and spell.maxRange > distance then
				distance = spell.maxRange
			end
		end

		if distance == 0 then
			distance = wt_global_information.AttackRange
		end
	end

	local filters = {
		"los",
		"noCritter"
	}

	local lowest_health = gSMATautoTargetLowestMax == 0 and ",lowesthealth" or ""

	if gSMATautoTargetCombat == 1 and Player.inCombat then
		table.insert(filters, "incombat")
	end

	if gSMATautoTargetPlayers == 1 then
		table.insert(filters, "player")
	end

	local groups = {}

	if distance > 0 then
		table.insert(groups, "downed,player,attackable,maxdistance=" .. distance .. lowest_health)
		table.insert(groups, "alive,attackable,maxdistance=" .. distance .. lowest_health)
	end

	if gSMATautoTargetRezDistance > 0 then
		local rez_distance = nil

		if gSMATautoTargetRezSlot > 0 then
			local slot = GW2.SKILLBARSLOT["Slot_" .. gSMATautoTargetRezSlot]

			if slot and self:SlotUp(slot) then
				local spell = Player:GetSpellInfo(slot)

				if spell and spell.maxRange > 0 then
					rez_distance = spell.maxRange
				end
			end
		end

		local group_friendly = "downed,player,lowesthealth,friendly,maxdistance=" .. (rez_distance or gSMATautoTargetRezDistance)
		table.insert(groups, 1, group_friendly)
	end

	for i, group in ipairs(groups) do
		local t = CharacterList(table.concat(filters, ",") .. "," .. group)

		if t then
			local lowest_max = nil

			if gSMATautoTargetLowestMax == 1
				and (
					not group_friendly
					or group ~= group_friendly
				)
			then
				local current_tid = Player:GetTarget()
				lowest_max = 99999

				if current_tid and current_tid ~= 0 then
					local current = CharacterList:Get(current_tid)

					if current then
						lowest_max = current.health.max
					end
				end
			end

			local tid, target = next(t)
			local set_tid = nil

			while tid do
				if tid ~= 0 and target then
					if lowest_max then
						if target.health.max < lowest_max then
							lowest_max = target.health.max
							set_tid = tid
						end
					else
						set_tid = tid
						break
					end
				end

				tid, target = next(t, tid)
			end

			if set_tid then
				Player:SetTarget(set_tid)
				break
			end
		end
	end
end