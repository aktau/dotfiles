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

-- Override tostring so that it also handles tables. We can't just alter the
-- table metatable to have a __tostring method because each new table gets a
-- clean metatable. Implementation from
-- http://lua-users.org/lists/lua-l/2006-11/msg00079.html. Thanks Aaron
-- Brown!
do
  -- Save the original implementation in _tostring.
  local _tostring = tostring

  -- Characters that have non-numeric backslash-escaped versions:
  local BsChars = {
    ["\a"] = "\\a",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
    ["\""] = "\\\"",
    ["\\"] = "\\\\"
  }

  -- Is Str an "escapeable" character (a non-printing character other than
  -- space, a backslash, or a double quote)?
  local function IsEscapeable(Char)
    return string.find(Char, "[^%w%p]") -- Non-alphanumeric, non-punct.
      and Char ~= " "                   -- Don't count spaces.
      or string.find(Char, '[\\"]')     -- A backslash or quote.
  end

  -- Converts an "escapeable" character (a non-printing character,
  -- backslash, or double quote) to its backslash-escaped version; the
  -- second argument is used so that numeric character codes can have one or
  -- two digits unless three are necessary, which means that the returned
  -- value may represent both the character in question and the digit after
  -- it:
  local function EscapeableToEscaped(Char, FollowingDigit)
    if IsEscapeable(Char) then
      local Format = FollowingDigit == ""
        and "\\%d"
        or "\\%03d" .. FollowingDigit
      return BsChars[Char]
        or string.format(Format, string.byte(Char))
    else
      return Char .. FollowingDigit
    end
  end

  -- Quotes a string in a Lua- and human-readable way.  (This is a
  -- replacement for string.format's %q placeholder, whose result isn't
  -- always human readable.)
  local function StrToStr(Str)
    return '"' .. string.gsub(Str, "(.)(%d?)", EscapeableToEscaped) .. '"'
  end

  -- Lua keywords:
  local Keywords = {["and"] = true, ["break"] = true, ["do"] = true,
    ["else"] = true, ["elseif"] = true, ["end"] = true, ["false"] = true,
    ["for"] = true, ["function"] = true, ["if"] = true, ["in"] = true,
    ["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true,
    ["repeat"] = true, ["return"] = true, ["then"] = true,
    ["true"] = true, ["until"] = true, ["while"] = true}

  -- Is Str an identifier?
  local function IsIdent(Str)
    return not Keywords[Str] and string.find(Str, "^[%a_][%w_]*$")
  end

  -- Converts a non-table to a Lua- and human-readable string.
  local function ScalarToStr(Val)
    local Ret
    local Type = type(Val)
    if Type == "string" then
      Ret = StrToStr(Val)
    elseif Type == "function" or Type == "userdata" or Type == "thread" then
      -- Punt:
      Ret = "<" .. _tostring(Val) .. ">"
    else
      Ret = _tostring(Val)
    end -- if
    return Ret
  end

  -- Converts a table to a Lua- and human-readable string.
  local function TblToStr(Tbl, Seen)
    Seen = Seen or {}
    local Ret = {}
    if not Seen[Tbl] then
      Seen[Tbl] = true
      local LastArrayKey = 0
      for Key, Val in pairs(Tbl) do
        if type(Key) == "table" then
          Key = "[" .. TblToStr(Key, Seen) .. "]"
        elseif not IsIdent(Key) then
          -- If the key is an identifier (and not a regular numeric index),
          -- we have to use the { [...] = ... } table syntax.
          if type(Key) == "number" and Key == LastArrayKey + 1 then
            -- Don't mess with Key if it's an array key.
            LastArrayKey = Key
          else
            Key = "[" .. ScalarToStr(Key) .. "]"
          end
        end
        if type(Val) == "table" then
          Val = TblToStr(Val, Seen)
        else
          Val = ScalarToStr(Val)
        end
        Ret[#Ret + 1] = (type(Key) == "string"
          and (Key .. " = ") -- Explicit key.
          or "")             -- Implicit array key.
          .. Val
      end
      Ret = "{" .. table.concat(Ret, ",") .. "}"
    else
      Ret = "<cycle to " .. _tostring(Tbl) .. ">"
    end
    return Ret
  end

  -- Override global tostring. It handles tables specially (except those
  -- that have a custom __tostring method), by printing their structure
  -- instead of <table: 0x...>.
  function tostring(t)
    if type(t) == 'table' and not
      (getmetatable(t) and getmetatable(t).__tostring) then
      return TblToStr(t)
    end
    return _tostring(t)
  end
end

-- Basic lua version of ml.compose(io.write, string.format). Alternatively,
-- you can use io.write(aString % {values}).
function printf(s, ...)
  return io.write(s:format(...))
end

-- Add the % operator to string types. It is used to format strings, like in
-- Python.
--
-- EXAMPLE
--
--   print("%d is an integer" % 5)
getmetatable("").__mod = function(a, b)
  if not b then
    return a
  end

  if type(b) == "table" then
    return string.format(a, unpack(b))
  end

  return string.format(a, b)
end

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

-- Stiter turns a stateful iterator like io.lines() into an iterator
-- accepted by luafun. It generates a "fake" state and returns the actual
-- output (value) as the second parameter (instead of the first). This
-- avoids the output from being mistaken as the state.
--
-- Example: lua.each(print, stiter(io.lines()))
function stiter(it)
  return function()
    local v = it()
    if v == nil then return nil end -- Break if iterator is done.
    return 1, v
  end
end

-- Define table.pack() for Lua 5.1.
--
-- Curious note, if, in Lua 5.1 the ... notation is used, arg will not be
-- defined.
--
--   lua -e 'function x(...) return arg end ; print(x(1,2,3))'
--   table: 0x18036e0
--
--   lua -e 'function x(...) return ... end ; print(x(1,2,3))'
--   1    2   3
--
--   lua -e 'function x(...) print(...) ; return arg end ; print(x(1,2,3))'
--   1  2   3
--   nil
--
-- Wat?!
if table.pack == nil then
  function table.pack(...)
    return { n = select("#", ...), ... }
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

if math.round == nil then
  function math.round(n)
    return math.floor(n + 0.5)
  end
end

if math.log2 == nil then
  function math.log2(n)
    return math.log(n) / math.log(2)
  end
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
