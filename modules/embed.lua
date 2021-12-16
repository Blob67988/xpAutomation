local module = {}

local embedKeywords = {
    "title",
    "description",
    "color",
    "fields",
    "url",
    "timestamp",
    "footer",
    "image",
    "thumbnail",
    "video",
    "author",
    "provider",
}

function module.new(arg)
    local message = {}
    local embed = {}
    if type(arg) == "table" then
        for _,v in pairs(embedKeywords) do
            embed[v] = arg[v]
        end
    elseif type(arg) == "string" then
        embed["description"] = arg
    end
    embed["color"] = 15756602
    message.embed = embed
    return message
end

return module