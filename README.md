# The Rake Remastered - Legacy & Remastered 

## Discord server is at " https://discord.gg/8At8X7YuKC" -- join this if you're interested in the executor I'm working on "Lunox" :>

1. These scripts are deprecated and won't be updated anymore.

2. Asking for updates in the Discord server or for support won't get you anywhere.

3. If you wan't new stuff, make it yourself; it's open source for a reason.

With a all this said, enjoy using the scripts! :>

```Lua
-- This is the legacy script (not updated with all the features from remastered or new UI)
   loadstring(game:HttpGet("https://raw.githubusercontent.com/kxtsuishimfr/The-Rake-Remastered/main/src/TheRakeRemastered.lua"))() -- This was created using generative AI for major parts of it.
```

```Lua
-- This is the remastered script (with all the new stuff, but still deprecated)
-- This was created by humans through collaborations, without generative AI.
local req = request or syn and syn.request or http and http.request
if not req then return end

local k = "Tempt_ETag"
local h = getgenv()[k] and {["If-None-Match"] = getgenv()[k]} or {}

local r = req({
	Url = "https://tempt.vercel.app/api/getLatestScript", 
	Method = "GET",
	Headers = h
})

if not r or r.StatusCode == 304 then return end
getgenv()[k] = r.Headers and (r.Headers.ETag or r.Headers.etag)

loadstring(r.Body)()
```

Have fun using or skidding this!!
