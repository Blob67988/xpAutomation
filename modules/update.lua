local db = require("./database.lua")
local verified = require("./verified.lua")

function getRank (tab,id)
    for _,v in pairs(tab) do
        if v.group.id == id then return v.role.rank end
    end
    return 0
end

local ReturnTable = {}

ReturnTable.global = function (rbx, author) -- a really expensive operation
    local UserId = verified(author.id)

    if UserId == nil then return end

    local User = rbx.user.getUser(UserId)
    local Groups = rbx.user.getGroups(UserId)
    if not Groups or not User then return false end

    for _,v in pairs(author.mutualGuilds) do
        local Guild = db:get(v.id)
        if Guild == nil then goto cont end

        local Member = v:getMember(author.id)

        local Rank = getRank(Groups,Guild.GroupId)

        for i,v in pairs(Guild.Roles) do
            if i == Rank then goto incont end

            for _,v in pairs(v.Roles) do
                Member:removeRole(v)
            end

            ::incont::
        end

        for _,v in pairs(Guild.Roles[Rank].Roles) do
            Member:addRole(v)
        end

        Member:setNickname(Guild.Roles[Rank].Prefix.." "..User.name)
        Member:addRole(Guild.Settings.VerifiedRole)

        if Guild.GroupBinds == nil then return true end
        for i,v in pairs(Guild.GroupBinds) do

            local Rank = rbx.group.getRank(i,UserId)
            if Rank > 0 then 

                for i,_ in pairs(v) do

                    if tonumber(i) == nil then goto inincont end
                    Member:addRole(i)

                    ::inincont::
                end

            else

                for i,_ in pairs(v) do

                    if tonumber(i) == nil then goto inincont end
                    Member:removeRole(i)

                    ::inincont::
                end

            end

        end

        for _,v in pairs(Guild.Medals) do
            Member:removeRole(v)
        end

        if Guild.Members[UserId] == nil then Guild.Members[UserId] = {Medals = {}} end
        for i,_ in pairs(Guild.Members[UserId].Medals) do
            if Guild.Medals[i] == nil then goto incont end
            for _,v in pairs(Guild.Medals[i].Roles) do
                Member:addRole(v)
            end
            ::incont::
        end

        ::cont::
    end

    return true
end

ReturnTable.single = function (rbx, dUser, guild)

    local UserId = verified(dUser.id)
    if UserId == nil then return end

    local Guild = db:get(guild.id)
    local Rank = rbx.group.getRank(Guild.GroupId,UserId)
    local User = rbx.user.getUser(UserId)

    local Member = guild:getMember(dUser.id)

    for i,v in pairs(Guild.Roles) do
        if i == Rank then goto incont end

        for _,v in pairs(v.Roles) do
            Member:removeRole(v)
        end

        ::incont::
    end

    for _,v in pairs(Guild.Roles[Rank].Roles) do
        Member:addRole(v)
    end

    Member:setNickname(Guild.Roles[Rank].Prefix.." "..User.name)
    Member:addRole(Guild.Settings.VerifiedRole)

    if Guild.GroupBinds == nil then return true end
    for i,v in pairs(Guild.GroupBinds) do

        local Rank = rbx.group.getRank(i,UserId)
        if Rank > 0 then 

            for i,_ in pairs(v) do

                if tonumber(i) == nil then goto inincont end
                Member:addRole(i)

                ::inincont::
            end

        else

            for i,_ in pairs(v) do

                if tonumber(i) == nil then goto inincont end
                Member:removeRole(i)

                ::inincont::
            end

        end

    end

    for _,v in pairs(Guild.Medals) do
        Member:removeRole(v)
    end

    if Guild.Members[UserId] == nil then Guild.Members[UserId] = {Medals = {}} end
    for i,_ in pairs(Guild.Members[UserId].Medals) do
        if Guild.Medals[i] == nil then goto incont end
        for _,v in pairs(Guild.Medals[i].Roles) do
            Member:addRole(v)
        end
        ::incont::
    end

    return true
end

return ReturnTable