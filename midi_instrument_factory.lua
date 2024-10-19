instrument_name = 'dn'
instrument_table = {
    root=3,
    mute=94,
    track_level=95,
    velocity=4,
    trig_length=5,
    trig_filter=13,
    trig_lfo=14,
    portamento_time=15,
    portamento_on=16,
    algorithm=90,
    ratio_c=91,
    ratio_a=92,
    ratio_b={1, 75},
    harmonics={1, 76},
    detune={1, 77},
    feedback={1, 78},
    op_mix={1, 79},
    ratio_c_offset={1, 95},
    ratio_a_offset={1, 96},
    ratio_b1_offset={1, 97},
    ratio_b2_offset={1, 98},
    env_a_attack=75,
    env_a_decay=76,
    env_a_end=77,
    a_level=78,
    env_b_attack=79,
    env_b_decay=80,
    env_b_end=81,
    b_level=82,
    a_delay=83,
    a_trig=84,
    env_a_reset=85,
    b_delay=86,
    b_trig=87,
    env_b_reset=88,
    phase_reset=89,
    filter_freq={1, 20},
    resonance={1, 21},
    filter_type=74,
    filter_attack=70,
    filter_decay=71,
    filter_sustain=72,
    filter_release=73,
    filter_env_depth={1, 23},
    filter_env_delay=43,
    base={1, 24},
    width={1, 25},
    amp_attack=104,
    amp_decay=105,
    amp_sustain=106,
    amp_release=107,
    amp_drive={1, 36},
    pan={1, 37},
    volume={1, 38},
    send_chorus={1, 41},
    send_delay={1, 40},
    send_reverb={1, 39},
    amp_env_reset=102,
    lfo1_speed={1, 48},
    lfo1_mult=108,
    lfo1_fade=109,
    lfo1_dest=110,
    lfo1_wave=111,
    lfo1_sph=112,
    lfo1_mode=113,
    lfo1_depth={1, 55},
    lfo2_speed={1, 57},
    lfo2_mult=114,
    lfo2_fade=115,
    lfo2_dest=116,
    lfo2_wave=117,
    lfo2_sph=118,
    lfo2_mode=119,
    lfo2_depth={1, 64},
    chorus_depth={2,0},
    chorus_speed={2,1},
    chorus_hp=70,
    chorus_width=71,
    chorus_delay_send={2,4},
    chorus_reverb_send={2,5},
    chorus_vol=14,
    delay_time={2,10},
    delay_pingpong={2,11},
    delay_width={2,12},
    delay_feedback={2,13},
    delay_hp=72,
    delay_lp=73,
    delay_reverb_send={2,16},
    delay_vol=20,
    reverb_predelay={2,20},
    reverb_decay=74,
    reverb_shelf_freq=75,
    reverb_shelf_gain={2,23},
    reverb_hp=76,
    reverb_lp=77,
    reverb_vol=23,
    master_overdrive={2,37},
    dual_mono=83,
    in_l_vol={2,30},
    in_r_vol={2,32},
    in_l_pan=78,
    in_r_pan=79,
    in_l_chorus={2,34},
    in_r_chorus={2,102},
    in_l_delay={2,35},
    in_r_delay={2,103},
    in_l_reverb={2,36},
    in_r_reverb={2,104},
    chorus_send_lr={2,34},
    delay_send_lr={2,35},
    reverb_send_lr={2,36},
    pattern_vol=95,
    pattern_mute={1,104},
    sustain=64,
    sostenuto=66
}
device_name = 'Elektron Digitone'

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

-- @function set_nrpn: set a 14-bit NRPN value
-- @param dev: a MIDI device
-- @param msb: a 7-bit NRPN MSB
-- @param lsb: a 7-bit NRPN LSB
-- @param val: a 14-bit NRPN value
-- @param ch: MIDI channel
local function set_nrpn(dev, msb, lsb, val, ch)
    dev:cc(0x63, msb, ch); -- NRPN MSB
    dev:cc(0x62, lsb, ch); -- NRPN LSB
    dev:cc(0x06, val >> 7,   ch); -- Data Entry MSB
    dev:cc(0x26, val & 0x7f, ch); -- Data Entry LSB 
    -- not required by MIDI spec, but good practice:
    -- set the active NRPN number to zero/null when we are done
    -- (this avoids unintended value changes from later use of the device) 
    dev:cc(0x63, 0, ch);
    dev:cc(0x62, 0, ch);
end

]]

local param_string = [[function NAME:PARAM(channel, value)
    NAME.device:cc(CCNUMBER, value, channel)
end

]]

local high_res_param_string = [[function NAME:PARAM(channel, value)
    set_nrpn(NAME.device, MSB, LSB, value, channel)
end

]]

local function save_code(code_string, filename)
    -- filename = _path.code..'me-norns-scripts/'..filename
    filename = './'..filename
    local file, err = io.open(filename, "wb")
    if err then return err end
    file:write(code_string)
    file:close()
end

function make_instrument(name, device, t)
    local instrument_code = string.gsub(master_string, 'DEVICESTRING', device)
    for parameter_name, cc_number in pairs(t) do
        local param_code
        if type(cc_number) == 'table' then
            param_code = string.gsub(high_res_param_string, 'PARAM', parameter_name..'_hr')
            local msb, lsb = table.unpack(cc_number)
            param_code = string.gsub(param_code, 'MSB', msb)
            param_code = string.gsub(param_code, 'LSB', lsb)
        else
            param_code = string.gsub(param_string, 'PARAM', parameter_name)
            param_code = string.gsub(param_code, 'CCNUMBER', cc_number)
        end
        instrument_code = instrument_code..param_code
    end
    instrument_code = instrument_code..'return NAME'
    instrument_code = string.gsub(instrument_code, 'NAME', name)
    print(save_code(instrument_code, name..'.lua'))
end

function init()
  make_instrument(instrument_name, device_name, instrument_table)
  print('init called')
end

init()
