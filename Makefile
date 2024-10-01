#
# Sample lex/yacc Makefile
# Shawn Ostermann - Mon Sep 24, 2001
#
CFLAGS = -Wall -Werror -O2
CC = gcc
CXX = g++

PROGRAM = bash
CFILES = 
CCFILES = bash.cc
HFILE = bash.h


##################################################
#
# You shouldn't need to change anything else
#
##################################################


# compute the OFILES
OFILES = ${CFILES:.c=.o} ${CCFILES:.cc=.o}

# all of the .o files that the program needs
OBJECTS = parser.tab.o lex.yy.o ${OFILES}


# How to make the whole program
# (don't forget the Lex Library "-ll")
${PROGRAM} : ${OBJECTS}
	${CXX} ${CFLAGS} ${OBJECTS} -o ${PROGRAM} 


# 
# Turn the parser.y file into parser.tab.c using "bison"
# 

parser.tab.c : parser.y ${HFILES}
	bison -dvt ${YFLAGS} parser.y
parser.tab.o: parser.tab.c
	${CC} ${CFLAGS} -c parser.tab.c
parser.tab.h: parser.tab.c


# 
#  Turn the scanner.l file into lex.yy.c using "lex"
# 
lex.yy.c : scanner.l parser.tab.h ${HFILE}
	flex ${LFLAGS} scanner.l
lex.yy.o: lex.yy.c
	${CC} ${CFLAGS} -Wno-unused-function -g -c lex.yy.c

#
# File dependencies
#
${OFILES}: ${HFILE} parser.tab.h

test: bash
	-chmod a+rx ./test.*
	-./test.1
	-./test.2
	-./test.3
	-./test.4
	-./test.5
	-./test.6
	-./test.7
	-./test.8
	

clean:
	/bin/rm -f *.o lex.yy.c parser.tab.c ${PROGRAM} parser.tab.h parser.output *.tab.c *.tab.h core test.*.myoutput test.*.correct test.*.input
