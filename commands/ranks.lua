local timer = require("timer")
local embed = require("../modules/embed")
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

function table.find(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return k
		end
	end
	return nil
end

return function (rbx, client, message, args)
    local Guild = db:get(message.guild.id)
    if args[2] == "role" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] ~= "add" and args[3] ~= "remove" then message.channel:send(embed.new("Use `add` or `remove` as the second argument.")) return end
        if args[4] == nil then message.channel:send(embed.new("You need to give a RankId!")) return end
        if tonumber(args[4]) == nil then message.channel:send(embed.new("`"..args[4].."` is not a valid RankId!")) return end
        if Guild.Roles[tonumber(args[4])] == nil then message.channel:send(embed.new("`"..args[4].."` is not a valid RankId!")) return end

        if args[3] == "add" then

            local MentionedRoles = message.mentionedRoles
            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to add it to a rank!")) return end
            for _,v in pairs(MentionedRoles) do
                if table.find(Guild.Roles[tonumber(args[4])].Roles,v.id) then message.channel:send(embed.new(v.mentionString.." is already in **"..Guild.Roles[tonumber(args[4])].Name.."**.")) goto cont end
                table.insert(Guild.Roles[tonumber(args[4])].Roles,v.id)
                message.channel:send(embed.new(v.mentionString.." has been added to **"..Guild.Roles[tonumber(args[4])].Name.."**."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been added to **"..Guild.Roles[tonumber(args[4])].Name.."**.")) return end

        elseif args[3] == "remove" then

            local MentionedRoles = message.mentionedRoles
            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to add it to a rank!")) return end
            for _,v in pairs(MentionedRoles) do
                local Index = table.find(Guild.Roles[tonumber(args[4])].Roles,v.id)
                if Index == nil then message.channel:send(embed.new(v.mentionString.." does not exist in **"..Guild.Roles[tonumber(args[4])].Name.."**.")) goto cont end
                table.remove(Guild.Roles[tonumber(args[4])].Roles,Index)
                message.channel:send(embed.new(v.mentionString.." was removed from **"..Guild.Roles[tonumber(args[4])].Name.."**."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been removed from **"..Guild.Roles[tonumber(args[4])].Name.."**.")) return end

        end

    elseif args[2] == "prefix" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] == nil then message.channel:send(embed.new("Give a RankId to set the prefix for.")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end
        if Guild.Roles[tonumber(args[3])] == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end

        local m = Split(message.content," ")

        if m[4] == nil then m[4] = "" end
        
        Guild.Roles[tonumber(args[3])].Prefix = m[4]

        db:set(Guild,message.guild.id)

        if args[4] == nil then 
            message.channel:send(embed.new("The prefix of **"..Guild.Roles[tonumber(args[3])].Name.."** has been set to **nil**.")) 
            return
        else
            message.channel:send(embed.new("The prefix of **"..Guild.Roles[tonumber(args[3])].Name.."** has been set to **"..m[4].."**.")) 
            return
        end

    elseif args[2] == "xp" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] == nil then message.channel:send(embed.new("Give a RankId to set the XP for.")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end
        if Guild.Roles[tonumber(args[3])] == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end

        if args[4] == nil then message.channel:send(embed.new("Give an XP amount to set it for **"..Guild.Roles[tonumber(args[3])].Name.."**.")) return end
        if tonumber(args[4]) == nil then message.channel:send(embed.new("Give a valid XP amount to set it for **"..Guild.Roles[tonumber(args[3])].Name.."**.")) return end

        Guild.Roles[tonumber(args[3])].XP = tonumber(args[4])

        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("The XP for **"..Guild.Roles[tonumber(args[3])].Name.."** was set to **"..args[4].."**."))

    elseif args[2] == "lock" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] == nil then message.channel:send(embed.new("Give a RankId to lock!")) return end

        table.remove(args,2)
        table.remove(args,1)

        for _,v in pairs(args) do
            if tonumber(v) == nil then message.channel:send(embed.new("`"..v.."` is not a valid RankId.")) goto cont end
            if Guild.Roles[tonumber(v)] == nil then message.channel:send(embed.new("`"..v.."` is not a valid RankId.")) goto cont end
            if Guild.Roles[tonumber(v)].Locked == true then message.channel:send(embed.new("**"..Guild.Roles[tonumber(v)].Name.."** is already locked.")) goto cont end
            Guild.Roles[tonumber(v)].Locked = true
            message.channel:send(embed.new("**"..Guild.Roles[tonumber(v)].Name.."** was locked."))
            ::cont::
        end
        db:set(Guild,message.guild.id)
        if #args > 1 then message.channel:send(embed.new("All ranks have been locked.")) end

    elseif args[2] == "unlock" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] == nil then message.channel:send(embed.new("Give a RankId to unlock!")) return end

        table.remove(args,2)
        table.remove(args,1)

        for _,v in pairs(args) do
            if tonumber(v) == nil then message.channel:send(embed.new("`"..v.."` is not a valid RankId.")) goto cont end
            if Guild.Roles[tonumber(v)] == nil then message.channel:send(embed.new("`"..v.."` is not a valid RankId.")) goto cont end
            if Guild.Roles[tonumber(v)].Locked == false then message.channel:send(embed.new("**"..Guild.Roles[tonumber(v)].Name.."** is already unlocked.")) goto cont end
            Guild.Roles[tonumber(v)].Locked = false
            message.channel:send(embed.new("**"..Guild.Roles[tonumber(v)].Name.."** was unlocked."))
            ::cont::
        end
        db:set(Guild,message.guild.id)
        if #args > 1 then message.channel:send(embed.new("All ranks have been unlocked.")) end

    elseif args[2] == "quota" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the `Owner` permission to use this command!")) return end
        if args[3] == nil then message.channel:send(embed.new("Give a RankId to set the Quota for.")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end
        if Guild.Roles[tonumber(args[3])] == nil then message.channel:send(embed.new("`"..args[3].."` is not a valid RankId.")) return end

        if args[4] == nil then message.channel:send(embed.new("Give an Quota amount to set it for **"..Guild.Roles[tonumber(args[3])].Name.."**.")) return end
        if tonumber(args[4]) == nil then message.channel:send(embed.new("Give a valid Quota amount to set it for **"..Guild.Roles[tonumber(args[3])].Name.."**.")) return end

        Guild.Roles[tonumber(args[3])].Quota = tonumber(args[4])

        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("The Quota for **"..Guild.Roles[tonumber(args[3])].Name.."** was set to **"..args[4].."**."))

    else

        message.channel:broadcastTyping()

        local Fields = {}

        local HighestPage = 1
        Fields[HighestPage] = {}
        for i=0,255 do
            local v = Guild.Roles[i]
            if v == nil then goto cont end
            if #Fields[HighestPage] >= 8 then HighestPage = HighestPage + 1; Fields[HighestPage] = {} end
            local New = {}
            New.name = v.Name

            if v.Locked then New.name = New.name.." :lock:" end

            local Roles = ""
            for _,v in pairs(v.Roles) do
                Roles = Roles.."<@&"..v.."> "
            end
            if Roles == "" then Roles = "**None**" end

            local Prefix = v.Prefix
            if Prefix == "" then Prefix = "None" end

            local Quota = v.Quota
            if Quota == nil or Quota == 0 then Quota = "None" end

            New.inline = true
            New.value = "RankId: **"..i.."**\nXP: **"..v.XP.."**\nRoles: "..Roles.."\nPrefix: **"..Prefix.."**\nQuota: **"..Quota.."**"
            table.insert(Fields[HighestPage],New)

            ::cont::
        end

        local CurrentPage = 1
        local m = message.channel:send(embed.new({title="Ranks",fields=Fields[1]}))

        if HighestPage == 1 then return end

        m:addReaction("⬅")
        m:addReaction("➡")

        client:on("reactionAdd", function(reaction, UserId)
            if reaction.message ~= m or client.user.id == UserId then return end
            if reaction.emojiName == "➡" then
                if CurrentPage == HighestPage then reaction:delete(UserId) return end
                CurrentPage = CurrentPage + 1
                m:update(embed.new({
                    title="Ranks",
                    fields=Fields[CurrentPage],
                }))
                reaction:delete(UserId)
            elseif reaction.emojiName == "⬅" then
                if CurrentPage == 1 then reaction:delete(UserId) return end
                CurrentPage = CurrentPage - 1
                m:update(embed.new({
                    title="Ranks",
                    fields=Fields[CurrentPage]
                }))
                reaction:delete(UserId)
            else
                reaction:delete(UserId)
            end
        end)

        timer.setTimeout(60000,function()
            client:removeListener("reactionAdd", function(reaction, UserId)
                if reaction.message ~= m or client.user.id == UserId then return end
                if reaction.emojiName == "➡" then
                    if CurrentPage == HighestPage then reaction:delete(UserId) return end
                    CurrentPage = CurrentPage + 1
                    reaction:delete(UserId)
                    m:update({title="Ranks",fields=Fields[CurrentPage]})
                
                elseif reaction.emojiName == "⬅" then
                    if CurrentPage == 1 then reaction:delete(UserId) return end
                    CurrentPage = CurrentPage - 1
                    reaction:delete(UserId)
                    m:update({title="Rank",fields=Fields[CurrentPage]})
                else
                    reaction:delete(UserId)
                end
            end)
        end)

    end
end