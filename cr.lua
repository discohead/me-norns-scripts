--- "Clock" Rhythm Generator.
local CR = {}

--- is v a table that is (hopefully) callable or a function?
-- we could check the metatable for __call but doesn't seem necessary
local function callable(v)
    local v_type = type(v)
    if v_type == 'table' or v_type == 'function' then
        return true
    end
    return false
end

--- Create a new Clock Rhythm generator.
-- @tparam[opt] number divisor return true every divisor times called, default: 1
-- @tparam[opt] boolean|function polarity if false, invert the return value just before return, default: true
-- @tparam[opt] boolean|function flip if true invert polarity, default: false
-- @tparam[opt] boolean|function pre_flip if true apply any polarity flip before polarity is applied to output, default: false
-- @treturn table new CR instance
function CR.new(divisor, polarity, flip, pre_flip)
    if polarity == nil then polarity = true end
    if flip == nil then flip = false end
    if pre_flip == nil then pre_flip = false end
    local cr = {
        divisor = divisor or 1,
        polarity = polarity,
        flip = flip,
        pre_flip = pre_flip,
        clocks = 0,
    }
    setmetatable(cr, CR)
    return cr
end

--- local helper for determining if polarity should be flipped.
-- @tparam boolean|function polarity current polarity
-- @tparam boolean|function if false return not polarity, else polarity
-- @treturn boolean
local function calculate_polarity(polarity, flip)
    if callable(polarity) then polarity = polarity() end
    if callable(flip) and flip() then
        polarity = not polarity
    elseif flip then
        polarity = not polarity
    end
    return polarity
end

--- Get the next step from this CR.
-- @tparam[opt] args table 'divisor', 'polarity', 'flip', 'pre_flip' (all optional)
-- @tparam[opt] number args.divisor return true every divisor times called, default: 1
-- @tparam[opt] boolean|function args.polarity if false, invert the return value just before return, default: true
-- @tparam[opt] boolean|function args.flip if true invert polarity, default: false
-- @tparam[opt] boolean|function args.pre_flip if true apply any polarity flip before polarity is applied to output, default: false
-- @treturn boolean
function CR.next(self, args)
    if args then
        print('args = '..args)
    end
    args = args or {}
    args.divisor = args.divisor or self.divisor
    args.polarity = args.polarity or self.polarity
    args.flip = args.flip or self.flip
    args.pre_flip = args.pre_flip or self.pre_flip
    if callable(args.pre_flip) then args.pre_flip = args.pre_flip() end
    self.clocks = self.clocks + 1
    local even_division = self.clocks % args.divisor == 0
    if args.pre_flip then
        self.polarity = calculate_polarity(args.polarity, args.flip)
    end
    if not self.polarity then
        even_division = not even_division
    end
    if not args.pre_flip then
       self.polarity = calculate_polarity(args.polarity, args.flip)
    end
    return even_division
end

--- Rest the clock count to 0.
function CR.reset(self)
    self.clocks = 0
    if type(self.polarity) == 'table' then
        self.polarity:reset()
    end
    if type(self.flip) == 'table' then
        self.flip:reset()
    end
    if type(self.pre_flip) == 'table' then
        self.pre_flip:reset()
    end
end

--- Helper to print the pattern to the console.
-- @tparam number num_steps number of steps to print
function CR.to_table(self, num_steps)
    self:reset()
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self:reset()
    return pattern
end

--- Helper to print the pattern to the console.
-- @tparam number num_steps number of steps to print
function CR.print(self, num_steps)
    local pattern = self:to_table(num_steps)
    tab.print(pattern)
end

CR.__call = function(self, ...)
    return (self == CR) and CR.new(...) or CR.next(self, ...)
end

CR.metaix = {reset=CR.reset, to_table=CR.to_table, print=CR.print}

CR.__index = function(self, ix)
    return CR.metaix[ix]
end

setmetatable(CR, CR)

return CR