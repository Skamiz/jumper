local players = {}

local function time_format(time)
	local minutes = math.floor(time/60)
	local seconds = time - (minutes*60)
	local ts = "" .. minutes .. ":"
	if seconds < 10 then ts = ts .. "0" end
	ts = ts .. seconds
	return ts
end

function jumper.start_timer(player)
	local name = player:get_player_name()
	if players[name] then return end

	local id = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=1},
		alignment = {x=1, y=-1},
		text = "Time: 0:00",
	})
	players[name] = {
		id = id,
		start_time = minetest.get_gametime(),
	}
end

function jumper.end_timer(player)
	local name = player:get_player_name()
	if not players[name] then return end

	minetest.chat_send_player(name, "Your time was " .. time_format(minetest.get_gametime() - players[name].start_time))
	player:hud_remove(players[name].id)
	players[name] = nil
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 1 then
	    for name, data in pairs(players) do
			local player = minetest.get_player_by_name(name)
			player:hud_change(data.id, "text", "Time: " .. time_format(minetest.get_gametime() - data.start_time))
	    end
		timer = timer - 1
	end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	players[player:get_player_name()] = nil
end)
