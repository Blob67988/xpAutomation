local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")
local verified = require("../modules/verified")

return function (rbx, client, message, args)

    if permissions(message) < 3 then message.channel:send(embed.new("You need permission **HICOM** to use this command!")) return end

    if tonumber(args[2]) == nil then message.channel:send(embed.new("Give a **number** to set someone's rank!")) return end

    if args[3] == nil then message.channel:send(embed.new("Give a **username** to set someone's rank!")) return end

    local UserId = verified(message.author.id)

    local User = rbx.user.getUser(UserId)

    local Guild = db:get(message.guild.id)

    local Role = rbx.group.getRole(Guild.GroupId,UserId)

    if Role == false then message.channel:send(embed.new("You need to be in the group to use this command!")) return end

    local Target = rbx.user.getUser(args[3])

    if Target == nil then message.channel:send(embed.new("**"..args[3].."** is not a real user!")) return end

    local TargetRole = rbx.group.getRole(Guild.GroupId,Target.id)

    if TargetRole == false then message.channel:send(embed.new("**"..Target.name.."** is not in the group!")) return end

    if TargetRole.rank > Role.rank then message.channel:send(embed.new("**"..Target.name.."** is a higher rank than you!")) return end

    if Guild.Roles[tonumber(args[2])] == nil then message.channel:send(embed.new("**"..args[2].."** is not valid rank!")) return end

    if tonumber(args[2]) >= Role.rank then message.channel:send(embed.new("You cannot rank someone higher than or equal to you!")) return end

    if Target.id == UserId then message.channel:send(embed.new("You cannot set your own rank!")) return end

    local success,a,b,c = rbx.group.rankUser(Guild.GroupId,Target.id,tonumber(args[2]))
    if not success then message.channel:send(embed.new("**"..Target.name.."** was supposed to be ranked to **"..Guild.Roles[tonumber(args[2])].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") return end
    message.channel:send(embed.new("**"..Target.name..":** "..TargetRole.name.." -> "..Guild.Roles[tonumber(args[2])].Name))

end