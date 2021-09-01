local CR = {}

function CR.new(divisor, polarity, flip, pre_flip)
    if polarity == nil then polarity = true end
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

local function calculate_polarity(polarity, flip)
    if flip ~= nil then
        if type(flip) == 'boolean' then
            if flip then
                polarity = not polarity
            end
        elseif flip() then
            polarity = not polarity
        end
    end
    return polarity
end

function CR.next(self, args)
    args = args or {}
    args.divisor = args.divisor or self.divisor
    args.polarity = args.polarity or self.polarity
    args.flip = args.flip or self.flip
    args.pre_flip = args.pre_flip or self.pre_flip
    self.clocks = self.clocks + 1
    local even_division = self.clocks % args.divisor == 0
    print('initial polarity = '..tostring(self.polarity))
    if args.pre_flip then
        self.polarity = calculate_polarity(args.polarity, args.flip)
        print('pre_flipped = '..tostring(self.polarity))
    end
    if not self.polarity then
        even_division = not even_division
    end
    if not args.pre_flip then
       self.polarity = calculate_polarity(args.polarity, args.flip)
       print('post flipped = '..tostring(self.polarity))
    end
    return even_division
end

function CR.reset(self)
    self.clocks = 0
end

--- Helper to print the pattern to the console.
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