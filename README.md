# PlantLang

Uma linguagem declarativa baseada em regras para automação de cuidados com plantas, compilando para PlantVM assembly.

##  Arquitetura PlantVM

### Registradores Graváveis
- **`WATER`**: Timer/contador de água (segundos)
- **`LIGHT`**: Intensidade da luz artificial (0-100%)

### Registradores Somente Leitura (Sensores)
- **`MOISTURE`**: Umidade do solo (0-100%)
- **`TEMP`**: Temperatura ambiente (°C)
- **`HUMIDITY`**: Umidade do ar (0-100%)
- **`LIGHTLV`**: Nível de luz natural (0-100%)
- **`HEALTH`**: Índice de saúde da planta (0-100%)

### Modelo de Memória
- Pilha para armazenamento temporário
- Contador de programa (PC)
- Fluxo de controle baseado em labels

### Modelo de Execução
- Execução sequencial de instruções
- Ramificação condicional baseada em zero-testing
- Transições de estado determinísticas
- Simulação de crescimento: HEALTH atualizado baseado em MOISTURE, TEMP e LUZ_TOTAL

## 📝 Conjunto de Instruções (ISA)

| Instrução | Sintaxe | Descrição | Exemplo |
|-----------|---------|-----------|---------|
| **SET** | `SET R n` | Define registrador R para valor n | `SET WATER 30` |
| **INC** | `INC R` | Incrementa registrador R em 1 | `INC LIGHT` |
| **DECJZ** | `DECJZ R label` | Decrementa R; pula se zero | `DECJZ WATER parar` |
| **GOTO** | `GOTO label` | Pulo incondicional | `GOTO ciclo` |
| **PRINT** | `PRINT` | Exibe valor de WATER | `PRINT` |
| **HALT** | `HALT` | Para execução | `HALT` |

### Labels
```assembly
loop_principal:
    INC WATER
```

##  Gramática EBNF

```ebnf
programa = { definicao | regra } ;

definicao = "planta" , identificador , "{" , { propriedade } , "}" ;

propriedade = identificador , ":" , numero , ";" ;

regra = "quando" , condicoes , "entao" , acoes , "prioridade" , numero , ";" ;

condicoes = condicao , { "e" , condicao } ;

condicao = sensor , operador , numero
         | sensor , "entre" , numero , "e" , numero ;

sensor = "umidade" | "temperatura" | "luz_natural" | "luz_total" | "saude" ;

operador = "<" | ">" | "<=" | ">=" | "==" | "!=" ;

acoes = acao , { "," , acao } ;

acao = "regar" , "durante" , numero , "segundos"
     | "ajustar_luz" , "para" , numero , "porcento"
     | "aguardar" , numero , "minutos"
     | "alertar" , string
     | "registrar" , string ;

numero = digito , { digito } , [ "." , digito , { digito } ] ;

string = '"' , { caractere } , '"' ;

identificador = letra , { letra | digito | "_" } ;

letra = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | 
        "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" |
        "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | 
        "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" ;

digito = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

caractere = letra | digito | " " | "!" | "?" | "," | "." | ":" | "-" ;
```