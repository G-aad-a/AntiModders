Anti_Modders = {}
Anti_Modders.Config = config
Anti_Modders.Bans = {}

Citizen.CreateThread(function() 
    PerformHttpRequest("https://melonac.xyz/api/FetchBans.php", function(err,text,headers) 
        json_data = json.decode(text)
        for k, v in pairs(json_data) do
            print(k)
            print(v)
        end
    end)
end)