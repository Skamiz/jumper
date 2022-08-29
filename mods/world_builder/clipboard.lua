local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local modprefix = modname .. ":"

local players = {}

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

-- preview section

local function delete_preview(player)
	local obj = players[player].obj
	for _, child in pairs(obj:get_children()) do
		child:remove()
	end
	obj:remove()
	players[player].obj = nil
end

local vector_1 = vector.new(1, 1, 1)
local function make_preview(player, pos)
	if not pos then pos = player:get_pos() end

	if players[player].obj then
		delete_preview(player)
	end

	local schem = players[player].schem
	local root = minetest.add_entity(pos, modprefix .."empty")
	players[player].obj = root
	local va = VoxelArea:new({MinEdge = vector_1, MaxEdge = schem.size})

	local nnodes = 0
	for k, v in pairs(schem.data) do
		if v.name ~= "air" then
			nnodes = nnodes + 1
		end
	end

	for i in va:iterp(vector_1, schem.size) do
		local name = schem.data[i].name
		if name ~= "air" and math.random() < (1000/nnodes) then
			local prev = minetest.add_entity(pos, modprefix .."preview")
			prev:set_properties({
				wield_item = name,
			})
			prev:set_attach(root, nil, (va:position(i) - vector_1) * 10)
		end
	end
end

local function hide_preview(player)
	local p_data = players[player]
	p_data.visible = false
	for _, child in pairs(p_data.obj:get_children()) do
		child:set_properties({is_visible = false})
	end
	p_data.obj:set_attach(player)
end

local function reveal_preview(player)
	local p_data = players[player]
	p_data.visible = true
	p_data.obj:set_detach()
	for _, child in pairs(p_data.obj:get_children()) do
		child:set_properties({is_visible = true})
	end
	if p_data.fixed_pos then
		p_data.obj:set_pos(p_data.fixed_obj_pos)
	end
end

-- -----------------------------------------------
local function move_preview(player, pos)
	local p_data = players[player]
	if p_data.fixed_pos then return end
	pos = pos + p_data.options.offset
	if not pos:equals(p_data.obj:get_pos()) then
		p_data.obj:set_pos(pos)
	end
end


-- options section
local function update_flag_string(player)
	local opt = players[player].options

	local t = {}
	for flag, bool in pairs(opt.flags) do
		if bool then
			t[#t + 1] = flag
		end
	end
	opt.flag_string = table.concat(t, ", ")
end


local function update_offset(player)
	local opt = players[player].options
		opt.offset = vector.new(0, 0, 0)

	local size = table.copy(players[player].schem.size)
	if opt.rot == 90 then
		opt.offset.z = opt.offset.z + size.x - 1
		size.x, size.z = size.z, size.x
	elseif opt.rot == 180 then
		opt.offset.x = opt.offset.x + size.x - 1
		opt.offset.z = opt.offset.z + size.z - 1
	elseif opt.rot == 270 then
		opt.offset.x = opt.offset.x + size.z - 1
		size.x, size.z = size.z, size.x
	end

	for flag, bool in pairs(opt.flags) do
		local axis = flag:sub(-1)
		if opt.flags[flag] then
			opt.offset[axis] = opt.offset[axis] - math.floor((size[axis] - 1)/2)
		end
	end
end

local function rotate_schematic(player, angle)
	local p_data = players[player]
	local rot = p_data.options.rot
	rot = rot + angle
	if rot > 270 then rot = rot - 360 end
	if rot < 0 then rot = rot + 360 end
	p_data.options.rot = rot

	p_data.obj:set_rotation(vector.new(0, -math.rad(rot), 0))
	update_offset(player)
end

-- clipboard section
local function copy_area_to_clipboard(player)
	local pos1, pos2 = world_builder.get_area(player)
	if not (pos1 and pos2) then
		minetest.chat_send_player(player:get_player_name(), "You first must select an area to copy.")
		return
	end

	local minp, maxp = vector.sort(pos1, pos2)
	local va = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})

	local air  = players[player].options.place_air

	local data = {}
	for i in va:iterp(minp, maxp) do
		local node = minetest.get_node(va:position(i))
		node.param1 = nil
		if node.name == "air" then
			node.prob = air and 255 or 0
		end
		data[i] = node
	end

	local schem = players[player].schem
	schem.size = va:getExtent()
	schem.data = data

	players[player].distance = math.max(schem.size.x, schem.size.y, schem.size.z)/1.5 + 3
	players[player].options.rot = 0
	update_offset(player)
	make_preview(player)
end

local function place_from_clipboard(player, pos)
	local p_data = players[player]
	pos = p_data.fixed_pos or pos
	p_data.fixed_pos = nil
	p_data.fixed_obj_pos = nil


	local schem = p_data.schem
	local options = p_data.options
	if not schem.data then
		minetest.chat_send_player(player:get_player_name(), "Nothing to place. The clipboard is empty.")
	end
	minetest.place_schematic(pos, schem, tostring(options.rot), nil, options.force_placement, options.flag_string)
