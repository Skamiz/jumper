local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

world_builder = {}

dofile(modpath .. "/palette.lua")
dofile(modpath .. "/color_picker.lua")
dofile(modpath .. "/random_node.lua")

-- TODO: the paintbrush nees an option to inverse mask
