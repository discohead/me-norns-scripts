--- Emulation of the Noise Engineering Zularic Repetitor pattern generator.
-- See the manual: https://www.noiseengineering.us/shop/zularic-repetitor
local ZR = {
    WORLDS = {new = 'new', old = 'old'},
    BANKS = {
        new = {
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
            prime_3 = 'prime_322',
        },
        old = {
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
}

--- See pages 5-8 of the manual: https://www.noiseengineering.us/shop/zularic-repetitor
ZR.patterns = {
    new = {
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
    },
    old = {
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
    },
}

--- Create a new Zularic Repetitor.
-- @tparam[opt] string world 'new' or 'old', see ZR.WORLDS, default: 'new'
-- @tparam[opt] string bank, see ZR.BANKS, default: 'motorik_1'
-- @tparam[opt] number child which of the 4 rhythms from the bank, 1 is mother rhythm (default)
-- @tparam[opt] number offset number of steps to offset the rhythm, resulting index always wraps
-- @treturn table ZR
function ZR.new(world, bank, child, offset)
    world, bank, child, offset = world or 'new', bank or 'motorik_1', child or 1, offset or 0
    local zr = {
        world=world,
        bank=bank,
        child=child,
        offset=offset,
        ix=1,
        length=#ZR.patterns[world][bank][child]
    }
    setmetatable(zr, ZR)
    return zr
end

--- Get the next step. Optionally override the world, bank, child, offset from construction.
-- @tparam[opt] table args 'world', 'bank', 'child', 'offset' (all optional)
-- @tparam[opt] string args.world 'new' or 'old', see ZR.WORLDS, default: self.world
-- @tparam[opt] string args.bank, see ZR.BANKS, default: self.bank
-- @tparam[opt] number args.child which of the 4 rhythms from the bank, 1 is mother rhythm, default: self.child
-- @tparam[opt] number args.offset number of steps to offset the rhythm, resulting index always wraps, default: self.offset
-- @treturn boolean
function ZR.next(self, args)
    args = args or {}
    local world, bank = args.world or self.world, args.bank or self.bank
    local child, offset = args.child or self.child, args.offset or self.offset
    local pattern = ZR.patterns[world][bank][child]
    local offset_ix = (((self.ix + offset) - 1) % self.length) + 1
    self.ix = (self.ix % self.length) + 1
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
end

--- Helper to print the pattern to the console.
function ZR.print(self)
    local current_ix = self.ix
    self.ix = 1
    local pattern = {}
    for step=1, 16 do
        table.insert(pattern, self())
    end
    self.ix = current_ix
    tab.print(pattern)
end

ZR.__call = function(self, ...)
    return (self == ZR) and ZR.new(...) or ZR.next(self, ...)
end

ZR.metaix = {reset=ZR.reset, print=ZR.print}

ZR.__index = function(self, ix)
    return ZR.metaix[ix]
end

ZR.__newindex = function(self, ix, v)
    if ix == 'world' or ix == 'bank' or ix == 'child' or ix == 'offset' then
        rawset(self,ix,v)
    end
end

setmetatable(ZR, ZR)

return ZR