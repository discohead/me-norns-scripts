--- Emulation of the Noise Engineering Numeric Repetitor, binary math pattern generator.
-- see the manual https://www.noiseengineering.us/shop/numeric-repetitor
-- @tparam[opt] number prime The prime rhythm index 1 - 32, default: 1
-- @tparam[opt] number mask any 1s in the prime flip to 0 if the same bit in the mask is a 0, default: 0
-- mask = 0 = no mask (default)
-- mask = 1 = 0000111100001111
-- mask = 2 = 1111000000000011
-- mask = 3 = 0000000111110000
-- any other value for mask is assumed to be a custom mask that is directly &'d with the prime
-- @tparam[opt] number factor 0 - 16 the masked rhythm is multiplied by this number to produce variations, default: 1
-- factor = 0 will always produce all 0's
-- factor = 1 will apply no variation (default)n
local NR = {}

--- "Prime" patterns from Noise Engineering Numeric Repetitor.
-- 1. 1000100010001000
-- 2. 1000100010001010
-- 3. 1000100010010010
-- 4. 1000100010010100
-- 5. 1000100010100010
-- 6. 1000100010100100
-- 7. 1000100100010010
-- 8. 1000100100010100
-- 9. 1000100100100010
-- 10. 1000100100100100
-- 11. 1000101010001010
-- 12. 1000101010101010
-- 13. 1001001010010010
-- 14. 1001001010101010
-- 15. 1001010010101010
-- 16. 1001010100101010
-- 17. 1000001010000010
-- 18. 1000001010001010
-- 19. 1000001010010010
-- 20. 1000001010100010
-- 21. 1000010010000100
-- 22. 1000010010001010
-- 23. 1000010010010010
-- 24. 1000010010010100
-- 25. 1000010010100010
-- 26. 1000010010100100
-- 27. 1000010100001010
-- 28. 1000010100010010
-- 29. 1000010100010100
-- 30. 1000010100100010
-- 31. 1000010100100100
-- 32. 1000010101000100
-- see pages 6-7 of the manual https://www.noiseengineering.us/shop/numeric-repetitor
NR.primes = {
    0x8888, 0x888A, 0x8892, 0x8894, 0x88A2, 0x88A4, 0x8912, 0x8914, 0x8922,
    0x8924, 0x8A8A, 0x8AAA, 0x9292, 0x92AA, 0x94AA, 0x952A, 0x8282, 0x828A,
    0x8292, 0x82A2, 0x8484, 0x848A, 0x8492, 0x8494, 0x84A2, 0x84A4, 0x850A,
    0x8512, 0x8514, 0x8522, 0x8524, 0x8544
}


--- Create a new Numeric Repetitor
-- @tparam[opt] number prime The prime rhythm index 1 - 32, default: 1
-- @tparam[opt] number mask any 1s in the prime flip to 0 if the same bit in the mask is a 0, default: 0
-- mask = 0 = no mask (default)
-- mask = 1 = 0000111100001111
-- mask = 2 = 1111000000000011
-- mask = 3 = 0000000111110000
-- any other value for mask is assumed to be a custom mask that is directly &'d with the prime
-- @tparam[opt] number factor 0 - 16 the masked rhythm is multiplied by this number to produce variations, default: 1
-- factor = 0 will always produce all 0's
-- factor = 1 will apply no variation (default)
-- @treturn table new NR instance
function NR.new(prime, mask, factor)
    prime, mask, factor = prime or 1, mask or 0, factor or 1
    local nr = {prime=prime, mask=mask, factor=factor, ix=1}
    setmetatable(nr, NR)
    return nr
end

--- Get the next bit from the pattern.
-- Optionally override the prime, mask, factor set at contstruction.
-- @tparam[opt] table args 'prime', 'mask', 'factor' (all are optional)
-- @tparam[opt] number args.prime The prime rhythm index 1 - 32, default: 1
-- @tparam[opt] number args.mask any 1s in the prime flip to 0 if the same bit in the mask is a 0, default: 0
-- mask = 0 = no mask (default)
-- mask = 1 = 0000111100001111
-- mask = 2 = 1111000000000011
-- mask = 3 = 0000000111110000
-- any other value for mask is assumed to be a custom mask that is directly &'d with the prime
-- @tparam[opt] number args.factor 0 - 16 the masked rhythm is multiplied by this number to produce variations, default: 1
-- factor = 0 will always produce all 0's
-- factor = 1 will apply no variation (default)
-- @treturn boolean
function NR.next(self, args)
    args = args or {}
    local prime, mask = args.prime or self.prime, args.mask or self.mask
    local factor = args.factor or self.factor
    prime = prime % 33
    if prime < 1 then prime = 32 + prime end
    local rhythm = NR.primes[prime]
    factor = factor % 17
    if factor < 0 then factor = 17 + factor end
    if mask == 1 then
        rhythm = rhythm & 0x0F0F
    elseif mask == 2 then
        rhythm = rhythm & 0xF003
    elseif mask == 3 then
        rhythm = rhythm & 0x1F0
    elseif mask ~= 0 then
        -- Assume custom mask
        rhythm = rhythm & mask
    end
    local modified = rhythm * factor
    local final = (modified & 0xFFFF) | (modified >> 16)
    local bit_status = (final >> (16 - self.ix)) & 1
    self.ix = (self.ix % 16) + 1
    return bit_status == 1 and true or false
end

--- Get the next step but then decrement the index back.
function NR.peek(self, args)
    local step = self:next(args)
    self.ix = self.ix - 1
    if self.ix < 1 then
        self.ix = 1
    end
    return step
end

--- Reset the pattern to the first step.
function NR.reset(self)
    self.ix = 1
end

--- Helper to convert pattern to a table.
function NR.to_table(self, num_steps)
    self:reset()
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self:reset()
    return pattern
end

--- Helper to print the pattern to the console.
function NR.print(self)
    local pattern = self:to_table(16)
    tab.print(pattern)
end

NR.__call = function(self, ...)
    return (self == NR) and NR.new(...) or NR.next(self, ...)
end

NR.metaix = {reset=NR.reset, to_table=NR.to_table, print=NR.print}
NR.__index = function(self, ix)
    return NR.metaix[ix]
end

setmetatable(NR, NR)

return NR