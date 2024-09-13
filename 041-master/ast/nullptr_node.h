#pragma once

#include <cdk/ast/expression_node.h>

namespace til {
    
    /**
    * Class for describing null pointer nodes.
    */
    class nullptr_node: public cdk::expression_node {
    public:
     nullptr_node(int lineno) :
          cdk::expression_node(lineno) {
     }

    public:
     void accept(basic_ast_visitor *sp, int level) { sp->do_nullptr_node(this, level); }
    
    };
} // til