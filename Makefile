# This Makefile is based on LuaSec's Makefile. Thanks to the LuaSec developers.
# Inform the location to intall the modules

uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')

LUA_DIR      ?= /usr/local
LUA_LIBDIR    = $(LUA_DIR)/lib/lua/5.1
LUA_SHAREDIR  = $(LUA_DIR)/share/lua/5.1

INCDIR ?= -I/usr/include/lua5.1
LIBDIR ?= -L/usr/local/lib

# For Mac OS X: set the system version
MACOSX_VERSION = 10.4

CMOD = zlib.so
OBJS = lua_zlib.o

LIBS ?= -lz -llua -lm
WARN ?= -Wall -pedantic

ifeq ($(uname_S),Darwin)
	OS_CFLAGS  = -O2 -fPIC -fno-common $(WARN)
	OS_LDFLAGS = -bundle -undefined dynamic_lookup -fPIC $(LIBDIR)
	OS_ENV = env MACOSX_DEPLOYMENT_TARGET='$(MACVER)'
endif
ifeq ($(uname_S),$(filter $(uname_S),Linux FreeBSD GNU/kFreeBSD OpenBSD NetBSD))
	OS_CFLAGS  = -O2 -fPIC $(WARN)
	OS_LDFLAGS = -shared -fPIC $(LIBDIR)
	OS_ENV =
endif

CFLAGS  ?= $(OS_CFLAGS)
LDFLAGS ?= $(OS_LDFLAGS)
ENV     ?= $(OS_ENV)

.PHONY: clean install uninstall

$(CMOD): $(OBJS)
	$(CC) $(LDFLAGS) -o $(CMOD) $(LIBDIR) $(OBJS)

$(OBJS):
	$(CC) $(CFLAGS) $(INCDIR) -c lua_zlib.c -o $(OBJS)

install: $(CMOD)
	mkdir -p $(LUA_LIBDIR)
	cp $(CMOD) $(LUA_LIBDIR)

uninstall:
	rm $(LUA_LIBDIR)/$(CMOD)

clean:
	rm -f $(OBJS) $(CMOD)
