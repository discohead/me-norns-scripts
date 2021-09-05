local ms = {}

for port, device in ipairs(midi.vports) do
    if device.name == 'Elektron Model:Samples' then
        ms.device = midi.connect(port)
        break
    end
end

-- Async note_off helper, passed into clock.run in note()
local function note_off(channel, midi_note, duration)
    clock.sleep(duration)
    ms.device:note_off(midi_note, 0, channel)
end

function ms:note(channel,velocity, duration, note)
    if type(channel) == 'table' then
        channel, velocity, duration, note = table.unpack(channel)
    end
    channel, velocity, duration = channel or 1, velocity or 100, duration or 0.0625
    local trigger_note = channel - 1
    if note then
        self:track_note(channel, note)
    end
    ms.device:note_on(trigger_note, velocity, channel)
    clock.run(note_off, channel, trigger_note, duration)
end

function ms:mute(channel, value)
    ms.device:cc(94, value, channel)
end

function ms:lfo_speed(channel, value)
    ms.device:cc(102, value, channel)
end

function ms:level(channel, value)
    ms.device:cc(95, value, channel)
end

function ms:decay(channel, value)
    ms.device:cc(80, value, channel)
end

function ms:sample_length(channel, value)
    ms.device:cc(20, value, channel)
end

function ms:pan(channel, value)
    ms.device:cc(10, value, channel)
end

function ms:chance(channel, value)
    ms.device:cc(14, value, channel)
end

function ms:track_note(channel, value)
    ms.device:cc(3, value, channel)
end

function ms:swing(channel, value)
    ms.device:cc(15, value, channel)
end

function ms:cutoff(channel, value)
    ms.device:cc(74, value, channel)
end

function ms:delay_fb(channel, value)
    ms.device:cc(86, value, channel)
end

function ms:lfo_dest(channel, value)
    ms.device:cc(105, value, channel)
end

function ms:lfo_reset(channel, value)
    ms.device:cc(108, value, channel)
end

function ms:volume_dist(channel, value)
    ms.device:cc(7, value, channel)
end

function ms:reverb_size(channel, value)
    ms.device:cc(87, value, channel)
end

function ms:delay_send(channel, value)
    ms.device:cc(12, value, channel)
end

function ms:sample_start(channel, value)
    ms.device:cc(19, value, channel)
end

function ms:loop(channel, value)
    ms.device:cc(17, value, channel)
end

function ms:reverb_send(channel, value)
    ms.device:cc(13, value, channel)
end

function ms:lfo_depth(channel, value)
    ms.device:cc(109, value, channel)
end

function ms:lfo_phase(channel, value)
    ms.device:cc(107, value, channel)
end

function ms:lfo_mult(channel, value)
    ms.device:cc(103, value, channel)
end

function ms:lfo_fade(channel, value)
    ms.device:cc(104, value, channel)
end

function ms:resonance(channel, value)
    ms.device:cc(71, value, channel)
end

function ms:lfo_wave(channel, value)
    ms.device:cc(106, value, channel)
end

function ms:reverse(channel, value)
    ms.device:cc(18, value, channel)
end

function ms:pitch(channel, value)
    ms.device:cc(16, value, channel)
end

function ms:delay_time(channel, value)
    ms.device:cc(85, value, channel)
end

function ms:reverb_tone(channel, value)
    ms.device:cc(88, value, channel)
end

return ms