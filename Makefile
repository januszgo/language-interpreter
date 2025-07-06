# Wykrywanie systemu
ifeq ($(OS),Windows_NT)
	IS_WINDOWS := 1
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		IS_LINUX := 1
	endif
endif

.PHONY: all clean

all:
ifeq ($(IS_WINDOWS),1)
	@if not exist build mkdir build
	@flex -o build/lexer.c src/lexer.l
	@bison --defines=build/parser.tab.h -o build/parser.c src/parser.y
	@gcc -o interpreter build/lexer.c build/parser.c src/main.c -Ibuild -lm
else
	@mkdir -p build
endif

clean:
ifeq ($(IS_WINDOWS),1)
	@if exist build rmdir /s /q build
else
	@rm -rf build
endif
