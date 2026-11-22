--External
local actions = require("__yafla__/scripts/actions.lua")
local ext_table = require("__yafla__/scripts/extended_table.lua")

--Internal
local yaqsa_gui = require("__yaqsa__/scripts/gui.lua")
local player_functions = require("__yaqsa__/scripts/player.lua")
local quick = require("__yaqsa__/scripts/quickstart.lua")
local commands = require("__yaqsa__/scripts/commands.lua")


--[[
	if mods...
--]]

local migrations = {}


if storage.first_cutscene == nil then
    log("[YAQSA] Initializing first_cutscene storage flag.")
    storage.first_cutscene = true
end

local on_player_created = function(event)
    if event.player_index ~= 1 then
        local player = game.get_player(event.player_index)
        if not player then return end
        if quick.quickstart.is_ready() then
            actions.delay_action(5, player_functions.give_quickstart_to_player, player)
        else
            player.get_main_inventory().clear()
        end
    else
        yaqsa_gui.quickstart_window(event)
    end
end

local on_cutscene_ended = function(event)
    if not storage.first_cutscene then return end
    on_player_created(event)
    storage.first_cutscene = false
end

local on_player_joined_game = function(event)
    if quick.quickstart.is_ready() then
        return
    end

    local player = game.get_player(event.player_index)
    if not player then return end


    if player.admin then
        yaqsa_gui.quickstart_window({ player_index = player.index })
    end

    if quick.quickstart.is_given_to(player.index) then
        player.print("[YAQSA] Warning the quickstart is not configured, please ask an admin to join to fix the problem.")
    else
        player.print("[YAQSA] Warning the quickstart is not configured, when configured you will lose your inventory, " ..
        player.name .. " ask an admin to join to fix the problem!")
        player.print("[YAQSA] If you don't want the quickstart type in chat /noquickstart")
    end
end

local on_player_respawned = function(event)
    if not quick.death_quickstart.is_ready() then
        return
    end
    log("[YAQSA] Player respawned, triggering death quickstart.")
    player_functions.give_death_quickstart_to_player({ player = game.get_player(event.player_index), try_again = 5 })
end

local function filter_missing_items(quickstart_module, prototype_items)
    local removed_any = false
    for _, v in pairs(quickstart_module.get_items()) do
        if not prototype_items[v.name] then
            quickstart_module.remove_broken_item(v.name)
            removed_any = true
        end
    end
    if removed_any then
        quickstart_module.set_broken()
    end
    return removed_any
end

local on_configuration_changed = function(event)
    local prototype_items = prototypes.item
    local quickstart_broken = filter_missing_items(quick.quickstart, prototype_items)
    filter_missing_items(quick.death_quickstart, prototype_items)

    if not quickstart_broken then
        return
    end

    for _, player in pairs(game.players) do
        if player.connected and player.admin then
            yaqsa_gui.fix_quickstart_window({ player_index = player.index })
            -- yaqsa_gui.fix_death_quickstart_window({ player_index = player.index })
            return
        end
    end
end

local on_load = function(event)
    -- to fix storage stuff maybe
end

-- First quickstart editor
script.on_event(defines.events.on_cutscene_cancelled, on_cutscene_ended)
script.on_event(defines.events.on_cutscene_finished, on_cutscene_ended)

-- Auto quickstart editor
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

-- Quickstart
script.on_event(defines.events.on_player_created, on_player_created)

-- Death quickstart
script.on_event(defines.events.on_player_respawned, on_player_respawned)

-- script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
