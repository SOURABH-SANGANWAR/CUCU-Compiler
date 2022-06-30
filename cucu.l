%{
#include <stdio.h>
#include "cucu.tab.h"
void yyerror(const char* message);
int line;
// extern int yylval;
%}

%%
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/          {fprintf(yyout,"COMMENT : %s\n",yytext);}
\(                          {fprintf(yyout,"P_OPEN : %s\n",yytext);return OPEN_PARENTHESIS;}
\)                          {fprintf(yyout,"P_CLOSE : %s\n",yytext);return CLOSE_PARENTHESIS;}
\[                          {fprintf(yyout,"SQ_OPEN : %s\n",yytext);return OPEN_SQUARE;}
\]                          {fprintf(yyout,"SQ_CLOSE : %s\n",yytext);return CLOSE_SQUARE;}
\{                          {fprintf(yyout,"CURL_OPEN : %s\n",yytext);return BLOCK_OPEN;}
\}                          {fprintf(yyout,"CURL_CLOSE : %s\n",yytext);return BLOCK_CLOSE;}
int                         {fprintf(yyout,"TYPE : %s\n",yytext);return INT_DYPE;}
char[ ]*\*                  {fprintf(yyout,"TYPE : %s\n",yytext);return STR_DTYPE;}
if                          {fprintf(yyout,"IF_CODE\n");return IF_CODE;}
else                        {fprintf(yyout,"ELSE_CODE\n");return ELSE_CODE;}
while                       {fprintf(yyout,"WHILE_CODE\n");return WHILE_CODE;}
return                      {fprintf(yyout,"RETURN_CODE\n");return RETURN_CODE;}
[0-9]+                      {fprintf(yyout,"CONSTANT : %s\n",yytext);yylval.number = atoi(yytext);return CONST;}
[A-Za-z][A-Za-z0-9_]*       {fprintf(yyout,"IDENTIFIER : %s\n",yytext);yylval.string = strdup(yytext);return IDEN;}
\"[^\n]*\"                  {fprintf(yyout,"STRING : %s\n",yytext);yylval.string = strdup(yytext);return STR;}
\'[^\n]\'                   {fprintf(yyout,"CHAR : %s\n",yytext);yylval.string = strdup(yytext);return CHAR;}
==                          {fprintf(yyout,"OPER : %s\n",yytext);return EQ_OP;}
\|\|                          {fprintf(yyout,"OPER : %s\n",yytext);return B_OR;}
\&\&                       {fprintf(yyout,"OPER : %s\n",yytext);return B_AND;}
\>                         {fprintf(yyout,"OPER : %s\n",yytext);return GT;}
\<                       {fprintf(yyout,"OPER : %s\n",yytext);return LT;}
!=                          {fprintf(yyout,"OPER : %s\n",yytext);return NEQ_OP;}
\+                          {fprintf(yyout,"OPER : %s\n",yytext);return ADD_OPER;}
\-                          {fprintf(yyout,"OPER : %s\n",yytext);return SUB_OPER;}
\*                          {fprintf(yyout,"OPER : %s\n",yytext);return MUL_OPER;}
\/                          {fprintf(yyout,"OPER : %s\n",yytext);return DIV_OPER;}
=                           {fprintf(yyout,"OPER : %s\n",yytext);return ASSIGN_OPER;}
[;]                         {fprintf(yyout,"SEMI_COL\n");return SEMI_COL;}
,                           {fprintf(yyout,"COMMA\n");return COMMA;}
\n                          {fprintf(yyout,"\n\n");line+=1;}
[ ]*                        /**/
.                           {fprintf(yyout,"\n\nMismatch found no valid token found in line %d. Skipping current character and searching next valid token \n\n",line);}
%%

int yywrap(){
    return 1;
}
