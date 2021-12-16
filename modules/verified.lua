local db = require("./database.lua")
local http = require("coro-http")
local json = require("json")

return function (id)
    local dbData = db:get("Users")[id]
    if dbData ~= nil then return dbData end

    local rwRes,rwBody = http.request("GET","https://api.rowifi.link/v1/users/"..id)
    if rwRes.code == 200 then
        rwBody = json.decode(rwBody)
        if rwBody.success == true then
            return rwBody.roblox_id
        end
    end

    local blRes,blBody = http.request("GET","https://api.blox.link/v1/user/"..id)
    if blRes.code == 200 then
        blBody = json.decode(blBody)
        if blBody.status == "ok" then
            return blBody.primaryAccount
        end
    end

    return nil
end