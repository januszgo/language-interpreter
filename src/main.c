#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern int yyparse();
extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("fopen");
            return 1;
        }
    } else {
        yyin = fopen("input.txt", "r");
        if (!yyin) {
            fprintf(stderr, "Nie można otworzyć pliku input.txt\n");
            return 1;
        }
    }
    if (yyparse() == 0) {
        eval(root);
    }
    return 0;
}
