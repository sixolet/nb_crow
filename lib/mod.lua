local mod = require 'core/mods'
local music = require 'lib/musicutil'

local ASL_SHAPES = {'linear','sine','logarithmic','exponential','now'}


if note_players == nil then
    note_players = {}
end


function add_player(cv, env)
    local player = {
        ext = "_"..cv.."_"..env,
        count = 0,
        tuning = false,
    }

    function player:add_params()
        params:add_group("nb_crow_"..self.ext, "crow "..cv.."/"..env, 11)
        params:add_control("nb_crow_attack_time"..self.ext, "attack", controlspec.new(0.0001, 3, 'exp', 0, 0.1, "s"))
        params:add_option("nb_crow_attack_shape"..self.ext, "attack shape", ASL_SHAPES, 3)
        params:add_control("nb_crow_decay_time"..self.ext, "decay", controlspec.new(0.0001, 10, 'exp', 0, 1.0, "s"))
        params:add_option("nb_crow_decay_shape"..self.ext, "decay shape", ASL_SHAPES, 4)
        params:add_control("nb_crow_sustain"..self.ext, "sustain", controlspec.new(0.0, 1.0, 'lin', 0, 0.75, ""))
        params:add_control("nb_crow_release_time"..self.ext, "release", controlspec.new(0.0001, 10, 'exp', 0, 0.5, "s"))
        params:add_option("nb_crow_release_shape"..self.ext, "release shape", ASL_SHAPES, 4)
        params:add_control("nb_crow_portomento"..self.ext, "portomento", controlspec.new(0.0, 1, 'lin', 0, 0.0, "s"))
        params:add_binary("nb_crow_legato"..self.ext, "legato", "toggle", 1)
        params:add_control("nb_crow_freq"..self.ext, "tuned to", controlspec.new(20, 4000, 'exp', 0, 440, 'Hz', 0.0003))
        params:add_binary("nb_crow_tune"..self.ext, "tune", "trigger")
        params:set_action("nb_crow_tune"..self.ext, function()
            self:tune()
        end)
        params:hide("nb_crow_"..self.ext)
    end

    local function freq_to_note_num_float(freq)
        local reference = music.note_num_to_freq(60)
        local ratio = freq/reference
        return 60 + 12*math.log(ratio)/math.log(2)
    end

    function player:note_on(note, vel)
        if self.tuning then return end
        -- I have zero idea why I have to add 50 cents to the tuning for it to sound right.
        -- But I do. WTF.
        local halfsteps = note - freq_to_note_num_float(params:get("nb_crow_freq"..self.ext))
        local v8 = halfsteps/12
        local v_vel = vel * 10
        local attack = params:get("nb_crow_attack_time"..self.ext)
        local attack_shape = ASL_SHAPES[params:get("nb_crow_attack_shape"..self.ext)]
        local decay = params:get("nb_crow_decay_time"..self.ext)
        local decay_shape = ASL_SHAPES[params:get("nb_crow_decay_shape"..self.ext)]
        local sustain = params:get("nb_crow_sustain"..self.ext)
        local portomento = params:get("nb_crow_portomento"..self.ext)
        local legato = params:get("nb_crow_legato"..self.ext)
        if self.count > 0 then
            crow.output[cv].action = string.format("{ to(%f,%f,sine) }", v8, portomento)
            crow.output[cv]()
        else
            crow.output[cv].volts = v8
        end
        local action
        if self.count > 0 and legato > 0 then
            action = string.format("{ to(%f,%f,'%s') }", v_vel*sustain, decay, decay_shape)
        else
            action = string.format("{ to(%f,%f,'%s'), to(%f,%f,'%s') }", v_vel, attack, attack_shape, v_vel*sustain, decay, decay_shape)
        end
        print(action)
        crow.output[env].action = action
        crow.output[env]()
        self.count = self.count + 1
    end

    function player:note_off(note)
        if self.tuning then return end
        self.count = self.count - 1
        if self.count <= 0 then
            self.count = 0
            local release = params:get("nb_crow_release_time"..self.ext)
            local release_shape = ASL_SHAPES[params:get("nb_crow_release_shape"..self.ext)]
            crow.output[env].action = string.format("{ to(%f,%f,'%s') }", 0, release, release_shape)
            crow.output[env]()
        end
    end

    function player:set_slew(s)
        params:set("nb_crow_portomento"..self.ext, s)
    end

    function player:describe(note)
        return {
            name = "crow "..cv.."/"..env,
            supports_bend = false,
            supports_slew = true,
            modulate_description = "unsupported",
        }
    end

    function player:active()
        params:show("nb_crow_"..self.ext)
        _menu.rebuild_params()
    end

    function player:inactive()
        params:hide("nb_crow_"..self.ext)
        _menu.rebuild_params()
    end

    function player:tune()
        print("OMG TUNING")
        self.tuning = true
        crow.output[cv].volts = 0
        crow.output[env].volts = 5

        local p = poll.set("pitch_in_l")
        p.callback = function(f) 
            print("in > "..string.format("%.2f",f))
            params:set("nb_crow_freq"..self.ext, f)
        end
        p.time = 0.25
        p:start()
        -- This is crow pitch tracking that doesn't work
        -- crow.input[1].freq = function(f)
        --     print("freq is", f)
        --     params:set("nb_crow_freq"..self.ext, f)         
        -- end
        -- crow.input[1].mode( 'freq', 2)
        clock.run(function()
             clock.sleep(10)
             p:stop()
             crow.output[env].volts = 0
             -- crow.input[1].mode('none')
             clock.sleep(0.2)
             self.tuning = false
        end)
    end
    note_players["crow "..cv.."/"..env] = player
end

mod.hook.register("script_pre_init", "nb crow pre init", function()
    add_player(1, 2)
    add_player(3, 4)
end)