local db = require("./database.lua")

return function (message)
    if message.author.id == "346249745590910976" then return 6 end
    if message.author.id == message.guild.ownerId then return 5 end
    local Guild = db:get(message.guild.id)
    for i,v in pairs(Guild.Permissions) do
        if i == 4 then 
            for _,UserId in pairs(v) do
                if UserId == message.author.id then return i end
            end
        else
            for _,RoleId in pairs(v) do
                if message.member:hasRole(RoleId) then return i end
            end
        end
    end
    return 0
end