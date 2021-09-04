local PHI = {}

function PHI.new(division, zero)
    local phi = {
        division = division or 4,
        zero = zero or clock.get_beats(),
    }
    setmetatable(phi, PHI)
    return phi
end

function PHI:get(at_beats, division)
    at_beats = at_beats or clock.get_beats()
    at_beats = at_beats - self.zero
    division = division or self.division
    at_beats = at_beats % division
    return util.linlin(0, division, 0, 1, at_beats)
end

function PHI:reset()
    self.zero = clock.get_beats()
end

PHI.__call = function(self, ...)
    return (self == PHI) and PHI.new(...) or PHI.get(self, ...)
end

PHI.metaix = {reset = PHI.reset}

setmetatable(PHI, PHI)

return PHI