commands.add_command("chiama_comando", nil, function(command)
    if command.player_index ~= nil and command.parameter == "me" then
      game.get_player(command.player_index).print(command.tick)
    else
      game.print(command.tick)
    end
  end)