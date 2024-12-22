--External
local ext_table = require("__yafla__/scripts/extended_table.lua")
local actions = require("__yafla__/scripts/actions.lua")

--Internal
local quickstart = require("__yaqsa__/scripts/quickstart.lua")

local player_functions = {}

---@param player LuaPlayer
function player_functions.give_quickstart_to_player(player)
	local inventory = player.get_main_inventory()
	if inventory == nil then
		print("Player "..player.index.." inventory is nil, giving items again in 20 ticks")
		actions.delay_action(20, player_functions.give_quickstart_to_player, player)
		return
	end

	if quickstart.quickstart.is_given_to(player.index) then
		return
	end

	inventory.clear()

	for _, v in pairs(quickstart.quickstart.get_items()) do
		if v.amount > 0 then
			inventory.insert({ name = v.name, count = v.amount })
		end
	end

	quickstart.quickstart.gave_to(player.index)
end


---@class death_quickstart_data
---@field player LuaPlayer
---@field try_again int

---@param data death_quickstart_data
function player_functions.give_death_quickstart_to_player(data)
	local inventory = data.player.get_main_inventory()
	try_again = try_again or 5

	if inventory == nil then
		if try_again <= 0 then
			print("Player "..data.player.index.." inventory was nil for too long, giving up on giving death quickstart")
			return
		end
		print("Player "..data.player.index.." inventory is nil, giving items again in 20 ticks for "..tostring(data.try_again).." more times")
		actions.delay_action(40, player_functions.give_quickstart_to_player, {player = data.player, try_again=data.try_again-1} )
		return
	end

	inventory.clear()

	for _, v in pairs(quickstart.death_quickstart.get_items()) do
		if v.amount > 0 then
			inventory.insert({ name = v.name, count = v.amount })
		end
	end
end


return player_functions
