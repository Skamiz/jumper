

function jumper.print_table(t)
	for k, v in pairs(t) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

function jumper.get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()
	player_pos.y = player_pos.y + eye_height
	player_pos = vector.add(player_pos, eye_offset)

	return player_pos
end

function jumper.player_intersects_node(player, pos)
	local cb = player:get_properties().collisionbox
	local p_pos = player:get_pos()
	return 	p_pos.x + cb[1] >= pos.x + 0.5 or
			p_pos.x + cb[4] <= pos.x - 0.5 or
			p_pos.y + cb[2] >= pos.y + 0.5 or
			p_pos.y + cb[5] <= pos.y - 0.5 or
			p_pos.z + cb[3] >= pos.z + 0.5 or
			p_pos.z + cb[6] <= pos.z - 0.5
end

function jumper.place_in_air(itemstack, user, pointed_thing)
	local pos = jumper.get_eye_pos(user)
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir, 0.5)
	while not jumper.player_intersects_node(user, vector.round(pos)) do
		pos = vector.add(pos, look_dir)
	end
	minetest.set_node(pos, {name = itemstack:get_name()})
end

function jumper.get_switcher()
    local state = false
	local state_off = function() state = false end
	local state_on = function() state = true end

    return function(pos, node, active_object_count, active_object_count_wider)
        minetest.sound_play("tick", {
            pos = pos,
            max_hear_distance = 5,
        })
        if state then
            if node.name == "jumper:platformA_on" then
                minetest.set_node(pos, {name = "jumper:platformA_off"})
            end
            if node.name == "jumper:platformB_off" then
                minetest.set_node(pos, {name = "jumper:platformB_on"})
            end
            -- this is stupid, but the only way I know how to make it work
            minetest.after(1, state_off)
        else
            if node.name == "jumper:platformA_off" then
                minetest.set_node(pos, {name = "jumper:platformA_on"})
            end
            if node.name == "jumper:platformB_on" then
                minetest.set_node(pos, {name = "jumper:platformB_off"})
            end
            minetest.after(1, state_on)
        end
    end
end

local function get_arrow_direction(u, v)
	local dir = 0
	if math.abs(u) > math.abs(v) then
		if u > 0 then dir = 1 else dir = 3 end
	else
		if v < 0 then dir = 2 else dir = 0 end
	end
	return dir
end

function jumper.get_arrow_rotation(player, pointed_thing)
	local normal = vector.subtract(pointed_thing.under, pointed_thing.above)
	local side = 0
	local direction = 0
	local pos = minetest.pointed_thing_to_face_pos(player, pointed_thing)
	pos  = vector.subtract(pos, pointed_thing.above)

	direction = get_arrow_direction(pos.x, pos.z)
	if normal.z < 0 then side = 4
		direction = get_arrow_direction(pos.x, -pos.y)
	elseif normal.z > 0 then side = 8
		direction = get_arrow_direction(pos.x, pos.y)
	elseif normal.x < 0 then side = 12
		direction = get_arrow_direction(-pos.y, pos.z)
	elseif normal.x > 0 then side = 16
		direction = get_arrow_direction(pos.y, pos.z)
	elseif normal.y > 0 then side = 20
		direction = get_arrow_direction(-pos.x, pos.z)
	end
	return side + direction
end

function jumper.get_sign_rotation(player, pointed_thing)
	local above = pointed_thing.above
	local under = pointed_thing.under
	local dir = player:get_look_dir()
	if above.y == under.y then
		if above.x == under.x then
			if above.z > under.z then
				return 6
			else
				return 8
			end
		else
			if above.x > under.x then
				return 15
			else
				return 17
			end
		end
	elseif above.y > under.y then
		if math.abs(dir.x) > math.abs(dir.z) then
			if dir.x < 0 then
				return 3
			else
				return 1
			end
		else
			if dir.z < 0 then
				return 2
			else
				return 0
			end
		end
	else
		if math.abs(dir.x) > math.abs(dir.z) then
			if dir.x < 0 then
				return 23
			else
				return 21
			end
		else
			if dir.z < 0 then
				return 20
			else
				return 22
			end
		end
	end
	return 0
end
