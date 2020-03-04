%{
#include "syntax.tab.h"
  extern FILE* yyin;
  int yycolumn = 1;
  int err = 0;
  #define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; \
    yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng;
%}
%option yylineno
/*The first section:regular definitions*/
int [1-9]+[0-9]{0,31}|0
int8 0[0-9]{3}
int16 0x[0-9A-Fa-f]{0,4}
float 0|([1-9]+[0-9]*)\.[0-9]*
id [_a-zA-Z][_0-9a-zA-Z]*
relop >|<|>=|<=|==|!=
/*The second section:roles*/
%%
\/\*[^*]*\*+([^/*][^*]*\*+)*\/ {    }
"//".* { /*comment*/ }
struct {yylval.a=newLeaf("STRUCT",yylineno);return STRUCT;}
return {yylval.a=newLeaf("RETURN",yylineno);return RETURN;}
if {yylval.a=newLeaf("IF",yylineno);return IF;}
else {yylval.a=newLeaf("ELSE",yylineno);return ELSE;}
whiel {yylval.a=newLeaf("WHILE",yylineno);return WHILE;}
int|float {yylval.a=newLeaf("TYPE",yylineno);return TYPE;}
{int} { yylval.a=newLeaf("INT",yylineno);return INT; }
{float} { yylval.a=newLeaf("FLOAT",yylineno);return FLOAT; }
{id} { yylval.a=newLeaf("ID",yylineno);return ID; }
";" { yylval.a=newLeaf("SEMI",yylineno);return SEMI; }
"," { yylval.a=newLeaf("COMMA",yylineno);return COMMA; }
"=" { yylval.a=newLeaf("ASSIGNOP",yylineno);return ASSIGNOP; }
{relop} {yylval.a=newLeaf("RELOP",yylineno);return RELOP;}
"+" { yylval.a=newLeaf("PLUS",yylineno);return PLUS; }
"-" {yylval.a=newLeaf("MINUS",yylineno);return MINUS;}
"*" {yylval.a=newLeaf("STAR",yylineno);return STAR;}
"/" {yylval.a=newLeaf("DIV",yylineno);return DIV;}
"&&" {yylval.a=newLeaf("AND",yylineno);return AND;}
"||" {yylval.a=newLeaf("OR",yylineno);return OR;}
"." {yylval.a=newLeaf("DOT",yylineno);return DOT;}
"!" {yylval.a=newLeaf("NOT",yylineno);return NOT;}
"(" {yylval.a=newLeaf("LP",yylineno);return LP;}
")" {yylval.a=newLeaf("RP",yylineno);return RP;}
"[" {yylval.a=newLeaf("LB",yylineno);return LB;}
"]" {yylval.a=newLeaf("RB",yylineno);return RB;}
"{" {yylval.a=newLeaf("LC",yylineno);return LC;}
"}" {yylval.a=newLeaf("RC",yylineno);return RC;}
[ \t\r\f]+  {  /*whitespace*/  }
"\n" { yycolumn=1; }
. {
    fprintf(stderr,"Error type A at Line %d: Mysterious characters \"%s\".\n",yylineno,yytext);
    err = 1;
  }
%%
//单个文件扫描完毕退出，以免打印语法树相关信息
int yywrap() 
{
    if(err==1)
        exit(0);
    return 1;
}