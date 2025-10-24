%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int line_num;
extern FILE *yyin;

void yyerror(const char *s);

int rule_count = 0;
int plant_count = 0;
%}

%union {
    int num;
    double fnum;
    char *str;
}

%token PLANTA QUANDO ENTAO PRIORIDADE E ENTRE
%token REGAR DURANTE SEGUNDOS AJUSTAR_LUZ PARA PORCENTO
%token AGUARDAR MINUTOS ALERTAR REGISTRAR
%token UMIDADE TEMPERATURA LUZ_NATURAL LUZ_TOTAL SAUDE
%token LBRACE RBRACE COLON SEMICOLON COMMA
%token LT GT LE GE EQ NE

%token <num> NUMBER
%token <fnum> FLOAT
%token <str> STRING ID

%type <num> numero

%%

programa:
    /* vazio */
    | programa definicao
    | programa regra
    ;

definicao:
    PLANTA ID LBRACE propriedades RBRACE
    {
        plant_count++;
        printf("✓ Planta '%s' definida\n", $2);
        free($2);
    }
    ;

propriedades:
    /* vazio */
    | propriedades propriedade
    ;

propriedade:
    ID COLON numero SEMICOLON
    {
        printf("  - %s: %d\n", $1, $3);
        free($1);
    }
    ;

regra:
    QUANDO condicoes ENTAO acoes PRIORIDADE numero SEMICOLON
    {
        rule_count++;
        printf("✓ Regra #%d (prioridade %d) processada\n", rule_count, $6);
    }
    ;

condicoes:
    condicao
    | condicoes E condicao
    ;

condicao:
    sensor operador numero
    | sensor ENTRE numero E numero
    ;

sensor:
    UMIDADE
    | TEMPERATURA
    | LUZ_NATURAL
    | LUZ_TOTAL
    | SAUDE
    ;

operador:
    LT | GT | EQ | LE | GE | NE
    ;

acoes:
    acao
    | acoes COMMA acao
    ;

acao:
    REGAR DURANTE numero SEGUNDOS
    | AJUSTAR_LUZ PARA numero PORCENTO
    | AGUARDAR numero MINUTOS
    | ALERTAR STRING { free($2); }
    | REGISTRAR STRING { free($2); }
    ;

numero:
    NUMBER { $$ = $1; }
    | FLOAT { $$ = (int)$1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d: %s\n", line_num, s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "Erro: não foi possível abrir '%s'\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    printf("=== PlantLang Compiler ===\n\n");
    
    int result = yyparse();
    
    if (result == 0) {
        printf("\n=== Análise Concluída ===\n");
        printf("Plantas definidas: %d\n", plant_count);
        printf("Regras processadas: %d\n", rule_count);
    }
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return result;
}