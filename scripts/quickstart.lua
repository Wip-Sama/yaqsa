---@type quickstart
storage.quickstart = storage.quickstart or {
    items = {},
    status = 0,
    given_to = {},
    broken_items = {},
}

---@type death_quickstart
storage.death_quickstart = storage.death_quickstart or {
    items = {},
    status = 0,
}

local quickstart = {}
local death_quickstart = {}

---@param player_index integer
function quickstart.is_given_to(player_index)
    return storage.quickstart.given_to[player_index] or false
end

---@param player_index integer
function quickstart.retract_given_to(player_index)
    if not quickstart.is_given_to(player_index) then return end
    table.remove(storage.quickstart.given_to, player_index)
end

---Should be called **AFTER** the player has been given the items
---@param player_index integer
function quickstart.gave_to(player_index)
    table.insert(storage.quickstart.given_to, player_index)
end

function quickstart.clear_given_to()
    storage.quickstart.given_to = {}
end

function quickstart.get_items()
    return util.copy(storage.quickstart.items)
end

---@param items Ingredient.base[]
function quickstart.set_items(items)
    storage.quickstart.items = {}
    for _, item in pairs(items) do
        for _, v in pairs(storage.quickstart.items) do
            if v.name == item.name then
                v.amount = v.amount + item.amount
                goto next_element
            end
        end
        table.insert(storage.quickstart.items, item)
        ::next_element::
    end
end

---@param item Ingredient.base
function quickstart.add_item(item)
    for _, v in pairs(storage.quickstart.items) do
        if v.name == item.name then
            v.amount = v.amount + item.amount
            return
        end
    end
    table.insert(storage.quickstart.items, item)
end

function quickstart.is_ready()
    return storage.quickstart.status == 1
end

function quickstart.is_broken()
    return storage.quickstart.status == 2
end

function quickstart.set_ready()
    storage.quickstart.status = 1
end

function quickstart.set_broken()
    storage.quickstart.status = 2
end

---comment
---@param name string
function quickstart.remove_broken_item(name)
    for i, item in pairs(storage.quickstart.items) do
        if item.name == name then
            table.insert(storage.quickstart.broken_items, table.remove(storage.quickstart.items, i))
            return
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------------------DEATH QUICK------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


function death_quickstart.get_items()
    return util.copy(storage.quickstart.items)
end

---@param items Ingredient.base[]
function death_quickstart.set_items(items)
    storage.quickstart.items = items
end

---comment
---@param name string
function death_quickstart.remove_broken_item(name)
    for i, item in pairs(storage.death_quickstart.items) do
        if item.name == name then
            table.insert(storage.death_quickstart.broken_items, table.remove(storage.death_quickstart.items, i))
            return
        end
    end
end

function death_quickstart.is_ready()
    return storage.death_quickstart.status == 1
end

function death_quickstart.is_broken()
    return storage.death_quickstart.status == 2
end

function death_quickstart.set_ready()
    storage.death_quickstart.status = 1
end

function death_quickstart.set_broken()
    storage.death_quickstart.status = 2
end


return {
    quickstart = quickstart,
    death_quickstart = death_quickstart,
}
