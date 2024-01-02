local Item = {}

local Preset = _G("classes.Preset") -- If you had an item with a physical model, maybe try using Object
local ItemPreset = _G("presets.examples.inventory.Item")
Preset:create("examples.inventory.Item", Item, ItemPreset)

return Item