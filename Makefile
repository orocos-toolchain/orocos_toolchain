.PHONY: all install
all: build/CMakeCache.txt
	$(MAKE) -C build $@

build/CMakeCache.txt: configure

configure:
	./configure
.PHONY: configure

install: all
.PHONY: install

.DEFAULT: build/CMakeCache.txt
	$(MAKE) -C build $@

