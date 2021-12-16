local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")
local verified = require("../modules/verified")
local timer = require("timer")

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

return function (rbx, client, message, args)

    local Guild = db:get(message.guild.id)

    if args[2] == "create" then

        if permissions(message) < 4 then message.channel:send(embed.new("You do not have the required permissions to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to provide a name!")) return end

        Capargs = Split(message.content," ")

        if Guild.Medals == nil then Guild.Medals = {} db:set(Guild,message.guild.id) end

        table.remove(Capargs,2)
        table.remove(Capargs,1)

        local MedalName = ""
        for i,v in pairs(Capargs) do
            if Capargs[i+1] == nil or string.find(Capargs[i+1],"^<@&") then MedalName = MedalName..v break end
            MedalName = MedalName..v.." "
        end

        if Guild.Medals[MedalName] ~= nil then message.channel:send(embed.new("A medal of the name `"..MedalName.."` already exists!")) return end

        local NewMedal = {}
        NewMedal.Roles = {}

        for _,v in pairs(message.mentionedRoles) do

            NewMedal.Roles[#NewMedal.Roles+1] = v.id

        end

        Guild.Medals[MedalName] = NewMedal
        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("New medal **"..MedalName.."** was created with **"..#message.mentionedRoles.."** roles."))

    elseif args[2] == "delete" then

        if permissions(message) < 4 then message.channel:send(embed.new("You do not have the required permissions to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to provide a name!")) return end

        Capargs = Split(message.content," ")

        if Guild.Medals == nil then Guild.Medals = {} db:set(Guild,message.guild.id) end

        table.remove(Capargs,2)
        table.remove(Capargs,1)

        local MedalName = ""
        for i,v in pairs(Capargs) do
            if Capargs[i+1] == nil or string.find(Capargs[i+1],"^<@&") then MedalName = MedalName..v break end
            MedalName = MedalName..v.." "
        end

        if Guild.Medals[MedalName] == nil then message.channel:send(embed.new("A medal of the name `"..MedalName.."` doesn't exist!")) return end

        Guild.Medals[MedalName] = nil
        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("Removed medal **"..MedalName.."**."))

    elseif args[2] == "add" then

        if permissions(message) < 2 then message.channel:send(embed.new("You do not have the required permissions to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to provide a **username**!")) return end
        if args[4] == nil then message.channel:send(embed.new("You need to provide a **medal name**!")) return end

        if Guild.Medals == nil then Guild.Medals = {} db:set(Guild,message.guild.id) end

        Capargs = Split(message.content," ")

        table.remove(Capargs,3)
        table.remove(Capargs,2)
        table.remove(Capargs,1)

        local MedalName = ""
        for i,v in pairs(Capargs) do
            if Capargs[i+1] == nil or string.find(Capargs[i+1],"^<@&") then MedalName = MedalName..v break end
            MedalName = MedalName..v.." "
        end

        if Guild.Medals[MedalName] == nil then message.channel:send(embed.new("**"..MedalName.."** does not exist!")) return end
        
        local User = rbx.user.getUser(args[3])

        if User == nil then message.channel:send(embed.new("**"..MedalName.."** doesn't exist!")) return end

        if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end

        if Guild.Members[User.id].Medals[MedalName] == true then message.channel:send(embed.new("**"..User.name.."** already has the medal **"..MedalName.."**!")) return end

        Guild.Members[User.id].Medals[MedalName] = true

        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("**"..User.name.."** was given **"..MedalName.."**."))

    elseif args[2] == "remove" then

        if permissions(message) < 2 then message.channel:send(embed.new("You do not have the required permissions to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to provide a **username**!")) return end
        if args[4] == nil then message.channel:send(embed.new("You need to provide a **medal name**!")) return end

        if Guild.Medals == nil then Guild.Medals = {} db:set(Guild,message.guild.id) end

        Capargs = Split(message.content," ")

        table.remove(Capargs,3)
        table.remove(Capargs,2)
        table.remove(Capargs,1)

        local MedalName = ""
        for i,v in pairs(Capargs) do
            if Capargs[i+1] == nil or string.find(Capargs[i+1],"^<@&") then MedalName = MedalName..v break end
            MedalName = MedalName..v.." "
        end

        if Guild.Medals[MedalName] == nil then message.channel:send(embed.new("**"..MedalName.."** does not exist!")) return end
        
        local User = rbx.user.getUser(args[3])

        if User == nil then message.channel:send(embed.new("**"..args[3].."** doesn't exist!")) return end

        if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end

        if Guild.Members[User.id].Medals[MedalName] == nil then message.channel:send(embed.new("**"..User.name.."** doesn't have the the medal **"..MedalName.."**!")) return end

        Guild.Members[User.id].Medals[MedalName] = nil

        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("**"..User.name.."** was removed from **"..MedalName.."**."))

    elseif args[2] == "list" then

        if Guild.Medals == nil then Guild.Medals = {} db:set(Guild,message.guild.id) end

        message.channel:broadcastTyping()

        local Fields = {}
        local HighestPage = 1
        Fields[HighestPage] = {}

        for i,v in pairs(Guild.Medals) do
            if #Fields[HighestPage] >= 7 then HighestPage = HighestPage + 1 Fields[HighestPage] = {} end

            local New = {}
            New.name = i
            
            New.value = ""
            for _,v in pairs(v.Roles) do
                New.value = New.value.."<@&"..v..">\n"
            end

            if New.value == "" then New.value = "No Roles" end

            New.inline = true

            table.insert(Fields[HighestPage],New)
        end

        local CurrentPage = 1
        local m = message.channel:send(embed.new({title="Medals",fields=Fields[1]}))

        if HighestPage == 1 then return end

        m:addReaction("⬅")
        m:addReaction("➡")

        client:on("reactionAdd", function(reaction, UserId)
            if reaction.message ~= m or client.user.id == UserId then return end
            if reaction.emojiName == "➡" then
                if CurrentPage == HighestPage then reaction:delete(UserId) return end
                CurrentPage = CurrentPage + 1
                m:update(embed.new({
                    title="Medals",
                    fields=Fields[CurrentPage],
                }))
                reaction:delete(UserId)
            elseif reaction.emojiName == "⬅" then
                if CurrentPage == 1 then reaction:delete(UserId) return end
                CurrentPage = CurrentPage - 1
                m:update(embed.new({
                    title="Medals",
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

    elseif args[2] == nil then

        local UserId = verified(message.author.id)

        local User = rbx.user.getUser(UserId)

        if User == nil then message.channel:send("This user doesn't exist!") return end

        if Guild.Members[User.id] == nil then Guild.Members[User.id] = {Medals = {}} end

        local desc = ""
        for i,v in pairs(Guild.Members[UserId].Medals) do
            desc = desc..i.."\n"
        end

        if desc == "" then desc = "This user has no medals!" end

        message.channel:send(embed.new({title="**"..User.name.."**'s Medals",description=desc}))

    else

        local User = rbx.user.getUser(args[2])

        if User == nil then message.channel:send("**"..args[2].."** is not a real user!") return end

        if Guild.Members[User.id] == nil then Guild.Members[User.id] = {Medals = {}} end

        local desc = ""
        for i,v in pairs(Guild.Members[User.id].Medals) do
            desc = desc..i.."\n"
        end

        if desc == "" then desc = "This user has no medals!" end

        message.channel:send(embed.new({title="**"..User.name.."**'s Medals",description=desc}))

    end

end