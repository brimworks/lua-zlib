pwd := $(pwd)

include $(make-common.dir)/tool/cc.mk
include $(make-common.dir)/tool/lua.mk
include $(make-common.dir)/layout.mk

_lib  := $(lua.lib.dir)/zlib.so
_objs := $(call cc.c.to.o,$(addprefix $(pwd)/, \
    lua_zlib.c \
))

all: | $(_lib)
$(_lib): cc.libs += lua z
$(_lib): cc.objs := $(_objs)
$(_lib): $(_objs)
	$(cc.so.rule)

# How to run lua_zlib tests:
.PHONY: lua_zlib.test
test: | lua_zlib.test

lua ?= lua
lua_zlib.test: | $(lua.lib.dir)/zlib.so
lua_zlib.test: lua.path += $(pwd)
lua_zlib.test: $(wildcard $(pwd)/test*)
	@mkdir -p $(tmp.dir)
	cd $(tmp.dir); for t in $<; do \
		echo "TESTING: $$t"; \
		env -i $(lua.run) $(lua) $$t; \
	done
