%{
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

%option noyywrap

%%

[ \t\r\n]+              /* pomijaj białe znaki i nowe linie */
"=="                   { return EQ; }
"!="                   { return NEQ; }
"<="                   { return LE; }
">="                   { return GE; }
"="                    { return '='; }
"<"                    { return '<'; }
">"                    { return '>'; }
"+"                    { return '+'; }
"-"                    { return '-'; }
"*"                    { return '*'; }
"/"                    { return '/'; }
"^"                    { return '^'; }
";"                    { return ';'; }
"("                    { return '('; }
")"                    { return ')'; }
"{"                    { return '{'; }
"}"                    { return '}'; }
"print"                { return PRINT; }
"if"                   { return IF; }
"else"                 { return ELSE; }
"for"                  { return FOR; }
"to"                   { return TO; }
"do"                   { return DO; }
"end"                  { return END; }
"sqrt"                 { return SQRT; }
"and"                  { return AND; }
"or"                   { return OR; }
"not"                  { return NOT; }
[0-9]+(\.[0-9]+)?      { yylval.num = atof(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID; }
.                      { /* ignoruj nieznane znaki */ }

%%