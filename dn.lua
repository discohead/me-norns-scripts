local dn = {}

for port, device in ipairs(midi.vports) do
    if device.name == 'Elektron Digitone' then
        dn.device = midi.connect(port)
        break
    end
end

-- Async note_off helper, passed into clock.run in note()
local function note_off(channel, midi_note, duration)
    clock.sleep(duration)
    dn.device:note_off(midi_note, 0, channel)
end

function dn:note(channel, note, velocity, duration)
    if type(channel) == 'table' then
        channel, note, velocity, duration = table.unpack(channel)
    end
    channel, note, velocity, duration = channel or 1, note or 48, velocity or 100, duration or 0.0625
    dn.device:note_on(note, velocity, channel)
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

function dn:lfo1_sph(channel, value)
    dn.device:cc(112, value, channel)
end

function dn:trig_lfo(channel, value)
    dn.device:cc(14, value, channel)
end

function dn:lfo2_speed_hr(channel, value)
    set_nrpn(dn.device, 1, 57, value, channel)
end

function dn:pan_hr(channel, value)
    set_nrpn(dn.device, 1, 37, value, channel)
end

function dn:ratio_b1_offset_hr(channel, value)
    set_nrpn(dn.device, 1, 97, value, channel)
end

function dn:delay_feedback_hr(channel, value)
    set_nrpn(dn.device, 2, 13, value, channel)
end

function dn:volume_hr(channel, value)
    set_nrpn(dn.device, 1, 38, value, channel)
end

function dn:delay_vol(channel, value)
    dn.device:cc(20, value, channel)
end

function dn:env_a_decay(channel, value)
    dn.device:cc(76, value, channel)
end

function dn:b_level(channel, value)
    dn.device:cc(82, value, channel)
end

function dn:lfo2_depth_hr(channel, value)
    set_nrpn(dn.device, 1, 64, value, channel)
end

function dn:chorus_width(channel, value)
    dn.device:cc(71, value, channel)
end

function dn:portamento_on(channel, value)
    dn.device:cc(16, value, channel)
end

function dn:detune_hr(channel, value)
    set_nrpn(dn.device, 1, 77, value, channel)
end

function dn:op_mix_hr(channel, value)
    set_nrpn(dn.device, 1, 79, value, channel)
end

function dn:amp_attack(channel, value)
    dn.device:cc(104, value, channel)
end

function dn:feedback_hr(channel, value)
    set_nrpn(dn.device, 1, 78, value, channel)
end

function dn:sostenuto(channel, value)
    dn.device:cc(66, value, channel)
end

function dn:in_l_vol_hr(channel, value)
    set_nrpn(dn.device, 2, 30, value, channel)
end

function dn:pattern_mute_hr(channel, value)
    set_nrpn(dn.device, 1, 104, value, channel)
end

function dn:delay_hp(channel, value)
    dn.device:cc(72, value, channel)
end

function dn:lfo1_wave(channel, value)
    dn.device:cc(111, value, channel)
end

function dn:pattern_vol(channel, value)
    dn.device:cc(95, value, channel)
end

function dn:send_chorus_hr(channel, value)
    set_nrpn(dn.device, 1, 41, value, channel)
end

function dn:reverb_send_lr_hr(channel, value)
    set_nrpn(dn.device, 2, 36, value, channel)
end

function dn:in_l_pan(channel, value)
    dn.device:cc(78, value, channel)
end

function dn:reverb_shelf_freq(channel, value)
    dn.device:cc(75, value, channel)
end

function dn:chorus_delay_send_hr(channel, value)
    set_nrpn(dn.device, 2, 4, value, channel)
end

function dn:amp_sustain(channel, value)
    dn.device:cc(106, value, channel)
end

function dn:root(channel, value)
    dn.device:cc(3, value, channel)
end

function dn:in_r_chorus_hr(channel, value)
    set_nrpn(dn.device, 2, 102, value, channel)
end

function dn:algorithm(channel, value)
    dn.device:cc(90, value, channel)
end

function dn:width_hr(channel, value)
    set_nrpn(dn.device, 1, 25, value, channel)
end

