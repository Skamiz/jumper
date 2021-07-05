--[[
- stairs?
--]]

local slab_preset = {
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	node_placement_prediction = "",
}
function jumper.register_slab(node_name, node_def)
	for property, value in pairs(slab_preset) do
		if node_def[property] == nil then
			node_def[property] = value
		end
	end
	minetest.register_node(node_name, node_def)
end


local pillar_preset = {
	drawtype = "nodebox",
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	node_placement_prediction = "",
}
function jumper.register_pillar(node_name, node_def, radius)
	for property, value in pairs(pillar_preset) do
		if node_def[property] == nil then
			node_def[property] = value
		end
	end
	local r = radius or 4
	node_def.node_box = {type = "fixed", fixed = {-r/16, -0.5, -r/16, r/16, 0.5, r/16}}
	minetest.register_node(node_name, node_def)
end

local wall_presets = {
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {wall = 1},
	connects_to = {"group:wall"},
}
function jumper.register_wall(node_name, node_def, radius)
	for property, value in pairs(wall_presets) do
		if node_def[property] == nil then
			node_def[property] = value
		end
	end

	local r = radius or 4
	node_def.node_box = {
		type = "connected",
		fixed = 		{-r/16, -1/2, -r/16,  r/16, 1/2,  r/16},
		connect_front = {-r/16, -1/2, -1/2,   r/16, 1/2, -r/16},
		connect_left = 	{-1/2,  -1/2, -r/16, -r/16, 1/2,  r/16},
		connect_back = 	{-r/16, -1/2,  r/16,  r/16, 1/2,  1/2},
		connect_right = { r/16, -1/2, -r/16,  1/2,  1/2,  r/16},
	}

	minetest.register_node(node_name, node_def)
end
