all: ../doc/xtable-manual.html ../doc/test-xtable.out ../doc/sample.html

CFLAGS = -fPIC

%.out: %.lua xtable.lua xtable_core.so
	lua $*.lua > $*.out

../doc/xtable-manual.html: xtable-manual.txt
	pandoc xtable-manual.txt -o ../doc/xtable-manual.html

../doc/sample.html: xtable.lua
	ldoc.lua -f markdown -o sample -d ../doc xtable.lua

xtable_core.so: xtable.c
	cc $(CFLAGS) -pedantic-errors -shared xtable.c -o xtable_core.so

