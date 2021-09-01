local XR = {AND='and', OR='or', XOR='xor', NOR='nor', NAND='nand', XNOR='xnor'}

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

    local chosen_r
    if r3_type == 'number' then
        if math.random() >= r3 then
            chosen_r = self.r1
        else
            chosen_r = self.r2
        end
    else
        if r3() then
            switch = not switch
        end
        if switch then
            chosen_r = self.r2
        else
            chosen_r = self.r1
        end
    end
    return chosen_r()
end

function XR.reset(self)
    self.r1.ix = 1
    self.r2.ix = 1
    if self.r3_type == 'table' then
        self.r3.ix = 1
    end
end

function XR.set_r3(self, r3)
    self.r3_type = type(r3)
    self.r3 = r3
end

--- Helper to print the pattern to the console.
function XR.print(self, num_steps)
    local r1_ix = self.r1.ix
    local r2_ix = self.r2.ix
    local r3_ix
    if self.r3_type == 'table' then
        r3_ix = self.r3.ix
    end
    XR.reset(self)
    local pattern = {}
    for step=1, num_steps do
        table.insert(pattern, self())
    end
    self.r1.ix = r1_ix
    self.r2.ix = r2_ix
    if r3_ix then
        self.r3.ix = r3_ix
    end
    tab.print(pattern)
end

XR.__call = function(self, ...)
    return (self == XR) and XR.new(...) or XR.next(self, ...)
end

XR.metaix = {reset=XR.reset, print=XR.print, set_r3=XR.set_r3}

XR.__index = function(self, ix)
    return XR.metaix[ix]
end

setmetatable(XR, XR)

return XR