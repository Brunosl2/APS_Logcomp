CC = gcc
CFLAGS = -Wall -g
FLEX = flex
BISON = bison

all: plantlang

plantlang: lex.yy.c parser.tab.c
	$(CC) $(CFLAGS) -o plantlang lex.yy.c parser.tab.c -lfl

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d parser.y

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) lexer.l

test: plantlang
	./plantlang test.plant

clean:
	rm -f plantlang lex.yy.c parser.tab.c parser.tab.h

.PHONY: all test clean