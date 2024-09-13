%{
//-- don't change *any* of these: if you do, you'll break the compiler.
#include <algorithm>
#include <memory>
#include <cstring>
#include <cdk/compiler.h>
#include <cdk/types/types.h>
#include ".auto/all_nodes.h"
#define LINE                         compiler->scanner()->lineno()
#define yylex()                      compiler->scanner()->scan()
#define yyerror(compiler, s)         compiler->scanner()->error(s)
//-- don't change *any* of these --- END!
%}

%parse-param {std::shared_ptr<cdk::compiler> compiler}

%union {
  //--- don't change *any* of these: if you do, you'll break the compiler.
  YYSTYPE() : type(cdk::primitive_type::create(0, cdk::TYPE_VOID)) {}
  ~YYSTYPE() {}
  YYSTYPE(const YYSTYPE &other) { *this = other; }
  YYSTYPE& operator=(const YYSTYPE &other) { type = other.type; return *this; }

  std::shared_ptr<cdk::basic_type> type;        /* expression type */
  //-- don't change *any* of these --- END!

  int                   i;          /* integer value */
  double                d;
  std::string          *s;          /* symbol name or string literal */
  cdk::basic_node      *node;       /* node pointer */
  cdk::sequence_node   *sequence;
  cdk::expression_node *expression; /* expression nodes */
  cdk::lvalue_node     *lvalue;
  std::vector<std::shared_ptr<cdk::basic_type>> *types;
};

%token <i> tINTEGER 
%token <d> tDOUBLE
%token <s> tIDENTIFIER tSTRING
%token tLOOP tIF tPRINT tREAD tBEGIN tEND tPROGRAM tPRINTLINE tRETURN tAND tOR 
%token tELSE tGE tLE tEQ tNE tPUBLIC tFORWARD tEXTERNAL tTYPEINT tPRIVATE tTYPESTRING
%token tSET tBLOCK tVAR tSTOP tSIZEOF tFUNCTION tVOID tTYPEDOUBLE tINDEX tOBJECT
%token tNULL tNEXT

%type <node> stmt program decl
%type <sequence> list exprs decls
%type <expression> expr fdecl
%type <lvalue> lval
%type <type> type var 
%type <i> qualifier
%type <types> types

%{
//-- The rules below will be included in yyparse, the main parsing function.
%}
%%

program : '(' tPROGRAM list ')'         { compiler->ast(new til::program_node(LINE, new cdk::sequence_node(LINE), $3, new cdk::sequence_node(LINE))); }
        | decls '(' tPROGRAM list ')'   { compiler->ast(new til::program_node(LINE, $1, new cdk::sequence_node(LINE), $4)); }
        | decls '(' tPROGRAM decls list ')'   { compiler->ast(new til::program_node(LINE, $1, $4, $5)); }
        | '(' tPROGRAM decls list ')'   { compiler->ast(new til::program_node(LINE, new cdk::sequence_node(LINE), $3, $4)); }
        ;

list : stmt                             { $$ = new cdk::sequence_node(LINE, $1); }
     | list stmt                        { $$ = new cdk::sequence_node(LINE, $2, $1); }
     ;

