%{
#include <string.h>
#include <ctype.h>
#include "parser.tab.h"

void yyerror(const char *s, ...);
void yywarn(const char *s, ...);
%}

/* The rules start here */
%%
[ \t]+            { /* Ignore white space */ }

\n                { return EOLN; }

"|"               { return PIPE; }
"<"               { return INFILE; }
">>"              { return OUTFILE_APPEND; }
">"               { return OUTFILE; }
"2>>"             { return ERRFILE_APPEND; }
"2>"              { return ERRFILE; }

";"               { /* Ignore semicolons and continue */ }

^#!.*             { /* Ignore shebang line */ }
^#.*              { /* Ignore comments */ }
^END$             { /* Ignore END marker */ }
[a-zA-Z_][a-zA-Z0-9_]*=[^ \t\n]+ { /* Ignore variable assignments */ }
^={10}.*={10}$    { /* Ignore line markers like '========== line 1 ==========' */ }
^Command.*$       { /* Ignore lines with command info like 'Command name:' */ }
^argv\[.*$        { /* Ignore lines with argument details like 'argv[0]:' */ }
^stdin:.*$        { /* Ignore lines with stdin info */ }
^stdout:.*$       { /* Ignore lines with stdout info */ }
^stderr:.*$       { /* Ignore lines with stderr info */ }
^if\b.*           { /* Ignore 'if' conditional statements from the script */ }
^else\b.*         { /* Ignore 'else' statements */ }
^exit\b.*         { /* Ignore 'exit' statements */ }
^echo[ \t]+PASSES { /* Ignore echo PASS output */ }
^echo[ \t]+FAILS  { /* Ignore echo FAIL output */ }
^diff\b.*         { /* Ignore 'diff' commands from the script */ }

\'([^\']*)\'      { 
                    int len = strlen(yytext) - 2; // Length excluding the quotes
                    yylval.string = (char *) malloc(len + 1); // Allocate memory
                    strncpy(yylval.string, yytext + 1, len); // Copy without quotes
                    yylval.string[len] = '\0'; // Null terminate the string
                    return WORD; 
                  }

\"([^\"]*)\"      {
                    // Capture a quoted string
                    int len = strlen(yytext) - 2; // Length excluding the quotes
                    yylval.string = (char *) malloc(len + 1); // Allocate memory
                    strncpy(yylval.string, yytext + 1, len); // Copy without quotes
                    yylval.string[len] = '\0'; // Null terminate the string
                    return WORD;
                  }

[a-zA-Z0-9_./!@#$%^&*()_+\-=\~\[\];:,?]+  {
    yylval.string = strdup(yytext);
    return WORD;
}

<<EOF>>           { return 0; }

.                 { yyerror("Unrecognized character: %s", yytext); }

%%

int yywrap(void) {
    return 1;
}
