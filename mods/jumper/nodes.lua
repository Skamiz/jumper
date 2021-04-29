local mod_name = minetest.get_current_modname()
local mod_prefix = mod_name .. ":"
local texture_prefix = mod_name .. "_"


-- Do nothing
minetest.register_node(mod_prefix .."ground", {
	description = "Ground",
	tiles = {texture_prefix .. "ground.png"},
	on_secondary_use = function(itemstack, user, pointed_thing)

	end,
})
minetest.register_node(mod_prefix .."path", {
	description = "Path",
	tiles = {texture_prefix .. "path.png"},
})
local box = {{-0.5, 1, -1.5, 1.5, 1, 1.6}}
minetest.register_node(mod_prefix .."flat", {
	description = "A disc",
	drawtype = "nodebox",
	tiles = {texture_prefix .. "path.png"},
	node_box = {type = "fixed", fixed = box},
	collision_box = {type = "fixed", fixed = box},
	selection_box = {type = "fixed", fixed = box},
})

-- Also just for buiding
minetest.register_node(mod_prefix .."glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {texture_prefix .. "glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
})
minetest.register_node(mod_prefix .."light", {
	description = "Light",
	tiles = {texture_prefix .. "light.png"},
	light_source = 14,
})

-- Checkpoint system
minetest.register_node(mod_prefix .."checkpoint", {
	description = "Checkpoint",
	tiles = {texture_prefix .. "checkpoint.png"},
	groups = {checkpoint = 1, on_walkover = 1},
	_on_walkover = function(player)
		set_checkpoint(player)
	end,
})
minetest.register_node(mod_prefix .."danger", {
	description = "Danger",
	tiles = {texture_prefix .. "danger.png"},
	groups = {danger = 1, on_walkover = 1},
	_on_walkover = function(player)
		move_to_checkpoint(player)
	end,
})

-- Timer system
minetest.register_node(mod_prefix .."timer_start", {
	description = "Timer Start",
	tiles = {texture_prefix .. "timer_start.png"},
	groups = {on_walkover = 1},
	_on_walkover = function(player)
		start_timer(player)
	end,
})
minetest.register_node(mod_prefix .."timer_end", {
	description = "Timer End",
	tiles = {texture_prefix .. "timer_end.png"},
	groups = {on_walkover = 1},
	_on_walkover = function(player)
		end_timer(player)
	end,
})

-- Special properties
minetest.register_node(mod_prefix .."ice", {
	description = "Ice",
	drawtype = "glasslike",
	tiles = {texture_prefix .. "ice.png"},
	-- for some reason this is neccesary since otherwise the node goes full on invissible in the inventory
	inventory_image = "[inventorycube{jumper_ice.png&[noalpha{jumper_ice.png&[noalpha{jumper_ice.png&[noalpha",
	use_texture_alpha = "blend",
	paramtype = "light",
	groups = {slippery = 3},
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
	selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -7 / 16, 0.5},
        },
    },
})
minetest.register_node(mod_prefix .."chain", {
	description = "Chain",
	drawtype = "plantlike",
	tiles = {texture_prefix .. "chain.png", texture_prefix .. "chain.png^[transformR180"},
	-- inventory_image = texture_prefix .. "grid.png",
	-- wield_image  = texture_prefix .. "grid.png",
	climbable = true,
	walkable = false,
	-- paramtype2 = "wallmounted",
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
        type = "fixed",
        fixed = {
            {-2/16, -0.5, -2/16, 2/16, 8/16, 2/16},
        },
    },
})
minetest.register_node(mod_prefix .."bouncy", {
	description = "Bouncy",
	tiles = {texture_prefix .. "bouncy.png"},
	groups = {bouncy = 100, disable_jump = 1},
})