function dn:lfo2_sph(channel, value)
    dn.device:cc(118, value, channel)
end

function dn:delay_send_lr_hr(channel, value)
    set_nrpn(dn.device, 2, 35, value, channel)
end

function dn:base_hr(channel, value)
    set_nrpn(dn.device, 1, 24, value, channel)
end

function dn:chorus_send_lr_hr(channel, value)
    set_nrpn(dn.device, 2, 34, value, channel)
end

function dn:filter_release(channel, value)
    dn.device:cc(73, value, channel)
end

function dn:env_a_reset(channel, value)
    dn.device:cc(85, value, channel)
end

function dn:in_r_reverb_hr(channel, value)
    set_nrpn(dn.device, 2, 104, value, channel)
end

function dn:ratio_b_hr(channel, value)
    set_nrpn(dn.device, 1, 75, value, channel)
end

function dn:ratio_a_offset_hr(channel, value)
    set_nrpn(dn.device, 1, 96, value, channel)
end

function dn:filter_attack(channel, value)
    dn.device:cc(70, value, channel)
end

function dn:lfo2_mode(channel, value)
    dn.device:cc(119, value, channel)
end

function dn:dual_mono(channel, value)
    dn.device:cc(83, value, channel)
end

function dn:lfo1_fade(channel, value)
    dn.device:cc(109, value, channel)
end

function dn:in_r_delay_hr(channel, value)
    set_nrpn(dn.device, 2, 103, value, channel)
end

function dn:amp_drive_hr(channel, value)
    set_nrpn(dn.device, 1, 36, value, channel)
end

function dn:in_r_vol_hr(channel, value)
    set_nrpn(dn.device, 2, 32, value, channel)
end

function dn:lfo1_dest(channel, value)
    dn.device:cc(110, value, channel)
end

function dn:mute(channel, value)
    dn.device:cc(94, value, channel)
end

function dn:in_l_chorus_hr(channel, value)
    set_nrpn(dn.device, 2, 34, value, channel)
end

function dn:portamento_time(channel, value)
    dn.device:cc(15, value, channel)
end

function dn:lfo1_mult(channel, value)
    dn.device:cc(108, value, channel)
end

function dn:reverb_shelf_gain_hr(channel, value)
    set_nrpn(dn.device, 2, 23, value, channel)
end

function dn:filter_freq_hr(channel, value)
    set_nrpn(dn.device, 1, 20, value, channel)
end

function dn:in_r_pan(channel, value)
    dn.device:cc(79, value, channel)
end

function dn:amp_release(channel, value)
    dn.device:cc(107, value, channel)
end

function dn:sustain(channel, value)
    dn.device:cc(64, value, channel)
end

function dn:env_b_decay(channel, value)
    dn.device:cc(80, value, channel)
end

function dn:in_l_reverb_hr(channel, value)
    set_nrpn(dn.device, 2, 36, value, channel)
end

function dn:ratio_a(channel, value)
    dn.device:cc(92, value, channel)
end

function dn:lfo1_mode(channel, value)
    dn.device:cc(113, value, channel)
end

function dn:master_overdrive_hr(channel, value)
    set_nrpn(dn.device, 2, 37, value, channel)
end

function dn:reverb_vol(channel, value)
    dn.device:cc(23, value, channel)
end

function dn:reverb_lp(channel, value)
    dn.device:cc(77, value, channel)
end

function dn:trig_length(channel, value)
    dn.device:cc(5, value, channel)
end

function dn:reverb_hp(channel, value)
    dn.device:cc(76, value, channel)
end

function dn:reverb_decay(channel, value)
    dn.device:cc(74, value, channel)
end

function dn:a_delay(channel, value)
    dn.device:cc(83, value, channel)
end

function dn:env_a_end(channel, value)
    dn.device:cc(77, value, channel)
end

function dn:lfo2_wave(channel, value)
    dn.device:cc(117, value, channel)
end

function dn:b_delay(channel, value)
    dn.device:cc(86, value, channel)
end

function dn:filter_decay(channel, value)
    dn.device:cc(71, value, channel)
end

function dn:reverb_predelay_hr(channel, value)
    set_nrpn(dn.device, 2, 20, value, channel)
