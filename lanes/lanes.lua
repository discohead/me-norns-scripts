--- lanes
-- breakpoint tables for creating DAW-like track automation
-- implemenation heavily borrows from @tyleretters' sequins

local L = {}

NON_ZERO = 0.01

function L.new(t)
    -- wrap a table in a lane with defaults
    local l = {data = t, startbeats = clock.get_beats()}
    setmetatable(l, L)
    return l
end

function L.setdata(self, t) self.data = t end

function L.setstartbeats(self, beats) self.startbeats = beats end

function L.is_lanes(t) return getmetatable(t) == L end

function L.extend(self, t) -- append table of breakpoints
    for i = 1, #t do self.data[#self.data + 1] = v end
    return self
end

function L.append(self, t) -- append a single breakpoint
    self.data[#self.data + 1] = t
    return self
end

function L.insert(self, t, ix) -- insert a single breakpoint at ix
    table.insert(self.data, ix, t)
    return self
end

function L.interpolate(self, at_beats)
    at_beats = at_beats or clock.get_beats() - self.startbeats
    local start_level, end_level, start_time, end_time
    local curve_func
    local final_point = false
    for ix, point in ipairs(self.data) do
        local time = point[1]
        local level = point[2]
        if time <= at_beats then
            start_time = time
            start_level = level
            curve_func = point[3]
            if ix == #self.data then return level end
        else
            end_time = time
            end_level = level
            break
        end
    end
    local phase = util.linlin(start_time, end_time, 0, 1, at_beats)
    local y = curve_func(phase)
    return util.linlin(0, 1, start_level, end_level, y)
end

--- metamethods

L.__call = function(self, ...)
    return (self == L) and L.new(...) or L.interpolate(self, ...)
end

L.metaix = {settable = L.setdata, setstartbearts = L.setstartbeats}

setmetatable(L, L)

return L
