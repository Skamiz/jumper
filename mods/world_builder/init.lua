local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local modprefix = modname .. ":"

world_builder = {}

-- misc
dofile(modpath .. "/functions.lua")

-- formspec stuff
dofile(modpath .. "/palette.lua")
dofile(modpath .. "/color_picker.lua")

-- tools
dofile(modpath .. "/random_node.lua")
dofile(modpath .. "/selector.lua")

-- TODO: the paintbrush needs an option to inverse mask
