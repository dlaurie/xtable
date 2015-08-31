VERSION = 1.0.2

all: src/xtable.lua src/xtable-manual.txt src/xtable.c
	make -C src

INSTALL: src/xtable.c
	head -n 18 src/xtable.c > INSTALL
	echo "Version "$(VERSION) >> INSTALL
	date >> INSTALL

package: Makefile all INSTALL
	zip -ur zip/xtable-$(VERSION).zip INSTALL $(COMP) doc src -x\*/\.*


