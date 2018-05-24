%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "main.h"

#define YYDEBUG 1


/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(string n);
nodeType *str(string n);
//nodeType *con(int value);
void freeNode(nodeType *p);
extern "C"
{
    int ex(nodeType *p, map<string,void*>& env);
    extern int yylex(void);
    void yyerror(char *);
    extern nodeType *con(int value);
}

void yyerror(char *s);
//int sym[26];                    /* symbol table */
map<string,nodeType*> sym;
%}

%token <sIndex> STRING
%token LEND
%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token <sIndex> FVAR
%token WHILE IF PRINT DO END THEN ELSEIF FUNCTION 
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%nonassoc CALL

%type <nPtr> stmt expr stmt_list ifstmt function callfunc argwrap arglist argdefine arglistDefine

%%

//token that lex returns, yacc push it into stack and check if there is a rule to reduct current stack.


// program:
        // stmt_list                { //ex($1,gEnv); 
									// freeNode($1); }
        // |
        // ;
program:
        stmt_list                {	compile($1);freeNode($1); }
        |
        ;

// function:
          // function stmt_list         { ex($2); freeNode($2); }
        // | /* NULL */
        // ;

stmt:
          LEND                            { $$ = opr(';', 2, NULL, NULL); }
        | expr LEND                      { $$ = $1; }
        | PRINT expr LEND                 { $$ = opr(PRINT, 1, $2); }
        | VARIABLE '=' expr LEND          {$$ = opr('=', 2, id($1), $3); }
        | WHILE  expr DO stmt_list END        { $$ = opr(WHILE, 2, $2, $4); }
        | ifstmt END %prec IFX    {$$=$1;}
        | ifstmt ELSE stmt_list END   {$$ = opr(ELSE, 2, $1, $3);}
        | function  {$$=$1;}
        ;
        
ifstmt:
        IF expr THEN stmt_list    {$$ = opr(IF, 2, $2, $4);}
        |ifstmt ELSEIF expr THEN stmt_list   {$$ = opr(ELSEIF, 3,$1, $3, $5);}
        ;

callfunc:
        VARIABLE argwrap {
            string* name=new string($1);
            $$=opr(typeCall,2,name->c_str(),$2);
            }
        
        
function:
        FUNCTION FVAR argdefine stmt_list END {
            LOG("%s",$2.c_str());
            string* name=new string($2);
            $$=opr(typeFuncDef,3,name->c_str(),$3,$4);
            }
        |FUNCTION argdefine stmt_list END      {$$=opr(typeFuncDef,2,$2,$3);}
        
argdefine:
        '(' ')' {$$=0;}
        |'(' arglistDefine ')' {$$=$2;}
        
arglistDefine:

//TODO:var's env should determin at ex,here should leave a node. 
        FVAR {LOG("%s",$1.c_str()); $$=id($1);}
        |arglistDefine ',' FVAR {
            string* n=new string($3);
            $$=opr(typeArgDef,2,$1,n->c_str());}

argwrap:
        '(' ')' {$$=0;}
        |'(' arglist ')' {$$=$2;}
        
arglist:
        expr { $$=$1;}
        | arglist ',' expr {$$=opr(',',2,$1,$3);}
        

stmt_list:
          stmt                  {$$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

expr:
          INTEGER               { $$ = con($1); }
		| STRING                { $$ = str($1); }
        | VARIABLE              { $$ = id($1); }
        | callfunc %prec CALL   {$$=$1;}
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
		| expr '%' expr         { $$ = opr('%', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          {$$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%


nodeType *str(string s)
{
	nodeType* p=new nodeType;
	p->type = typeStr;
	p->id.name = s;
	return p;
}

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(string n) {
    nodeType *p=new nodeType;

    /* copy information */
    p->type = typeId;
    //cout<<"id n "<<n<<endl;
    p->id.name = n;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(int argc, char* argv[]) {
    
    yydebug=1;
    char* fn=argv[1];
    FILE* fp=fopen(fn,"r");
    //assert(fp!=NULL);
    extern FILE* yyin;
    yyin=fp;
    
    cout<<"start----------"<<endl;

    yyparse();
    
    cout<<"end------"<<endl;
    return 0;
}
