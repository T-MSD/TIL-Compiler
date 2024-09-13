#pragma once

#include <cdk/ast/unary_operation_node.h>

namespace til {

  /**
   * Class for describing object allocation nodes.
   */
  class object_node: public cdk::unary_operation_node {
  public:
    inline object_node(int lineno, cdk::expression_node *argument) :
        cdk::unary_operation_node(lineno, argument) {
    }

  public:
    void accept(basic_ast_visitor *sp, int level) {
      sp->do_object_node(this, level);
    }

  };

} // til