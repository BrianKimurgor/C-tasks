/*
 * Headstart for Ostermann's shell project
 *
 * Shawn Ostermann -- Sept 11, 2022
 */
 
#include <string.h>
#include <iostream>
#include <unistd.h>     // for execvp, fork, pipe
#include <sys/wait.h>   // for wait
#include <vector>

using namespace std;



// types and definitions live in "C land" and must be flagged
extern "C" {
#include "parser.tab.h"
#include "bash.h"
extern "C" void yyset_debug(int d);
}

// global debugging flag
int debug = 0;

// Function declarations
void execute_command(struct command *pcmd);
void execute_pipeline(struct command *pcmd);
void handle_redirections(struct redirs *redirection);

// Main entry pointint main(int argc, char *argv[])
int main(int argc, char *argv[])
{
    if (debug)
        yydebug = 1;  /* turn on YACC debugging if needed */

    // Infinite loop to keep the shell running
    while (1) {
        printf("> ");  // Print the prompt
        fflush(stdout);  // Ensure the prompt is printed immediately

        // Parse the input
        if (yyparse() != 0) {
            printf("Parsing error occurred!\n");
        }
    }

    return 0;
}



/*
 * doline - function called after parsing each line
 * Handles a single command or a pipeline of commands.
 */
void doline(struct command *pcmd)
{
    static int line_number = 1;  // Line number across multiple calls to doline()

    while (pcmd != NULL) {
        // Print the line header
        printf("========== line %d ==========\n", line_number);
        printf("Command name: '%s'\n", pcmd->command);

        // Display the arguments
        struct args *parg = pcmd->args;
        int arg_index = 0;
        while (parg != NULL) {
            printf("    argv[%d]: '%s'\n", arg_index++, parg->arg);  // 4 spaces indentation
            parg = parg->next;
        }

        // Display redirection info (stdin, stdout, stderr)
        printf("  stdin:  %s\n", pcmd->infile ? pcmd->infile : "UNDIRECTED");
        printf("  stdout: %s\n", pcmd->outfile ? (pcmd->output_append ? pcmd->outfile : pcmd->outfile) : "UNDIRECTED");
        printf("  stderr: %s\n", pcmd->errfile ? (pcmd->error_append ? pcmd->errfile : pcmd->errfile) : "UNDIRECTED");

        // Move to the next command in the pipeline
        pcmd = pcmd->next;
        line_number++;  // Increment line number for each command, even if it's part of a pipeline
    }
}



/*
 * execute_command - executes a single command with its arguments and redirections
 */
void execute_command(struct command *pcmd)
{
    if (pcmd == NULL || pcmd->command == NULL) {
        cout << "No command to execute\n";
        return;
    }

    // Convert the linked list of args into an array
    vector<char *> args;
    struct args *parg = pcmd->args;
    while (parg) {
        args.push_back(parg->arg);
        parg = parg->next;
    }
    args.push_back(NULL);  // execvp expects the last argument to be NULL

    // Fork the process to run the command
    pid_t pid = fork();
    if (pid == 0) {
        // Child process

        // Handle any redirections
        handle_redirections(pcmd->redirs);

        // Execute the command
        execvp(pcmd->command, args.data());
        perror("execvp failed");
        exit(1);  // Exit child if exec fails
    } else if (pid > 0) {
        // Parent process - wait for child to complete
        int status;
        waitpid(pid, &status, 0);
        cout << "Command executed: " << pcmd->command << endl;
    } else {
        // Fork failed
        perror("fork failed");
    }
}

/*
 * execute_pipeline - executes a series of commands connected by pipes
 */
void execute_pipeline(struct command *pcmd)
{
    int pipefd[2];
    pid_t pid;
    struct command *current = pcmd;

    while (current != NULL && current->next != NULL) {
        // Create a pipe
        if (pipe(pipefd) == -1) {
            perror("pipe failed");
            return;
        }

        // Fork the first command in the pipeline
        pid = fork();
        if (pid == 0) {
            // Child process

            // Redirect stdout to pipe write end
            close(pipefd[0]);
            dup2(pipefd[1], STDOUT_FILENO);
            close(pipefd[1]);

            // Execute the current command
            execute_command(current);

            exit(0);
        } else if (pid > 0) {
            // Parent process

            // Close the write end of the pipe
            close(pipefd[1]);

            // Redirect stdin to pipe read end for the next command
            dup2(pipefd[0], STDIN_FILENO);
            close(pipefd[0]);

            // Move to the next command in the pipeline
            current = current->next;
        } else {
            // Fork failed
            perror("fork failed");
        }
    }

    // Execute the last command in the pipeline
    execute_command(current);
}

/*
 * handle_redirections - handles input/output redirections
 */
void handle_redirections(struct redirs *redirection)
{
    while (redirection) {
        switch (redirection->redir_token) {
            case INFILE:
                freopen(redirection->filename, "r", stdin);
                break;
            case OUTFILE:
                freopen(redirection->filename, "w", stdout);
                break;
            case OUTFILE_APPEND:
                freopen(redirection->filename, "a", stdout);
                break;
            case ERRFILE:
                freopen(redirection->filename, "w", stderr);
                break;
            case ERRFILE_APPEND:
                freopen(redirection->filename, "a", stderr);
                break;
            default:
                cerr << "Unknown redirection type\n";
                break;
        }
        redirection = redirection->next;
    }
}
