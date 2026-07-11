local gui = require("__yaqsa__/scripts/gui.lua")
local quick = require("__yaqsa__/scripts/quickstart.lua")
local player_functions = require("__yaqsa__/scripts/player.lua")

local function get_valid_player(command)
    if command.player_index == nil then return nil end
    return game.get_player(command.player_index)
end

local function get_admin_player(command)
    local player = get_valid_player(command)
    if not player then return nil end
    if not player.admin then
        player.print({"yaqsa-messages.not-an-admin"})
        return nil
    end
    return player
end

commands.add_command("quickstart", nil, function(command)
    local player = get_valid_player(command)
    if not player then return end
    if not quick.quickstart.is_ready() then
        player.print({"yaqsa-messages.quickstart-not-ready"})
        return
    end

    if command.parameter == "me" then
        if quick.quickstart.is_given_to(player.index) then
            player.print({"yaqsa-messages.already-received"})
            return
        end
        player_functions.give_quickstart_to_player(player)
    elseif command.parameter == "all" then
        for _, p in pairs(game.players) do
            player_functions.give_quickstart_to_player(p)
        end
    else
        player.print({"yaqsa-messages.invalid-parameters"})
    end
end)

commands.add_command("force_quickstart", nil, function(command)
    local player = get_admin_player(command)
    if not player then return end
    if not quick.quickstart.is_ready() then
        player.print({"yaqsa-messages.quickstart-not-ready"})
        return
    end

    if command.parameter == "me" then
        quick.quickstart.retract_given_to(player.index)
        player_functions.give_quickstart_to_player(player)
    elseif command.parameter == "all" then
        for _, p in pairs(game.players) do
            quick.quickstart.retract_given_to(player.index)
            player_functions.give_quickstart_to_player(p)
        end
    elseif tonumber(command.parameter) ~= nil then
        local p = game.get_player(tonumber(command.parameter))
        if p == nil then
            player.print({"yaqsa-messages.player-not-found"})
            return
        end
        quick.quickstart.retract_given_to(p.index)
        player_functions.give_quickstart_to_player(p)
    else
        player.print({"yaqsa-messages.invalid-admin-parameters"})
    end
end)

commands.add_command("edit_quickstart", nil, function(command)
    local player = get_admin_player(command)
    if not player then return end

    quick.quickstart.set_broken()
    gui.fix_quickstart_window({ player_index = player.index })

end)

commands.add_command("retract_quickstart", nil, function(command)
    local player = get_admin_player(command)
    if not player then return end

    if command.parameter == "me" then
        quick.quickstart.retract_given_to(player.index)
    elseif command.parameter == "all" then
        for _, p in pairs(game.players) do
            quick.quickstart.retract_given_to(player.index)
        end
    elseif tonumber(command.parameter) ~= nil then
        local p = game.get_player(tonumber(command.parameter))
        if p == nil then
            player.print({"yaqsa-messages.player-not-found"})
            return
        end
        quick.quickstart.retract_given_to(p.index)
    else
        player.print({"yaqsa-messages.invalid-admin-parameters"})
    end

end)

commands.add_command("no_quickstart", nil, function(command)
    local player = get_valid_player(command)
    if not player then return end

    quick.quickstart.gave_to(player.index)
    player.print({"yaqsa-messages.forfeit-quickstart"})
end)

commands.add_command("edit_death_quickstart", nil, function(command)
    local player = get_admin_player(command)
    if not player then return end

    quick.death_quickstart.set_broken()
    gui.fix_death_quickstart_window({ player_index = player.index })

end)

commands.add_command("death_quickstart", nil, function(command)
    local player = get_valid_player(command)
    if not player then return end

    player_functions.give_death_quickstart_to_player({ player = player, try_again = 5 })
end)