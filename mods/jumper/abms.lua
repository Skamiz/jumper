minetest.register_abm({
    label = "Periodic blocks",
    nodenames = "group:periodic",
    interval = 3, --The sound file has been manualy synchronized with this.
    chance = 1,
    catch_up = false,
    action = jumper.get_switcher() --is defined in misc.lua
})
