local Graph = require "graph"

local curves = {}

-- local helper functions

local function callable(v) return (type(v) == 'function') and true or false end

local function clamp(pos)
    if pos > 1.0 then
        return 1.0
    elseif pos < 0.0 then
        return 0.0
    end
    return pos
end

local function calc_pos(pos, rate, phase)
    pos = clamp(pos)
    if callable(rate) then
        pos = pos * rate(pos)
    else
        pos = pos * rate
    end
    if callable(phase) then
        return (pos + phase(pos)) % 1.0
    else
        return (pos + phase) % 1.0
    end
end

local function amp_bias(value, amp, bias, pos)
    pos = pos or value
    if callable(amp) then amp = amp(pos) end
    if callable(bias) then bias = bias(pos) end
    return (value * amp) + bias
end

local function pos2rad(pos)
    pos = clamp(pos)
    degrees = pos * 360
    return math.rad(degrees)
end

local function tri_distribution(low, high, mode)
    r = math.random()
    if mode == nil then
        mode = 0.5
    else
        local divisor = high - low
        if divisor < 0 then divisor = low end
    end
    if r > mode then
        r = 1.0 - r
        mode = 1.0 - mode
        low, high = high, low
    end
    return low + (high - low) * math.sqrt(r * mode)
end

-- composeable curve function generators

--- Constant value function that can optionally be modulated.
-- @tparam[opt] table args v, m, a, r, p, b (all are optional)
-- @tparam number|function args.v value to return or modulate, defaults to 1
-- @tparam boolean args.m indicates whether or not to apply modulation, defaults to nil
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.const(args)
    args.v = args.v or 1
    args.a, args.r, args.p, args.b = args.a or 1, args.r or 1, args.p or 0, args.b or 0
    function f(pos)
        if args.m then
            pos = calc_pos(pos, args.r, args.p)
            if callable(args.v) then args.v = args.v(pos) end
            return amp_bias(args.v, args.a, args.b, pos)
        else
            return args.v
        end
    end
    return f
end

--- Random value function, uniform or triangular distribution.
-- @tparam[opt] table args lo, hi, m, a, r, p, b (all are optional)
-- @tparam number|function args.lo minimum random result, defaults to 0
-- @tparam number|function args.hi maximum random result, defaults to 1
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates the random value given a 0-1 phase argument
function curves.noise(args)
    args.lo, args.hi = args.lo or 0, args.hi or 1
    args.a, args.r, args.p, args.b = args.a or 1, args.r or 1, args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        if callable(args.lo) then args.lo = args.lo(pos) end
        if callable(args.hi) then args.hi = args.hi(pos) end
        if args.mode ~= nil then
            -- use Triangular Distribution
            if callable(args.mode) then args.mode = args.mode(pos) end
            return amp_bias(tri_distribution(args.lo, args.hi, args.mode), args.a,
                            args.b, pos)
        else
            -- use Uniform Distribution
            local rand_float = args.lo + math.random() * (args.hi - args.lo)
            return amp_bias(rand_float, args.a, args.b, pos)
        end
    end
    return f
end

--- Linear function aka ramp or phasor.
-- @tparam[opt] table args a, r, p, b (all are optional)
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.ramp(args)
    args.a, args.r, args.p, args.b = args.a or 1, args.r or 1, args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        return amp_bias(pos, args.a, args.b)
    end
    return f
end

--- Inverse linear function aka sawtooth.
-- @tparam[opt] table args a, r, p, b (all are optional)
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.saw(args)
    args.a, args.r, args.p, args.b = args.a or 1, args.r or 1, args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(1 - pos, args.r, args.p)
        return amp_bias(pos, args.a, args.b)
    end
    return f
end

--- Triangle wave function with symmetry.
-- @tparam[opt] table args s, a, r, p, b (all are optional)
-- @tparam number|function args.s symmetry of triangle, 0 = saw, 1 = ramp, defaults to 0.5
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.tri(args)
    args.s, args.a, args.r = args.s or 0.5, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        if callable(args.s) then args.s = args.s(pos) end
        if pos < args.s then
            value = pos * 1 / args.s
        else
            value = 1 - ((pos - args.s) * (1 / (1 - args.s)))
        end
        return amp_bias(value, args.a, args.b, pos)
    end
    return f
end

--- Sine wave function.
-- @tparam[opt] table args a, r, p, b (all are optional)
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.sine(args)
    args.a, args.r, args.p, args.b = args.a or 1, args.r or 1, args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        return amp_bias((math.sin(pos2rad(pos)) * 0.5) + 0.5, args.a, args.b, pos)
    end
    return f
end

--- Pulse wave function with pwm.
-- @tparam[opt] table args w, a, r, p, b (all are optional)
-- @tparam number|function args.w pulse width between 0-1, defaults to 0.5
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.pulse(args)
    args.w, args.a, args.r = args.w or 0.5, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        if callable(args.w) then args.w = args.w(pos) end
        if pos < args.w then
            return amp_bias(0.0, args.a, args.b, pos)
        else
            return amp_bias(1.0, args.a, args.b, pos)
        end
    end
    return f
