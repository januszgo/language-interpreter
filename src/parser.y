%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
extern int yylex();
extern int yyerror(const char* s);
Stmt *root;
%}

%code requires {
  #include "ast.h"
}

%union {
    double num;
    char *id;
    AST *ast;
    Stmt *stmt;
}

%token <num> NUMBER
%token <id> ID
%token PRINT IF ELSE FOR TO DO END SQRT AND OR NOT NEG
%token EQ NEQ LE GE
%left OR
%left AND
%right NOT
%nonassoc '<' '>' EQ NEQ LE GE
%left '+' '-'
%left '*' '/'
%right '^'
%right NEG

%type <stmt> stmt stmt_list block
%type <ast> expr

%%

program:
    stmt_list         { root = $1; }
;

stmt_list:
    /* empty */       { $$ = NULL; }
  | stmt_list stmt    { $$ = append_stmt($1, $2); }
;

stmt:
    ID '=' expr ';'               { $$ = make_assign($1, $3); }
  | PRINT expr ';'               { $$ = make_print($2); }
  | IF expr block ELSE block ';' { $$ = make_if($2, $3, $5); }
  | IF expr block ';'            { $$ = make_if($2, $3, NULL); }
  | FOR ID '=' expr TO expr DO block END ';'
                                  { $$ = make_for($2, $4, $6, $8); }
;

block:
    '{' stmt_list '}'  { $$ = $2; }
;

expr:
    expr OR expr   { $$ = make_binary_op("or", $1, $3); }
  | expr AND expr  { $$ = make_binary_op("and", $1, $3); }
  | NOT expr       { $$ = make_unary_op("not", $2); }
  | expr '<' expr  { $$ = make_binary_op("<", $1, $3); }
  | expr '>' expr  { $$ = make_binary_op(">", $1, $3); }
  | expr EQ expr   { $$ = make_binary_op("==", $1, $3); }
  | expr NEQ expr  { $$ = make_binary_op("!=", $1, $3); }
  | expr LE expr   { $$ = make_binary_op("<=", $1, $3); }
  | expr GE expr   { $$ = make_binary_op(">=", $1, $3); }
  | expr '+' expr  { $$ = make_binary_op("+", $1, $3); }
  | expr '-' expr  { $$ = make_binary_op("-", $1, $3); }
  | expr '*' expr  { $$ = make_binary_op("*", $1, $3); }
  | expr '/' expr  { $$ = make_binary_op("/", $1, $3); }
  | expr '^' expr  { $$ = make_binary_op("^", $1, $3); }
  | '-' expr %prec NEG { $$ = make_unary_op("-", $2); }
  | '(' expr ')'   { $$ = $2; }
  | NUMBER         { $$ = make_number($1); }
  | ID             { $$ = make_variable($1); }
  | SQRT '(' expr ')' { $$ = make_unary_op("sqrt", $3); }
;

%%

int yyerror(const char *s) {
    fprintf(stderr, "Błąd składniowy: %s\n", s);
    return 0;
}
