local FH2 = {}

for port, device in ipairs(midi.vports) do
    if device.name == 'FH-2' then
        FH2.device = midi.connect(port)
        break
    end
end

-- Async note_off helper, passed into clock.run in note()
local function note_off(channel, midi_note, duration)
    clock.sleep(duration)
    FH2.device:note_off(midi_note, 0, channel)
end

function FH2:note(voice, note, velocity, duration, modwheel)
    if type(voice) == 'table' then
        voice, note, velocity, duration, modwheel = table.unpack(voice)
    end
    voice, note, velocity, duration = voice or 1, note or 48, velocity or 100, duration or 0.0625
    if modwheel then
        FH2.device:cc(1, modwheel, voice)
    end
    FH2.device:note_on(note, velocity, voice)
    clock.run(note_off, voice, note, duration)
end

function FH2:mod(voice, modwheel)
    FH2.device:cc(1, modwheel, voice)
end

FH2.dmk4 = {channel=5}

function FH2.dmk4:param(param_number, value)
    FH2.device:cc(param_number + 1, value, FH2.dmk4.channel)
end

function FH2.dmk4:set_z(value)
    FH2.device:cc(17, value, FH2.dmk4.channel)
end

function FH2.dmk4:algorithm(algo_number)
    FH2.device:cc(18, algo_number, FH2.dmk4.channel)
end

function FH2.dmk4:free_z()
    FH2.device:cc(19, 127, FH2.dmk4.channel)
end

function FH2.dmk4:note(note, velocity, duration)
    note, velocity, duration = note or 48, velocity or 100, duration or 0.0625
    FH2.device:note_on(note, velocity, FH2.dmk4.channel)
    clock.run(note_off, FH2.dmk4.channel, note, duration)
end

return FH2