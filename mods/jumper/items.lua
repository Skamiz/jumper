local mod_name = minetest.get_current_modname()
local mod_prefix = mod_name .. ":"
local texture_prefix = mod_name .. "_"
local multiplier = 15

-- Potential mechanic, hammpered by how the pysiscs override messes with horizontal velocities
minetest.register_craftitem(mod_prefix .. "feather", {
    description = "Feather",
    inventory_image = texture_prefix .. "feather.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        local dir = user:get_look_dir()
        local vel = user:get_player_velocity()
        dir.x = dir.x * multiplier
        dir.y = dir.y * multiplier/3
        dir.z = dir.z * multiplier
        user:add_player_velocity(dir)
    end,
})

minetest.register_craftitem(mod_prefix .. "return", {
    description = "Return to last checkpoint",
    inventory_image = texture_prefix .. "returner.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        jumper.move_to_checkpoint(user)
    end,
    on_drop = function() end,
})

minetest.register_craftitem(mod_prefix .. "builders_hand", {
    description = "A tool to make mapbreaking possible",
    inventory_image = "jumper_hand.png",
    stack_max = 1,
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            mapmaker = {
                times = { [1]=0.20}
            },
        },
    },
})


minetest.register_craftitem(mod_prefix .. "pos_ticket", {
    description = "Holds a position\nplace for 'above' position\npunch for 'under' position",
    inventory_image = "jumper_pos_ticket.png",
    -- stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local meta = itemstack:get_meta()
		if meta:contains("pos") then return end
		local pos = pointed_thing.above
		meta:set_string("description", "Position" .. minetest.pos_to_string(pos) .. "\nsneak + use to clear position")
		meta:set_string("pos", minetest.pos_to_string(pos))
		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		local meta = itemstack:get_meta()
		if meta:contains("pos") then return end
		local pos = pointed_thing.under
		meta:set_string("description", "Position" .. minetest.pos_to_string(pos) .. "\nsneak + use to clear position")
		meta:set_string("pos", minetest.pos_to_string(pos))
		return itemstack
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		if not user:get_player_control().sneak then return end
		local meta = itemstack:get_meta()
		meta:set_string("description", "")
		meta:set_string("pos", "")
		return itemstack
	end,
})
-- just an item for testing random code snipets
minetest.register_craftitem(mod_prefix .. "debug", {
    description = "Not a bug",
    inventory_image = texture_prefix .. "feather.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        minetest.sound_play("tick")
    end,
})
