#pragma once

#include <cdk/ast/basic_node.h>

namespace til {

  /**
   * Class for describing program nodes.
   */
  class program_node : public cdk::basic_node {
    cdk::sequence_node *_declarations;
    cdk::basic_node *_statements;
    cdk::sequence_node *_declarations1;

  public:
    program_node(int lineno, cdk::sequence_node *declarations, cdk::basic_node *statements, cdk::sequence_node *declarations1) :
        cdk::basic_node(lineno), _declarations(declarations), _statements(statements), _declarations1(declarations1) {
    }

    cdk::sequence_node *declarations() { return _declarations; }

    cdk::basic_node *statements() { return _statements; }

    cdk::sequence_node *declarations1() { return _declarations1; }

    void accept(basic_ast_visitor *sp, int level) { sp->do_program_node(this, level); }

  };

} // til
