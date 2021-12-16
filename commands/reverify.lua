local embed = require("../modules/embed.lua")
local db = require("../modules/database")
local verified = require("../modules/verified")
local update = require("../modules/update")

local CodeOptions = {
    "World",
    "Red",
    "Grey",
    "Blue",
    "Orange",
    "Apple",
    "Add",
    "Bear",
    "Dog",
    "Horse",
    "Tomato",
    "Potato",
    "Color",
    "Sky",
    "Water",
    "Drain",
    "Great",
    "Bad",
    "Nice",
    "Pop",
    "Loop",
    "Return",
    "String",
    "End",
    "Time",
    "Supercalifragilisticexpialidocious",
}

return function (rbx, client, message, args)
    if args[2] == nil then message.channel:send(embed.new("You need to give a username to verify!")) return end
    local User = rbx.user.getUser(args[2])
    if User["errors"] ~= nil then message.channel:send(embed.new("User `"..args[2].."` does not exist!")) return end

    local Code = ""
    for i=1,8 do
        if i == 8 then Code = Code..CodeOptions[math.random(1,#CodeOptions)] break end
        Code = Code..CodeOptions[math.random(1,#CodeOptions)].." "
    end

    message.channel:send(embed.new({title="Verify",description="Go to your [profile](https://www.roblox.com/users/"..User.id.."/profile) and change your about section to:\n`"..Code.."` and type **done** when you finish."}))
    local Reply, mess = client:waitFor("messageCreate",60000,function(mess)
        return (mess.author == message.author and mess.channel == message.channel)
    end)
    if not Reply then message.channel:send(embed.new("Prompt timeout!")) return end
    if mess.content ~= "done" then message.channel:send(embed.new("Prompt cancelled!")) return end
    User = rbx.user.getUser(User.id)
    if User.description ~= Code then message.channel:send(embed.new("The user description does not match!")) return end
    local Users = db:get("Users")
    Users[message.author.id] = User.id
    db:set(Users,"Users")
    message.channel:send(embed.new("You were successfully verified as **"..User.name.."**!"))
    update.global(rbx, message.author)
end