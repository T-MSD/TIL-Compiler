#pragma once

#include <string>
#include <cdk/ast/basic_node.h>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/nil_node.h>
#include <cdk/ast/expression_node.h>


namespace til {

    /**
   * Class for describing function calls.
   */
  class function_call_node: public cdk::expression_node {
    cdk::expression_node *_func;
    cdk::sequence_node *_args;

  public:

    function_call_node(int lineno, cdk::expression_node *func) :
        cdk::expression_node(lineno), _func(func), _args(new cdk::sequence_node(lineno)) {
    }

    function_call_node(int lineno, cdk::expression_node  *func, cdk::sequence_node *args) :
        cdk::expression_node(lineno), _func(func), _args(args) {
    }


  public:
    cdk::expression_node *argument(size_t ix) {
      return dynamic_cast<cdk::expression_node*>(_args->node(ix));
    }
    cdk::expression_node *func() {
      return _func;
    }
    cdk::sequence_node *arguments() {
      return _args;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_call_node(this, level);
    }

  };

} // til
