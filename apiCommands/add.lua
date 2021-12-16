local db = require("../modules/database")

return function (rbx, data, guildId)

    if type(data.details) ~= "table" then return end
    if tonumber(data.details.amount) == nil then return end
    if type(data.details.users) ~= "table" then return end

    local Guild = db:get(guildId)

    for _,v in pairs(data.details.users) do
        local User = rbx.user.getUser(v)
        if User == nil then goto cont end -- not a real user

        if Guild.Members[User.id] == nil then Guild.Members[User.id] = { XP = 0, Medals = {}, Blacklisted = false } end -- create new profile

        local NewXP = Guild.Members[User.id].XP + tonumber(data.details.amount)

        Guild.Members[User.id].XP = NewXP

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

        ::cont::
    end

    db:set(Guild,guildId)

end