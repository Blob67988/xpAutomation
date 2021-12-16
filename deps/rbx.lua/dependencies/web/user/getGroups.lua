local module = {
	authenticationRequired = false;
};

function module.run(authentication,input)
	local run = function(userId)
		if(userId ~= nil) then
			local endpoint = "https://groups.roblox.com/v2/users/"..userId.."/groups/roles";
			local response,body = api.request("GET",endpoint,{},{},authentication,false,false);

			if(response.code == 200) then
				return json.decode(body)["data"];
			else 
				return false;
			end
		else
			logger:log(1,"Invalid int provided for `userId`")
		end
	end

	return run(utility.resolveToUserId(input));
end

return module;