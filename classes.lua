---@class preset
---@field small Ingredient.base[]
---@field medium Ingredient.base[]|nil
---@field big Ingredient.base[]|nil

---@class item
---@field type string
---@field name string
---@field amount int

---@class quickstart
---@field items Ingredient.base[]
---@field status 0 | 1 | 2 -- 0: not ready, 1: ready, 2: broken
---@field given_to int[]
---@field broken_items Ingredient.base[]? -- only set if it's broken and some items are missing

---@class death_quickstart
---@field items Ingredient.base[]
---@field status 0 | 1 | 2 -- 0: not ready, 1: ready, 2: broken
---@field broken_items Ingredient.base[]? -- only set if it's broken and some items are missing