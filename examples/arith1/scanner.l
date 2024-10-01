%{
/*
 * Simple example lex input file
 *
 * Shawn Ostermann -- Sunday, Sept 10, 2022
 *
 */

#include <string.h>
#include "parser.tab.h"

int yywrap(void) {return(1);} // don't need this

/* Everything up to the funny characters on the next line */
/* goes directly into the lex.yy.c file */
%}


/* The rest of this after the '%%' is lex rules */
%%

[ \t]+	{ }  /* Just ignore white space */

"\n" 	        { return(EOLN); } 
"+" 	        { return(PLUS); }
"-" 	        { return(MINUS); }
"*" 	        { return(TIMES); }
"/" 	        { return(DIVIDE); }


[0123456789]+	{
    /* a number is a sequence of digits */
    yylval.number = atoi(yytext);  /* convert the string to binary */
    return(NUMBER);
}

.		{
    /* if we haven't matched anything yet, then it's illegal */
    fprintf(stderr, "arith: Bad character '%c'\n", *yytext);
}

%%