end



-- TODO: ctrl + RMB fix preview in space
-- TODO: ctrl + LMB options formspec


local function show_clipboard_fs(player)
	local opt = players[player].options
	local fs = ""
	.. "formspec_version[6]"
	.. "size[12.75,9.75,false]"
	.. "container[0.25,0.25]"
	.. "checkbox[0,1;force_placement;force_placement;" .. tostring(opt.force_placement) .. "]"
	.. "checkbox[0,2;place_air;place_air;" .. tostring(opt.place_air) .. "]"
	.. "checkbox[0,3;place_center_x;place_center_x;" .. tostring(opt.flags.place_center_x) .. "]"
	.. "checkbox[0,4;place_center_y;place_center_y;" .. tostring(opt.flags.place_center_y) .. "]"
	.. "checkbox[0,5;place_center_z;place_center_z;" .. tostring(opt.flags.place_center_z) .. "]"
	.. "container_end[]"


	minetest.show_formspec(player:get_player_name(), modprefix .. "clipboard", fs)
end

local function clipboard_lmb(player)
	if player:get_player_control().aux1 then
		show_clipboard_fs(player)
	elseif player:get_player_control().sneak then
		rotate_schematic(player, -90)
	else
		copy_area_to_clipboard(player)
	end
end

local function clipboard_rmb(player)
	local p_data = players[player]
	local pos = vector.round(world_builder.get_looked_pos(player, players[player].distance))
	if player:get_player_control().aux1 then
		if p_data.fixed_pos then
			p_data.fixed_pos = nil
			p_data.fixed_obj_pos = nil
		elseif p_data.obj then
			p_data.fixed_pos = pos
			p_data.fixed_obj_pos = p_data.obj:get_pos()
		end
	elseif player:get_player_control().sneak then
		rotate_schematic(player, 90)
	else
		place_from_clipboard(player, pos)
	end
end

minetest.register_craftitem(modprefix .."clipboard", {
	description = "Area Clipboard"
			.. "\n" .. minetest.colorize("#e3893b", "LMB") .. ": Copy area to clipboard."
			.. "\n" .. minetest.colorize("#3dafd2", "RMB") .. ": Place clipboard schem."
			.. "\n" .. minetest.colorize("#ff7070", "Shift") .. " + " .. minetest.colorize("#e3893b", "LMB") .. ": Rotate right."
			.. "\n" .. minetest.colorize("#ff7070", "Shift") .. " + " .. minetest.colorize("#3dafd2", "RMB") .. ": Rotate left."
			.. "\n" .. minetest.colorize("#67a943", "Ctrl") .. " + " .. minetest.colorize("#e3893b", "LMB") .. ": Clipboard options."
			.. "\n" .. minetest.colorize("#67a943", "Ctrl") .. " + " .. minetest.colorize("#3dafd2", "RMB") .. ": Fixate preview."
	,
	inventory_image = "wb_clipboard.png",
	on_use = function(itemstack, user, pointed_thing)
		clipboard_lmb(user)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		clipboard_rmb(placer)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		clipboard_rmb(user)
	end,
})

minetest.register_on_joinplayer(function(player, last_login)
	players[player] = {
		schem = {
			data = nil,
		},
		options = {
			rot = 0,
			force_placement = false,
			place_air = false,
			offset = vector.new(0, 0, 0),
			flags = {
				place_center_x = true,
				place_center_y = false,
				place_center_z = true,
			},
			flag_string = "place_center_x, place_center_z",
		},
		fixed_pos = nil,
		fixed_obj_pos = nil,
		distance = 5,
		obj = nil,
		visible = nil,
	}
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	delete_preview(player)
	players[player] = nil
end)

minetest.register_globalstep(function(dtime)
	for player, p_data in pairs(players) do
		if p_data.obj then
			if player:get_wielded_item():get_name() == modprefix .."clipboard" then
				if not p_data.visible then
					reveal_preview(player)
				end

				local new_pos = vector.round(world_builder.get_looked_pos(player, p_data.distance))
				move_preview(player, new_pos)

			elseif p_data.visible then
				hide_preview(player)
			end
		end
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= modprefix .."clipboard" then return end
	local p_data = players[player]
	local opt = p_data.options
	if fields.force_placement then
		opt.force_placement = not opt.force_placement
	end
	if fields.place_air then
		opt.place_air = not opt.place_air
		if opt.place_air then
			for i, node in pairs(p_data.schem.data) do
				if node.name == "air" then
					node.prob = 255
				end
			end
		else
			for i, node in pairs(p_data.schem.data) do
				if node.name == "air" then
					node.prob = 0
				end
			end
		end
	end
	if not p_data.schem.data then return true end

	for flag, bool in pairs(opt.flags) do
		if fields[flag] then
			opt.flags[flag] = not opt.flags[flag]
			update_offset(player)
			update_flag_string(player)
		end
	end

	return true
end)
