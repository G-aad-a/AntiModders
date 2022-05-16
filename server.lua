Anti_Modders = {}
Anti_Modders.Config = config
Anti_Modders.Bans = {}

Citizen.CreateThread(function() 
    PerformHttpRequest("https://melonac.xyz/api/FetchBans.php", function(err,text,headers) 
        json_data = json.decode(text)
        for k, v in pairs(json_data) do
            Anti_Modders.Bans[k] = {}
            for _k, _v in pairs(v) do
                if _k == "reason" then
                    Anti_Modders.Bans[k]["reason"] = _v
                elseif _k == "identifer" then
                    Anti_Modders.Bans[k]["identifer"] = _v
                elseif _k == "id" then
                    Anti_Modders.Bans[k]["id"] = _v
                end
            end
        end
    end)

    Wait(1000)
    --for k, v in pairs(GetPlayerIdentifiers(source)) do
        for _k, _v in pairs(Anti_Modders.Bans) do
            print(_k)
            print(_v)
            print(_v["identifer"])
            for k, v in pairs(_v) do
               
            end
        end
    --end
end)


AddEventHandler("playerConnecting", function(name, skr, def)
    local source = source
    def.defer()
    Wait(60)


   

end)