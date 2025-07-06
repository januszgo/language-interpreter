# Wykrywanie systemu
ifeq ($(OS),Windows_NT)
	IS_WINDOWS := 1
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		IS_LINUX := 1
	endif
endif

FLEX = flex -o build/lexer.c src/lexer.l
BISON = bison --defines=include/parser.tab.h -o build/parser.c src/parser.y
GCC = gcc -o interpreter build/lexer.c build/parser.c src/main.c -Iinclude -lm

.PHONY: all clean rerun

all:
ifeq ($(IS_WINDOWS),1)
	@if not exist build mkdir build
	@if not exist include mkdir include
	$(FLEX)
	$(BISON)
	$(GCC)
else
	@mkdir -p build
	@mkdir -p include
	$(FLEX)
	$(BISON)
	$(GCC)
endif

rerun:
ifeq ($(IS_WINDOWS),1)
	@if exist build rmdir /s /q build
	@if not exist build mkdir build
	@if exist include rmdir /s /q include
	@if not exist include mkdir include
	$(FLEX)
	$(BISON)
	$(GCC)
else
	@rm -rf build
	@mkdir -p build
	@rm -rf include
	@mkdir -p include
	$(FLEX)
	$(BISON)
	$(GCC)
endif

clean:
ifeq ($(IS_WINDOWS),1)
	@if exist build rmdir /s /q build
	@if exist include rmdir /s /q include
else
	@rm -rf build
	@rm -rf include
endif
