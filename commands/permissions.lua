local embed = require("../modules/embed")
local db = require("../modules/database")
local permissions = require("../modules/permissions")

function Dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. Dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function find (table,value)
    for i,v in ipairs(table) do
        if v == value then return i end
    end
end

return function (rbx, client, message, args)
    local Guild = db:get(message.guild.id)
    if args[2] == "add" then --------------------------------------------------------- ADD SECTION ------------------------------------------------------------
        if args[3] == "owner" then ----------------------------------------------- OWNER ---------------------------------------------------------------
            if permissions(message) < 5 then message.channel:send(embed.new("You must be the server owner to use this command!")) return end

            local MentionedUsers = message.mentionedUsers

            if #MentionedUsers < 1 then message.channel:send(embed.new("You need to mention a **user** to add them to the `Owner` permission.")) return end
            for _,v in pairs(MentionedUsers) do
                if find(Guild.Permissions[4],v.id) then message.channel:send(embed.new(v.mentionString.." already had the permission `Owner`.")) goto cont end
                table.insert(Guild.Permissions[4],v.id)
                message.channel:send(embed.new(v.mentionString.." has been added to the `Owner` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedUsers > 1 then message.channel:send(embed.new("All users have been added to the `Owner` permission.")) return end
        elseif args[3] == "hicom" then ------------------------------------------- HICOM -----------------------------------------------------------
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end
            
            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to add them to the `HICOM` permission.")) return end
            for _,v in pairs(MentionedRoles) do
                if find(Guild.Permissions[3],v.id) then message.channel:send(embed.new(v.mentionString.." already had the permission `HICOM`.")) goto cont end
                table.insert(Guild.Permissions[3],v.id)
                message.channel:send(embed.new(v.mentionString.." has been added to the `HICOM` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been added to the `HICOM` permission.")) return end
        elseif args[3] == "supervisor" then -------------------------------------- SUPERVISOR --------------------------------------------------------
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end
            
            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to add them to the `Supervisor` permission.")) return end
            for _,v in pairs(MentionedRoles) do
                if find(Guild.Permissions[2],v.id) then message.channel:send(embed.new(v.mentionString.." already had the permission `Supervisor`.")) goto cont end
                table.insert(Guild.Permissions[2],v.id)
                message.channel:send(embed.new(v.mentionString.." has been added to the `Supervisor` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been added to the `Supervisor` permission.")) return end
        elseif args[3] == "officer" then ---------------------------------------------- OFFICER ---------------------------------------------------------
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end
            
            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to add them to the `Officer` permission.")) return end
            for _,v in pairs(MentionedRoles) do
                if find(Guild.Permissions[1],v.id) then message.channel:send(embed.new(v.mentionString.." already had the permission `Officer`.")) goto cont end
                table.insert(Guild.Permissions[1],v.id)
                message.channel:send(embed.new(v.mentionString.." has been added to the `Officer` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been added to the `Officer` permission.")) return end
        else
            message.channel:send(embed.new("You need to give a valid permission level."))
        end
    elseif args[2] == "remove" then ------------------------------------------- REMOVE SECTION -----------------------------------------------------------------
        if args[3] == "owner" then ------------------------------------------- OWNER ---------------------------------------------------------------
            if permissions(message) < 5 then message.channel:send(embed.new("You must be the server owner to use this command!")) return end

            local MentionedUsers = message.mentionedUsers

            if #MentionedUsers < 1 then message.channel:send(embed.new("You need to mention a **user** to remove them from the `Owner` permission.")) return end
            for _,v in pairs(MentionedUsers) do
                local Index = find(Guild.Permissions[4],v.id)
                if Index == nil then message.channel:send(embed.new(v.mentionString.." did not have the permission `Owner`.")) goto cont end
                table.remove(Guild.Permissions[4],Index)
                message.channel:send(embed.new(v.mentionString.." has been removed from the `Owner` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedUsers > 1 then message.channel:send(embed.new("All users have been removed from the `Owner` permission.")) return end
        elseif args[3] == "hicom" then
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end

            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to remove them from the `HICOM` permisssion.")) return end
            for _,v in pairs(MentionedRoles) do
                local Index = find(Guild.Permissions[3],v.id)
                if Index == nil then message.channel:send(embed.new(v.mentionString.." did not have the permission `HICOM`.")) goto cont end
                table.remove(Guild.Permissions[3],Index)
                message.channel:send(embed.new(v.mentionString.." has been removed from the `HICOM` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been removed from the `HICOM` permission.")) return end
        elseif args[3] == "supervisor" then
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end

            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to remove them from the `Supervisor` permisssion.")) return end
            for _,v in pairs(MentionedRoles) do
                local Index = find(Guild.Permissions[2],v.id)
                if Index == nil then message.channel:send(embed.new(v.mentionString.." did not have the permission `Supervisor`.")) goto cont end
                table.remove(Guild.Permissions[2],Index)
                message.channel:send(embed.new(v.mentionString.." has been removed from the `Supervisor` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been removed from the `Supervisor` permission.")) return end
        elseif args[3] == "officer" then
            if permissions(message) < 4 then message.channel:send(embed.new("You need the permission `Owner` to use this command.")) return end

            local MentionedRoles = message.mentionedRoles

            if #MentionedRoles < 1 then message.channel:send(embed.new("You need to mention a **role** to remove them from the `Officer` permisssion.")) return end
            for _,v in pairs(MentionedRoles) do
                local Index = find(Guild.Permissions[1],v.id)
                if Index == nil then message.channel:send(embed.new(v.mentionString.." did not have the permission `Officer`.")) goto cont end
                table.remove(Guild.Permissions[1],Index)
                message.channel:send(embed.new(v.mentionString.." has been removed from the `Officer` permission."))
                ::cont::
            end
            db:set(Guild,message.guild.id)
            if #MentionedRoles > 1 then message.channel:send(embed.new("All roles have been removed from the `Officer` permission.")) return end
        else
            message.channel:send(embed.new("You need to give a valid permission level.")) 
        end
    else
        local OwnerVal = ""
        local HicomVal = ""
        local SuperVal = ""
        local OfficVal = ""
        for _,v in pairs(Guild.Permissions[4]) do
            OwnerVal = OwnerVal.."<@"..v..">\n"
        end
        for _,v in pairs(Guild.Permissions[3]) do
            HicomVal = HicomVal.."<@&"..v..">\n"
        end
        for _,v in pairs(Guild.Permissions[2]) do
            SuperVal = SuperVal.."<@&"..v..">\n"
        end
        for _,v in pairs(Guild.Permissions[1]) do
            OfficVal = OfficVal.."<@&"..v..">\n"
        end
        if OwnerVal == "" then OwnerVal = "None" end
        if HicomVal == "" then HicomVal = "None" end
        if SuperVal == "" then SuperVal = "None" end
        if OfficVal == "" then OfficVal = "None" end
        local Fields = {
            {
                name = "Owner",
                value = OwnerVal,
            },
            {
                name = "HICOM",
                value = HicomVal,
            },
            {
                name = "Supervisor",
                value = SuperVal,
            },
            {
                name = "Officer",
                value = OfficVal,
            },
        }
        message.channel:send(embed.new({title = "Permissions", fields = Fields}))
    end
end