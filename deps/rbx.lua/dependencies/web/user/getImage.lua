local endpoint = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=1&size=150x150&format=Png&isCircular=false"

local module = {
	authenticationRequired = false;
};

function module.run(authentication,input)
	local run = function(userId)
		if(userId ~= nil) then 
			local endpoint = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png&isCircular=false"
			local response,body = api.request("GET",endpoint,{},{},authentication,false,false);
			if(response.code == 200) then 
				return (json.decode(body)["data"][1]["imageUrl"]);
			else 
				return nil -- added
			end
		else
			return nil -- added
		end
	end

	return run(utility.resolveToUserId(input))
end

return module;