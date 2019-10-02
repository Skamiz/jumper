function round(x)
    return math.floor(x + 0.5)
end

function dont_drop(itemstack, dropper, pos)
    return itemstack
end

function get_switcher()
    local state = false

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
            minetest.after(1, function() state = false end)
        else
            if node.name == "jumper:platformA_off" then
                minetest.set_node(pos, {name = "jumper:platformA_on"})
            end
            if node.name == "jumper:platformB_on" then
                minetest.set_node(pos, {name = "jumper:platformB_off"})
            end
            minetest.after(1, function() state = true end)
        end
    end
end
