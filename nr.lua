-- 1000100010001000
-- 1000100010001010
-- 1000100010010010
-- 1000100010010100
-- 1000100010100010
-- 1000100010100100
-- 1000100100010010
-- 1000100100010100
-- 1000100100100010
-- 1000100100100100
-- 1000101010001010
-- 1000101010101010
-- 1001001010010010
-- 1001001010101010
-- 1001010010101010
-- 1001010100101010
-- 1000001010000010
-- 1000001010001010
-- 1000001010010010
-- 1000001010100010
-- 1000010010000100
-- 1000010010001010
-- 1000010010010010
-- 1000010010010100
-- 1000010010100010
-- 1000010010100100
-- 1000010100001010
-- 1000010100010010
-- 1000010100010100
-- 1000010100100010
-- 1000010100100100
-- 1000010101000100

-- "Prime" patterns from Noise Engineering Numeric Repetitor
-- see manual https://www.noiseengineering.us/shop/numeric-repetitor
local NR = {}

NR.primes = {
    0x8888, 0x888A, 0x8892, 0x8894, 0x88A2, 0x88A4, 0x8912, 0x8914, 0x8922,
    0x8924, 0x8A8A, 0x8AAA, 0x9292, 0x92AA, 0x94AA, 0x952A, 0x8282, 0x828A,
    0x8292, 0x82A2, 0x8484, 0x848A, 0x8492, 0x8494, 0x84A2, 0x84A4, 0x850A,
    0x8512, 0x8514, 0x8522, 0x8524, 0x8544
}

--- Emulation of the Noise Engineering Numeric Repetitor, binary math pattern generator.
-- @tparam number prime The prime rhythm 1 - 32
-- @tparam number mask any 1s in the prime flip to 0 if the same bit in the mask is a 0
-- mask = 0 = no mask
-- mask = 1 = 0000111100001111
-- mask = 2 = 1111000000000011
-- mask = 3 = 0000000111110000
-- any other value for mask is assumed to be a custom mask that is directly &'d with the prime
-- @tparam number factor 0 - 16 the masked rhythm is multiplied by this number to produce variations
-- 0 will always produce all 0's
-- 1 will apply no variation
function NR.new(prime, mask, factor)
    prime, mask, factor = prime or 1, mask or 0, factor or 1
    local nr = {prime=prime, mask=mask, factor=factor, ix=1}
    setmetatable(nr, NR)
    return nr
end

function NR.next(self)
    self.prime = self.prime % 33
    if self.prime < 0 then self.prime = 33 + self.prime end
    local rhythm = primes[self.prime]
    self.factor = self.factor % 17
    if self.factor < 0 then self.factor = 17 + self.factor end
    if self.mask == 1 then
        rhythm = rhythm & 0x0F0F
    elseif self.mask == 2 then
        rhythm = rhythm & 0xF003
    elseif self.mask == 3 then
        rhythm = rhythm & 0x1F0
    elseif self.mask ~= 0 then
        -- Assume custom mask
        rhythm = rhythm & self.mask
    end
    local modified = rhythm * self.factor
    local final = (modified & 0xFFFF) | (modified >> 16)
    local bit_status = (final >> (15 - self.ix)) & 1
    self.ix = (self.ix % 16) + 1
    return bit_status
end

function NR.reset(self)
    self.ix = 1
end


function NR.print(self)
    self.ix = 1
    local pattern = {}
    for step=1, 16 do
        table.insert(pattern, self())
    end
    print(table.unpack(pattern))
end

NR.__call = function(self, ...)
    return (self == NR) and NR.new(...) or NR.next(self, ...)
end

NR.metaix = {reset=NR.reset, print=NR.print}

setmetatable(NR, NR)

return NR