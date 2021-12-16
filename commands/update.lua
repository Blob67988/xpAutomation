local embed = require("../modules/embed")
local permissions = require("../modules/permissions")
local update = require("../modules/update")

return function (rbx, client, message, args)

    if #message.mentionedUsers > 0 then 

        local User
        for _,v in pairs(message.mentionedUsers) do
            User = v break
        end

        local Success = update.single(rbx, User, message.guild)
        if Success == nil then message.channel:send(embed.new(User.mentionString.." needs to verify before they can be updated!")) return end
        message.channel:send(embed.new(User.mentionString.." has been updated!"))

    else

        local Success = update.single(rbx, message.author, message.guild)
        if Success == nil then message.channel:send(embed.new("You need verify before you can be updated!")) return end
        message.channel:send(embed.new("You have been updated!"))

    end

end