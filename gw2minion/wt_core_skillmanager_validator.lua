function SkillMgr.ValidateSkill(skillID, slot, target, tid, maxrange, mybuffs, cooldown)
	--d(tostring(Player:GetCurrentlyCastedSpell()).." IC: "..tostring(Player:IsSpellOnCooldown(GW2.SKILLBARSLOT.Slot_3)).." IS1cast: "..tostring(Player:IsSpellCurrentlyCast(GW2.SKILLBARSLOT.Slot_3)).." X:"..tostring(Player:IsCasting()))

	local castable = true

	-- COOLDOWN CHECK
	if ( cooldown == true and slot ~= GW2.SKILLBARSLOT.Slot_1 and Player:IsSpellOnCooldown(slot)) then return false end

	-- OUTOFCOMBAT CHECK
	if ( (tostring(_G["SKM_OutOfCombat_"..tostring(skillID)]) == "No" and not Player.inCombat) ) then return false end

	-- PLAYER MOVEMENT CHECK
	if ( ( (tostring(_G["SKM_PMove_"..tostring(skillID)]) == "No" and Player.movementstate == GW2.MOVEMENTSTATE.GroundMoving) or (tostring(_G["SKM_PMove_"..tostring(skillID)]) == "Yes" and Player.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) )) then return false end
	--d("castable1:"..tostring(castable).." " ..tostring(skillID))

	-- TARGETTYPE + LOS + RANGE + MOVEMENT + HEALTH CHECK
	if ((tostring(_G["SKM_TType_"..tostring(skillID)]) == "Enemy"
		and (not target
			or (tostring(_G["SKM_LOS_"..tostring(skillID)]) == "Yes" and not target.los)
			or (tonumber(_G["SKM_MinR_"..tostring(skillID)]) > 0 and target.distance < tonumber(_G["SKM_MinR_"..tostring(skillID)]))
			or (tonumber(_G["SKM_MaxR_"..tostring(skillID)]) > 0 and target.distance > tonumber(_G["SKM_MaxR_"..tostring(skillID)])+25)
			or (tostring(_G["SKM_TMove_"..tostring(skillID)]) == "No" and target.movementstate == GW2.MOVEMENTSTATE.GroundMoving)
			or (tostring(_G["SKM_PMove_"..tostring(skillID)]) == "Yes" and target.movementstate == GW2.MOVEMENTSTATE.GroundNotMoving)
			or (tonumber(_G["SKM_THPL_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_THPL_"..tostring(skillID)]) > target.health.percent)
			or (tonumber(_G["SKM_THPB_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_THPB_"..tostring(skillID)]) < target.health.percent)
			))) then return false end

	-- PLAYER HEALTH,POWER,ENDURANCE CHECK
	if ((
		(tonumber(_G["SKM_PHPL_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_PHPL_"..tostring(skillID)]) > Player.health.percent)
		or (tonumber(_G["SKM_PHPB_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_PHPB_"..tostring(skillID)]) < Player.health.percent)
		or (tonumber(_G["SKM_PPowL_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_PPowL_"..tostring(skillID)]) > Player:GetProfessionPowerPercentage())
		or (tonumber(_G["SKM_PPowB_"..tostring(skillID)]) > 0 and tonumber(_G["SKM_PPowB_"..tostring(skillID)]) < Player:GetProfessionPowerPercentage())
		)) then return false end

	-- PLAYER BUFF CHECKS
	if ((tostring(_G["SKM_PEff1_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_PEff2_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_PNEff1_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_PNEff2_"..tostring(skillID)]) ~= "None") )then

		if ( mybuffs ) then
			local E1 = SkillMgr.BuffEnum[tostring(_G["SKM_PEff1_"..tostring(skillID)])]
			local E2 = SkillMgr.BuffEnum[tostring(_G["SKM_PEff2_"..tostring(skillID)])]
			local NE1 = SkillMgr.BuffEnum[tostring(_G["SKM_PNEff1_"..tostring(skillID)])]
			local NE2 = SkillMgr.BuffEnum[tostring(_G["SKM_PNEff2_"..tostring(skillID)])]

			local bufffound = false
			local i,buff = next(mybuffs)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID == NE1 or bskID == NE2 or bskID == E1 or bskID == E2 ) then
					bufffound = true
					break
				end
				i,buff = next(mybuffs,i)
			end
			if (not bufffound and (E1 or E2))then return false end
			if (bufffound and (NE1 or NE2))then return false end
		end
	end
	if ((tonumber(_G["SKM_PCondC_"..tostring(skillID)]) > 0 )) then
		if ( mybuffs ) then
			local condcount = 0
			local i,buff = next(mybuffs)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID and SkillMgr.ConditionsEnum[bskID] ~= nil) then
					condcount = condcount + 1
					if (condcount > tonumber(_G["SKM_PCondC_"..tostring(skillID)])) then
						break
					end
				end
				i,buff = next(mybuffs,i)
			end
			if (condcount <= tonumber(_G["SKM_PCondC_"..tostring(skillID)])) then return false end
		end
	end


	-- ALLIE AE CHECK
	if ((tonumber(_G["SKM_TACount_"..tostring(skillID)]) > 1 and tonumber(_G["SKM_TARange_"..tostring(skillID)]) > 0)) then
		if ( not target
			or not target.id
			or ( TableSize(CharacterList("friendly,maxdistance="..tonumber(_G["SKM_TARange_"..tostring(skillID)])..",distanceto="..target.id)) < tonumber(_G["SKM_TACount_"..tostring(skillID)]))) then
			return false
		end
	end

	-- TARGET BUFF CHECKS
	if (target and (tostring(_G["SKM_TEff1_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_TEff2_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_TNEff1_"..tostring(skillID)]) ~= "None" or tostring(_G["SKM_TNEff2_"..tostring(skillID)]) ~= "None") )then
		local tbuffs = target.buffs
		if ( tbuffs ) then
			local E1 = SkillMgr.BuffEnum[tostring(_G["SKM_TEff1_"..tostring(skillID)])]
			local E2 = SkillMgr.BuffEnum[tostring(_G["SKM_TEff2_"..tostring(skillID)])]
			local NE1 = SkillMgr.BuffEnum[tostring(_G["SKM_TNEff1_"..tostring(skillID)])]
			local NE2 = SkillMgr.BuffEnum[tostring(_G["SKM_TNEff2_"..tostring(skillID)])]
			local bufffound = false
			local i,buff = next(tbuffs)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID == NE1 or bskID == NE2 or bskID == E1 or bskID == E2) then
					bufffound = true
					break
				end
				i,buff = next(tbuffs,i)
			end
			if (not bufffound and (E1 or E2))then return false end
			if (bufffound and (NE1 or NE2))then return false end
		end
	end
	-- TARGET AE CHECK
	if ((tonumber(_G["SKM_TECount_"..tostring(skillID)]) > 1 and tonumber(_G["SKM_TERange_"..tostring(skillID)]) > 0)) then
		if ( not target
			or not target.id
			or ( TableSize(CharacterList("alive,attackable,maxdistance="..tonumber(_G["SKM_TERange_"..tostring(skillID)])..",distanceto="..target.id)) < tonumber(_G["SKM_TECount_"..tostring(skillID)]))) then
			return false
		end
	end
	-- TARGET #CONDITIONS CHECK
	if (target and (tonumber(_G["SKM_TCondC_"..tostring(skillID)]) > 0 )) then
		local tbuffs2 = target.buffs
		if ( tbuffs2 ) then
			local condcount = 0
			local i,buff = next(tbuffs2)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID and SkillMgr.ConditionsEnum[bskID] ~= nil) then
					condcount = condcount + 1
					if (condcount > tonumber(_G["SKM_TCondC_"..tostring(skillID)])) then
						break
					end
				end
				i,buff = next(tbuffs2,i)
			end
			if (condcount <= tonumber(_G["SKM_TCondC_"..tostring(skillID)])) then return false end
		end
	end

	-- PLAYER #BOON CHECK
	if ((tonumber(_G["SKM_PBoonC_"..tostring(skillID)]) > 0 )) then
		if ( mybuffs ) then
			local booncount = 0
			local i,buff = next(mybuffs)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID and SkillMgr.BoonsEnum[bskID] ~= nil) then
					booncount = booncount + 1
					if (booncount > tonumber(_G["SKM_PBoonC_"..tostring(skillID)])) then
						break
					end
				end
				i,buff = next(mybuffs,i)
			end
			if (booncount <= tonumber(_G["SKM_PBoonC_"..tostring(skillID)])) then return false end
		end
	end

	-- TARGET #BOON CHECK
	if (target and (tonumber(_G["SKM_TBoonC_"..tostring(skillID)]) > 0 )) then
		local tbuffs2 = target.buffs
		if ( tbuffs2 ) then
			local booncount = 0
			local i,buff = next(tbuffs2)
			while i and buff do
				local bskID = buff.skillID
				if ( bskID and SkillMgr.BoonsEnum[bskID] ~= nil) then
					booncount = booncount + 1
					if (booncount > tonumber(_G["SKM_TBoonC_"..tostring(skillID)])) then
						break
					end
				end
				i,buff = next(tbuffs2,i)
			end
			if (booncount <= tonumber(_G["SKM_TBoonC_"..tostring(skillID)])) then return false end
		end
	end

	-- SKILL POLL TIME
	castable = tonumber(_G["SKM_SPoll_"..tostring(skillID)]) <= 0 or SkillMgr.DoActionTmr - (tonumber(_G["SKM_SPollTime_"..tostring(skillID)]) or 0) > tonumber(_G["SKM_SPoll_"..tostring(skillID)]) - SkillMgr.poll
	if (castable == false) then
		return false
	end

	-- NOT CONTENT ID
	if ((tonumber(_G["SKM_notContentID_"..tostring(skillID)]) > 0 )) then
		local not_content_id, not_slot = string.match(_G["SKM_notContentID_"..tostring(skillID)], "^(%d+)#(%d+)$")

		if not_content_id and not_slot then
			not_content_id = tonumber(not_content_id)
			not_slot = tonumber(not_slot)
		end

		castable = (tonumber(_G["SKM_notContentID_"..tostring(skillID)]) ~= skillID
			and (
				not not_slot
				or (
					SkillMgr.cskills[not_slot]
					and SkillMgr.cskills[not_slot].contentID ~= tonumber(not_content_id)
				)
			))
		if (castable == false) then
			return false
		end
	end

	-- SKILL EXISTS
	if ((tonumber(_G["SKM_skillExists_"..tostring(skillID)]) > 0 )) then
		local exists_skill_id, exists_slot = string.match(_G["SKM_skillExists_"..tostring(skillID)], "^(%d+)#(%d+)$")

		if exists_skill_id and exists_slot then
			exists_skill_id = tonumber(exists_skill_id)
			exists_slot = tonumber(exists_slot)
		end

		castable = (exists_slot
			and SkillMgr.cskills[exists_slot]
			and SkillMgr.cskills[exists_slot].contentID == tonumber(exists_skill_id))
		if (castable == false) then
			return false
		end
	end

	-- SKILL READY
	if (tonumber(_G["SKM_skillReady_"..tostring(skillID)]) > 0) then
		castable = SkillMgr.check_skillReady(_G["SKM_skillReady_"..tostring(skillID)], skillID, target, tid, maxrange, mybuffs)
		if (castable == false) then
			return false
		end
	end

	-- SKILL NOT READY
	if (tonumber(_G["SKM_skillNotReady_"..tostring(skillID)]) > 0) then
		castable = SkillMgr.check_skillNotReady(_G["SKM_skillNotReady_"..tostring(skillID)], skillID, target, tid, maxrange, mybuffs)
		if (castable == false) then
			return false
		end
	end

	return true
end