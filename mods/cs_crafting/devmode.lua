
minetest.register_chatcommand("devmode", {

    params = "",
    description = "gives you devmode/creative privileges",
    privs = {privs=true},
    func = function(name, param)
        local haspriv, _ = core.check_player_privs(name, "devmode")
        core.change_player_privs(name, {devmode=not haspriv})
    end

})
