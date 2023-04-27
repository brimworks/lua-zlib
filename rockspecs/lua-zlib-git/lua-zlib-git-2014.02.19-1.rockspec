package="lua-zlib-git"
version="2014.02.19-1"
source = {
   url = "https://github.com/brimworks/lua-zlib/archive/f976cfbfc872dc670ecc18b448dfd7ecd6a03765.tar.gz",
   dir = "lua-zlib-f976cfbfc872dc670ecc18b448dfd7ecd6a03765",
}
description = {
   summary = "Simple streaming interface to zlib for Lua.",
   detailed = [[
      This package provides a streaming interface to zlib.
   ]],
   homepage = "https://github.com/brimworks/lua-zlib",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1, < 5.3"
}
external_dependencies = {
   ZLIB = {
      header = "zlib.h",
      library = "z",
   }
}
build = {
   type = "builtin",
   modules = {
      zlib = {
         sources = "lua_zlib.c",
         libdirs = "$(ZLIB_LIBDIR)",
         incdirs = "$(ZLIB_INCDIR)",
         libraries = "z",
      },
   }
}
