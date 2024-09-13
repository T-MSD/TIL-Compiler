#pragma once

#include <string>
#include <memory>
#include <cdk/types/basic_type.h>

namespace til {

  class symbol {
    std::shared_ptr<cdk::basic_type> _type;
    std::string _name;
    bool _global;
    int _offset;

  public:
    symbol(std::shared_ptr<cdk::basic_type> type, const std::string &name) :
        _type(type), _name(name) {
    }

    virtual ~symbol() {
      // EMPTY
    }

    std::shared_ptr<cdk::basic_type> type() const {
      return _type;
    }
    bool is_typed(cdk::typename_type name) const {
      return _type->name() == name;
    }
    const std::string &name() const {
      return _name;
    }
    bool is_global() const {
      return _global;
    }
    void set_global(bool global) {
      _global = global;
    }
    int offset() const {
      return _offset;
    }
    void set_offset(int offset) {
      _offset = offset;
    }
  };

} // til
