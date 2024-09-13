#pragma once

#include <string>
#include <cdk/ast/typed_node.h>
#include <cdk/ast/sequence_node.h>
#include "ast/block_node.h"

namespace til {

  /**
   * Class for describing function definitions.
   */
  class function_definition_node: public cdk::expression_node {
    cdk::sequence_node *_args;
    til::block_node *_block;


  public:
    function_definition_node(int lineno, cdk::sequence_node *args,
                             til::block_node *block) :
        cdk::expression_node(lineno), _args(
            args), _block(block) {
      type(cdk::primitive_type::create(0, cdk::TYPE_VOID));
    }

    function_definition_node(int lineno, std::shared_ptr<cdk::basic_type> funType,
                             cdk::sequence_node *args, til::block_node *block) :
        cdk::expression_node(lineno), _args(args), _block(block) {
      type(funType);
    }

  public:
    cdk::sequence_node *arguments() {
      return _args;
    }
    til::block_node *block() {
      return _block;
    }
    cdk::typed_node* argument(size_t ax) {
      return dynamic_cast<cdk::typed_node*>(_args->node(ax));
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_definition_node(this, level);
    }

  };

} // til
