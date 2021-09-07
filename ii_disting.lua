local disting = {zero_volt_note = 48}

--- Chord scales for the SD Multisample and Poly Wavetable algorithms.
disting.CHORD_SCALES = {
    major = 0,
    minor = 1,
    dominant = 2,
    diminished = 3,
    dominant_diminished = 4,
    augmented = 5,
    whole = 6,
    chromatic = 7
}

--- Chord shapes for the SD Multisample and Poly Wavetable algorithms.
disting.CHORD_SHAPES = {
    none = 0,
    octave = 1,
    two_octaves = 2,
    root_fifth = 3,
    root_fifth_oct = 4,
    triad = 5,
    triad_oct = 6,
    sus4 = 7,
    sus4_oct = 8,
    sixth = 9,
    sixth_oct = 10,
    seventh = 11,
    seventh_oct = 12,
    ninth = 13
}

--- Arpeggiator modes for the SD multisample and Poly Wavetable algorithms.
disting.ARP_MODES = {
    up = 0,
    down = 1,
    alt = 2,
    alt2 = 3,
    up_oct = 4,
    down_oct = 5,
    alt_oct = 6,
    alt2_oct = 7,
    random = 8
}

--------------------------------
-- local helper functions

-- Convert boolean to 1 or 0
local function b2n(bool) return bool and 1 or 0 end

-- Async note_off helper, passed into clock.run in note()
local function note_off(midi_note, duration)
    clock.sleep(duration)
    crow.ii.disting.note_off(midi_note)
end

-- Async voice_off helper, passed into clock.run in voice()
local function voice_off(voice, duration)
    clock.sleep(duration)
    crow.ii.disting.voice_off(voice)
end

--- Load preset.
-- @tparam number number 1-based preset number
function disting:load_preset(number) crow.ii.disting.load_preset(number) end

--- Save preset.
-- @tparam number number 1-based preset number
function disting:save_preset(number) crow.ii.disting.save_preset(number) end

--- Reset preset.
function disting:reset_preset() crow.ii.disting.reset_preset(0) end

--- Load one of the single algorithms.
-- @tparam number number 1-based algorithm number
function disting:load_algorithm(number) crow.ii.disting.load_algorithm(number) end

--- Set i2c controller to value
-- These messages are used via Mappings
-- @tparam number controller
-- @tparam number value
function disting:set_controller(controller, value)
    crow.ii.disting.set_controller(controller, value)
end

--- Set parameter to value using actual parameter value
-- @tparam number parameter
-- @tparam number value
function disting:set_parameter(parameter, value)
    crow.ii.disting.set_parameter(parameter, value)
end

--- Set parameter to value using 0-16384 range
-- @tparam number parameter
-- @tparam number value
function disting:set_scale_parameter(parameter, value)
    crow.ii.disting.set_scale_parameter(parameter, value)
end

--- Trigger (note_on + note_off) with optional velocity and duration.
-- @tparam number midi_note midi note number 0 to 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration note_on time in seconds, default: 0.0625
function disting:note(midi_note, velocity, duration)
    if type(midi_note) == 'table' then
        tab.print(midi_note)
        midi_note, velocity, duration = table.unpack(midi_note)
        if midi_note ~= nil then
            print('midi_note = '..midi_note)
        end
    end
    midi_note, velocity, duration = midi_note or 48, velocity or 100, duration or 0.0625
    local zero_v_note = disting.zero_volt_note or 48
    crow.ii.disting.note_pitch(midi_note, (midi_note - zero_v_note) / 12)
    crow.ii.disting.note_velocity(midi_note, velocity * 128)
    clock.run(note_off, midi_note, duration)
end

-- Set the pitch of note with note_id
-- Note: note_id is just a reference to a note
-- @tparam number note_id 0 - 127
-- @tparam number pitch volts in 1v/Oct
function disting:note_pitch(note_id, pitch)
    crow.ii.disting.note_pitch(note_id, pitch)
end

-- Turn on note with note_id and optional velocity.
-- @tparam number note_id 0 - 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
function disting:note_on(note_id, velocity)
    velocity = velocity or 100
    crow.ii.disting.note_velocity(note_id, velocity * 128)
end

-- Turn off note with note_id.
-- @tparam number note_id 0 - 127
function disting:note_off(note_id) crow.ii.disting.note_off(note_id) end

--- Kill all notes.
function disting:all_notes_off() crow.ii.disting.all_notes_off(0) end

-- Trigger (voice_on+voice_off) with optional pitch, velocity and duration.
-- @tparam number voice 1 - 8
-- @tparam[opt] number pitch volts in 1v/Oct, default: 0
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration voice_on duration in seconds, default: 0.0625
function disting:voice(voice, pitch, velocity, duration)
    voice = voice - 1
    pitch, velocity, duration = pitch or 0, velocity or 100, duration or 0.0625
    crow.ii.disting.voice_pitch(voice, pitch)
    crow.ii.disting.voice_on(voice, velocity * 128)
    clock.run(voice_off, voice, duration)
