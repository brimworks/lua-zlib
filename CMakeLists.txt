# Copyright (C) 2007-2009 LuaDist.
# Submitted by David Manura
# Redistribution and use of this file is allowed according to the
# terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own
# license.

PROJECT(lua-zlib C)
CMAKE_MINIMUM_REQUIRED (VERSION 2.6)

# Basic configurations
  SET(INSTALL_CMOD share/lua/cmod CACHE PATH "Directory to install Lua binary modules (configure lua via LUA_CPATH)")
# / configs

# Find zlib
  FIND_PACKAGE(ZLIB REQUIRED)
# / Find zlib

# Find lua
  FIND_PACKAGE(Lua51 REQUIRED)
# / Find lua

# Define how to build zlib.so:
  INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIRS} ${LUA_INCLUDE_DIR})
  ADD_LIBRARY(cmod_zlib MODULE
    lua_zlib.c zlib.def)
  SET_TARGET_PROPERTIES(cmod_zlib PROPERTIES PREFIX "")
  SET_TARGET_PROPERTIES(cmod_zlib PROPERTIES OUTPUT_NAME zlib)
  TARGET_LINK_LIBRARIES(cmod_zlib ${LUA_LIBRARIES} ${ZLIB_LIBRARIES})  
# / build zlib.so

# Define how to test zlib.so:
  INCLUDE(CTest)
  FIND_PROGRAM(LUA NAMES lua lua.bat)
  ADD_TEST(basic ${LUA} ${CMAKE_CURRENT_SOURCE_DIR}/test.lua ${CMAKE_CURRENT_SOURCE_DIR}/ ${CMAKE_CURRENT_BINARY_DIR}/)
  SET_TESTS_PROPERTIES(basic
                       PROPERTIES
                       FAIL_REGULAR_EXPRESSION
                       "not ok")
# / test zlib.so

# Where to install stuff
  INSTALL (TARGETS cmod_zlib DESTINATION ${INSTALL_CMOD})
# / Where to install.
