--- lanes are breakpoint tables for creating DAW-like track automation.
-- implemenation heavily borrows from @tyleretters' sequins
local L = {}

--- Create a new lane.
-- @tparam table t table containing breakpoints that define the return value at given number of beats
-- ex: l { {0, 0}, {16, 100}, {32, 0}}
-- each point can have an optional 3rd element that defines the curve to the next point
-- ex: l { {0, 0, curves.ramp{}}, {16, 100, curves.ease_in{}}, {32, 0, curves.ease_out{}}}}
-- see the curves library for more info
-- @tparam[opt] boolean loop wether or not the lane should loop, default: false
-- @treturn table new Lane
function L.new(t, loop)
    -- wrap a table in a lane with defaults
    local l = {data = t, startbeats = clock.get_beats(), loop = loop}
    setmetatable(l, L)
    return l
end
--- Set an entirely new table of breakpoints.
-- @tparam table t
function L.setdata(self, t) self.data = t end

--- Set the the 0th beat to reset phase calculations.
-- @tparam number beats
function L.setstartbeats(self, beats) self.startbeats = beats end

--- Test whether a table is a Lane.
-- @tparam table t
-- @treturn boolean
function L.is_lanes(t) return getmetatable(t) == L end

--- Append an entire table of breakpoints to this lane.
-- @tparam table t table of breakpoints
-- @treturn table self
function L.extend(self, t)
    for i = 1, #t do self.data[#self.data + 1] = v end
    return self
end

-- Append a single breakpoint to this lane.
-- @tparam table t table containing a single break point
-- @treturn table self
function L.append(self, t) -- append a single breakpoint
    self.data[#self.data + 1] = t
    return self
end

--- Insert a single breakpoint at index ix.
-- @tparam table t table containg a single breakpoint
-- @tapram number ix index to insert at
-- @treturn table self
function L.insert(self, t, ix) -- insert a single breakpoint at ix
    table.insert(self.data, ix, t)
    return self
end

--- Interpolate between two breakpoints at the specified number of beats.
-- @tparam [opt] number at_beats point in time in beats to interpolate, default: clock.get_beats()
-- @treturn number value at specified beats
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
            curve_func = point[3] -- will default to linear below
            if ix == #self.data then
                if self.loop then
                    self.startbeats = clock.get_beats()
                    end_time = self.data[1][1]
                    end_level = self.data[1][2]
                    break
                else
                    return level
                end
            end
        else
            end_time = time
            end_level = level
            break
        end
    end
    local phase = util.linlin(start_time, end_time, 0, 1, at_beats)
    local y = curve_func and curve_func(phase) or phase -- default to linear
    return util.linlin(0, 1, start_level, end_level, y)
end

--- metamethods

L.__call = function(self, ...)
    return (self == L) and L.new(...) or L.interpolate(self, ...)
end

L.metaix = {settable = L.setdata, setstartbearts = L.setstartbeats}

setmetatable(L, L)

return L