end

--- Set voice pitch in v/Oct
-- @tparam number voice 1 - 8
-- @tparam number pitch volts in v/Oct
function disting:voice_pitch(voice, pitch)
    crow.ii.disting.voice_pitch(voice - 1, pitch)
end

--- Turn voice on with optional velocity.
-- @tparam number voice 1 - 8
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
function disting:voice_on(voice, velocity)
    velocity = velocity or 100
    crow.ii.disting.voice_on(voice - 1, velocity * 128)
end

--- Turn voice off.
-- @tparam number voice 1 - 8
function disting:voice_off(voice) crow.ii.disting.voice_off(voice - 1) end

--- Kill all voices.
function disting:all_voices_off()
    for i = 0, 7 do crow.ii.disting.voice_off(i) end
end

--- SD 6 Algorithm.
disting.sd6 = {}

-- Trigger (voice_on+voice_off) with optional velocity and duration.
-- @tparam number voice 1 - 6
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration voice_on duration in seconds, default: 0.0625
function disting.sd6:trig(voice, velocity, duration)
    voice = voice - 1
    velocity, duration = velocity or 100, duration or 0.0625
    crow.ii.disting.voice_on(voice, velocity * 128)
    clock.run(voice_off, voice, duration)
end

--- Turn voice on with optional velocity.
-- @tparam number voice 1 - 6
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
disting.sd6.voice_on = disting.voice_on

--- Turn voice off.
-- @tparam number voice 1 - 6
disting.sd6.voice_off = disting.voice_off

--- Kill all voices.
disting.sd6.all_voices_off = disting.all_voices_off

--- Select the folder to load samples from.
-- @tparam number folder 0 - 999
function disting.sd6:folder(folder) crow.ii.disting.set_parameter(7, folder) end

--- Select the sample for the voice.
-- The special value -1 disables the voice
-- @tparam number voice 1 - 6
-- @tparam number sample -1 - 999
function disting.sd6:sample(voice, sample)
    crow.ii.disting.set_parameter(8 + (voice - 1), sample)
end

--- Set the output assignment for the voice.
-- 1-4 indicate a single output
-- 5 is 1/2 stereo; 6 is 3/4 stereo
-- @tparam number voice 1 - 6
-- @tparam number output 1 - 6
function disting.sd6:output(voice, output)
    crow.ii.disting.set_parameter(14 + (voice - 1), output)
end

--- Set the gain for the voice, in decibels.
-- @tparam number voice 1 - 6
-- @tparam number dB min: -40, max: 6, default: -6
function disting.sd6:gain(voice, dB)
    crow.ii.disting.set_parameter(20 + (voice - 1), dB)
end

--- Set the pan position for the voice.
-- (If assigned to stereo output)
-- @tparam number voice 1 - 6
-- @tparam numbrer position min: -100, max: 100, default: 0
function disting.sd6:pan(voice, position)
    crow.ii.disting.set_parameter(26 + (voice - 1), postion)
end

--- Set the envelope release time for the voice.
-- The value 100 means "infinite" - forever if looped
-- or until it stops if one-shot
-- @tparam number voice 1 - 6
-- @tparam number time min: 0, max: 100, default: 100
function disting.sd6:env_time(voice, time)
    crow.ii.disting.set_parameter(32 + (voice - 1), time)
end

--- Set the transposition of each voice, in semitones.
-- @tparam number voice 1 - 6
-- @tparam number semitones min: -60, max: 60, default: 0
function disting.sd6:transpose(voice, semitones)
    crow.ii.disting.set_parameter(38 + (voice - 1), semitones)
end

--- Set the fine tuning of each voice, in cents.
-- @tparam number voice 1 - 6
-- @tparam number cents min: -100, max: 100, default: 0
function disting.sd6:fine_tune(voice, cents)
    crow.ii.disting.set_parameter(44 + (voice - 1), cents)
end

--- Set the choke group for the voice.
-- 0 for off
-- @tparam number voice 1 - 6
-- @tparam number group 0 - 3
function disting.sd6:choke_group(voice, group)
    crow.ii.disting.set_parameter(50 + (voice - 1), group)
end

--- Set the sample start point, in % of sample length.
-- Unit = 0.1%
-- @tparam number voice 1 - 6
-- @tparam number offset min: 0, max: 999, default: 0
function disting.sd6:start_offset(voice, offset)
    crow.ii.disting.set_parameter(56 + (voice - 1), offset)
end

