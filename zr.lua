--- Emulation of the Noise Engineering Zularic Repetitor pattern generator.
-- See the manual: https://www.noiseengineering.us/shop/zularic-repetitor
local ZR = {
    new_world = {
        motorik_1 = 'motorik_1',
        motorik_2 = 'motorik_2',
        motorik_3 = 'motorik_3',
        pop_1 = 'pop_1',
        pop_2 = 'pop_2',
        pop_3 = 'pop_3',
        pop_4 = 'pop_4',
        funk_1 = 'funk_1',
        funk_2 = 'funk_2',
        funk_3 = 'funk_3',
        sequence = 'sequence',
        prime_2 = 'prime_2',
        prime_322 = 'prime_322',
    },
    old_world = {
        king_1 = 'king_1',
        king_2 = 'king_2',
        kroboto = 'kroboto',
        vodou_1 = 'vodou_1',
        vodou_2 = 'vodou_2',
        vodou_3 = 'vodou_3',
        gahu = 'gahu',
        clave = 'clave',
        rhumba = 'rhumba',
        jhaptal_1 = 'jhaptal_1',
        jhaptal_2 = 'jhaptal_2',
        chacar = 'chacar',
        mata = 'mata',
        pashto = 'pashto',
        prime_232 = 'prime_232',
    }
}

--- See pages 5-8 of the manual: https://www.noiseengineering.us/shop/zularic-repetitor
ZR.banks = {
    motorik_1 = {
        {1,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0},
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,0,0,0,1,0,0,1,0,1,0},
        {0,0,0,0,1,0,1,1,0,0,0,0,1,0,1,1,0,0,0,0,1,0,1,1,0,0,0,0,1,0,1,1},
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0},
    },
    motorik_2 = {
        {1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
        {1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0},
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0},
    },
    motorik_3 = {
        {1,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,1,0,0,0,0,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0},
        {1,0,1,1,1,0,0,1,1,0,1,1,1,0,0,1,1,0,1,1,1,0,0,1,1,0,1,1,1,0,0,1},
        {1,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    },
    pop_1 = {
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0},
        {0,0,1,0,0,1,0,0,1,0,1,1,0,0,0,0,0,0,1,0,0,1,0,0,1,0,1,1,0,0,1,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
        {1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1},
    },
    pop_2 = {
        {0,0,1,0,1,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,0},
        {0,0,1,0,1,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0},
    },
    pop_3 = {
        {1,0,1,0,1,1,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,1,0,0,0},
        {1,0,1,0,1,1,1,1,1,0,1,0,0,0,1,1,1,0,1,0,0,0,1,1,1,0,1,0,1,0,0,0},
        {0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0},
        {0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,1,0},
    },
    pop_4 = {
        {1,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,1,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1},
        {1,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,1,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1},
        {1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,0,0,0,1,1,1,0,1,0,1,1,0,0},
        {1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,0,0,0,1,1,1,0,1,0,1,1,0,0},
    },
    funk_1 = {
        {1,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0},
        {0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0},
        {0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
        {0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1},
    },
    funk_2 = {
        {0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0},
        {1,0,1,1,0,1,1,1,1,0,1,0,0,1,1,1},
        {0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
        {0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1},
    },
    funk_3 = {
        {1,0,1,1,0,1,1,1,1,0,1,0,0,1,1,1},
        {1,0,0,1,1,0,0,1,1,0,0,1,1,0,1,0},
        {0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1},
        {0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1},
    },
    post = {
        {1,0,0,1,0,1,0,1,1,1,0,0,1,0,1,0,1,0,1,0},
        {1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0},
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0},
    },
    sequence = {
        {1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0},
        {0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0},
        {0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0},
        {0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1},
    },
    prime_2 = {
        {1,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,0,0,0,1,0,0,0,0,0},
        {1,0,0,1,0,0,1,0,0,1,0,0},
        {1,1,1,1,1,1,1,1,1,1,1,1},
    },
    prime_322 = {
        {1,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,0,0,0,1,0,0,0,0,0},
        {1,0,0,1,0,0,1,0,0,1,0,0},
        {1,1,1,1,1,1,1,1,1,1,1,1},
    },
    king_1 = {
        {1,0,1,0,1,1,0,1,0,1,0,1},
        {1,0,1,0,1,1,0,1,0,1,0,1},
        {1,0,1,1,0,1,0,0,1,1,0,0},
        {1,0,1,1,0,1,0,0,1,1,0,0},
    },
    king_2 = {
        {1,0,1,1,0,1,0,0,1,1,0,0},
        {1,0,1,1,0,1,0,0,0,1,0,0},
        {1,0,1,0,1,1,0,1,0,1,0,1},
        {1,0,1,0,1,1,0,1,0,1,0,1},
    },
    kroboto = {
        {0,0,1,0,1,1,0,0,1,0,1,1},
        {0,0,1,0,1,1,0,0,1,0,1,1},
        {1,0,0,0,0,0,1,0,0,1,0,0},
        {1,0,1,0,1,1,0,1,0,1,0,1},
    },
    vodou_1 = {
        {1,0,1,0,1,0,1,1,0,1,0,1},
        {1,0,1,0,1,0,1,1,0,1,0,1},
        {1,0,0,0,0,0,1,0,0,1,0,0},
        {0,0,0,0,1,1,0,0,0,0,1,1},
    },
    vodou_2 = {
        {0,1,1,0,1,1,0,1,1,0,1,1},
        {0,1,1,0,1,1,0,1,1,0,1,1},
        {1,0,1,0,1,0,1,1,0,1,0,1},
        {0,0,0,0,1,1,0,0,0,0,1,1},
    },
    vodou_3 = {
        {1,0,0,0,0,0,1,0,0,1,0,0},
        {1,0,0,0,0,0,1,0,0,1,0,0},
        {0,1,1,0,1,1,0,1,1,0,1,1},
        {0,0,0,0,1,1,0,0,0,0,1,1},
    },
    gahu = {
        {1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0},
        {1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0},
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0},
    },
    clave = {
        {1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0},
        {1,0,0,1,0,0,1,0,0,0,1,0,1,0,0,0},
        {1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1},
        {0,0,1,1,0,0,1,1,0,0,1,0,0,0,1,1},
    },
    rhumba = {
        {1,0,0,1,0,0,0,1,0,0,1,0,1,0,0,0},
        {1,0,0,1,0,0,0,1,0,0,1,0,1,0,0,0},
        {1,0,1,1,0,1,0,1,1,0,1,0,1,1,0,1},
        {0,0,1,1,0,0,1,1,0,0,1,0,0,0,1,1},
    },
    jhaptal_1 = {
        {0,1,0,0,1,1,1,0,0,1},
        {0,1,0,0,1,1,1,0,0,1},
        {1,0,1,1,0,0,0,1,1,0},
        {1,0,0,0,0,1,0,0,0,0},
    },
    jhaptal_2 = {
        {1,0,0,0,0,0,0,0,0,0},
        {1,0,1,1,0,0,0,1,1,0},
        {1,0,1,1,0,0,0,1,1,0},
        {1,0,0,0,0,1,0,0,0,0},
    },
    chacar = {
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0},
        {0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0},
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
    },
    mata = {
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0},
        {1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,1,0,0},
        {1,0,0,0,1,0,1,0,0,0,0,0,1,1,0,1,0,1},
        {0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1},
    },
    pashto = {
        {1,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,1,1,0,0,0,0,0,0,1,0},
        {0,0,0,0,1,1,0,0,0,0,0,0,1,0},
        {1,0,0,0,0,0,1,0,0,0,1,0,0,0},
    },
    prime_232 = {
        {1,0,0,0,0,0,0,0,0,0,0,0},
        {1,0,0,0,0,0,1,0,0,0,0,0},
        {1,0,1,0,1,0,1,0,1,0,1,0},
        {1,1,1,1,1,1,1,1,1,1,1,1},
    },
}

