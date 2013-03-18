eventmonitor = { }
eventmonitor.running = false
eventmonitor.lastticks = 0
eventmonitor.visible = false

function eventmonitor.ToggleMenu()
	if (eventmonitor.visible) then
		GUI_WindowVisible("eventmonitor",false)	
		eventmonitor.visible = false
		eventmonitor.running = false
	else
		GUI_WindowVisible("eventmonitor",true)	
		eventmonitor.visible = true
		eventmonitor.running = true
	end
end

function eventmonitor.ClearFields()
	GUI_NewField("eventmonitor","Get Type","TargetGetType","TargetInfo")
	GUI_NewField("eventmonitor","ID","TargetID","TargetInfo")
	GUI_NewField("eventmonitor","health.current","TargetHealthCurrent","TargetInfo")
	GUI_NewField("eventmonitor","health.max","TargetHealthMax","TargetInfo")
	GUI_NewField("eventmonitor","health.percent","TargetHealthPercent","TargetInfo")
	GUI_NewField("eventmonitor","pos.x","TargetPosX","TargetInfo")
	GUI_NewField("eventmonitor","pos.y","TargetPosY","TargetInfo")
	GUI_NewField("eventmonitor","pos.z","TargetPosZ","TargetInfo")
	GUI_NewField("eventmonitor","pos.onmesh","TargetOnMesh","TargetInfo")
	GUI_NewField("eventmonitor","alive","TargetAlive","TargetInfo")
	GUI_NewField("eventmonitor","healthstate","TargetHealthState","TargetInfo")
	GUI_NewField("eventmonitor","lootable","TargetLootable","TargetInfo")
	GUI_NewField("eventmonitor","isPlayer","TargetIsPlayer","TargetInfo")
	GUI_NewField("eventmonitor","isControlled","TargetIsControlled","TargetInfo")
	GUI_NewField("eventmonitor","attitude","TargetAttitude","TargetInfo")
	GUI_NewField("eventmonitor","swiming","TargetSwimming","TargetInfo")
	GUI_NewField("eventmonitor","level","TargetLevel","TargetInfo")
	GUI_NewField("eventmonitor","profession","TargetProfession","TargetInfo")
	GUI_NewField("eventmonitor","distance","TargetDistance","TargetInfo")
	GUI_NewField("eventmonitor","pathdistance","TargetPathDistance","TargetInfo")
	GUI_NewField("eventmonitor","los","TargetLOS","TargetInfo")
	GUI_NewField("eventmonitor","isChampion","TargetIsChampion","TargetInfo")
	GUI_NewField("eventmonitor","isVeteran","TargetIsVeteran","TargetInfo")
	GUI_FoldGroup("eventmonitor","TargetInfo");
	
	GUI_NewField("eventmonitor","GagetType","GadgetGetType","GadgetInfo")
	GUI_NewField("eventmonitor","GadgetID","GadgetID","GadgetInfo")
	GUI_NewField("eventmonitor","Health.current","GadgetHealthCurrent","GadgetInfo")
	GUI_NewField("eventmonitor","Health.max","GadgetHealthMax","GadgetInfo")
	GUI_NewField("eventmonitor","Health.percent","GadgetHealthPercent","GadgetInfo")
	GUI_NewField("eventmonitor","Pos.x","GadgetPosX","GadgetInfo")
	GUI_NewField("eventmonitor","Pos.y","GadgetPosY","GadgetInfo")
	GUI_NewField("eventmonitor","Pos.z","GadgetPosZ","GadgetInfo")
	GUI_NewField("eventmonitor","Pos.onmesh","GadgetOnMesh","GadgetInfo")	
	GUI_NewField("eventmonitor","Distance","GadgetDistance","GadgetInfo")
	GUI_NewField("eventmonitor","Pathdistance","GadgetPathDistance","GadgetInfo")
	GUI_NewField("eventmonitor","Los","GadgetLOS","GadgetInfo")
	GUI_NewField("eventmonitor","type","GadgetType","GadgetInfo")
	GUI_NewField("eventmonitor","resourceType","GadgetResourceType","GadgetInfo")
	GUI_NewField("eventmonitor","gatherable","GadgetGatherable","GadgetInfo")
	GUI_NewField("eventmonitor","contentID","GadgetcontentID","GadgetInfo")
	GUI_NewField("eventmonitor","state","Gadgetstate","GadgetInfo")
	GUI_NewField("eventmonitor","category","GadgetCategory","GadgetInfo")
	GUI_NewField("eventmonitor","hasHPBar","GadgetHasHPBar","GadgetInfo")
	GUI_NewField("eventmonitor","IsOurs","GadgetIsOurs","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownA","GadgetA","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownB","GadgetB","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownC","GadgetC","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownD","GadgetD","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownE","GadgetE","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownF","GadgetF","GadgetInfo")
	GUI_NewField("eventmonitor","UnknownG","GadgetG","GadgetInfo")
	GUI_NewField("eventmonitor","isselectable","Gadgetisselectable","GadgetInfo")	
	GUI_FoldGroup("eventmonitor","GadgetInfo");
			
	GUI_NewField("eventmonitor","Event Count","EventCount","EventInfo")
	GUI_NewField("eventmonitor","Event Type","Eventtype","EventInfo")
	GUI_NewField("eventmonitor","Event WMtype","Eventwmtype","EventInfo")
	GUI_NewField("eventmonitor","Event Mtype","Eventmtype","EventInfo")
	GUI_NewField("eventmonitor","CharacterID","charID","EventInfo")
	GUI_NewField("eventmonitor","EventID","eventID","EventInfo")
	GUI_NewField("eventmonitor","QuestID","questID","EventInfo")
	GUI_NewField("eventmonitor","Epos.x","EPosX","EventInfo")
	GUI_NewField("eventmonitor","Epos.y","EPosY","EventInfo")
	GUI_NewField("eventmonitor","Epos.z","EPosZ","EventInfo")
	GUI_NewField("eventmonitor","Distance","Edist","EventInfo")
	GUI_NewField("eventmonitor","ObjectiveCount","Ocount","EventInfo")
	GUI_NewField("eventmonitor","Level","Level","EventInfo")
	GUI_NewField("eventmonitor","IsRunning","runs","EventInfo")
	GUI_NewField("eventmonitor","IsDungeonEv","isdungeon","EventInfo")
	GUI_NewField("eventmonitor","EventA","EA","EventInfo")
	GUI_NewField("eventmonitor","EventB","EB","EventInfo")
	GUI_NewField("eventmonitor","EventC","EC","EventInfo")
	GUI_NewField("eventmonitor","EventD","ED","EventInfo")
	GUI_NewField("eventmonitor","EventE","EE","EventInfo")
	GUI_NewField("eventmonitor","EventF","EF","EventInfo")
	GUI_NewField("eventmonitor","EventG","EG","EventInfo")
	
	GUI_NewField("eventmonitor","UKNA","UA","EventInfo")
	GUI_NewField("eventmonitor","UKNB","UB","EventInfo")
	GUI_NewField("eventmonitor","UKNC","UC","EventInfo")
	GUI_NewField("eventmonitor","UKND","UD","EventInfo")
	GUI_NewField("eventmonitor","UKNE","UE","EventInfo")
	GUI_NewField("eventmonitor","UKNF","UF","EventInfo")
	GUI_NewField("eventmonitor","UKNG","UG","EventInfo")
	GUI_NewField("eventmonitor","UKNH","UH","EventInfo")
	GUI_NewField("eventmonitor","UKNI","UI","EventInfo")
	GUI_FoldGroup("eventmonitor","EventInfo");
	GUI_WindowVisible("eventmonitor",false)
