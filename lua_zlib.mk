# How to build lua_zlib:
all: $(dir.LIB_LUA)/zlib.so

OBJS:=$(addprefix $(dir.TMP)/lua_zlib/, \
	lua_zlib.o \
)

$(dir.LIB_LUA)/zlib.so: OBJS:=$(OBJS)
$(dir.LIB_LUA)/zlib.so: $(OBJS)
	@mkdir -p $(dir $@)
	$(LIB_LINKER) -o $@ $(addprefix -L,$(LIBS)) -llua -lz $(OBJS)

ifneq ($(BUILD_LUA),)
  $(dir.LIB_LUA)/zlib.so: $(dir.LIB)/liblua.so
  $(OBJS): | lua.headers
endif
ifneq ($(BUILD_ZLIB),)
  $(dir.LIB_LUA)/zlib.so: $(dir.LIB)/libz.so
  $(OBJS): | zlib.headers
endif

# How to run lua_zlib tests:
test: | lua_zlib.test

LUA=lua $1
TESTS := $(wildcard $(ROOT)/lua_zlib/test*)
lua_zlib.test: TESTS := $(TESTS)
lua_zlib.test: $(dir.LIB_LUA)/zlib.so $(TESTS)
	cd $(ROOT)/lua_zlib; for f in $(TESTS); do \
		echo "TESTING: $$f"; \
		echo "run $$f" > $(dir.TMP)/backtrace.gdb; \
		echo "where"  >> $(dir.TMP)/backtrace.gdb; \
		env -i LUA_CPATH='$(dir.LIB_LUA)/?.so' DYLD_LIBRARY_PATH=$(subst $(SPACE),:,$(LIBS)) PATH=$(BINS):$$PATH $(call LUA,"$$f"); \
	done

backtrace: lua_zlib.test
backtrace: LUA=gdb -f -x $(dir.TMP)/backtrace.gdb -batch lua

.PHONY: lua_zlib.test backtrace
