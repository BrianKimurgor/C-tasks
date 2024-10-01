%{
#include "parser.tab.h"
int yywrap(void) {return(1);} // don't need this
%}


%%
[ \t]   	    {}
"\n"		    { return(NEWLINE); }
"dogcatcher"	{ return(DOGCATCHER); }
"dog"		    { return(DOG); }
"cat"		    { return(CAT); }
"bear"		    { return(BEAR); }
. 		        { printf("Syntax error\n");}
%%
