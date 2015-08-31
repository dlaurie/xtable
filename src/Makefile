all: ../doc/xtable-manual.html ../doc/test-xtable.out ../doc/sample.html

LUA_5_2 = /usr/local/bin/lua5.2
LUA_5_3 = /usr/local/bin/lua5.3

INC_5_2 = /usr/local/include/lua5.2
INC_5_3 = /usr/local/include/lua5.3

LUA = $(LUA_5_3)
INC = $(INC_5_3)

CFLAGS = -fPIC -I$(INC)

%.out: %.lua xtable.lua xtable_core.so
	$(LUA) $*.lua > $*.out

../doc/xtable-manual.html: xtable-manual.txt
	pandoc xtable-manual.txt -o ../doc/xtable-manual.html

../doc/sample.html: xtable.lua
	ldoc.lua -f markdown -o sample -d ../doc xtable.lua

xtable_core.so: xtable.c
	cc -std=c99 $(CFLAGS) -pedantic-errors -shared xtable.c -o xtable_core.so

clean:
	rm xtable_core.so 	
