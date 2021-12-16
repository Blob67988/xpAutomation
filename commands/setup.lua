local embed = require("../modules/embed.lua")
local verified = require("../modules/verified")
local db = require("../modules/database")

return function (rbx, client, message, args)
    if message.author.id ~= message.guild.ownerId and message.author.id ~= "346249745590910976" then message.channel:send(embed.new("You are not the server owner!")) return end
    if args[2] == nil then message.channel:send(embed.new("Missing GroupId.")) return end

    local GroupId = tonumber(args[2])
    if GroupId == nil then message.channel:send(embed.new("Invalid GroupId `"..args[2].."`.")) return end

    local Group = rbx.group.getGroup(GroupId)
    if Group.errors ~= nil then message.channel:send(embed.new("Invalid GroupId `"..args[2].."`.")) return end

    local User = verified(message.author.id)
    if Group.owner.userId ~= User and message.author.id ~= "346249745590910976" then message.channel:send(embed.new("You are not verified as the owner of this group!")) return end

    local m = message.channel:send(embed.new({title="IMPORTANT",description="Confirm that you agree to the xpAutomations Terms of Service and that you understand all previous data will be lost forever by **reacting to this message**."}))
    m:addReaction("✅")
    m:addReaction("❎")
    local reply, reaction = client:waitFor("reactionAdd",30000,function(reaction,userid)
        return (reaction.message == m and message.author.id == userid)
    end)
    if not reply then message.channel:send(embed.new("Prompt timeout, setup cancelled.")) return end
    if reaction.emojiName ~= "✅" then message.channel:send(embed.new("Setup cancelled.")) return end
    

    local New = {}

    New.Roles = {}
    New.Members = {}
    New.GroupId = GroupId
    New.OwnerId = message.guild.ownerId
    New.Permissions = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {message.guild.ownerId},
    }
    New.Settings = {
        ["VerifiedRole"] = nil,
        ["CanDemote"] = true,
        ["FilledBar"] = "🟧",
        ["EmptyBar"] = "⬛",
        ["MaxChange"] = 20,
        ["Prefix"] = "r!",
        ["Quota"] = {
            ["Enabled"] = false,
            ["Channel"] = nil,
        }
    }
    New.API = {
        ["Enabled"] = false,
        ["Key"] = "",
        ["MaxChange"] = 20,
    }
    New.Quota = {}

    local Roles = rbx.group.getRoles(GroupId)

    for _,v in pairs(Roles) do
        New.Roles[v.rank] = {
            Name = v.name,
            Id = v.id,
            Locked = true,
            XP = 0,
            Prefix = "",
            Roles = {},
            Quota = 0,
        }
    end

    message.channel:send(embed.new("Ping your verified role."))
    local reply, mess = client:waitFor("messageCreate",60000,function(mess)
        return (message.author == mess.author and mess.channel == message.channel)
    end)
    if not reply then message.channel:send(embed.new("Prompt timeout, setup cancelled.")) return end

    if #mess.mentionedRoles < 1 then message.channel:send(embed.new("Role not mentioned, setup cancelled.")) return end

    for _,v in pairs(mess.mentionedRoles) do
        New.Settings.VerifiedRole = v.id break
    end

    db:set(New,message.guild.id)

    message.channel:send(embed.new("Setup completed for **"..Group.name.."**."))

end