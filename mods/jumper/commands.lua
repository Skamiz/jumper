local modname = minetest.get_current_modname()

local function print_po(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

local function show_pysiscs_formspec(name)
	local player = minetest.get_player_by_name(name)
	local po = player:get_physics_override()
	local fs = "formspec_version[4]" ..
	"size[10.75,8.5]"..
	"container[0.5,0.5]"

	local n = 0
	for k, v in pairs(po) do
		fs = fs .. "label[0," .. n + 0.5 .. ";" .. k .. "]"
		if type(v) == "boolean" then
			fs = fs .. "checkbox[5," .. n + 0.5 .. ";" .. k .. ";;" .. tostring(v) .. "]"
		elseif type(v) == "number" then
			fs = fs .. "field[5," .. n + 0.25 .. ";2,0.5;" .. k .. ";;" .. v .. "]"
		end
		n = n + 1
	end

	fs = fs .. "container_end[]"
	minetest.show_formspec(name, modname .. ":physics_override",fs)
end

minetest.register_chatcommand("phys", {
	params = "phys",
	description = "Allows to change own physics override.",
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local po = player:get_physics_override()
		-- print_po(po)
		show_pysiscs_formspec(name)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formnname == modname .. ":physics_override" then return false end
	-- local player = minetest.get_player_by_name(player:)
	local po = player:get_physics_override()
	po.speed = fields.speed or po.speed
	po.jump = fields.jump or po.jump
	po.gravity = fields.gravity or po.gravity
	if fields.sneak ~= nil then po.sneak = (fields.sneak == "true") end
	if fields.sneak_glitch ~= nil then po.sneak_glitch = (fields.sneak_glitch == "true") end
	if fields.new_move ~= nil then po.new_move = (fields.new_move == "true") end
	-- print_po(po)
	player:set_physics_override(po)
end)
