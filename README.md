# GardenScript

Uma linguagem de programação de alto nível para sistemas automatizados de cuidado com plantas, compilando para assembly PlantVM para controladores de jardim com recursos limitados.

## 🎯 Visão Geral

GardenScript é uma linguagem de programação educacional projetada para demonstrar conceitos de construção de compiladores enquanto resolve problemas reais de jardinagem IoT. Com construtos essenciais da linguagem (variáveis, condicionais, loops) e comandos de cuidado com plantas, compila para assembly PlantVM, sendo perfeita para:

- **Educação em Ciência da Computação**: Aprender design de compiladores com Flex/Bison
- **Desenvolvimento IoT**: Construir backends para sistemas automatizados de jardim  
- **Programação Embarcada**: Implementar algoritmos de cuidado com plantas com recursos mínimos
- **Pesquisa Agrícola**: Explorar conceitos de horticultura automatizada

## 🏗️ Arquitetura

### Máquina Virtual Alvo: PlantVM

#### Registradores Graváveis
- **`WATER`**: Timer/contador de água (segundos restantes para irrigação)
- **`LIGHT`**: Configuração de intensidade da luz artificial (0-100% brilho)

#### Registradores Somente Leitura (Sensores)
- **`MOISTURE`**: Nível atual de umidade do solo (0-100%, medido por sensor)
- **`TEMP`**: Temperatura ambiente (°C, sensor ambiental)
- **`HUMIDITY`**: Porcentagem de umidade do ar (0-100%, sensor atmosférico)
- **`LIGHTLV`**: Nível de luz natural detectado (0-100%, fotossensor)
- **`HEALTH`**: Índice de saúde da planta (0-100%, computado por sistema de visão)

### Modelo de Memória
- Pilha para armazenamento temporário de valores (operações LIFO)
- Contador de programa (PC) para sequenciamento de instruções
- Fluxo de controle baseado em labels (computado em tempo de carregamento)
- Memória de configuração para parâmetros de cuidado com plantas

### Modelo de Execução
- Execução sequencial de instruções
- Ramificação condicional e loops
- Transições de estado determinísticas
- **Simulação de crescimento de plantas**: Registrador HEALTH atualizado a cada tick de instrução baseado nas condições ambientais
- **Operações de pilha**: Armazenamento LIFO para valores temporários

## 📝 Arquitetura do Conjunto de Instruções (ISA)

| Instrução | Sintaxe | Descrição | Exemplo |
|-----------|---------|-----------|---------|
| **SET** | `SET R n` | Define registrador R para valor n | `SET WATER 30` |
| **INC** | `INC R` | Incrementa registrador R em 1 | `INC LIGHT` |
| **DEC** | `DEC R` | Decrementa registrador R em 1 | `DEC WATER` |
| **DECJZ** | `DECJZ R label` | Decrementa R; pula se zero | `DECJZ WATER parar_agua` |
| **GOTO** | `GOTO label` | Pulo incondicional | `GOTO loop_principal` |
| **CMP** | `CMP R n` | Compara registrador R com valor n | `CMP MOISTURE 50` |
| **JLT** | `JLT label` | Pula se última CMP foi menor que | `JLT regar_planta` |
| **JGT** | `JGT label` | Pula se última CMP foi maior que | `JGT reduzir_luz` |
| **PRINT** | `PRINT R` | Exibe valor do registrador no log | `PRINT HEALTH` |
| **WAIT** | `WAIT n` | Aguarda por n segundos (atualiza sensores) | `WAIT 60` |
| **HALT** | `HALT` | Para execução do programa | `HALT` |

### Labels
```assembly
loop_principal:     ; Define um alvo de pulo
    INC WATER       ; Instruções seguindo o label
```

### Modelo de Cuidado com Plantas

PlantVM inclui uma simulação realística de resposta da planta que atualiza o registrador `HEALTH` a cada tick de instrução:

```
Mudança de Saúde = f(MOISTURE, TEMP, LUZ_TOTAL, tempo)
LUZ_TOTAL = LIGHTLV + (LIGHT * 0.8)
```

**Características do Modelo:**
- **Faixa Ideal de Umidade**: 40-70% para crescimento saudável
- **Efeitos da Temperatura**: Crescimento diminui abaixo de 18°C ou acima de 30°C
- **Requisitos de Luz**: Mínimo de 30% de luz total (natural + artificial) para fotossíntese
- **Recuperação de Saúde**: Boas condições restauram lentamente a saúde da planta ao longo do tempo
- **Resposta ao Estresse**: Condições ruins reduzem gradualmente o índice de saúde

**Exemplo**: Uma planta com MOISTURE=30%, TEMP=25°C e LIGHT=60% perderá gradualmente saúde devido à água insuficiente, apesar da luz e temperatura adequadas.

## 📝 Gramática (BNF)

```bnf
<programa> ::= {<declaracao>}*

<declaracao> ::= <declaracao-variavel>
               | <atribuicao>
               | <declaracao-if>
               | <declaracao-while>
               | <comando>
               | <bloco>

<declaracao-variavel> ::= var <identificador> ;
                        | var <identificador> = <expressao> ;

<atribuicao> ::= <identificador> = <expressao> ;

<declaracao-if> ::= if ( <expressao> ) <declaracao>
                  | if ( <expressao> ) <declaracao> else <declaracao>

<declaracao-while> ::= while ( <expressao> ) <declaracao>

<bloco> ::= { {<declaracao>}* }

<comando> ::= <identificador> ( {<lista-expressoes>}? ) ;

<lista-expressoes> ::= <expressao>
                     | <lista-expressoes> , <expressao>

<expressao> ::= <expressao-ou>

<expressao-ou> ::= <expressao-e>
                 | <expressao-ou> || <expressao-e>

<expressao-e> ::= <expressao-igualdade>
                | <expressao-e> && <expressao-igualdade>

<expressao-igualdade> ::= <expressao-relacional>
                        | <expressao-igualdade> == <expressao-relacional>
                        | <expressao-igualdade> != <expressao-relacional>

<expressao-relacional> ::= <expressao-aditiva>
                         | <expressao-relacional> < <expressao-aditiva>
                         | <expressao-relacional> > <expressao-aditiva>

<expressao-aditiva> ::= <expressao-multiplicativa>
                      | <expressao-aditiva> + <expressao-multiplicativa>
                      | <expressao-aditiva> - <expressao-multiplicativa>

<expressao-multiplicativa> ::= <expressao-unaria>
                             | <expressao-multiplicativa> * <expressao-unaria>
                             | <expressao-multiplicativa> / <expressao-unaria>

<expressao-unaria> ::= <expressao-primaria>
                     | ! <expressao-unaria>
                     | - <expressao-unaria>

<expressao-primaria> ::= <identificador>
                       | <numero>
                       | <string>
                       | <booleano>
                       | ( <expressao> )

<numero> ::= <digito> {<digito>}*
           | <digito> {<digito>}* . <digito> {<digito>}*

<string> ::= " {<caractere>}* "

<booleano> ::= true | false

<identificador> ::= <letra> {<letra-ou-digito>}*

<letra-ou-digito> ::= <letra> | <digito>

<letra> ::= a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z
          | A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z

<digito> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

<caractere> ::= <letra> | <digito> | <espaco> | <simbolo>

<simbolo> ::= ! | @ | # | $ | % | ^ | & | * | ( | ) | - | + | = | [ | ] | { | } | | | \ | : | ; | ' | < | > | , | . | ? | /

<espaco> ::= " "
```
