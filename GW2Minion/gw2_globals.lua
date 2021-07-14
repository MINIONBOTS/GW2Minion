ml_global_information = ml_global_information or {}
ml_global_information.Path = GetStartupPath()
ml_global_information.Lasttick = -3000
ml_global_information.Running = false
ml_global_information.MAX_SKILLBAR_SLOTS = 21
ml_global_information.Chinese = Player:GetLanguage() == 5

ml_global_information.ConditionsEnum = {
	[736]		= "Bleeding",
	[720]		= "Blind",
	[737]		= "Burning",
	[722]		= "Chilled",
	[861]		= "Confusion",
	[721]		= "Crippled",
	[791]		= "Fear",
	[727]		= "Immobilized",
	[738]		= "Vulnerability",
	[742]		= "Weakness",
	[723]		= "Poison",
	[27705]		= "Taunt",
	[26766]		= "Slow",
	[19426]		= "Torment",
};

ml_global_information.BoonsEnum = {
	[743]		= "Aegis",
	[17675]		= "Aegis",
	[725]		= "Fury",
	[740]		= "Might",
	[717]		= "Protection",
	[1187]		= "Quickness",
	[718]		= "Regeneration",
	[17674]		= "Regeneration",
	[26980]		= "Resistance",
	[873]		= "Retaliation",
	[1122]		= "Stability",
	[719]		= "Swiftness",
	[726]		= "Vigor",
	[762]		= "Determined",
};

ml_global_information.SpeedBoons = {
	[719]		= "Swiftness",
	[5974]		= "Super Speed",
	[5543]		= "Mist form",
	[12542]		= "Signet of the Hunt",
	[13060]		= "Signet of Shadows",
	[5572]		= "Signet of Air",
	[10612]		= "Signet of the Locust",
	[33843]		= "Leader of the Pact I",
	[32675]		= "Leader of the Pact II",
	[33611]		= "Leader of the Pact III",
}

ml_global_information.SlowConditions = {
	[721]		= "Cripple",
	[722]		= "Chill",
	[18621]		= "Ichor",
}

ml_global_information.ImmobilizeConditions = {
	[727]		= "Immobilize",
	[791]		= "Fear",
	[872]		= "Stun",
	[833]		= "Daze",
	[27705]		= "Taunt",
	[15090]		= "Petrified 1",
	[16963]		= "Petrified 2",
	[25181]		= "Trapped",
	[37211]		= "Frostbite"
}

ml_global_information.InvulnerabilityConditions = {
	[762]		= "Determined",
	[785]		= "Determined",
	[895]		= "Determined (no icon)",
	[11641]		= "Determined (no icon)",
	[757]		= "Invulnerable",
	[903]		= "Righteous Indignation",
	[36143]		= "Destruction Immunity",
	[29065]		= "Tough Hide"
}

-- These are MapMarker - ContentIDs
ml_global_information.VendorSell = {
	GW2.MAPMARKER.Merchant,
	GW2.MAPMARKER.Armorsmith,
	GW2.MAPMARKER.Weaponsmith,
	GW2.MAPMARKER.Repair,
	GW2.MAPMARKER.ItzelVendor,
	GW2.MAPMARKER.ExaltedVendor,
	GW2.MAPMARKER.NuhochVendor,
	--305607,  -- Priory Historian Bandit Chest Seller (Vendors in forts do not have sell option)
	887588, -- Gathering Merchant
}

ml_global_information.VendorBuy = {
	GW2.MAPMARKER.Merchant,
	GW2.MAPMARKER.ItzelVendor,
	GW2.MAPMARKER.ExaltedVendor,
	GW2.MAPMARKER.NuhochVendor
}

ml_global_information.VendorRepair = {
	GW2.MAPMARKER.Repair
}