--- Enable soft saturation on each output.
-- @tparam number output 1 - 4
-- @tparam boolean enabled default: true
function disting.sd6:out_saturation(output, enabled)
    crow.ii.disting.set_parameter(62 + (voice - 1), b2n(enabled))
end

---------------------------------------

--- SD Multisample Algorithm.
-- Different multisamples can have different 0v pitches
-- Set disting.zero_volt_note to get tuning correct
-- Default is 48 (C3) (130.81Hz)
disting.multisample = {}

--- Output Modes.
-- all_summed: 1/2 main stereo, 4 mono mix, 3 gate output
-- per_gate_12_34: 1/2 & 3/4 stereo, assignment dependant on gate input
-- per_gate_1_2_3: 1,2,3 mono per gate input, 4 gate output
disting.multisample.OUTPUT_MODES = {
    all_summed = 0,
    per_gate_12_34 = 1,
    per_gate_1_2_3 = 2
}

--- Trigger (note_on + note_off) with optional velocity and duration.
-- @tparam number midi_note midi note number 0 to 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration note_on time in seconds, default: 0.0625
disting.multisample.note = disting.note

-- Set the pitch of note with note_id
-- Note: note_id is just a reference to a note
-- @tparam number note_id 0 - 127
-- @tparam number pitch volts in 1v/Oct
disting.multisample.note_pitch = disting.note_pitch

-- Turn on note with note_id and optional velocity.
-- @tparam number note_id 0 - 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
disting.multisample.note_on = disting.note_on

-- Turn off note with note_id.
-- @tparam number note_id 0 - 127
disting.multisample.note_off = disting.note_off

--- Kill all notes.
disting.multisample.all_notes_off = disting.all_notes_off

-- Trigger (voice_on+voice_off) with optional pitch, velocity and duration.
-- @tparam number voice 1 - 8
-- @tparam[opt] number pitch volts in 1v/Oct, default: 0
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration voice_on duration in seconds, default: 0.0625
disting.multisample.voice = disting.voice

--- Set voice pitch in v/Oct
-- @tparam number voice 1 - 8
-- @tparam number pitch volts in v/Oct
disting.multisample.voice_pitch = disting.voice_pitch

--- Turn voice on with optional velocity.
-- @tparam number voice 1 - 8
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
disting.multisample.voice_on = disting.voice_on

--- Turn voice off.
-- @tparam number voice 1 - 8
disting.multisample.voice_off = disting.voice_off

--- Kill all voices
disting.multisample.all_voices_off = disting.all_voices_off

--- Select the folder to load samples from.
-- @tparam number folder min: 0, max: 999
function disting.multisample:folder(folder)
    crow.ii.disting.set_parameter(7, folder)
end

--- Set the envelope release time.
-- The value 100 means "infinite" - forever if looped
-- or until it stops if one-shot
-- @tparam number time min: 0, max: 100, default: 25
function disting.multisample:env_time(time)
    crow.ii.disting.set_parameter(8, time)
end

--- Set how many CV/gate pairs to use.
-- 1 uses 2/4, 2 adds 1/3, 3 adds 5/6
-- @tparam number mode min: 0, max: 3, default: 1
function disting.multisample:input_mode(mode)
    crow.ii.disting.set_parameter(9, mode)
end

--- Transpose the whole instrument in octaves.
-- @tparam number octave min: -8, max: 8, default: 0
function disting.multisample:octave(octave)
    crow.ii.disting.set_parameter(10, octave)
end

--- Transpose the whole instrument in semitones.
-- @tparam number semitones min: -60, max: 60, default: 0
function disting.multisample:transpose(semitones)
    crow.ii.disting.set_parameter(11, semitones)
end

--- Transpose the whole instrument in cents.
-- @tparam number cents min: -100, max: 100, default: 0
function disting.multisample:fine_tune(cents)
    crow.ii.disting.set_parameter(12, cents)
end

--- Apply output gain in decibels (before saturation, if enable).
-- @tparam number dB min: -40, max: 6, default: 0
function disting.multisample:gain(dB) crow.ii.disting.set_parameter(13, dB) end

--- Enable soft saturation at the output.
-- @tparam boolean enabled
function disting.multisample:saturation(enabled)
    crow.ii.disting.set_parameter(14, b2n(enabled))
end

--- Select a velocity curve applied to incoming midi notes.
-- @tparam number curve min: 0, max: 3, default: 0
function disting.multisample:velocity_curve(curve)
    crow.ii.disting.set_parameter(15, curve)
end

--- Activate sustain (notes remain palying when gate goes low).
-- @tparam boolean enabled
function disting.multisample:sustain(enabled)
    crow.ii.disting.set_parameter(16, b2n(enabled))
end

