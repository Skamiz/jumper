#jumper
A game for the minetest engine, which is focused on jump'n run gameplay.

##Curent game mechanics
Besides the normal mechanics featured in most minetest games, Jumper currently offers:
-A checkpoint system.
-Two nodes which alternatingly become unwalkable.

##Building a map
When you start a world in creative mode, anybody who joins is granted the fast and fly privilage and the ability to dig nodes.
When you start the world without creative mode the privs are automaticaly removed.

##Before publishing a map
Don't forget to place the player at the intended start.
Disable creative mode
Tie the game to the map by making it a:
(form the lua_api.txt)
###World-specific game
"It is possible to include a game in a world; in this case, no mods or
games are loaded or checked from anywhere else.

This is useful for e.g. adventure worlds and happens if the `<worldname>/game/`
directory exists.

Mods should then be placed in `<worldname>/game/mods/`."


This prevents the map from breaking when the game changes nodename definitions/mechanics/etc...
