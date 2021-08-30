local er301 = {f0_freqs = {27.5}, f0_notes = {21}} -- defaults to ER-301 oscillator default f0 frequency 27.5hz (A0)

local math_log_2 = 0.69314718055995 -- math.log(2)

--- Return a frequency's nearest MIDI note number.
-- taken from MusicUtil
-- @tparam float freq Frequency number in Hz.
-- @treturn integer MIDI note number (0-127).
local function freq_to_note_num(freq)
    return util.clamp(math.floor(12 * math.log(freq / 440.0) / math.log(2) + 69.5), 0, 127)
end

--- Set TR port to state (0/1).
-- @tparam number port 1 - 100
-- @tparam number state 0 or 1
function er301.tr(port, state) crow.ii.er301.tr(port, state) end

--- Toggle the TR port.
-- @tparam number port 1 - 100
function er301.tog(port) crow.ii.er301.tr_tog(port) end

--- Pulse TR port using pulse_time().
-- @tparam number port 1 - 100
function er301.pulse(port) crow.ii.er301.tr_pulse(port) end

--- pulse() time for port in milliseconds.
-- @tparam number port 1 - 100
-- @tparam milliseconds time in milliseconds
function er301.pulse_time(port, milliseconds)
    crow.ii.er301.tr_time(port, milliseconds)
end

--- Polarity for TR port.
-- @tparam number port 1 - 100
-- @tparam rising 0 or 1
function er301.polarity(port, rising) crow.ii.er301.tr_pol(port, rising) end

--- Set CV port to bipolar voltage, following slew() time.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.cv(port, volts) crow.ii.er301.cv(port, volts) end

--- Set CV port to bipolar v/Oct using midi note number.
-- @tparam number port 1 - 100
-- @tparam number midi_note 0 - 127
-- @tparam[opt] number f0_note 0v note number, default is 21 (A0) (27.5hz)
-- default f0_note for each port can be set with er301.f0_notes[port] = X
function er301.note_pitch(port, midi_note, f0_note)
    f0_note = f0_note or er301.f0_notes[port] or 21
    midi_note = midi_note - middle_note
    crow.ii.er301.cv(port, midi_note / 12)
end

--- Set a pitch CV using midi note and pulse TR, to the same port number.
-- @tparam number port 1 - 100
-- @tparam number midi_note 0 - 127
-- @tparam[opt] number duration pulse duration in milliseconds
-- @tparam[opt] number middle_note 0v note number, default is 21 (A0) (27.5hz)
function er301.note(port, midi_note, duration, f0_note)
    f0_note = f0_note or er301.f0_notes[port] or 21
    midi_note = midi_note - f0_note
    crow.ii.er301.cv(port, midi_note / 12)
    if duration then crow.ii.er301.tr_time(port, duration) end
    crow.ii.er301.tr_pulse(port)
end

--- Set CV port voltage in hertz.
-- @tparam number port 1 - 100
-- @tparam number frequency in hertz
-- @tparam[opt] number f0_freq 0v frequency (f0 on oscillator), default is 27.5hz
-- default f0_freq for each port can be set with er301.f0_freqs[port] = X
function er301.hz(port, frequency, f0_freq)
    f0_freq = f0_freq or er301.f0_freqs[port] or 27.5
    local volts = math.log(frequency / f0_freq) / math_log_2
    crow.ii.er301.cv(port, volts)
end

--- Set CV port slew time in milliseconds.
-- @tparam number port 1 - 100
-- @tparam number milliseconds time in milliseconds
function er301.slew(port, milliseconds) crow.ii.er301
    .cv_slew(port, milliseconds) end

--- Set CV port to bipolar voltage, ignoring slew() time.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.set_cv(port, volts) crow.ii.er301.cv_set(port, volts) end

--- Set CV port offset voltage, added at final stage.
-- @tparam number port 1 - 100
-- @tparam number volts min: -10, max: 10
function er301.offset(port, volts) crow.ii.er301.cv_off(port, volts) end

--- Helper to create a custom API for a voice on er301
-- from a table of keys and port numbers
-- the 'hz' and 'note' keys can be a table of {port, f0_freq}
-- for 'note' the f0_freq will be converted to an f0_note
-- i.e. er301.make_voice{name='bass', note={1, 130.81}, vel=2, filter=3}
-- er301.bass.vel.cv(9); er301.bass.filter.slew(30); er301.bass.note(32)
function er301.make_voice(t)
    local voice_name = t.name
    t.name = nil
    er301[voice_name] = {}
    local keys = tab.sort(er301)
    for param_name, port in pairs(t) do
        if tab.contains(keys, param_name) then
            if (param_name == 'note' or param_name == 'hz') and type(port) == 'table' then
                port, f0_freq = table.unpack(port)
                if param_name == 'note' then
                    er301.f0_notes[port] = freq_to_note_num(f0_freq)
                else
                    er301.f0_freqs[port] = f0_freq
                end
            end
            er301[voice_name][param_name] = function(...)
                er301[param_name](port, ...)
            end
        else
            er301[voice_name][param_name] = {}
            for k, v in pairs(er301) do
                if type(v) == 'function' then
                    er301[voice_name][param_name][k] = function(...)
                        er301[k](port, ...)
                    end
                end
            end
        end
    end
end

return er301
