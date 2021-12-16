local embed = require("../modules/embed.lua")
local db = require("../modules/database")
local permissions = require("../modules/permissions")

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

return function (rbx, client, message, args)

    if permissions(message) < 4 then message.channel:send(embed.new("You need permission **Owner** to use this command!")) return end

    if args[2] == "verified" and args[3] == "role" then

        local MentionedRoles = message.mentionedRoles
        if #MentionedRoles  < 1 then message.channel:send(embed.new("Mention a **role** to set the verified role!")) return end

        local Guild = db:get(message.guild.id)

        for _,v in pairs(MentionedRoles) do
            Guild.Settings.VerifiedRole = v.id break
        end

        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("Verified Role set to <@&"..Guild.Settings.VerifiedRole..">"))

    elseif args[2] == "can" and args[3] == "demote" then

        if args[4] ~= "true" and args[4] ~= "false" then message.channel:send(embed.new("Please give **true** or **false** to set Can Demote.")) return end
        local Guild = db:get(message.guild.id)
        if args[4] == "true" then
            Guild.Settings.CanDemote = true
            message.channel:send(embed.new("Can Demote changed to **true**."))
        elseif args[4] == "false" then
            Guild.Settings.CanDemote = false
            message.channel:send(embed.new("Can Demote changed to **false**."))
        end

        db:set(Guild,message.guild.id)

    elseif args[2] == "max" and args[3] == "change" then
        
        if args[4] == nil then message.channel:send(embed.new("Give a **number** to change it to!")) return end
        if tonumber(args[4]) == nil then message.channel:send(embed.new("Give a **number** to change it to!")) return end

        local Guild = db:get(message.guild.id)

        Guild.Settings.MaxChange = tonumber(args[4])
        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("**Max Change** was updated to **"..args[4].."**."))

    elseif args[2] == "prefix" then

        if args[3] == nil then message.channel:send(embed.new("Give a **string** to change the prefix.")) return end

        local Guild = db:get(message.guild.id)

        local args = string.gsub(message.content,Guild.Settings.Prefix,"")
        args = Split(args," ")

        Guild.Settings.Prefix = tostring(args[3])
        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("The prefix for **"..message.guild.name.."** had been set to **"..args[3].."**"))

    else

        local Guild = db:get(message.guild.id)

        local CanDemote = "False"
        if Guild.Settings.CanDemote then CanDemote = "True" end

        message.channel:send(embed.new({
            title = "Settings",
            description = "Verified Role: <@&"..Guild.Settings.VerifiedRole..">\nCan Demote: **"..CanDemote.."**\nFilled Bar: "..Guild.Settings.FilledBar.."\nEmpty Bar: "..Guild.Settings.EmptyBar.."\nMax Change: **"..Guild.Settings.MaxChange.."**\nPrefix: **"..Guild.Settings.Prefix.."**"
        }))

    end

end