stmt : expr                             { $$ = new til::evaluation_node(LINE, $1); }
     | '(' tRETURN expr ')'             { $$ = new til::return_node(LINE, $3); }
     | '(' tPRINT exprs ')'             { $$ = new til::print_node(LINE, $3, false); }
     | '(' tPRINTLINE exprs ')'         { $$ = new til::print_node(LINE, $3, true); }
     | tREAD lval ';'                   { $$ = new til::read_node(LINE, $2); }
     | '(' tLOOP expr stmt ')'          { $$ = new til::loop_node(LINE, $3, $4); }
     | '(' tIF expr stmt ')'            { $$ = new til::if_node(LINE, $3, $4); }
     | '(' tIF expr stmt stmt ')'       { $$ = new til::if_else_node(LINE, $3, $4, $5); }
     | '(' tBLOCK decls list')'         { $$ = new til::block_node(LINE, $3, $4); }
     | '(' tBLOCK list')'               { $$ = new til::block_node(LINE, new cdk::sequence_node(LINE), $3); }
     | '(' tBLOCK decls ')'             { $$ = new til::block_node(LINE, $3, new cdk::sequence_node(LINE)); }
     | '(' tSTOP ')'                    { $$ = new til::stop_node(LINE); }
     | '(' tSTOP tINTEGER ')'           { $$ = new til::stop_node(LINE, $3); }
     | '(' tNEXT ')'                    { $$ = new til::next_node(LINE); }
     | '(' tNEXT tINTEGER ')'           { $$ = new til::next_node(LINE, $3); }
     ;

expr : tINTEGER                         { $$ = new cdk::integer_node(LINE, $1); }
     | tSTRING                          { $$ = new cdk::string_node(LINE, $1); }
     | tDOUBLE                          { $$ = new cdk::double_node(LINE, $1); }
     | '(' '-' expr ')'                 { $$ = new cdk::unary_minus_node(LINE, $3); }
     | '(' '+' expr ')'                 { $$ = new cdk::unary_plus_node(LINE, $3); }
     | '(' '+' expr expr ')'            { $$ = new cdk::add_node(LINE, $3, $4); }
     | '(' '-' expr expr ')'            { $$ = new cdk::sub_node(LINE, $3, $4); }
     | '(' '*' expr expr ')'            { $$ = new cdk::mul_node(LINE, $3, $4); }
     | '(' '/' expr expr ')'            { $$ = new cdk::div_node(LINE, $3, $4); }
     | '(' '%' expr expr ')'            { $$ = new cdk::mod_node(LINE, $3, $4); }
     | '(' '<' expr expr ')'            { $$ = new cdk::lt_node(LINE, $3, $4); }
     | '(' '>' expr expr ')'            { $$ = new cdk::gt_node(LINE, $3, $4); }
     | '(' tGE expr expr ')'            { $$ = new cdk::ge_node(LINE, $3, $4); }
     | '(' tLE expr expr ')'            { $$ = new cdk::le_node(LINE, $3, $4); }
     | '(' tNE expr expr ')'            { $$ = new cdk::ne_node(LINE, $3, $4); }
     | '(' tEQ expr expr ')'            { $$ = new cdk::eq_node(LINE, $3, $4); }
     | '(' tAND expr expr ')'           { $$ = new cdk::and_node(LINE, $3, $4); }
     | '(' tOR expr expr ')'            { $$ = new cdk::or_node(LINE, $3, $4); }
     | '(' '~' expr ')'                 { $$ = new cdk::not_node(LINE, $3); }
     | lval                             { $$ = new cdk::rvalue_node(LINE, $1); }
     | '(' tSET lval expr ')'           { $$ = new cdk::assignment_node(LINE, $3, $4); }
     | '(' tSIZEOF expr ')'             { $$ = new til::sizeof_node(LINE, $3); }
     | fdecl                            { $$ = $1; }
     | '(' expr ')'                     { $$ = new til::function_call_node(LINE, $2, new cdk::sequence_node(LINE)); }
     | '(' expr exprs ')'               { $$ = new til::function_call_node(LINE, $2, $3); }
     | '(' '@' exprs ')'                { $$ = new til::function_call_node(LINE, nullptr, $3); }
     | '(' '@' '(' ')' ')'              { $$ = new til::function_call_node(LINE, nullptr, new cdk::sequence_node(LINE)); } 
     | '(' tOBJECT expr ')'             { $$ = new til::object_node(LINE, $3); }
     | tNULL                            { $$ = new til::nullptr_node(LINE); }
     | '(' '?' lval ')'                 { $$ = new til::address_of_node(LINE, $3); }
     ;

