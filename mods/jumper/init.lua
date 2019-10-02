local mod_name = minetest.get_current_modname()
dofile(minetest.get_modpath(mod_name).."/misc.lua")
dofile(minetest.get_modpath(mod_name).."/checkpoints.lua")
dofile(minetest.get_modpath(mod_name).."/nodes.lua")
dofile(minetest.get_modpath(mod_name).."/items.lua")
dofile(minetest.get_modpath(mod_name).."/mapgen.lua")
dofile(minetest.get_modpath(mod_name).."/abms.lua")

minetest.register_craftitem(":", {
    inventory_image = "jumper_hand.png",
    -- What does this do?
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


minetest.register_globalstep(
    function(dtime)
        for _, v in pairs(minetest.get_connected_players()) do
            for _, player in pairs(minetest.get_connected_players()) do
                local pos = player:get_pos()
                pos.y = pos.y - 0.1
                local node = minetest.get_node(pos)
                if node.name == "jumper:checkpoint" then
                    set_checkpoint(player)
                end
                if node.name == "jumper:danger" then
                    move_to_checkpoint(player)
                end
            end
        end
    end
)
