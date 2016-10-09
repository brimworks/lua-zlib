# Usage

## Requirements

To use this library, you need zlib, get it [here](http://www.gzip.org/zlib/) or from distribution packages.


## Installation

### From package

- debian/ubuntu: `lua-zlib`

### With luarocks/moonrock

```shell
luarocks install --server=http://rocks.moonscript.org lua-zlib
```
or
```shell
moonrocks install lua-zlib
```

# Documentation

Loading the library:

If you built the library as a loadable package

```lua
[local] zlib = require 'zlib'
```

If you compiled the package statically into your application, call
the function `luaopen_zlib(L)`. It will create a table with the zlib
functions and leave it on the stack.

```lua
-- zlib functions --

int major, int minor, int patch = zlib.version()
```

returns numeric zlib version for the major, minor, and patch
levels of the version dynamically linked in.

```lua
function stream = zlib.deflate([ int compression_level ], [ int window_size ])
```

If no `compression_level` is provided uses `Z_DEFAULT_COMPRESSION (6)`,
compression level is a number from 1-9 where `zlib.BEST_SPEED` is 1
and `zlib.BEST_COMPRESSION` is 9.

Returns a "stream" function that compresses (or deflates) all
strings passed in.  Specifically, use it as such:

```lua
string deflated, bool eof, int bytes_in, int bytes_out =
  stream(string input [, 'sync' | 'full' | 'finish'])
```

Takes input and deflates and returns a portion of it,
optionally forcing a flush.

A 'sync' flush will force all pending output to be flushed to
the return value and the output is aligned on a byte boundary,
so that the decompressor can get all input data available so
far.  Flushing may degrade compression for some compression
algorithms and so it should be used only when necessary.

A 'full' flush will flush all output as with 'sync', and the
compression state is reset so that decompression can restart
from this point if previous compressed data has been damaged
or if random access is desired. Using `Z_FULL_FLUSH` too often
can seriously degrade the compression.

A 'finish' flush will force all pending output to be processed
and results in the stream become unusable.  Any future
attempts to print anything other than the empty string will
result in an error that begins with `IllegalState`.

The eof result is true if 'finish' was specified, otherwise
it is false.

The `bytes_in` is how many bytes of input have been passed to
stream, and `bytes_out` is the number of bytes returned in
deflated string chunks.

```lua
function stream = zlib.inflate([int windowBits])
```

Returns a "stream" function that decompresses (or inflates) all
strings passed in.  Optionally specify a windowBits argument
that is passed to `inflateInit2()`, see `zlib.h` for details about
this argument.  By default, gzip header detection is done, and
the max window size is used.

The "stream" function should be used as such:

```lua
string inflated, bool eof, int bytes_in, int bytes_out = stream(string input)
```

Takes input and inflates and returns a portion of it.  If it
detects the end of a deflation stream, then total will be the
total number of bytes read from input and all future calls to
stream() with a non empty string will result in an error that
begins with IllegalState.

No flush options are provided since the maximal amount of
input is always processed.

eof will be true when the input string is determined to be at
the "end of the file".

The `bytes_in` is how many bytes of input have been passed to
stream, and `bytes_out` is the number of bytes returned in
inflated string chunks.

```lua
function compute_checksum = zlib.adler32()
function compute_checksum = zlib.crc32()
```

Create a new checksum computation function using either the
adler32 or crc32 algorithms.  This resulting function should be
used as such:

```lua
int checksum = compute_checksum(string input | function compute_checksum)
```

The `compute_checksum` function takes as input either a string
that is logically getting appended to or another
`compute_checksum` function that is logically getting appended.
The result is the updated checksum.

For example, these uses will all result in the same checksum:

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
