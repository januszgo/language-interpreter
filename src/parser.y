%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Symbol table structure */
typedef struct Symbol {
    char *name;
    int value;
    struct Symbol *next;
} Symbol;

Symbol *symtab = NULL;

/* Helper functions */
Symbol *lookup(char *name) {
    Symbol *s;
    for (s = symtab; s != NULL; s = s->next)
        if (strcmp(s->name, name) == 0)
            return s;
    return NULL;
}

void install(char *name, int value) {
    Symbol *s = lookup(name);
    if (s) {
        s->value = value;
    } else {
        s = (Symbol *)malloc(sizeof(Symbol));
        s->name = strdup(name);
        s->value = value;
        s->next = symtab;
        symtab = s;
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

extern int yylex();

/* Execution control */
int executing = 1;  // Global execution flag

%}

%union {
    int num;
    char *str;
}

/* Tokens */
%token PRINT IF ELSE FOR TO DO END AND OR NOT SQRT
%token <num> INT
%token <str> ID
%token EQ NE LE GE

/* Precedence */
%left OR
%left AND
%right NOT
%nonassoc '<' '>' EQ NE LE GE
%left '+' '-'
%left '*' '/'
%right '^'
%right UMINUS
%right SQRT

/* Expression types */
%type <num> expr bool_expr arith_expr term factor
%type <num> stmt stmt_list program

%%

program:
    stmt_list
;

stmt_list:
    stmt
    | stmt_list stmt
;

stmt:
    PRINT expr ';' { 
        if (executing) printf("%d\n", $2); 
        $$ = 0; 
    }
    | ID '=' expr ';' { 
        if (executing) install($1, $3); 
        $$ = 0; 
    }
    | IF bool_expr '{' stmt_list '}' {
        int condition = $2;
        int saved_executing = executing;
        
        if (!condition) {
            executing = 0;  // Skip if-block if condition false
        }
        // Parse if-block
        $$ = $4;
        executing = saved_executing;
    }
    | IF bool_expr '{' stmt_list '}' ELSE '{' stmt_list '}' {
        int condition = $2;
        int saved_executing = executing;
        
        // Execute if-block if condition true
        if (condition) {
            executing = 1;
            // Parse if-block
            $$ = $4;
            // Skip else-block
            executing = 0;
            // Parse else-block without executing
            $8;
        } 
        // Execute else-block if condition false
        else {
            // Skip if-block
            executing = 0;
            // Parse if-block without executing
            $4;
            // Execute else-block
            executing = 1;
            $$ = $8;
        }
        executing = saved_executing;
    }
    | FOR ID '=' expr TO expr DO '{' stmt_list '}' END {
        if (executing) {
            int start = $4;
            int end = $6;
            char *varname = $2;
            int i;
            
            for (i = start; i <= end; i++) {
                install(varname, i);
                // Execute loop body
                $9;
            }
        }
        free($2);  // Free loop variable name
        $$ = 0;
    }
;

expr:
    bool_expr { $$ = $1; }
    | arith_expr { $$ = $1; }
;

bool_expr:
    bool_expr OR bool_expr { $$ = $1 || $3; }
    | bool_expr AND bool_expr { $$ = $1 && $3; }
    | NOT bool_expr { $$ = !$2; }
    | arith_expr '<' arith_expr { $$ = $1 < $3; }
    | arith_expr '>' arith_expr { $$ = $1 > $3; }
    | arith_expr EQ arith_expr { $$ = $1 == $3; }
    | arith_expr NE arith_expr { $$ = $1 != $3; }
    | arith_expr LE arith_expr { $$ = $1 <= $3; }
    | arith_expr GE arith_expr { $$ = $1 >= $3; }
    | '(' bool_expr ')' { $$ = $2; }
;

arith_expr:
    arith_expr '+' term { $$ = $1 + $3; }
    | arith_expr '-' term { $$ = $1 - $3; }
    | term { $$ = $1; }
;

term:
    term '*' factor { $$ = $1 * $3; }
    | term '/' factor { 
        if ($3 == 0) {
            yyerror("Division by zero");
            exit(1);
        }
        $$ = $1 / $3; 
      }
    | factor { $$ = $1; }
;

factor:
    INT { $$ = $1; }
    | ID { 
        if (!executing) { 
            $$ = 0;
        } else {
            char *name = $1;
            Symbol *s = lookup(name); 
            if (!s) {
                fprintf(stderr, "Undefined variable: %s\n", name);
                exit(1);
            }
            $$ = s->value;
        }
        free($1);  // Free the ID string
      }
    | '(' arith_expr ')' { $$ = $2; }
    | '-' factor %prec UMINUS { $$ = -$2; }
    | factor '^' factor { 
        if ($3 < 0) {
            yyerror("Negative exponent");
            exit(1);
        }
        int result = 1;
        int i;
        for(i = 0; i < $3; i++) result *= $1;
        $$ = result;
      }
    | SQRT '(' arith_expr ')' { 
        if ($3 < 0) {
            yyerror("Square root of negative number");
            exit(1);
        }
        $$ = (int)sqrt($3); 
      }
;

%%