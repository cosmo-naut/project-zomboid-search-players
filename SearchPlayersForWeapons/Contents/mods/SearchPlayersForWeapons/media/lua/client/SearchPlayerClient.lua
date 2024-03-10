-- Module is SearchPlayer
-- commands are requestServerItems
--              requestClientItems
--              respondServerItems
--              respondClientItems

SearchPlayer = SearchPlayer or {}

function SearchPlayer.isOtherContraband(item)
    local vars = SandboxVars.SearchPlayer
    local otherContraband = vars and vars.OtherContrabandItems or ''

    local typeList = string.split(otherContraband, ';')
    local fullType = item:getFullType()
    for i = 1, #typeList do
        if fullType == string.trim(typeList[i]) then
            return true
        end
    end

    return false
end

function SearchPlayer.hasOtherContrabandConfigured()
    local vars = SandboxVars.SearchPlayer
    local value = vars and vars.OtherContrabandItems
    return value and value ~= ''
end

function SearchPlayer.predicateContraband(item)
    return item:IsWeapon() or SearchPlayer.isOtherContraband(item)
    -- return item:IsWeapon() and item:getActualWeight() >= 1
end

function SearchPlayer.reportBeingSearched(player, otherPlayer)
    player:Say(getText("UI_SearchedBy", otherPlayer:getDisplayName()))
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
        local weapons = playerInv:getAllEval(SearchPlayer.predicateContraband);
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