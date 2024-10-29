instrument_name = 'matrix'
instrument_table = {
    ["F_to_B"] = 51,
    ["F_to_F"] = 55,
    ["D_to_A"] = 32,
    ["F_to_C"] = 52,
    ["F_to_D"] = 53,
    ["E_to_D"] = 44,
    ["B_track"] = 3,
    ["C_to_D"] = 26,
    ["B_to_D"] = 17,
    ["A_to_D"] = 8,
    ["F_track"] = 7,
    ["F_to_A"] = 50,
    ["F_fine"] = 49,
    ["E_to_B"] = 42,
    ["B_to_C"] = 16,
    ["B_to_A"] = 14,
    ["A_to_A"] = 5,
    ["A_to_C"] = 7,
    ["A_to_B"] = 6,
    ["B_to_B"] = 15,
    ["D_to_C"] = 34,
    ["A_track"] = 2,
    ["E_out"] = 38,
    ["F_out"] = 47,
    ["note"] = 1,
    ["E_track"] = 6,
    ["A_out"] = 2,
    ["B_out"] = 11,
    ["C_out"] = 20,
    ["D_out"] = 29,
    ["C_to_E"] = 27,
    ["E_to_E"] = 45,
    ["name"] = "matrix",
    ["E_to_C"] = 43,
    ["F_ratio"] = 48,
    ["E_ratio"] = 39,
    ["E_to_A"] = 41,
    ["C_to_B"] = 24,
    ["B_ratio"] = 12,
    ["A_ratio"] = 3,
    ["D_ratio"] = 30,
    ["C_ratio"] = 21,
    ["D_track"] = 5,
    ["C_track"] = 4,
    ["C_to_A"] = 23,
    ["D_to_D"] = 35,
    ["D_to_B"] = 33,
    ["F_to_E"] = 54,
    ["A_fine"] = 4,
    ["B_fine"] = 13,
    ["D_fine"] = 31,
    ["A_to_F"] = 10,
    ["B_to_F"] = 19,
    ["C_to_F"] = 28,
    ["D_to_F"] = 37,
    ["E_to_F"] = 46,
    ["A_to_E"] = 9,
    ["C_to_C"] = 25,
    ["C_fine"] = 22,
    ["B_to_E"] = 18,
    ["E_fine"] = 40,
    ["D_to_E"] = 36
}

-----------------------------------------------------

local master_string = [[local NAME = {}

function NAME:note(midi_note, duration, f0_note)
    if type(midi_note) == 'table' then
        note, duration, f0_note = table.unpack(channel)
    end
    note, duration, f0_note = note or 21, duration or 0.0625, f0_note or 21
    er301.note_on(1, note, duration, f0_note)
end

]]

local param_string = [[function NAME:PARAM(volts)
    er301.cv(PORTNUMBER, volts)
end

]]

local function save_code(code_string, filename)
    filename = _path.code..'me-norns-scripts/'..filename
    local file, err = io.open(filename, "wb")
    if err then return err end
    file:write(code_string)
    file:close()
end

function make_instrument(name, t)
    local instrument_code = master_string
    for parameter_name, port_number in pairs(t) do
        local param_code = string.gsub(param_string, 'PARAM', parameter_name)
        param_code = string.gsub(param_code, 'PORTNUMBER', port_number)
        instrument_code = instrument_code..param_code
    end
    instrument_code = instrument_code..'return NAME'
    instrument_code = string.gsub(instrument_code, 'NAME', name)
    print(save_code(instrument_code, name..'.lua'))
end

function init()
  make_instrument(instrument_name, instrument_table)
end

