local embed = require("../modules/embed.lua")
local db = require("../modules/database")
local permissions = require("../modules/permissions")

function GenerateKey ()
    local Key = ""
    math.randomseed(os.time())
    for i=1,65 do
        Key = Key..string.char(math.random(97,122))
    end
    return Key
end

return function (rbx, client, message, args)

    if permissions(message) < 5 then message.channel:send(embed.new("You do not have the required permissions to use this command!")) return end

    local Guild = db:get(message.guild.id)

    if args[2] == "enable" then

        if Guild.API.Key == "" then message.channel:send(embed.new("You need to generate a APIKey before you can enabled the API.")) return end

        Guild.API.Enabled = true
        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("The API has been enabled."))

    elseif args[2] == "generate" then

        local KeyList = db:get("APIKeys")

        local Key = ""
        while true do
            Key = GenerateKey()
            if KeyList[Key] == nil then KeyList[Key] = message.guild.id break end
        end

        db:set(KeyList, "APIKeys")
        message.channel:send(embed.new("Your API Key has been sent to you! **Be careful who you share this with, as it gives them unlimited access to add and remove XP.**"))
        message.author:send(Key)

    elseif args[2] == "disable" then

        Guild.API.Enabled = true
        db:set(Guild,message.guild.id)
        message.channel:send(embed.new("The API has been enabled."))

    end

end