end
			
function eventmonitor.UpdateWindow()
	TID = Player:GetTarget()
	if (TID  ~= nil) and (TID ~= 0) then
		mytarget = CharacterList:Get(TID)
		if (mytarget ~= nil) then
			TargetID = TID
			TargetGetType = "Character"
			TargetHealthCurrent = mytarget.health.current
			TargetHealthMax = mytarget.health.max
			TargetHealthPercent = mytarget.health.percent
			TargetPosX = (math.floor(mytarget.pos.x * 10) / 10)
			TargetPosY = (math.floor(mytarget.pos.y * 10) / 10)
			TargetPosZ = (math.floor(mytarget.pos.z * 10) / 10)
			TargetOnMesh = tostring(mytarget.pos.onmesh)
			TargetAlive = tostring(mytarget.alive)
			TargetHealthState = mytarget.healthstate
			TargetLootable = tostring(mytarget.lootable)
			TargetIsPlayer = tostring(mytarget.isPlayer)
			TargetIsControlled = tostring(mytarget.isControlled)
			TargetAttitude = mytarget.attitude
			TargetSwimming = mytarget.swimming
			TargetLevel = mytarget.level
			TargetProfession = mytarget.profession
			TargetDistance = (math.floor(mytarget.distance * 10) / 10)
			TargetPathDistance = mytarget.pathdistance
			TargetLOS = tostring(mytarget.los)
			TargetIsVeteran = tostring(mytarget.isVeteran)
			TargetIsChampion = tostring(mytarget.isChampion)
		else
			mytarget = GadgetList:Get(TID)
			if (mytarget ~= nil) then
				GadgetID = TID
				GadgetGetType = "Gadget"
				if (mytarget.hashpbar and mytarget.iscombatant and mytarget.health ~= nil) then
					GadgetHealthCurrent = mytarget.health.current
					GadgetHealthMax = mytarget.health.max
					GadgetHealthPercent = mytarget.health.percent
				else
					GadgetHealthCurrent = "n/a"
					GadgetHealthMax = "n/a"
					GadgetHealthPercent = "n/a"
				end
				GadgetPosX = (math.floor(mytarget.pos.x * 10) / 10)
				GadgetPosY = (math.floor(mytarget.pos.y * 10) / 10)
				GadgetPosZ = (math.floor(mytarget.pos.z * 10) / 10)
				GadgetOnMesh = tostring(mytarget.pos.onmesh)				
				GadgetDistance = (math.floor(mytarget.distance * 10) / 10)
				GadgetPathDistance = mytarget.pathdistance
				GadgetLOS = tostring(mytarget.los)
				GadgetType = mytarget.type
				GadgetResourceType = mytarget.resourceType
				GadgetGatherable = tostring(mytarget.gatherable)
				GadgetcontentID = tostring(mytarget.contentID)
				Gadgetstate = tostring(mytarget.state)
				GadgetCategory = tostring(mytarget.category)
				GadgetHasHPBar = tostring(mytarget.hashpbar)
				GadgetIsOurs = tostring(mytarget.isours)
				GadgetA = tostring(mytarget.A)
				GadgetB = tostring(mytarget.B)
				GadgetC = tostring(mytarget.C)
				GadgetD = tostring(mytarget.D)
				GadgetE = tostring(mytarget.E)
				GadgetF = tostring(mytarget.F)
				GadgetG = tostring(mytarget.G)
				Gadgetisselectable = tostring(mytarget.isselectable)				
			end
		end
		
	else
	--get nearest gadget
			local mytargetT = GadgetList("nearest")
			if (mytargetT ~= nil) then
				local i,mytarget = next(mytargetT)
				if (i~=nil and mytarget ~= nil) then
					GadgetID = i
					GadgetGetType = "NearestGadget"
					if (mytarget.hashpbar and mytarget.iscombatant and mytarget.health) then
						GadgetHealthCurrent = mytarget.health.current
						GadgetHealthMax = mytarget.health.max
						GadgetHealthPercent = mytarget.health.percent
					else
						GadgetHealthCurrent = "n/a"
						GadgetHealthMax = "n/a"
						GadgetHealthPercent = "n/a"
					end
					GadgetPosX = (math.floor(mytarget.pos.x * 10) / 10)
					GadgetPosY = (math.floor(mytarget.pos.y * 10) / 10)
					GadgetPosZ = (math.floor(mytarget.pos.z * 10) / 10)
					GadgetOnMesh = tostring(mytarget.pos.onmesh)				
					GadgetDistance = (math.floor(mytarget.distance * 10) / 10)
					GadgetPathDistance = mytarget.pathdistance
					GadgetLOS = tostring(mytarget.los)
					GadgetType = mytarget.type
					GadgetResourceType = mytarget.resourceType
					GadgetGatherable = tostring(mytarget.gatherable)
					GadgetcontentID = tostring(mytarget.contentID)
					Gadgetstate = tostring(mytarget.state)
					GadgetCategory = tostring(mytarget.category)
					GadgetHasHPBar = tostring(mytarget.hashpbar)
					GadgetIsOurs = tostring(mytarget.isours)
					GadgetA = tostring(mytarget.A)
					GadgetB = tostring(mytarget.B)
					GadgetC = tostring(mytarget.C)
					GadgetD = tostring(mytarget.D)
					GadgetE = tostring(mytarget.E)
					GadgetF = tostring(mytarget.F)
					GadgetG = tostring(mytarget.G)
					Gadgetisselectable = tostring(mytarget.isselectable)	
					end
			end
	end
	
	local mlist = MapMarkerList("isevent")
	if (mlist ~= nil) then	
		local i,event = next(mlist)
		if (i~=nil and event~=nil) then			
			EventCount = tostring(TableSize(mlist))
			Eventtype = tostring(event.type)
			Eventwmtype = tostring(event.worldmarkertype)
			Eventmtype = tostring(event.markertype)
			charID = tostring(event.characterID)
			eventID = tostring(event.eventID)
			questID = tostring(event.questID)
			EPosX = math.floor(event.pos.x)
			EPosY = math.floor(event.pos.y)
			EPosZ = math.floor(event.pos.z)
			Edist = math.floor(event.distance)
			UA = tostring(event.A)
			UB = tostring(event.B)
			UC = tostring(event.C)
			UD = tostring(event.D)
			UE = tostring(event.E)
			UF = tostring(event.F)
			UG = tostring(event.G)
			UH = tostring(event.H)
			UI = tostring(event.I)
			local einfo = event.eventinfo
			if ( einfo) then
				ObjectiveCount = tostring(einfo.objectivecount)
				Level = tostring(einfo.level)
				runs = tostring(einfo.isrunning)
				isdungeon = tostring(einfo.isdungeonevent)
				EA = tostring(einfo.A)
				EB = tostring(einfo.B)
				EC = tostring(einfo.C)
				ED = tostring(einfo.D)
				EE = tostring(einfo.E)
				EF = tostring(einfo.F)
				EG = tostring(einfo.G)
			else
				ObjectiveCount = "none"
				Level = "none"
				runs = "none"
				isdungeon = "none"
				EA = "none"
				EB = "none"
				EC = "none"
				ED = "none"
				EE = "none"
				EF = "none"
				EG = "none"
			end
			

		end
	end
	
	GUI_RefreshWindow("eventmonitor")
end

function eventmonitor.OnUpdateHandler( Event, ticks ) 	
	if ( eventmonitor.running and ticks - eventmonitor.lastticks > 1000 ) then
		eventmonitor.lastticks = ticks
		eventmonitor.UpdateWindow()
	end
end

RegisterEventHandler("Gameloop.Update",eventmonitor.OnUpdateHandler)
GUI_NewWindow("eventmonitor",400,50,250,430)
eventmonitor.ClearFields()