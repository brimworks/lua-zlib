package = "lua-zlib"
version = "scm-0"
source = {
   url = "git+https://github.com/brimworks/lua-zlib.git",
   branch = "master",
}
description = {
   summary = "Simple streaming interface to zlib for Lua.",
   detailed = [[
      Simple streaming interface to zlib for Lua.
      Consists of two functions: inflate and deflate.
      Both functions return "stream functions" (takes a buffer of input and returns a buffer of output).
      This project is hosted on github.
   ]],
   homepage = "https://github.com/brimworks/lua-zlib",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, <= 5.4"
}
external_dependencies = {
    ZLIB = {
       header = "zlib.h"
    }
}

build = {
   type = "builtin",
   modules = {
      zlib = {
         sources = { "lua_zlib.c" },
         libraries = { "z" },
         defines = { "LZLIB_COMPAT" },
         incdirs = { "$(ZLIB_INCDIR)" },
         libdirs = { "$(ZLIB_LIBDIR)" }
      }
   },
   platforms = {
      windows = {
         modules = {
            zlib = {
               libraries = { "zlib" }
            }
         }
      },
      mingw = {
         modules = {
            zlib = {
               libraries = { "zlib1" },
               libdirs = { "$(ZLIB_INCDIR)/../bin" }
            }
         }
      }
   }
}
