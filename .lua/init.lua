-- Lua init file. It tries to degrade gracefully with the presence of
-- libraries and luajit. To autoload it, you can execute the following in
-- your favourite shell.
--
--   export LUA_INIT="@$HOME/.lua/init.lua"

-- Add $HOME/.lua to the search path.
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.lua/?.lua"
package.cpath = package.cpath .. ";" .. os.getenv("HOME") .. "/.lua/?.so"

-- Load modules.
has_fun, fun     = pcall(require, 'fun')
has_ml, ml       = pcall(require, 'ml')
has_syscall, sys = pcall(require, 'syscall')
has_graph, graph = pcall(require, 'graph')
has_ffi, ffi     = pcall(require, 'ffi')

-- Detect luajit.
has_lj           = type(jit) == 'table'

-- Basic lua version of ml.compose(io.write, string.format).
printf = function(s,...) return io.write(s:format(...)) end

-- Benchmarking support.
if has_syscall and has_lj and jit.os == "Linux" then
  -- Return a point in time. This timestamp will only advance when this
  -- thread (process for LuaJIT) is on-CPU. The data type of the return
  -- value is system dependent. Use tick_diff() to get a number value.
  --
  --   local start = tick_user()
  --   heavy_function()
  --   local ns_passed = tick_diff(start, tick_user())
  function tick_user()
    return sys.clock_gettime(sys.c.CLOCK.THREAD_CPUTIME_ID)
  end

  -- Returns a timestamp that advances with wall-clock time.
  function tick_wall()
    return sys.clock_gettime(sys.c.CLOCK.MONOTONIC_RAW)
  end

  local function ts_to_u64(ts)
    return ffi.cast("uint64_t", ts.tv_sec), ffi.cast("uint64_t", ts.tv_nsec)
  end

  -- Returns the difference between two ticks (b - a) in nanoseconds.
  function tick_diff(a, b)
    local seca, nseca = ts_to_u64(a)
    local secb, nsecb = ts_to_u64(b)
    return tonumber((secb - seca) * 1000000000ULL + (nsecb - nseca))
  end

  -- Benchmark function <fn>. Pass rest of the arguments to it (like
  -- Bernstein chaining). Returns the elapsed time in nanoseconds.
  function bench(fn, ...)
    local a, val, b = tick_user(), fn(...), tick_user()
    return tick_diff(a, b)
  end
end

-- If we could use table.pack and table.unpack, we could generalize this to:
--
--   function curry(fn, ...)
--     local up = table.pack(...)
--     return function(...) return fn(table.unpack(up), ...) end
--   end
--
-- However, luajit without the LUA52COMPAT option doesn't have this.
function curry(fn, arg)
  return function(...)
      return fn(arg, ...)
  end
end

-- Checks if val is in the iterator. Equivalent to
-- fun.wrap(...).any(function(item) return val == item end).
function isin(val, ...)
  for _, v in ... do
    if v == val then return true end
  end
  return false
end

function round(n)
  return math.floor(n + 0.5)
end

function log2(n)
  return math.log(n) / math.log(2)
end

-- Make all math functions part of the global namespace, reduces typing.
-- Nice when using lua as a souped-up bc(1).
for k,v in pairs(math) do
  _G[k] = v
end

-- Construct examples string, which the user may choose to print out.
examples = "Available modules:\n"
if has_ml then
  examples = examples .. [[
  ml:    ml.tstring(val), ml.split('hello dolly'), ml.readfile(fname), ...
]]
end
if has_fun then
  examples = examples .. [[
  fun:   fun.range(100):map(function(x) return x^2 end):reduce(operator.add, 0)
]]
end
if has_graph then
  examples = examples .. [[
  graph: p = graph.plot('y = sin(x) * x^2'); p:addline(graph.fxline(function(x) return math.sin(x) * x^2 end, 0, 25), 'red'); p:show()
]]
end
if has_syscall and has_lj and jit.os == "Linux" then
  examples = examples .. [[
  bench: bench(function() fun.range(100):map(function(x) return x^2 end):reduce(operator.add, 0) end)]]
end

-- Print the examples if --examples was passed as an argument
if arg ~= nil and isin("--examples", ipairs(arg)) then
  print(examples)
end
