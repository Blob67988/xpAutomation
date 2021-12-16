local embed = require("../modules/embed.lua")

return function (rbx, client, message, args)

    message.channel:send(embed.new({
        title = "Invite xpAutomations",
        description = "You can invite the bot [here](https://discord.com/api/oauth2/authorize?client_id=852407625840328704&permissions=8&scope=bot). Join [this support server](https://discord.gg/MB38a5xKWQ) to purchase the bot."
    }))

end