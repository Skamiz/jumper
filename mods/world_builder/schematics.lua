local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local modprefix = modname .. ":"

--[[
It seems Minetest has no direct way to just create a schematic,
the only thing it can do is write a schematic to file and then read it in.
--]]

local schematics = {}
world_builder.schematics = schematics

schematics.make_schematic = function(pos1, pos2, air_prob)
	-- by default don't include "air"
	-- air_prob = air_prob or 0
	local minp, maxp = vector.sort(pos1, pos2)
	local va = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})

	local data = {}
	for i in va:iterp(minp, maxp) do
		local node = minetest.get_node(va:position(i))
		node.param1 = nil
		if node.name == "air" then
			node.prob = air_prob
		end
		data[i] = node
	end

	local size = va:getExtent()

	local schematic = {
		data = data,
		size = size,
	}

	return schematic
end

schematics.set_node_probability = function(schematic, node_name, probability)
	for i, node in pairs(schematic.data) do
		if node.name == node_name then
			node.prob = probability
		end
	end
end
