local checkpoints = {}
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

function set_checkpoint(player)
    local name = player:get_player_name()
    local pos = player:get_pos()
    pos.x = round(pos.x)
    pos.z = round(pos.z)
    pos.y = math.floor(pos.y) + 0.5
    if checkpoints[name] and vector.equals(checkpoints[name], pos) then
        return
    end
    particlespawner_deffinition.minpos = {x= pos.x - 0.5, y = pos.y, z = pos.z - 0.5}
    particlespawner_deffinition.maxpos = {x= pos.x + 0.5, y = pos.y + 2 , z = pos.z + 0.5}
    particlespawner_deffinition.playername = name
    local id = minetest.add_particlespawner(particlespawner_deffinition)
    checkpoints[name] = pos
    if particlespawners[name] then
        minetest.delete_particlespawner(particlespawners[name])
    end
    particlespawners[name] = id
    minetest.chat_send_player(name, "Your checkpoint has been set.")
end
function remove_checkpoint(player)
    local name = player:get_player_name()
    checkpoints[name] = nil
    minetest.delete_particlespawner(particlespawners[name])
    minetest.chat_send_player(name, "Your checkpoint has been removed.")
end
function move_to_checkpoint(player)
    local name = player:get_player_name()
    if not checkpoints[name] then
        minetest.chat_send_player(name, "You currently don't have a checkpoint.")
        return
    end
    player:set_pos(checkpoints[name])
end
