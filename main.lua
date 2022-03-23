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
local Blacklist = DeveloperData.Blacklist or {}

local Cooldown = {}

discordClient:on("messageCreate",function(message)
    if Blacklist[message.author.id] ~= nil then return end
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

    if args[1] == "dev" and message.author.id == "856348786770837534" then cmds["dev"](rbxClient, discordClient, message, args) Timer.setTimeout(1000,function() DeveloperData = db:get("DeveloperData") Blacklist = DeveloperData.Blacklist or {} Whitelist = DeveloperData.Whitelist end)return end
    if args[1] == "help" then cmds[args[1]](rbxClient, discordClient, message, args) return end

    if verified(message.author.id) == nil and args[1] ~= "verify" then message.channel:send(embed.new("You must verify before using commands!\n\n`r!verify <roblox username>`")) return end

    Cooldown[message.guild.id] = true
    Timer.setTimeout(800,function()Cooldown[message.guild.id] = false end)
    local s,e = pcall(cmds[args[1]],rbxClient, discordClient, message, args)
    if not s then message.channel:send(embed.new("The request returned with an error. Contact the developers at r!support.")) message.channel:send(e) print(e) end
end)








-- test




rbxClient:run("")
discordClient:run('')