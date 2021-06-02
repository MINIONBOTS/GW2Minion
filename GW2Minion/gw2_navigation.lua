-- Extends minionlib's ml_navigation.lua by adding the game specific navigation handler

-- Since we have different "types" of movement, add all types and assign a value to them. Make sure to include one entry for each of the 4 kinds below per movement type!
ml_navigation.NavPointReachedDistances = { ["Walk"] = 32, ["Diving"] = 48, ["Mounted"] = 100, }      -- Distance to the next node in the path at which the ml_navigation.pathindex is iterated
ml_navigation.PathDeviationDistances = { ["Walk"] = 50, ["Diving"] = 150, ["Mounted"] = 150, }      -- The max. distance the playerposition can be away from the current path. (The Point-Line distance between player and the last & next pathnode)
ml_navigation.lastMount = 0
ml_navigation.movement_status = 0
ml_navigation.skills = {}
ml_navigation.ticks = {
   favorite_mount = 0,
   mount = 0,
   obstacle_check = 0,
   sync = 0,
   mount_leap = 0,
}

ml_navigation.thresholds = {
   favorite_mount = 500,
   mount = 2500,
   obstacle_check = 25,
   sync = 25,
   mount_leap = 125,
}
ml_navigation.favorite_mounts = {
   "none",
   "Raptor",
   "Jackal",
}

-- gw2_obstacle_manager has control over this now
ml_navigation.avoidanceareasize = 50
ml_navigation.avoidanceareas = { }   -- TODO: make a proper API in c++ for handling a list and accessing single entries
ml_navigation.previous = {}
ml_navigation.obstacles = {
   left = {},
   right = {},
}

-- all mount related variables
ml_navigation.lastMountOMCID = nil
ml_navigation.gw2mount = {}
ml_navigation.gw2mount.disabled_buffs = { [57576] = true, [43406] = true, [49494] = true, [54938] = true, [14346] = true, [7509] = true, [7466] = true }
ml_navigation.gw2mount.skimmer = {
   ID = 40509,
   SKILLID = 41253,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 750,
   DISMOUNT_DISTANCE = 650,
   NAME = "Skimmer",
}
ml_navigation.gw2mount.warclaw = {
   ID = 54871,
   SKILLID = 54912,
   SKILLID_MASTERED = 54889,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 5000,
   DISMOUNT_DISTANCE = 650,
   NAME = "Warclaw",
}
ml_navigation.gw2mount.griffon = {
   ID = 44590,
   SKILLID = 41192,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 750,
   DISMOUNT_DISTANCE = 600,
   NAME = "Griffon",
}
ml_navigation.gw2mount.skyscale = {
   ID = 55715,
   SKILLID = 55536,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 750,
   DISMOUNT_DISTANCE = 600,
   NAME = "Skyscale",
}
ml_navigation.gw2mount.rollerbeetle = {
   ID = 50908,
   SKILLID = 51040,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 2500,
   DISMOUNT_DISTANCE = 1200,
   NAME = "Roller Beetle",
}
ml_navigation.gw2mount.springer = {
   NC_SUBTYPE = 7,
   ID = 41731,
   SKILLID = 45994,
   MAXLOADTIME = 800,
   GRACETIME = 2000,
   SYNCTIME = 500,
   LOWBOOSTFACTOR = 0.25, -- if we jump higher than far
   HIGHBOOSTFACTOR = 0.75, -- if we jump further than high
   GetMaxTravelHeight = function()
      return (ml_navigation.acc_name ~= "" and Settings.GW2Minion[ml_navigation.acc_name] and Settings.GW2Minion[ml_navigation.acc_name].springerMastered and 1050) or 550
   end,
   GetMaxTravelTime = function()
      return (ml_navigation.acc_name ~= "" and Settings.GW2Minion[ml_navigation.acc_name] and Settings.GW2Minion[ml_navigation.acc_name].springerMastered and 3500) or 2050
   end,
   PREMOUNT_DISTANCE = 600,
   MOUNT_SWITCH_DISTANCE = 450,
   DISMOUNT_DISTANCE = 600,
   NAME = "Springer",
}
ml_navigation.gw2mount.jackal = {
   NC_SUBTYPE = 8,
   ID = 40215,
   SKILLID = 46089,
   GRACETIME = 2000,
   SYNCTIME = 1000,
   PREMOUNT_DISTANCE = 3000,
   MOUNT_SWITCH_DISTANCE = 600,
   DISMOUNT_DISTANCE = 650,
   NAME = "Jackal",
}
ml_navigation.gw2mount.raptor = {
   NC_SUBTYPE = 9,
   ID = 41378,
   SKILLID = 40409,
   GRACETIME = 1000,
   SYNCTIME = 500,
   GetMaxTravelDistance = function()
      return (ml_navigation.acc_name ~= "" and Settings.GW2Minion[ml_navigation.acc_name] and Settings.GW2Minion[ml_navigation.acc_name].raptorMastered and 1884) or 1100
   end,
   PREMOUNT_DISTANCE = 3000,
   MOUNT_SWITCH_DISTANCE = 600,
   DISMOUNT_DISTANCE = 650,
   NAME = "Raptor",
}
ml_navigation.smooth_dismounts = {
   [1] = 575,
   [3] = 425,
   [4] = 425,
   [6] = 425,
   [7] = ml_navigation.gw2mount.springer.DISMOUNT_DISTANCE,
   [8] = ml_navigation.gw2mount.jackal.DISMOUNT_DISTANCE,
   [9] = ml_navigation.gw2mount.raptor.DISMOUNT_DISTANCE,
}
ml_navigation.GetMovementType = function()
   if (Player.swimming ~= GW2.SWIMSTATE.Diving) then
      if (Player.mounted) then
         return "Mounted"
      else
         return "Walk"
      end
   else
      return "Diving"
   end
end   -- Return the EXACT NAMES you used above in the 4 tables for movement type keys
ml_navigation.StopMovement = function()
   Player:StopMovement()
end

function ml_navigation.Init()
   ml_navigation.acc_name = GetAccountName()
end

RegisterEventHandler("Module.Initalize", ml_navigation.Init, "ml_navigation.Init")

-- Main function to move the player. 'targetid' is optional but should be used as often as possible, if there is no target, use 0
function Player:MoveTo(x, y, z, targetid, stoppingdistance, randommovement, smoothturns, staymounted, use_leaps)
   local ms = Player.movementstate
   local last_dest = ml_navigation.path and ml_navigation.path[table.size(ml_navigation.path)]

   --- Check if we are synced with the world due to teleports or what not; added here to handle everything movement related.

   if (ms ~= GW2.MOVEMENTSTATE.Falling and ms ~= GW2.MOVEMENTSTATE.Jumping) or not table.valid(ml_navigation.path) or (last_dest and math.distance3d(last_dest, { x = x, y = y, z = z }) > 5) then
      ml_navigation.stoppingdistance = stoppingdistance or 154
      ml_navigation.randommovement = randommovement
      ml_navigation.smoothturns = smoothturns or true
      ml_navigation.targetid = targetid or 0
      ml_navigation.staymounted = staymounted or false
      ml_navigation.use_leaps = use_leaps == nil and true or use_leaps
      ml_navigation.debug = nil

      ml_navigation.targetposition = { x = x, y = y, z = z }

      if (not ml_navigation.navconnection or ml_navigation.navconnection.type == 5) then
         -- We are not currently handling a NavConnection / ignore MacroMesh Connections, these have to be replaced with a proper path by calling this exact function here
         if (ml_navigation.navconnection) then
            gw2_unstuck.Reset()
         end
         ml_navigation.navconnection = nil
         local status = ml_navigation:MoveTo(x, y, z, targetid)
         ml_navigation.movement_status = status

         if status > 0 then
            if ms == 0 then
               d("[Navigation] - Players Movement Mode is 0. This is mostly caused by teleports. Stepping backwards to fix.")
               ml_navigation.Sync()
            end
         end

         -- Handle stuck if we start off mesh
         if (status == -1 or status == -7) then
            -- We're starting off the mesh, so return 0 (valid) to let unstuck handle moving without failing the moveto
            gw2_unstuck.HandleStuck()
            return 0
         end
         return status
      else
         return table.size(ml_navigation.path)
      end
   else
      if table.valid(ml_navigation.path) then
         return table.size(ml_navigation.path)
      else
         return ml_navigation.movement_status
      end
   end
end

