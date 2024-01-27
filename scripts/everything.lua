local yafla_gui_builder = require("__yafla__/scripts/experimental/gui_builder.lua")
local yafla_gui_components = require("__yafla__/scripts/experimental/gui_components.lua")
local ext_table = require("__yafla__/scripts/extended_table.lua")
local actions = require("__yafla__/scripts/actions.lua")

local presets = {
	Belt = {
		Small = {
			{"transport-belt", 200},
			{"underground-belt", 50},
			{"splitter", 50},
		},
		Medium = {
			{"transport-belt", 400},
			{"underground-belt", 100},
			{"splitter", 100},
		},
		Big = {
			{"transport-belt", 800},
			{"underground-belt", 200},
			{"splitter", 200},
		},
	},
	Power = {
		Small = {
			{"small-electric-pole", 100},
		},
		Medium = {
			{"medium-electric-pole", 150},
		},
		Big = {
			{"medium-electric-pole", 200},
			{"big-electric-pole", 50},
		},
	},
	Constructions = {
		Small = {
			{"construction-robot", 10},
			{"personal-roboport-equipment", 1},
			{"modular-armor", 1},
			{"solar-panel-equipment", 7},
			{"battery-equipment", 2},
		},
		Medium = {
			{"construction-robot", 20},
			{"personal-roboport-equipment", 2},
			{"power-armor", 1},
			{"solar-panel-equipment", 16},
			{"battery-equipment", 4},
		},
		Big = {
			{"construction-robot", 40},
			{"personal-roboport-equipment", 4},
			{"power-armor", 1},
			{"fusion-reactor-equipment", 1},
			{"battery-mk2-equipment", 4},
		},
	},
	Personal_transport = {
		Basic = {
			{"car", 1}
		},
		Medium = {
			{"power-armor", 1},
			{"solar-panel-equipment", 14},
			{"exoskeleton-equipment", 2}
		},
		Advanced = {
			{"spidertron", 1}
		}
	},
	--[[
		Trains = {
			
		},
		Weapons = {
			
		},
	--]]
}

--[[
	if mods...
--]]

local migrations = {}

if not global.given_quickstart then
	global.given_quickstart = {}
end
--TODO populate default quickstart
if not global.default_quickstart then
	global.quickstart_ready = {}
end
if not global.quickstart then
	global.quickstart = {}
end
if not global.quickstart_ready then
	global.quickstart_ready = false
end
if not global.quickstart_broken then
	global.quickstart_broken = false
end

local function item_preset_element(item, quantity)
	return SPRITE_BUTTON {
		sprite = "item/"..item,
		tooltip = { "quick-start-popup.add-item-to-quickstart" },
		on_click = "add_element",
		LABEL {
			name = item,
			position = defines.relative_gui_position.left,
			vertically_scretchable = true,
			ignored_by_interaction = true,
			caption = tostring(quantity),
			style = "bold_label",
		}
	}
end

local function item_preset_row(items)
	local out = {}
	for _, v in pairs(items) do
		table.insert(out, item_preset_element(v[1], v[2]))
	end
	return FLOW {
		out
	}
end

local function item_preset_row_panel(items)
	local number_of_elements = #items

	local rows_pane = {
		vertical_scroll_policy = 'always',
		horizontal_scroll_policy = 'never',
		horizontally_stretchable = true,
		vertically_scretchable = true,
		margin = 0,
		padding = 0,
	}

	for i = 1, math.floor(number_of_elements / 10) do
		table.insert(rows_pane, item_preset_row(ext_table.slice(items, i, i*10)))
	end

	local n_elements = number_of_elements % 10
	if number_of_elements % 10 ~= 0 then
		table.insert(rows_pane, item_preset_row(ext_table.slice(items, number_of_elements-n_elements, number_of_elements)))
	end

	return rows_pane
end

