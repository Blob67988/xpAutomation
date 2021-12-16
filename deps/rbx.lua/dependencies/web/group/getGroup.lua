local module = {
	authenticationRequired = false;
};

function module.run(authentication,groupId)
	local endpoint = "https://groups.roblox.com/v1/groups/"..groupId;
	local response,body = api.request("GET",endpoint,{},{},authentication,false,false);
	return json.decode(body);
end

return module;