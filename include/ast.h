#ifndef AST_H
#define AST_H

#include <stdio.h>

// Typy węzłów AST dla wyrażeń
enum { AST_NUMBER, AST_VARIABLE, AST_BINARY, AST_UNARY };

// Typy węzłów AST dla instrukcji
enum { STMT_ASSIGN, STMT_PRINT, STMT_IF, STMT_FOR };

typedef struct AST {
    int type;      // typ węzła (AST_NUMBER, AST_VARIABLE, AST_BINARY, AST_UNARY)
    double value;  // wartość dla liczby
    char *var;     // nazwa zmiennej (dla AST_VARIABLE)
    char *op;      // operator (dla AST_BINARY i AST_UNARY)
    struct AST *left;
    struct AST *right;
} AST;

typedef struct Stmt {
    int type;             // typ instrukcji (STMT_ASSIGN, STMT_PRINT, STMT_IF, STMT_FOR)
    char *var;            // nazwa zmiennej (dla przypisania lub pętli for)
    AST *expr;            // wyrażenie (dla przypisania, print, warunku if, początek for)
    AST *expr2;           // drugie wyrażenie (koniec zakresu pętli for)
    struct Stmt *then_branch;  // instrukcje if (gałąź true)
    struct Stmt *else_branch;  // instrukcje if (gałąź false)
    struct Stmt *body;    // ciało pętli for
    struct Stmt *next;    // następna instrukcja w sekwencji
} Stmt;

extern Stmt *root;  // wskaźnik na początek listy instrukcji (program)

// Funkcje tworzące węzły AST
Stmt *append_stmt(Stmt *list, Stmt *s);
Stmt *make_assign(char *var, AST *expr);
Stmt *make_print(AST *expr);
Stmt *make_if(AST *cond, Stmt *then_branch, Stmt *else_branch);
Stmt *make_for(char *var, AST *start_expr, AST *end_expr, Stmt *body);

AST *make_number(double value);
AST *make_variable(char *var);
AST *make_binary_op(const char *op, AST *left, AST *right);
AST *make_unary_op(const char *op, AST *expr);

// Funkcje ewaluujące AST
double eval_expr(AST *expr);
void eval(Stmt *stmt_list);

#endif
