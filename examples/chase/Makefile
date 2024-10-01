#
# Sample lex/yacc Makefile
# Shawn Ostermann - Wed Feb  7, 1996
#
CFLAGS = -g 
CC = gcc


# all of the .o files that the program needs
OBJECTS = parser.tab.o lex.yy.o chase.o


# How to make the whole program
chase : ${OBJECTS}
	${CC} ${CFLAGS} ${OBJECTS} -o chase 


# 
# Turn the parser.y file into y.tab.c using "yacc"
# 
# Also, yacc generates a header file called "y.tab.h" which lex needs
#
parser.tab.c : parser.y
	bison -dvt ${YFLAGS} parser.y
parser.tab.h: parser.tab.c

# 
#  Turn the scanner.l file into lex.yy.c using "lex"
# 
lex.yy.c : scanner.l parser.tab.h
	flex ${LFLAGS} scanner.l

clean:
	/bin/rm -f *.o lex.yy.c parser.tab.c chase y.output parser.tab.h parser.output
