#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "ast.h"

// Struktura symboli (zmiennych)
typedef struct Var {
    char *name;
    double value;
    struct Var *next;
} Var;

static Var *var_list = NULL;

double get_var_value(const char *name) {
    for (Var *v = var_list; v != NULL; v = v->next) {
        if (strcmp(v->name, name) == 0) {
            return v->value;
        }
    }
    // jeżeli nie znaleziono, domyślnie 0
    return 0.0;
}

void set_var_value(const char *name, double value) {
    for (Var *v = var_list; v != NULL; v = v->next) {
        if (strcmp(v->name, name) == 0) {
            v->value = value;
            return;
        }
    }
    // dodaj nową zmienną
    Var *v = (Var*)malloc(sizeof(Var));
    v->name = strdup(name);
    v->value = value;
    v->next = var_list;
    var_list = v;
}

// Dodaj instrukcję do listy
Stmt *append_stmt(Stmt *list, Stmt *s) {
    if (!list) return s;
    Stmt *p = list;
    while (p->next) p = p->next;
    p->next = s;
    return list;
}

// Utwórz instrukcję przypisania
Stmt *make_assign(char *var, AST *expr) {
    Stmt *s = (Stmt*)malloc(sizeof(Stmt));
    s->type = STMT_ASSIGN;
    s->var = strdup(var);
    s->expr = expr;
    s->expr2 = NULL;
    s->then_branch = NULL;
    s->else_branch = NULL;
    s->body = NULL;
    s->next = NULL;
    return s;
}

// Utwórz instrukcję print
Stmt *make_print(AST *expr) {
    Stmt *s = (Stmt*)malloc(sizeof(Stmt));
    s->type = STMT_PRINT;
    s->var = NULL;
    s->expr = expr;
    s->expr2 = NULL;
    s->then_branch = NULL;
    s->else_branch = NULL;
    s->body = NULL;
    s->next = NULL;
    return s;
}

// Utwórz instrukcję if-else
Stmt *make_if(AST *cond, Stmt *then_branch, Stmt *else_branch) {
    Stmt *s = (Stmt*)malloc(sizeof(Stmt));
    s->type = STMT_IF;
    s->var = NULL;
    s->expr = cond;
    s->expr2 = NULL;
    s->then_branch = then_branch;
    s->else_branch = else_branch;
    s->body = NULL;
    s->next = NULL;
    return s;
}

// Utwórz pętlę for
Stmt *make_for(char *var, AST *start_expr, AST *end_expr, Stmt *body) {
    Stmt *s = (Stmt*)malloc(sizeof(Stmt));
    s->type = STMT_FOR;
    s->var = strdup(var);
    s->expr = start_expr;
    s->expr2 = end_expr;
    s->then_branch = NULL;
    s->else_branch = NULL;
    s->body = body;
    s->next = NULL;
    return s;
}

// Utwórz węzeł liczby
AST *make_number(double value) {
    AST *a = (AST*)malloc(sizeof(AST));
    a->type = AST_NUMBER;
    a->value = value;
    a->var = NULL;
    a->op = NULL;
    a->left = NULL;
    a->right = NULL;
    return a;
}

// Utwórz węzeł zmiennej
AST *make_variable(char *var) {
    AST *a = (AST*)malloc(sizeof(AST));
    a->type = AST_VARIABLE;
    a->value = 0;
    a->var = strdup(var);
    a->op = NULL;
    a->left = NULL;
    a->right = NULL;
    return a;
}

// Utwórz węzeł operacji binarnej
AST *make_binary_op(const char *op, AST *left, AST *right) {
    AST *a = (AST*)malloc(sizeof(AST));
    a->type = AST_BINARY;
    a->value = 0;
    a->var = NULL;
    a->op = strdup(op);
    a->left = left;
    a->right = right;
    return a;
}

// Utwórz węzeł operacji unarnej
AST *make_unary_op(const char *op, AST *expr) {
    AST *a = (AST*)malloc(sizeof(AST));
    a->type = AST_UNARY;
    a->value = 0;
    a->var = NULL;
    a->op = strdup(op);
    a->left = expr;
    a->right = NULL;
    return a;
}

// Ewaluuj wyrażenie AST
double eval_expr(AST *expr) {
    if (!expr) return 0.0;
    switch (expr->type) {
        case AST_NUMBER:
            return expr->value;
        case AST_VARIABLE:
            return get_var_value(expr->var);
        case AST_BINARY: {
            double left = eval_expr(expr->left);
            double right = eval_expr(expr->right);
            if (strcmp(expr->op, "+") == 0) return left + right;
            if (strcmp(expr->op, "-") == 0) return left - right;
            if (strcmp(expr->op, "*") == 0) return left * right;
            if (strcmp(expr->op, "/") == 0) return left / right;
            if (strcmp(expr->op, "^") == 0) return pow(left, right);
            if (strcmp(expr->op, "<") == 0) return left < right ? 1.0 : 0.0;
            if (strcmp(expr->op, ">") == 0) return left > right ? 1.0 : 0.0;
            if (strcmp(expr->op, "<=") == 0) return left <= right ? 1.0 : 0.0;
            if (strcmp(expr->op, ">=") == 0) return left >= right ? 1.0 : 0.0;
            if (strcmp(expr->op, "==") == 0) return left == right ? 1.0 : 0.0;
            if (strcmp(expr->op, "!=") == 0) return left != right ? 1.0 : 0.0;
            if (strcmp(expr->op, "and") == 0) return (left != 0.0 && right != 0.0) ? 1.0 : 0.0;
            if (strcmp(expr->op, "or") == 0) return (left != 0.0 || right != 0.0) ? 1.0 : 0.0;
            return 0.0;
        }
        case AST_UNARY: {
            double val = eval_expr(expr->left);
            if (strcmp(expr->op, "-") == 0) return -val;
            if (strcmp(expr->op, "not") == 0) return (val == 0.0) ? 1.0 : 0.0;
            if (strcmp(expr->op, "sqrt") == 0) return sqrt(val);
            return 0.0;
        }
        default:
            return 0.0;
    }
}

// Wykonaj listę instrukcji
void eval(Stmt *stmt_list) {
    for (Stmt *s = stmt_list; s != NULL; s = s->next) {
        if (s->type == STMT_ASSIGN) {
            double v = eval_expr(s->expr);
            set_var_value(s->var, v);
        } else if (s->type == STMT_PRINT) {
            double v = eval_expr(s->expr);
            printf("%g\n", v);
        } else if (s->type == STMT_IF) {
            double cond = eval_expr(s->expr);
            if (cond != 0.0) {
                eval(s->then_branch);
            } else if (s->else_branch) {
                eval(s->else_branch);
            }
        } else if (s->type == STMT_FOR) {
            double start_val = eval_expr(s->expr);
            double end_val = eval_expr(s->expr2);
            int start = (int)start_val;
            int end = (int)end_val;
            for (int i = start; i <= end; i++) {
                set_var_value(s->var, (double)i);
                eval(s->body);
            }
        }
    }
}
