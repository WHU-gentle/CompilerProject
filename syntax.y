%{
  #include "tree.h"
  //#define YYERROR_VERBOSE
  void yyError(char* msg);
  void yyerror(const char* msg);
  int ERR = 0;
%}
%union{
struct Ast* a;
}
/*tokens 终结符 词法单元 尖括号定义其类型*/
%token <a> INT FLOAT ID
%token <a> SEMI COMMA ASSIGNOP RELOP
%token <a> PLUS MINUS STAR DIV
%token <a> AND OR
%token <a> DOT NOT TYPE
%token <a> LP RP LB RB LC RC
%token <a> STRUCT RETURN IF ELSE WHILE
/*语法单元值的类型说明*/
%type <a> Program ExtDefList ExtDef ExtDecList Specifier StructSpecifier 
%type <a> OptTag Tag VarDec FunDec VarList ParamDec CompSt StmtList Stmt DefList Def DecList Dec Exp Args
/*左结合，右结合，优先级设定*/
%right ASSIGNOP 
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV 
%right NOT
%left LP COMMA RP LB RB DOT
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
Program : ExtDefList {struct Ast* t[1]={$1};$$=newNode("Program",@1.first_line,1,t);if(ERR==0) printTree($$,0);}
        ;
ExtDefList : ExtDef ExtDefList {struct Ast* t[2]={$1,$2};$$=newNode("ExtDefList",@1.first_line,2,t);}
           | {$$=newNode0("ExtDefList",0);}
           ;
ExtDef : Specifier ExtDecList SEMI {struct Ast* t[3]={$1,$2,$3};$$=newNode("ExtDef",@1.first_line,3,t);}
       | Specifier SEMI {struct Ast* t[2]={$1,$2};$$=newNode("ExtDef",@1.first_line,2,t);}
       | Specifier FunDec CompSt {struct Ast* t[3]={$1,$2,$3};$$=newNode("ExtDef",@1.first_line,3,t);}
       ;
ExtDecList : VarDec {struct Ast* t[1]={$1};$$=newNode("ExtDecList",@1.first_line,1,t);}
           | VarDec COMMA ExtDecList {struct Ast* t[3]={$1,$2,$3};$$=newNode("ExtDecList",@1.first_line,3,t);}
           | VarDec error ExtDecList {yyError("text");}
           ;
           
Specifier : TYPE {struct Ast* t[1]={$1};$$=newNode("Specifier",@1.first_line,1,t);}
          | StructSpecifier {struct Ast* t[1]={$1};$$=newNode("Specifier",@1.first_line,1,t);}
          ;
StructSpecifier : STRUCT OptTag LC DefList RC {struct Ast* t[5]={$1,$2,$3,$4,$5};$$=newNode("StructSpecifier",@1.first_line,5,t);}
                | STRUCT Tag {struct Ast* t[2]={$1,$2};$$=newNode("StructSpecifier",@1.first_line,2,t);}
                ;
OptTag : ID {struct Ast* t[1]={$1};$$=newNode("OptTag",@1.first_line,1,t);}
       | {$$=newNode0("OptTag",0);}
       ;
Tag : ID {struct Ast* t[1]={$1};$$=newNode("Tag",@1.first_line,1,t);}
    ;
VarDec : ID {struct Ast* t[1]={$1};$$=newNode("VarDec",@1.first_line,1,t);}
       | VarDec LB INT RB {struct Ast* t[4]={$1,$2,$3,$4};$$=newNode("VarDec",@1.first_line,4,t);}
       | VarDec LB error RB { yyError("int");}
       ;
FunDec : ID LP VarList RP {struct Ast* t[4]={$1,$2,$3,$4};$$=newNode("FunDec",@1.first_line,4,t);}
       | ID LP RP {struct Ast* t[3]={$1,$2,$3};$$=newNode("FunDec",@1.first_line,3,t);}
       | ID LP error RP { yyError("VarList"); }
       ;
VarList : ParamDec COMMA VarList {struct Ast* t[3]={$1,$2,$3};$$=newNode("VarList",@1.first_line,3,t);}
        | ParamDec {struct Ast* t[1]={$1};$$=newNode("VarList",@1.first_line,1,t);}
        ;
ParamDec : Specifier VarDec {struct Ast* t[2]={$1,$2};$$=newNode("ParamDec",@1.first_line,2,t);}
         ;
