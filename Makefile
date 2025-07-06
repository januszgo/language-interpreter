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
BISON = bison --defines=build/parser.tab.h -o build/parser.c src/parser.y
GCC = gcc -o interpreter build/lexer.c build/parser.c src/main.c -Ibuild -lm

.PHONY: all clean

all:
ifeq ($(IS_WINDOWS),1)
	@if not exist build mkdir build
	$(FLEX)
	$(BISON)
	$(GCC)
else
	@mkdir -p build
	$(FLEX)
	$(BISON)
	$(GCC)
endif

clean:
ifeq ($(IS_WINDOWS),1)
	@if exist build rmdir /s /q build
else
	@rm -rf build
endif
