local er301 = {}

local math_log_2 = 0.69314718055995
 -- defaults to ER-301 oscillator default frequency 27.5hz
local global_reference_hz = 27.5
local volt_offset = 2.29721868499 -- math.log(2)*math.log(27.5)

--- Set TR port to state (0/1).
-- @tparam number port 1 - 100
-- @tparam number state 0 or 1
function er301.tr(port, state)
    crow.ii.er301.tr(port, state)
end

--- Toggle the TR port.
-- @tparam number port 1 - 100
function er301.tog(port)
    crow.ii.er301.tr_tog(port)
end

--- Pulse TR port using pulse_time().
-- @tparam number port 1 - 100
function er301.pulse(port)
    crow.ii.er301.tr_pulse(port)
end

--- pulse() time for port in milliseconds.
-- @tparam number port 1 - 100
-- @tparam milliseconds time in milliseconds
function er301.pulse_time(port, milliseconds)
    crow.ii.er301.tr_time(port, milliseconds)
end

--- Polarity for TR port.
-- @tparam number port 1 - 100
-- @tparam rising 0 or 1
function er301.polarity(port, rising)
    crow.ii.er301.tr_pol(port, rising)
end

--- Set CV port to bipolar voltage, following slew() time.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.cv(port, volts)
    crow.ii.er301.cv(port, volts)
end

--- Set CV port to bipolar v/Oct using midi note number.
-- @tparam number port 1 - 100
-- @tparam number midi_note 0 - 127
-- @tparam[opt] number middle_note 0v note number, default is 21 (A0) (27.5hz)
function er301.note_pitch(port, midi_note, middle_note)
    middle_note = middle_note or 21 -- defaults to ER-301 oscillator default frequency 27.5hz
    midi_note = midi_note - middle_note
    crow.ii.er301.cv(port, midi_note/12)
end

--- Set a pitch CV using midi note and pulse TR, to the same port number.
-- @tparam number port 1 - 100
-- @tparam number midi_note 0 - 127
-- @tparam[opt] number duration pulse duration in milliseconds
-- @tparam[opt] number middle_note 0v note number, default is 21 (A0) (27.5hz)
function er301.note(port, midi_note, duration, middle_note)
    middle_note = middle_note or 21 -- defaults to ER-301 oscillator default frequency 27.5hz
    midi_note = midi_note - middle_note
    crow.ii.er301.cv(port, midi_note/12)
    if duration then crow.ii.er301.tr_time(port, duration) end
    crow.ii.er301.tr_pulse(port)
end

--- Set CV port voltage in hertz.
-- @tparam number port 1 - 100
-- @tparam number hertz frequency in hertz
-- @tparam number reference_hz 0v frequency, default is 27.5hz
function er301.hz(port, hertz, reference_hz)
    if reference_hz and reference_hz ~= global_reference_hz then
        volt_offset = math_log_2 * math.log(reference_hz)
        global_reference_hz = reference_hz
    end
    local volts = (math_log_2 * math.log(hertz)) - volt_offset
    crow.ii.er301.cv(port, volts)
end

--- Set CV port slew time in milliseconds.
-- @tparam number port 1 - 100
-- @tparam number milliseconds time in milliseconds
function er301.slew(port, milliseconds)
    crow.ii.er301.cv_slew(port, milliseconds)
end

--- Set CV port to bipolar voltage, ignoring slew() time.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.set_cv(port, volts)
    crow.ii.er301.cv_set(port, volts)
end

--- Set CV port offset voltage, added at final stage.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.offset(port, volts)
    crow.ii.er301.cv_off(port, volts)
end

--- Helper to create a custom API for a voice on er301
-- from a table of keys and port numbers
-- i.e. er301.make_voice{name='bass', note=1, vel=2, filter=3}
-- er301.bass.vel(100); er301.bass.filter(5); er301.bass.note(32)
function er301.make_voice(t)
    local voice_name = t.name
    t.name = nil
    er301[voice_name] = {}
    local keys = tab.sort(er301)
    for param_name, port in pairs(t) do
        if tab.contains(keys, param_name) then
            er301[voice_name][param_name] = function (...) er301[param_name](port, ...) end
        else
            er301[voice_name][param_name] = function(v) crow.ii.er301.cv(port, v) end
        end
    end
end

return er301
