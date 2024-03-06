-- Module is SearchPlayer
-- commands are requestServerItems
--              requestClientItems
--              respondServerItems
--              respondClientItems

SearchPlayer = SearchPlayer or {}

function SearchPlayer.predicateWeapon(item)
    return item:IsWeapon()
    -- return item:IsWeapon() and item:getActualWeight() >= 1
end

function SearchPlayer.reportBeingSearched(player, otherPlayer)
    player:Say("Being searched by " .. otherPlayer:getDisplayName())
end

local function OnServerCommand(module, command, args)
    if module ~= "SearchPlayer" then
        return
    end

    if command == "requestClientItems" then
        local player = getPlayer();
        local otherPlayer = getPlayerByOnlineID(args[1])
        if not otherPlayer then
            return
        end

        local playerInv = player:getInventory();
        local weapons = playerInv:getAllEval(SearchPlayer.predicateWeapon);
        SearchPlayer.reportBeingSearched(player, otherPlayer)
        print("Found " .. weapons:size() .. " weapons");
        for i=0,weapons:size()-1 do
            local item = weapons:get(i)
            print(item:getName())
            tradingUISendAddItem(player, otherPlayer, item);
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)