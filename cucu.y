%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(const char* message);
int yylex();
int yywrap();
int yyparse();
extern FILE* yyin;
extern FILE* yyout;
int current;
int done = 0;
extern int line;
FILE* par;
int main(int argc, char** argv)
{
    
    if(argc!=2){
        printf("please provide arguments correctly");
    }
    else{
        yyin = fopen(argv[1], "r");
        yyout = fopen("Lexer.txt","w");
        par = fopen("Parser.txt","w");
        line = 1;
        yyparse();
        if(done){
          printf("Errors detected\n");
        }
        else{
          printf("No errors detected\n");
        }
    }
}

void yyerror(const char* message)
{
	fprintf(par,"\n\nERROR! Line : %d : %s",line,message);
  done = 1;
}

struct symrec
{
  char *name;             
  struct symrec *next;    
  int type;
};
typedef struct symrec symrec;
symrec *var_varmap,*fun_varmap;
symrec * putsym ( char *sym_name ,int typ,symrec *var_varmap)
{
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof(symrec));
  ptr->name = (char *) malloc (strlen(sym_name)+1);
  ptr->type = typ;
  strcpy (ptr->name,sym_name);
  ptr->next = (struct symrec *)var_varmap;
  var_varmap = ptr;
  return ptr;
}
int getsym ( char *sym_name ,symrec *var_varmap)
{
  symrec *ptr;
  for (ptr = var_varmap; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr->type;
  return 0;
}





%}
%union{
    int number;
    char* string;
}

%token OPEN_PARENTHESIS
%token CLOSE_PARENTHESIS
%token OPEN_SQUARE
%token CLOSE_SQUARE
%token BLOCK_OPEN
%token BLOCK_CLOSE
%token INT_DYPE
%token STR_DTYPE
%token IF_CODE
%token ELSE_CODE
%token WHILE_CODE
%token RETURN_CODE
%token<number> CONST
%token<string> IDEN
%token<string> STR
%token EQ_OP
%token NEQ_OP
%token ADD_OPER
%token SUB_OPER
%token MUL_OPER
%token DIV_OPER
%token ASSIGN_OPER
%token SEMI_COL
%token COMMA
%token B_OR
%token B_AND
%token GT
%token LT
%token<string> CHAR
%type<number> DTYPE
%type<number> FACT
%type<number> TERM
%type<number> A_EXPR                    //bool or int 1 char* 2 char 3
%type<number> B_EXPR
%type<number> EXPR
%type<number> VAR_ASSIGN
%type<number> FUN_CALL

%left MUL_OPER DIV_OPER
%left ADD_OPER SUB_OPER
%left B_OR B_AND
%left EQ_OP NEQ_OP GT LT
%%

CODES:                          CODE {fprintf(par,"\n");} CODES                                                       
                                | CODE                                               {fprintf(par,"Program ended");printf("Parsing completed\n");}                                               

CODE :                          F_DECLARATION SEMI_COL|  V_DECLARATION|      DEFINATION

F_DECLARATION :                 DTYPE IDEN OPEN_PARENTHESIS {fprintf(par,"Function %s \nARGS:", $2);} AARGS CLOSE_PARENTHESIS   {fprintf(par,"\n");if(getsym($2,fun_varmap)==0){fun_varmap = putsym($2,$1,fun_varmap);}else{yyerror("function already declared or defined\n\n");}}                                      

AARGS:                                                                                           {fprintf(par,"NO ARGS\n");}
                                |ARGS                                                              
ARGS :                          ARGS COMMA DTYPE IDEN                                            {fprintf(par,"var %s, ",$4);}
                                | DTYPE IDEN                                                      {fprintf(par,"var %s\n",$2);}                 
V_DECLARATION :                 DTYPE IDEN SEMI_COL                                               {fprintf(par,"var %s\n",$2);if(getsym($2,var_varmap)==0){var_varmap = putsym($2,$1,var_varmap);}else{yyerror("variable already declared\n\n");}}        

DTYPE:                          INT_DYPE                                                          {fprintf(par,"type int ");$$ = 1;}
                                | STR_DTYPE                                                       {fprintf(par,"type char * ");$$ = 2;}

DEFINATION :                    FUN_START STATS BLOCK_CLOSE                        {fprintf(par,"function ended\n");}                     
FUN_START:                      F_DECLARATION BLOCK_OPEN                           {fprintf(par,"function defination starts:\n");}
STATS :                         | STAT STATS                                        {fprintf(par,"\n");}

STAT :                          FUN_CALL SEMI_COL                                   {fprintf(par,"\n");}
                                | ASSIGN | RETURN | IF | WHILE | V_DECLARATION

FUN_CALL :                      IDEN OPEN_PARENTHESIS {fprintf(par,"calling function %s, with following arguments:",$1);current=1;} ARGUM CLOSE_PARENTHESIS      {$$ = getsym($1,fun_varmap);if($$==0){yyerror("Function NOT DECLARED\n\n");}}                    
ARGUM :                         
                                |ARGUM COMMA {fprintf(par,"arg %d : ",current++);}EXPR              {fprintf(par,",");}                                         
                                |{fprintf(par,"arg %d : ",current++);}EXPR                          {fprintf(par,",");}                  

