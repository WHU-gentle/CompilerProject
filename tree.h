#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAXCHILD 10
extern int yylineno; /*[未定义的应用]行号*/
extern char *yytext; /*[未定义的应用]*/
extern int yylex(void);

/*grammer Tree node*/
struct Ast{
    int line;
    char *name;
    int n; //子节点个数
    union{
        char* type;
        int i;
        int f;
    };
    struct Ast* child[MAXCHILD]; //指向子节点的链表
};
struct Ast* newLeaf(char* s,int yyline);
struct Ast *newNode(char *s,int yyline,int num,struct Ast* arr[]);
struct Ast *newNode0(char *s,int num);
void printTree(struct Ast* r,int layer);