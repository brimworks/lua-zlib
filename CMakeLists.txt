# Copyright (C) 2007-2009 LuaDist.
# Submitted by David Manura
# Redistribution and use of this file is allowed according to the
# terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own
# license.

cmake_minimum_required(VERSION 3.18)

project(lua-zlib LANGUAGES C)

option(USE_LUA "Use Lua (also called 'C' Lua) includes (default)" ON)
option(USE_LUAJIT "Use LuaJIT includes instead of 'C' Lua ones (recommended, if you're using LuaJIT, but disabled by default)" OFF)
set(USE_LUA_VERSION 5.1 CACHE STRING "Set the Lua version to use (default: 5.1)")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

if(USE_LUAJIT)
# Find luajit
        find_package(LuaJIT REQUIRED)
        set(USE_LUA OFF)
# / Find lua
endif()

if(USE_LUA)
# Find lua
        find_package(Lua ${USE_LUA_VERSION} EXACT REQUIRED)
# / Find lua
endif()


# Basic configurations
set(INSTALL_CMOD share/lua/cmod CACHE PATH "Directory to install Lua binary modules (configure lua via LUA_CPATH)")
# / configs

# Find zlib
find_package(ZLIB REQUIRED)
# / Find zlib

# Define how to build zlib.so:
add_library(cmod_zlib MODULE
        lua_zlib.c zlib.def)
set_target_properties(cmod_zlib PROPERTIES PREFIX "" OUTPUT_NAME zlib)
target_include_directories(cmod_zlib PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(cmod_zlib ZLIB::ZLIB)
# / build zlib.so

# Define how to test zlib.so:
include(CTest)
set(LUA_BIN "lua${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
find_program(LUA NAMES ${LUA_BIN} lua luajit lua.bat)
add_test(basic ${LUA} ${CMAKE_CURRENT_SOURCE_DIR}/test.lua ${CMAKE_CURRENT_SOURCE_DIR}/ ${CMAKE_CURRENT_BINARY_DIR}/)
set_tests_properties(basic
        PROPERTIES
        FAIL_REGULAR_EXPRESSION
        "not ok")
# / test zlib.so

# Where to install stuff
install(TARGETS cmod_zlib DESTINATION ${INSTALL_CMOD})
# / Where to install.