lval : tIDENTIFIER                      { $$ = new cdk::variable_node(LINE, $1); }
     | '(' tINDEX expr expr ')'         { $$ = new til::index_node(LINE, $3, $4); } 
     ;
     
exprs : expr                            { $$ = new cdk::sequence_node(LINE, $1); }
      | exprs expr                      { $$ = new cdk::sequence_node(LINE, $2, $1); }
      ;

decl : '(' type tIDENTIFIER ')'         { $$ = new til::declaration_node(LINE, tPRIVATE, $2, *$3, nullptr); }
     | '(' type tIDENTIFIER expr ')'    { $$ = new til::declaration_node(LINE, tPRIVATE, $2, *$3, $4); }
     | '(' var tIDENTIFIER expr ')'     { $$ = new til::declaration_node(LINE, tPRIVATE, $2, *$3, $4); }
     | '(' qualifier type tIDENTIFIER ')' { $$ = new til::declaration_node(LINE, $2, $3, *$4, nullptr); }
     | '(' qualifier tIDENTIFIER expr')'   { $$ = new til::declaration_node(LINE, $2, cdk::primitive_type::create(0, cdk::TYPE_UNSPEC), *$3, $4); }
     | '(' qualifier type tIDENTIFIER expr ')' { $$ = new til::declaration_node(LINE, $2, $3, *$4, $5); }
     ;

decls : decl                            { $$ = new cdk::sequence_node(LINE, $1); }
      | decls decl                      { $$ = new cdk::sequence_node(LINE, $2, $1); }
      ;

type : tTYPEINT                         { $$ = cdk::primitive_type::create(4,cdk::TYPE_INT); }
     | tTYPESTRING                      { $$ = cdk::primitive_type::create(4,cdk::TYPE_STRING); }
     | tVOID                            { $$ = cdk::primitive_type::create(4,cdk::TYPE_VOID); } 
     | tTYPEDOUBLE                      { $$ = cdk::primitive_type::create(8,cdk::TYPE_DOUBLE); }
     | '(' type ')'                     { $$ = $2; }
     | '(' type '(' types ')' ')'       { auto output = new std::vector<std::shared_ptr<cdk::basic_type>>();
                                          output->push_back($2);
                                          $$ = cdk::functional_type::create(*$4, *output); } 
     | type'!'                          { $$ = cdk::reference_type::create(4, $1); }                       
     ; 

types : type                           { $$ = new std::vector<std::shared_ptr<cdk::basic_type>>(); $$->push_back($1); }
      | types type                     { $$ = $1; $$->push_back($2); }
      ; 

qualifier : tPUBLIC                     { $$ = tPUBLIC; }
          | tPRIVATE                    { $$ = tPRIVATE; }
          | tFORWARD                    { $$ = tFORWARD; }
          | tEXTERNAL                   { $$ = tEXTERNAL; }
          ;

var : tVAR                              { $$ = cdk::primitive_type::create(4,cdk::TYPE_UNSPEC); }        
    ;

fdecl : '(' tFUNCTION '(' type ')' decls list ')'   { $$ = new til::function_definition_node(LINE, $4, new cdk::sequence_node(LINE), new til::block_node(LINE, $6, $7)); }
      | '(' tFUNCTION '(' type ')' list ')'   { $$ = new til::function_definition_node(LINE, $4, new cdk::sequence_node(LINE), new til::block_node(LINE, new cdk::sequence_node(LINE), $6)); }
      | '(' tFUNCTION '(' type decls ')' decls list ')'   { $$ = new til::function_definition_node(LINE, $4, $5, new til::block_node(LINE, $7, $8)); }
      | '(' tFUNCTION '(' type decls ')' list ')'   { $$ = new til::function_definition_node(LINE, $4, $5, new til::block_node(LINE, new cdk::sequence_node(LINE), $7)); }
      ;              
%%
