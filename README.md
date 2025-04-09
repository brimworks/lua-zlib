# lua-zlib

Provides a functional, streaming interface to zlib.

## Prerequisites

To use this library, you need zlib, get it here:
* [https://zlib.net/](https://zlib.net/)

## Installing

* **Debian/Ubuntu** `apt-get install lua-zlib`
* **luarocks** `luarocks install lua-zlib`
* **source** `make <platform>`

## API

### Loading

Dynamically linked:

```lua
local zlib = require("zlib")
```

Statically linked:

```c
luaopen_zlib(L);
// zlib functions are now on the top of the Lua stack.
```

### Query ZLib Version

```lua
-- @return major (integer)
-- @return minor (integer)
-- @return patch (integer | nil)
local major, minor, patch = zlib.version()
```

Returns numeric zlib version for the major, minor, and patch
levels of the version linked in.

### Deflating

Used for compressing a stream of bytes.

```lua
-- @param compression_level (optional integer), defaults to
--     `Z_DEFAULT_COMPRESSION` (6), this is a number between 1-9 where
--     `zlib.BEST_SPEED` is 1 and `zlib.BEST_COMPRESSION` is 9.
-- @param window_size (optional integer), base two logarithm of the window size
--     (the size of the history buffer). It should be in the range of 8..15,
--     larger values result in better compression at the expense of more memory
--     used. This value can also be negative in order to indicate that "raw"
--     compression is used, and thus the zlib header is omitted in the output.
-- @return stream function documented below. The intent is to call the stream
--     function multiple times for each chunk.
local stream = zlib.deflate(compression_level, window_size)

-- @param input (string) is a byte array to compress.
-- @param flush_option (optional enum) may be `"sync"` | `"full"` | `"finish"`
-- @return deflated (string) is a byte array that is compressed.
-- @return eof (bool) indicates the `"finish"` flush_option was specified.
-- @return bytes_in (integer) the total number of input bytes processed.
-- @return bytes_out (integer) the total number of output bytes processed.
local deflated, eof, bytes_in, bytes_out = stream(input, flush_option)
```

**Flush options:**
* `"sync"` flush will force all pending output to be flushed to
    the return value and the output is aligned on a byte boundary,
    so that the decompressor can get all input data available so
    far.  Flushing may degrade compression for some compression
    algorithms and so it should be used only when necessary.
* `"full"` flush will flush all output as with `"sync"`, and the
    compression state is reset so that decompression can restart
    from this point if previous compressed data has been damaged
    or if random access is desired. Using this option too often
    can seriously degrade the compression. 
* `"finish"` flush will force all pending output to be processed
    and results in the stream become unusable.  Any future
    attempts to call `stream()` with anything other than the empty string will
    result in an error that begins with IllegalState.

### Inflating

Used for uncompressing a stream of bytes.

```lua
-- @param window_size (optional integer) should match the window size specified
--    when `zlib.deflate()` was called (absolute larger sizes are okay, but
--    will consume more memory than necessary). If not specified, a zlib header
--    is assumed to exist with information on what the correct window size to
--    be used is.
-- @return stream function documented below. The intent is to call the stream
--    function multiple times for each chunk.
local stream = zlib.inflate(window_size)

-- @param input (string) is a byte array to decompress.
-- @return inflated (string) is the decompressed byte array.
-- @return eof (bool) indicates the zlib trailer was detected, and that all
--    bytes have been processed.
-- @return bytes_in (int) the total number of input bytes processed thus far.
-- @return bytes_out (int) the total number of output bytes processed thus far.
local inflated, eof, bytes_in, bytes_out = stream(input)
```

**Note:** The `stream()` function **must** not be called after `eof=true` is
returned, otherwise this function will fail with an error that begins with
IllegalState.

No flush options are provided since the maximal amount of
input is always processed.

### Inflating Concatenated Streams

If multiple gzip files are concatenated, you will need to properly handle the
`eof` and `bytes_in` returned values in order to avoid loosing data.

This can be done like this:

```lua
local source = io.open("allparts.gz")
local dest = io.tmpfile()

local inflate = lz.inflate()
local shift = 0
while true do
    local data = source:read(4096) -- read in 4K chunks
    if not data then break end     -- end if no more data
    local inflated, eos, bytes_in, bytes_out = inflate(data)
    dest:write(inflated)           -- write inflated data
    if eos then                    -- end of current stream
        source:seek("set", shift + bytes_in)
        shift = shift + bytes_in   -- update shift
        inflate = lz.inflate()     -- new inflate per stream
    end
end
```

In this example, the input file is `seek`ed backwards in order to preserve the
unprocessed bytes of the input `data`. However, another way to accomplish this
without requiring `seek`ing is to preserve the `bytes_in` between calls to
`inflate()`.

### Checksums

Due to the fact that zlib includes code to compute a checksum trailer, this
library also provides access to this functionality.

```lua
-- Function "factory" for a fresh adler32 checksum.
-- @return compute_checksum (function) described below
local compute_checksum = zlib.adler32()
-- Function "factory" for a fresh crc32 checksum.
-- @return compute_checksum (function) described below
local compute_checksum = zlib.crc32()

-- Updates the running checksum.
-- @param input (string or function) if this is a function, it **must**
--     be the result of `zlib.adler32()` or `zlib.crc32()`.
-- @return checksum (integer) of the input
local checksum = compute_checksum(input)
```

Here are some examples of using this API. These examples all compute the same
checksum:

```lua
-- All in one call:
local csum = zlib.crc32()("one two")

-- Multiple calls:
local compute = zlib.crc32()
compute("one")
assert(csum == compute(" two"))

-- Multiple compute_checksums joined:
local compute1, compute2 = zlib.crc32(), zlib.crc32()
compute1("one")
compute2(" two")
assert(csum == compute1(compute2))
```

### `lzlib` Compatibility API

To avoid linking two Lua zlib libraries, we have opted to provide "lzlib"
compatibility shims with this library which provide low-level APIs which are
not documented here. Note that there are a few incompatibilities you may need
to be aware of if trying to use this as a drop-in replacement for "lzlib":

* zlib.version() in lzlib returns a string, but this library returns a
   numeric tuple (see above documentation).

* zlib.{adler,crc}32() in lzlib returns the {adler,crc}32 initial value,
   however if this value is used with calls to adler32 it works in
   compatibility mode.

To use this shim add the `-DLZLIB_COMPAT` compiler flag.
