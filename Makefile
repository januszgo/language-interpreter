# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -g -Ibuild
LIBS = -lm

# Bison and Flex settings
BISON = bison
FLEX = flex

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source files
LEXER_SRC = $(SRC_DIR)/lexer.l
PARSER_SRC = $(SRC_DIR)/parser.y
MAIN_SRC = $(SRC_DIR)/main.c

# Generated files
LEXER_GEN = $(BUILD_DIR)/lex.yy.c
PARSER_GEN = $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h
OBJS = $(BUILD_DIR)/lex.yy.o $(BUILD_DIR)/parser.tab.o $(BUILD_DIR)/main.o

# Executable
TARGET = interpreter

.PHONY: all clean

all: $(BUILD_DIR) $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

$(LEXER_GEN): $(LEXER_SRC) $(BUILD_DIR)/parser.tab.h
	$(FLEX) -o $@ $<

$(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h: $(PARSER_SRC) | $(BUILD_DIR)
	$(BISON) -d -o $(BUILD_DIR)/parser.tab.c $<

$(BUILD_DIR)/main.o: $(MAIN_SRC) $(BUILD_DIR)/parser.tab.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/lex.yy.o: $(LEXER_GEN) $(BUILD_DIR)/parser.tab.h
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/parser.tab.o: $(BUILD_DIR)/parser.tab.c $(BUILD_DIR)/parser.tab.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) $(OBJS) $(LEXER_GEN) $(PARSER_GEN)
	rmdir $(BUILD_DIR) 2>/dev/null || true