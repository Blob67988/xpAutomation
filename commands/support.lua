local embed = require("../modules/embed.lua")

return function (rbx, client, message, args)

    message.channel:send(embed.new({
        title = "Support Server",
        description = "Join [this support server](https://discord.gg/MB38a5xKWQ) to get help or purchase the bot."
    }))

end