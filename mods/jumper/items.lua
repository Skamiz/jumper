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
        move_to_checkpoint(user)
    end,
    -- Makes item stack disappear until the inventory formspec is updated.
    -- on_drop = dont_drop,
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
-- just an item for testing random code snipets
minetest.register_craftitem(mod_prefix .. "debug", {
    description = "Not a bug",
    inventory_image = texture_prefix .. "feather.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        minetest.sound_play("tick")
    end,
})
