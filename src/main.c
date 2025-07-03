#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

// Declare symbol table type
typedef struct Symbol {
    char *name;
    int value;
    struct Symbol *next;
} Symbol;

extern Symbol *symtab;

extern int yyparse();
extern FILE *yyin;

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error opening file");
            return 1;
        }
    }
    
    yyparse();
    
    // Clean up symbol table
    Symbol *current = symtab;
    while (current != NULL) {
        Symbol *next = current->next;
        free(current->name);
        free(current);
        current = next;
    }
    symtab = NULL;
    
    return 0;
}