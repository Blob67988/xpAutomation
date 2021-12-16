local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")
local verified = require("../modules/verified")
local update = require("../modules/update")

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

function Round(n, i)
	local m = 10 ^ (i or 0)
	return math.floor(n * m + 0.5) / m
end

return function (rbx, client, message, args)

    if args[2] == "add" then ------------------------------------------------------------ ADD -----------------------------------------------------------------------

        if permissions(message) < 1 then message.channel:send(embed.new("You need the permission **Officer** to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to give a **number** to add XP!")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("You need to give a **number** to add XP!")) return end

        local XPAdd = tonumber(args[3])

        local Guild = db:get(message.guild.id)

        if XPAdd > Guild.Settings.MaxChange then message.channel:send(embed.new("The requested XP change is greater than the max change of "..Guild.Settings.MaxChange)) return end

        if args[4] == nil then message.channel:send(embed.new("You need to give a user to add XP!")) return end

        table.remove(args,3)
        table.remove(args,2)
        table.remove(args,1)

        Guild = db:get(message.guild.id)

        for _,v in pairs(args) do

            local User = rbx.user.getUser(v)
            if User == nil then message.channel:send(embed.new("**"..v.."** is not a real user!")) goto cont end

            if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end

            local OldXP = Guild.Members[User.id].XP
            local NewXP = Guild.Members[User.id].XP + XPAdd

            Guild.Members[User.id].XP = NewXP

            message.channel:send(embed.new("**"..User.name..":** "..OldXP.." -> "..NewXP))

            local Role = rbx.group.getRole(Guild.GroupId,User.id)

            if Role == false then goto cont end

            if Guild.Roles[Role.rank].Locked == true then goto cont end

            local HighestRank = 0
            local HighestXP = -1
            for i,v in pairs(Guild.Roles) do

                if i == 0 then goto incont end

                if NewXP < v.XP then goto incont end

                if v.Locked then goto incont end

                if i < HighestRank then goto incont end

                HighestRank = i
                HighestXP = v.XP

                ::incont::
            end

            if HighestRank == Role.rank then goto cont end

            local success,a,b,c = rbx.group.rankUser(Guild.GroupId,User.id,HighestRank)
            if not success then message.channel:send(embed.new("**"..User.name.."** was supposed to be ranked to **"..Guild.Roles[HighestRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") goto cont end
            message.channel:send(embed.new("**"..User.name..":** "..Role.name.." -> "..Guild.Roles[HighestRank].Name))

            ::cont::
        end

        db:set(Guild,message.guild.id)

        if #args > 1 then message.channel:send(embed.new("All users have been updated.")) end

    elseif args[2] == "remove" then ------------------------------------------------------------ REMOVE -----------------------------------------------------------------------

        if permissions(message) < 1 then message.channel:send(embed.new("You need the permission **Officer** to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to give a **number** to remove XP!")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("You need to give a **number** to remove XP!")) return end

        local XPRemove = tonumber(args[3])

        local Guild = db:get(message.guild.id)

        if XPRemove > Guild.Settings.MaxChange then message.channel:send(embed.new("The requested XP change is greater than the max change of "..Guild.Settings.MaxChange)) return end

        if args[4] == nil then message.channel:send(embed.new("You need to give a user to set XP!")) return end

        table.remove(args,3)
        table.remove(args,2)
        table.remove(args,1)

        Guild = db:get(message.guild.id)

        for _,v in pairs(args) do

            local User = rbx.user.getUser(v)
            if User == nil then message.channel:send(embed.new("**"..v.."** is not a real user!")) goto cont end

            if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end

            local OldXP = Guild.Members[User.id].XP
            local NewXP = Guild.Members[User.id].XP - XPRemove

            Guild.Members[User.id].XP = NewXP

            message.channel:send(embed.new("**"..User.name..":** "..NewXP.." <- "..OldXP))

            local Role = rbx.group.getRole(Guild.GroupId,User.id)

            if Role == false then goto cont end

            if Guild.Roles[Role.rank].Locked == true then goto cont end

            local HighestRank = 0
            local HighestXP = -1
            for i,v in pairs(Guild.Roles) do

                if i == 0 then goto incont end

                if NewXP < v.XP then goto incont end

                if v.Locked then goto incont end

                if i < HighestRank then goto incont end

                HighestRank = i
                HighestXP = v.XP

                ::incont::
            end

            if HighestRank == Role.rank then goto cont end

            local success,a,b,c = rbx.group.rankUser(Guild.GroupId,User.id,HighestRank)
            if not success then message.channel:send(embed.new("**"..User.name.."** was supposed to be ranked to **"..Guild.Roles[HighestRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") goto cont end
            message.channel:send(embed.new("**"..User.name..":** "..Role.name.." -> "..Guild.Roles[HighestRank].Name))

            ::cont::
        end

        db:set(Guild,message.guild.id)

        if #args > 1 then message.channel:send(embed.new("All users have been updated.")) end

    elseif args[2] == "set" then ------------------------------------------------------------ SET -----------------------------------------------------------------------

        if permissions(message) < 2 then message.channel:send(embed.new("You need the permission **Supervisor** to use this command!")) return end

        if args[3] == nil then message.channel:send(embed.new("You need to give a **number** to set XP!")) return end
        if tonumber(args[3]) == nil then message.channel:send(embed.new("You need to give a **number** to set XP!")) return end

        local XPSet = tonumber(args[3])

        local Guild = db:get(message.guild.id)

        if args[4] == nil then message.channel:send(embed.new("You need to give a user to set XP!")) return end

        table.remove(args,3)
        table.remove(args,2)
        table.remove(args,1)

        Guild = db:get(message.guild.id)

        for _,v in pairs(args) do

            local User = rbx.user.getUser(v)
            if User == nil then message.channel:send(embed.new("**"..v.."** is not a real user!")) goto cont end

            if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end

            local OldXP = Guild.Members[User.id].XP
            local NewXP = XPSet

            Guild.Members[User.id].XP = NewXP

            message.channel:send(embed.new("**"..User.name..":** "..OldXP.." -> "..NewXP))

            local Role = rbx.group.getRole(Guild.GroupId,User.id)

            if Role == false then goto cont end

            if Guild.Roles[Role.rank].Locked == true then goto cont end

            local HighestRank = 0
            local HighestXP = -1
            for i,v in pairs(Guild.Roles) do

                if i == 0 then goto incont end

                if NewXP < v.XP then goto incont end

                if v.Locked then goto incont end

                if i < HighestRank then goto incont end

                HighestRank = i
                HighestXP = v.XP

                ::incont::
            end

            if HighestRank == Role.rank or 0 then goto cont end

            local success,a,b,c = rbx.group.rankUser(Guild.GroupId,User.id,HighestRank)
            if not success then message.channel:send(embed.new("**"..User.name.."** was supposed to be ranked to **"..Guild.Roles[HighestRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") goto cont end
            message.channel:send(embed.new("**"..User.name..":** "..Role.name.." -> "..Guild.Roles[HighestRank].Name))

            ::cont::
        end

        db:set(Guild,message.guild.id)

        if #args > 1 then message.channel:send(embed.new("All users have been updated.")) end

    elseif args[2] ~= nil then ------------------------------------------------------------ VIEW OTHER -----------------------------------------------------------------------

        local User = rbx.user.getUser(args[2])

        if User == nil then message.channel:send(embed.new("**"..args[2].."** does not exist!")) return end

        message.channel:broadcastTyping()

        local UserId = User.id

        local Guild = db:get(message.guild.id)

        local Role = rbx.group.getRole(Guild.GroupId,User.id)

        local Member = Guild.Members[UserId]

        if Member == nil then Guild.Members[UserId] = { XP = 0, Medals = {}, Blacklisted = false } db:set(Guild,message.guild.id) end

        local XP = Guild.Members[UserId].XP

        if Role == false then goto cont end

        if Guild.Roles[Role.rank].Locked == true then goto cont end

        do

            local HighestRank = 0
            local HighestXP = -1
            for i,v in pairs(Guild.Roles) do

                if i == 0 then goto incont end

                if XP < v.XP then goto incont end

                if v.Locked then goto incont end

                if i < HighestRank then goto incont end

                HighestRank = i
                HighestXP = v.XP

                ::incont::
            end

            if HighestRank == Role.rank then goto cont end

            local success,a,b,c = rbx.group.rankUser(Guild.GroupId,User.id,HighestRank)
            if not success then message.channel:send(embed.new("**"..User.name.."** was supposed to be ranked to **"..Guild.Roles[HighestRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") goto cont end
            message.channel:send(embed.new("**"..User.name..":** "..Role.name.." -> "..Guild.Roles[HighestRank].Name))

        end

        ::cont::

        local rbxRole = rbx.group.getRole(Guild.GroupId,User.id)

        if rbxRole == false then rbxRole = {rank=0} end

        local Role = Guild.Roles[rbxRole.rank]

        local NextRole
        for i=0,255 do
            if Guild.Roles[i] ~= nil and i > rbxRole.rank then NextRole = Guild.Roles[i] break end
        end
        if NextRole == nil then NextRole = {Name = "None", XP = 0, Locked = true} end

        local ProgressXP = math.abs(XP - Role.XP)
        local TotalXP = NextRole.XP - Role.XP

        if TotalXP < 0 then TotalXP = 0 end

        local RemainingXP = TotalXP - ProgressXP

        if RemainingXP < 0 then RemainingXP = 0 end

        if NextRole.Locked then RemainingXP = 0 ProgressXP = 0 end

        local Percent = (ProgressXP/TotalXP)*100

        if Percent == 1e309 or Percent ~= Percent then Percent = 100 end

        Percent = Round(Percent)

        local Tenth = Round(Percent/10)

        local FilledBar = Guild.Settings.FilledBar
        local EmptyBar = Guild.Settings.EmptyBar

        local BarText = ""

        for i=1,Tenth do
            BarText = BarText..FilledBar
        end

        for i=1,(10-Tenth) do
            BarText = BarText..EmptyBar
        end

        local Text = BarText.." **"..Percent.."%**\n\nRank: **"..Role.Name.."**\nXP: **"..XP.."\n\n"..RemainingXP.."** XP remaining for **"..NextRole.Name.."** (**"..NextRole.XP.."**)"

        local Image = rbx.user.getImage(UserId)

        message.channel:send(embed.new({
            title = User.name,
            description = Text,
            thumbnail = { url = Image },
        }))


    else

        message.channel:broadcastTyping()

        local UserId = tonumber(verified(message.author.id))

        local User = rbx.user.getUser(UserId)

        local Guild = db:get(message.guild.id)

        local Role = rbx.group.getRole(Guild.GroupId,User.id)

        local Member = Guild.Members[UserId]

        if Member == nil then Guild.Members[UserId] = { XP = 0, Medals = {}, Blacklisted = false } db:set(Guild,message.guild.id) end

        local XP = Guild.Members[UserId].XP

        if Role == false then goto cont end

        if Guild.Roles[Role.rank].Locked == true then goto cont end

        do

            local HighestRank = 0
            local HighestXP = -1
            for i,v in pairs(Guild.Roles) do

                if i == 0 then goto incont end

                if XP < v.XP then goto incont end

                if v.Locked then goto incont end

                if i < HighestRank then goto incont end

                HighestRank = i
                HighestXP = v.XP

                ::incont::
            end

            if HighestRank == Role.rank then goto cont end

            local success,a,b,c = rbx.group.rankUser(Guild.GroupId,User.id,HighestRank)
            if not success then message.channel:send(embed.new("**"..User.name.."** was supposed to be ranked to **"..Guild.Roles[HighestRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") goto cont end
            message.channel:send(embed.new("**"..User.name..":** "..Role.name.." -> "..Guild.Roles[HighestRank].Name))

        end

        ::cont::

        update.single(rbx,message.author,message.guild)

        local rbxRole = rbx.group.getRole(Guild.GroupId,User.id)

        if rbxRole == false then rbxRole = {rank=0} end

        local Role = Guild.Roles[rbxRole.rank]

        local NextRole
        for i=0,255 do
            if Guild.Roles[i] ~= nil and i > rbxRole.rank then NextRole = Guild.Roles[i] break end
        end
        if NextRole == nil then NextRole = {Name = "None", XP = 0} end

        local ProgressXP = math.abs(XP - Role.XP)
        local TotalXP = NextRole.XP - Role.XP

        if TotalXP < 0 then TotalXP = 0 end

        local RemainingXP = TotalXP - ProgressXP

        if RemainingXP < 0 then RemainingXP = 0 end

        if NextRole.Locked then RemainingXP = 0 ProgressXP = 0 end

        local Percent = (ProgressXP/TotalXP)*100

        if Percent == 1e309 or Percent ~= Percent then Percent = 100 end

        Percent = Round(Percent)

        local Tenth = Round(Percent/10)

        local FilledBar = Guild.Settings.FilledBar
        local EmptyBar = Guild.Settings.EmptyBar

        local BarText = ""

        for i=1,Tenth do
            BarText = BarText..FilledBar
        end

        for i=1,(10-Tenth) do
            BarText = BarText..EmptyBar
        end

        local Text = BarText.." **"..Percent.."%**\n\nRank: **"..Role.Name.."**\nXP: **"..XP.."\n\n"..RemainingXP.."** XP remaining for **"..NextRole.Name.."** (**"..NextRole.XP.."**)"

        local Image = rbx.user.getImage(UserId)

        message.channel:send(embed.new({
            title = User.name,
            description = Text,
            thumbnail = { url = Image },
        }))

    end

end