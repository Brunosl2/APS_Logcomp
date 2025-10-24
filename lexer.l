%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;
%}

%option noyywrap

%%

"//".*                  { /* Comentário de linha */ }

"planta"                { return PLANTA; }
"quando"                { return QUANDO; }
"entao"                 { return ENTAO; }
"prioridade"            { return PRIORIDADE; }
"e"                     { return E; }
"entre"                 { return ENTRE; }

"regar"                 { return REGAR; }
"durante"               { return DURANTE; }
"segundos"              { return SEGUNDOS; }
"ajustar_luz"           { return AJUSTAR_LUZ; }
"para"                  { return PARA; }
"porcento"              { return PORCENTO; }
"aguardar"              { return AGUARDAR; }
"minutos"               { return MINUTOS; }
"alertar"               { return ALERTAR; }
"registrar"             { return REGISTRAR; }

"umidade"               { return UMIDADE; }
"temperatura"           { return TEMPERATURA; }
"luz_natural"           { return LUZ_NATURAL; }
"luz_total"             { return LUZ_TOTAL; }
"saude"                 { return SAUDE; }

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
[0-9]+\.[0-9]+          { yylval.fnum = atof(yytext); return FLOAT; }

\"[^\"]*\"              { yylval.str = strdup(yytext); return STRING; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return ID; }

"<"                     { return LT; }
">"                     { return GT; }
"<="                    { return LE; }
">="                    { return GE; }
"=="                    { return EQ; }
"!="                    { return NE; }

"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
":"                     { return COLON; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }

[ \t]+                  { /* Ignorar espaços e tabs */ }
\n                      { line_num++; }

.                       { 
                            fprintf(stderr, "Erro léxico na linha %d: '%s'\n", 
                                    line_num, yytext);
                        }

%%