--- Set the behavior of the sustain function.
-- 'synth' = sustained notes cannot be retriggered
-- 'piano' = sustained notes can be retriggered
-- @tparam string mode 'synth' or 'piano'
function disting.multisample:sustain_mode(mode)
    local v
    if mode == 'synth' then
        v = 0
    elseif v == 'piano' then
        v = 1
    end
    crow.ii.disting.set_parameter(17, v)
end

--- Set the max number of simultaneous voices.
-- @tparam number max min: 1, max: 8, default: 8
function disting.multisample:max_voices(max)
    crow.ii.disting.set_parameter(18, max)
end

--- Set pitch bend range in semitones.
-- @tparam number semitones min: 0, max: 48, default: 2
function disting.multisample:bend_range(semitones)
    crow.ii.disting.set_parameter(19, semitones)
end

--- Set the pitch bend input, or 0 for none.
-- @tparam number input 0 - 6
function disting.multisample:bend_input(input)
    crow.ii.disting.set_parameter(20, input)
end

--- Set per-voice detune.
-- @tparam number voice 1 - 8
-- @tparam number cents min: -100, max: 100, default: 0
function disting.multisample:voice_detune(voice, cents)
    crow.ii.disting.set_parameter(21 + (voice - 1), cents)
end

--- Set per-voice pitch bend input, or 0 for none.
-- @tparam number voice 1 - 8
-- @tparam number input 0 - 6
function disting.multisample:voice_bend_input(voice, input)
    crow.ii.disting.set_parameter(29 + (voice - 1), input)
end

--- Enable the chord generator function.
-- NOTE: The arpeggiator requires this to be active.
-- @tparam boolean enabled
function disting.multisample:chord_enable(enabled)
    crow.ii.disting.set_parameter(37, b2n(enabled))
end

--- Set the key of the chord generator.
-- 0 is C, 1 is C#, 2 is D, etc.
-- @tparam number key min: -12, max: 12, default: 0 (C)
function disting.multisample:chord_key(key)
    crow.ii.disting.set_parameter(38, key)
end

--- The scale of the chord generator.
-- See disting.CHORD_SCALES table
-- @tparam number scale min: 0, max: 7, default: 0 (Major)
function disting.multisample:chord_scale(scale)
    crow.ii.disting.set_parameter(39, scale)
end

--- Set the shape of the chord generator.
-- See disting.CHORD_SHAPES table
-- @tparam number shape min: 0, max: 13, default: 0 (None)
function disting.multisample:chord_shape(shape)
    crow.ii.disting.set_parameter(40, shape)
end

--- Set the inversion for the chord generator.
-- each inversion moves the lowest up one octave
-- @tparam number inversion min: 0, max: 3, default: 0
function disting.multisample:chord_inversion(inversion)
    crow.ii.disting.set_parameter(41, inversion)
end

--- Set the arpeggiator mode for each CV/gate pair.
-- Notes received over MIDI & i2c use the mode for cv_gate_pair 3
-- See disting.ARP_MODES table
-- @tparam number cv_gate_pair 1 - 3
-- @tparam number mode min: 0, max: 9, default: 0 (Up)
function disting.multisample:arp_mode(cv_gate_pair, mode)
    crow.ii.disting.set_parameter(42 + (cv_gate_pair - 1), mode)
end

--- Set the arpeggiator range.
-- Notes received over MIDI & i2c use the range for cv_gate_pair 3
-- When set to 1 the arpeggio is the notes in the chord.
-- When set to 2 or 3 adds 1 or 2 additional octaves
-- @tparam number cv_gate_pair 1 - 3
-- @tparam number range number of octaves to extend arp
function disting.multisample:arg_range(cv_gate_pair, range)
    crow.ii.disting.set_parameter(45 + (cv_gate_pair - 1), range)
end

--- Set the arpeggiator reset input, or 0 for none.
-- Trigger to this input resets arp to step 1
-- @tparam number input 0 - 6
function disting.multisample:arp_reset_input(input)
    crow.ii.disting.set_parameter(48, input)
end

--- Offset (delay) the gate inputs relative to the pitch inputs.
-- @tparam number offset min: 0, max: 496, default: 0
function disting.multisample:gate_offset(offset)
    crow.ii.disting.set_parameter(49, offset)
end

--- Set the Scala file to use, 0 for none, -1 for MTS.
-- @tparam number file min: -1, max: 500, default: 0
function disting.multisample:scala_scl(file)
    crow.ii.disting.set_parameter(50, file)
end

--- Set the Scala keyboard map file to use, or 0 for none.
-- @tparam number file min: 0, max: 500, default: 0
function disting.multisample:scala_kbm(file)
    crow.ii.disting.set_parameter(51, file)
end

