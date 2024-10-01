/*
 * Simple YACC example
 *
 * Shawn Ostermann -- Wed Feb  7, 1996
 */
 
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

/* found elsewhere */
int yyparse(void);

int main()
{
    yyparse();
    exit(0);
}
