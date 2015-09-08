# Linux Makefile. Don't use this if you are not a developer or maintainer. 
# Install via LuaRocks instead.
#
# The original 2012 instruction hints are:
#
#  on Linux compile  with `cc -shared xtable.c -o xtable.so`
#
#  on Windows, define the symbols 'LUA_BUILD_AS_DLL' and 'LUA_LIB' and
#  compile and link with stub library lua52.lib (for lua52.dll)
#  generating xtable.dll. If necessary, generate lua52.lib and lua52.dll by 
#  compiling Lua sources with 'LUA_BUILD_AS_DLL' defined.

all: ../doc/xtable-manual.html ../doc/test-xtable.out ../doc/sample.html

LUA_5_1 = /usr/bin/lua5.1
LUA_5_2 = /usr/local/bin/lua5.2
LUA_5_3 = /usr/local/bin/lua5.3

INC_5_1 = /usr/include/lua5.1
INC_5_2 = /usr/local/include/lua5.2
INC_5_3 = /usr/local/include/lua5.3

LUA = $(LUA_5_3)
INC = $(INC_5_3)

CORE = ../lib/xtable_core.so
CFLAGS = -fPIC -I$(INC)

%.out: %.lua xtable.lua $(CORE)
	cp $(CORE) xtable_core.so
	$(LUA) $*.lua > $*.out
	rm xtable_core.so

../doc/xtable-manual.html: xtable-manual.txt
	pandoc xtable-manual.txt -o ../doc/xtable-manual.html

../doc/sample.html: xtable.lua
	ldoc -f markdown -o sample -d ../doc xtable.lua

../lib/xtable_core.so: xtable.c
	cc -std=c99 $(CFLAGS) -pedantic-errors -shared xtable.c -o $(CORE)

clean:
	rm $(CORE) 	
