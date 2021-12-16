local module = {
	authenticationRequired = false;
};

function module.run(authentication,groupid,input)
	local run = function(userId)
		if(userId ~= nil) then
			local endpoint = "https://groups.roblox.com/v2/users/"..userId.."/groups/roles";
			local response,body = api.request("GET",endpoint,{},{},authentication,false,false);

			if(response.code == 200) then
				local d =  json.decode(body)["data"];
                for _,v in pairs(d) do
                    if v.group.id == groupid then return v.role end
                end
                return false
			else 
				return false;
			end
		else
			return false
		end
	end

	return run(utility.resolveToUserId(input));
end

return module;