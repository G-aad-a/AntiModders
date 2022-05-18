# Anti Modders

This is a global ban list resource to stop all known modders from joining your server.

**Drag and drop it into your server and your ready to go**

```
ensure AntiModders
```

## Available Functions

```lua

anti_modders = exports['AntiModders']:GetMainObject()

anti_modders.FetchBans() -- will return all bans in a table

anti_modders.IsGloballyBanned(source) --[[ if the source is banned, it returns a table with the reason and if they're banned 

    {banned = bool, reason = string or nil)

--]]

```

## Discord
[Discord](https://antimodders.gaada.vip)

## License
[MIT](https://choosealicense.com/licenses/mit/)