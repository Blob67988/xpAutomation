local embed = require("../modules/embed.lua")
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

function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end

return function (rbx, client, message, args)
    if permissions(message) < 6 then return end
    local DeveloperData = db:get("DeveloperData")
    if DeveloperData["Blacklist"] == nil then DeveloperData.Blacklist = {} end
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
    elseif args[2] == "dump" then
        print_table (db:get(message.guild.id))
    elseif args[2] == "blacklist" then
        if args[3] == "add" then
            DeveloperData.Blacklist[args[4]] = true
            db:set(DeveloperData,"DeveloperData")
        elseif args[3] == "remove" then
            DeveloperData.Blacklist[args[4]] = nil
            db:set(DeveloperData,"DeveloperData")
        end
    end
end