lua_instrument = require('matrix')
name = 'matrix'
num_channels = 1
fields_to_modulate = {}
default_fields = {'sync_rate', 'rhythm', 'velocity', 'duration'}

local function save_code(code_string, filename)
    filename = _path.code..'me-norns-scripts/'..filename
    local file, err = io.open(filename, "wb")
    if err then return err end
    file:write(code_string)
    file:close()
end

local function make_sync_rate_sequins()
    return 's{1/4}'
end

local function make_cr()
    local divisor = math.random(1, 16)
    local polarity = math.random() < 0.5 and true or false
    local flip = math.random() < 0.5 and true or false
    local pre_flip = math.random() < 0.5 and true or false
    return 'cr('..tostring(divisor)..', '..tostring(polarity)..', '..tostring(flip)..', '..tostring(pre_flip)..')'
end

local function make_rhythm_generator()
    return 'nil'
end

local function make_velocity_sequins()
    return 'nil'
end

local function make_duration_sequins()
    return 'nil'
end

local function make_modulation_curve(field)
    if tab.contains(fields_to_modulate, field) then
        local random_rate = math.random(1, 4)
        return math.random() < 0.5 and 'c.ramp{r='..random_rate..'}' or 'c.sine{r='..random_rate..'}'
    else
        return 'nil'
    end
end

local function make_note_sequins()
    return 'nil'
end


local field_value_generators = {
    sync_rate = make_sync_rate_sequins,
    note = make_note_sequins,
    rhythm = make_rhythm_generator,
    velocity = make_velocity_sequins,
    duration = make_duration_sequins,
    modulation = make_modulation_curve,
}

local function make_field_value(field)
    if field_value_generators[field] then
        return field_value_generators[field]()
    else
        return field_value_generators['modulation'](field)
    end
end

local function make_score_table(name, num_channels, fields)
    local table_string = name..'_table = {'
    for channel=1, num_channels do
        table_string = table_string..'{'
        table.sort(fields)
        for _, field in ipairs(fields) do
            table_string = table_string..field..' = '..make_field_value(field)..','
        end
        table_string = table_string..'},'
    end
    table_string = table_string..'device = '..name..', name = "'..name..'",'
    table_string = table_string..'}'
    local filename = name..'_score_table.lua'
    save_code(table_string, filename)
end

local function make_fields_table(lua_instrument)
    local fields = default_fields
    for field, _ in pairs(lua_instrument) do
        fields[#fields+1] = field
    end
    return fields
end

function init()
    local fields = make_fields_table(lua_instrument)
    make_score_table(name, num_channels, fields)
end