--- sequins
-- nestable tables with sequencing behaviours & control flow
-- TODO i think ASL can be defined in terms of a sequins...


local S = {}

function S.new(t, random)
    -- wrap a table in a sequins with defaults
    local s = { data   = t
              , length = #t -- memoize table length for speed
              , set_ix = 1 -- force first stage to start at elem 1
              , ix     = 1 -- current val
              , n      = 1 -- can be a sequin or a function
              , random = random -- always return a random element
              }
    s.action = {up = s}
    setmetatable(s, S)
    return s
end

local function wrap_index(s, ix) return ((ix - 1) % s.length) + 1 end

-- can this be generalized to cover every/count/times etc
function S.setdata(self, t)
    self.data   = t
    self.length = #t
    self.ix = wrap_index(self, self.ix)
end

function S.is_sequins(t) return getmetatable(t) == S end

local function turtle(t, fn)
    -- apply fn to all nested sequins. default to 'next'
    if S.is_sequins(t) then
        if fn then
            return fn(t)
        else return S.next(t) end
    end
    return t
end

local function nval(val)
    if type(val) == 'function' then return math.floor(val()) end
    return val
end

----------------------------------------------
--- destructive manipulation of the data table

-- source: https://gist.github.com/Uradamus/10323382
function S.shuffle(self)
    for i = self.length, 2, -1 do
        local j = math.random(i)
        self.data[i], self.data[j] = self.data[j], self.data[i]
    end
    return self
end

-- source: https://github.com/HuotChu/ArrayForLua
function S.reverse(self, start, stop)
    start, stop = start or 1, stop or self.length
    local distance, temp, start_index, stop_index

    if not start then
        start = 1
    elseif start < 1 then
        start = stop - start
    end

    if start == 0 then
        start = stop
    end

    if not stop or stop > self.length then
        stop = self.length
    elseif stop < 1 then
        stop = self.length - stop
    end

    if stop < start then
        stop = start
    end

    distance = stop - start

    for i = math.floor(distance * .5), 0, -1 do
        start_index = start + i
        stop_index = stop - i
        if start_index ~= stop_index then
            temp = self.data[start_index]
            self.data[start_index] = self.data[stop_index]
            self.data[stop_index] = temp
        end
    end
    return self
end

-- source: https://github.com/HuotChu/ArrayForLua
function S.rotate(self, step, start, stop)
    step, start, stop = step or 1, start or 1, stop or self.length
    local split, calculated_stop

    if step ~= 0 then
        split = start + step

        if step > 0 then
            calculated_stop = split - 1
        else
            calculated_stop = stop + step
        end
        S.reverse(self, start, calculated_stop)
        S.reverse(self, calculated_stop + 1, stop)
        S.reverse(self, start, stop)
    end
    return self
end

-- source: https://github.com/HuotChu/ArrayForLua
function S.map(self, callback, context)
    local mapped_table = {}
    local success, result
    for i, v in ipairs(self.data) do
        success, result = pcall(callback, v, i, self.data, context or S)
        if success then
            table.insert(mapped_table, result)
        else
            table.insert(mapped_table, v)
        end
    end
    self.data = mapped_table
    return self
end

------------------------------
--- control flow execution

function S.next(self)
    local act = self.action
    if act.action then
        return S.do_ctrl(act)
    else return S.do_step(act) end
end

function S.select(self, ix)
    rawset(self, 'set_ix', ix)
    return self
end

function S.do_step(act)
    local s = act.up
    local newix
    if s.random then
        -- if .random is true, use a random index rather than incrementing by s.n
        newix = math.random(s.length)
        print('new random ix = '..newix)
    else
        -- if .set_ix is set, it will be used, rather than incrementing by s.n
        newix = wrap_index(s, s.set_ix or s.ix + turtle(nval(s.n)))
    end
    local retval, exec = turtle(s.data[newix])
    if exec ~= 'again' then s.ix = newix; s.set_ix = nil end
    -- FIXME add protection for list of dead sequins. for now we just recur, hoping for a live sequin in nest
    if exec == 'skip' then return S.next(s) end
    return retval, exec
end


------------------------------
--- control flow manipulation

function S.do_ctrl(act)
    act.ix = act.ix + 1
    local retval, exec
    if not act.cond or act.cond(act) then
        retval, exec = S.next(act)
        if exec then act.ix = act.ix - 1 end -- undo increment
    else
        retval, exec = {}, 'skip'
    end
    if act.rcond then
        if act.rcond(act) then
            if exec == 'skip' then retval, exec = S.next(act)
            else exec = 'again' end
        end
    end
    return retval, exec
end

function S.reset(self)
    self.ix = self.length
    for _,v in ipairs(self.data) do turtle(v, S.reset) end
    local a = self.action
    while a.ix do
        a.ix = 0
        turtle(nval(a.n), S.reset)
        a = a.action
    end
end

--- behaviour modifiers
function S.step(self, s) self.n = s; return self end
function S.drunk(self, w)
    w = w or 0.5
    self.n = function()
        if math.random() > w then
            return 1
        else
            return -1
        end
    end
    return self
end

function S.extend(self, t)
    self.action = { up     = self -- containing sequins
                  , action = self.action -- wrap nested actions
                  , ix     = 0
                  }
    for k,v in pairs(t) do self.action[k] = v end
    return self
end

function S._every(self)
    return (self.ix % turtle(nval(self.n))) == 0
end

function S._times(self)
    return self.ix <= turtle(nval(self.n))
end

function S._count(self)
    if self.ix < turtle(nval(self.n)) then return true
    else self.ix = 0 end -- reset
end

function S.cond(self, p) return S.extend(self, {cond = p}) end
function S.condr(self, p) return S.extend(self, {cond = p, rcond = p}) end
function S.every(self, n) return S.extend(self, {cond = S._every, n = n}) end
function S.times(self, n) return S.extend(self, {cond = S._times, n = n}) end
function S.count(self, n) return S.extend(self, {rcond = S._count, n = n}) end

--- helpers in terms of core
function S.all(self) return self:count(self.length) end
function S.once(self) return self:times(1) end


--- metamethods

S.__call = function(self, ...)
    return (self == S) and S.new(...) or S.next(self)
end

S.metaix = { settable = S.setdata
           , step     = S.step
           , drunk    = S.drunk
           , cond     = S.cond
           , condr    = S.condr
           , every    = S.every
           , times    = S.times
           , count    = S.count
           , all      = S.all
           , once     = S.once
           , reset    = S.reset
           , select   = S.select
           , reverse  = S.reverse
           , rotate   = S.rotate
           , map      = S.map
           , shuffle  = S.shuffle
           }
S.__index = function(self, ix)
    -- runtime calls to step() and select() should return values, not functions
    if type(ix) == 'number' then return self.data[ix]
    else
        return S.metaix[ix]
    end
end

S.__newindex = function(self, ix, v)
    if type(ix) == 'number' then self.data[ix] = v
    elseif ix == 'n' then rawset(self,ix,v)
    end
end


setmetatable(S, S)

return S