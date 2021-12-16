local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")

return function (rbx, client, message, args)
    if permissions(message) < 4 then message.channel:send(embed.new("You need the permission **Owner** to use this command!")) return end
    local Guild = db:get(message.guild.id)
    Guild.Settings.LogsChannel = message.channel.id
    db:set(Guild,message.guild.id)
    message.channel:send(embed.new("The logs channel has been set to this channel!"))
end