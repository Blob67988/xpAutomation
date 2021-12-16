local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")
local verified = require("../modules/verified")

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

    local Changed = false
    if Guild.Quota == nil then Guild.Quota = {} Changed = true end
    if Guild.Settings.Quota == nil then Guild.Settings.Quota = {Enabled = false, Channel = nil} Changed = true end

    for i,v in pairs(Guild.Roles) do
        if Guild.Roles[i].Quota == nil then Guild.Roles[i].Quota = 0 Changed = true end
    end

    if Changed then db:set(Guild,message.guild.id) end

    if args[2] == "host" then

        if permissions(message) < 1 then message.channel:send(embed.new("You lack the required permission **Officer**!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to give a **screenshot link** for event proof!")) return end

        local UserId = verified(message.author.id)

        local Role = rbx.group.getRole(Guild.GroupId,UserId)
        local User = rbx.user.getUser(UserId)

        if type(Role) ~= "table" then message.channel:send(embed.new("Something went wrong! You may not be in the group!")) return end

        if Guild.Quota[Role.rank] == nil then Guild.Quota[Role.rank] = {} end

        if Guild.Quota[Role.rank][UserId] == nil then Guild.Quota[Role.rank][UserId] = 0 end

        Guild.Quota[Role.rank][UserId] = Guild.Quota[Role.rank][UserId] + 1

        db:set(Guild,message.guild.id)

        if Guild.Settings.Quota.Channel ~= nil then client:getChannel(Guild.Settings.Quota.Channel):send(embed.new({title=User.name,description="Event Proof: "..args[3]})) end

        message.channel:send(embed.new("Event was logged!"))

    elseif args[2] == "reset" then

        if permissions(message) < 3 then message.channel:send(embed.new("You lack the required permission **HICOM**!")) return end

        Guild.Quota = {}

        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("All quota data has been reset!"))

    elseif args[2] == "check" then

        if permissions(message) < 3 then message.channel:send(embed.new("You lack the required permission **HICOM**!")) return end

        for i,v in pairs(Guild.Roles) do

            if v.Quota == 0 then goto cont end

            local PagesObj = rbx.group.getUsersInRank(Guild.GroupId,v.Id)

            while true do

                local Data = PagesObj.getPage()

                for _,vv in pairs(Data) do
                    if Guild.Quota == nil then message.channel:send(embed.new("**"..vv.username.." failed Quota! 0/"..v.Quota.."**")) goto incont end
                    if Guild.Quota[i] == nil then message.channel:send(embed.new("**"..vv.username.." failed Quota! 0/"..v.Quota.."**")) goto incont end
                    if Guild.Quota[i][vv.userId] == nil then message.channel:send(embed.new("**"..vv.username.." failed Quota! 0/"..v.Quota.."**")) goto incont end
                    if Guild.Quota[i][vv.userId] < v.Quota then message.channel:send(embed.new("**"..vv.username.." failed Quota! "..Guild.Quota[i][vv.userId].."/"..v.Quota.."**")) else message.channel:send(embed.new(vv.username.." passed Quota! "..Guild.Quota[i][vv.userId].."/"..v.Quota)) end
                    ::incont::
                end
                
                if PagesObj.isFinalPage then break end
                PagesObj.nextPage()

            end

            PagesObj = nil

            ::cont::
        end

        message.channel:send(embed.new("Quota check complete!"))

    elseif args[2] == "logs" then

        if permissions(message) < 4 then message.channel:send(embed.new("You need the permission **Owner** to use this command!")) return end

        Guild.Settings.Quota.Channel = message.channel.id

        db:set(Guild,message.guild.id)

        message.channel:send(embed.new("The host log channel has been set to this channel!"))

    else

    end

end