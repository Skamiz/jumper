
--noise parameters, not realy used, but keeping them just in case
np_generic = {
        offset = 0,
        scale = 1,
        spread = {x = 200, y = 200, z = 200},
        seed = 0,
        octaves = 5,
        persist = 0.63,
        lacunarity = 2.0,
}

local c_ground = minetest.get_content_id("jumper:ground")


minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	local side_lenght = maxp.x - minp.x + 1
	local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}
	local noise_values_generic = minetest.get_perlin_map(np_generic, chunk_size):get_2d_map_flat({x = minp.x, y = minp.z})

-- all this does is fill the bottom half of the world with a solid node
	local i = 1
	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local vi = area:index(x, y, z)
                if y < 0 then
                    data[vi] = c_ground
				end
				i = i + 1
			end
			i = i - side_lenght
		end
		i = i + side_lenght
	end

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting() -- doesn't prevent shadows at chunk boundaries
	vm:write_to_map(data)

end)