--- Set how many voices playing simulataneously generate full output.
-- For monophonic, reduce this. For big chords, increase this to avoid clipping.
-- @tparam number num_voices min: 1, max: 8, default: 6
function disting.multisample:normalisation(num_voices)
    crow.ii.disting.set_parameter(52, num_voices)
end

--- Set how the outputs are used.
-- See disting.multisample.OUTPUT_MODES table
-- @tparam number mode min: 0, max: 2, default: 0 (all_summed)
function disting.multisample:output_mode(mode)
    crow.ii.disting.set_parameter(53, mode)
end

--- Poly Wavetable Algorithm.
disting.poly = {}

--- Poly Wavetable Output Modes.
-- Spread modes 0, 1, 2: 1/2 main stereo, 4 mono, 3 gate output
-- Mode 3 (out per voice): 1 for 1/5, 2 for 2/6, 3 for 3/7, 4 for 4/8
disting.poly.OUTPUT_MODES = {
    spread_voice = 0,
    spread_voice2 = 1,
    spread_pitch = 2,
    per_voice = 3
}

--- Trigger (note_on + note_off) with optional velocity and duration.
-- @tparam number midi_note midi note number 0 to 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration note on duration in seconds, default 0.0625
disting.poly.note = disting.note

-- Set the pitch of note with note_id
-- Note: note_id is just a reference to a note, unrelated to pitch
-- @tparam number note_id 0 - 127
-- @tparam number pitch volts in 1v/Oct
disting.poly.note_pitch = disting.note_pitch

-- Turn on note with note_id and optional velocity.
-- @tparam number note_id 0 - 127
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
disting.poly.note_on = disting.note_on

-- Turn off note with note_id.
-- @tparam number note_id 0 - 127
disting.poly.note_off = disting.note_off

--- Kill all notes.
disting.poly.all_notes_off = disting.all_notes_off

-- Trigger (voice_on+voice_off) with optional pitch, velocity and duration.
-- @tparam number voice 1 - 8
-- @tparam[opt] number pitch volts in 1v/Oct, default: 0
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
-- @tparam[opt] number duration voice_on duration in seconds, default: 0.0625
disting.poly.voice = disting.voice

--- Set voice pitch in v/Oct
-- @tparam number voice 1 - 8
-- @tparam number pitch volts in v/Oct
disting.poly.voice_pitch = disting.voice_pitch

--- Turn voice on with optional velocity.
-- @tparam number voice 1 - 8
-- @tparam[opt] number velocity min: 0, max: 128, default: 100
disting.poly.voice_on = disting.voice_on

--- Turn voice off.
-- @tparam number voice 1 - 8
disting.poly.voice_off = disting.voice_off

-- Kill all voices.
disting.poly.all_voices_off = disting.all_voices_off

--- Select the folder to load samples from.
-- @tparam number folder min: 0, max: 999
function disting.poly:folder(folder) crow.ii.disting.set_parameter(7, folder) end

--- Select the wavetable file.
-- @tparam number wavetable min: 0, max: 999, default: 0
function disting.poly:wavetable(wavetable)
    crow.ii.disting.set_parameter(7, wavetable)
end

--- Set offset for the wavetable position, added to wave input.
-- @tparam number offset min: -100, max: 100, default: 0
function disting.poly:wave_offset(offset)
    crow.ii.disting.set_parameter(8, offset)
end

--- Amount by which to spread the per-voice wavetable position.
-- @tparam number spread min: -100, max: 100, default: 0
function disting.poly:wave_spread(spread)
    crow.ii.disting.set_parameter(9, spread)
end

--- Transpose the whole instrument in semitones.
-- @tparam number semitones min: -60, max: 60, default: 0
function disting.poly:coarse_tune(semitones)
    crow.ii.disting.set_parameter(10, semitones)
end

--- Transpose the whole instrument in cents.
-- @tparam number cents min: -100, max: 100, default: 0
function disting.poly:fine_tune(cents) crow.ii.disting.set_parameter(11, cents) end

--- Envelope 1 attack time, range 1ms-15s.
-- @tparam number time min: 0, max: 127, default: 20
function disting.poly:attack_time(time) crow.ii.disting.set_parameter(12, time) end

--- Envelope 1 decay time, range 20ms-15s.
-- @tparam number time min: 0, max: 127, default: 60
function disting.poly:decay_time(time) crow.ii.disting.set_parameter(13, time) end

--- Envelope 1 sustain level.
-- @tparam number level min: 0, max: 127, default: 80
function disting.poly:sustain_level(level)
    crow.ii.disting.set_parameter(14, level)
end

--- Envelope 1 release time, range 10ms-30s.
-- @tparam number time min: 0, max: 127, default: 60
function disting.poly:release_time(time) crow.ii.disting.set_parameter(15, time) end