CompSt : LC DefList StmtList RC {struct Ast* t[4]={$1,$2,$3,$4};$$=newNode("CompSt",@1.first_line,4,t);}
       ;
StmtList : Stmt StmtList {struct Ast* t[2]={$1,$2};$$=newNode("StmtList",@1.first_line,2,t);}
         | {$$=newNode0("StmtList",0);}
         ;
Stmt : Exp SEMI {struct Ast* t[2]={$1,$2};$$=newNode("Stmt",@1.first_line,2,t);}
     //| Exp error SEMI {yyerror("e");}
     | CompSt {struct Ast* t[1]={$1};$$=newNode("Stmt",@1.first_line,1,t);}
     | RETURN Exp SEMI {struct Ast* t[3]={$1,$2,$3};$$=newNode("Stmt",@1.first_line,3,t);}
     | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE {struct Ast* t[5]={$1,$2,$3,$4,$5};$$=newNode("Stmt",@1.first_line,5,t);}
     | IF LP Exp RP Stmt ELSE Stmt {struct Ast* t[7]={$1,$2,$3,$4,$5,$6,$7};$$=newNode("Stmt",@1.first_line,7,t);}
     | WHILE LP Exp RP Stmt  {struct Ast* t[5]={$1,$2,$3,$4,$5};$$=newNode("Stmt",@1.first_line,5,t);}
     | Exp error{yyError(" Missing \";\"");}
     ;
DefList : Def DefList {struct Ast* t[2]={$1,$2};$$=newNode("DefList",@1.first_line,2,t);}
        | {$$=newNode0("DefList",0);}
        ;
Def : Specifier DecList SEMI {struct Ast* t[3]={$1,$2,$3};$$=newNode("Def",@1.first_line,3,t);}
    | Specifier error SEMI {yyError("Syntax error");}
    | Specifier DecList error {yyError("missing \";\"");}
    ;
DecList : Dec {struct Ast* t[1]={$1};$$=newNode("DecList",@1.first_line,1,t);}
        | Dec COMMA DecList {struct Ast* t[3]={$1,$2,$3};$$=newNode("DecList",@1.first_line,3,t);}
        ;
Dec : VarDec {struct Ast* t[1]={$1};$$=newNode("Dec",@1.first_line,1,t);}
    | VarDec ASSIGNOP Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Dec",@1.first_line,3,t);}
    ;         
Exp : Exp ASSIGNOP Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp AND Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp OR Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp RELOP Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp PLUS Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp MINUS Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp STAR Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp DIV Exp {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | LP Exp RP {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | MINUS Exp {struct Ast* t[2]={$1,$2};$$=newNode("Exp",@1.first_line,2,t);}
    | NOT Exp {struct Ast* t[2]={$1,$2};$$=newNode("Exp",@1.first_line,2,t);}
    | ID LP Args RP {struct Ast* t[4]={$1,$2,$3,$4};$$=newNode("Exp",@1.first_line,4,t);}
    | ID LP RP {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | Exp LB Exp RB {struct Ast* t[4]={$1,$2,$3,$4};$$=newNode("Exp",@1.first_line,4,t);}
    | Exp DOT ID {struct Ast* t[3]={$1,$2,$3};$$=newNode("Exp",@1.first_line,3,t);}
    | ID {struct Ast* t[1]={$1};$$=newNode("Exp",@1.first_line,1,t);}
    | INT {struct Ast* t[1]={$1};$$=newNode("Exp",@1.first_line,1,t);}
    | FLOAT {struct Ast* t[1]={$1};$$=newNode("Exp",@1.first_line,1,t);}
    | Exp ASSIGNOP error {yyError("a");}
    | LP error RP {yyError("Syntax error");}
    | ID LP error RP {yyError("Syntax error");}
    | Exp LB error RB {yyError("Syntax error");}
    | Exp LB Exp error RB{yyError(" Missing \"]\"");}
    //| error ';' //{yyError(" Missing\"]\"");}
    ;
Args : Exp COMMA Args {struct Ast* t[3]={$1,$2,$3};$$=newNode("Args",@1.first_line,3,t);}
     | Exp {struct Ast* t[1]={$1};$$=newNode("Args",@1.first_line,1,t);}
     ;  
%%
void yyerror(const char* msg)
{
    //ERR = 1;
    //fprintf(stderr,"Error type B at Line %d:%s\n",yylineno,msg);
}
void yyError(char* msg)
{
    ERR = 1;
    fprintf(stderr,"Error type B at Line %d:%s.\n",yylineno,msg);
}