--- Handles the Navigation along the current Path. Is not supposed to be called manually.
function ml_navigation.Navigate(event, ticks)

   if ((ticks - (ml_navigation.lastupdate or 0)) > 10) then

      if GetGameState() == GW2.GAMESTATE.GAMEPLAY then
         ml_navigation.lastupdate = ticks
         local playerpos = Player.pos

         if playerpos then
            local energy = Player:GetEnergies(0)
            ml_navigation.mount_energy = energy and energy.A or 0
            if Player.mounted then
               ml_navigation.fight_aggro = false
            end

            if (ml_navigation.forcereset) then
               ml_navigation.forcereset = nil
               Player:StopMovement()
               return
            end

            --- Sync in case we are not
            if ml_navigation.sync ~= nil then
               local moving = ml_navigation.isMoving(Player.movementstate)
               if ml_navigation.sync == true or not moving then
                  Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
                  ml_navigation.sync = false
               elseif moving then
                  Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                  ml_navigation.sync = nil
               end
            end

            if (not ml_navigation.debug) then
               local allowMount = true
               ml_navigation.mounted = Player.mounted
               ml_navigation.skills[5] = Player:GetSpellInfo(5)
               ml_navigation.skills[19] = Player:GetSpellInfo(19)
               ml_navigation.current_Mount = {}
               ml_navigation.current_Mount.skill, ml_navigation.current_Mount.info = ml_navigation.getCurrentMount((ml_navigation.skills[5] and ml_navigation.skills[5].id), (ml_navigation.skills[19] and ml_navigation.skills[19].id))
               ml_navigation.inWvW = ml_navigation.IsInWvW()
               local mount = (Settings.GW2Minion[ml_navigation.acc_name].favorite_mount ~= 1 and ml_navigation.inWvW and "warclaw") or (Settings.GW2Minion[ml_navigation.acc_name].favorite_mount == 2 and "raptor") or (Settings.GW2Minion[ml_navigation.acc_name].favorite_mount == 3 and "jackal")
               ml_navigation.skills.favorite_mount = mount and ml_navigation.gw2mount[mount] and ml_navigation.getCurrentMount(ml_navigation.gw2mount[mount].SKILLID, ml_navigation.gw2mount[mount].ID)
               ml_navigation.pathindex = NavigationManager.NavPathNode   -- gets the current path index which is saved in c++ ( and changed there on updating / adjusting the path, which happens each time MoveTo() is called. Index starts at 1 and 'usually' is 2 whne running
               local can_switch_mount = true

               if (Player.buffs and gw2_common_functions.HasBuffs(Player, ml_navigation.gw2mount.disabled_buffs)) then
                  allowMount = false
               end

               local pathsize = table.size(ml_navigation.path)
               if (pathsize > 0) then
                  if (ml_navigation.pathindex <= pathsize) then
                     local lastnode = ml_navigation.pathindex > 1 and ml_navigation.path[ml_navigation.pathindex - 1] or nil
                     local nextnode = ml_navigation.path[ml_navigation.pathindex]
                     local nextnextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                     local totalpathdistance = ml_navigation.path[1].pathdistance or 0
                     local movementstate = Player:GetMovementState()
                     local path_distance, check_obstacle, smooth_dismount, next_mount = 0, true

                     --- Ensure Position: Takes a second to make sure the player is really stopped at the wanted position (used for precise OMC bunnyhopping)
                     if (table.valid(ml_navigation.ensureposition) and ml_navigation:EnsurePosition(playerpos)) then
                        return
                     end

                     --- Validate the next few path nodes if they are mount OMCs and are reachable (mastery, too high/far in general etc.)
                     for index = 0, 20 do
                        local navCon = ml_navigation.path[ml_navigation.pathindex + index]
                        local prevCon = ((ml_navigation.pathindex + index - 1) >= ml_navigation.pathindex and ml_navigation.path[ml_navigation.pathindex + index - 1]) or playerpos
                        if (navCon) then
                           path_distance = path_distance + ((prevCon and math.distance3d({ x = navCon.x, y = navCon.y, z = navCon.z }, { x = prevCon.x, y = prevCon.y, z = prevCon.z })) or 0)

                           local navConId = navCon.navconnectionid
                           local omc = NavigationManager:GetNavConnection(navConId)

                           if (omc and omc.details and navConId ~= 0 and omc.details.subtype == 7) then
                              local startPos = (omc.sideA.walkable and omc.sideA.x == navCon.x and omc.sideA.y == navCon.y and omc.sideA.z == navCon.z) and omc.sideA or omc.sideB
                              local endPos = (omc.sideA.x == startPos.x and omc.sideA.y == startPos.y and omc.sideA.z == startPos.z) and omc.sideB or omc.sideA
                              if (not Settings.GW2Minion[ml_navigation.acc_name].usemount or not ml_navigation:ValidSpringerOMC(startPos, endPos)) then
                                 if (omc.enabled) then
                                    d("[Navigation] - Springer OMC (ID:" .. tostring(navConId) .. ") disabled at [" .. tostring(startPos.x) .. "," .. tostring(startPos.y) .. "," .. tostring(startPos.z) .. "]")
                                    NavigationManager:ResetPath()
                                    ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                    DisableNavConnection(omc, nil)
                                 end
                              else
                                 EnableNavConnection(omc)
                                 if not next_mount then
                                    next_mount = {
                                       distance = math.round(path_distance),
                                       mount = ml_navigation.gw2mount.springer,
                                       pre_mount = path_distance <= ml_navigation.gw2mount.springer.PREMOUNT_DISTANCE,
                                    }
                                 end
                              end
                           elseif (omc and omc.details and navConId ~= 0 and omc.details.subtype == 8) then
                              local startPos = (omc.sideA.walkable and omc.sideA.x == navCon.x and omc.sideA.y == navCon.y and omc.sideA.z == navCon.z) and omc.sideA or omc.sideB
                              if (not Settings.GW2Minion[ml_navigation.acc_name].usemount or not Settings.GW2Minion[ml_navigation.acc_name].jackalPortalMastered) then
                                 if (omc.enabled) then
                                    d("[Navigation] - Jackal Portal OMC (ID:" .. tostring(navConId) .. ") disabled at [" .. tostring(startPos.x) .. "," .. tostring(startPos.y) .. "," .. tostring(startPos.z) .. "]")
                                    NavigationManager:ResetPath()
                                    ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                    DisableNavConnection(omc, nil)
                                 end
                              else
                                 EnableNavConnection(omc)
                                 if not next_mount then
                                    next_mount = {
                                       distance = math.round(path_distance),
                                       mount = ml_navigation.gw2mount.jackal,
                                       pre_mount = path_distance <= ml_navigation.gw2mount.jackal.PREMOUNT_DISTANCE,
                                    }
                                 end
                              end
                           elseif (omc and omc.details and navConId ~= 0 and omc.details.subtype == 9) then
                              local startPos = (omc.sideA.walkable and omc.sideA.x == navCon.x and omc.sideA.y == navCon.y and omc.sideA.z == navCon.z) and omc.sideA or omc.sideB
                              local endPos = (omc.sideA.x == startPos.x and omc.sideA.y == startPos.y and omc.sideA.z == startPos.z) and omc.sideB or omc.sideA
                              if (not Settings.GW2Minion[ml_navigation.acc_name].usemount or not ml_navigation:ValidRaptorOMC(startPos, endPos)) then
                                 if (omc.enabled) then
                                    d("[Navigation] - Raptor Jump OMC (ID:" .. tostring(navConId) .. ") disabled at [" .. tostring(startPos.x) .. "," .. tostring(startPos.y) .. "," .. tostring(startPos.z) .. "]")
                                    NavigationManager:ResetPath()
                                    ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                    DisableNavConnection(omc, nil)
                                 end
                              else
                                 EnableNavConnection(omc)
                                 if not next_mount then
                                    next_mount = {
                                       distance = math.round(path_distance),
                                       mount = ml_navigation.gw2mount.raptor,
                                       pre_mount = path_distance <= ml_navigation.gw2mount.raptor.PREMOUNT_DISTANCE,
                                    }
                                 end
                              end

                           elseif (omc and omc.details and (omc.details.subtype == 1 or omc.details.subtype == 3 or omc.details.subtype == 4 or omc.details.subtype == 6)) then
                              if omc.details.subtype == 6 then
                                 if omc.details.luacode then
                                    if string.contains(omc.details.luacode, "PauseMountUsage") then
                                       smooth_dismount = smooth_dismount or {
                                          distance = path_distance,
                                          subtype = omc.details.subtype,
                                       }
                                    end
                                 end

                              elseif omc.details.subtype ~= 6 then
                                 smooth_dismount = smooth_dismount or {
                                    distance = path_distance,
                                    subtype = omc.details.subtype,
                                 }
                              end
                           elseif omc and omc.details and (omc.details.subtype == 5) then
                              if index <= 1 then
                                 check_obstacle = false
                              end
                           end
                        end
                     end

                     --- Handle Current NavConnections
                     if (ml_navigation.navconnection) then
                        -- Temp solution to cancel navcon handling after 10 sec
                        if (ml_navigation.navconnection_start_tmr and (ml_global_information.Now - ml_navigation.navconnection_start_tmr > 10000)) then
                           d("[Navigation] - We did not complete the Navconnection handling in 10 seconds, something went wrong ?...Resetting Path..")
                           ml_navigation.currentMountOMC = nil
                           allowMount = false
                           Player:StopMovement()
                           return
                        end


                        --d("ml_navigation.navconnection ID " ..tostring(ml_navigation.navconnection.id))
                        --CubeCube & PolyPoly && Floor-Cube -> go straight to the end node
                        if (ml_navigation.navconnection.type == 1 or ml_navigation.navconnection.type == 2 or ml_navigation.navconnection.type == 3) then
                           lastnode = nextnode
                           nextnode = ml_navigation.path[ml_navigation.pathindex + 1]

                           -- Custom OMC
                        elseif (ml_navigation.navconnection.type == 4) then

                           local ncsubtype
                           local ncradius
                           local ncdirectionFromA
                           if (ml_navigation.navconnection.details) then
                              ncsubtype = ml_navigation.navconnection.details.subtype
                              if (nextnode.navconnectionsideA == true) then
                                 ncradius = ml_navigation.navconnection.sideB.radius -- yes , B , not A
                                 ncdirectionFromA = true
                              else
                                 ncradius = ml_navigation.navconnection.sideA.radius
                                 ncdirectionFromA = false
                              end
                           end
                           if (ncsubtype == 1) then
                              -- JUMP
                              if (ml_navigation.mounted) then
                                 Player:Dismount()
                                 ml_navigation.PauseMountUsage(5000)
                              end
                              lastnode = nextnode
                              nextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                              if (movementstate == GW2.MOVEMENTSTATE.Jumping) then
                                 if (not ml_navigation.omc_startheight) then
                                    ml_navigation.omc_startheight = playerpos.z
                                 end
                                 -- Additionally check if we are "above" the target point already, in that case, stop moving forward
                                 local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                 if ((nodedist) < ml_navigation.NavPointReachedDistances["Walk"] or (playerpos.z < nextnode.z and (math.distance2d(playerpos, nextnode) - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"])) then
                                    d("[Navigation] - We are above the OMC_END Node, stopping movement. (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                    Player:Stop()
                                    if (ncradius < 1.0) then
                                       ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                    end
                                 else
                                    Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                 end
                                 Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)

                              elseif (movementstate == GW2.MOVEMENTSTATE.Falling and ml_navigation.omc_startheight) then
                                 -- If Playerheight is lower than 4*omcreached dist AND Playerheight is lower than 4* our Startposition -> we fell below the OMC START & END Point
                                 if ((playerpos.z > (nextnode.z + 4 * ml_navigation.NavPointReachedDistances["Walk"])) and (playerpos.z > (ml_navigation.omc_startheight + 4 * ml_navigation.NavPointReachedDistances["Walk"]))) then
                                    if (ml_navigation.omcteleportallowed and math.distance3d(playerpos, nextnode) < ml_navigation.NavPointReachedDistances["Walk"] * 10) then
                                       if (ncradius < 1.0) then
                                          ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                       end
                                    else
                                       d("[Navigation] - We felt below the OMC start & END height, missed our goal...")
                                       ml_navigation.StopMovement()
                                    end
                                 else
                                    -- Additionally check if we are "above" the target point already, in that case, stop moving forward
                                    local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                    if ((nodedist) < ml_navigation.NavPointReachedDistances["Walk"] or (playerpos.z < nextnode.z and (math.distance2d(playerpos, nextnode) - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"])) then
                                       d("[Navigation] - We are above the OMC END Node, stopping movement. (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                       Player:Stop()
                                       if (ncradius < 1.0) then
                                          ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                       end
                                    else
                                       Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                       Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                                    end
                                 end

                              else
                                 -- We are still before our Jump
                                 if (not ml_navigation.omc_startheight) then
                                    if (Player:CanMove() and ml_navigation.omc_starttimer == 0) then
                                       ml_navigation.omc_starttimer = ticks
                                       Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                       Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                                    elseif (Player:IsMoving() and ticks - ml_navigation.omc_starttimer > 100) then
                                       Player:Jump()
                                    end

                                 else
                                    -- We are after the Jump and landed already
                                    local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                                    if ((nodedist - ncradius * 32) < ml_navigation.NavPointReachedDistances["Walk"]) then
                                       d("[Navigation] - We reached the OMC END Node (Jump). (" .. tostring(math.round(nodedist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances["Walk"]) .. ")")
                                       local nextnode = nextnextnode
                                       local nextnextnode = ml_navigation.path[ml_navigation.pathindex + 2]
                                       if (ncradius < 1.0) then
                                          ml_navigation:SetEnsureEndPosition(nextnode, nextnextnode, playerpos)
                                       end
                                       ml_navigation.pathindex = ml_navigation.pathindex + 1
                                       NavigationManager.NavPathNode = ml_navigation.pathindex
                                       ml_navigation.navconnection = nil

                                    else
                                       Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                       Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                                    end
                                 end
                              end
                              return

                           elseif (ncsubtype == 2) then
                              -- WALK
                              lastnode = nextnode      -- OMC start
                              nextnode = ml_navigation.path[ml_navigation.pathindex + 1]   -- OMC end

                              local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
                              local enddist = nodedist - ncradius * 32
                              if (enddist < ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()]) then
                                 d("[Navigation] - We reached the OMC END Node (Walk). (" .. tostring(math.round(enddist, 2)) .. " < " .. tostring(ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()]) .. ")")
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.navconnection = nil
                              end
                           elseif (ncsubtype == 3) then
                              -- TELEPORT
                              nextnode = ml_navigation.path[ml_navigation.pathindex + 1]
                              HackManager:Teleport(nextnode.x, nextnode.y, nextnode.z)
                              ml_navigation.pathindex = ml_navigation.pathindex + 1
                              NavigationManager.NavPathNode = ml_navigation.pathindex
                              ml_navigation.navconnection = nil
                              return

                           elseif (ncsubtype == 4) then
                              -- INTERACT
                              Player:Stop()
                              -- delay getting on mount, this can cancel whatever interacter needs to take place
                              ml_navigation.PauseMountUsage(2000)
                              if (not ml_navigation.mounted and movementstate ~= GW2.MOVEMENTSTATE.Jumping and movementstate ~= GW2.MOVEMENTSTATE.Falling) then
                                 Player:Interact()
                                 ml_navigation.lastupdate = ml_navigation.lastupdate + 1000
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.navconnection = nil
                              elseif (ml_navigation.mounted) then
                                 Player:Dismount()
                                 ml_navigation.PauseMountUsage(3000)
                              end
                              return

                           elseif (ncsubtype == 5) then
                              -- PORTAL
                              -- Check if we have reached the portal end position
                              local portalend = ml_navigation.path[ml_navigation.pathindex + 1]
                              if (ml_navigation:NextNodeReached(playerpos, portalend, nextnextnode)) then
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.navconnection = nil

                              else
                                 -- We need to face and move
                                 if (nextnode.navconnectionsideA == true) then
                                    Player:SetFacingH(ml_navigation.navconnection.details.headingA_x, ml_navigation.navconnection.details.headingA_y, ml_navigation.navconnection.details.headingA_z)
                                 else
                                    Player:SetFacingH(ml_navigation.navconnection.details.headingB_x, ml_navigation.navconnection.details.headingB_y, ml_navigation.navconnection.details.headingB_z)
                                 end
                              end
                              return

                           elseif (ncsubtype == 6) then
                              -- Custom Lua Code
                              lastnode = nextnode      -- OMC start
                              nextnode = nextnextnode   -- OMC end
                              local result

                              if (ml_navigation.navconnection.details.luacode and ml_navigation.navconnection.details.luacode and ml_navigation.navconnection.details.luacode ~= "" and ml_navigation.navconnection.details.luacode ~= " ") then

                                 if (not ml_navigation.navconnection.luacode_compiled and not ml_navigation.navconnection.luacode_bugged) then
                                    local execstring = 'return function(self,startnode,endnode) ' .. ml_navigation.navconnection.details.luacode .. ' end'
                                    local func = loadstring(execstring)
                                    if (func) then
                                       result = func()(ml_navigation.navconnection, lastnode, nextnode)
                                       if (ml_navigation.navconnection) then
                                          -- yeah happens, crazy, riught ?
                                          ml_navigation.navconnection.luacode_compiled = func
                                       else
                                          --ml_error("[Navigation] - Cannot set luacode_compiled, ml_navigation.navconnection is nil !?")
                                       end
                                    else
                                       ml_navigation.navconnection.luacode_compiled = nil
                                       ml_navigation.navconnection.luacode_bugged = true
                                       ml_error("[Navigation] - A NavConnection ahead in the path of type 'Lua Code' has a BUG !")
                                       assert(loadstring(execstring)) -- print out the actual error
                                    end
                                 else
                                    --executing the already loaded function
                                    if (ml_navigation.navconnection.luacode_compiled) then
                                       result = ml_navigation.navconnection.luacode_compiled()(ml_navigation.navconnection, lastnode, nextnode)
                                    end
                                 end

                              else
                                 d("[Navigation] - ERROR: A 'Custom Lua Code' MeshConnection has NO lua code!...")
                              end

                              -- continue to walk to the omc end
                              if (result) then
                                 -- moving on to the omc end
                              else
                                 -- keep calling the MeshConnection
                                 return
                              end
                           elseif (ncsubtype == 7) then
                              -- SPRINGER
                              ml_navigation.staymounted = true -- prevent unnecessary dismounting

                              local function resetSpringerOMC()
                                 local continueNode = ml_navigation.path[ml_navigation.pathindex + 2]
                                 local navConId = continueNode.navconnectionid
                                 -- Continue path available
                                 if (navConId ~= 0 and (NavigationManager:GetNavConnection(navConId).details or {}).subtype == 7) then
                                    -- We will have right after a springer jump OMC again so we stay mounted on springer
                                    ml_navigation.PauseMountUsage(ml_navigation.gw2mount.springer.GRACETIME)
                                 end
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 ml_navigation.navconnection = nil
                                 d("[Navigation] - Springer OMC done")
                                 return
                              end

                              -- Make sure this is setup
                              if (Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key = 0x56 -- V
                              end
                              if (Settings.GW2Minion[ml_navigation.acc_name].stepBackwards == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].stepBackwards = 0x53 -- S
                              end

                              -- We got into combat so we abort the OMC
                              if (not ml_navigation.mounted and Player.inCombat and ml_navigation.navconnection) then
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 local target = gw2_common_functions.AggroTargetAtPos(nextnode, 1200)
                                 if target then
                                    ml_navigation.fight_aggro = {
                                       target_id = target.id,
                                       pos = { x = nextnode.x, y = nextnode.y, z = nextnode.z, },
                                       id = ml_navigation.navconnection.id,
                                    }
                                 else
                                    ml_navigation.fight_aggro = false
                                 end

                                 Player:StopMovement()
                                 d("[Navigation] - Reset OMC due of being in combat.")
                                 return
                              else
                                 ml_navigation.fight_aggro = false
                              end

                              local skill = ml_navigation.skills[19]
                              -- Low level character without mount skill slot
                              if (not skill) then
                                 DisableNavConnection(ml_navigation.navconnection, nil)
                                 NavigationManager:ResetPath()
                                 ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                 resetSpringerOMC()
                                 d("[Navigation] - Springer OMC disabled. You don't have skill slot 19")
                                 return
                              end

                              -- OMC handling
                              if (table.valid(ml_navigation.currentMountOMC)) then
                                 -- OMC RUNNING

                                 -- Variable definitions
                                 local startPos = ml_navigation.currentMountOMC.startSide
                                 local endPos = ml_navigation.currentMountOMC.endSide
                                 local zDistToTravel = -startPos.z + endPos.z -- negativ means we have to descend
                                 local xyDistToTravel = math.distance2d(startPos, endPos)
                                 local xyDistToTravelFactor = zDistToTravel < xyDistToTravel and ml_navigation.gw2mount.springer.LOWBOOSTFACTOR or ml_navigation.gw2mount.springer.HIGHBOOSTFACTOR
                                 local totalDistToTravel = -zDistToTravel + xyDistToTravel * xyDistToTravelFactor
                                 local neededChargeTime = totalDistToTravel / ml_navigation.gw2mount.springer.GetMaxTravelHeight() * ml_navigation.gw2mount.springer.MAXLOADTIME
                                 local needTravelTime = ml_navigation.gw2mount.springer.GetMaxTravelHeight() / ml_navigation.gw2mount.springer.GetMaxTravelTime() * totalDistToTravel
                                 local angleToEndPos = gw2_common_functions.angle2DToTargetInDeg(playerpos, { x = playerpos.hx, y = playerpos.hy }, endPos)

                                 -- OMC end reached or we failed to jump
                                 if (ml_navigation.currentMountOMC.jumpTime
                                         and ((math.distance3d(playerpos, startPos) > math.distance3d(playerpos, endPos) - endPos.radius * 32) or (math.distance2d(playerpos, startPos) > math.distance2d(startPos, endPos) - endPos.radius * 32))
                                         and (movementstate == GW2.MOVEMENTSTATE.GroundMoving
                                         or movementstate == GW2.MOVEMENTSTATE.GroundNotMoving)) then

                                    if (TimeSince(ml_navigation.currentMountOMC.jumpTime) > neededChargeTime + needTravelTime) then
                                       resetSpringerOMC()
                                    else
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                    end
                                    return
                                 end

                                 -- SetFacingExact to have a smoother start and fast a correct direction, due to it being not 100% reliable we only try to use it once
                                 if (not ml_navigation.currentMountOMC.facingSet and not ml_navigation.currentMountOMC.jumpTime) then
                                    Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                    gw2_unstuck.SoftReset()
                                    Player:SetFacingExact(endPos.x, endPos.y, endPos.z, true)
                                    ml_navigation.currentMountOMC.facingSet = ml_global_information.Now
                                    --SetFacing has a "casttime" while beeing mounted, so we wait a bit
                                    if (ml_navigation.mounted and ml_navigation.lastupdate) then
                                       ml_navigation.lastupdate = ml_navigation.lastupdate + 1000 / 180 * angleToEndPos
                                    end
                                    return
                                 end

                                 -- Mount springer and save last mount to swap back later
                                 if (ml_navigation.currentMountOMC.mountTime and TimeSince(ml_navigation.currentMountOMC.mountTime) < 1000) then
                                    return
                                 elseif (ml_navigation.mounted and ml_navigation.skills[5].skillid ~= ml_navigation.gw2mount.springer.SKILLID) then
                                    Player:Dismount()
                                    return
                                 elseif (not ml_navigation.mounted and ml_navigation.skills[19].skillid == ml_navigation.gw2mount.springer.ID and Player.canmount) then
                                    if (movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
                                       Player:Mount()
                                       ml_navigation.currentMountOMC.mountTime = ml_global_information.Now
                                    end
                                    return
                                 elseif (not ml_navigation.mounted and Player.canmount and not ml_navigation.lastMountOMCID) then
                                    ml_navigation.lastMountOMCID = ml_navigation.skills[19].skillid
                                    Player:SelectMount(ml_navigation.gw2mount.springer.ID)
                                    return
                                 elseif (not ml_navigation.mounted) then
                                    return
                                 end

                                 -- face + jump
                                 if (not ml_navigation.currentMountOMC.jumpTime) then
                                    -- Do facing
                                    if (angleToEndPos > 15) then
                                       if (not ml_navigation.currentMountOMC.faceTime) then
                                          Player:SetMovement(gw2_common_functions.getTurnDirection(endPos))
                                          ml_navigation.currentMountOMC.faceTime = ml_global_information.Now
                                       end
                                       return
                                    else
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnLeft)
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnRight)
                                    end
                                    -- Do jump
                                    if (neededChargeTime > 0) then
                                       KeyDown(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                    end
                                    Player:SetFacingExact(endPos.x, endPos.y, endPos.z)
                                    ml_navigation.currentMountOMC.jumpTime = ml_global_information.Now
                                    ml_navigation.currentMountOMC.start_mount_energy = ml_navigation.mount_energy
                                    d("[Navigation] - Springer OMC jump with charge time of (" .. tostring(neededChargeTime) .. ")")
                                    return
                                 end

                                 -- Charge + in air phase
                                 if (ml_navigation.currentMountOMC.jumpTime and TimeSince(ml_navigation.currentMountOMC.jumpTime) > neededChargeTime) then
                                    gw2_unstuck.SoftReset()
                                    -- Interrupt jump
                                    KeyUp(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                    ml_navigation.currentMountOMC.stop_mount_energy = ml_navigation.currentMountOMC.stop_mount_energy or ml_navigation.mount_energy
                                    -- Move towards endPos
                                    local inAir = movementstate == GW2.MOVEMENTSTATE.Falling or movementstate == GW2.MOVEMENTSTATE.Jumping
                                    -- TODO: as soon we get a better way to track the charge skill bar we can start moving forward earlier and thus getting further
                                    if ((inAir or neededChargeTime <= 0) and math.distance2d(playerpos, startPos) <= math.distance2d(endPos, startPos)) then
                                       Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
                                    else
                                       -- prevent boosting over the endpoint
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                       if (math.distance2d(playerpos, startPos) >= math.distance2d(endPos, startPos) - endPos.radius * 32) then
                                          Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
                                       else
                                          Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                       end
                                    end

                                    if ml_navigation.currentMountOMC.stop_mount_energy >= ml_navigation.currentMountOMC.start_mount_energy and math.distance2d(playerpos, startPos) < math.distance2d(playerpos, endPos) then
                                       d("[Navigation] - Mount Energy still is above or equals our starting energy of " .. tostring(ml_navigation.currentMountOMC.start_mount_energy) .. ". Mount Energy at: " .. tostring(ml_navigation.currentMountOMC.stop_mount_energy))
                                       resetSpringerOMC()
                                    end
                                    return
                                 end
                              else
                                 -- OMC STARTING
                                 ml_navigation.currentMountOMC = {}
                                 ml_navigation.currentMountOMC.startSide = (ml_navigation.navconnection.sideB.walkable
                                         and math.distance3d(playerpos, ml_navigation.navconnection.sideA) >= math.distance3d(playerpos, ml_navigation.navconnection.sideB))
                                         and ml_navigation.navconnection.sideB
                                         or ml_navigation.navconnection.sideA
                                 ml_navigation.currentMountOMC.endSide = table.deepcompare(ml_navigation.currentMountOMC.startSide, ml_navigation.navconnection.sideB, true)
                                         and ml_navigation.navconnection.sideA
                                         or ml_navigation.navconnection.sideB

                                 ml_navigation.currentMountOMC.path = table.valid(ml_navigation.path) and table.deepcopy(ml_navigation.path[table.size(ml_navigation.path)], false)
                                 Player:Stop()
                                 d("[Navigation] - Springer OMC started")
                              end

                              return

                           elseif (ncsubtype == 8) then
                              -- JACKAL JUMP
                              ml_navigation.staymounted = true -- prevent unnecessary dismounting

                              local function resetJackalJumpOMC()
                                 local continueNode = ml_navigation.path[ml_navigation.pathindex + 2]
                                 local navConId = continueNode.navconnectionid
                                 -- Continue path available
                                 if (navConId ~= 0 and (NavigationManager:GetNavConnection(navConId).details or {}).subtype == 8) then
                                    -- We will have right after a springer jump OMC again so we stay mounted on springer
                                    ml_navigation.PauseMountUsage(ml_navigation.gw2mount.jackal.GRACETIME)
                                 end
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 ml_navigation.navconnection = nil
                                 d("[Navigation] - Jackal Portal OMC done")
                                 return
                              end

                              -- Make sure this is setup
                              if (Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key = 0x56 -- V
                              end
                              if (Settings.GW2Minion[ml_navigation.acc_name].stepBackwards == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].stepBackwards = 0x53 -- S
                              end

                              -- We got into combat so we abort the OMC
                              if (not ml_navigation.mounted and Player.inCombat and ml_navigation.navconnection) then
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 local target = gw2_common_functions.AggroTargetAtPos(nextnode, 1200)
                                 if target then
                                    ml_navigation.fight_aggro = {
                                       target_id = target.id,
                                       pos = { x = nextnode.x, y = nextnode.y, z = nextnode.z, },
                                       id = ml_navigation.navconnection.id,
                                    }
                                 else
                                    ml_navigation.fight_aggro = false
                                 end

                                 Player:StopMovement()
                                 d("[Navigation] - Reset OMC due of being in combat.")
                                 return
                              else
                                 ml_navigation.fight_aggro = false
                              end

                              -- Low level character without mount skill slot
                              if (not ml_navigation.skills[19]) then
                                 DisableNavConnection(ml_navigation.navconnection, nil)
                                 NavigationManager:ResetPath()
                                 ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                 resetJackalJumpOMC()
                                 d("[Navigation] - Jackal Portal OMC disabled. You don't have skill slot 19")
                                 return
                              end

                              -- OMC handling
                              if (table.valid(ml_navigation.currentMountOMC)) then
                                 -- OMC RUNNING

                                 -- Variable definitions
                                 local startPortalPos = ml_navigation.currentMountOMC.startPortal
                                 local startPos = ml_navigation.currentMountOMC.startSide
                                 local endPos = ml_navigation.currentMountOMC.endSide
                                 local angleToStartPortal = startPortalPos and gw2_common_functions.angle2DToTargetInDeg(playerpos, { x = playerpos.hx, y = playerpos.hy }, startPortalPos)

                                 if (not angleToStartPortal) then
                                    ml_navigation.currentMountOMC = nil
                                    allowMount = false
                                    Player:StopMovement()
                                    d("[Navigation] - Reset OMC due not finding any portal closeby.")
                                    return
                                 end

                                 -- OMC end reached or we failed to jump
                                 if (math.distance2d(playerpos, startPos) > math.distance2d(playerpos, endPos) - endPos.radius * 32) then
                                    if (not ml_navigation.currentMountOMC.syncPos) then
                                       if (movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
                                          ml_navigation.currentMountOMC.syncPos = ml_global_information.Now
                                       end
                                    elseif (TimeSince(ml_navigation.currentMountOMC.syncPos) < ml_navigation.gw2mount.jackal.SYNCTIME) then
                                       -- Sync camera TODO: make this one day better...
                                       PressKey(Settings.GW2Minion[ml_navigation.acc_name].stepBackwards)
                                    else
                                       resetJackalJumpOMC()
                                    end
                                    return
                                 end

                                 -- SetFacingExact to have a smoother start and fast a correct direction, due to it being not 100% reliable we only try to use it once
                                 if (not ml_navigation.currentMountOMC.facingSet and not ml_navigation.currentMountOMC.jumpTime) then
                                    Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                    gw2_unstuck.SoftReset()
                                    Player:SetFacingExact(startPortalPos.x, startPortalPos.y, startPortalPos.z, true)
                                    ml_navigation.currentMountOMC.facingSet = ml_global_information.Now
                                    --SetFacing has a "casttime" while beeing mounted, so we wait a bit
                                    if (ml_navigation.mounted and ml_navigation.lastupdate) then
                                       ml_navigation.lastupdate = ml_navigation.lastupdate + 1000 / 180 * angleToStartPortal
                                    end
                                    return
                                 end

                                 -- Mount jackal and save last mount to swap back later
                                 if (ml_navigation.currentMountOMC.mountTime and TimeSince(ml_navigation.currentMountOMC.mountTime) < 1000) then
                                    return
                                 elseif (ml_navigation.mounted and ml_navigation.skills[5].skillid ~= ml_navigation.gw2mount.jackal.SKILLID) then
                                    Player:Dismount()
                                    return
                                 elseif (not ml_navigation.mounted and ml_navigation.skills[19].skillid == ml_navigation.gw2mount.jackal.ID and Player.canmount) then
                                    if (movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
                                       Player:Mount()
                                       ml_navigation.currentMountOMC.mountTime = ml_global_information.Now
                                    end
                                    return
                                 elseif (not ml_navigation.mounted and Player.canmount and not ml_navigation.lastMountOMCID) then
                                    ml_navigation.lastMountOMCID = ml_navigation.skills[19].skillid
                                    Player:SelectMount(ml_navigation.gw2mount.jackal.ID)
                                    return
                                 elseif (not ml_navigation.mounted) then
                                    return
                                 end

                                 -- Facing and jump phase
                                 if (math.distance2d(playerpos, startPos) <= math.distance2d(playerpos, endPos) - endPos.radius * 32) then
                                    -- Facing, prevent facing trigger when we just jumped
                                    if (not ml_navigation.currentMountOMC.jumpTime or TimeSince(ml_navigation.currentMountOMC.jumpTime) > ml_navigation.gw2mount.springer.GRACETIME) then
                                       if (angleToStartPortal > 15) then
                                          -- Do facing
                                          if (not ml_navigation.currentMountOMC.faceTime or TimeSince(ml_navigation.currentMountOMC.faceTime) > ml_navigation.gw2mount.springer.GRACETIME) then
                                             Player:SetMovement(gw2_common_functions.getTurnDirection(startPortalPos))
                                             ml_navigation.currentMountOMC.faceTime = ml_global_information.Now
                                          end
                                          return
                                       else
                                          if (ml_navigation.currentMountOMC.faceTime) then
                                             if (not ml_navigation.currentMountOMC.overFacing) then
                                                ml_navigation.currentMountOMC.overFacing = ml_global_information.Now
                                                return
                                             else
                                                if (TimeSince(ml_navigation.currentMountOMC.overFacing) > 500) then
                                                   Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnLeft)
                                                   Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnRight)
                                                else
                                                   return
                                                end
                                             end
                                          end
                                       end
                                    end

                                    -- Jump phase
                                    if (not ml_navigation.currentMountOMC.jumpTime or TimeSince(ml_navigation.currentMountOMC.jumpTime) > ml_navigation.gw2mount.springer.GRACETIME) then
                                       PressKey(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                       ml_navigation.currentMountOMC.jumpTime = ml_global_information.Now
                                    end
                                    return
                                 end
                              else
                                 -- OMC STARTING
                                 ml_navigation.currentMountOMC = {}
                                 ml_navigation.currentMountOMC.startSide = (ml_navigation.navconnection.sideB.walkable
                                         and math.distance3d(playerpos, ml_navigation.navconnection.sideA) >= math.distance3d(playerpos, ml_navigation.navconnection.sideB))
                                         and ml_navigation.navconnection.sideB
                                         or ml_navigation.navconnection.sideA
                                 ml_navigation.currentMountOMC.endSide = table.deepcompare(ml_navigation.currentMountOMC.startSide, ml_navigation.navconnection.sideB, true)
                                         and ml_navigation.navconnection.sideA
                                         or ml_navigation.navconnection.sideB
                                 ml_navigation.currentMountOMC.startPortal = ml_navigation.JackalPortal().pos

                                 ml_navigation.currentMountOMC.path = table.valid(ml_navigation.path) and table.deepcopy(ml_navigation.path[table.size(ml_navigation.path)], false)
                                 Player:Stop()
                                 d("[Navigation] - Jackal Portal OMC started")
                              end
                              return

                           elseif (ncsubtype == 9) then
                              -- RAPTOR JUMP
                              ml_navigation.staymounted = true -- prevent unnecessary dismounting

                              local function resetRaptorOMC()
                                 local continueNode = ml_navigation.path[ml_navigation.pathindex + 2]
                                 local navConId = continueNode.navconnectionid
                                 -- Continue path available
                                 if (navConId ~= 0 and (NavigationManager:GetNavConnection(navConId).details or {}).subtype == 9) then
                                    -- We will have right after a springer jump OMC again so we stay mounted on springer
                                    ml_navigation.PauseMountUsage(ml_navigation.gw2mount.raptor.GRACETIME)
                                 end
                                 -- Interrupt jump
                                 KeyUp(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                 ml_navigation.currentMountOMC.stop_mount_energy = ml_navigation.currentMountOMC.stop_mount_energy or ml_navigation.mount_energy
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                 Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                 ml_navigation.pathindex = ml_navigation.pathindex + 1
                                 NavigationManager.NavPathNode = ml_navigation.pathindex
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 ml_navigation.navconnection = nil
                                 d("[Navigation] - Raptor Jump OMC done")
                                 return
                              end

                              -- Make sure this is setup
                              if (Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key = 0x56 -- V
                              end
                              if (Settings.GW2Minion[ml_navigation.acc_name].stepBackwards == nil) then
                                 Settings.GW2Minion[ml_navigation.acc_name].stepBackwards = 0x53 -- S
                              end

                              -- We got into combat so we abort the OMC
                              if (not ml_navigation.mounted and Player.inCombat and ml_navigation.navconnection) then
                                 ml_navigation.currentMountOMC = nil
                                 allowMount = false
                                 local target = gw2_common_functions.AggroTargetAtPos(nextnode, 1200)
                                 if target then
                                    ml_navigation.fight_aggro = {
                                       target_id = target.id,
                                       pos = { x = nextnode.x, y = nextnode.y, z = nextnode.z, },
                                       id = ml_navigation.navconnection.id,
                                    }
                                 else
                                    ml_navigation.fight_aggro = false
                                 end

                                 Player:StopMovement()
                                 d("[Navigation] - Reset OMC due of being in combat.")
                                 return
                              else
                                 ml_navigation.fight_aggro = false
                              end

                              local skill = ml_navigation.skills[19]
                              -- Low level character without mount skill slot
                              if (not skill) then
                                 DisableNavConnection(ml_navigation.navconnection, nil)
                                 NavigationManager:ResetPath()
                                 ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
                                 resetRaptorOMC()
                                 d("[Navigation] - Raptor Jump OMC disabled. You don't have skill slot 19")
                                 return
                              end

                              -- OMC handling
                              if (table.valid(ml_navigation.currentMountOMC)) then
                                 -- OMC RUNNING

                                 -- Variable definitions
                                 local startPos = ml_navigation.currentMountOMC.startSide
                                 local endPos = ml_navigation.currentMountOMC.endSide
                                 local angleToEndPos = gw2_common_functions.angle2DToTargetInDeg(playerpos, { x = playerpos.hx, y = playerpos.hy }, endPos)
                                 local drifting = (HackManager:GetDriftDirection() or { x = 0 }).x ~= 0

                                 -- OMC end reached or we failed to jump
                                 if (ml_navigation.currentMountOMC.jumpTime and TimeSince(ml_navigation.currentMountOMC.jumpTime) > 1000 and not drifting) then
                                    -- Interrupt jump
                                    KeyUp(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                    Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                    if (not ml_navigation.currentMountOMC.syncPos) then
                                       if (movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
                                          ml_navigation.currentMountOMC.syncPos = ml_global_information.Now
                                       end
                                    elseif (TimeSince(ml_navigation.currentMountOMC.syncPos) < ml_navigation.gw2mount.raptor.SYNCTIME) then
                                       -- Sync camera TODO: make this one day better...
                                       PressKey(Settings.GW2Minion[ml_navigation.acc_name].stepBackwards)
                                    else
                                       resetRaptorOMC()
                                    end
                                    return

                                 elseif (math.distance3d(ml_global_information.Player_Position, endPos) < math.distance3d(ml_global_information.Player_Position, startPos) and math.distance3d(ml_global_information.Player_Position, endPos) < 350) then
                                    resetRaptorOMC()
                                    return
                                 end

                                 -- SetFacingExact to have a smoother start and fast a correct direction, due to it being not 100% reliable we only try to use it once
                                 if (not ml_navigation.currentMountOMC.facingSet and not ml_navigation.currentMountOMC.jumpTime) then
                                    Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward)
                                    gw2_unstuck.SoftReset()
                                    Player:SetFacingExact(endPos.x, endPos.y, endPos.z, true)
                                    ml_navigation.currentMountOMC.facingSet = ml_global_information.Now
                                    --SetFacing has a "casttime" while beeing mounted, so we wait a bit
                                    if (ml_navigation.mounted and ml_navigation.lastupdate) then
                                       ml_navigation.lastupdate = ml_navigation.lastupdate + 1000 / 180 * angleToEndPos
                                    end
                                    return
                                 end

                                 -- Mount raptor and save last mount to swap back later
                                 if (ml_navigation.currentMountOMC.mountTime and TimeSince(ml_navigation.currentMountOMC.mountTime) < 1000) then
                                    return
                                 elseif (ml_navigation.mounted and ml_navigation.skills[5].skillid ~= ml_navigation.gw2mount.raptor.SKILLID) then
                                    Player:Dismount()
                                    return
                                 elseif (not ml_navigation.mounted and ml_navigation.skills[19].skillid == ml_navigation.gw2mount.raptor.ID and Player.canmount) then
                                    if (movementstate == GW2.MOVEMENTSTATE.GroundNotMoving) then
                                       Player:Mount()
                                       ml_navigation.currentMountOMC.mountTime = ml_global_information.Now
                                    end
                                    return
                                 elseif (not ml_navigation.mounted and Player.canmount and not ml_navigation.lastMountOMCID) then
                                    ml_navigation.lastMountOMCID = ml_navigation.skills[19].skillid
                                    Player:SelectMount(ml_navigation.gw2mount.raptor.ID)
                                    return
                                 elseif (not ml_navigation.mounted) then
                                    return
                                 end

                                 -- face + jump
                                 if (not ml_navigation.currentMountOMC.jumpTime) then
                                    -- Do facing
                                    if (angleToEndPos > 10) then
                                       if (not ml_navigation.currentMountOMC.faceTime) then
                                          Player:SetMovement(gw2_common_functions.getTurnDirection(endPos))
                                          ml_navigation.currentMountOMC.faceTime = ml_global_information.Now
                                       end
                                       return
                                    else
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnLeft)
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.TurnRight)
                                    end
                                    -- Do jump
                                    KeyDown(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                    ml_navigation.currentMountOMC.start_mount_energy = ml_navigation.mount_energy
                                    Player:SetFacingExact(endPos.x, endPos.y, endPos.z)
                                    ml_navigation.currentMountOMC.jumpTime = ml_global_information.Now
                                    return
                                 end

                                 -- Charge + in air phase
                                 if (ml_navigation.currentMountOMC.jumpTime) then
                                    gw2_unstuck.SoftReset()
                                    -- Interrupt Jump
                                    if (math.distance2d(playerpos, startPos) > math.distance2d(endPos, startPos) - endPos.radius * 32 - 500) and TimeSince(ml_navigation.currentMountOMC.jumpTime) > 150 then
                                       KeyUp(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                       ml_navigation.currentMountOMC.stop_mount_energy = ml_navigation.currentMountOMC.stop_mount_energy or ml_navigation.mount_energy
                                    end
                                    -- prevent boosting over the endpoint
                                    if (math.distance2d(playerpos, startPos) > math.distance2d(endPos, startPos) - endPos.radius * 32) then
                                       Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
                                    else
                                       Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
                                       if (movementstate == GW2.MOVEMENTSTATE.Jumping
                                               or movementstate == GW2.MOVEMENTSTATE.Falling) then
                                          Player:SetFacingExact(endPos.x, endPos.y, endPos.z)
                                       end
                                    end

                                    if ml_navigation.currentMountOMC.stop_mount_energy and ml_navigation.currentMountOMC.stop_mount_energy >= ml_navigation.currentMountOMC.start_mount_energy and TimeSince(ml_navigation.currentMountOMC.jumpTime) > 50 and math.distance2d(playerpos, startPos) < math.distance2d(playerpos, endPos) then
                                       d("[Navigation] - Mount Energy still is above or equals our starting energy of " .. tostring(ml_navigation.currentMountOMC.start_mount_energy) .. ". Mount Energy at: " .. tostring(ml_navigation.currentMountOMC.stop_mount_energy))
                                       resetRaptorOMC()
                                    end
                                    return
                                 end
                              else
                                 -- OMC STARTING
                                 ml_navigation.currentMountOMC = {}
                                 ml_navigation.currentMountOMC.startSide = (ml_navigation.navconnection.sideB.walkable
                                         and math.distance3d(playerpos, ml_navigation.navconnection.sideA) >= math.distance3d(playerpos, ml_navigation.navconnection.sideB))
                                         and ml_navigation.navconnection.sideB
                                         or ml_navigation.navconnection.sideA
                                 ml_navigation.currentMountOMC.endSide = table.deepcompare(ml_navigation.currentMountOMC.startSide, ml_navigation.navconnection.sideB, true)
                                         and ml_navigation.navconnection.sideA
                                         or ml_navigation.navconnection.sideB
                                 ml_navigation.currentMountOMC.effectiveDistance = math.distance2d(playerpos, ml_navigation.currentMountOMC.endSide)

                                 ml_navigation.currentMountOMC.path = table.valid(ml_navigation.path) and table.deepcopy(ml_navigation.path[table.size(ml_navigation.path)], false)
                                 Player:Stop()
                                 d("[Navigation] - Raptor Jump OMC started")
                              end

                              return

                           end


                           -- Macromesh node
                        elseif (ml_navigation.navconnection.type == 5) then
                           -- we should not be here in the first place..c++ should have replaced any macromesh node with walkable paths. But since this is on a lot faster timer than the main bot pulse, it can happen that 4-5 pathnodes are "reached" and then a macronode appears.
                           d("[Navigation] - Reached a Macromesh node... waiting for a path update...")
                           Player:Stop()
                           return

                        else
                           d("[Navigation] - OMC BUT UNKNOWN TYPE !? WE SHOULD NOT BE HERE!!!")
                        end

                     else

                        --- Check if the Camera is bugged and we are mounted, includes a check for Manual Camera Rotation with Mouse Left & Right; if stuck do not allow to mount
                        if not ml_navigation.navconnection and ml_navigation.CameraStuck(playerpos) then
                           ml_navigation.camera_stuck = ml_navigation.camera_stuck or ml_global_information.Now

                           if TimeSince(ml_navigation.camera_stuck) > 1000 then
                              d("[Navigation] - Camera stuck? Dismounting and resetting movement to unstuck.")
                              Player:Dismount()
                              Player:StopMovement()
                              ml_navigation.camera_stuck = false
                              allowMount = false
                           end
                        else
                           ml_navigation.camera_stuck = false
                        end

                        --- Check for Obstacles in front of us, jump over it or dismount; if so do not allow to mount
                        if not ml_navigation.navconnection and movementstate == GW2.MOVEMENTSTATE.GroundMoving and check_obstacle then
                           local hit1 = ml_navigation.ObstacleCheck(200, 6)
                           local hit2, gap = ml_navigation.ObstacleCheck(50, 6, true, 15)
                           if hit1 or hit2 then
                              if ml_navigation.mounted then
                                 if not ml_navigation.obstacles.dismount then
                                    d("[Navigation]: Something is blocking our path. Dismounting.")
                                 end

                                 if hit2 then
                                    Player:StopMovement()
                                 end

                                 ml_navigation.obstacles.dismount = true
                                 allowMount = false
                                 Player:Dismount()
                              elseif gap and gap > 7 and ml_navigation:DistanceToNextNavConnection() > 250 and Player:IsMoving() and ml_navigation:GetRemainingPathLenght() >= 150 then
                                 d("[Navigation]: Something is blocking our path, but we should be able to jump over it. Jumping.")
                                 Player:Jump()
                                 ml_navigation.PauseMountUsage(500)
                              end
                           end
                        end

                        if not ml_navigation.mounted and ml_navigation.obstacles.dismount then
                           ml_navigation.PauseMountUsage(1250)
                           ml_navigation.obstacles = {
                              left = {},
                              right = {},
                           }
                        end

                        if not ml_navigation.navconnection and smooth_dismount and (not next_mount or next_mount.distance > smooth_dismount.distance) and smooth_dismount.distance < ml_navigation.smooth_dismounts[smooth_dismount.subtype] then
                           allowMount = false
                           ml_navigation.PauseMountUsage(2500)

                           if ml_navigation.mounted then
                              d("[Navigation] - We have a non mount OMC next. To have a smoother handling for that we dismount already.")
                              Player:Dismount()
                           end
                        end

                        if TimeSince(ml_navigation.lastMount) > ml_navigation.thresholds.mount and Settings.GW2Minion[ml_navigation.acc_name].usemount and allowMount and not ml_navigation.currentMountOMC then
                           local remainingPathLenght = ml_navigation:GetRemainingPathLenght()

                           --- Checks if one of the next 20 nodes is a mount OMC, if it is and its nearer then the 'premount distance' for that mount we switch over to that mount
                           if next_mount and next_mount.pre_mount then
                              can_switch_mount = false
                              if ml_navigation.current_Mount.skill and (next_mount.mount.ID ~= ml_navigation.current_Mount.skill.id) then
                                 allowMount = false

                                 if ml_navigation.mounted and not ml_global_information.Player_InCombat then
                                    local _, aggro_nearby = next(CharacterList("nearest,Hostile,aggro,maxdistance=900"))
                                    local enemies_nearby = CharacterList("Hostile,maxdistance=750")
                                    if not aggro_nearby and table.size(enemies_nearby) <= 1 then
                                       d("[Navigation] - We will need " .. tostring(next_mount.mount.NAME) .. " in " .. tostring(next_mount.distance) .. " units. Dismounting to swap to it already.")
                                       Player:Dismount()
                                       ml_navigation.PauseMountUsage(250)
                                    end

                                 elseif not ml_navigation.mounted then
                                    d("[Navigation] - We will need " .. tostring(next_mount.mount.NAME) .. " in " .. tostring(next_mount.distance) .. " units. Selecting mount already.")
                                    Player:SelectMount(next_mount.mount.ID)
                                    ml_navigation.PauseMountUsage(250)
                                 elseif next_mount.distance < next_mount.mount.MOUNT_SWITCH_DISTANCE then
                                    d("[Navigation] - Dismounting for a smoother start of the next " .. tostring(next_mount.mount.NAME) .. " OMC in " .. tostring(next_mount.distance) .. " units.")
                                    Player:SelectMount(next_mount.mount.ID)
                                    Player:Dismount()
                                    ml_navigation.PauseMountUsage(250)
                                 end
                              end
                           end

                           --- Checking for the correct mount if we don't use a specific one for the current or upcoming OMCs
                           if (not next_mount or (not next_mount.pre_mount and next_mount.distance > 1800)) then
                              if TimeSince(ml_navigation.ticks.favorite_mount) > ml_navigation.thresholds.favorite_mount then
                                 ml_navigation.ticks.favorite_mount = ml_global_information.Now

                                 if (not ml_navigation.currentMountOMC or not table.valid(ml_navigation.currentMountOMC)) and not ml_global_information.Player_InCombat then
                                    local _, aggro_nearby = next(CharacterList("nearest,Hostile,aggro,maxdistance=900"))
                                    local enemies_nearby = CharacterList("Hostile,maxdistance=750")

                                    if Settings.GW2Minion[ml_navigation.acc_name].favorite_mount > 1 and not aggro_nearby and table.size(enemies_nearby) <= 1 then
                                       if ml_navigation.skills.favorite_mount then
                                          if ml_navigation.mounted then
                                             local c = ml_navigation.current_Mount.skill
                                             if (not ml_navigation.skills[5] or (ml_navigation.skills[5].id ~= ml_navigation.gw2mount[mount].SKILLID and (not ml_navigation.gw2mount[mount].SKILLID_MASTERED or ml_navigation.skills[5].id ~= ml_navigation.gw2mount[mount].SKILLID_MASTERED))) and (not ml_navigation.skills[19] or (ml_navigation.skills[19].id ~= ml_navigation.gw2mount[mount].ID)) then
                                                if not ml_navigation.inWvW then
                                                   d("[Navigation] - We are currently mounted on " .. ((c and c.name and (c.name and (c.name ~= "" and ("our " .. c.name)) or ((c.name_fallback and "our " .. c.name_fallback) or " a wrong mount"))) or " a wrong mount") .. ". Swapping to our favorite mount: " .. (ml_navigation.skills.favorite_mount.name ~= "" and ml_navigation.skills.favorite_mount.name or mount))
                                                else
                                                   d("[Navigation] - We are currently mounted on " .. ((c and c.name and (c.name and (c.name ~= "" and ("our " .. c.name)) or ((c.name_fallback and "our " .. c.name_fallback) or " a wrong mount"))) or " a wrong mount") .. ". Swapping to : " .. (ml_navigation.skills.favorite_mount.name ~= "" and ml_navigation.skills.favorite_mount.name or mount))
                                                end
                                                Player:Dismount()
                                             end
                                          end

                                          if not ml_navigation.mounted and (not ml_navigation.skills[19] or (ml_navigation.skills[19].id ~= ml_navigation.gw2mount[mount].ID)) then
                                             if not ml_navigation.inWvW then
                                                d("[Navigation] - Selecting our favorite mount: " .. (ml_navigation.skills.favorite_mount.name ~= "" and ml_navigation.skills.favorite_mount.name or mount))
                                             else
                                                d("[Navigation] - Selecting : " .. (ml_navigation.skills.favorite_mount.name ~= "" and ml_navigation.skills.favorite_mount.name or mount))
                                             end
                                             Player:SelectMount(ml_navigation.gw2mount[mount].ID)
                                          end
                                       end
                                    end
                                 end
                              end
                           end

                           --- Check if we are close to the path end, if so we dismount earlier
                           if ml_navigation.current_Mount.info and remainingPathLenght <= ml_navigation.current_Mount.info.DISMOUNT_DISTANCE then
                              if (ml_navigation.mounted and ml_navigation.staymounted == false) then
                                 d("[Navigation] - Reaching the path end in " .. math.round(remainingPathLenght) .. " units. Dismounting already to smooth it and not overshoot.")
                                 Player:Dismount()
                                 allowMount = false
                                 ml_navigation.PauseMountUsage(2500)
                              end
                           end

                           --- Only use leaps if we are allowed to, set by Player:MoveTo(); default = true
                           if ml_navigation.use_leaps then
                              ml_navigation.UseMountLeap(allowMount)
                           end

                           -- TODO: check if water surface node, dont try to mount if so.
                           if not ml_navigation.mounted and Player.canmount then
                              if (remainingPathLenght ~= 0 and remainingPathLenght > ((ml_navigation.current_Mount.info and ml_navigation.current_Mount.info.DISMOUNT_DISTANCE * 2.5) or 1200)) then
                                 local distanceToNextNode = math.distance3d(playerpos, { x = nextnode.x, y = nextnode.y, z = nextnode.z, })

                                 if (lastnode and lastnode.navconnectionid ~= 0 and nextnode and nextnode.navconnectionid ~= 0) then
                                    allowMount = false
                                 end
                                 if (not next_mount or not next_mount.pre_mount) and (ml_navigation:DistanceToNextNavConnection() < 1000) then
                                    allowMount = false
                                 end

                                 if (allowMount) then
                                    local anglediffPlayerNextNode = math.angle({ x = playerpos.hx, y = playerpos.hy, z = 0 }, { x = nextnode.x - playerpos.x, y = nextnode.y - playerpos.y, z = 0, })
                                    local anglediffNextNodeNextNextNode = nextnextnode and math.angle({ x = nextnode.x - playerpos.x, y = nextnode.y - playerpos.y, z = 0 }, { x = nextnextnode.x - nextnode.x, y = nextnextnode.y - nextnode.y, z = 0, }) or 0

                                    if (distanceToNextNode >= 500) then
                                       if (anglediffPlayerNextNode < 30) and not ml_navigation.navconnection then
                                          gw2_common_functions.NecroLeaveDeathshroud()

                                          Player:Mount()
                                       end

                                    else
                                       if (anglediffPlayerNextNode < 30 and anglediffNextNodeNextNextNode < 45) and not ml_navigation.navconnection then
                                          gw2_common_functions.NecroLeaveDeathshroud()
                                          Player:Mount()
                                       end
                                    end
                                 end
                              end
                           end
                        end
                     end

                     --- Move to next node in our path
                     if (ml_navigation:NextNodeReached(playerpos, nextnode, nextnextnode)) then
                        ml_navigation.pathindex = ml_navigation.pathindex + 1
                        NavigationManager.NavPathNode = ml_navigation.pathindex
                     else
                        -- Dismount when we are close to our target position, so we can get to the actual point and not overshooting it or similiar unprecise stuff
                        -- if (pathsize - ml_navigation.pathindex < 5 and ml_navigation.mounted and ml_navigation.staymounted == false)then
                        if (ml_navigation.mounted and ml_navigation.staymounted == false) then
                           local remainingPathLenght = ml_navigation:GetRemainingPathLenght()
                           if (remainingPathLenght ~= 0 and remainingPathLenght < 400) then
                              Player:Dismount()
                           end
                        end
                        ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode)
                     end
                     return
                  else
                     d("[Navigation] - Path end reached.")
                     if (ml_navigation.mounted and ml_navigation.staymounted == false) then
                        Player:Dismount()
                     end
                     Player:StopMovement()
                     gw2_unstuck.Reset()
                  end
               end
            end

            -- stoopid case catch
            if (ml_navigation.navconnection) then
               if GetGameState() == GW2.GAMESTATE.CINEMATIC then
                  d("[Navigation] - Running cutscene. Stop Player Movement.")
               else

                  ml_error("[Navigation] - Breaking out of not handled NavConnection.")
               end
               Player:StopMovement()
            end
         end
      end
   end
end
RegisterEventHandler("Gameloop.Draw", ml_navigation.Navigate, "ml_navigation.Navigate") -- TODO: navigate on draw loop?

-- Checks if the next node in our path was reached, takes differen movements into account ( swimming, walking, riding etc. )
function ml_navigation:NextNodeReached(playerpos, nextnode, nextnextnode)

   -- take into account navconnection radius, to randomize the movement on places where precision is not needed
   local navcon = nil
   local navconradius = 0
   if (nextnode.navconnectionid and nextnode.navconnectionid ~= 0) then
      navcon = NavigationManager:GetNavConnection(nextnode.navconnectionid)
      if (navcon) then
         if (nextnode.navconnectionsideA == true) then
            navconradius = navcon.sideA.radius -- meshspace to gamespace is *32 in GW2
         else
            navconradius = navcon.sideB.radius -- meshspace to gamespace is *32 in GW2
         end
      end
   end

   if (Player.swimming ~= GW2.SWIMSTATE.Diving) then
      local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
      -- local nodedist = math.distance3d(playerpos,nextnode)
      local movementstate = Player.movementstate
      local nodeReachedDistance = (movementstate == GW2.MOVEMENTSTATE.Jumping or movementstate == GW2.MOVEMENTSTATE.Falling) and ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()] * 2 or ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()]
      if ((nodedist - navconradius * 32) < nodeReachedDistance) then
         -- d("[Navigation] - Node reached. ("..tostring(math.round(nodedist - navconradius*32,2)).." < "..tostring(ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()])..")")
         -- We arrived at a NavConnection Node

         --self:CallCustomLuaNavConnectionsAhead(5) TEST THIS FIRST

         if (navcon) then
            d("[Navigation] -  Arrived at NavConnection ID: " .. tostring(nextnode.navconnectionid))
            ml_navigation:ResetOMCHandler()
            gw2_unstuck.SoftReset()
            ml_navigation.navconnection = navcon
            if (not ml_navigation.navconnection) then
               ml_error("[Navigation] -  No NavConnection Data found for ID: " .. tostring(nextnode.navconnectionid))
               return false
            end
            if (navconradius > 0 and navconradius < 1.0) then
               -- kinda shitfix for the conversion of the old OMCs to the new NavCons, I set all precise connections to have a radius of 0.5
               ml_navigation:SetEnsureStartPosition(nextnode, nextnextnode, playerpos, ml_navigation.navconnection)
            end
            -- Add for now a timer to cancel the shit after 10 seconds if something really went crazy wrong
            ml_navigation.navconnection_start_tmr = ml_global_information.Now

         else
            if (ml_navigation.navconnection) then
               gw2_unstuck.Reset()
            end
            ml_navigation.navconnection = nil
            return true
         end

      else
         -- Still walking towards the nextnode...
         --d("nodedist  - navconradius "..tostring(nodedist).. " - " ..tostring(navconradius))

      end

   else
      -- Handle underwater movement
      -- Check if the next Cubenode is reached:
      local dist3D = math.distance3d(nextnode, playerpos)
      if ((dist3D - navconradius * 32) < ml_navigation.NavPointReachedDistances["Diving"]) then
         -- We reached the node
         -- d("[Navigation] - Cube Node reached. ("..tostring(math.round(dist3D - navconradius*32,2)).." < "..tostring(ml_navigation.NavPointReachedDistances["Diving"])..")")
         ml_navigation.omc_track = ml_navigation.omc_track or {}
         -- We arrived at a NavConnection Node
         if (navcon) and (not ml_navigation.omc_track[nextnode.navconnectionid] or TimeSince(ml_navigation.omc_track[nextnode.navconnectionid]) > 2500) then
            ml_navigation.omc_track[nextnode.navconnectionid] = ml_navigation.omc_track[nextnode.navconnectionid] or ml_global_information.Now

            d("[Navigation] -  Arrived at NavConnection ID: " .. tostring(nextnode.navconnectionid))
            ml_navigation:ResetOMCHandler()
            gw2_unstuck.SoftReset()
            ml_navigation.navconnection = navcon
            if (not ml_navigation.navconnection) then
               ml_error("[Navigation] -  No NavConnection Data found for ID: " .. tostring(nextnode.navconnectionid))
               return false
            end
            if (navconradius > 0 and navconradius < 1.0) then
               -- kinda shitfix for the conversion of the old OMCs to the new NavCons, I set all precise connections to have a radius of 0.5
               ml_navigation:SetEnsureStartPosition(nextnode, nextnextnode, playerpos, ml_navigation.navconnection)
            end
         elseif (navcon) then
            return true
         else
            if (ml_navigation.navconnection) then
               gw2_unstuck.Reset()
            end
            ml_navigation.navconnection = nil
            return true
         end
      end
   end
   return false
end

function ml_navigation:MoveToNextNode(playerpos, lastnode, nextnode, overridefacing)
   self.turningOnMount = nil
   -- Only check unstuck when we are not handling a navconnection
   if (ml_navigation.navconnection or (not ml_navigation.navconnection and not gw2_unstuck.HandleStuck())) then

      if (Player.swimming ~= GW2.SWIMSTATE.Diving) then
         -- We have not yet reached our next node
         if (not overridefacing) then
            local anglediff = math.angle({ x = playerpos.hx, y = playerpos.hy, z = 0 }, { x = nextnode.x - playerpos.x, y = nextnode.y - playerpos.y, z = 0 })
            local nodedist = ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode)
            if not ml_navigation.mounted and (ml_navigation.smoothturns and anglediff < 75 and nodedist > 2 * ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()]) then
               Player:SetFacing(nextnode.x, nextnode.y, nextnode.z)
            else
               local ncsubtype = ml_navigation.navconnection and ml_navigation.navconnection.details and ml_navigation.navconnection.details.subtype
               if not ml_global_information.Player_InCombat or not ncsubtype or (ncsubtype ~= 7 and ncsubtype ~= 8 and ncsubtype ~= 9) then
                  if not ml_navigation.mounted then
                     Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                     ml_navigation.lastturn = ml_global_information.Now
                  elseif not ml_navigation.lastturn or anglediff > 10 and TimeSince(ml_navigation.lastturn) > 300 then
                     Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
                     ml_navigation.lastturn = ml_global_information.Now
                  end
               end
            end
         end

         -- Make sure we are not strafing away (happens sometimes after being dead + movement was set)
         local movdirs = Player:GetMovement()
         if (movdirs.backward) then
            Player:UnSetMovement(1)
         end
         if (movdirs.left) then
            Player:UnSetMovement(2)
         end
         if (movdirs.right) then
            Player:UnSetMovement(3)
         end

         if (Player.mounted) then
            -- Calc heading difference between player and next node
            local ppos = Player.pos
            local radianA = math.atan2(ppos.hx, ppos.hy)
            local radianB = math.atan2(nextnode.x - ppos.x, nextnode.y - ppos.y)
            local twoPi = 2 * math.pi
            local diff = (radianB - radianA) % twoPi
            local s = diff < 0 and -1.0 or 1.0
            local res = diff * s < math.pi and diff or (diff - s * twoPi)

            if (res > 0.75 or res < -0.75) then
               self.turningOnMount = true
               local mountSpeed = HackManager:GetSpeed()
               if (mountSpeed > 450) then
                  Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
               elseif (mountSpeed > 400) then
                  Player:UnSetMovement(GW2.MOVEMENTTYPE.Forward) -- stopping forward movement until we are facing the node
                  Player:UnSetMovement(GW2.MOVEMENTTYPE.Backward)
               elseif (mountSpeed > 350) then
                  Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
               end
               --d("TURNING : "..tostring(res))
               gw2_unstuck.stucktick = ml_global_information.Now + 500 -- the unstuck kicks in too often when we are still turning on our sluggish slow mount...
            else
               Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
               self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[ml_navigation.GetMovementType()])
            end
         else
            local ncsubtype = ml_navigation.navconnection and ml_navigation.navconnection.details and ml_navigation.navconnection.details.subtype
            if not ncsubtype or (ncsubtype ~= 7 and ncsubtype ~= 8 and ncsubtype ~= 9) or (ml_navigation:GetRaycast_Player_Node_Distance(playerpos, nextnode) > ml_navigation.NavPointReachedDistances["Walk"]) then
               Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
               self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances[ml_navigation.GetMovementType()])
            end
         end

      else
         -- Handle underwater movement

         -- We have not yet reached our node
         local dist2D = math.distance2d(nextnode, playerpos)
         if (dist2D < ml_navigation.NavPointReachedDistances["Diving"]) then
            -- We are on the correct horizontal position, but our goal is now either above or below us
            -- compensate for the fact that the char is always swimming on the surface between 0 - 50 @height
            local pHeight = playerpos.z
            if (nextnode.z < 20) then
               pHeight = nextnode.z
            end -- if the node is in shallow water (<50) , fix the playerheight at this pos. Else it gets super wonky at this point.
            local distH = math.abs(math.abs(pHeight) - math.abs(nextnode.z))

            if (distH > ml_navigation.NavPointReachedDistances["Diving"]) then
               -- Move Up / Down only until we reached the node
               Player:StopHorizontalMovement()
               if (pHeight > nextnode.z) then
                  -- minus is "up" in gw2
                  Player:SetMovement(GW2.MOVEMENTTYPE.SwimUp)
               else
                  Player:SetMovement(GW2.MOVEMENTTYPE.SwimDown)
               end

            else
               -- We have a good "height" position already, let's move a bit more towards the node on the horizontal plane
               Player:StopVerticalMovement()
               if (not overridefacing) then
                  Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
               end
               Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
            end

         else
            Player:StopVerticalMovement()
            if (not overridefacing) then
               Player:SetFacingExact(nextnode.x, nextnode.y, nextnode.z, true)
            end
            Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
         end
         self:IsStillOnPath(playerpos, lastnode, nextnode, ml_navigation.PathDeviationDistances["Diving"])

      end

   else
      --d("[ml_navigation:MoveToNextNode] - Unstuck ...")
   end
   return false
end
--[[  UNTESTED AND NEEDS MOST LIKELY FIXING
function ml_navigation:CallCustomLuaNavConnectionsAhead(maxAheadCount)
	local pathsize = table.size(ml_navigation.path)
	local pstartindex = ml_navigation.pathindex
	local pindex = ml_navigation.pathindex
	if ( pathsize > 0 ) then
		while ( pindex < pathsize and pindex < (pstartindex + maxAheadCount)) do
			local lastnode = ml_navigation.path[ pindex ]	-- OMC start
			local nextnode = ml_navigation.path[ ml_navigation.pathindex + 1]	-- OMC end

			if( nextnode.navconnectionid and nextnode.navconnectionid ~= 0) then
				local navcon = NavigationManager:GetNavConnection(nextnode.navconnectionid)
				if ( navcon and navcon.type == 4 and navcon.details and navcon.details.subtype == 6) then -- Custom OMC / -- Custom Lua Code

					if ( navcon.details.luacode and navcon.details.luacode and navcon.details.luacode ~= "" ) then
						local execstring = 'return function(self,startnode,endnode) '..navcon.details.luacode..' end'
						local func = loadstring(execstring)
						if ( func ) then
							func()(ml_navigation.navconnection, lastnode, nextnode)
						else
							ml_error("[Navigation] - A 'Custom Lua Code' NavConnection ahead in the path has a BUG !")
							assert(loadstring(execstring)) -- print out the actual error
						end
					else
						d("[Navigation] - ERROR: A 'Custom Lua Code' NavConnection ahead in the path has NO lua code!...")
					end
				end
			end
			pindex = pindex + 1
		end
	end
end]]

function ml_navigation:GetRemainingPathLenght()
   local pathLength = 0
   local pathNodeCount = #self.path
   local lastNodePosition = Player.pos

   if (self.pathindex < pathNodeCount) then
      for pathNodeID = self.pathindex + 1, pathNodeCount do
         local pathNode = self.path[pathNodeID]
         pathLength = pathLength + math.distance3d(lastNodePosition, pathNode)
         lastNodePosition = pathNode
      end

   else
      if (self.pathindex == pathNodeCount) and self.path[pathNodeCount] and lastNodePosition then
         pathLength = math.distance3d(lastNodePosition, self.path[pathNodeCount])
      end
   end

   return pathLength
end

function ml_navigation:DistanceToNextNavConnection()
   local pathLength = 0
   local pathNodeCount = #self.path
   local lastNodePosition = Player.pos

   if (self.pathindex < pathNodeCount) then
      for pathNodeID = self.pathindex + 1, pathNodeCount do
         local pathNode = self.path[pathNodeID]
         pathLength = pathLength + math.distance3d(lastNodePosition, pathNode)
         lastNodePosition = pathNode
         if (pathNode.navconnectionid ~= 0) then
            return pathLength
         end
      end
   end

   return 999999
end


-- Calculates the Point-Line-Distance between the PlayerPosition and the last and the next PathNode. If it is larger than the treshold, it returns false, we left our path.
function ml_navigation:IsStillOnPath(ppos, lastnode, nextnode, deviationthreshold)
   if (lastnode) then
      -- Dont use this when we crossed / crossing a navcon
      if (lastnode.navconnectionid == 0) then

         local movstate = Player:GetMovementState()
         if (Player.swimming ~= GW2.SWIMSTATE.Diving2) then
            -- Ignoring up vector, since recast's string pulling ignores that as well
            local from = { x = lastnode.x, y = lastnode.y, z = 0 }
            local to = { x = nextnode.x, y = nextnode.y, z = 0 }
            local playerpos = { x = ppos.x, y = ppos.y, z = 0 }
            if (movstate ~= GW2.MOVEMENTSTATE.Jumping and movstate ~= GW2.MOVEMENTSTATE.Falling and math.distancepointline(from, to, playerpos) > deviationthreshold) then
               d("[Navigation] - Player left the path - 2D-Distance to Path: " .. tostring(math.distancepointline(from, to, playerpos)) .. " > " .. tostring(deviationthreshold))
               --NavigationManager:UpdatePathStart()  -- this seems to cause some weird twitching loops sometimes..not sure why
               NavigationManager:ResetPath()
               ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
               return false
            end

         else
            -- Under water, using 3D
            if (movstate ~= GW2.MOVEMENTSTATE.Jumping and movstate ~= GW2.MOVEMENTSTATE.Falling and math.distancepointline(lastnode, nextnode, ppos) > deviationthreshold) then
               d("[Navigation] - Player not on Path anymore. - Distance to Path: " .. tostring(math.distancepointline(lastnode, nextnode, ppos)) .. " > " .. tostring(deviationthreshold))
               --NavigationManager:UpdatePathStart()
               NavigationManager:ResetPath()
               ml_navigation:MoveTo(ml_navigation.targetposition.x, ml_navigation.targetposition.y, ml_navigation.targetposition.z, ml_navigation.targetid)
               return false
            end
         end
      end
   end
   return true
end

-- Tries to use RayCast to determine the exact floor height from Player and Node, and uses that to calculate the correct distance.
function ml_navigation:GetRaycast_Player_Node_Distance(ppos, node)
   -- Raycast from "top to bottom" @PlayerPos and @NodePos
   local P_hit, P_hitx, P_hity, P_hitz = RayCast(ppos.x, ppos.y, ppos.z - 120, ppos.x, ppos.y, ppos.z + 250)
   local N_hit, N_hitx, N_hity, N_hitz = RayCast(node.x - 25, node.y - 25, node.z - 120, node.x, node.y, node.z + 250)
   local dist = math.distance3d(ppos, node)

   -- To prevent spinny dancing when we are unable to reach the 3D targetposition due to whatever reason , a little safety check here
   if (not self.lastpathnode or self.lastpathnode.x ~= node.x or self.lastpathnode.y ~= node.y or self.lastpathnode.z ~= node.z) then
      self.lastpathnode = node
      self.lastpathnodedist = nil
      self.lastpathnodecloser = 0
      self.lastpathnodefar = 0
   else

      if (Player:IsMoving() and Player.swimming ~= GW2.SWIMSTATE.Diving and not Player.mounted) then
         -- we are still moving towards the same node
         local dist2d = math.distance2d(ppos, node)
         if (dist2d < 5 * ml_navigation.NavPointReachedDistances[ml_navigation.GetMovementType()]) then
            -- count / record if we are getting closer to it or if we are spinning around
            if (self.lastpathnodedist) then
               if (dist2d <= self.lastpathnodedist) then
                  self.lastpathnodecloser = self.lastpathnodecloser + 1
               else
                  if (self.lastpathnodecloser > 1) then
                     -- start counting after we actually started moving closer, else turns or at start of moving fucks the logic
                     self.lastpathnodefar = self.lastpathnodefar + 1
                  end
               end
            end
            self.lastpathnodedist = dist2d
         end

         if (self.lastpathnodefar > 3) then
            d("[Navigation] - Loop detected, going back and forth too often - reset navigation.. " .. tostring(dist2d) .. " ---- " .. tostring(self.lastpathnodefar))
            ml_navigation.forcereset = true
            return 0 -- should make the calling logic "arrive" at the node
         end
      end
   end

   if (P_hit and N_hit) then
      local raydist = math.distance3d(P_hitx, P_hity, P_hitz, N_hitx, N_hity, N_hitz)
      if (raydist < dist) then
         -- d("return ray dist")
         return raydist
      end
   end
   -- d("return dist")
   return dist
end

-- Sets the position and heading which the main call will make sure that it has before continuing the movement. Used for NavConnections / OMC
function ml_navigation:SetEnsureStartPosition(currentnode, nextnode, playerpos, navconnection)
   Player:Stop()
   self.ensureposition = { x = currentnode.x, y = currentnode.y, z = currentnode.z }

   if (navconnection.details) then
      if (currentnode.navconnectionsideA == true) then
         self.ensureheading = { hx = navconnection.details.headingA_x, hy = navconnection.details.headingA_y, hz = navconnection.details.headingA_z }
      else
         self.ensureheading = { hx = navconnection.details.headingB_x, hy = navconnection.details.headingB_y, hz = navconnection.details.headingB_z }
      end
      self.ensureheadingtargetpos = nil

   else
      -- this still a thing ?
      -- TODO: Is this ever showing up? if so, then leave it. probs old nav crap
      ml_error("DO NOT REMOVE ME!!!")
      if (currentnode.navconnectionsideA == true) then
         self.ensureheadingtargetpos = { x = navconnection.sideA.x, y = navconnection.sideA.y, z = navconnection.sideA.z }
      else
         self.ensureheadingtargetpos = { x = navconnection.sideB.x, y = navconnection.sideB.y, z = navconnection.sideB.z }
      end
      self.ensureheading = nil
   end

   self:EnsurePosition(playerpos)
end
function ml_navigation:SetEnsureEndPosition(currentnode, nextnode, playerpos)
   Player:Stop()
   self.ensureposition = { x = currentnode.x, y = currentnode.y, z = currentnode.z }
   if (nextnode) then
      self.ensureheadingtargetpos = { x = nextnode.x, y = nextnode.y, z = nextnode.z }
   end
   self:EnsurePosition(playerpos)
end


-- Ensures that the player is really at a specific position, stopped and facing correctly. Used for NavConnections / OMC
function ml_navigation:EnsurePosition(playerpos)
   if (Player.mounted) then
      Player:Dismount()
      ml_navigation.PauseMountUsage(5000)
   end
   if (not self.ensurepositionstarttime) then
      self.ensurepositionstarttime = ml_global_information.Now
   end

   local dist = self:GetRaycast_Player_Node_Distance(playerpos, self.ensureposition)
   if (dist > 15) then
      HackManager:Teleport(self.ensureposition.x, self.ensureposition.y, self.ensureposition.z)
   end

   if ((ml_global_information.Now - self.ensurepositionstarttime) < 750 and ((self.ensureheading and Player:IsFacingH(self.ensureheading.hx, self.ensureheading.hy, self.ensureheading.hz) ~= 0) or (self.ensureheadingtargetpos and Player:IsFacing(self.ensureheadingtargetpos.x, self.ensureheadingtargetpos.y, self.ensureheadingtargetpos.z) ~= 0))) then

      if (Player:IsMoving()) then
         Player:Stop()
      end
      local dist = self:GetRaycast_Player_Node_Distance(playerpos, self.ensureposition)

      if (dist > 15) then
         HackManager:Teleport(self.ensureposition.x, self.ensureposition.y, self.ensureposition.z)
      end

      if (self.ensureheading) then
         Player:SetFacingH(self.ensureheading.hx, self.ensureheading.hy, self.ensureheading.hz)

      elseif (self.ensureheadingtargetpos) then
         Player:SetFacingExact(self.ensureheadingtargetpos.x, self.ensureheadingtargetpos.y, self.ensureheadingtargetpos.z, true)
      end

      return true

   else
      -- We waited long enough
      self.ensureposition = nil
      self.ensureheading = nil
      self.ensureheadingtargetpos = nil
      self.ensurepositionstarttime = nil
   end
   return false
end

-- lookahead, number of nodes to look ahead for an omc
-- returns true if there is an omc on our path
function ml_navigation:OMCOnPath(lookahead)
   lookahead = lookahead or 3

   local pathsize = table.size(ml_navigation.path)

   lookahead = lookahead > pathsize and pathsize or lookahead

   if (pathsize > 0) then
      for i = 1, lookahead do
         local node = ml_navigation.path[i]
         if (node.navconnectionid ~= 0) then
            return true
         end
      end
   end

   return false
end


-- param = {mindist, raycast, path, startpos}
-- mindist, minimum distance to get a position
-- raycast, set to false to disable los checks
-- path, provide an alternate path then the current navigation path
-- startpos, provide an alternate starting position. player position by default
-- returns a pos nearest to the minimum distance or nil
function ml_navigation:GetPointOnPath(param)
   local startpos = param.startpos ~= nil and param.startpos or ml_global_information.Player_Position

   local raycast = true
   if (param.raycast ~= nil) then
      raycast = param.raycast
   end

   local mindist = param.mindist ~= nil and param.mindist or 0
   local path = param.path ~= nil and param.path or ml_navigation.path
   local pathsize = table.size(path)
   local prevnode = Player.pos

   if (pathsize > 0 and mindist > 0) then
      local traversed
      for i = 1, pathsize do
         local node = path[i]
         local dist = math.distance3d(node, startpos)

         if (dist >= mindist) then
            local disttoprev = math.distance3d(prevnode, node)
            local newpos = {
               x = prevnode.x + (traversed / disttoprev) * (node.x - prevnode.x);
               y = prevnode.y + (traversed / disttoprev) * (node.y - prevnode.y);
               z = prevnode.z + (traversed / disttoprev) * (node.z - prevnode.z);
            }

            if (not raycast) then
               return newpos
            end

            local hit, hitx, hity, hitz = RayCast(startpos.x, startpos.y, startpos.z, newpos.x, newpos.y, newpos.z)
            if (not hit) then
               return newpos
            end
         end

         prevnode = node
         traversed = mindist - dist
      end
   end

   return nil
end

-- Get a node that is further away then min distance
function ml_navigation:GetNearestNodeToDistance(mindist, startpos)
   startpos = startpos or ml_global_information.Player_Position

   local pathsize = table.size(ml_navigation.path)

   if (pathsize > 0) then
      for i = 1, pathsize do
         local node = ml_navigation.path[i]
         local pos = { x = node.x, y = node.y, z = node.z }
         if (math.distance3d(startpos, pos) >= mindist) then
            return pos, i
         end
      end
   end

   return nil
end


-- Resets all OMC related variables
function ml_navigation:ResetOMCHandler()
   self.omc_id = nil
   self.omc_traveltimer = nil
   self.ensureposition = nil
   self.ensureheading = nil
   self.ensureheadingtargetpos = nil
   self.ensurepositionstarttime = nil
   self.omc_starttimer = 0
   self.omc_startheight = nil
   self.navconnection = nil
   self.turningOnMount = nil
end

-- Resets Path and Stops the Player Movement
function Player:StopMovement()
   ml_navigation.obstacles = {
      left = {},
      right = {},
   }
   ml_navigation.navconnection = nil
   ml_navigation.navconnection_start_tmr = nil
   ml_navigation.pathindex = 0
   ml_navigation.turningOnMount = nil
   ml_navigation.currentMountOMC = nil
   ml_navigation.lastMountOMC = nil
   ml_navigation.lastMountOMCID = nil
   ml_navigation:ResetCurrentPath()
   ml_navigation:ResetOMCHandler()
   gw2_unstuck.SoftReset()
   Player:Stop()
   NavigationManager:ResetPath()
   gw2_combat_movement:StopCombatMovement()
end

-- Takes {x,y,z} lua tables and checks if a jump would be not too high/far
function ml_navigation:ValidSpringerOMC(startPos, endPos)
   -- VARIABLES
   local lowerEndPos = endPos.z > startPos.z
   local zDistToTravel = lowerEndPos and -math.abs(endPos.z - startPos.z) or math.abs(endPos.z - startPos.z)
   local xyDistToTravel = math.distance2d(startPos, endPos)
   local totalDistToTravel = zDistToTravel - startPos.radius * 32 + xyDistToTravel * ml_navigation.gw2mount.springer.LOWBOOSTFACTOR - endPos.radius * 32 -- We always use lower boost factor for this validation
   local neededChargeTime = totalDistToTravel / ml_navigation.gw2mount.springer.GetMaxTravelHeight() * ml_navigation.gw2mount.springer.MAXLOADTIME

   if (not lowerEndPos and neededChargeTime > ml_navigation.gw2mount.springer.MAXLOADTIME) then
      return false
   end
   return true
end

-- Takes {x,y,z} lua tables and checks if a jump would be not too far
function ml_navigation:ValidRaptorOMC(startPos, endPos)
   -- VARIABLES
   local xyDistToTravel = math.distance2d(startPos, endPos)
   local zDistToTravel = -startPos.z + endPos.z -- negativ means we have to descend
   local jump_up = startPos.z > endPos.z

   if (zDistToTravel > 200) and jump_up then
      return false
   end -- too high endPos, might jump into edge/wall
   if (xyDistToTravel > ml_navigation.gw2mount.raptor.GetMaxTravelDistance()) then
      return false
   end
   return true
end

-- gets a jackal portal
function ml_navigation.JackalPortal()
   local portal, nearest = {}, 1000
   for k, v in pairs(GadgetList("contentid=17513,type=11,maxdistance=1000")) do
      if v.status == 3741829306 and v.type2 == 10 and v.distance < nearest then
         portal = v
         nearest = v.distance
      end
   end

   return portal
end

function ml_navigation.getCurrentMount(slot5, slot19)
   for mount_name, mount in pairs(ml_navigation.gw2mount) do
      if (slot5 and slot5 == mount.SKILLID) or (mount.SKILLID_MASTERED and slot5 and slot5 == mount.SKILLID_MASTERED) or (slot19 and slot19 == mount.ID) then
         local skill = Player:GetSpellInfoByID(mount.ID)
         if skill then
            skill.name_fallback = mount_name
         end

         return skill, mount
      end
   end
end

function ml_navigation.IsInWvW()
   local WvW_Maps = {
      [95] = "Alpine Borderlands",
      [96] = "Alpine Borderlands",
      [1099] = "Desert Borderlands",
      [38] = "Eternal Battlegrounds",
      [899] = "Obsidian Sanctum",
   }

   return WvW_Maps[ml_global_information.CurrentMapID]
end

function ml_navigation.ResetMountUsage()
   ml_navigation.ticks.favorite_mount = 0
   ml_navigation.lastMount = 0
end

function ml_navigation.PauseMountUsage(time)
   time = type(time) == "number" and time or 500
   ml_navigation.ticks.favorite_mount = ml_global_information.Now + time
   ml_navigation.lastMount = ml_global_information.Now + time
end

function ml_navigation.ObstacleCheck(input_distance, amount, front, front_amount)
   local hit = {
      left = 0,
      right = 0,
      frontal = 0,
   }
   local no_hit = {
      frontal = {},
   }
   local size = Player.height + 5
   local width = Player.radius + 2
   amount = amount == nil and 8 or amount
   front_amount = front_amount or 15
   local p = Player.pos
   local staymounted, ray_distance = true

   local nav_node = ml_navigation.path[ml_navigation.pathindex]
   if nav_node then
      local dis = math.distance3d(p, nav_node)
      local vec = {
         x = (nav_node.x - p.x) / dis,
         y = (nav_node.y - p.y) / dis,
         z = (nav_node.z - p.z) / dis
      }
      local vech = math.atan2(vec.y, vec.x)
      local vec_perp_L = {
         hx = -math.sin(vech),
         hy = math.cos(vech)
      }
      local vec_perp_R = {
         hx = math.sin(vech),
         hy = -math.cos(vech)
      }
      local distance = input_distance
      hit.frontal = 0
      no_hit.frontal = {}
      local ahead_loc = {
         x = p.x + (distance * vec.x),
         y = p.y + (distance * vec.y),
         z = p.z + (distance * vec.z)
      }

      local frontal = {
         x = p.x + ((distance + 25) * vec.x),
         y = p.y + ((distance + 25) * vec.y),
         z = p.z + ((distance + 25) * vec.z)
      }

      local frontal_dis = math.distance3d(p, frontal)
      if frontal_dis > dis then
         frontal = {
            x = p.x + ((dis + 25) * vec.x),
            y = p.y + ((dis + 25) * vec.y),
            z = p.z + ((dis + 25) * vec.z),
         }
      end

      --- RayCasts
      local Rays = {
         down = {},
         up = {},
         left = {},
         right = {},
         frontal = {}
      }

      Rays.down.hit, Rays.down.x, Rays.down.y, Rays.down.z = RayCast(ahead_loc.x, ahead_loc.y, ahead_loc.z - (size / 2), ahead_loc.x, ahead_loc.y, ahead_loc.z + (size / 2))
      if Rays.down.hit then
         local z = {
            feet = Rays.down.z - 25,
            head = Rays.down.z - size,
         }

         Rays.up.hit, Rays.up.x, Rays.up.y, Rays.up.z = RayCast(ahead_loc.x, ahead_loc.y, z.feet, ahead_loc.x, ahead_loc.y, z.head)

         local left = {
            x = ahead_loc.x + (width * 2 * vec_perp_L.hx),
            y = ahead_loc.y + (width * 2 * vec_perp_L.hy)
         }
         local right = {
            x = ahead_loc.x + (width * 2 * vec_perp_R.hx),
            y = ahead_loc.y + (width * 2 * vec_perp_R.hy)
         }

         if amount then
            local step = -(z.feet - z.head) / amount

            for height = z.feet, z.head, step do
               local l = {
                  ray = {},
                  start = {
                     x = ahead_loc.x,
                     y = ahead_loc.y,
                     z = height,
                  },
                  dest = {
                     x = left.x,
                     y = left.y,
                     z = height,
                  },
               }
               l.ray.hit, l.ray.x, l.ray.y, l.ray.z = RayCast(ahead_loc.x, ahead_loc.y, height, left.x, left.y, height)
               hit.left = hit.left + (l.ray.hit and 1 or 0)
               ray_distance = math.distance2d(l.ray, ahead_loc)
               if l.ray.hit and (not ml_navigation.obstacles.right[ml_global_information.Now] or ml_navigation.obstacles.right[ml_global_information.Now].distance > ray_distance) then
                  ml_navigation.obstacles.right[ml_global_information.Now] = { x = ahead_loc.x, y = ahead_loc.y, z = height, distance = ray_distance }
               end

               local r = {
                  ray = {},
                  start = {
                     x = ahead_loc.x,
                     y = ahead_loc.y,
                     z = height,
                  },
                  dest = {
                     x = right.x,
                     y = right.y,
                     z = height,
                  },
               }
               r.ray.hit, r.ray.x, r.ray.y, r.ray.z = RayCast(ahead_loc.x, ahead_loc.y, height, right.x, right.y, height)
               hit.right = hit.right + (r.ray.hit and 1 or 0)
               ray_distance = math.distance2d(r.ray, ahead_loc)
               if r.ray.hit and (not ml_navigation.obstacles.right[ml_global_information.Now] or ml_navigation.obstacles.right[ml_global_information.Now].distance > ray_distance) then
                  ml_navigation.obstacles.right[ml_global_information.Now] = { x = ahead_loc.x, y = ahead_loc.y, z = height, distance = ray_distance }
               end
            end
         end

         if front then
            local step = (z.head - z.feet) / front_amount
            local prev_f
            for height = z.feet, z.head, step do
               local f = {
                  ray = {},
               }
               f.ray.hit, f.ray.x, f.ray.y, f.ray.z = RayCast(ahead_loc.x, ahead_loc.y, height, frontal.x, frontal.y, height)
               if f.ray.hit then
                  if prev_f and prev_f.hit then
                     local lowerdist = math.distance2d(prev_f, ahead_loc)
                     local upperdist = math.distance2d(f.ray, ahead_loc)

                     local dist = upperdist - lowerdist
                     local slope = (prev_f.z - f.ray.z) / dist

                     if slope > 1.5 or slope < 0 then
                        hit.frontal = hit.frontal + (f.ray.hit and 1 or 0)
                        no_hit.frontal = {}
                     end
                  end
               else
                  table.insert(no_hit.frontal, math.abs(height) - math.abs(z.feet))
               end

               prev_f = f.ray
            end
         end
         if amount then
            if ml_navigation.obstacles.right[ml_global_information.Now] and ml_navigation.obstacles.left[ml_global_information.Now] then
               if math.distance2d(ml_navigation.obstacles.right[ml_global_information.Now], ml_navigation.obstacles.left[ml_global_information.Now]) > (width * 2) then
                  return true
               end
            end
         end
         if front and hit.frontal > 0 then
            return true, table.size(no_hit.frontal)
         end

         if amount then
            if table.valid(ml_navigation.obstacles.right) and table.valid(ml_navigation.obstacles.left) then
               for r_time, right in table.pairsbykeys(ml_navigation.obstacles.right) do
                  if TimeSince(r_time) < 2500 then
                     for l_time, left in table.pairsbykeys(ml_navigation.obstacles.left) do
                        if TimeSince(l_time) < 2500 then
                           if math.distance2d(left, right) < (width * 2) then
                              return true
                           end
                        else
                           ml_navigation.obstacles.left[l_time] = nil
                        end
                     end
                  else
                     ml_navigation.obstacles.left[r_time] = nil
                  end
               end
            end
         end
      end
   end
end

function ml_navigation.Sync(ms)
   if ms == 0 then
      if HackManager.Hover then
         d("[Navigation] - Hover hack is active. Disabling it.")
         HackManager.Hover = false
      end
   end

   ml_navigation.sync = true
end

function ml_navigation.CameraStuck(ppos, tolerance)
   tolerance = tolerance or 0.4625
   ppos = ppos or Player.pos

   if ml_global_information.Player_IsMounted and not GUI:IsMouseDown(0) and not GUI:IsMouseDown(1) then
      local eye = HackManager:GetCompassData().eye

      if eye and ppos then
         local cfacing = {
            x = -(eye.x - ppos.x),
            y = -(eye.y - ppos.y),
            z = 0
         }
         local pfacing = {
            x = ppos.hx,
            y = ppos.hy,
            z = 0
         }

         local pangle = math.atan2(pfacing.y, pfacing.x)
         local cangle = math.atan2(cfacing.y, cfacing.x)

         local difference = math.abs((cangle - pangle + 3 * math.pi) % (2 * math.pi) - math.pi)

         return (difference > tolerance), {
            difference = difference,
            cangle = cangle,
            pangle = pangle,
         }
      end
   end

   return false
end

function ml_navigation.isMoving(ms)
   if ms then
      return (ms == GW2.MOVEMENTSTATE.GroundMoving or ms == GW2.MOVEMENTSTATE.Falling or ms == GW2.MOVEMENTSTATE.Jumping or ms == GW2.MOVEMENTSTATE.BelowWaterMoving or ms == GW2.MOVEMENTSTATE.AboveWaterMoving)
   end
end

function ml_navigation.UseMountLeap(allowMount)
   if Settings.GW2Minion[ml_navigation.acc_name].usemountleaps then
      if ml_navigation.mount_leap then
         if not ml_navigation.mount_leap.started and allowMount then
            d("[Navigation] - Starting Raptor Leap.")
            KeyDown(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
            ml_navigation.mount_leap.started = true
         else
            if not allowMount or (TimeSince(ml_navigation.mount_leap.start) >= 2500 or ml_navigation.mount_energy <= ml_navigation.mount_leap.spent_energy) then
               if ml_navigation.mount_leap.started then
                  d("[Navigation] - Stopping Raptor Leap.")
                  KeyUp(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
               end

               ml_navigation.mount_leap = false
            end
         end
      end

      if allowMount and ml_navigation.current_Mount and ml_navigation.mounted and TimeSince(ml_navigation.ticks.mount_leap) > ml_navigation.thresholds.mount_leap then
         ml_navigation.ticks.mount_leap = ml_global_information.Now
         if ml_navigation.current_Mount.info and ml_navigation.current_Mount.info.NAME == "Jackal" then
            local prevnode = ml_navigation.pathindex > 1 and ml_navigation.path[ml_navigation.pathindex - 1] or nil
            local nnode = ml_navigation.path[ml_navigation.pathindex]
            if nnode and ml_navigation.mount_energy >= 33 and Player:IsMoving() then
               local nnode_adjust = 0
               if nnode and nnode.navconnectionid then
                  local omc = NavigationManager:GetNavConnection(nnode.navconnectionid)
                  if omc and omc.details and omc.details.subtype then
                     nnode_adjust = ml_navigation.smooth_dismounts[omc.details.subtype] or 400
                  end
               end
               local ppos = Player.pos
               local maxdist = 1000
               local pnndist = math.max(math.distance3d(ppos, nnode) - nnode_adjust, 0)

               if pnndist >= maxdist then
                  local eye = HackManager:GetCompassData().eye
                  if eye then
                     local cfacing = {
                        x = ppos.x - eye.x,
                        y = ppos.y - eye.y,
                        z = 0
                     }
                     local phead = math.atan2(cfacing.y,cfacing.x)
                     local phead = math.atan2(ppos.hy, ppos.hx)
                     local pnhead = math.atan2(nnode.y - ppos.y, nnode.x - ppos.x)
                     local tolerance = math.pi / 32
                     local correct_heading

                     if (not prevnode or not prevnode.navconnectionsideA) then
                        local difference = pnhead - phead
                        difference = (difference + 3 * math.pi) % (math.pi * 2) - math.pi
                        if difference < tolerance and difference > -tolerance then
                           correct_heading = true
                        end

                        if correct_heading and pnndist >= maxdist then
                           local heading = gw2_common_functions.normalize({ x = ppos.hx, y = ppos.hy })
                           local endpos = {
                              x = ppos.x + heading.x * maxdist,
                              y = ppos.y + heading.y * maxdist,
                              z = ppos.z
                           }
                           local Ray_zcheck = {}
                           Ray_zcheck.hit, Ray_zcheck.x, Ray_zcheck.y, Ray_zcheck.z = RayCast(endpos.x, endpos.y, endpos.z - 150, endpos.x, endpos.y, endpos.z + 100)
                           if Ray_zcheck.hit and NavigationManager:IsOnMesh(Ray_zcheck.x, Ray_zcheck.y, Ray_zcheck.z) or nnode.z < ppos.z then
                              local Ray_front = {}
                              Ray_front.hit, Ray_front.x, Ray_front.y, Ray_front.z = RayCast(ppos.x, ppos.y, ppos.z - 35, endpos.x, endpos.y, endpos.z - 35)
                              if not Ray_front.hit or nnode.z < ppos.z then
                                 d("[Navigation] - Using Jackal Leap.")
                                 PressKey(Settings.GW2Minion[ml_navigation.acc_name].mountAbility2Key)
                                 ml_navigation.ticks.mount_leap = ml_global_information.Now + 750
                              end
                           end
                        end
                     end
                  end
               end
            end
         end

         if ml_navigation.current_Mount.info and ml_navigation.current_Mount.info.NAME == "Raptor" then
            local prevnode = ml_navigation.pathindex > 1 and ml_navigation.path[ml_navigation.pathindex - 1] or nil
            local nnode = ml_navigation.path[ml_navigation.pathindex]
            local nnnode = ml_navigation.path[ml_navigation.pathindex + 1]
            if nnode and nnnode and ml_navigation.mount_energy >= 50 and Player:IsMoving() then
               local nnode_adjust = 0
               if nnode and nnode.navconnectionid then
                  local omc = NavigationManager:GetNavConnection(nnode.navconnectionid)
                  if omc and omc.details and omc.details.subtype then
                     nnode_adjust = ml_navigation.smooth_dismounts[omc.details.subtype] or 400
                  end
               end

               local ppos = Player.pos
               local pnndist = math.max(math.distance3d(ppos, nnode) - nnode_adjust, 0)
               local maxdist = ml_navigation.gw2mount.raptor.GetMaxTravelDistance()

               if pnndist >= maxdist / 2 then
                  local dist12 = math.distance3d(nnode, nnnode)
                  local phead = math.atan2(ppos.hy, ppos.hx)
                  local pnhead = math.atan2(nnode.y - ppos.y, nnode.x - ppos.x)
                  local nhead = math.atan2(nnnode.y - nnode.y, nnnode.x - nnode.x)
                  local tolerance = math.pi / 16
                  local pheight = Player.height
                  local correct_heading, distance_check, distance_check2, truncation, zcheck

                  if pnndist >= maxdist or (pnndist > 600 and pnndist + dist12 >= maxdist) and (not prevnode or not prevnode.navconnectionsideA) then
                     local difference = pnhead - phead
                     difference = (difference + 3 * math.pi) % (math.pi * 2) - math.pi
                     if difference < tolerance and difference > -tolerance then
                        correct_heading = true
                     end
                     if correct_heading and pnndist >= maxdist then
                        distance_check = true
                     elseif correct_heading and pnndist + dist12 >= maxdist and not nnode.navconnectionsideA then
                        local difference2 = nhead - pnhead
                        difference2 = (difference2 + 3 * math.pi) % (math.pi * 2) - math.pi
                        if difference2 < tolerance and difference > -tolerance then
                           distance_check2 = true
                        end
                     end
                  end
                  --truncation
                  if pnndist < maxdist and not distance_check and not distance_check2 and (not prevnode or not prevnode.navconnectionsideA) then
                     local difference = pnhead - phead
                     difference = (difference + 3 * math.pi) % (math.pi * 2) - math.pi
                     if difference < tolerance and difference > -tolerance then
                        truncation = true
                     end
                  end
                  --zpos check
                  local RC = {}
                  if truncation or distance_check or distance_check2 then
                     local zmax = 125
                     local zmin = -75
                     if truncation then
                        local zdiff = nnode.z - ppos.z
                        if zdiff > zmin and zdiff < zmax then
                           zcheck = true
                        end
                     end
                     if distance_check then
                        local magnitude = math.distance2d(nnode.x, nnode.y, ppos.x, ppos.y)
                        local x = ppos.x + (maxdist * (nnode.x - ppos.x) / magnitude)
                        local y = ppos.y + (maxdist * (nnode.y - ppos.y) / magnitude)
                        RC.hit, RC.x, RC.y, RC.z = RayCast(x, y, ppos.z - zmax, x, y, ppos.z - zmin)
                        if RC.hit then
                           zcheck = true
                        end
                     end
                     if distance_check2 then
                        local zdiff = nnode.z - ppos.z
                        if zdiff < zmax then
                           local magnitude = math.distance2d(nnode.x, nnode.y, nnnode.x, nnnode.y)
                           local remainder = math.distance2d(nnode.x, nnode.y, ppos.x, ppos.y)
                           local x = nnode.x + ((maxdist - remainder) * (nnnode.x - nnode.x) / magnitude)
                           local y = nnode.y + ((maxdist - remainder) * (nnnode.y - nnode.y) / magnitude)
                           RC.hit, RC.x, RC.y, RC.z = RayCast(x, y, ppos.z - zmax, x, y, ppos.z - zmin)
                           if RC.hit then
                              zcheck = true
                           end
                        end
                     end
                  end

                  --so we wanna leap, zcheck passed and distance check passed
                  if zcheck then
                     if truncation or distance_check then
                        local center = pnndist / 2
                        local zheight = 165
                        local heading = { x = nnode.x - ppos.x, y = nnode.y - ppos.y, z = nnode.z - ppos.z }
                        heading = gw2_common_functions.normalize(heading)
                        local point = (truncation == true and nnode) or (distance_check == true and RC)
                        local RC1_top, RC1_bot, RC2_top, RC2_bot = {}, {}, {}, {}
                        local toppos = { x = ppos.x + (heading.x * center), y = ppos.y + (heading.y * center), z = ppos.z - zheight - pheight }
                        local botpos = { x = ppos.x + (heading.x * center), y = ppos.y + (heading.y * center), z = ppos.z - zheight }
                        RC1_top.hit, RC1_top.x, RC1_top.y, RC1_top.z = RayCast(ppos.x, ppos.y, ppos.z - pheight, toppos.x, toppos.y, toppos.z)
                        RC1_bot.hit, RC1_bot.x, RC1_bot.y, RC1_bot.z = RayCast(ppos.x, ppos.y, ppos.z - 10, botpos.x, botpos.y, botpos.z)
                        RC2_top.hit, RC2_top.x, RC2_top.y, RC2_top.z = RayCast(toppos.x, toppos.y, toppos.z, point.x, point.y, point.z - pheight)
                        RC2_bot.hit, RC2_bot.x, RC2_bot.y, RC2_bot.z = RayCast(botpos.x, botpos.y, botpos.z, point.x, point.y, point.z - 10)
                        if not RC1_top.hit and not RC1_bot.hit and not RC2_top.hit and not RC2_bot.hit then
                           if truncation then
                              local dist = math.distance3d(ppos, point)
                              local energy_needed = ((20) / (maxdist - (maxdist / 2))) * dist + 10
                              energy_needed = (energy_needed > 50 and 50) or energy_needed

                              ml_navigation.mount_leap = ml_navigation.mount_leap or {
                                 spent_energy = ml_navigation.mount_energy - energy_needed,
                                 start = ml_global_information.Now,
                              }

                              return pnndist
                           elseif distance_check then
                              local energy_needed = 50

                              ml_navigation.mount_leap = ml_navigation.mount_leap or {
                                 spent_energy = ml_navigation.mount_energy - energy_needed,
                                 start = ml_global_information.Now,
                              }

                              return maxdist
                           end
                        end
                     end
                  end
               end
            end
         end
      end
   end
end
