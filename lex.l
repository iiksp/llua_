%{
#include <stdlib.h>
#include "main.h"
#include "yacc.tab.h"
#include "string.h"

extern "C"
{
    void yyerror(char *);
	int yywrap(void);
	int yylex(void);	    
}

//when lex match one pattern,it will not go the rule below.
%}

%x FDEFINE

nondigit	([_A-Za-z])
digit		([0-9])

%%


\'(\\.|[^'\\])*\'    {
				yytext=yytext+1;
				yytext[strlen(yytext)-1] ='\0';
                yylval.sIndex = yytext;
                return STRING;
            }

--(.|[^\n])*		return LEND;

0           {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[1-9][0-9]* {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[-()<>=+*/%{}.,] {
                return *yytext;
             }

[;\n]			return LEND;

">="            return GE;
"<="            return LE;
"=="            return EQ;
"~="            return NE;
"while"         return WHILE;
"do"            return DO;
"end"           return END;
"if"            return IF;
"then"          return THEN;
"elseif"        return ELSEIF;
"else"          return ELSE;
"print"         return PRINT;

"function"      {
    BEGIN FDEFINE;
    return FUNCTION;
}
<FDEFINE>[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sIndex=yytext;
    return FVAR;
}
<FDEFINE>[-(<>=+*/;{}.,] {
                return *yytext;
}
<FDEFINE>")" {
    BEGIN INITIAL;
    return *yytext;
}

[a-zA-Z_][a-zA-Z0-9_]*       { 
                yylval.sIndex = yytext;
                return VARIABLE;
            }



[ \t]+        ;       /* ignore whitespace */

.               yyerror("Unknown character");

%%

int yywrap(void) {
    return 1;
}