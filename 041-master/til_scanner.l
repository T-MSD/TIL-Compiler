%option c++ prefix="til_scanner_" outfile="til_scanner.cpp"
%option stack noyywrap yylineno 8bit debug
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "til_parser.tab.h"

// don't change this
#define yyerror LexerError
%}
EXP [Ee][+-]?[0-9]+
%x X_STRING X_COMMENT
%%
  yydebug=1; set_debug(1);

";".*                 ; /* ignore comments */

">="                   return tGE; 
"<="                   return tLE; 
"=="                   return tEQ; 
"!="                   return tNE; 

"set"                  return tSET;
"loop"                 return tLOOP; 
"if"                   return tIF; 
"else"                 return tELSE; 
"print"                return tPRINT; 
"read"                 return tREAD; 
"begin"                return tBEGIN; 
"end"                  return tEND; 
"program"              return tPROGRAM;
"println"              return tPRINTLINE;
"return"               return tRETURN;
"&&"                   return tAND;
"||"                   return tOR;
"int"                  return tTYPEINT;
"double"               return tTYPEDOUBLE;
"string"               return tTYPESTRING;
"block"                return tBLOCK;
"stop"                 return tSTOP;
"sizeof"               return tSIZEOF;
"function"             return tFUNCTION;

"public"               return tPUBLIC;
"forward"              return tFORWARD;
"external"             return tEXTERNAL;
"private"              return tPRIVATE;
"var"                  return tVAR;
"void"                 return tVOID;
"object"               return tOBJECT;
"index"                return tINDEX;
"null"                 return tNULL;
"next"                 return tNEXT;

[A-Za-z][A-Za-z0-9_]*  yylval.s = new std::string(yytext); return tIDENTIFIER;

\"                     yy_push_state(X_STRING); yylval.s = new std::string("");
<X_STRING>\"           yy_pop_state(); return tSTRING;
<X_STRING>\\\"         *yylval.s += yytext + 1;
<X_STRING>.            *yylval.s += yytext;
<X_STRING>\n           yyerror("newline in string");

<X_STRING>\\t          *yylval.s += '\t';
<X_STRING>\\n          *yylval.s += '\n';
<X_STRING>\\r          *yylval.s += '\r';
<X_STRING>\\[0-7]{1,3} *yylval.s += (char)strtoul(yytext + 1, NULL, 8);

0x([0-9]|[a-f]|[A-F])+ yylval.i = strtoul(yytext, NULL, 16); return tINTEGER;

"/*"                   yy_push_state(X_COMMENT);
<X_COMMENT>"*/"        yy_pop_state();
<X_COMMENT>.           ;

[0-9]+                 yylval.i = strtol(yytext, nullptr, 10); return tINTEGER;       
[0-9]*\.[0-9]+{EXP}?   yylval.d = std::stod(yytext); return tDOUBLE;
[0-9]+\.[0-9]*{EXP}?   yylval.d = std::stod(yytext); return tDOUBLE;
[0-9]+{EXP}            yylval.d = std::stod(yytext); return tDOUBLE;

[-()<>=+*/%;{}~&.|@!?]       return *yytext;

[ \t\n\r]+             ; /* ignore whitespace */

.                      yyerror("Unknown character");

%%
