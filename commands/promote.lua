local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")
local verified = require("../modules/verified")

return function (rbx, client, message, args)

    if permissions(message) < 2 then message.channel:send(embed.new("You need permission **Supervisor** to use this command!")) return end

    if args[2] == nil then message.channel:send(embed.new("Give a **username** to promote them!")) return end

    local UserId = verified(message.author.id)

    local User = rbx.user.getUser(UserId)

    local Guild = db:get(message.guild.id)

    local UserRole = rbx.group.getRole(Guild.GroupId,UserId)
    if UserRole == false then message.channel:send(embed.new("You need to be in the group to use this command!")) return end

    local TargetUser = rbx.user.getUser(args[2])
    if TargetUser == nil then message.channel:send(embed.new("**"..args[2].."** is not a real user!")) return end

    if TargetUser.id == User.id then message.channel:send(embed.new("You cannot promote yourself!")) return end

    local TargetRole = rbx.group.getRole(Guild.GroupId,TargetUser.id)
    if TargetRole == false then message.channel:send(embed.new("**"..TargetUser.name.."** is not in the group!")) return end

    if TargetRole.rank > UserRole.rank then message.channel:send(embed.new("**"..TargetUser.name.."** is a higher rank than you!")) return end
    if TargetRole.rank == UserRole.rank then message.channel:send(embed.new("**"..TargetUser.name.."** is the same rank than you!")) return end
    
    local SetRank = 0

    for i = TargetRole.rank,255 do

        if Guild.Roles[i] == nil or i == TargetRole.rank then goto cont end
        SetRank = i
        break

        ::cont::

    end

    if SetRank > UserRole.rank then message.channel:send(embed.new("You cannot promote someone to a rank higher than your own!")) return end

    if setRank == UserRole.rank then message.channel:send(embed.new("You cannot promote someone to your own rank!")) return end

    local success,a,b,c = rbx.group.rankUser(Guild.GroupId,TargetUser.id,SetRank)
    if not success then message.channel:send(embed.new("**"..TargetUser.name.."** was supposed to be ranked to **"..Guild.Roles[SetRank].Name.."** but the operation failed!")) print("ERROR WHILE RANKING") return end
    message.channel:send(embed.new("**"..TargetUser.name..":** "..TargetRole.name.." -> "..Guild.Roles[SetRank].Name))

end