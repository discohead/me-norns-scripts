--- Arrangers are breakpoint tables for "arranging" values to be used at points in time (beats) in a song
-- implemenation heavily borrows from @tyleretters' sequins
local A = {}

--- Create a new Arranger.
-- @tparam table t table containing breakpoints that define the return value at given number of beats
-- ex: a { {0, s{32, 36, 39}}, {16, s{36, 43, 44}}, {32, s{32, 36, 41}}}
-- @tparam[opt] boolean loop wether or not the arranger should loop, default: false
-- @tparam[opt] function callback a function to be called at the start of each breakpoint
-- the function will be called with 2 parameters, the breakpoint that triggered it and the Arranger object itself
-- @treturn table new Lane
function A.new(t, loop, callback)
    -- wrap a table in a Arranger with defaults
    local a = {data = t, loop = loop, ix=1, callback=callback}
    setmetatable(a, A)
    return a
end
--- Set an entirely new table of breakpoints.
-- @tparam table t
function A.setdata(self, t) self.data = t end

--- Set the the 0th beat to reset phase calculations.
-- @tparam number beats
function A.setstartbeats(self, beats) self.startbeats = beats end

--- Test whether a table is a Arranger.
-- @tparam table t
-- @treturn boolean
function A.is_arranger(t) return getmetatable(t) == A end

--- Append an entire table of breakpoints to this Arranger.
-- @tparam table t table of breakpoints
-- @treturn table self
function A.extend(self, t)
    for i = 1, #t do self.data[#self.data + 1] = v end
    return self
end

-- Append a single breakpoint to this Arranger.
-- @tparam table t table containing a single break point
-- @treturn table self
function A.append(self, t) -- append a single breakpoint
    self.data[#self.data + 1] = t
    return self
end

--- Insert a single breakpoint at index ix.
-- @tparam table t table containg a single breakpoint
-- @tapram number ix index to insert at
-- @treturn table self
function A.insert(self, t, ix) -- insert a single breakpoint at ix
    table.insert(self.data, ix, t)
    return self
end

--- Get the value to be returned at the specified beats.
-- @tparam [opt] number at_beats point in time in beats to check, default: clock.get_beats()
-- @return value at specified beats
function A.get(self, at_beats)
    at_beats = at_beats or clock.get_beats()
    self.startbeats = self.startbeats or at_beats
    at_beats = at_beats - self.startbeats
    local start_beats, retval = table.unpack(self.data[self.ix])
    local next_ix = (self.ix % #self.data) + 1
    local target_beats, target_retval = table.unpack(self.data[next_ix])
    if at_beats >= target_beats then
        retval = target_retval
        self.ix = next_ix
        next_ix = (self.ix % #self.data) + 1
        if self.callback then
            self.callback(self.data[self.ix], self)
        end
    end

    if self.ix == #self.data and self.loop then
        self.startbeats = clock.get_beats()
    end
    local mt = getmetatable(retval)
    if mt.__call ~= nil then
        return retval()
    end
    return retval
end

--- metamethods

A.__call = function(self, ...)
    return (self == A) and A.new(...) or A.get(self, ...)
end

A.metaix = {settable = A.setdata, setstartbearts = A.setstartbeats}

A.__index = function(self, ix)
    return A.metaix[ix]
end

setmetatable(A, A)

return A
