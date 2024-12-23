--External
local yafla_gui_builder = require("__yafla__/scripts/experimental/gui_builder.lua")
require("__yafla__/scripts/experimental/gui_components.lua")
local actions = require("__yafla__/scripts/actions.lua")
local ext_table = require("__yafla__/scripts/extended_table.lua")

--Internal
local presets = require("__yaqsa__/scripts/presets.lua")
local player_functions = require("__yaqsa__/scripts/player.lua")
local quick = require("__yaqsa__/scripts/quickstart.lua")

local yaqsa_gui = {}

------------------------------------------
--------------GUI COMPONENTS--------------
------------------------------------------

---@param extra_parameters table
---@return table
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


------------------------------------------
-----------------SELECTOR-----------------
------------------------------------------

---@return table
local function Item_selector_element()
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

    -- Size 68*50
    return FRAME {
        direction = "vertical",
        margin = 1,
        padding = 0,
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
    }
end

---@param items int?
---@return table
local function Item_selector_row(items)
    items = items or 10
    local out = {}
    for _ = 1, items do
        table.insert(out, Item_selector_element())
    end
    return FLOW {
        out
    }
end

local function update_selector_gui(self)
    local player = game.get_player(1)
    if not player then return end
    local inventory = player.get_main_inventory()

    if inventory == nil then
        actions.delay_action(5, update_selector_gui, { scroll_pane = self.scroll_pane })
        return
    end

    if self.scroll_pane == nil then
        -- functions.generate_ui({player_index = 1})
        return
    end

    for _, flow in pairs(self.scroll_pane.children) do
        for _, element in pairs(flow.children) do
            element.children[1].elem_value = nil
            element.children[2].text = ''
            element.children[2].enabled = false
        end
    end

    local items = quick.quickstart.get_items()

    if quick.quickstart.is_broken() then
        local counter = 1
        for _, flow in pairs(self.scroll_pane.children) do
            for _, element in pairs(flow.children) do
                if counter > #items then
                    goto update_label_and_quit
                end
                element.children[1].elem_value = items[counter].name
                element.children[2].text = tostring(items[counter].amount) 
                element.children[2].enabled = true
                counter = counter + 1
            end
        end
    else
        for count, item in pairs(inventory.get_contents()) do
            for _, flow in pairs(self.scroll_pane.children) do
                for _, element in pairs(flow.children) do
                    if not element.children[1].elem_value then
                        element.children[1].elem_value = item.name
                        element.children[2].text = tostring(item.count)
                        element.children[2].enabled = true
                        goto next_item
                    elseif item == element.children[1].elem_value then
                        element.children[2].text = tostring(tonumber(element.children[2].text) + count)
                        goto next_item
                    end
                end
            end
            quick.quickstart.set_items(inventory.get_contents())
            ::next_item::
        end
        inventory.clear()
    end
    ::update_label_and_quit::
    yaqsa_gui.update_label(self.scroll_pane)
end

---@param add_reset boolean
---@param preset table?
---@return table
function yaqsa_gui.Item_selector_pane(add_reset, preset)
    add_reset = add_reset or false
    local number_of_elements
    if preset then
        number_of_elements = #preset
    else
        number_of_elements = 80
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
        table.insert(rows_pane, Item_selector_row())
    end
    if number_of_elements % 10 ~= 0 then
        table.insert(rows_pane, Item_selector_row(number_of_elements % 10))
    end
    local inventory_size = "?"
    local player = game.get_player(1)
    local main_inventory = nil

    if player ~= nil then
        main_inventory = player.get_main_inventory()
    end

    if main_inventory ~= nil then
        inventory_size = "" .. #main_inventory
    end

    return FRAME {
        direction = "vertical",
        style = "inside_shallow_frame",
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
                caption = inventory_size .. "/0",
                tooltip = { "quick-start-popup.inventory-space" }
            },
            EMPTY_WIDGET {
                horizontally_stretchable = true,
                vertically_scretchable = true,
            },
            add_reset and SPRITE_BUTTON {
                margin = 2,
                sprite = "utility/expand_dots",
                style = "tool_button_red", --"frame_action_button",
                tooltip = { "quick-start-popup.clear-quickstart" },
                size = { 18, 18 },
                on_click = 'reset_all_elements',
            } or nil,
        },
        SCROLL_PANE(rows_pane)
    }
end

