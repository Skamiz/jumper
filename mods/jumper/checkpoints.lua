-- Setting/removing and moving player to checkpoints + fancy paritcle effects
-- Potentioaly exctract this into it's own mod so jump'n run maps made in other games can be freed from the /sethome, /home bullshit

-- note: after rejoining the game the current checkpoint has no particles
local particlespawners = {}

local particlespawner_deffinition = {
    amount = 5,
    time = 0,
    minexptime = 1,
    maxexptime = 2,
    texture = "checkpoint_particles.png",
    minsize = 0.5,
    maxsize = 1.5,
}

function jumper.set_checkpoint(player)
	local meta = player:get_meta()
    local name = player:get_player_name()
    local pos = player:get_pos()
    pos.x = math.floor(pos.x + 0.5)
    pos.z = math.floor(pos.z + 0.5)
    pos.y = math.floor(pos.y) + 0.5

	local string_pos = minetest.pos_to_string(pos)
    if string_pos and meta:get_string("checkpoint") == string_pos then
        return
    end
    particlespawner_deffinition.minpos = {x= pos.x - 0.5, y = pos.y, z = pos.z - 0.5}
    particlespawner_deffinition.maxpos = {x= pos.x + 0.5, y = pos.y + 2 , z = pos.z + 0.5}
    particlespawner_deffinition.playername = name
    local id = minetest.add_particlespawner(particlespawner_deffinition)
	meta:set_string("checkpoint", string_pos)
    if particlespawners[name] then
        minetest.delete_particlespawner(particlespawners[name])
    end
    particlespawners[name] = id
	-- already conveyed via particals
    -- minetest.chat_send_player(name, "Your checkpoint has been set.")
end

function jumper.remove_checkpoint(player)
	local meta = player:get_meta()
	meta:set_string("checkpoint", "")

    local name = player:get_player_name()
    minetest.delete_particlespawner(particlespawners[name])
    minetest.chat_send_player(name, "Your checkpoint has been removed.")
end

function jumper.move_to_checkpoint(player)
	local meta = player:get_meta()
    if meta:contains("checkpoint") then
		player:set_pos(minetest.string_to_pos(meta:get_string("checkpoint")))
	else
		minetest.chat_send_player(player:get_player_name(), "You currently don't have a checkpoint.")
    end
end