end

function dn:ratio_b2_offset_hr(channel, value)
    set_nrpn(dn.device, 1, 98, value, channel)
end

function dn:trig_filter(channel, value)
    dn.device:cc(13, value, channel)
end

function dn:delay_reverb_send_hr(channel, value)
    set_nrpn(dn.device, 2, 16, value, channel)
end

function dn:track_level(channel, value)
    dn.device:cc(95, value, channel)
end

function dn:resonance_hr(channel, value)
    set_nrpn(dn.device, 1, 21, value, channel)
end

function dn:harmonics_hr(channel, value)
    set_nrpn(dn.device, 1, 76, value, channel)
end

function dn:delay_lp(channel, value)
    dn.device:cc(73, value, channel)
end

function dn:phase_reset(channel, value)
    dn.device:cc(89, value, channel)
end

function dn:delay_pingpong_hr(channel, value)
    set_nrpn(dn.device, 2, 11, value, channel)
end

function dn:filter_type(channel, value)
    dn.device:cc(74, value, channel)
end

function dn:delay_time_hr(channel, value)
    set_nrpn(dn.device, 2, 10, value, channel)
end

function dn:chorus_vol(channel, value)
    dn.device:cc(14, value, channel)
end

function dn:in_l_delay_hr(channel, value)
    set_nrpn(dn.device, 2, 35, value, channel)
end

function dn:chorus_hp(channel, value)
    dn.device:cc(70, value, channel)
end

function dn:env_b_reset(channel, value)
    dn.device:cc(88, value, channel)
end

function dn:env_b_end(channel, value)
    dn.device:cc(81, value, channel)
end

function dn:chorus_speed_hr(channel, value)
    set_nrpn(dn.device, 2, 1, value, channel)
end

function dn:chorus_depth_hr(channel, value)
    set_nrpn(dn.device, 2, 0, value, channel)
end

function dn:ratio_c_offset_hr(channel, value)
    set_nrpn(dn.device, 1, 95, value, channel)
end

function dn:lfo2_dest(channel, value)
    dn.device:cc(116, value, channel)
end

function dn:lfo2_fade(channel, value)
    dn.device:cc(115, value, channel)
end

function dn:lfo2_mult(channel, value)
    dn.device:cc(114, value, channel)
end

function dn:lfo1_depth_hr(channel, value)
    set_nrpn(dn.device, 1, 55, value, channel)
end

function dn:chorus_reverb_send_hr(channel, value)
    set_nrpn(dn.device, 2, 5, value, channel)
end

function dn:velocity(channel, value)
    dn.device:cc(4, value, channel)
end

function dn:lfo1_speed_hr(channel, value)
    set_nrpn(dn.device, 1, 48, value, channel)
end

function dn:amp_env_reset(channel, value)
    dn.device:cc(102, value, channel)
end

function dn:filter_sustain(channel, value)
    dn.device:cc(72, value, channel)
end

function dn:amp_decay(channel, value)
    dn.device:cc(105, value, channel)
end

function dn:send_delay_hr(channel, value)
    set_nrpn(dn.device, 1, 40, value, channel)
end

function dn:filter_env_depth_hr(channel, value)
    set_nrpn(dn.device, 1, 23, value, channel)
end

function dn:filter_env_delay(channel, value)
    dn.device:cc(43, value, channel)
end

function dn:b_trig(channel, value)
    dn.device:cc(87, value, channel)
end

function dn:send_reverb_hr(channel, value)
    set_nrpn(dn.device, 1, 39, value, channel)
end

function dn:delay_width_hr(channel, value)
    set_nrpn(dn.device, 2, 12, value, channel)
end

function dn:a_trig(channel, value)
    dn.device:cc(84, value, channel)
end

function dn:a_level(channel, value)
    dn.device:cc(78, value, channel)
end

function dn:env_b_attack(channel, value)
    dn.device:cc(79, value, channel)
end

function dn:env_a_attack(channel, value)
    dn.device:cc(75, value, channel)
end

function dn:ratio_c(channel, value)
    dn.device:cc(91, value, channel)
end

return dn