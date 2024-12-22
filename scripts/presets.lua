---@type table<string, preset>
local presets = {
    belt = {
        small = {
            { type = "item", name = "transport-belt",   amount = 200 },
            { type = "item", name = "underground-belt", amount = 50 },
            { type = "item", name = "splitter",         amount = 50 },
        },
        medium = {
            { type = "item", name = "transport-belt",   amount = 400 },
            { type = "item", name = "underground-belt", amount = 100 },
            { type = "item", name = "splitter",         amount = 100 },
        },
        big = {
            { type = "item", name = "transport-belt",   amount = 800 },
            { type = "item", name = "underground-belt", amount = 200 },
            { type = "item", name = "splitter",         amount = 200 },
        },
    },
    power = {
        small = {
            { type = "item", name = "small-electric-pole", amount = 100 },
        },
        medium = {
            { type = "item", name = "medium-electric-pole", amount = 150 },
        },
        big = {
            { type = "item", name = "medium-electric-pole", amount = 200 },
            { type = "item", name = "big-electric-pole",    amount = 50 },
        },
    },
    constructions = {
        small = {
            { type = "item", name = "construction-robot",          amount = 10 },
            { type = "item", name = "personal-roboport-equipment", amount = 1 },
            { type = "item", name = "modular-armor",               amount = 1 },
            { type = "item", name = "solar-panel-equipment",       amount = 7 },
            { type = "item", name = "battery-equipment",           amount = 2 },
        },
        medium = {
            { type = "item", name = "construction-robot",          amount = 20 },
            { type = "item", name = "personal-roboport-equipment", amount = 2 },
            { type = "item", name = "power-armor",                 amount = 1 },
            { type = "item", name = "solar-panel-equipment",       amount = 16 },
            { type = "item", name = "battery-equipment",           amount = 4 },
        },
        big = {
            { type = "item", name = "construction-robot",          amount = 40 },
            { type = "item", name = "personal-roboport-equipment", amount = 4 },
            { type = "item", name = "power-armor",                 amount = 1 },
            { type = "item", name = "fusion-reactor-equipment",    amount = 1 },
            { type = "item", name = "battery-mk2-equipment",       amount = 4 },
        },
    },
    personal_transport = {
        small = {
            { type = "item", name = "car", amount = 1 }
        },
        medium = {
            { type = "item", name = "power-armor",           amount = 1 },
            { type = "item", name = "solar-panel-equipment", amount = 14 },
            { type = "item", name = "exoskeleton-equipment", amount = 2 }
        },
        big = {
            { type = "item", name = "spidertron", amount = 1 }
        }
    },
    compat = {
        small = {
            { type = "item", name = "car", amount = 1 }
        },
        medium = {
            { type = "item", name = "car", amount = 1 }
        },
        big = {
            { type = "item", name = "car", amount = 1 }
        }
    }
    --[[
		Trains = {
			
		},
		Weapons = {
			
		},
	--]]
}

---@type table<string, preset>
if (not storage.presets) or storage.presets == {} then
    storage.presets = util.copy(presets)
end

local out = {}

---@param name string
---@param size "small" | "medium" | "big"
---@return preset?
function out.get_preset(name, size)
    if (not storage.presets) or storage.presets == {} then
        storage.presets = util.copy(presets)
    end
    if (not storage.presets[name]) or (not storage.presets[name][size]) then
        return nil
    end
    return util.copy(storage.presets[name][size])
end

---@return preset[]
function out.get_presets()
    if (not storage.presets) or storage.presets == {} then
        storage.presets = util.copy(presets)
    end
    return util.copy(storage.presets)
end

---@param name string
---@param preset table<string, preset>
function out.add_preset(name, preset)
    if not storage.presets or storage.presets == {} then
        storage.presets = util.copy(presets)
    end
    if storage.presets[name] then
        return nil
    end
    if not preset.small then
        assert(false, "Preset must have a 'small' size")
        return nil
    end
    storage.presets[name] = {}
    for size, items in pairs(preset) do
        storage.presets[name][size] = items
    end
end

return out