local embed = require("../modules/embed.lua")
local db = require("../modules/database")
local permissions = require("../modules/permissions")

return function (rbx, client, message, args)
    if permissions(message) < 6 then return end
    local DeveloperData = db:get("DeveloperData")
    if args[2] == "whitelist" then
        if args[3] == "add" then
            DeveloperData.Whitelist[args[4]] = true
            db:set(DeveloperData,"DeveloperData")
            message.channel:send(embed.new("Developer request completed: Whitelist Add"))
        elseif args[3] == "remove" then
            DeveloperData.Whitelist[args[4]] = nil
            db:set(DeveloperData,"DeveloperData")
            message.channel:send(embed.new("Developer request completed: Whitelist Remove"))
        end
    elseif args[2] == "shutdown" then
        message.channel:send(embed.new("Developer Request Attempt: Shutting Down."))
        os.exit()
    end
end