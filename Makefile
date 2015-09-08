# Linux Makefile. Don't use this if you are not a developer or maintainer. 
# Install via LuaRocks instead.

VERSION = 1.0.3

all: src/xtable.lua src/xtable-manual.txt src/xtable.c
	make -C src

INSTALL: src/xtable.c src/INSTALL.in
	cp src/INSTALL.in INSTALL
	echo "Version "$(VERSION) >> INSTALL
	date >> INSTALL

package: Makefile all INSTALL
	zip -ur zip/xtable-$(VERSION).zip INSTALL $(COMP) doc src -x\*/\.*