--- Envelope 1 attack shape, 0 highly exponential, 127 almost linear.
-- @tparam number shape min: 0, max: 127, default: 64
function disting.poly:attack_shape(shape)
    crow.ii.disting.set_parameter(16, shape)
end

--- Envelope 1 decay shape, 0 highly exponential, 127 almost linear.
-- @tparam number shape min: 0, max: 127, default: 64
function disting.poly:decay_shape(shape) crow.ii.disting
    .set_parameter(17, shape) end

--- Envelope 2 attack time, range 1ms-15s.
-- @tparam number time min: 0, max: 127, default: 20
function disting.poly:attack_time2(time) crow.ii.disting.set_parameter(18, time) end

--- Envelope 2 decay time, range 20ms-15s.
-- @tparam number time min: 0, max: 127, default: 60
function disting.poly:decay_time2(time) crow.ii.disting.set_parameter(19, time) end

--- Envelope 2 sustain level.
-- NOTE: This can go negative
-- @tparam number level min: -127, max: 127, default: 64
function disting.poly:sustain_level2(level)
    crow.ii.disting.set_parameter(20, level)
end

--- Envelope 2 release time, range 10ms-30s.
-- @tparam number time min: 0, max: 127, default: 60
function disting.poly:release_time2(time) crow.ii.disting
    .set_parameter(21, time) end

--- Envelope 2 attack shape, 0 highly exponential, 127 almost linear.
-- @tparam number shape min: 0, max: 127, default: 6
function disting.poly:attack_shape2(shape)
    crow.ii.disting.set_parameter(22, shape)
end

--- Envelope 2 decay shape, 0 highly exponential, 127 almost linear.
-- @tparam number shape min: 0, max: 127, default: 64
function disting.poly:decay_shape2(shape)
    crow.ii.disting.set_parameter(23, shape)
end

--- Select the filter type.
-- 0 = Off, 1 = LP, 2 = BP, 3 = HP
-- @tparam number mode min: 0, max: 3, default: 0
function disting.poly:filter_type(type) crow.ii.disting.set_parameter(24, type) end

--- Set the filter frequency, specified by MIDI note.
-- @tparam number midi_note min: 0, max: 127, default: 64 (E4) (329.63Hz)
function disting.poly:filter_freq(midi_note)
    crow.ii.disting.set_parameter(25, midi_note)
end

--- Set the filter resonance.
-- @tparam number q min: 0, max: 100, default: 50
function disting.poly:filter_q(q) crow.ii.disting.set_parameter(26, q) end

--- The % amount by which velocity affects volume.
-- @tparam number percent min: 0, max: 100, default: 100
function disting.poly:vel_to_volume(percent)
    crow.ii.disting.set_parameter(27, percent)
end

--- The % amount by which velocity affects wavetable postion.
-- NOTE: Can be a negative percent
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:vel_to_wave(percent)
    crow.ii.disting.set_parameter(28, percent)
end

--- The amount by which velocity affect filter frequency.
-- NOTE: amount can be negative.
-- @tparam number amount min: -127, max: 127, default: 0
function disting.poly:vel_to_filter(amount)
    crow.ii.disting.set_parameter(29, amount)
end

--- The % amount by which the note pitch affects the wavetable postion.
-- NOTE: Can be a negative percent
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:pitch_to_wave(percent)
    crow.ii.disting.set_parameter(30, percent)
end

--- The % amount by which note pitch affects filter frequency.
-- NOTE: Can be a negative percent.
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:pitch_to_filter(percent)
    crow.ii.disting.set_parameter(31, percent)
end

-- The % amount by which envelope 1 affects wavetable position.
-- NOTE: Can be a negative percent.
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:env1_to_wave(percent)
    crow.ii.disting.set_parameter(32, percent)
end

--- The amount by which envelope 1 affects filter frequency.
-- NOTE: amount can be negative.
-- @tparam number amount min: -127, max: 127, default: 0
function disting.poly:env1_to_fiter(amount)
    crow.ii.disting.set_parameter(33, amount)
end

--- The % amount by which envelope 2 affects wavetable position.
-- NOTE: Can be a negative percent.
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:env2_to_wave(percent)
    crow.ii.disting.set_parameter(34, percent)
end

--- The amount by which envelope 2 affects filter frequency.
-- NOTE: amount can be negative.
-- @tparam number amount min: -127, max: 127, default: 0
function disting.poly:env2_to_filter(amount)
    crow.ii.disting.set_parameter(35, amount)
end

--- The amount by which envelope 2 affects the note pitch.
-- In units of 1/10th semitone, can be negative.
-- @tparam number amount min: -120, max: 120, default: 0
function disting.poly:env2_to_pitch(amount)
    crow.ii.disting.set_parameter(36, amount)
end

