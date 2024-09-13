#pragma once

#include <cdk/ast/basic_node.h>

namespace til {

  /**
   * Class for describing next nodes.
   */
  class next_node: public cdk::basic_node {
    int _level;

  public:
    inline next_node(int lineno) :
        cdk::basic_node(lineno) {
    }
    inline next_node(int lineno, int level) :
        cdk::basic_node(lineno), _level(level) {
    }

  public:
    inline int level() {
      return _level;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_next_node(this, level);
    }

  };

} // til