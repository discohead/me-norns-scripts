local mc = {}

for port, device in ipairs(midi.vports) do
    if device.name == 'Elektron Model:Cycles' then
        mc.device = midi.connect(port)
        break
    end
end

-- Async note_off helper, passed into clock.run in note()
local function note_off(channel, midi_note, duration)
    clock.sleep(duration)
    mc.device:note_off(midi_note, 0, channel)
end

function mc:note(channel,velocity, duration, note)
    if type(channel) == 'table' then
        channel, velocity, duration, note = table.unpack(channel)
    end
    channel, velocity, duration = channel or 1, velocity or 100, duration or 0.0625
    note = note or channel - 1
    mc.device:note_on(note, velocity, channel)
    clock.run(note_off, channel, note, duration)
end

function mc:level(channel, value)
    mc.device:cc(95, value, channel)
end

function mc:reverb_tone(channel, value)
    mc.device:cc(88, value, channel)
end

function mc:mute(channel, value)
    mc.device:cc(94, value, channel)
end

function mc:shape(channel, value)
    mc.device:cc(17, value, channel)
end

function mc:track_note(channel, value)
    mc.device:cc(3, value, channel)
end

function mc:lfo_mult(channel, value)
    mc.device:cc(103, value, channel)
end

function mc:reverb_send(channel, value)
    mc.device:cc(13, value, channel)
end

function mc:swing(channel, value)
    mc.device:cc(15, value, channel)
end

function mc:volume_dist(channel, value)
    mc.device:cc(7, value, channel)
end

function mc:reverb_size(channel, value)
    mc.device:cc(87, value, channel)
end

function mc:delay_fb(channel, value)
    mc.device:cc(86, value, channel)
end

function mc:delay_time(channel, value)
    mc.device:cc(85, value, channel)
end

function mc:pan(channel, value)
    mc.device:cc(10, value, channel)
end

function mc:lfo_speed(channel, value)
    mc.device:cc(102, value, channel)
end

function mc:color(channel, value)
    mc.device:cc(16, value, channel)
end

function mc:lfo_phase(channel, value)
    mc.device:cc(107, value, channel)
end

function mc:delay_send(channel, value)
    mc.device:cc(12, value, channel)
end

function mc:chance(channel, value)
    mc.device:cc(14, value, channel)
end

function mc:punch(channel, value)
    mc.device:cc(66, value, channel)
end

function mc:sweep(channel, value)
    mc.device:cc(18, value, channel)
end

function mc:lfo_reset(channel, value)
    mc.device:cc(108, value, channel)
end

function mc:lfo_wave(channel, value)
    mc.device:cc(106, value, channel)
end

function mc:lfo_dest(channel, value)
    mc.device:cc(105, value, channel)
end

function mc:gate(channel, value)
    mc.device:cc(67, value, channel)
end

function mc:decay(channel, value)
    mc.device:cc(80, value, channel)
end

function mc:contour(channel, value)
    mc.device:cc(19, value, channel)
end

function mc:lfo_fade(channel, value)
    mc.device:cc(104, value, channel)
end

function mc:pitch(channel, value)
    mc.device:cc(65, value, channel)
end

function mc:lfo_depth(channel, value)
    mc.device:cc(109, value, channel)
end

return mc