#
# Sample lex/yacc Makefile
# Shawn Ostermann - Sept 10, 2022
#
CFLAGS = -Wall -Werror -O2
CC = gcc

PROGRAM = calc
CFILES = calc.c
HFILE = calc.h


##################################################
#
# You shouldn't need to change anything else
#
##################################################


# compute the OFILES
OFILES = ${CFILES:.cc=.o}

# all of the .o files that the program needs
OBJECTS = parser.tab.o lex.yy.o ${OFILES}


# How to make the whole program
# (don't forget the Lex Library "-ll")
${PROGRAM} : ${OBJECTS}
	${CC} ${CFLAGS} ${OBJECTS} -o ${PROGRAM} -ll


# 
# Turn the parser.y file into parser.tab.c using "bison"
# 
parser.tab.c : parser.y ${HFILES}
	bison -dvt ${YFLAGS} parser.y
parser.tab.o: parser.tab.c
	${CC} ${CFLAGS} -c parser.tab.c
parser.tab.h: parser.tab.c


# 
#  Turn the scanner.l file into lex.yy.c using "flex"
# 
lex.yy.c : scanner.l parser.tab.h ${HFILE}
	flex ${LFLAGS} scanner.l
lex.yy.o: lex.yy.c
	${CC} ${CFLAGS} -Wno-unused-function -g -c lex.yy.c

#
# File dependencies
#
${OFILES}: ${HFILE} parser.tab.h tokens.h

tokens.h: parser.y


clean:
	/bin/rm -f *.o lex.yy.c parser.tab.c ${PROGRAM} parser.h parser.output *.tab.c *.tab.h core
