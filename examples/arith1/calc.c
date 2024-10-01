/*
 * Simple arithmetic program as a lex/yacc example
 *
 * Shawn Ostermann -- Sept 11, 2022
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"  // created by bison
#include "calc.h"

/* globals */


/* local routines */
static void doexpr(struct assignment *pass);


/**
 * @brief Main entry point of the program.
 *
 * This function initializes the program, checks for command-line arguments,
 * and sets the debugging mode for YACC based on the provided arguments.
 * It then proceeds to parse the input file.
 *
 * @param argc The number of command-line arguments.
 * @param argv An array of command-line arguments.
 * @return int Exit status of the program.
 */
int
main(
     int argc,
     char *argv[])
{
    if ((argc == 2) && (strcmp(argv[1],"-d") == 0))
	    yydebug = 1;  /* turn on ugly YACC debugging */
    else
	    yydebug = 0;  /* turn off ugly YACC debugging */

    /* parse the input file */
    yyparse();

    exit(0);
}


static void
/**
 * doexpr - Processes an assignment expression.
 * @pass: Pointer to the assignment structure containing the expression details.
 *
 * This function takes a pointer to an assignment structure and processes
 * the expression contained within it. The specifics of the processing
 * depend on the implementation details of the function.
 */
doexpr(
    struct assignment *pass)
{
    int i;
    int sum;
    int nextterm;
    int debug = 0;

    if (debug) for (i=0; i < pass->nops; ++i) {
        printf("Term[%d] = %d\n", i, pass->numbers[i]);

    }

    printf("  Number of operations: %d\n", pass->nops);
    printf("  Question: '");
    sum = pass->numbers[0];
    
    for (i=0; i < pass->nops; ++i) {
        printf(" %d", pass->numbers[i]);
        if (i+1 < pass->nops) {
            nextterm = pass->numbers[i+1];
                switch(pass->operators[i]) {
                case PLUS:    printf(" +"); sum += nextterm; break;
                case MINUS:   printf(" -"); sum -= nextterm; break;
                case TIMES:   printf(" *"); sum *= nextterm; break;
                case DIVIDE:  printf(" /"); sum /= nextterm; break;
                default:  printf("? ");
            }
        }
    }
    printf("'\n");
    printf("  answer is %d\n\n", sum);
}


void
doline(
    struct assignment *pass)
{
    printf("Read a line:\n");

    doexpr(pass);
}
