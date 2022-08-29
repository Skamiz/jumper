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
dofile(modpath .. "/clipboard.lua")

-- TODO: the paintbrush needs an option to inverse mask
-- TODO: scripter, writing and library of scripts to run on each node in selection
-- in addition to smooth also have versions bieased to take away/add


local function print_table(t)
	for k, v in pairs(t) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end
