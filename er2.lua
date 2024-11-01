--- Euclidean Rhythm Generator.
local ER = {}

--- Local helper for calculating the euclidean rhythm.
-- taken from lib/er.lua
local function gen(pulses, steps, rotation)
    rotation = rotation or 0
    -- results array, intially all zero
    local r = {}
    for i=1,steps do r[i] = false end
 
    if pulses<1 then return r end
 
    -- using the "bucket method"
    -- for each step in the output, add K to the bucket.
    -- if the bucket overflows, this step contains a pulse.
    local b = steps
    for i=1,steps do
       if b >= steps then
          b = b - steps
          local j = i + rotation
          while (j > steps) do j = j - steps end
          while (j < 1) do j = j + steps end
          r[j] = true
       end
       b = b + pulses
    end
    return r
end

--- Create a new Euclidean Rhythm Generator.
-- @tparam number pulses number of triggers in the pattern
-- @tparam number steps length of the pattern
-- @tparam number rotation shift or rotation of the pattern
-- @tparam table new ER instance
function ER.new(pulses, steps, rotation)
    local er = {
        pulses = pulses or 4,
        steps = steps or 16,
        rotation = rotation or 0,
        ix = 1,
    }
    er.pattern = gen(er.pulses, er.steps, er.rotation)
    setmetatable(er, ER)
    return er
end

--- Get the next step from this Euclidean pattern.
-- @tparam[opt] table args : 'pulses', 'steps', 'roatation' (all optional)
-- @tparam[opt] number args.pulses : number of pulses, default: self.pulses
-- @tparam[opt] number args.steps : total number of steps, default: self.steps
-- @tparam[opt] number args.rotation : shift amount, default: self.rotation
-- @treturn boolean
function ER.next(self, args)
    local dirty
    if args then
        for k, v in pairs(args) do
            if self[k] ~= v then
                self[k] = v
                dirty = true
            end
        end
        if dirty then
            self.pattern = gen(self.pulses, self.steps, self.rotation)
        end
    end
    local step = self.pattern[self.ix]
    self.ix = (self.ix % self.steps) + 1
    return step
 end

 --- Get the next step, but decrement the index back
 -- and make sure the pattern is restored.
 function ER.peek(self, args)
    local p = self.pattern
    local step = self:next(args)
    self.pattern = p
    self.ix = self.ix - 1
    if self.ix < 1 then
        self.ix = 1
    end
    return step
 end

 --- Reset the pattern to the first step.
function ER.reset(self)
    self.ix = 1
end

--- Helper to convert the pattern to a table.
function ER.to_table(self, num_steps)
    self:reset()
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self:reset()
    return pattern
end

--- Helper to print the pattern to the console.
function ER.print(self)
    local pattern = self:to_table(self.steps)
    tab.print(pattern)
end

ER.__call = function(self, ...)
    return (self == ER) and ER.new(...) or ER.next(self, ...)
end

ER.metaix = {reset=ER.reset, to_table=ER.to_table, print=ER.print}
ER.__index = function(self, ix)
    return ER.metaix[ix]
end

ER.__tostring = function(self)
    return 'er2('..self.pulses..', '..self.steps..', '..self.rotation..')'
end

setmetatable(ER, ER)

return ER