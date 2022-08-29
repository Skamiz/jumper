local modname = minetest.get_current_modname()
local modprefix = modname .. ":"

-- TODO: allow players to configure their selector/indicator colors

local players = {}

function world_builder.get_area(player)
	local p_data = players[player]

	return p_data.pos_1.pos, p_data.pos_2.pos
end

function world_builder.set_area(player, pos_1, pos_2)
	local p_data = players[player]

	set_indicator_position(player, "pos_1", pos_1)
	set_indicator_position(player, "pos_2", pos_2)
end

local one_node_vector = vector.new(1.001, 1.001, 1.001)
local function update_selection(player, pos_1, pos_2)
	local p_data = players[player]

	if not (pos_1 and pos_2) then
		pos_1 = p_data.pos_1.pos
		pos_2 = p_data.pos_2.pos
	end
	if not (pos_1 and pos_2) then
		if not (pos_1 or pos_2) then
			if p_data.selection then
				p_data.selection:remove()
				p_data.selection = nil
			end
		end
		return
	end

	if not p_data.selection or p_data.selection:get_pos() == nil then
		p_data.selection = minetest.add_entity(player:get_pos(), modprefix .."selector")
		local t = "wb_pixel.png^[colorize:#c8c837^[opacity:129"
		p_data.selection:set_properties({textures = {t, t, t, t, t, t}})
	end

	local minp, maxp = vector.sort(pos_1, pos_2)

	local dif = maxp - minp
	p_data.selection:set_properties({visual_size = (dif + one_node_vector)})
	local mid = dif / 2
	p_data.selection:set_pos(minp + mid)
end

local function set_indicator_position(player, indicator, pos)
	local ind = players[player][indicator]
	if not ind.obj or ind.obj:get_pos() == nil then
		ind.obj = minetest.add_entity(pos, modprefix .."selector")
		ind.obj:set_properties({textures = {ind.tex, ind.tex, ind.tex, ind.tex, ind.tex, ind.tex}})
		ind.pos = pos
	end
	if not pos:equals(ind.pos) then
		ind.pos = pos
		ind.obj:set_pos(ind.pos)
	end
	update_selection(player)
end

-- also could have used marker instead of indicator, oh well
local function remove_indicator(player, indicator)
	local ind = players[player][indicator]
	ind.pos = nil
	if ind.obj then ind.obj:remove() end
	ind.obj = nil
	update_selection(player)
end

local function use_selector(player, indicator)
	if player:get_player_control().sneak then
		remove_indicator(player, indicator)
	else
		local pos = vector.round(world_builder.get_looked_pos(player, 5))
		set_indicator_position(player, indicator, pos)
	end
end

minetest.register_craftitem(modprefix .."selector", {
	description = "Area Selector"
			.. "\n" .. minetest.colorize("#e3893b", "LMB") .. " Set pos_1"
			.. "\n" .. minetest.colorize("#3dafd2", "RMB") .. " Set pos_2"
			.. "\n" .. minetest.colorize("#ff7070", "Shift") .. " + " .. minetest.colorize("#e3893b", "LMB") .. " Unset pos_1"
			.. "\n" .. minetest.colorize("#ff7070", "Shift") .. " + " .. minetest.colorize("#3dafd2", "RMB") .. " Unset pos_2"
			,
	inventory_image = "wb_selector.png",
	on_use = function(itemstack, user, pointed_thing)
		use_selector(user, "pos_1")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		use_selector(placer, "pos_2")
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		use_selector(user, "pos_2")
	end,
})

do
	-- WARNING: if texture is made any more opaque it will become completely invissible
	local tex = "wb_pixel.png^[opacity:129"
	local scale = 1.002
	minetest.register_entity(modprefix .."selector", {
		pointable = false,
		visual = "cube",
		visual_size = {x = scale, y = scale, z = scale},
		textures = {tex, tex, tex, tex, tex, tex},
		use_texture_alpha = true,
		-- is_visible = true,
		backface_culling = false,
		glow = -1,
		static_save = false,
	})
end


minetest.register_on_joinplayer(function(player, last_login)
	players[player] = {
		selection = nil,
		pointer = {tex = "wb_pos_pointer.png^[opacity:129"},
		pos_1 = {tex = "wb_pos_1.png^[colorize:#e3893b^[opacity:129"},
		pos_2 = {tex = "wb_pos_2.png^[colorize:#3dafd2^[opacity:129"},
	}
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local p_data = players[player]
	if p_data.pointer.obj:get_pos() then p_data.pointer.obj:remove() end
	if p_data.pos_1.obj:get_pos() then p_data.pos_1.obj:remove() end
	if p_data.pos_2.obj:get_pos() then p_data.pos_2.obj:remove() end
	if p_data.selection:get_pos() then p_data.selection:remove() end
	players[player] = nil

end)

minetest.register_globalstep(function(dtime)
	for player, p_data in pairs(players) do
		if player:get_wielded_item():get_name() == modprefix .."selector" then
			local new_pos = vector.round(world_builder.get_looked_pos(player, 5))

			if not p_data.pointer.pos then
				update_selection(player)
			end

			set_indicator_position(player, "pointer", new_pos)

			local pos_1, pos_2 = p_data.pos_1.pos, p_data.pos_2.pos
			if ((pos_1 or pos_2) and not (pos_1 and pos_2)) then
				update_selection(player, pos_1 or pos_2, vector.round(world_builder.get_looked_pos(player, 5)))
			end

		elseif p_data.pointer.pos then
			remove_indicator(player, "pointer")
			if p_data.selection then
				p_data.selection:remove()
				p_data.selection = nil
			end
		end
	end
end)
