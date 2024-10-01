/*
 * Ostermann's shell header file
 */


#define MAX_ARGS 500


/* This is the definition of a command */
struct command {
    char *command;
    int argc;
    char *argv[MAX_ARGS];
    char *infile;
    char *outfile;
    char *errfile;

    char output_append;		/* boolean: append stdout? */
    char error_append;		/* boolean: append stderr? */

    struct command *next;
};


/* externals */
extern int yydebug;
extern int debug;
extern int lines;  // defined and updated by parser, used by bash.cc


/* you should use THIS routine instead of malloc */
void *MallocZ(int numbytes);

/* global routine decls */
void doline(struct command *pass);
int yyparse(void);
