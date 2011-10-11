print "1..9"

local src_dir, build_dir = ...
package.path  = (src_dir or "./") .. "?.lua;" .. package.path
package.cpath = (build_dir or "./") .. "?.so;" .. package.cpath

local tap   = require("tap")
local lz    = require("zlib")
local ok    = tap.ok
local table = require("table")

function main()
   test_stats()
   test_buff_err()
   test_small_inputs()
   test_basic()
   test_large()
   test_no_input()
   test_invalid_input()
   test_streaming()
   test_illegal_state()
   test_checksum()
   test_version()
end

function test_stats()
   local string = ("one"):rep(20)
   local deflated, eof, bin, bout = lz.deflate()(string, 'finish')
   ok(eof == true, "eof is true (" .. tostring(eof) .. ")");
   ok(bin > bout, "bytes in is greater than bytes out?")
   ok(#deflated == bout, "bytes out is the same size as deflated string length")
   ok(#string == bin, "bytes in is the same size as the input string length")
end

-- Thanks to Tobias Markmann for the bug report!  We are trying to
-- force inflate() to return a Z_BUF_ERROR (which should be recovered
-- from).  For some reason this only happens when the input is exactly
-- LUAL_BUFFERSIZE (at least on my machine).
function test_buff_err()
   local text = ("X"):rep(lz._TEST_BUFSIZ);

   local deflated = lz.deflate()(text, 'finish')

   for i=1,#deflated do
      lz.inflate()(deflated:sub(1,i))
   end
end

function test_small_inputs()
   local text = ("X"):rep(lz._TEST_BUFSIZ);

   local deflated = lz.deflate()(text, 'finish')

   local inflated = {}
   local inflator = lz.inflate()
   for i=1,#deflated do
      local part = inflator(deflated:sub(i,i))
      table.insert(inflated, part)
   end
   inflated = table.concat(inflated)
   ok(inflated == text, "Expected " .. #text .. " Xs got " .. #inflated)
end

function test_basic()
   local test_string = "abcdefghijklmnopqrstuv"

   -- Input to deflate is same as output to inflate:
   local deflated = lz.deflate()(test_string, "finish")
   local inflated = lz.inflate()(deflated, "finish")

   ok(test_string == inflated, "'" .. tostring(test_string) .. "' == '" .. tostring(inflated) .. "'")
end

function test_large()
   -- Try a larger string:
   local numbers = ""
   for i=1, 100 do numbers = numbers .. string.format("%3d", i) end
   local numbers_table = {}
   for i=1, 10000 do numbers_table[i] = numbers end
   local test_string = table.concat(numbers_table, "\n")

   local deflated = lz.deflate()(test_string, "finish")
   local inflated = lz.inflate()(deflated, "finish")
   ok(test_string == inflated, "large string")
end

function test_no_input()
   local stream = lz.deflate()
   local deflated = stream("")
   deflated = deflated .. stream("")
   deflated = deflated .. stream(nil, "finish")
   ok("" == lz.inflate()(deflated, "finish"), "empty string")
end

function test_invalid_input()
   local stream = lz.inflate()
   local _, emsg = pcall(
      function()
         stream("bad input")
      end)
   ok(string.find(emsg, "^InvalidInput"),
      string.format("InvalidInput error (%s)", emsg))
end

function test_streaming()
   local shrink     = lz.deflate(lz.BEST_COMPRESSION)
   local enlarge    = lz.inflate()
   local expected   = {}
   local got        = {} 
   local chant      = "Isn't He great, isn't He wonderful?\n"
   for i=1,100 do
      if ( i == 100 ) then
         chant = nil
         print "EOF round"
      end
      local shrink_part, shrink_eof   = shrink(chant)
      local enlarge_part, enlarge_eof = enlarge(shrink_part)
      if ( i == 100 ) then
         if not shrink_eof  then error("expected eof after shrinking flush") end
         if not enlarge_eof then error("expected eof after enlarging") end
      else
         if shrink_eof  then error("unexpected eof after shrinking") end
         if enlarge_eof then error("unexpected eof after enlarging") end
      end
      if enlarge_part then table.insert(got, enlarge_part) end
      if chant        then table.insert(expected, chant) end
   end
   ok(table.concat(got) == table.concat(expected), "streaming works")
end

function test_illegal_state()
   local stream = lz.deflate()
   stream("abc")
   stream() -- eof/close

   local _, emsg = pcall(
      function()
         stream("printing on 'closed' handle")
      end)
   ok(string.find(emsg, "^IllegalState"),
      string.format("IllegalState error (%s)", emsg))
   
   local enlarge = lz.inflate()
end

function test_checksum()
    local string = ("one"):rep(100)
    local res = zlib.adler32(string)
    local res2 = zlib.adler32()
    local res3 = zlib.adler32(("one"):rep(50))
    res3 = zlib.adler32(res3, res3, 50*3)
    for i = 1, 100 do
        res2 = zlib.adler32("one", res2)
    end
    ok(res == res2, "partical adler32 is equal whole checksum (" .. ("%04x"):format(res) .. ")")
    ok(res == res3, "combined adler32 is equal whole checksum (" .. ("%04x"):format(res) .. ")")

    local res = zlib.crc32(string)
    local res2 = zlib.crc32()
    local res3 = zlib.crc32(("one"):rep(50))
    res3 = zlib.crc32(res3, res3, 50*3)
    for i = 1, 100 do
        res2 = zlib.crc32("one", res2)
    end
    ok(res == res2, "partical crc32 is equal whole checksum (" .. ("%04x"):format(res) .. ")")
    ok(res == res3, "combined crc32 is equal whole checksum (" .. ("%04x"):format(res) .. ")")
end

function test_version()
   local major, minor, patch = lz.version()
   ok(1 == major, "major version 1 == " .. major);
   ok(type(minor) == "number", "minor version is number (" .. minor .. ")")
   ok(type(patch) == "number", "patch version is number (" .. patch .. ")")
end

main()
