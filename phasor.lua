local PHI = {}

function PHI.new(division, zero)
    local phi = {
        division = division or 4,
        zero = zero,
    }
    setmetatable(phi, PHI)
    return phi
end

function PHI:get(at_beats, division)
    at_beats = at_beats or clock.get_beats()
    self.zero = self.zero or at_beats
    at_beats = at_beats - self.zero
    division = division or self.division
    at_beats = at_beats % division
    return util.linlin(0, division, 0, 1, at_beats)
end

function PHI:reset()
    self.zero = nil
end

PHI.__call = function(self, ...)
    return (self == PHI) and PHI.new(...) or PHI.get(self, ...)
end

PHI.metaix = {reset = PHI.reset}

PHI.__index = function(self, ix)
    return PHI.metaix[ix]
end

setmetatable(PHI, PHI)

return PHI