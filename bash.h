#ifndef BASH_H
#define BASH_H

#define MAX_ARGS 500

// Data structure to hold a linked list of arguments for a command
struct args {
    char *arg;           // Argument string
    struct args *next;   // Pointer to the next argument
};

// Data structure to hold a linked list of redirections for a command
struct redirs {
    int redir_token;     // Type of redirection
    char *filename;      // File associated with redirection
    struct redirs *next; // Pointer to the next redirection
};

// This is the definition of a command
struct command {
    char *command;          // Command name
    int argc;              // Argument count
    char *argv[MAX_ARGS];  // Argument array
    char *infile;          // Input file
    char *outfile;         // Output file
    char *stdin;
    char *stdout;
    char *stderr;
    char *errfile;         // Error file
    struct args *args;     // Linked list of arguments
    struct redirs *redirs; // Linked list of redirections

    char output_append;     /* boolean: append stdout? */
    char error_append;      /* boolean: append stderr? */

    struct command *next;   // Pointer to the next command in a pipeline
    int line_number;
};

// Global variable for the parsed command
extern struct command *parsed_command;


/* externals */
extern int yydebug;
extern int debug;
extern int lines;  // Defined and updated by parser, used by bash.cc

/* Use THIS routine instead of malloc */
void *MallocZ(int numbytes);

void handle_redirections(struct redirs *redirection, struct command *pcmd);


/* Global routine declarations */
void doline(struct command *pass);
int yyparse(void);

#endif // BASH_H