ASSIGN :                        DTYPE VAR_ASSIGN                                                    {if($2<10){yyerror("Variable already declared\n\n");}if(($2-10)!=$1 ){yyerror("Datatype mismatch\n\n");}}                      
                                | VAR_ASSIGN                                                        {if($1==-1){yyerror("Datatype mismatch\n\n");}if($1>10){yyerror("Variable not already declared\n\n");}}

VAR_ASSIGN:                     IDEN ASSIGN_OPER EXPR SEMI_COL                                      {fprintf(par," %s assign\n",$1);$$ = getsym($1,var_varmap);if($$ == 0){$$ = 10+$3;var_varmap = putsym($1,$3,var_varmap);}else{if($$!=$3){$$ = -1;}else{$$=$3;}}}      
                                | IDEN OPEN_SQUARE IDEN CLOSE_SQUARE ASSIGN_OPER CHAR SEMI_COL      {fprintf(par," %s assign\n",$1);$$ = getsym($1,var_varmap);if($$ == 2){$$ = getsym($3,var_varmap);if($$==1){$$ = 4;}else{$$=-1;}}else{$$=-1;}}

RETURN :                        RETURN_CODE {fprintf(par,"function return");} EXPR SEMI_COL                                           

WHILE :                         WHILE_START BOOLEAN {fprintf(par,"\nSTATEMENTS:\n");} CLOSE_PARENTHESIS BLOCK_OPEN STATS BLOCK_CLOSE
WHILE_START:                    WHILE_CODE OPEN_PARENTHESIS                                             {fprintf(par,"While:\nB_EXPR:");}
IF :                            IF_BLOCK                                                                {fprintf(par,"\nIF ENDED\n");}
                                |IF_BLOCK ELSE_B STATS BLOCK_CLOSE                                            {fprintf(par,"\nIF ELSE ENDED\n");}
ELSE_B:                         ELSE_CODE BLOCK_OPEN                                                    {fprintf(par,"\nELSE START\nSTATEMENTS:\n");}
IF_BLOCK:                       IF_START BOOLEAN {fprintf(par,"\nSTATEMENTS:\n");} CLOSE_PARENTHESIS BLOCK_OPEN STATS BLOCK_CLOSE 
BOOLEAN:                        B_EXPR                                                                

IF_START:                       IF_CODE OPEN_PARENTHESIS                                                {fprintf(par,"if cond:\nB_EXPR:");}
EXPR :                          A_EXPR                                      {$$ =$1;}           
                                | B_EXPR                                    {$$ =$1;}

B_EXPR :                        EXPR EQ_OP EXPR                             {fprintf(par,"operator: == ");$$=1;} 
                                |EXPR NEQ_OP EXPR                           {fprintf(par,"operator: != ");$$=1;}
                                |EXPR GT EXPR                         {fprintf(par,"operator: > ");$$=1;}
                                |EXPR LT EXPR                        {fprintf(par,"operator: < ");$$=1;}
                                |EXPR B_OR EXPR                        {fprintf(par,"operator: || ");$$=1;}
                                |EXPR B_AND EXPR                        {fprintf(par,"operator: && ");$$=1;}

FACT:                           OPEN_PARENTHESIS EXPR CLOSE_PARENTHESIS     {fprintf(par,"operator: () ");$$ = $2;} 
                                | CONST                                     {fprintf(par," const-%d ",$1);$$ = 1;} 
                                | STR                                       {fprintf(par," string-%s ",$1);$$ = 2;} 
                                | IDEN                                      {fprintf(par," var-%s ",$1);$$ = getsym($1,var_varmap);if($$==0){yyerror("\n\nVARIABLE NOT DECLARED\n\n");}}         
                                | CHAR                                      {fprintf(par," character-%s ",$1);$$ = 3;}
                                | IDEN OPEN_SQUARE IDEN CLOSE_SQUARE        {fprintf(par," var_char- %s %s []",$1,$3);$$ = 3;}
                                | FUN_CALL                                  {$$ = $1;}
                          

A_EXPR:                         EXPR ADD_OPER TERM                   {fprintf(par,"operator: + ");if($1!=$3 || $1!=1){yyerror("data type is not mached in expreession\n\n");}$$ = $1;}                            
                                | EXPR SUB_OPER TERM                 {fprintf(par,"operator: - ");if($1!=$3 || $1!=1){yyerror("data type is not mached in expreession\n\n");}$$ = $1;}       
                                | TERM                               {$$ = $1;}                    

TERM :                          TERM MUL_OPER FACT                  {fprintf(par,"operator: * ");if($1!=$3 || $1!=1){yyerror("data type is not mached in expreession\n\n");}$$ = $1;}                                    
                                | TERM DIV_OPER FACT                {fprintf(par,"operator: / ");if($1!=$3 || $1!=1){yyerror("data type is not mached in expreession\n\n");}$$ = $1;}       
                                | FACT                              {$$ =$1;}

%%