--- Create a new Zularic Repetitor.
-- @tparam[opt] string bank, see ZR.new_world, ZR.old_world and ZR.banks, default: 'motorik_1'
-- @tparam[opt] number child which of the 4 rhythms from the bank, 1 is mother rhythm (default)
-- @tparam[opt] number offset number of steps to offset the rhythm, resulting index always wraps
-- @treturn table ZR
function ZR.new(bank, child, offset)
    bank, child, offset = bank or 'motorik_1', child or 1, offset or 0
    local zr = {
        bank=bank,
        child=child,
        offset=offset,
        ix=1,
    }
    setmetatable(zr, ZR)
    return zr
end

--- is v a table that is (hopefully) callable or a function?
-- we could check the metatable for __call but doesn't seem necessary
local function callable(v)
    local v_type = type(v)
    if v_type == 'table' or v_type == 'function' then
        return true
    end
    return false
end

local function is_table(t) return type(t) == 'table' end

--- Get the next step. Optionally override the world, bank, child, offset from construction.
-- @tparam[opt] table args 'bank', 'child', 'offset' (all optional)
-- @tparam[opt] string args.bank, see ZR.new_world, ZR.old_world and ZR.banks default: self.bank
-- @tparam[opt] number args.child which of the 4 rhythms from the bank, 1 is mother rhythm, default: self.child
-- @tparam[opt] number args.offset number of steps to offset the rhythm, resulting index always wraps, default: self.offset
-- @treturn boolean
function ZR.next(self, args)
    args = args or {}
    local bank = args.bank or self.bank
    local child, offset = args.child or self.child, args.offset or self.offset
    if callable(bank) then bank = math.floor(bank()) end
    if callable(child) then child = math.floor(child()) end
    if callable(offset) then offset = math.floor(offset()) end
    local pattern = ZR.banks[bank][child]
    local length = #pattern
    local offset_ix = (((self.ix + offset) - 1) % length) + 1
    self.ix = (self.ix % length) + 1
    return pattern[offset_ix] == 1 and true or false
end

-- Get the next step but then decrement the index back.
function ZR.peek(self, args)
    local step = self:next(args)
    self.ix = self.ix - 1
    if self.ix < 1 then
        self.ix = 1
    end
    return step
end

--- Reset the pattern to the first step.
function ZR.reset(self)
    self.ix = 1
    if is_table(self.bank) then self.bank:reset() end
    if is_table(self.child) then self.child:reset() end
    if is_table(self.offset) then self.offset:reset() end
end

--- Helper to convert to a pattern to a table.
function ZR.to_table(self, num_steps)
    self:reset()
    num_steps = num_steps or #ZR.banks[self.bank][self.child]
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self:reset()
    return pattern
end

--- Helper to print the pattern to the console.
function ZR.print(self)
    local pattern = self:to_table(#ZR.banks[self.bank][self.child])
    tab.print(pattern)
end

ZR.__call = function(self, ...)
    return (self == ZR) and ZR.new(...) or ZR.next(self, ...)
end

ZR.metaix = {reset=ZR.reset, to_table=ZR.to_table, print=ZR.print}

ZR.__index = function(self, ix)
    return ZR.metaix[ix]
end

setmetatable(ZR, ZR)

return ZR