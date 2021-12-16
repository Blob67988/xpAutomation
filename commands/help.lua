local embed = require("../modules/embed.lua")

local commandsInfo = {

    ["demote"] = "**DESCRIPTION**\nDemotes a user.\n\n**SYNTAX**\nr!demote `<username>`\n\n**EXAMPLES**\nr!demote `Uncontained0`",
    ["help"] = "**DESCRIPTION**\nLists all commands and can get info on commands.\n\n**SYNTAX**\nr!help `[command]`\n\n**EXAMPLES**\nr!help\nr!help `xp`",
    ["permissions"] = "**DESCRIPTION**\nLists permissions and gives you the ability to change them.\n\n**SYNTAX**\nr!permissions `[add/remove]` `[level]` `[roles/users]`\n\n**EXAMPLES**\nr!permissions\nr!permissions add `hicom` `@hicomRole`\nr!permissions remove `hicom` `@hicomRole`",
    ["promote"] = "**DESCRIPTION**\nPromotes a user.\n\n**SYNTAX**\nr!promote `<username>`\n\n**EXAMPLES**\nr!promote `Uncontained0`",
    ["ranks"] = "**DESCRIPTION**\nEnables you to view the group's ranks, and make changes to their settings.\n\n**SYNTAX**\nr!ranks\nr!ranks xp `<rankid>` `<xpAmount>`\nr!ranks role `<add/remove>` `<rankid>` `<roles>`\nr!ranks prefix `<rankid>` `<prefix>`\nr!ranks unlock `<rankids>`\nr!ranks lock `<rankids>`\n\n**EXAMPLES**\nr!ranks\nr!ranks xp `4` `100`\nr!ranks role `add` `4` `@Trooper` `@LowRank`\nr!ranks prefix `4` `[T]`\nr!ranks unlock `4`\nr!ranks lock `4`",
    ["reverify"] = "**DESCRIPTION**\nLets you change the roblox account your discord account is linked to.\n\n**SYNTAX**\nr!reverify `<roblox username>`\n\n**EXAMPLES**\nr!reverify `Uncontained0`",
    ["setrank"] = "**DESCRIPTION**\nLets you set a user's rank.\n\n**SYNTAX**\nr!setrank `<rankid>` `<username>`\n\n**EXAMPLES**\nr!setrank `4` `Uncontained0`",
    ["settings"] = "**DESCRIPTION**\nLets you change and view settings about your group.\n\n**SYNTAX**\nr!settings\nr!settings verified role `<@role>`\nr!settings can demote `<true/false>`\nr!settings max change `<number>`\n\n**EXAMPLES**\nr!settings\nr!settings verified role `@verifiedRole`\nr!settings can demote `true`\nr!settings max change `20`",
    ["setup"] = "**DESCRIPTION**\nLets you setup your group. This deletes all past data. Contact support if you need to use this command without losing data.\n\n**SYNTAX**\nr!setup `<groupid>`\n\n**EXAMPLES**\nr!setup `123456`",
    ["update"] = "**DESCRIPTION**\nLets you update yourself or other users.\n\n**SYNTAX**\nr!update\nr!update `<@user>`\n\n**EXAMPLES**\nr!update\nr!update `@Uncontained`",
    ["verify"] = "**DESCRIPTION**\nLets you link your roblox account to your discord account.\n\n**SYNTAX**\nr!verify `<roblox username>`\n\n**EXAMPLES**\nr!verify `Uncontained0`",
    ["xp"] = "**DESCRIPTION**\nLets you view yours and other's xp, change user's xp, and set user's xp.\n\n**SYNTAX**\nr!xp\nr!xp `<username>`\nr!xp add/remove `<amount>` `<usernames>`\nr!xp set `<amount>` `<username>`\n\n**EXAMPLES**\nr!xp\nr!xp `Uncontained0`\nr!xp add `20` `Uncontained0` `FlamingTntNoob79`\nr!xp remove `20` `Uncontained0` `FlamingTntNoob79`\nr!xp set `20` `Uncontained0`",
    ["support"] = "**DESCRIPTION**\nGives you a link to the support server where you can contact the developers and purchase the bot.\n\n**SYNTAX**\nr!support\n\n**EXAMPLES**\nr!support",
    ["invite"] = "**DESCRIPTION**\nGives you a link to the support server where you can contact the developers and purchase the bot.\n\n**SYNTAX**\nr!invite\n\n**EXAMPLES**\nr!invte",
    ["groupbinds"] = "**DESCRIPTION**\nAllows you to view groupbinds, add groupbinds, and remove groupbinds.\n\n**SYNTAX**\nr!groupbinds\nr!groupbinds add `GroupId` `Roles`\nr!groupbinds remove `GroupId` `Roles`\n\n**EXAMPLES**\nr!groupbinds\nr!groupbinds add `123456` `@Role` `@Role`\nr!groupbinds remove `123456` `@Role` `@Role`",
    ["api"] = "**DESCRIPTION**\nAllows you to use the in-game api.\n\n**SYNTAX**\nr!api generate\nr!api enable\nr!api disable\n\n**EXAMPLES**\nr!api generate\nr!api enable\nr!api disable",
    ["medals"] = "**DESCRIPTION**\nAllows you to view, create, and grant medals.\n\n**SYNTAX**\nr!medals\nr!medals `<username>`\nr!medals list\nr!medals add `<username>` `<medal name>`\nr!medals remove `<username>` `<medal name>`\nr!medals create `<medal name>` `[medal roles]`\nr!medals delete `<medal name>`\n\n**EXAMPLES**\nr!medals\nr!medals `Uncontained0`\nr!medals list\nr!medals add `Uncontained0` `Cool Medal`\nr!medals remove `Uncontained0` `Cool Medal`\nr!medals create `Cool Medal` `@Cool-Medal-Role`\nr!medals delete `Cool Medal`",

}

return function (rbx, client, message, args)

    if args[2] ~= nil then

        if commandsInfo[args[2]] == nil then message.channel:send(embed.new("**"..args[2].."** is not a command!")) return end

        message.channel:send(embed.new({
            description = commandsInfo[args[2]],
        }))

    else

        local text = ""
        local num = 0
        for i,_ in pairs(commandsInfo) do

            num = num + 1
            text = text.." `"..i.."`"

            if num >= 3 then text = text.."\n" num = 0 end -- change 3 to be whatever #commandsInfo/4 is

        end

        message.channel:send(embed.new({
            title = "Help",
            description = text.."\n\nDo r!help `command` to view more info on a command.",
        }))

    end

end