local function update_label(elements)
	local label = elements.parent.children[1].children[3]
	local close_button = elements.parent.parent.parent.children[1].children[#elements.parent.parent.parent.children[1].children]
	close_button.enabled = true
	local space_used = 0
	for _, flow in pairs(elements.children) do
		for _, element in pairs(flow.children) do
			if element.children[1].elem_value then
				local quantity = tonumber(element.children[2].text) or 0
				space_used = space_used + math.ceil(quantity/game.item_prototypes[element.children[1].elem_value].stack_size)
			end
		end
	end
	local inv_size = #game.get_player(1).get_main_inventory()
	label.caption = tostring(inv_size).."/"..tostring(space_used)
	if space_used > inv_size then
		label.caption = "[color=red]"..label.caption.."[/color]"
		close_button.enabled = false
	elseif space_used == inv_size then
		label.caption = "[color=blue]"..label.caption.."[/color]"
	end
end

local function give_items_to_player(player)
	local inventory = player.get_main_inventory()
	inventory.clear()
	if ext_table.is_present(global.given_quickstart, player.index) then
		return
	end
	table.insert(global.given_quickstart, player.index)
	for _, v in pairs(global.quickstart) do
		if v.count == nil or v.count <= 0 then
			goto next_item
		end
		inventory.insert({name=v.name, count=v.count})
		::next_item::
	end
end

local function update_all_elements(self)
	local player = game.get_player(1)
	local inventory = player.get_main_inventory()

	for _, flow in pairs(self.scroll_pane.children) do
		for _, element in pairs(flow.children) do
			element.children[1].elem_value = nil
			element.children[2].text = ''
			element.children[2].enabled = false
		end
	end

	if global.quickstart_broken then
		local counter = 1
		for _, flow in pairs(self.scroll_pane.children) do
			for _, element in pairs(flow.children) do
				if counter > #global.quickstart then
					goto update_label_and_quit
				end
				element.children[1].elem_value = global.quickstart[counter].name
				element.children[2].text = tostring(global.quickstart[counter].count)
				element.children[2].enabled = true
				counter = counter+1
			end
		end
	else
		for item, count in pairs(inventory.get_contents()) do
			for _, flow in pairs(self.scroll_pane.children) do
				for _, element in pairs(flow.children) do
					if not element.children[1].elem_value then
						element.children[1].elem_value = item
						element.children[2].text = tostring(count)
						element.children[2].enabled = true
						goto next_item
					elseif item == element.children[1].elem_value then
						element.children[2].text = tostring(tonumber(element.children[2].text)+count)
						goto next_item
					end
				end
			end
			::next_item::
		end
		inventory.clear()
	end
	::update_label_and_quit::
	update_label(self.scroll_pane)
end

local update_element = function(event)
	local chose_button = event.element
	local textfield = event.element.parent.children[#event.element.parent.children]

	if chose_button.elem_value then
		--https://lua-api.factorio.com/latest/classes/LuaItemPrototype.html#stack_size
		textfield.text = tostring(game.item_prototypes[chose_button.elem_value].stack_size)
		textfield.enabled = true
	else
		textfield.text = ''
		textfield.enabled = false
	end

	update_label(event.element.parent.parent.parent)
end

local reset_all_elements = function(event)
	local elements_frame = event.element.parent.parent.children[#event.element.parent.parent.children]
	if global.default_quickstart == {} then
		for _, flow in pairs(elements_frame.children) do
			for _, element in pairs(flow.children) do
				element.children[1].elem_value = nil
				element.children[2].text = ''
				element.children[2].enabled = false
			end
		end
	else
		for _, preset_element in pairs(global.default_quickstart) do
			for _, flow in pairs(elements_frame.children) do
				for _, element in pairs(flow.children) do
					if not element.children[1].elem_value then
						element.children[1].elem_value = preset_element[1]
						element.children[2].text = tostring(preset_element[2])
						element.children[2].enabled = true
						goto next_preset_element
					elseif preset_element[1] == element.children[1].elem_value then
						element.children[2].text = tostring(tonumber(element.children[2].text)+preset_element[2])
						goto next_preset_element
					end
				end
			end
			::next_preset_element::
		end
	end
	update_label(elements_frame)
end

local update_preset = function(event)
	local scroll_pane = event.element.parent.parent.children[#event.element.parent.parent.children]
	scroll_pane.destroy()
	yafla_gui_builder.build(
		event.element.parent.parent,
		SCROLL_PANE(item_preset_row_panel(presets[event.element.name][event.element.items[event.element.selected_index]]))
	)
end

local text_updated = function(event)
	update_label(event.element.parent.parent.parent)
end

local add_all_elements = function(event)
	local elements_frame = event.element.parent.parent.parent.parent.children[1].children[2]
	local dropdown = event.element.parent.children[#event.element.parent.children]
	local this_preset = presets[dropdown.name][dropdown.items[dropdown.selected_index]]

	for _, preset_element in pairs(this_preset) do
		for _, flow in pairs(elements_frame.children) do
			for _, element in pairs(flow.children) do
				if not element.children[1].elem_value then
					element.children[1].elem_value = preset_element[1]
					element.children[2].text = tostring(preset_element[2])
					element.children[2].enabled = true
					goto next_preset_element
				elseif preset_element[1] == element.children[1].elem_value then
					element.children[2].text = tostring(tonumber(element.children[2].text)+preset_element[2])
					goto next_preset_element
				end
			end
		end
		::next_preset_element::
	end

	update_label(elements_frame)
end

local add_element = function(event)
	local elements_frame = event.element.parent.parent.parent.parent.parent.children[1].children[2]
	for _, flow in pairs(elements_frame.children) do
		for _, element in pairs(flow.children) do
			if not element.children[1].elem_value then
				element.children[1].elem_value = event.element.children[1].name
				element.children[2].text = event.element.children[1].caption
				element.children[2].enabled = true
				update_label(elements_frame)
				return
			end
			if event.element.children[1].name == element.children[1].elem_value then
				element.children[2].text = tostring(tonumber(element.children[2].text)+tonumber(event.element.children[1].caption))
				update_label(elements_frame)
				return
			end
		end
	end
end

local give_items_to_players = function(event)
	local elements_frame = event.element.parent.parent.children[2].children[1].children[2]
	for _, flow in pairs(elements_frame.children) do
		for _, element in pairs(flow.children) do
			if element.children[1].elem_value then
				for _, v in pairs(global.quickstart) do
					if v.name == element.children[1].elem_value then
						v.count = v.count + tonumber(element.children[2].text)
						goto next_element
					end
				end
				table.insert(global.quickstart, {name = element.children[1].elem_value, count = tonumber(element.children[2].text)})
				::next_element::
			end
		end
	end
	global.quickstart_ready = true
	global.quickstart_broken = false
	for _, v in pairs(game.players) do
		for _, p in pairs(global.given_quickstart) do
			if p == v.index then
				goto next_player
			end
		end
		give_items_to_player(v)
		::next_player::
	end
	event.element.parent.parent.destroy()
end

yafla_gui_builder.register_handler("add_element", add_element)
yafla_gui_builder.register_handler("text_updated", text_updated)
yafla_gui_builder.register_handler("update_preset", update_preset)
yafla_gui_builder.register_handler("update_element", update_element)
yafla_gui_builder.register_handler("add_all_elements", add_all_elements)
yafla_gui_builder.register_handler("reset_all_elements", reset_all_elements)
yafla_gui_builder.register_handler("give_items_to_players", give_items_to_players)

local function item_selector_element()
	local out = {
		FRAME {
			direction = "vertical",
			margin = 1,
			padding = 0,
			--height = 68
			--width = 50
			CHOOSE_ELEM_BUTTON {
				elem_type = "item",
				on_elem_changed = "update_element"
			},
			TEXTFIELD {
				height = 15,
				width = 40,
				enabled = false,
				on_text_changed = 'text_updated',
				numeric = true
			}
		},
	}
	return out
end

local function item_selector_row(items)
	items = items or 10
	local out = {}
	for i = 1, items do
		table.insert(out, item_selector_element())
	end
	return FLOW {
		out
	}
end

local function item_selector_generator(add_reset, preset)
	add_reset = add_reset or false
	local number_of_elements
	if preset then
		number_of_elements = #preset
	else
		number_of_elements = 60
	end

	local rows_pane = {
		name = "selected_items_pane",
		vertical_scroll_policy = 'always',
		horizontal_scroll_policy = 'never',
		horizontally_stretchable = true,
		vertically_scretchable = true,
		margin = 0,
		padding = 0,
	}

	for _ = 1, math.floor(number_of_elements / 10) do
		table.insert(rows_pane, item_selector_row())
	end
	if number_of_elements % 10 ~= 0 then
		table.insert(rows_pane, item_selector_row(number_of_elements % 10))
	end
	local inventory_size
	local player = game.get_player(1)
	local main_inventory = player.get_main_inventory()
	if main_inventory ~= nil then
		inventory_size = #main_inventory
	else
		inventory_size = "?"
	end

	return FRAME {
		direction = "vertical",
		style =  "inside_shallow_frame",
		margin = 6,
		padding = 0,
		height = 178,
		width = 550,
		FRAME {
			padding = 0,
			margin = 0,
			horizontally_stretchable = true,
			height = 30,
			direction = 'horizontal',
			LABEL {
				margin = 1,
				style = "bold_label",
				caption = { "quick-start-popup.select-your-items" }
			},
			EMPTY_WIDGET {
				horizontally_stretchable = true,
				vertically_scretchable = true,
			},
			LABEL {
				margin = 1,
				name = 'available_space',
				caption = inventory_size.."/0",
				tooltip = { "quick-start-popup.inventory-space" }
			},
			EMPTY_WIDGET {
				horizontally_stretchable = true,
				vertically_scretchable = true,
			},
			add_reset and SPRITE_BUTTON {
				margin = 2,
				sprite = "utility/expand_dots",
				style = "tool_button_red",--"frame_action_button",
				tooltip = { "quick-start-popup.clear-quickstart" },
				size = {18,18},
				on_click = 'reset_all_elements',
			} or nil,
		},
		SCROLL_PANE(rows_pane)
	}
end

local function Upload_button(extra_parameters)
    local element = {
        sprite = "arrow_up_white",
        hovered_sprite = "arrow_up_black",
        clicked_sprite = "arrow_up_black",
        tooltip = { "quick-start-popup.add-preset-to-quickstart" },
        style = "tool_button_blue",
    }

    if not extra_parameters then return SPRITE_BUTTON(element) end
    for k, v in pairs(extra_parameters) do
        element[k] = v
    end

    return SPRITE_BUTTON(element)
end

local function item_preset_generator(preset, preset_name)
	local names = {}
	for k, _ in pairs(preset) do 
		table.insert(names, k)
	end

	return FRAME {
		direction = "vertical",
		style = 'borderless_frame',
		padding = 0,
		maximal_height = 178,
		width = 538,
		FRAME {
			padding = 2,
			margin = 0,
			horizontally_stretchable = true,
			height = 30,
			style = 'borderless_frame',
			direction = 'horizontal',
			LABEL {
				caption = preset_name,
				padding = 2,
				style = "bold_label"
			},
			EMPTY_WIDGET {
				horizontally_stretchable = true,
				vertically_scretchable = true,
			},
			Upload_button {
				padding = 1,
				on_click = "add_all_elements"
			},
			(#names>1) and DROP_DOWN {
				name = preset_name,
				items = names,
				right_padding = 6,
				selected_index = 1,
				on_selection_changed = 'update_preset',
			} or nil,
		},
		SCROLL_PANE(item_preset_row_panel(preset[names[1]]))
	}
end

local function item_presets_scoll_pane_generator(presets)

	local pane = {
		vertical_scroll_policy = 'always',
		horizontal_scroll_policy = 'never',
		vertically_scretchable = true,
		padding = 0,
		margin = 6,
		maximal_height = 178*4,
		width = 550,
	}

	for k, v in pairs(presets) do
		table.insert(pane, item_preset_generator(v, k))
	end

	return SCROLL_PANE(pane)
end

local function generate_ui(event)
	local player = game.get_player(event.player_index)
	if player.get_main_inventory() == nil then
		return
	end

	local window = Window(player, {
		window_icon = nil,
		window_title = { "quick-start-popup.title" },
		pinnable = false,
		closable = false,
		extra_button = Upload_button{
			on_click = "give_items_to_players",
			tooltip = { "quick-start-popup.give-quickstart" }
		},
	})
	yafla_gui_builder.build(
		window,
		FLOW {
			name = "quickstart_main_flow",
			direction = "vertical",
			item_selector_generator(true),
			item_presets_scoll_pane_generator(presets)
		}
	)
	actions.delay_action(5, update_all_elements, {scroll_pane = window.children[2].children[1].children[2]})
end

local function handle_new_player(event)
	if event.player_index ~= 1 then
		local player = game.get_player(event.player_index)
		if global.quickstart_ready == true then
			Delay_action(5, give_items_to_player, player)
		else
			player.get_main_inventory().clear()
		end
	else
		generate_ui(event)
	end
end

local function handle_configuration_changed(event)
	global.quickstart_ready = false
	global.quickstart_broken = true
	local items = game.item_prototypes
	for k, v in pairs(global.quickstart) do
		for item, _ in pairs(items) do
			if item == v.name then
				goto next_item
			end
		end
		global.quickstart[k] = nil
		::next_item::
	end
	--Open menu for player with the lowest id that is admin
	local player_1 = game.get_player(1)
	if player_1.connected and player_1.admin then
		generate_ui({player_index = 1})
		return
	end
	for _, player in pairs(game.players) do
		if player.connected and player.admin then
			generate_ui({player_index = player.index})
			return
		end
	end
end

local function handle_player_joined(event)
	if global.quickstart_ready then
		return
	end
	local player = game.get_player(event.player_index)
	if player.admin then
		generate_ui({player_index = player.index})
	end
	if not ext_table.is_present(global.given_quickstart, player.index) then
		game.print("[YAQSA] Warning the quickstart is not configured, when configured you will lose your inventory ".. player.name.." ask an admin to join to fix the problem!")
	else
		game.print("[YAQSA] Warning the quickstart is not configured, please ask an admin to join to fix the problem")
	end
end


script.on_event(defines.events.on_player_created, handle_new_player)
script.on_event(defines.events.on_cutscene_cancelled, generate_ui)
script.on_event(defines.events.on_cutscene_finished, generate_ui)

script.on_configuration_changed(handle_configuration_changed)
script.on_event(defines.events.on_player_joined_game, handle_player_joined)