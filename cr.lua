--- "Clock" Rhythm Generator.
local CR = {}

--- is v a function?
local function callable(v) return (type(v) == 'function') and true or false end

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
end

--- Helper to print the pattern to the console.
-- @tparam number num_steps number of steps to print
function CR.print(self, num_steps)
    local current_clocks = self.clocks
    self.clocks = 0
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self.clocks = current_clocks
    tab.print(pattern)
end

CR.__call = function(self, ...)
    return (self == CR) and CR.new(...) or CR.next(self, ...)
end

CR.metaix = {reset=CR.reset, print=CR.print}

CR.__index = function(self, ix)
    return CR.metaix[ix]
end

setmetatable(CR, CR)

return CR