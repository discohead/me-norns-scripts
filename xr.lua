--- Cross Rhythm Generator.
-- Combine 2 (or 3) CR, ER, NR, ZR... or XR's!
local XR = {AND='and', OR='or', XOR='xor', NOR='nor', NAND='nand', XNOR='xnor'}

--- Create a new Cross Rhythm Generator.
-- @param r1 a CR, ER, NR, ZR, XR or any function that returns a boolean when called
-- @param r2 a CR, ER, NR, ZR, XR or any function that returns a boolean when called
-- @param[opt] r3 this determines r1 and r2 will be combined, there are several options: (default 0.5)
-- 'string' - one the 6 logic gates, XR.AND, XR.OR, XR.XOR, XR.NOR, XR.NAND, XR.XNOR
-- 'number' - probably, between 0.0 and 1.0, 0.0 = 100% r1, 1.0 = 100% r2, 0.5 = 50/50, etc.
-- 'function' - a user defined function that expects r1 and r2 as parameters and returns a boolean
-- '*R' - a 3rd CR, ER, etc... that toggles the output between r1 and r2
-- @treturn table
function XR.new(r1, r2, r3)
    local xr = {
        r1 = r1,
        r2 = r2,
        r3 = r3 or 0.5,
        switch = false,
    }
    xr.r3_type = type(xr.r3)
    setmetatable(xr, XR)
    return xr
end

--- Get the next step from the Cross Rhythm Generator.
-- Optionally override r3 from constructor.
-- @param[opt] r3 this determines r1 and r2 will be combined, there are several options: (default self.r3)
-- 'string' - one the 6 logic gates, XR.AND, XR.OR, XR.XOR, XR.NOR, XR.NAND, XR.XNOR
-- 'number' - probably, between 0.0 and 1.0, 0.0 = 100% r1, 1.0 = 100% r2, 0.5 = 50/50, etc.
-- 'function' - a user defined function that expects r1 and r2 as parameters and returns a boolean
-- '*R' - a 3rd CR, ER, etc... that toggles the output between r1 and r2
-- @treturn boolean
function XR.next(self, r3)
    local r3_type = self.r3_type
    if r3 then
        r3_type = type(r3)
    else
        r3 = self.r3
    end
    if r3_type == 'string' then
        if r3 == XR.AND then
            return self.r1() and self.r2()
        elseif r3 == XR.OR then
            return self.r1() or self.r2()
        elseif r3 == XR.XOR then
            return self.r1() ~= self.r2()
        elseif r3 == XR.NOR then
            return not (self.r1() or self.r2())
        elseif r3 == XR.NAND then
            return not (self.r1() and self.r2())
        elseif r3 == XR.XNOR then
            return not (self.r1() ~= self.r2())
        else
            print('ERROR: Invalid r3 logic gate: '..r3)
            return
        end
    end

    if r3_type == 'function' then
        return r3(self.r1, self.r2)
    end

    local r1_step, r2_step = self.r1(), self.r2()
    local chosen_step
    if r3_type == 'number' then
        if math.random() >= r3 then
            chosen_step = r1_step
        else
            chosen_step = r2_step
        end
    else
        if r3() then
            self.switch = not self.switch
        end
        if self.switch then
            chosen_step = r2_step
        else
            chosen_step = r1_step
        end
    end
    return chosen_step
end

--- Reset all rythm generators to their first step.
function XR.reset(self)
    self.r1:reset()
    self.r2:reset()
    if self.r3_type == 'table' then
        self.r3:reset()
    end
end

--- Use this to update r3 at runtime, so the type can be automatically memoized.
-- @param r3 this determines r1 and r2 will be combined, there are several options:
-- 'string' - one the 6 logic gates, XR.AND, XR.OR, XR.XOR, XR.NOR, XR.NAND, XR.XNOR
-- 'number' - probably, between 0.0 and 1.0, 0.0 = 100% r1, 1.0 = 100% r2, 0.5 = 50/50, etc.
-- 'function' - a user defined function that expects r1 and r2 as parameters and returns a boolean
-- '*R' - a 3rd CR, ER, etc... that toggles the output between r1 and r2
function XR.set_r3(self, r3)
    self.r3_type = type(r3)
    self.r3 = r3
end

--- Helper to convert pattern to a table.
-- @tparam number num_steps the number of steps to print
function XR.to_table(self, num_steps)
    self:reset()
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self:reset()
    return pattern
end

--- Helper to print the pattern to the console.
-- @tparam number num_steps the number of steps to print
function XR.print(self, num_steps)
    local pattern = self:to_table(num_steps)
    tab.print(pattern)
end

XR.__call = function(self, ...)
    return (self == XR) and XR.new(...) or XR.next(self, ...)
end

XR.metaix = {reset=XR.reset, to_table=XR.to_table, print=XR.print, set_r3=XR.set_r3}

XR.__index = function(self, ix)
    return XR.metaix[ix]
end

setmetatable(XR, XR)

return XR