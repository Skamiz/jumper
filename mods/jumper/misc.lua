-- TODO: get all of these functions out of global
function round(x)
    return math.floor(x + 0.5)
end

function dont_drop(itemstack, dropper, pos)
    return itemstack
end

function get_switcher()
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

function get_arrow_rotation(player, pointed_thing)
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

function get_sign_rotation(player, pointed_thing)
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
