local gui = require("__yaqsa__/scripts/gui.lua")
local quick = require("__yaqsa__/scripts/quickstart.lua")
local player_functions = require("__yaqsa__/scripts/player.lua")

commands.add_command("quickstart", nil, function(command)
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end
    if not quick.quickstart.is_ready() then
        player.print("Quickstart is not ready")
        return
    end

    if command.parameter == "me" then
        if quick.quickstart.is_given_to(player.index) then
            player.print("You already received the quickstart items")
            return
        end
        player_functions.give_quickstart_to_player(player)
    elseif command.parameter == "all" then
        for _, p in pairs(game.players) do
            player_functions.give_quickstart_to_player(p)
        end
    else
        player.print("Only 'me' and 'all' are valid parameters")
    end
end)

commands.add_command("force_quickstart", nil, function(command)
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end
    if not quick.quickstart.is_ready() then
        player.print("Quickstart is not ready")
        return
    end

    if not player.admin then
        player.print("You are not an admin")
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
            player.print("Player not found")
            return
        end
        quick.quickstart.retract_given_to(p.index)
        player_functions.give_quickstart_to_player(p)
    else
        player.print("Only 'me' and 'all' and player_indexes are valid parameters")
    end
end)

commands.add_command("edit_quickstart", nil, function(command)
    if command.player_index == nil then
        return
    end
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end
    if not player.admin then
        player.print("You are not an admin")
        return
    end

    quick.quickstart.set_broken()
    gui.fix_quickstart_window({ player_index = player.index })

end)

commands.add_command("retract_quickstart", nil, function(command)
    if command.player_index == nil then
        return
    end
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end
    if not player.admin then
        player.print("You are not an admin")
        return
    end

    if command.parameter == "me" then
        quick.quickstart.retract_given_to(player.index)
    elseif command.parameter == "all" then
        for _, p in pairs(game.players) do
            quick.quickstart.retract_given_to(player.index)
        end
    elseif tonumber(command.parameter) ~= nil then
        local p = game.get_player(tonumber(command.parameter))
        if p == nil then
            player.print("Player not found")
            return
        end
        quick.quickstart.retract_given_to(p.index)
    else
        player.print("Only 'me' and 'all' and player_indexes are valid parameters")
    end

end)

commands.add_command("no_quickstart", nil, function(command)
    if command.player_index == nil then
        return
    end
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end

    quick.quickstart.gave_to(player.index)
    player.print("You will not receive the quickstart items")

end)

commands.add_command("edit_death_quickstart", nil, function(command)
    if command.player_index == nil then
        return
    end
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end

    if not player.admin then
        player.print("You are not an admin")
        return
    end

    -- quick.death_quickstart.set_broken()
    player.print("Death quickstart is still not available")
    -- gui.fix_death_quickstart_window({ player_index = player.index })

end)

commands.add_command("death_quickstart", nil, function(command)
    if command.player_index == nil then
        return
    end
    local player = game.get_player(command.player_index)
    if player == nil then
        return
    end

    player.print("Death quickstart is still not available")
    -- player_functions.give_death_quickstart_to_player({ player = player, try_again = 5 })
end)