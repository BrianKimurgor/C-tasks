%{
#include <stdio.h>
#include <stdarg.h>
#include "bash.h"
#include <stdlib.h>
#include <string.h>

extern int lines;
int yylex();
void yyerror(const char *s,...);
void doline(struct command *cmd);
%}

%union {
    char *string;              // For WORD token
    struct command *pcmd;      // For command structure
    struct args *pargs;        // For argument structure
    struct redirs *predir;     // For redirection structure
    int number;                // For numerical values, if needed
}
// Define tokens
%token IF THEN ELSE FI          // Define tokens for if-else statements
%token condition
%token <string> WORD           // Associate WORD token with string type
%token EOLN PIPE INFILE OUTFILE OUTFILE_APPEND ERRFILE ERRFILE_APPEND
%type <pcmd> line cmd
%type <pargs> optargs arg
%type <predir> optredirs redir

%%  // Parsing rules

input : lines | ;

lines : oneline | oneline lines ;

oneline : line eoln { doline($1); }
        | eoln ;

eoln : EOLN { ++lines; } ;

line : cmd { $$ = $1; }
     | if_block { $$ = NULL; }  // Ignore the whole if block
     | cmd PIPE line {
         // Pipe handling logic
     }
     ;

if_block : IF condition THEN lines ELSE lines FI { /* Ignore this block */ }
          | IF condition THEN lines FI { /* Ignore this block */ }
          ;

cmd : WORD optargs optredirs {
         struct command *newcmd = (struct command *) MallocZ(sizeof(struct command));
         newcmd->command = $1;   // Set the command name to the WORD token
         
         // Create a new args structure to include the command name
         struct args *cmd_arg = (struct args *) MallocZ(sizeof(struct args));
         cmd_arg->arg = $1;       // Assign the command name as the first argument
         cmd_arg->next = $2;      // Link the existing arguments to this new argument
         
         newcmd->args = cmd_arg;  // Set arguments with command name as the first entry
         newcmd->redirs = $3;     // Set the redirections
         newcmd->infile = NULL;   // Initialize input redirection
         newcmd->outfile = NULL;  // Initialize output redirection
         newcmd->errfile = NULL;  // Initialize error redirection

         // Handle redirections (similar to your original code)
         struct redirs *current_redir = $3; // Use the parsed redirs list
         while (current_redir != NULL) {
             if (current_redir->redir_token == INFILE) {
                 newcmd->infile = current_redir->filename; // Link input redirection
             } else if (current_redir->redir_token == OUTFILE) {
                 newcmd->outfile = current_redir->filename; // Link output redirection
                 newcmd->output_append = 0; // Set append flag to false
             } else if (current_redir->redir_token == OUTFILE_APPEND) {
                 newcmd->outfile = current_redir->filename; // Link output redirection (append)
                 newcmd->output_append = 1; // Set append flag to true
             } else if (current_redir->redir_token == ERRFILE) {
                 newcmd->errfile = current_redir->filename; // Link error redirection
                 newcmd->error_append = 0; // Set append flag to false
             } else if (current_redir->redir_token == ERRFILE_APPEND) {
                 newcmd->errfile = current_redir->filename; // Link error redirection (append)
                 newcmd->error_append = 1; // Set append flag to true
             }
             current_redir = current_redir->next; // Move to the next redirection
         }
         $$ = newcmd;            // Return the new command structure
     }
     ;

optargs : arg optargs {
            $1->next = $2;       // Link new argument to the argument list
            $$ = $1;
        }
        | { $$ = NULL; }
        ;

arg : WORD {
        struct args *newarg = (struct args *) MallocZ(sizeof(struct args));
        newarg->arg = $1;       // Assign the WORD token as the argument
        newarg->next = NULL;    // Set the next pointer to NULL
        $$ = newarg;            // Return the new argument structure
    }
    ;

optredirs : redir optredirs {
              $1->next = $2;    // Link new redirection to the redirection list
              $$ = $1;
          }
          | { $$ = NULL; }
          ;

redir : INFILE WORD {
       struct redirs *newredir = (struct redirs *) MallocZ(sizeof(struct redirs));
       newredir->redir_token = INFILE;
       newredir->filename = $2;  // Capture the filename for input redirection
       newredir->next = NULL;
       $$ = newredir;            // Return the new redirection structure
   }
   | OUTFILE WORD {
       struct redirs *newredir = (struct redirs *) MallocZ(sizeof(struct redirs));
       newredir->redir_token = OUTFILE;
       newredir->filename = $2;  // Capture the filename for output redirection
       newredir->next = NULL;
       $$ = newredir;            // Return the new redirection structure
   }
   | OUTFILE_APPEND WORD {
       struct redirs *newredir = (struct redirs *) MallocZ(sizeof(struct redirs));
       newredir->redir_token = OUTFILE_APPEND;
       newredir->filename = $2;  // Capture the filename for append output redirection
       newredir->next = NULL;
       $$ = newredir;            // Return the new redirection structure
   }
   | ERRFILE WORD {
       struct redirs *newredir = (struct redirs *) MallocZ(sizeof(struct redirs));
       newredir->redir_token = ERRFILE;
       newredir->filename = $2;  // Capture the filename for error redirection
       newredir->next = NULL;
       $$ = newredir;            // Return the new redirection structure
   }
   | ERRFILE_APPEND WORD {
       struct redirs *newredir = (struct redirs *) MallocZ(sizeof(struct redirs));
       newredir->redir_token = ERRFILE_APPEND;
       newredir->filename = $2;  // Capture the filename for append error redirection
       newredir->next = NULL;
       $$ = newredir;            // Return the new redirection structure
   }
   ;

%%

// Error handling and memory allocation functions remain the same.
void yyerror(const char *error_string, ...) {
    va_list ap;
    FILE *f = stdout;

    va_start(ap, error_string);
    fprintf(f, "Error on line %d: ", lines);
    vfprintf(f, error_string, ap);
    fprintf(f, "\n");
    va_end(ap);
}

void *MallocZ(int nbytes) {
    char *ptr = malloc(nbytes);
    if (ptr == NULL) {
        perror("MallocZ failed, fatal\n");
        exit(66);
    }
    memset(ptr, '\00', nbytes);
    return ptr;
}
