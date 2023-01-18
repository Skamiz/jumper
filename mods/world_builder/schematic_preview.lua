local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local modprefix = modname .. ":"




local schem_prev = {}
local schem_prev_meta = {}
world_builder.schem_prev = schem_prev


local invi = "wb_pixel.png^[opacity:0"
minetest.register_entity(modprefix .."empty", {
	pointable = false,
	visual = "cube",
	use_texture_alpha = true,
	textures = {invi, invi, invi, invi, invi, invi},
	-- is_visible = true,
	static_save = false,
})
minetest.register_entity(modprefix .."preview", {
	pointable = false,
	visual = "item",
	wield_item = "air",
	visual_size = {x = 2/3 + 0.001, y = 2/3 + 0.001, z = 2/3 + 0.001},
	use_texture_alpha = true,
	-- is_visible = true,
	-- backface_culling = false,
	glow = -1,
	static_save = false,
})

-- we need a player here so the schematic can be in a loaded area when hidden
schem_prev.new = function(schematic, attach_player)
	local pos = attach_player:get_pos()
	local schem = schematic
	local root = minetest.add_entity(pos, modprefix .."empty")

	local va = VoxelArea:new({MinEdge = vector_1, MaxEdge = schem.size})

	local nnodes = 0
	for k, v in pairs(schem.data) do
		if v.name ~= "air" then
			nnodes = nnodes + 1
		end
	end

	for i in va:iterp(vector_1, schem.size) do
		local name = schem.data[i].name
		-- TODO: instead of randomly hide nodes
		-- 		1) completely enclosed
		-- 		2) cut out entire slices, so the rest remains more cohesive
		if name ~= "air" and math.random() < (1000/nnodes) then
			local prev = minetest.add_entity(pos, modprefix .."preview")
			prev:set_properties({
				wield_item = name,
			})
			prev:set_attach(root, nil, (va:position(i) - vector_1) * 10)
		end
	end

	local schem_prev = {
		player = attach_player,
		schematic = schematic,
		obj = root,

		pos = pos,
		rotation = 0,
		flags = {},
	}
	return schem_prev
end

schem_prev_meta.delete = function(schem_prev)
	local obj = schem_prev.obj
	for _, child in pairs(obj:get_children()) do
		child:remove()
	end
	obj:remove()
end

schem_prev_meta.show = function(schem_prev)
	schem_prev.visible = true
	local obj = schem_prev.obj
	obj:set_detach()
	for _, child in pairs(obj:get_children()) do
		child:set_properties({is_visible = true})
	end
	schem_prev:set_placement()
end

schem_prev_meta.hide = function(schem_prev)
	schem_prev.visible = false
	local obj = schem_prev.obj
	for _, child in pairs(obj:get_children()) do
		child:set_properties({is_visible = false})
	end
	obj:set_attach(player)
end

schem_prev_meta.rotate = function(schem_prev, angle)
	local rot = schem_prev.rotation
	rot = rot + angle
	if rot > 270 then rot = rot - 360 end
	if rot < 0 then rot = rot + 360 end
	schem_prev.rotation = rot
end

schem_prev_meta.set_placement = function(schem_prev, pos, rotation, flags)
	local pos = pos or schem_prev.pos
	local rotation = rotation or schem_prev.rotation
	local flags = flags or schem_prev.flags
end
