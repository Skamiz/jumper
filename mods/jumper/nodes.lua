local mod_name = minetest.get_current_modname()
local mod_prefix = mod_name .. ":"
local texture_prefix = mod_name .. "_"


-- Do nothing
minetest.register_node(mod_prefix .."ground", {
	description = "Ground",
	tiles = {texture_prefix .. "ground.png"},
	groups = {mapmaker = 1},
})
minetest.register_node(mod_prefix .."path", {
	description = "Path",
	tiles = {texture_prefix .. "path.png"},
	groups = {mapmaker = 1},
})
-- Also just for buiding
minetest.register_node(mod_prefix .."glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {texture_prefix .. "glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {mapmaker = 1},
})
minetest.register_node(mod_prefix .."light", {
	description = "Light",
	tiles = {texture_prefix .. "light.png"},
	light_source = 14,
	groups = {mapmaker = 1},
})
-- Checkpoint system
minetest.register_node(mod_prefix .."checkpoint", {
	description = "Checkpoint",
	tiles = {texture_prefix .. "checkpoint.png"},
	groups = {mapmaker = 1, checkpoint = 1},
})
minetest.register_node(mod_prefix .."danger", {
	description = "Danger",
	tiles = {texture_prefix .. "danger.png"},
	groups = {mapmaker = 1, danger = 1},
})
-- Special properties
minetest.register_node(mod_prefix .."ice", {
	description = "Ice",
	drawtype = "glasslike",
	tiles = {texture_prefix .. "ice.png"},
	inventory_image = "[inventorycube{jumper_ice.png&[noalpha{jumper_ice.png&[noalpha{jumper_ice.png&[noalpha",
	use_texture_alpha = true,
	paramtype = "light",
	groups = {mapmaker = 1, slippery = 3},
})
minetest.register_node(mod_prefix .."ladder", {
	description = "Ladder",
	drawtype = "signlike",
	tiles = {texture_prefix .. "grid.png"},
	inventory_image = texture_prefix .. "grid.png",
	wield_image  = texture_prefix .. "grid.png",
	climbable = true,
	walkable = false,
	paramtype2 = "wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {mapmaker = 1},
	selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -7 / 16, 0.5},
        },
    },
})
minetest.register_node(mod_prefix .."bouncy", {
	description = "Bouncy",
	tiles = {texture_prefix .. "bouncy.png"},
	groups = {mapmaker = 1, bouncy = 90},
})
-- Timer nodes
minetest.register_node(mod_prefix .."platformA_on", {
	description = "Platform A on",
	tiles = {texture_prefix .. "platformA_on.png"},
	groups = {mapmaker = 1, periodic = 5},
})
minetest.register_node(mod_prefix .."platformA_off", {
	description = "Platform A off",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {texture_prefix .. "platformA_off.png"},
	walkable = false,
	groups = {mapmaker = 1, periodic = 5, not_in_creative_inventory = 1},
})
minetest.register_node(mod_prefix .."platformB_on", {
	description = "Platform B on",
	tiles = {texture_prefix .. "platformB_on.png"},
	groups = {mapmaker = 1, periodic = 5, not_in_creative_inventory = 1},
})
minetest.register_node(mod_prefix .."platformB_off", {
	description = "Platform B off",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {texture_prefix .. "platformB_off.png"},
	walkable = false,
	groups = {mapmaker = 1, periodic = 5},
})



-- Slabs
local function register_slab(node_name, texture_name)
	local node_def = table.copy(minetest.registered_nodes[node_name])
	node_def.description = node_def.description .. " slab"
	node_def.drawtype = "nodebox"
	node_def.tiles = {node_def.tiles[1], node_def.tiles[1], texture_prefix .. texture_name .. "_half.png"}
	node_def.node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}}
	node_def.on_place = minetest.rotate_node
	node_def.paramtype = "light"
	node_def.paramtype2 = "facedir"
	minetest.register_node(node_name .. "_slab", node_def)
end
register_slab("jumper:ground", "ground")
register_slab("jumper:path", "path")
-- doesn't work properly bacause of how the node is detected.
-- register_slab("jumper:danger")

local function register_pillar(node_name, texture_name)
	local node_def = table.copy(minetest.registered_nodes[node_name])
	node_def.description = node_def.description .. " pillar"
	node_def.drawtype = "nodebox"
	node_def.tiles = {texture_prefix .. texture_name .. "_pillar_top.png",
		texture_prefix .. texture_name .. "_pillar_top.png",
		texture_prefix .. texture_name .. "_pillar_side.png"}
	node_def.node_box = {type = "fixed", fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}}
	node_def.on_place = minetest.rotate_node
	node_def.paramtype = "light"
	node_def.paramtype2 = "facedir"
	minetest.register_node(node_name .. "_pillar", node_def)
end
register_pillar("jumper:ground", "ground")
register_pillar("jumper:path", "path")