end

--- Exponential function aka ease in curve.
-- @tparam[opt] table args e, a, r, p, b (all are optional)
-- @tparam number|function args.e exponent, defaults to 2
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.ease_in(args)
    args.e, args.a, args.r = args.e or 2, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        if callable(args.e) then args.e = args.e(pos) end
        return amp_bias(pos ^ args.e, args.a, args.b, pos)
    end
    return f
end

--- Logarithmic function aka ease out curve.
-- @tparam[opt] table args e, a, r, p, b (all are optional)
-- @tparam number|function args.e exponent, defaults to 3
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.ease_out(args)
    args.e, args.a, args.r = args.e or 3, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        if callable(args.e) then args.e = args.e(pos) end
        return amp_bias(((pos - 1) ^ args.e) + 1, args.a, args.b, pos)
    end
    return f
end

--- Exponential to logarithmic function aka ease in-out curve.
-- @tparam[opt] table args e, a, r, p, b (all are optional)
-- @tparam number|function args.e exponent, defaults to 3
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.ease_in_out(args)
    args.e, args.a, args.r = args.e or 3, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        value = pos * 2
        if callable(args.e) then args.e = args.e(pos) end
        if value < 1 then
            return amp_bias(0.5 * (value ^ args.e), args.a, args.b, pos)
        end
        value = value - 2
        return amp_bias(0.5 * ((value ^ args.e) + 2), args.a, args.b, pos)
    end
    return f
end

--- Logarithmic to exponential function aka ease out-in curve.
-- @tparam[opt] table args e, a, r, p, b (all are optional)
-- @tparam number|function args.e exponent, defaults to 3
-- @tparam number|function args.a amplitude of resulting function, like mul in SuperCollider, defaults to 1
-- @tparam number|function args.r rate, number of periods in one phase cycle, defaults to 1
-- @tparam number|function args.p phase, phase offset, defaults to 0
-- @tparam number|function args.b bias, added at final stage of calculation, like add in SuperCollider, defaults to 0
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.ease_out_in(args)
    args.e, args.a, args.r = args.e or 3, args.a or 1, args.r or 1
    args.p, args.b = args.p or 0, args.b or 0
    function f(pos)
        pos = calc_pos(pos, args.r, args.p)
        value = (pos * 2) - 1
        if callable(args.e) then args.e = args.e(pos) end
        if value < 2 then
            return amp_bias(0.5 * ((value ^ args.e) + 0.5), args.a, args.b, pos)
        else
            return amp_bias(1.0 - ((0.5 * (value ^ args.e)) + 0.5), args.a, args.b, pos)
        end
    end
    return f
end

--- Helper function to normalize a table of numbers to within 0-1
--  The max value of the table = 1.0, 0 = 0, all negative numbers normalize to 0
-- @tparam table values table of numbers to be normalized
-- @treturn table normalized table
function curves.normalize(values)
    local min, max = next(values)
    for i, v in ipairs(values) do
        if v < min then
            min = v
        elseif v > max then
            max = v
        end
    end
    local normalized = {}
    for i, v in ipairs(values) do
        normalized[i] = (v - min) / (max - min)
    end
    return normalized
end

--- Generate a curve function from a table of numbers in time order
-- @tparam table yvalues array of y values in time order, will be normalized to 0-1
-- @treturn function a function that calculates y values of the curve given a 0-1 phase argument
function curves.timeseries(yvalues)
    yvalues = normalize(yvalues)
    function f(pos)
        local indexf = pos * (#yvalues - 1)
        pos = indexf % 1.0
        indexf = indexf + 1
        return (yvalues[math.floor(indexf)] * (1.0 - pos)) + (yvalues[math.ceil(indexf)] * pos)
    end
    return f
end

--- Helper function to sample a curve generator function to a table
-- @tparam function f a function returned from one of the curve generators
-- @tparam number num_samples the number of samples from one phase cycle of the curve
-- @tparam[opt] function map_func optional function to be applied to each sample
-- @treturn table a table of length num_samples
function curves.to_table(f, num_samples, map_func)
    samples = {}
    for i = 1, num_samples do
        sample = f((i-1)/num_samples)
        if map_func then
            sample = map_func(sample)
        end
        samples[i] = sample
    end
    return samples
end

--- Helper function to get a full-screen Graph object representing one complete phase cycle of the curve
-- @tparam function f a function returned from one of the curve generators
-- @treturn Graph a Graph object, call :redraw() on the return value in your script's redraw()
function curves.plot(f)
    point_vals = to_table(f, 128)
    signal_graph = Graph.new(0, 127, "lin", 0, 127/128, "lin", "line_and_point",
                             false, false)
    signal_graph:set_position_and_size(0, 0, 128, 64)
    for i = 1, 128 do signal_graph:add_point(i, point_vals[i]) end
    return signal_graph
end

return curves