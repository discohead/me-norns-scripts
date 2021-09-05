instrument_name = 'ms'
instrument_table = {
    note=3,
    mute=94,
    level=95,
    pan=10,
    pitch=16,
    decay=80,
    sample_start=19,
    sample_length=20,
    cutoff=74,
    resonance=71,
    delay_send=12,
    reverb_send=13,
    volume_dist=7,
    swing=15,
    chance=14,
    loop=17,
    reverse=18,
    lfo_speed=102,
    lfo_mult=103,
    lfo_fade=104,
    lfo_dest=105,
    lfo_wave=106,
    lfo_phase=107,
    lfo_reset=108,
    lfo_depth=109,
    delay_time=85,
    delay_fb=86,
    reverb_size=87,
    reverb_tone=88,
}
device_name = 'Elektron Model:Samples'

-----------------------------------------------------

local master_string = [[local NAME = {}

for port, device in ipairs(midi.vports) do
    if device.name == 'DEVICESTRING' then
        NAME.device = midi.connect(port)
        break
    end
end

-- Async note_off helper, passed into clock.run in note()
local function note_off(channel, midi_note, duration)
    clock.sleep(duration)
    NAME.device:note_off(midi_note, 0, channel)
end

function NAME:note(channel, note, velocity, duration)
    if type(channel) == 'table' then
        channel, note, velocity, duration = table.unpack(channel)
    end
    channel, note, velocity, duration = channel or 1, note or 48, velocity or 100, duration or 0.0625
    NAME.device:note_on(note, velocity, channel)
    clock.run(note_off, channel, note, duration)
end

]]

local param_string = [[function NAME:PARAM(channel, value)
    NAME.device:cc(CCNUMBER, value, channel)
end

]]

local function save_code(code_string, filename)
    filename = _path.code..'me-norns-scripts/'..filename
    local file, err = io.open(filename, "wb")
    if err then return err end
    file:write(code_string)
    file:close()
end

function make_instrument(name, device, t)
    local instrument_code= string.gsub(master_string, 'DEVICESTRING', device)
    for parameter_name, cc_number in pairs(t) do
        local param_code = string.gsub(param_string, 'PARAM', parameter_name)
        param_code = string.gsub(param_code, 'CCNUMBER', cc_number)
        instrument_code = instrument_code..param_code
    end
    instrument_code = instrument_code..'return NAME'
    instrument_code = string.gsub(instrument_code, 'NAME', name)
    print(save_code(instrument_code, name..'.lua'))
end

function init()
  make_instrument(instrument_name, device_name, instrument_table)
end