--- The % amount by which the LFO affects the wavetable position.
-- NOTE: Can be a negative percent.
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:lfo_to_wave(percent)
    crow.ii.disting.set_parameter(37, percent)
end

--- The amount by which the LFO affects the filter frequency.
-- NOTE: amount can be negative
-- @tparam number amount min: -127, max: 127, default: 0
function disting.poly:lfo_to_filter(amount)
    crow.ii.disting.set_parameter(38, amount)
end

--- The amount by which the LFO affects the note pitch.
-- In units of 1/10th semitone, can be negative.
-- @tparam number amount min: -120, max: 120, default: 0
function disting.poly:lfo_to_pitch(amount)
    crow.ii.disting.set_parameter(39, amount)
end

--- The LFO speed, range 0.01Hz-10Hz.
-- NOTE: speed can be negative
-- @tparam number speed min: -100, max: 100, default: 90
function disting.poly:lfo_speed(speed) crow.ii.disting.set_parameter(40, speed) end

--- Apply an overall output gain.
-- @tparam number dB min: -40, max: 24, default: 0
function disting.poly:gain(dB) crow.ii.disting.set_parameter(41, dB) end

--- Activate sustain (notes remain playing when gate goes low).
-- @tparam boolean enabled
function disting.poly:sustain(enabled)
    crow.ii.disting.set_parameter(42, b2n(enabled))
end

--- Set pitch bend range in semitones.
-- @tparam number semitones min: 0, max: 48, default: 2
function disting.poly:bend_range(semitones)
    crow.ii.disting.set_parameter(43, semitones)
end

--- Enable the chord generator function.
-- NOTE: The arpeggiator requires this to be active.
-- @tparam boolean enabled
function disting.poly:chord_enable(enabled)
    crow.ii.disting.set_parameter(44, b2n(enabled))
end

--- Set the key of the chord generator.
-- 0 is C, 1 is C#, 2 is D, etc.
-- @tparam number key min: -12, max: 12, default: 0
function disting.poly:chord_key(key) crow.ii.disting.set_parameter(45, key) end

--- Set the scale of the chord generator.
-- See disting.CHORD_SCALES table
-- @tparam number scale min: 0, max: 7, default: 0 (Major)
function disting.poly:chord_scale(scale) crow.ii.disting
    .set_parameter(46, scale) end

--- Set the shape of the chord generator.
-- See disting.CHORD_SHAPES table
-- @tparam number shape min: 0, max: 13, default: 0 (None)
function disting.poly:chord_shape(shape) crow.ii.disting
    .set_parameter(47, shape) end

--- Set the inversion for the chord generator.
-- each inversion moves the lowest up one octave
-- @tparam number inversion min: 0, max: 3, default: 0
function disting.poly:chord_inversion(inversion)
    crow.ii.disting.set_parameter(48, inversion)
end

--- Set the arpeggiator mode for each CV/gate input.
-- Notes received over MIDI & i2c use the mode for cv_gate_pair 3
-- See disting.ARP_MODES table
-- @tparam number cv_gate_pair 1 - 3
-- @tparam number mode min: 0, max: 9, default: 0 (Up)
function disting.poly:arp_mode(cv_gate_pair, mode)
    crow.ii.disting.set_parameter(49 + (cv_gate_pair - 1), mode)
end

--- Set the arpeggiator range.
-- Notes received over MIDI & i2c use the range for cv_gate_pair 3
-- When set to 1 the arpeggio is the notes in the chord.
-- When set to 2 or 3 adds 1 or 2 additional octaves
-- @tparam number cv_gate_pair 1 - 3
-- @tparam number range number of octaves to extend ar
function disting.poly:arp_range(cv_gate_pair, range)
    crow.ii.disting.set_parameter(52 + (cv_gate_pair - 1), range)
end

--- Set the Scala file to use, 0 for none, -1 for MTS.
-- @tparam number file min: -1, max: 500, default: 0
function disting.poly:scala_scl(file) crow.ii.disting.set_parameter(55, file) end

--- Set the Scala keyboard map file to use, 0 for none.
-- @tparam number file min: 0, max: 500, default: 0
function disting.poly:scala_kbm(file) crow.ii.disting.set_parameter(56, file) end

-- Engages the chorus effect.
-- 0 is Off, 1 is Juno Chorus I, 2 is Juno Chorus II
-- @tparam number mode min: 0, max: 2, default: 0
function disting.poly:chorus_mode(mode) crow.ii.disting.set_parameter(57, mode) end

--- Type of the delay effect.
-- 0 is off, 1 is Stereo, 2 is Ping-Pong
-- @tparam number mode min: 0, max: 2, default: 0
function disting.poly:delay_mode(mode) crow.ii.disting.set_parameter(58, mode) end

