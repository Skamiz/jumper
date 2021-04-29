local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
dofile(mod_path.."/misc.lua")
dofile(mod_path.."/commands.lua")
dofile(mod_path.."/timers.lua")
dofile(mod_path.."/checkpoints.lua")
dofile(mod_path.."/nodes.lua")
dofile(mod_path.."/items.lua")
dofile(mod_path.."/mapgen.lua")
dofile(mod_path.."/abms.lua")

minetest.register_craftitem(":", {
    inventory_image = "jumper_hand.png",
    -- What does this do? MTG has it for some reason,but the documentation doesn't meniton it.
    -- type = "none",
})

local creative_mode_cache = minetest.settings:get_bool("creative_mode")



minetest.register_on_joinplayer(
    function(player)
        local name = player:get_player_name()
        local privs = minetest.get_player_privs(name)
        local inv_ref = player:get_inventory()

        if not inv_ref:contains_item("main", "jumper:return") then
            inv_ref:add_item("main", "jumper:return")
        end

        inv_ref:set_size("hand", 1)
        -- note to self, extract this into it's own function
        if creative_mode_cache then
            privs.fast = true
            privs.fly = true
            inv_ref:set_stack("hand", 1, "jumper:builders_hand")
        else
            privs.fast = nil
            privs.fly = nil
            inv_ref:set_size("hand", 0)
        end
        minetest.set_player_privs(name, privs)

    end
)


local nodes = {}

-- nodes which use this mechanic are cached here to shorten lookup time
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.groups.on_walkover then
			nodes[name] = def._on_walkover
		end
	end
end)

minetest.register_globalstep(
    function(dtime)
        for _, player in pairs(minetest.get_connected_players()) do
            local pos = player:get_pos()
            pos.y = pos.y - 0.1
			pos = vector.round(pos)
            local node = minetest.get_node(pos)

			if nodes[node.name] then
				nodes[node.name](player, pos)
			end
        end
    end
)