-- Moved this here so it's easier to look at and easier to copy paste
function ml_global_information.OnUpdate(Event,ticks)	
	ml_global_information.GameState = GetGameState()

	if(TimeSince(ml_global_information.Lasttick) > BehaviorManager:GetTicksThreshold()) then
		ml_global_information.Lasttick = ticks

		if(Player) then
			ml_global_information.Player_ID = Player.id or 0
			ml_global_information.Player_Name = Player.name or ""
			ml_global_information.Player_Health = Player.health or { current = 0, max = 0, percent = 0 }
			ml_global_information.Player_Profession = Player.profession or 0
			ml_global_information.Player_ProfessionName = table.invert(GW2.CHARCLASS)[ml_global_information.Player_Profession] or "NoClass"
			ml_global_information.Player_Power = Player.power or 0
			ml_global_information.Player_Endurance = Player.endurance or 0
			ml_global_information.Player_InCombat = Player.incombat or false		
			ml_global_information.Player_Position = Player.pos
			ml_global_information.Player_Level = Player.level
			ml_global_information.Player_OnMesh = Player.onmesh or false
			ml_global_information.Player_Alive = Player.alive or false
			ml_global_information.Player_IsMoving = Player:IsMoving() or false
			ml_global_information.Player_CanMove = Player:CanMove() or false
			ml_global_information.Player_MovementDirections = Player:GetMovement() or { forward=false, backward=false, left=false, right=false }
			ml_global_information.Player_Inventory_SlotsFree = Inventory.freeslotcount or 0
			ml_global_information.Player_HealthState = Player.healthstate or 0
			ml_global_information.Player_SwimState = Player.swimming or 0
			ml_global_information.Player_MovementState = Player:GetMovementState() or 1
			ml_global_information.Player_Party = Player:GetParty() or nil
			ml_global_information.Player_CastInfo = Player.castinfo or nil
			ml_global_information.Player_Buffs = Player.buffs or {}
			ml_global_information.Player_InPVPMatch = PvPManager:IsInMatch()
			ml_global_information.Player_InPVPLobby = PvPManager:IsInPvPLobby()
			ml_global_information.Player_InPVPArea = ml_global_information.Player_InPVPMatch or ml_global_information.Player_InPVPLobby
			ml_global_information.Player_IsMounted = Player.mounted
			ml_global_information.Language = Player:GetLanguage()

			ml_global_information.CurrentMapID = Player:GetLocalMapID() or 0
			if (gw2_datamanager and ml_global_information.CurrentMapID ~= 0) then  
				ml_global_information.CurrentMapName = gw2_datamanager.GetMapName(ml_global_information.CurrentMapID) 
			else
				ml_global_information.CurrentMapName = ""
			end
			
			ml_global_information.Player_CurrentWeaponSet = Player:GetCurrentWeaponSet() or 0	-- 0 Aqua1, 1 Aqua2, 2 Engikit, 3 Necro Lich Form/ranger astralform,  4 Weapon1, 5 Weapon2
			ml_global_information.Player_TransformID = Player:GetTransformID() or 0 -- 1-4 attunement, 5 deathshroud, 9 rangernormal, 10 rangerastralform

		end
	end
end
RegisterEventHandler("Gameloop.Draw", ml_global_information.OnUpdate, "ml_global_information.OnUpdate")

function ml_global_information.Start()
	gw2_unstuck.Start()
end

function ml_global_information.Stop()	
    Player:StopMovement() -- this function is overrwitten in gw2_navigation.lua (on the bottom). It stops the player, clearls the path and resets OMCs. 
	gw2_unstuck.Stop()
end

-- Waits xxx seconds before running the next pulse
function ml_global_information.Waiting()
	ml_global_information.next_tick = ml_global_information.next_tick or BehaviorManager:GetLastTick() or ml_global_information.Now
	return TimeSince(ml_global_information.next_tick) < 0
end

function ml_global_information.Wait(mseconds)
	ml_global_information.next_tick = (BehaviorManager:GetLastTick() or ml_global_information.Now) + mseconds
	BehaviorManager:SetLastTick(ml_global_information.next_tick)
end
