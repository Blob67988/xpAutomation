local Timer = require("timer")
local db = require("./modules/database.lua")
local discordia = require("discordia")
local rbx = require("rbx.lua")
local fs = require("fs")
local embed = require("./modules/embed.lua")
local verified = require("./modules/verified.lua")
local json = require("json")

local rbxClient = rbx.client()
local discordClient = discordia.Client()

local BypassCommands = {"verify","help","setup"}

function Split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function Dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. Dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

local cmds = {}

fs.readdir("./commands",function(err,tbl)
    for _,v in pairs(tbl) do
        local n = string.gsub(v,".lua","")
        cmds[n] = require("./commands/"..v)
    end
end)

local apicmds = {}

fs.readdir("./apiCommands",function(err,tbl)
    for _,v in pairs(tbl) do
        local n = string.gsub(v,".lua","")
        apicmds[n] = require("./apiCommands/"..v)
    end
end)

rbxClient:on("ready",function()
    print("ROBLOX CLIENT READY")
end)

local DeveloperData = db:get("DeveloperData")
local Whitelist = DeveloperData.Whitelist

local Cooldown = {}

discordClient:on("messageCreate",function(message)
    if message.channel.type ~= 0 then return end
    if Cooldown[message.guild.id] then return end
    
    local Guild = db:get(message.guild.id)
    local Whitelisted = Whitelist[message.guild.id]

    local args
    if Guild == nil then
        if not string.find(message.content,"^r!") then return end
        args = string.lower(message.content)
        args = Split(args," ")
        args[1] = string.gsub(args[1],"^r!","")

        if not Whitelisted then message.channel:send(embed.new("This guild is not currently whitelisted. Contact the developers if you think this is a mistake!")) return end
        if args[1] ~= "verify" and args[1] ~= "setup" and args[1] ~= "help" then message.channel:send(embed.new("You need to setup before you can use this command!\n\n`r!setup <groupid>`")) return end
    else
        if not string.find(message.content,"^"..Guild.Settings.Prefix) then return end
        args = string.lower(message.content)
        args = Split(args," ")
        args[1] = string.gsub(args[1],Guild.Settings.Prefix,"")

        if not Whitelisted then message.channel:send(embed.new("This guild is not currently whitelisted. Contact the developers if you think this is a mistake!")) return end
    end

    --[[if message.referencedMessage == nil then
        for _,v in pairs(message.mentionedUsers) do
            if discordClient.user.id == v.id then message.channel:send(embed.new("Prefix: **"..Guild.Settings.Prefix.."**")) return end
        end
    end]]

    if cmds[args[1]] == nil then return end

    if args[1] == "dev" and message.author.id == "346249745590910976" then cmds["dev"](rbxClient, discordClient, message, args) Timer.setTimeout(1000,function() DeveloperData = db:get("DeveloperData") Whitelist = DeveloperData.Whitelist end)return end
    if args[1] == "help" then cmds[args[1]](rbxClient, discordClient, message, args) return end

    if verified(message.author.id) == nil and args[1] ~= "verify" then message.channel:send(embed.new("You must verify before using commands!\n\n`r!verify <roblox username>`")) return end

    Cooldown[message.guild.id] = true
    Timer.setTimeout(800,function()Cooldown[message.guild.id] = false end)
    local s,e = pcall(cmds[args[1]],rbxClient, discordClient, message, args)
    if not s then message.channel:send(embed.new("The request returned with an error. Contact the developers at r!support.")) message.channel:send(e) print(e) end
end)








-- test




rbxClient:run("_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_6CB0C3424E08C0706DE863AC22362693C71FDDF3BB0454E4AD6ADDBE9BE34BBC8C5B9E1785961808D4B25E12FC1B521E74B53E830A54624FDD381C23B4A182EE29A2894877AE00CCC65C7C0026E80A59CF72F8D893EF2935F7495932DAFE5CD92FA40B81A44F129CCF605CE34D816EA1C65E1F46FF18A8C2BCE29687506476167A5E6123DC7A29E3FE582766037F6AAAFD195A263D1FA209EA8D7CE42B18D6ADD6D085AE620DCEEB971CD6886431A941413A24F50AF0D8F4BCE9945EE44C322775533BADE641984C076B53712C894571B3BC1A919A525CADBF4901378B1364CD803485DF5B1020211CB27004CC93A6551D9350908F66F27BB54E37E72A0F949BD1EFBB1F8EFACADB0DA3992CD13B6E22A47A045CFCE44555031F30D6E190D0B462D427F01CD0133A44D77E2A7A7698E7690D7656AFD561668E3E3AF59E6DC32E72B20B63F7FFF1547C62ECEE04422D7A47B8F697")
discordClient:run('Bot ODUyNDA3NjI1ODQwMzI4NzA0.YMGYdg.OOnrV_WNVVOQNrK7jDWFlyoCIQs')