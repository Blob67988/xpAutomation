local embed = require("../modules/embed.lua")
local timer = require("timer")
local db = require("../modules/database")
local verified = require("../modules/verified")
local permissions = require("../modules/permissions")

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

    if permissions(message) < 4 then message.channel:send(embed.new("You need the **Owner** permission to use this command!")) return end

    local Guild = db:get(message.guild.id)

    if Guild.GroupBinds == nil then Guild.GroupBinds = {} end

    if args[2] == "add" then
        
        if args[3] == nil then message.channel:send(embed.new("You need to give a **GroupId**!")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("**"..args[3].."** is not a valid GroupId.")) return end

        local Group = rbx.group.getGroup(args[3])
        if Group["errors"] ~= nil then message.channel:send(embed.new("**"..args[3].."** is not a valid GroupId.")) return end
        if Group.id == Guild.GroupId then message.channel:send(embed.new("You cannot add binds to this group!")) return end

        if Guild.GroupBinds[Group.id] == nil then Guild.GroupBinds[Group.id] = {} Guild.GroupBinds[Group.id].Name = Group.name end
        
        if #message.mentionedRoles < 1 then message.channel:send(embed.new("You need to **mention a role**!")) return end
        for _,v in pairs(message.mentionedRoles) do

            if Guild.GroupBinds[Group.id][v.id] == true then message.channel:send(embed.new(v.mentionString.." is already bound to **"..Group.name.."**.")) goto cont end
            Guild.GroupBinds[Group.id][v.id] = true
            message.channel:send(embed.new(v.mentionString.." has been added to **"..Group.name.."**."))

            ::cont::
        end
        db:set(Guild,message.guild.id)
        if #message.mentionedRoles > 1 then message.channel:send(embed.new("All roles have been added!")) end

    elseif args[2] == "remove" then
        
        if args[3] == nil then message.channel:send(embed.new("You need to give a **GroupId**!")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("**"..args[3].."** is not a valid GroupId.")) return end

        local Group = rbx.group.getGroup(args[3])
        if Group["errors"] ~= nil then message.channel:send(embed.new("**"..args[3].."** is not a valid GroupId.")) return end
        if Guild.GroupBinds[Group.id] == Guild.GroupId then message.channel:send(embed.new("You cannot remove binds to this group!")) return end

        if Guild.GroupBinds[Group.id] == nil then message.channel:send(embed.new("**"..Group.name.."** has no bound roles!")) return end
        
        if #message.mentionedRoles < 1 then message.channel:send(embed.new("You need to **mention a role**!")) return end
        for _,v in pairs(message.mentionedRoles) do

            if Guild.GroupBinds[Group.id][v.id] == nil then message.channel:send(embed.new(v.mentionString.." is not bound to **"..Group.name.."**.")) goto cont end
            Guild.GroupBinds[Group.id][v.id] = nil
            message.channel:send(embed.new(v.mentionString.." has been removed from **"..Group.name.."**."))

            ::cont::
        end
        if #Guild.GroupBinds[Group.id] == 0 then Guild.GroupBinds[Group.id] = nil end
        db:set(Guild,message.guild.id)
        if #message.mentionedRoles > 1 then message.channel:send(embed.new("All roles have been remove!")) end

    else

        -- glitchy hack that lets me get how many bind groups there are, # doesnt work for some reason
        local l = 0
        for _,v in pairs(Guild.GroupBinds) do l = l + 1 end

        if Guild.GroupBinds == nil then Guild.GroupBinds = {} db:set(Guild,message.guild.id) end
        if l == 0 then message.channel:send(embed.new("You currently have no groupbinds!")) return end

        message.channel:broadcastTyping()

        local Fields = {}
        local HighestPage = 1
        for _,v in pairs(Guild.GroupBinds) do

            if Fields[HighestPage] == nil then Fields[HighestPage] = {} end
            if #Fields[HighestPage] >= 8 then HighestPage = HighestPage + 1 end

            local New = {}

            New.name = v.Name
            New.value = ""
            for i,v in pairs(v) do
                if tonumber(i) == nil then goto cont end

                New.value = New.value.."<@&"..i.."> "

                ::cont::
            end

            table.insert(Fields[HighestPage],New)

        end

        local CurrentPage = 1
        local m = message.channel:send(embed.new({title="Groupbinds",fields=Fields[CurrentPage]}))

        if HighestPage == 1 then return end

        m:addReaction("⬅")
        m:addReaction("➡")

        client:on("reactionAdd", function(reaction, UserId)
            if reaction.message ~= m or client.user.id == UserId then return end
            if reaction.emojiName == "➡" then
                if CurrentPage == HighestPage then reaction:delete(UserId) return end
                CurrentPage = CurrentPage + 1
                m:update(embed.new({
                    title="Groupbinds",
                    fields=Fields[CurrentPage],
                }))
                reaction:delete(UserId)
            elseif reaction.emojiName == "⬅" then
                if CurrentPage == 1 then reaction:delete(UserId) return end
                CurrentPage = CurrentPage - 1
                m:update(embed.new({
                    title="Groupbinds",
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