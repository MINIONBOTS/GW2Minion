local api_manager = {}
api_manager.path = GetLuaModsPath() .. "GW2Minion\\"
api_manager.icons_path = GetLuaModsPath() .. "GW2Minion\\Icons\\"
api_manager.data_path = GetLuaModsPath() .. "GW2Minion\\API_Data\\"
api_manager.categories = {
   ["skills"] = {
      data_path = api_manager.data_path .. "skills\\",
      icon_path = api_manager.icons_path .. "skills\\",
      default_iconpath = {
         "icon"
      },
      api_path = "/v2/skills",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["achievements"] = {
      data_path = api_manager.data_path .. "achievements\\",
      icon_path = false,
      api_path = "/v2/achievements",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["traits"] = {
      data_path = api_manager.data_path .. "traits\\",
      icon_path = api_manager.icons_path .. "traits\\",
      default_iconpath = {
         "icon",
      },
      api_path = "/v2/traits",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["specializations"] = {
      data_path = api_manager.data_path .. "specializations\\",
      icon_path = api_manager.icons_path .. "specializations\\",
      default_iconpath = {
         "profession_icon_big",
      },
      api_path = "/v2/specializations",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["professions"] = {
      data_path = api_manager.data_path .. "professions\\",
      icon_path = api_manager.icons_path .. "professions\\",
      default_iconpath = {
         "icon"
      },
      api_path = "/v2/professions",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["items"] = {
      data_path = api_manager.data_path .. "items\\",
      icon_path = api_manager.icons_path .. "items\\",
      default_iconpath = {
         "icon",
      },
      api_path = "/v2/items",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
         "getPrice",
         "getListings",
      },
   },
   ["currencies"] = {
      data_path = api_manager.data_path .. "currencies\\",
      icon_path = api_manager.icons_path .. "currencies\\",
      default_iconpath = {
         "icon"
      },
      api_path = "/v2/currencies",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["files"] = {
      data_path = api_manager.data_path .. "files\\",
      icon_path = api_manager.icons_path .. "files\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/files",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["pets"] = {
      data_path = api_manager.data_path .. "pets\\",
      icon_path = api_manager.icons_path .. "pets\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/pets",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["outfits"] = {
      data_path = api_manager.data_path .. "outfits\\",
      icon_path = api_manager.icons_path .. "outfits\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/outfits",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["novelties"] = {
      data_path = api_manager.data_path .. "novelties\\",
      icon_path = api_manager.icons_path .. "novelties\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/novelties",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["minis"] = {
      data_path = api_manager.data_path .. "minis\\",
      icon_path = api_manager.icons_path .. "minis\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/minis",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["mailcarriers"] = {
      data_path = api_manager.data_path .. "mailcarriers\\",
      icon_path = api_manager.icons_path .. "mailcarriers\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/mailcarriers",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["gliders"] = {
      data_path = api_manager.data_path .. "gliders\\",
      icon_path = api_manager.icons_path .. "gliders\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/gliders",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["finishers"] = {
      data_path = api_manager.data_path .. "finishers\\",
      icon_path = api_manager.icons_path .. "finishers\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/finishers",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["quaggans"] = {
      data_path = api_manager.data_path .. "quaggans\\",
      icon_path = api_manager.icons_path .. "quaggans\\",
      default_iconpath = {
         "icon"
      },
      api_path = "v2/quaggans",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["listings"] = {
      data_path = api_manager.data_path .. "commerce\\",
      icon_path = false,
      api_path = "/v2/commerce/listings",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = 600,
      all_data = {
         "getInfo",
         "getIcon",
         "getPrice",
         "getListings",
      },
   },
   ["prices"] = {
      data_path = api_manager.data_path .. "commerce\\",
      icon_path = false,
      api_path = "/v2/commerce/prices",
      host = "api.guildwars2.com",
      name_key = false,
      valid_duration = 600,
      all_data = {
         "getInfo",
         "getIcon",
         "getPrice",
         "getListings",
      },
   },
   ["masteries"] = {
      data_path = api_manager.data_path .. "masteries\\",
      icon_path = api_manager.icons_path .. "masteries\\",
      default_iconpath = {
         "background"
      },
      api_path = "/v2/masteries",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["skins"] = {
      data_path = api_manager.data_path .. "skins\\",
      icon_path = api_manager.icons_path .. "items\\",
      default_iconpath = {
         "icon"
      },
      api_path = "/v2/skins",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
         "getIcon",
      },
   },
   ["itemstats"] = {
      data_path = api_manager.data_path .. "itemstats\\",
      icon_path = false,
      api_path = "/v2/itemstats",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["materials"] = {
      data_path = api_manager.data_path .. "materials\\",
      icon_path = false,
      api_path = "/v2/materials",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["titles"] = {
      data_path = api_manager.data_path .. "titles\\",
      icon_path = false,
      api_path = "/v2/titles",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["stories"] = {
      data_path = api_manager.data_path .. "stories\\",
      icon_path = false,
      api_path = "/v2/stories",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["recipes"] = {
      data_path = api_manager.data_path .. "recipes\\",
      icon_path = false,
      api_path = "/v2/recipes",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["raids"] = {
      data_path = api_manager.data_path .. "raids\\",
      icon_path = false,
      api_path = "/v2/raids",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["races"] = {
      data_path = api_manager.data_path .. "races\\",
      icon_path = false,
      api_path = "/v2/races",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["quests"] = {
      data_path = api_manager.data_path .. "quests\\",
      icon_path = false,
      api_path = "/v2/quests",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["mounts"] = {
      data_path = api_manager.data_path .. "mounts\\",
      icon_path = false,
      api_path = "/v2/mounts/types",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["maps"] = {
      data_path = api_manager.data_path .. "maps\\",
      icon_path = false,
      api_path = "/v2/maps",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["continents"] = {
      data_path = api_manager.data_path .. "continents\\",
      icon_path = false,
      api_path = "/v2/continents",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["legends"] = {
      data_path = api_manager.data_path .. "legends\\",
      icon_path = false,
      api_path = "/v2/legends",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["colors"] = {
      data_path = api_manager.data_path .. "colors\\",
      icon_path = false,
      api_path = "/v2/colors",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["dungeons"] = {
      data_path = api_manager.data_path .. "dungeons\\",
      icon_path = false,
      api_path = "/v2/dungeons",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["emotes"] = {
      data_path = api_manager.data_path .. "emotes\\",
      icon_path = false,
      api_path = "/v2/emotes",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
   ["worlds"] = {
      data_path = api_manager.data_path .. "worlds\\",
      icon_path = false,
      api_path = "/v2/worlds",
      host = "api.guildwars2.com",
      name_key = true,
      valid_duration = false,
      all_data = {
         "getInfo",
      },
   },
}
api_manager.request_types = {
   ["prices"] = {
      limit = 200,
   },
   ["listings"] = {
      limit = 200,
   },
   ["data"] = {
      limit = 200,
   },
   ["icon"] = {
      limit = 200,
   },
}
api_manager.languages = {
   [0] = "en",
   [2] = "fr",
   [3] = "de",
   [4] = "es",
   [5] = "cn",
}
api_manager.language_dependent = {
   name = true,
   description = true,
   details = false,
   status = true,
   text = true,
   instruction = true,
   requirement = true,
   active = true,
   complete = true,
   bonuses = true,
}
api_manager.language = Player:GetLanguage()
api_manager.chinese = api_manager.language == 5
api_manager.API_Data = {}
api_manager.Icons = {}
---more can be found here: https://gist.github.com/itsmefox/d34ad5a0dd220ec58703486d4d87d7c1
api_manager.HTTP_Status = {
   ok = 200,
   partial_content = 206,
   exceeded_limit = 429,
   bad_request = 400, --e.g. using ids=all on items or passing more ids then the request limit allows (mostly 200)
   not_found = 404,
}
api_manager.queue_Status = {
   not_requested = 0,
   request_sent = 1,
   data_received = 3,
   download_queued = 4,
   downloading = 5,
}
api_manager.ticks = {
   global = 0,
   request = 0,
   icons = 0,
   cleanup = 0,
}
api_manager.thresholds = {
   global = 50,
   request = 666,
   icons = 50,
   cleanup = 500,
}
api_manager.blacklist = {}
api_manager.queue = {}
api_manager.Now = os.time()
api_manager.UI = {
   open = false,
   not_collapsed = false,
}
api_manager.version = 2.1
api_manager.game_version = GetGameVersion()

---create folders, load already gathered data files
function api_manager.ModuleInit()

   if not FolderExists(api_manager.categories["quaggans"].data_path) then
      ml_warning("[gw2_api_manager]: Resetting all api data and icons due to major rework! Sorry <3")
      FolderDelete(api_manager.data_path)
      FolderDelete(api_manager.icons_path)
   end

   Settings.api_manager.open = Settings.api_manager.open or false
   Settings.api_manager.not_collapsed = Settings.api_manager.not_collapsed or false

   if not FolderExists(api_manager.data_path) then
      FolderCreate(api_manager.data_path)
   end

   if not FolderExists(api_manager.icons_path) then
      FolderCreate(api_manager.icons_path)
   end

   if not FolderExists(api_manager.data_path .. "manual") then
      FolderCreate(api_manager.data_path .. "manual")
   end

   if not FolderExists(api_manager.icons_path .. "manual") then
      FolderCreate(api_manager.icons_path .. "manual")
   end

   for _, category in pairs(api_manager.categories) do
      if category.data_path and not FolderExists(category.data_path) then
         FolderCreate(category.data_path)
      end

      if category.icon_path and not FolderExists(category.icon_path) then
         FolderCreate(category.icon_path)
      end
   end

   api_manager.Load_Blacklist()
   api_manager.Load_API_Data()
end

---load already gathered data files
function api_manager.Load_API_Data()
   for _, foldername in pairs(FolderList(api_manager.path .. "API_Data", ".*", true)) do
      for _, file in pairs(FolderList(api_manager.path .. "API_Data\\" .. foldername, ".*.lua", false) or {}) do
         api_manager.API_Data[foldername] = api_manager.API_Data[foldername] or {}
         api_manager.API_Data[foldername][string.trim(file, 4)] = FileLoad(api_manager.path .. "API_Data\\" .. foldername .. "\\" .. file) or {}

         if not table.valid(api_manager.API_Data[foldername][string.trim(file, 4)]) then
            FileDelete(api_manager.path .. "API_Data\\" .. foldername .. "\\" .. file)
            api_manager.API_Data[foldername][string.trim(file, 4)] = {}
         end
      end
   end
end

---save already gathered data to lua files
function api_manager.Save_API_Data(category, ids)
   if not category then
      for category, v in pairs(api_manager.API_Data) do
         if api_manager.categories[category] then
            local path = api_manager.categories[category].data_path

            for k2, v2 in pairs(api_manager.API_Data[category]) do
               FileSave(path .. k2 .. ".lua", api_manager.API_Data[category][k2])
            end
         end
      end

   else
      if api_manager.categories[category] then
         local path = api_manager.categories[category].data_path

         if not ids then
            for k, v in pairs(api_manager.API_Data[category]) do
               FileSave(path .. k .. ".lua", api_manager.API_Data[category][k])
            end

         else
            local id_type = type(ids)
            ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false

            for _, id in pairs(ids or {}) do
               FileSave(path .. id .. ".lua", api_manager.API_Data[category][id])
            end
         end
      end
   end
end

---get passed time in seconds based on os.time() in form of api_manager.Now, we need to know if the data is from the same day or not
function api_manager.TimeSince(time)
   if time then
      return api_manager.Now - time
   end

   return 86400 ---return 24 h when no time is given, just lazy stuff so we can call it without checking the time
end

---check for name on those categories to know if we have to call the api again because the language info is missing
function api_manager.HasName(category)
   return api_manager.categories[category] and api_manager.categories[category].name_key or false
end

---custom console print to only spam the console when api_manager.Debug == true
function api_manager.d(txt)
   if Settings.api_manager.Debug then
      d("[gw2_api_manager]: " .. tostring(txt))
   end
end

---extracting the icon id out of the url of icons to get each icon only once not once for every item
function api_manager.createIconID(url)
   if url and (type(url) == "string" or type(url) == "number") then
      for txt in string.split(url, "/") do
         if string.contains(txt, ".png") then
            return string.trim(txt, 4)
         end
      end
   end
end

---extracting the right url based on a table of keys
function api_manager.geturl(tbl, keys, url)
   url = url or false
   if tbl and keys then
      if type(tbl) == "table" then
         for k, v in pairs(keys) do
            keys[k] = nil
            if tbl[v] then
               url = tbl[v]
               url = api_manager.geturl(tbl[v], keys, url)
            end
         end
      end
   end

   return url
end

---custom trim code to trim from left
function api_manager.ltrim(txt, num)
   txt = string.reverse(txt)
   txt = string.trim(txt, num)
   txt = string.reverse(txt)
   return txt
end

---custom code to replace simple % signs to not cause issues when beeing printed or used in GUI:Text() etc
function api_manager.prepare(txt)
   if type(txt) == "string" then
      txt = string.gsub(txt, "%%", "%%%1")
      return txt
   end

   return txt
end

---custom code to simply concatenate a tables value to a string
function api_manager.id_string(tbl)
   local tbl_type = type(tbl)
   tbl = (tbl_type == "table" and tbl) or ((tbl_type == "number" or tbl_type == "string") and { tbl }) or false
   if tbl then
      local txt
      for _, v in pairs(tbl) do
         local v_type = type(v)
         if v_type == "string" or v_type == "number" then
            txt = (txt and txt .. "," .. v) or v
         end
      end
      return txt
   end
end

---adding a request to the queue
function api_manager.add(ids, category, request_type, url, custom_id, custom_key)
   local id_type = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false

   if ids and category and api_manager.categories[category] and request_type and api_manager.request_types[request_type] then
      for _, id in pairs(ids) do
         if not api_manager.is_Blacklisted(id, category) then
            api_manager.queue[id .. " - " .. category .. " - " .. request_type] = api_manager.queue[id .. " - " .. category .. " - " .. request_type] or {
               status = 0,
               start = ml_global_information.Now,
               requested = 0,
               category = category,
               request_type = request_type,
               key = id .. " - " .. category .. " - " .. request_type,
               id = id,
               tries = 0,
               url = url,
               custom_id = custom_id,
               custom_key = custom_key
            }
            api_manager.queue[id .. " - " .. category .. " - " .. request_type].url = url
         end
      end
   end
end

---returns the collected item/skill/currency/... info
---for easy use juse use:
---id = itemid / currency id / skillid or table of ids
---category = item/skill/currency/...
---all_data will force to return all language variants for the name, description, text ... ; default is false and returns only in Players language
---creates automatically a new request if the requested info is not available
function api_manager.getInfo(ids, category, all_data)
   all_data = type(all_data) == "boolean" and all_data or false

   local id_type, _ = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false
   local tbl, request_ids, invalid_ids = {}, {}, {}

   if ids and api_manager.categories[category] then
      local path = api_manager.categories[category].data_path

      for _, id in pairs(ids) do
         if (api_manager.API_Data[category] and api_manager.API_Data[category][id]) or FileExists(path .. id .. ".lua") then
            local info = api_manager.LoadData(category, id, request_ids, all_data)
            tbl[id] = info

            if (not tbl[id] or info.game_version ~= api_manager.game_version) and not api_manager.is_Blacklisted(id, category) then
               table.insert(request_ids, id)
               tbl[id] = nil
            end

         elseif not api_manager.is_Blacklisted(id, category) then
            table.insert(request_ids, id)

         else
            table.insert(invalid_ids, id)
         end
      end
   end

   if table.valid(request_ids) then
      api_manager.add(request_ids, category, "data")
   end

   if table.size(ids) == 1 then
      _, tbl = next(tbl)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

---returns the collected trading post prices
---id = itemid or table of ids
---all_data will force to return all language variants for the name, description, text ... ; default is false and returns only in Players language
---creates automatically a new request if the requested info is not available or older then 15 minutes
function api_manager.getPrice(ids, all_data, include_infos)
   local category = "prices"
   all_data = type(all_data) == "boolean" and all_data or false

   local id_type, _ = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false
   local tbl, request_ids, invalid_ids = {}, {}, {}

   if ids and api_manager.categories[category] then
      local path = api_manager.categories[category].data_path

      for _, id in pairs(ids) do
         if (api_manager.API_Data[category] and api_manager.API_Data[category][id]) or FileExists(path .. id .. ".lua") then
            local info = api_manager.LoadData(category, id, request_ids, all_data)
            local item_info = include_infos and api_manager.LoadData("items", id, request_ids, all_data)
            local valid_duration = api_manager.categories[category].valid_duration

            tbl[id] = item_info or info

            if info and item_info and api_manager.TimeSince(info.lastupdate) < valid_duration and info.game_version == api_manager.game_version then
               for k, v in pairs(info) do
                  if k == "buys" or k == "sells" then
                     if table.valid(v) and v[1] then
                        tbl[id][k] = tbl[id][k] or {}
                        tbl[id][k].quantity = v[1].quantity or 0
                        tbl[id][k].unit_price = v[1].unit_price or 0

                     elseif table.valid(v) then
                        tbl[id][k] = v

                     else
                        tbl[id][k] = {
                           quantity = 0,
                           unit_price = 0,
                        }
                     end
                  else
                     tbl[id][k] = v
                  end
               end

            elseif (not info or (info.game_version ~= api_manager.game_version or api_manager.TimeSince(info.lastupdate) >= valid_duration)) then
               if not api_manager.is_Blacklisted(id, category) then
                  table.insert(request_ids, id)
               else
                  table.insert(invalid_ids, id)
               end

               tbl[id] = nil
            end

         elseif not api_manager.is_Blacklisted(id, category) then
            table.insert(request_ids, id)

         else
            table.insert(invalid_ids, id)
         end
      end
   end

   if table.valid(request_ids) then
      api_manager.add(request_ids, category, "prices")
   end

   if table.size(ids) == 1 then
      _, tbl = next(tbl)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

---returns the collected trading post prices
---id = itemid or table of ids
---all_data will force to return all language variants for the name, description, text ... ; default is false and returns only in Players language
---creates automatically a new request if the requested info is not available or older then 15 minutes
function api_manager.getListings(ids, all_data)
   local category = "listings"
   all_data = type(all_data) == "boolean" and all_data or false

   local id_type, _ = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false
   local tbl, request_ids, invalid_ids = {}, {}, {}

   if ids and api_manager.categories[category] then
      local path = api_manager.categories[category].data_path

      for _, id in pairs(ids) do
         if (api_manager.API_Data[category] and api_manager.API_Data[category][id]) or FileExists(path .. id .. ".lua") then
            local info = api_manager.LoadData(category, id, request_ids, all_data)
            local item_info = api_manager.LoadData("items", id, request_ids, all_data)
            local valid_duration = api_manager.categories[category].valid_duration

            tbl[id] = item_info or info

            if info and item_info and info.listings and api_manager.TimeSince(info.listings) < valid_duration and info.game_version == api_manager.game_version then
               for k, v in pairs(info) do
                  tbl[id][k] = v
               end

            elseif (not info or not info.listings or (info.game_version ~= api_manager.game_version or api_manager.TimeSince(info.listings) >= valid_duration)) then
               if not api_manager.is_Blacklisted(id, category) then
                  table.insert(request_ids, id)
               else
                  table.insert(invalid_ids, id)
               end

               tbl[id] = nil
            end

         elseif not api_manager.is_Blacklisted(id, category) then
            table.insert(request_ids, id)

         else
            table.insert(invalid_ids, id)
         end
      end
   end

   if table.valid(request_ids) then
      api_manager.add(request_ids, category, "listings")
   end

   if table.size(ids) == 1 then
      _, tbl = next(tbl)
   end

   return (table.valid(tbl) and tbl) or false, (table.valid(request_ids) and request_ids) or false, (table.valid(invalid_ids) and invalid_ids) or false
end

---returns the collected item/skill/currency/... icon for the passed id & category;
---for easy use juse use:
---id = itemid / currency id / skillid
---category = item/skill/currency/...
---creates automatically a new request if the requested icon is not available to get it and returns either the fallback_icon or GetStartupPath().."\\GUI\\UI_Textures\\change.png" to have a placeholder and not mess up the UI
---custom_key allows you to select a different id, default is "icon" but there might be reasons to get "profession_icon_big" or "profession_icon"
function api_manager.getIcon(ids, category, fallback_icon, custom_key, check)
   local key_type, _ = type(custom_key)
   custom_key = (key_type == "table" and table.deepcopy(custom_key)) or ((key_type == "number" or key_type == "string") and { custom_key }) or (api_manager.categories[category] and api_manager.categories[category].default_iconpath and table.deepcopy(api_manager.categories[category].default_iconpath))

   local id_type, _ = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false
   local tbl = {}

   if api_manager.categories[category] and api_manager.categories[category].icon_path then
      for _, id in pairs(ids) do
         local info = api_manager.getInfo(id, category)
         local path = api_manager.categories[category].icon_path
         local url = info and api_manager.geturl(info, table.deepcopy(custom_key))

         if url then
            local skin_id = api_manager.createIconID(url)

            if skin_id then
               api_manager.Icons[category] = api_manager.Icons[category] or {}

               ---caching the path so we only have to check for the file once every 5 seconds. This would only fuck up the UI for max 5 seconds if an icon got deleted.
               if (api_manager.Icons[category][skin_id] and (not check or TimeSince(api_manager.Icons[category][skin_id].checked) < 5000)) or FileExists(path .. skin_id .. ".png") then
                  tbl[id] = path .. skin_id .. ".png"
                  api_manager.Icons[category][skin_id] = api_manager.Icons[category][skin_id] or {}
                  api_manager.Icons[category][skin_id].path = api_manager.Icons[category][skin_id].path or path .. skin_id .. ".png"
                  api_manager.Icons[category][skin_id].checked = (api_manager.Icons[category][skin_id].checked and TimeSince(api_manager.Icons[category][skin_id].checked) < 5000 and api_manager.Icons[category][skin_id].checked) or ml_global_information.Now

               else
                  api_manager.add(id, category, "icon", url, skin_id, custom_key)
                  tbl[id] = fallback_icon or GetStartupPath() .. "\\GUI\\UI_Textures\\change.png"
               end
            else
               api_manager.add(id, category, "icon", url, skin_id, custom_key)
               tbl[id] = fallback_icon or GetStartupPath() .. "\\GUI\\UI_Textures\\change.png"
            end
         end
      end
   end

   if table.size(ids) == 1 then
      _, tbl = next(tbl)
   end

   return tbl or (fallback_icon or GetStartupPath() .. "\\GUI\\UI_Textures\\change.png")
end

---delete a entry from the queue
function api_manager.delete(key)
   api_manager.queue[key] = nil
end

---external call to update the api language
function api_manager.update_language()
   api_manager.language = Player:GetLanguage()
   api_manager.chinese = api_manager.language == 5
end

---add a custom http request to the queue, this should be used so that not multiple addons run api request and hit the limit that way
---delay allows to add a custom delay for especially big requests that take more time, default is 15 seconds
function api_manager.add_custom(key, params, delay)
   if key and table.valid(params) then
      local param_edited = table.deepcopy(params)
      if params.host ~= nil then
         if params.path ~= nil then
            if params.port ~= nil then
               if params.method ~= nil then
                  if params.onsuccess ~= nil then
                     if params.onfailure ~= nil then

                        local function success(str, header, statuscode)
                           api_manager.delete(key)
                           params.onsuccess(str, header, statuscode)
                        end
                        local function fail(str, header, statuscode)
                           api_manager.delete(key)
                           params.onfailure(str, header, statuscode)
                        end

                        param_edited.onsuccess = success
                        param_edited.onfailure = fail
                        api_manager.queue[key] = api_manager.queue[key] or {
                           category = "custom",
                           request_type = "custom",
                           params = param_edited,
                           key = key,
                           status = 0,
                           start = ml_global_information.Now,
                           requested = 0,
                           tries = 0,
                           delay = delay or 15000,
                        }
                        return true
                     end
                  end
               end
            end
         end
      end
   end
   return false
end

---this is a combined call to fetch all infos regarding a id & category available
---using this for items would call -> getInfo, getIcon, getListings
---allow_parts will return infos for items that are available, eventho a request had to be sent
---special case is icons, icons will always return the placeholder to allow its usage in your UI
function api_manager.get(ids, category, allow_parts, all_data)
   if api_manager.categories[category] and api_manager.categories[category].all_data then
      local data = {}
      local requested = {}
      local blacklisted = {}
      for _, v in pairs(api_manager.categories[category].all_data) do
         local key = string.lower(string.gsub(v, "get", ""))
         if v ~= "getPrice" and v ~= "getListings" and v ~= "getIcon" then
            local info, requests, blacklist = api_manager[v](ids, category, all_data)
            data[key] = info
            requested[key] = requests
            blacklisted[key] = blacklist

         elseif v == "getIcon" then
            local info, requests, blacklist = api_manager[v](ids, category, all_data)
            data[key] = info
            requested[key] = requests
            blacklisted[key] = blacklist

         else
            local info, requests, blacklist = api_manager[v](ids, all_data)
            data[key] = info
            requested[key] = requests
            blacklisted[key] = blacklist

         end
      end

      if not allow_parts then
         for key, data in pairs(requested) do
            if data then
               for _, id in pairs(data) do


               end
            end
         end
      end

      --- those tables are index by:
      --- .info - contains the return of getInfo
      --- .icon - contains the return of getIcon
      --- .price - contains the return of getPrice
      --- .listings - contains the return of getListings
      return data, requested, blacklisted
   end
end

---check the loaded items and the existing files to return api infos
---all_data == true/false forces to return the hole table for language dependent values, else it will return only a single value based on current language
function api_manager.LoadData(category, id, requested, all_data)
   local tbl = (api_manager.API_Data[category] and api_manager.API_Data[category][id] and table.deepcopy(api_manager.API_Data[category][id])) or (api_manager.categories[category] and FileLoad(api_manager.categories[category].data_path .. id .. ".lua"))
   if (not table.valid(tbl) or (api_manager.API_Data[category] and api_manager.API_Data[category][id] and (not api_manager.API_Data[category][id].gw2_api_manager_version or api_manager.API_Data[category][id].gw2_api_manager_version ~= api_manager.version))) and api_manager.categories[category] and FileExists(api_manager.categories[category].data_path .. id .. ".lua") then
      FileDelete(api_manager.categories[category].data_path .. id .. ".lua")
   elseif table.valid(tbl) then
      api_manager.API_Data[category] = api_manager.API_Data[category] or {}
      api_manager.API_Data[category][id] = tbl
   end

   tbl = table.valid(tbl) and tbl or false

   local language, error = api_manager.language

   if tbl and table.valid(tbl) and tbl.gw2_api_manager_version and tbl.gw2_api_manager_version == api_manager.version and tbl.game_version == api_manager.game_version then
      if not all_data then
         tbl = api_manager.Prepare_LoadData(tbl, language, nil, requested, id)
         if not tbl.name and api_manager.HasName(category) then
            tbl = nil
         end
      end

      if category == "items" and api_manager.chinese and (not api_manager.API_Data[category][id].name[5] or api_manager.API_Data[category][id].name[5] == "") then
         local _, item = next(Inventory("contentid=" .. id))
         if item then
            api_manager.API_Data[category][id].name[5] = item.name
            api_manager.Save_API_Data("items", id)
         end
      end

   else
      if tbl and ((not tbl.gw2_api_manager_version or tbl.gw2_api_manager_version ~= api_manager.version) or (tbl.game_version ~= api_manager.game_version)) then
         if FileExists(api_manager.categories[category].data_path .. id .. ".lua") then
            FileDelete(api_manager.categories[category].data_path .. id .. ".lua")
         end

         tbl = nil
      end

      error = "File contains not a valid table."
   end

   return tbl, error
end

---preparing the saving of api infos to make sure we save values that are language dependent and not overwrite existing values
function api_manager.Prepare_SaveData(tbl, language, target)
   language = language or api_manager.language
   target = target or {}

   if type(tbl) == "table" then
      for k, v in pairs(tbl) do
         if api_manager.language_dependent[k] then
            target[k] = target[k] or {}
            target[k][language] = v
            if language == 5 then
               target[k][0] = v
            end

         elseif type(v) == "table" then
            target[k] = target[k] or {}
            api_manager.Prepare_SaveData(v, language, target[k])

         else
            target[k] = v
         end
      end
   end

   return target
end

---preparing the loading of api infos to make sure we return only the language dependent value and not a table
function api_manager.Prepare_LoadData(tbl, language, target, requested, id)
   language = language or api_manager.language
   target = target or {}

   for k, v in pairs(tbl) do
      if api_manager.language_dependent[k] then
         target[k] = api_manager.prepare(v[language])

         if type(requested) == "table" and ((not v[language] and language ~= 5) or (not v[0] and api_manager.chinese)) and not table.contains(requested, id) then
            table.insert(requested, id)
         end

      elseif type(v) == "table" then
         target[k] = api_manager.Prepare_LoadData(v, language, target[k], requested, id)

      else
         target[k] = api_manager.prepare(v)
      end
   end

   return target
end

function api_manager.add_to_Blacklist(ids, category, reason)
   local id_type = type(ids)
   ids = (id_type == "table" and ids) or ((id_type == "number" or id_type == "string") and { ids }) or false

   for _, v in pairs(ids) do
      api_manager.blacklist[category] = api_manager.blacklist[category] or {}
      api_manager.blacklist[category][v] = api_manager.blacklist[category][v] or {}
      api_manager.blacklist[category][v].time = api_manager.Now
      api_manager.blacklist[category][v].reason = reason
      api_manager.blacklist[category][v].game_version = api_manager.game_version
      api_manager.blacklist[category][v].count = api_manager.blacklist[category][v].count and api_manager.blacklist[category][v].count + 1 or 1
   end

   api_manager.Save_Blacklist()
end

function api_manager.is_Blacklisted(id, category)
   if api_manager.blacklist[category] then
      if api_manager.blacklist[category][id] then
         if api_manager.API_Data[category] and api_manager.API_Data[category][id] then
            api_manager.blacklist[category][id] = nil
            api_manager.Save_Blacklist()
            return false

         elseif api_manager.game_version ~= api_manager.blacklist[category][id].game_version then
            return false

         elseif api_manager.game_version == api_manager.blacklist[category][id].game_version then
            if api_manager.blacklist[category][id].count >= 5 then
               return true
            end
         end
      end
   end

   return false
end

function api_manager.Save_Blacklist()
   FileSave(GetLuaModsPath() .. "GW2Minion\\API_Data\\blacklist.lua", api_manager.blacklist)
end

function api_manager.Load_Blacklist()
   local tbl = FileLoad(GetLuaModsPath() .. "GW2Minion\\API_Data\\blacklist.lua")
   if not table.valid(tbl) and FileExists(GetLuaModsPath() .. "GW2Minion\\API_Data\\blacklist.lua") then
      FileDelete(GetLuaModsPath() .. "GW2Minion\\API_Data\\blacklist.lua")
   end

   api_manager.blacklist = (table.valid(tbl) and tbl) or {}
end

function api_manager.RefreshQueue()
   api_manager.queue = api_manager.queue or {}
   local function sortbystart(op1, op2)
      return op1.start < op2.start
   end
   table.sort(api_manager.queue, sortbystart)

   for k, v in table.pairsByValueAttribute(api_manager.queue, "start") do
      if v.request_type ~= "icon" then
         return v.request_type, v.category, v
      end
   end
end

function api_manager.API_DataHandler()
   if not api_manager.menuadded then
      ml_gui.ui_mgr:AddMember(
              {
                 id = "GW2MINION##APIMGR",
                 name = "API Manager",
                 onClick = function()
                    Settings.api_manager.open = not Settings.api_manager.open
                 end,
                 tooltip = "Open API Manager Info window.",
                 texture = GetStartupPath() .. "\\GUI\\UI_Textures\\api.png"
              },
              "GW2MINION##MENU_HEADER"
      )
      api_manager.menuadded = true
   end

   if TimeSince(api_manager.ticks.global) > api_manager.thresholds.global then
      api_manager.language = Player:GetLanguage()
      api_manager.chinese = api_manager.language == 5
      api_manager.ticks.global = ml_global_information.Now
      api_manager.Now = os.time()
      local s = api_manager.queue_Status

      if TimeSince(api_manager.ticks.request) > api_manager.thresholds.request then
         api_manager.ticks.request = ml_global_information.Now

         ---clear the queue so we get rid of outdated requests etc
         local request_type, category, first = api_manager.RefreshQueue()

         if table.valid(api_manager.queue) and request_type and request_type ~= "icon" then
            if request_type ~= "custom" then

               local request_table = {
                  request_type = request_type,
                  category = category,
                  ids = {

                  },
               }

               for k, v in table.pairsByValueAttribute(api_manager.queue, "start") do
                  if v.request_type == request_type and v.category == category then
                     if (v.status == s.not_requested) or (v.status == s.request_sent and TimeSince(v.requested) > 15000) then

                        v.requested = ml_global_information.Now
                        v.status = s.request_sent
                        v.tries = v.tries + 1

                        table.insert(request_table.ids, v.id)
                     end
                  end

                  if table.size(request_table.ids) >= api_manager.request_types[request_type].limit then
                     break
                  end
               end

               if table.valid(request_table.ids) then
                  local function success(str, header, statuscode)
                     local data = json.decode(str)
                     if statuscode == api_manager.HTTP_Status.exceeded_limit then
                        ml_warning("[gw2_api_manager]: Exceeded the apis limit! Waiting another minute before allowing more api requests.")
                        api_manager.ticks.request = ml_global_information.Now + 60000
                     end

                     if statuscode == api_manager.HTTP_Status.ok or statuscode == api_manager.HTTP_Status.partial_content then
                        if data then
                           api_manager.d("Request Successful. Deleting queue entry.")
                           api_manager.d("HTTP Result Header: " .. header)
                           api_manager.d("HTTP Result StatusCode: " .. tostring(statuscode))

                           for k, v in pairs(request_table.ids) do
                              local found = false
                              for _, entry in pairs(data) do
                                 if entry.id == v then
                                    found = true
                                 end

                                 api_manager.API_Data[category] = api_manager.API_Data[category] or {}
                                 api_manager.API_Data[category][entry.id] = api_manager.Prepare_SaveData(entry, api_manager.language, api_manager.API_Data[category][entry.id])
                                 api_manager.API_Data[category][entry.id].listings = (request_type == "listings" and api_manager.Now) or api_manager.API_Data[category][entry.id].listings or false
                                 api_manager.API_Data[category][entry.id].lastupdate = api_manager.Now
                                 api_manager.API_Data[category][entry.id].gw2_api_manager_version = api_manager.version
                                 api_manager.API_Data[category][entry.id].game_version = api_manager.game_version
                              end

                              if found then
                                 api_manager.queue[v .. " - " .. category .. " - " .. request_type] = nil

                              else
                                 api_manager.d("Added " .. v .. " to blacklist")
                                 api_manager.add_to_Blacklist(v, category)
                                 api_manager.queue[v .. " - " .. category .. " - " .. request_type] = nil
                              end
                           end

                           api_manager.Save_API_Data(category, request_table.ids)
                        end

                     elseif statuscode == api_manager.HTTP_Status.not_found then
                        for k, v in pairs(request_table.ids) do
                           api_manager.d("Ids not found. Added " .. v .. " to blacklist")
                           api_manager.d("HTTP Result Header: " .. header)
                           api_manager.d("HTTP Result StatusCode: " .. tostring(statuscode))
                           api_manager.d(data or str)
                           api_manager.add_to_Blacklist(v, category)
                           api_manager.queue[v .. " - " .. category .. " - " .. request_type] = nil
                        end

                     else
                        api_manager.d(data or str)
                        api_manager.d("Request Successful. Deleting queue entry.")
                        api_manager.d("HTTP Result Header: " .. header)
                        api_manager.d("HTTP Result StatusCode: " .. tostring(statuscode))
                     end
                  end

                  local function failed(str, header, statuscode)
                     api_manager.d("HTTP Request failed. Adding another 3 seconds before we try to send a new one!")
                     api_manager.ticks.request = ml_global_information.Now + 3000
                     d("HTTP Failed Error: " .. str)
                     d("HTTP Failed Header: " .. header)
                     d("HTTP Failed StatusCode: " .. tostring(statuscode))
                  end

                  local params = {
                     host = api_manager.categories[category].host,
                     path = api_manager.categories[category].api_path .. "?ids=" .. api_manager.id_string(request_table.ids) .. "&lang=" .. api_manager.languages[api_manager.language],
                     port = 443,
                     method = "GET",
                     https = true,
                     onsuccess = success,
                     onfailure = failed,
                     body = "",
                     headers = "",
                     getheaders = true ---if true, headers will be returned
                  }

                  api_manager.d("Sending HttpRequest for: " .. category .. " at api path: " .. api_manager.categories[category].api_path .. " with ids: " .. api_manager.id_string(request_table.ids))
                  HttpRequest(params)
               end
            elseif first then
               local s = api_manager.queue_Status

               if (first.status == s.not_requested) or (first.status == s.request_sent and TimeSince(first.requested) > first.delay) then
                  first.requested = ml_global_information.Now
                  first.status = s.request_sent
                  first.tries = first.tries + 1
                  HttpRequest(first.params)

                  if first.tries >= 5 then
                     api_manager.queue[first.key] = nil
                  end
               end
            end
         end
      end

      if TimeSince(api_manager.ticks.icons) > api_manager.thresholds.icons then
         api_manager.ticks.icons = ml_global_information.Now

         if not api_manager.last_icon or FileExists(api_manager.last_icon.path) or TimeSince(api_manager.last_icon.time) > 250 then
            api_manager.last_icon = false

            for k, v in table.pairsByValueAttribute(api_manager.queue, "start") do
               if v.request_type == "icon" and v.category and api_manager.categories[v.category] then
                  local path = api_manager.categories[v.category].icon_path
                  local id = v.custom_id or v.id

                  if not v.url then
                     local info = api_manager.getInfo(v.id, v.category)

                     if table.valid(info) then
                        v.url = info and api_manager.geturl(info, table.deepcopy(v.custom_key))
                        if not v.url then
                           api_manager.queue[v.key] = nil
                        end
                     end
                  end

                  local skin_id = api_manager.createIconID(v.url)

                  if skin_id and FileExists(path .. skin_id .. ".png") or api_manager.is_Blacklisted(v.id, v.category) then
                     api_manager.queue[v.key] = nil

                     if FileExists(path .. skin_id .. ".png" .. "_tmp") then
                        FileDelete(path .. skin_id .. ".png" .. "_tmp")
                     end
                  else
                     if v.url and skin_id then
                        if (v.status == s.not_requested) or (v.status == s.request_sent and TimeSince(v.requested) > 5000) then
                           v.requested = ml_global_information.Now
                           v.status = s.request_sent
                           v.tries = v.tries + 1

                           api_manager.last_icon = {
                              path = path .. skin_id .. ".png",
                              time = ml_global_information.Now,
                           }
                           WebAPI:GetImage(id, v.url, path .. skin_id .. ".png")
                           break
                        end
                     end
                  end
               end
            end
         end
      end
   end
end

function api_manager.InfoUI()
   api_manager.Draw()
end

function api_manager.Draw()
   GUI:SetNextWindowSize(600, 900, GUI.SetCond_FirstUseEver)
   api_manager.UI.open = Settings.api_manager.open or false
   api_manager.UI.not_collapsed = Settings.api_manager.not_collapsed or false

   if api_manager.UI.open then
      api_manager.UI.not_collapsed, api_manager.UI.open = GUI:Begin("gw2_api_manager - Info##1", api_manager.UI.open)
      if api_manager.UI.not_collapsed then
         GUI:TextWrapped()
         Settings.api_manager.Debug = GUI:Checkbox("Show console debug", Settings.api_manager.Debug or false)
         local x, y = GUI:GetContentRegionAvail()
         if GUI:CollapsingHeader("Queued") then
            GUI:BeginChild("Queued", 0, y - 50, true)
            for k, v in table.pairsByValueAttribute(api_manager.queue, "start") do

               if GUI:ImageButton("del " .. v.key, GetStartupPath() .. "\\GUI\\UI_Textures\\w_delete.png", 13, 13) then
                  api_manager.blacklist[v.key] = nil
               end
               GUI:SameLine()

               if GUI:CollapsingHeader(v.key) then
                  GUI:Text("start: " .. tostring(v.start))
                  GUI:Text("since start: " .. tostring(v.start and TimeSince(v.start)))
                  GUI:Text("status: " .. tostring(v.status))
                  GUI:Text("requested: " .. tostring(v.requested))
                  GUI:Text("since requested: " .. tostring(v.requested and TimeSince(v.requested)))
                  GUI:Text("category: " .. tostring(v.category))
                  GUI:Text("request_type: " .. tostring(v.request_type))
                  GUI:Text("key: " .. tostring(v.key))
                  GUI:Text("id: " .. tostring(v.id))
                  GUI:Text("tries: " .. tostring(v.tries))
                  GUI:Text("URL: " .. tostring(v.url))
                  GUI:Text("custom_id: " .. tostring(v.custom_id))
               end
            end
            GUI:EndChild()
         end

         if GUI:CollapsingHeader("Blacklisted") then
            GUI:BeginChild("Blacklisted", 0, 0, true)
            for category, data in table.pairsbykeys(api_manager.blacklist) do
               for k, v in table.pairsbykeys(data) do
                  if GUI:ImageButton("del " .. category .. k, GetStartupPath() .. "\\GUI\\UI_Textures\\w_delete.png", 13, 13) then
                     api_manager.blacklist[category][k] = nil
                  end
                  GUI:SameLine()
                  if GUI:CollapsingHeader(k .. " - " .. category) then
                     GUI:Text("start: " .. tostring(v.time))
                     GUI:Text("since start: " .. tostring(v.time and api_manager.TimeSince(v.time)))
                     GUI:Text("blacklist amount: " .. tostring(v.count))
                     GUI:Text("game version: " .. tostring(v.game_version))
                  end
               end
            end
            GUI:EndChild()
         end
      end
      GUI:End()
   end

   Settings.api_manager.open = api_manager.UI.open
   Settings.api_manager.not_collapsed = api_manager.UI.not_collapsed
end

gw2_api_manager = {
   getIcon = api_manager.getIcon,
   getPrice = api_manager.getPrice,
   getListings = api_manager.getListings,
   getInfo = api_manager.getInfo,
   get = api_manager.get,
   add_custom = api_manager.add_custom,
   delete = api_manager.delete,
   Load_API_Data = api_manager.Load_API_Data,
   Load_Blacklist = api_manager.Load_Blacklist,
   is_Blacklisted = api_manager.is_Blacklisted,
   Save_API_Data = api_manager.Save_API_Data,
   API_Data = api_manager.API_Data,
   blacklist = api_manager.blacklist,
   path = api_manager.path,
   icons_path = api_manager.icons_path,
   data_path = api_manager.data_path,
   update_language = api_manager.update_language,
}

RegisterEventHandler("Module.Initalize", api_manager.ModuleInit, "api_manager.ModuleInit")
RegisterEventHandler("Gameloop.Update", api_manager.API_DataHandler, "api_manager.API_DataHandler")
RegisterEventHandler("Gameloop.Draw", api_manager.InfoUI, "api_manager.InfoUI")