function yaqsa_gui.update_label(elements)
    local label = elements.parent.children[1].children[3]
    local close_button = elements.parent.parent.parent.children[1].children
        [#elements.parent.parent.parent.children[1].children]
    close_button.enabled = true
    local space_used = 0
    for _, flow in pairs(elements.children) do
        for _, element in pairs(flow.children) do
            if element.children[1].elem_value then
                local quantity = tonumber(element.children[2].text) or 0
                space_used = space_used + math.ceil(quantity / prototypes.item[element.children[1].elem_value]
                    .stack_size)
            end
        end
    end
    local inventory = game.get_player(1).get_main_inventory()
    local inv_size = 0

    if inventory ~= nil then
        inv_size = #inventory
    else

    end
    label.caption = tostring(inv_size) .. "/" .. tostring(space_used)
    if space_used > inv_size then
        label.caption = "[color=red]" .. label.caption .. "[/color]"
        close_button.enabled = false
    elseif space_used == inv_size then
        label.caption = "[color=blue]" .. label.caption .. "[/color]"
    end
end


------------------------------------------
------------------PRESET------------------
------------------------------------------

---@param item_name string
---@param amount number
---@return table
local function Item_preset_element(item_name, amount)
    return SPRITE_BUTTON {
        sprite = "item/" .. item_name,
        tooltip = { "quick-start-popup.add-item-to-quickstart" },
        on_click = "add_element",
        LABEL {
            name = item_name,
            position = defines.relative_gui_position.left,
            vertically_scretchable = true,
            ignored_by_interaction = true,
            caption = tostring(amount),
            style = "bold_label",
        }
    }
end

---@param items Ingredient.base[]
local function Item_preset_row(items)
    local out = {}
    for _, v in pairs(items) do
        table.insert(out, Item_preset_element(v.name, v.amount))
    end
    return FLOW {
        out
    }
end

---@param items Ingredient.base[]
local function Item_preset_row_panel(items)
    local number_of_elements = #items

    local rows_pane = {
        vertical_scroll_policy = 'always',
        horizontal_scroll_policy = 'never',
        horizontally_stretchable = true,
        vertically_scretchable = true,
        margin = 0,
        padding = 0,
    }

    for i = 1, math.ceil(number_of_elements / 10) do
        table.insert(rows_pane, Item_preset_row(ext_table.slice(items, i, i * 10)))
    end

    -- for i = 1, math.floor(number_of_elements / 10) do
    --     table.insert(rows_pane, Item_preset_row(ext_table.slice(items, i, i * 10)))
    -- end

    -- local n_elements = number_of_elements % 10
    -- if number_of_elements % 10 ~= 0 then
    --     table.insert(rows_pane,
    --         Item_preset_row(ext_table.slice(items, number_of_elements - n_elements, number_of_elements)))
    -- end

    return rows_pane
end

---@param preset_name string
---@param preset preset
---@return table
local function Item_preset(preset_name, preset)
    local sizes = {}
    for k, _ in pairs(preset) do
        table.insert(sizes, k)
    end

    return FRAME {
        direction = "vertical",
        style = 'invisible_frame',
        padding = 0,
        maximal_height = 178,
        width = 538,
        FRAME {
            padding = 2,
            margin = 0,
            horizontally_stretchable = true,
            height = 30,
            style = 'invisible_frame',
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
            (#sizes > 1) and DROP_DOWN {
                name = preset_name,
                items = sizes,
                right_padding = 6,
                selected_index = 1,
                on_selection_changed = 'update_preset',
            } or nil,
        },
        SCROLL_PANE(Item_preset_row_panel(preset["small"]))
    }
end

---@param preset table<string, preset>
function yaqsa_gui.Item_presets_pane(preset)
    local pane = {
        vertical_scroll_policy = 'always',
        horizontal_scroll_policy = 'never',
        vertically_scretchable = true,
        padding = 0,
        margin = 6,
        maximal_height = 178 * 4,
        width = 550,
    }

    for preset_name, preset_data in pairs(preset) do
        table.insert(pane, Item_preset(preset_name, preset_data))
    end

    return SCROLL_PANE(pane)
end


------------------------------------------
------------------WINDOW------------------
------------------------------------------
---------------NEED  REWORK---------------
------------------------------------------

function yaqsa_gui.quickstart_window(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local inventory = player.get_main_inventory()
    local window = nil

    if inventory ~= nil then
        if not player.gui.screen.quickstart_popup then
            window = Window(player, {
                name = "quickstart_popup",
                window_icon = nil,
                window_title = { "quick-start-popup.title" },
                pinnable = false,
                closable = false,
                extra_button = Upload_button {
                    on_click = "give_quickstart_to_players",
                    tooltip = { "quick-start-popup.give-quickstart" }
                },
            })
            yafla_gui_builder.build(
                window,
                FLOW {
                    name = "quickstart_main_flow",
                    direction = "vertical",
                    yaqsa_gui.Item_selector_pane(true),
                    yaqsa_gui.Item_presets_pane(presets.get_presets())
                },
                player.index
            )
        else
            window = player.gui.screen.quickstart_popup
        end
    end

    local out = nil

    if window then
        out = window.children[2].children[1].children[2]
    end

    if inventory and inventory.get_item_count() > 0 then
        update_selector_gui({ scroll_pane = out })
    else
        actions.delay_action(5, update_selector_gui, { scrol_pane = out })
    end
end

function yaqsa_gui.fix_quickstart_window(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local inventory = player.get_main_inventory()
    local window = nil

    if inventory ~= nil then
        if not player.gui.screen.quickstart_popup then
            window = Window(player, {
                name = "quickstart_popup",
                window_icon = nil,
                window_title = { "quick-start-popup.fix-title" },
                pinnable = false,
                closable = false,
                extra_button = Upload_button {
                    on_click = "give_quickstart_to_players",
                    tooltip = { "quick-start-popup.give-quickstart" }
                },
            })
            yafla_gui_builder.build(
                window,
                FLOW {
                    name = "quickstart_main_flow",
                    direction = "vertical",
                    yaqsa_gui.Item_selector_pane(true),
                    yaqsa_gui.Item_presets_pane(presets.get_presets())
                },
                player.index
            )
        else
            window = player.gui.screen.quickstart_popup
        end
    end

    local out = nil

    if window then
        out = window.children[2].children[1].children[2]
    end

    if inventory and inventory.get_item_count() > 0 then
        update_selector_gui({ scroll_pane = out })
    else
        actions.delay_action(5, update_selector_gui, { scrol_pane = out })
    end
end

function yaqsa_gui.death_quickstart_window(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local inventory = player.get_main_inventory()
    local window = nil

    if inventory ~= nil then
        if not player.gui.screen.quickstart_popup then
            window = Window(player, {
                name = "quickstart_popup",
                window_icon = nil,
                window_title = { "quick-start-popup.title" },
                pinnable = false,
                closable = false,
                extra_button = Upload_button {
                    on_click = "give_quickstart_to_players",
                    tooltip = { "quick-start-popup.give-quickstart" }
                },
            })
            yafla_gui_builder.build(
                window,
                FLOW {
                    name = "quickstart_main_flow",
                    direction = "vertical",
                    yaqsa_gui.Item_selector_pane(true),
                    yaqsa_gui.Item_presets_pane(presets.get_presets())
                },
                player.index
            )
        else
            window = player.gui.screen.quickstart_popup
        end
    end

    local out = nil

    if window then
        out = window.children[2].children[1].children[2]
    end

    if inventory and inventory.get_item_count() > 0 then
        update_selector_gui({ scroll_pane = out })
    else
        actions.delay_action(5, update_selector_gui, { scrol_pane = out })
    end
end

function yaqsa_gui.fix_death_quickstart_window(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local inventory = player.get_main_inventory()
    local window = nil

    if inventory ~= nil then
        if not player.gui.screen.quickstart_popup then
            window = Window(player, {
                name = "quickstart_popup",
                window_icon = nil,
                window_title = { "quick-start-popup.fix-title" },
                pinnable = false,
                closable = false,
                extra_button = Upload_button {
                    on_click = "give_quickstart_to_players",
                    tooltip = { "quick-start-popup.give-quickstart" }
                },
            })
            yafla_gui_builder.build(
                window,
                FLOW {
                    name = "quickstart_main_flow",
                    direction = "vertical",
                    yaqsa_gui.Item_selector_pane(true),
                    yaqsa_gui.Item_presets_pane(presets.get_presets())
                },
                player.index
            )
        else
            window = player.gui.screen.quickstart_popup
        end
    end

    local out = nil

    if window then
        out = window.children[2].children[1].children[2]
    end

    if inventory and inventory.get_item_count() > 0 then
        update_selector_gui({ scroll_pane = out })
    else
        actions.delay_action(5, update_selector_gui, { scrol_pane = out })
    end
end

------------------------------------------
---------------GUI HANDLERS---------------
------------------------------------------

local update_element = function(event)
    local chose_button = event.element
    local textfield = event.element.parent.children[#event.element.parent.children]

    if chose_button.elem_value then
        --https://lua-api.factorio.com/latest/classes/LuaItemPrototype.html#stack_size
        textfield.text = tostring(prototypes.item[chose_button.elem_value].stack_size)
        textfield.enabled = true
    else
        textfield.text = ''
        textfield.enabled = false
    end

    yaqsa_gui.update_label(event.element.parent.parent.parent)
end

local reset_all_elements = function(event)
    local elements_frame = event.element.parent.parent.children[#event.element.parent.parent.children]
    local items = quick.quickstart.get_items()

    if #items <= 0 then
        for _, flow in pairs(elements_frame.children) do
            for _, element in pairs(flow.children) do
                element.children[1].elem_value = nil
                element.children[2].text = ''
                element.children[2].enabled = false
            end
        end
    else
        for _, preset_element in pairs(items) do
            for _, flow in pairs(elements_frame.children) do
                for _, element in pairs(flow.children) do
                    if not element.children[1].elem_value then
                        if preset_element.amount <= 0 then
                            goto next_preset_element
                        end
                        element.children[1].elem_value = preset_element.name
                        element.children[2].text = tostring(preset_element.amount)
                        element.children[2].enabled = true
                        goto next_preset_element
                    elseif preset_element.name == element.children[1].elem_value then
                        element.children[2].text = tostring(tonumber(element.children[2].text) + preset_element.amount)
                        goto next_preset_element
                    end
                end
            end
            ::next_preset_element::
        end
    end

    yaqsa_gui.update_label(elements_frame)
end

local update_preset = function(event)
    local scroll_pane = event.element.parent.parent.children[#event.element.parent.parent.children]
    scroll_pane.destroy()
    yafla_gui_builder.build(
        event.element.parent.parent,
        SCROLL_PANE(Item_preset_row_panel(storage.presets[event.element.name]
            [event.element.items[event.element.selected_index]])),
        event.player_index
    )
end

local text_updated = function(event)
    yaqsa_gui.update_label(event.element.parent.parent.parent)
end

local add_all_elements = function(event)
    local elements_frame =event.element.parent.parent.parent.parent.children[1].children[2]
    local dropdown = event.element.parent.children[#event.element.parent.children]
    ---@type preset?
    local this_preset = presets.get_preset(dropdown.name, dropdown.items[dropdown.selected_index])
    if not this_preset then return end
    for _, preset_element in pairs(this_preset) do
        for _, flow in pairs(elements_frame.children) do
            for _, element in pairs(flow.children) do
                if not element.children[1].elem_value then
                    element.children[1].elem_value = preset_element.name
                    element.children[2].text = tostring(preset_element.amount)
                    element.children[2].enabled = true
                    goto next_preset_element
                elseif preset_element.name == element.children[1].elem_value then
                    element.children[2].text = tostring(tonumber(element.children[2].text) + preset_element.amount)
                    goto next_preset_element
                end
            end
        end
        ::next_preset_element::
    end

    yaqsa_gui.update_label(elements_frame)
end

local add_element = function(event)
    local elements_frame = event.element.parent.parent.parent.parent.parent.children[1].children[2]
    for _, flow in pairs(elements_frame.children) do
        for _, element in pairs(flow.children) do
            if not element.children[1].elem_value then
                element.children[1].elem_value = event.element.children[1].name
                element.children[2].text = event.element.children[1].caption
                element.children[2].enabled = true
                yaqsa_gui.update_label(elements_frame)
                return
            end
            if event.element.children[1].name == element.children[1].elem_value then
                element.children[2].text = tostring(tonumber(element.children[2].text) +
                    tonumber(event.element.children[1].caption))
                yaqsa_gui.update_label(elements_frame)
                return
            end
        end
    end
end

local give_quickstart_to_players = function(event)
    quick.quickstart.set_ready()
    local elements_frame = event.element.parent.parent.children[2].children[1].children[2]
    for _, flow in pairs(elements_frame.children) do
        for _, element in pairs(flow.children) do
            quick.quickstart.add_item({ name = element.children[1].elem_value, amount = tonumber(element.children[2].text) or 0, type = "item" })
        end
    end

    for _, v in pairs(game.players) do
        if not quick.quickstart.is_given_to(v.index) then
            player_functions.give_quickstart_to_player(v)
            quick.quickstart.gave_to(v.index)
        end
    end
    event.element.parent.parent.destroy()
end

yafla_gui_builder.register_handler("add_element", add_element)
yafla_gui_builder.register_handler("text_updated", text_updated)
yafla_gui_builder.register_handler("update_preset", update_preset)
yafla_gui_builder.register_handler("update_element", update_element)
yafla_gui_builder.register_handler("add_all_elements", add_all_elements)
yafla_gui_builder.register_handler("reset_all_elements", reset_all_elements)
yafla_gui_builder.register_handler("give_quickstart_to_players", give_quickstart_to_players)

return yaqsa_gui