-- Timer nodes(with awfull naming scheme, but from a players point it makes no difference so it's good enough for now)
minetest.register_node(mod_prefix .."platformA_on", {
	description = "Platform A on",
	tiles = {texture_prefix .. "platformA_on.png"},
	groups = {periodic = 5},
})
minetest.register_node(mod_prefix .."platformA_off", {
	description = "Platform A off",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {texture_prefix .. "platformA_off.png"},
	walkable = false,
	groups = {periodic = 5, not_in_creative_inventory = 1},
})
minetest.register_node(mod_prefix .."platformB_on", {
	description = "Platform B on",
	tiles = {texture_prefix .. "platformB_on.png"},
	groups = {periodic = 5, not_in_creative_inventory = 1},
})
minetest.register_node(mod_prefix .."platformB_off", {
	description = "Platform B off",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {texture_prefix .. "platformB_off.png"},
	walkable = false,
	groups = {periodic = 5},
})





minetest.register_node(mod_prefix .."telepad", {
	description = "Telepad",
	tiles = {texture_prefix .. "telepad.png"},
	groups = {on_walkover = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
		-- meta:set_string("formspec", [[
		-- 	formspec_version[4]
		-- 	size[10.25,6.5]
		-- 	list[context;main;4.625,0.25;1,1]
		-- 	list[current_player;main;0.25,1.5;8,4]
		-- 	listring[]
		-- ]])
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if stack:get_name() == "jumper:pos_ticket" and stack:get_meta():contains("pos") then
			return 1
		else
			return 0
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker and clicker:get_player_name() and minetest.is_creative_enabled(clicker:get_player_name()) then
			local pos = pointed_thing.under
			-- TODO: clean this up
			minetest.show_formspec(clicker:get_player_name(), "jumper:telepad", [[
				formspec_version[4]
				size[10.25,6.5] ]] ..
				"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;4.625,0.25;1,1]" ..
			[[	list[current_player;main;0.25,1.5;8,4]
				listring[]
			]])
		end
	end,
	_on_walkover = function(player, node_pos)
		local node_meta = minetest.get_meta(node_pos)
		local inv = node_meta:get_inventory()
		if inv:is_empty("main") then return end
		local stack = inv:get_stack("main", 1)
		local stack_meta = stack:get_meta()
		local destination_pos = minetest.string_to_pos(stack_meta:get_string("pos"))
		-- minetest.chat_send_all(minetest.pos_to_string(destination_pos))
		player:set_pos(destination_pos)
	end,
})

minetest.register_node(mod_prefix .. "sign", {
	description = "Sign",
	drawtype = "nodebox",
	tiles = {texture_prefix .. "sign.png"},
	sunlight_propagates = true,
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -6/16, 8/16, -7/16, 6/16},
	},
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local param2 = get_sign_rotation(placer, pointed_thing)
		core.item_place(itemstack, placer, pointed_thing, param2)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker and clicker:get_player_name() and minetest.is_creative_enabled(clicker:get_player_name()) then
			local pos = pointed_thing.under
			local meta = minetest.get_meta(pos)
			local text = meta:get_string("infotext")

			pos = minetest.pos_to_string(pos)
			minetest.show_formspec(clicker:get_player_name(), "jumper:sign",
				"formspec_version[4]" ..
				"size[6,2]" ..
				"field[0.5,0.5;5,1;input;Sign Text:;" .. text .. "]" ..
				"field[-1,-1;1,1;pos;;" .. pos .. "]"
			)
		end
	end,
})
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "jumper:sign" or not fields.pos then return end
	local pos = fields.pos
	pos = minetest.string_to_pos(pos)
	local meta = minetest.get_meta(pos)
	local text = meta:set_string("infotext", fields.input)
end)


minetest.register_node(mod_prefix .. "arrow", {
	description = "Path arrow",
	drawtype = "nodebox",
	tiles = {"jumper_arrow.png"},
	use_texture_alpha = "clip",
	walkable = false,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type = "fixed",
		fixed = {-8/16,- 0.5, -8/16, 8/16, -0.49, 8/16}},
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		local param2 = get_arrow_rotation(placer, pointed_thing)
		minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
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

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		local groups = table.copy(def.groups)
		groups.mapmaker = 1
		minetest.override_item(name, {
			groups = groups
		})
	end
end)
