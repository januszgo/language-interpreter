%{
#include "parser.tab.h"
#include <stdlib.h>
#include <math.h>
%}

%option noyywrap

%%

[ \t\n]         ; /* Skip whitespace */
"print"         { return PRINT; }
"if"            { return IF; }
"else"          { return ELSE; }
"for"           { return FOR; }
"to"            { return TO; }
"do"            { return DO; }
"end"           { return END; }
"and"           { return AND; }
"or"            { return OR; }
"not"           { return NOT; }
"sqrt"          { return SQRT; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return ID; }
[0-9]+          { yylval.num = atoi(yytext); return INT; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"^"             { return '^'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
"<"             { return '<'; }
">"             { return '>'; }
"=="            { return EQ; }
"!="            { return NE; }
"<="            { return LE; }
">="            { return GE; }
"="             { return '='; }
";"             { return ';'; }
.               { fprintf(stderr, "Invalid character: %c\n", *yytext); }

%%