--- Set the level of the delay effect.
-- -40 is treated as -infinity dB
-- @tparam number dB min: -40, max: 0, default: -3
function disting.poly:delay_level(dB) crow.ii.disting.set_parameter(59, dB) end

--- Set delay time in milliseconds.
-- @tparam number milliseconds min: 1, max: 10000, default: 500
function disting.poly:delay_time(milliseconds)
    crow.ii.disting.set_parameter(60, milliseconds)
end

--- Set the delay feedback percent.
-- @tparam number percent min: 0, max: 100, default: 50
function disting.poly:delay_feedback(percent)
    crow.ii.disting.set_parameter(61, percent)
end

--- Set the number of voices to play simultaneously for each note.
-- @tparam number num_voices min: 1, max: 8, default: 1
function disting.poly:unison(num_voices)
    crow.ii.disting.set_parameter(62, num_voices)
end

--- Set the detune amount when unison is active.
-- @taparm number cents min: 0, max: 100, default: 10
function disting.poly:unison_detune(cents)
    crow.ii.disting.set_parameter(63, cents)
end

--- Set the % amount of output spread, if seleted output mode uses spread.
-- NOTE: can be negative percent
-- @tparam number percent min: -100, max: 100, default: 0
function disting.poly:output_spread(amount)
    crow.ii.disting.set_parameter(64, amount)
end

--- Set the output mode.
-- See disting.poly:OUTPUT_MODES table
-- @tparam number mode min: 0, max: 3, default: 0
function disting.poly:output_mode(mode) crow.ii.disting.set_parameter(65, mode) end

--- Set how many input CV/gate pairs to use.
-- 1 uses 2/4, 2 adds 1/3, 3 adds 5/6
-- @tparam number num_pairs min: 0, max: 3, default: 1
function disting.poly:input_mode(num_pairs)
    crow.ii.disting.set_parameter(66, num_pairs)
end

--- Set the behavior of the sustain function.
-- 'synth' = 0 = sustained notes cannot be retriggered
-- 'piano' = 1 = sustained notes can be retriggered
-- @tparam string|number mode 'synth' or 'piano'
function disting.poly:sustain_mode(mode)
    local v
    if mode == 'synth' or mode == 0 then
        v = 0
    elseif mode == 'piano' or mode == 1 then
        v = 1
    end
    crow.ii.disting.set_parameter(67, v)
end

--- Select a velocity curve appleid to incoming MIDI notes.
-- @tparam number curve min: 0, max: 3, default: 0
function disting.poly:velocity_curve(curve)
    crow.ii.disting.set_parameter(68, curve)
end

--- Which input to use to control the wavetable position, or 0 for none.
-- @tparam number input min: 0, max: 6, default: 5
function disting.poly:wave_input(input) crow.ii.disting.set_parameter(69, input) end

--- Which input to use for pitch bend, or 0 for none.
-- @tparam number input min: 0, max: 6, default: 0 (None)
function disting.poly:pitch_bend_input(input)
    crow.ii.disting.set_parameter(70, input)
end

--- Which to use as arpeggiator reset, or 0 for none.
-- trigger to this input resets arp back to step 1
-- @tparam number input min: 0, max: 6, default: 0 (None)
function disting.poly:arp_reset_input(input)
    crow.ii.disting.set_parameter(71, input)
end

--- Set the maximum number of of simultaneous voices.
-- @tparam number max min: 1, max: 8, default: 8
function disting.poly:max_voices(max) crow.ii.disting.set_parameter(72, max) end

--- Sets whether the LFOs are retriggered at note on.
-- 'poly' = 0 = each LFO trigers independently
-- 'mono' = 1 = all LFOs are retriggered when the first note is played
-- 'off' = 2 = LFO's free-running
-- @tparam string|number 'poly' or 0, 'mono' or 1, 'off' or 2
function disting.poly:lfo_retrigger(mode)
    local v
    if type(mode) == 'string' then
        if mode == 'poly' then
            v = 0
        elseif mode == 'mono' then
            v = 1
        elseif mode == 'off' then
            v = 2
        end
    else
        v = mode
    end
    crow.ii.disting.set_parameter(73, v)
end

--- Set the phase to which LFOs are retriggered.
-- The value, in degrees, is multiplied by the voice number
-- to give the initial LFO phase. When retrigger is off,
-- this sets the phase relationship between the free-running LFOs
-- @tparam number degrees min: 0, max: 90, default: 0
function disting.poly:lfo_spread(degrees)
    crow.ii.disting.set_parameter(74, degrees)
end

--- Offset (delay) the gate inputs relative to the pitch inputs.
-- @tparam number offset min: 0, max: 496, default: 0
function disting.poly:gate_offset(offset)
    crow.ii.disting.set_parameter(75, offset)
end

return disting
