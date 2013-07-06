// Copyright (C) by Josh Blum. See LICENSE.txt for licensing information.

#ifndef INCLUDED_GRAS_CALLABLE_HPP
#define INCLUDED_GRAS_CALLABLE_HPP

#include <gras/gras.hpp>
#include <PMC/PMC.hpp>
#include <boost/shared_ptr.hpp>
#include <string>

namespace gras
{

/*!
 * The callable interface allows subclasses to export public methods,
 * but without actually exporting traditional library symbols.
 *
 * Callable handles the template magic so you don't have to:
 *  - registering subclass methods is simple and easy on the user.
 *  - users call registered methods with natural code aesthetics.
 *
 * Register a method (in the constructor of MyClass):
 * this->register_call("set_foo", &MyClass::set_foo);
 *
 * Call a method on a instance of MyClass:
 * my_class->x("set_foo", new_foo_val);
 *
 * Why x for the call method?
 *  - The "x" is short, one character of screen width.
 *  - The "x" looks like "*", which is commonly used.
 *  - The overloaded () operator sucks with pointers.
 *  - The overloaded () operator has template issues.
 */
struct GRAS_API Callable
{
    //! Default constructor
    Callable(void);

    //! Destructor (virtual for subclasses)
    virtual ~Callable(void);

    /*******************************************************************
     * Register API - don't look here, template magic, not helpful
     ******************************************************************/
    template <typename ClassType, typename ReturnType>
    void register_call(const std::string &key, ReturnType(ClassType::*fcn)(void));

    template <typename ClassType>
    void register_call(const std::string &key, void(ClassType::*fcn)(void));

    template <typename ClassType, typename ReturnType, typename Arg0>
    void register_call(const std::string &key, ReturnType(ClassType::*fcn)(const Arg0 &));

    template <typename ClassType, typename Arg0>
    void register_call(const std::string &key, void(ClassType::*fcn)(const Arg0 &));

    template <typename ClassType, typename ReturnType, typename Arg0, typename Arg1>
    void register_call(const std::string &key, ReturnType(ClassType::*fcn)(const Arg0 &, const Arg1 &));

    template <typename ClassType, typename Arg0, typename Arg1>
    void register_call(const std::string &key, void(ClassType::*fcn)(const Arg0 &, const Arg1 &));

    template <typename ClassType, typename ReturnType, typename Arg0, typename Arg1, typename Arg2>
    void register_call(const std::string &key, ReturnType(ClassType::*fcn)(const Arg0 &, const Arg1 &, const Arg2 &));

    template <typename ClassType, typename Arg0, typename Arg1, typename Arg2>
    void register_call(const std::string &key, void(ClassType::*fcn)(const Arg0 &, const Arg1 &, const Arg2 &));

    /*******************************************************************
     * Call API - don't look here, template magic, not helpful
     ******************************************************************/
    template <typename ReturnType>
    ReturnType x(const std::string &key);

    inline
    void x(const std::string &key);

    template <typename ReturnType, typename Arg0>
    ReturnType x(const std::string &key, const Arg0 &);

    template <typename Arg0>
    void x(const std::string &key, const Arg0 &);

    template <typename ReturnType, typename Arg0, typename Arg1>
    ReturnType x(const std::string &key, const Arg0 &, const Arg1 &);

    template <typename Arg0, typename Arg1>
    void x(const std::string &key, const Arg0 &, const Arg1 &);

    template <typename ReturnType, typename Arg0, typename Arg1, typename Arg2>
    ReturnType x(const std::string &key, const Arg0 &, const Arg1 &, const Arg2 &);

    template <typename Arg0, typename Arg1, typename Arg2>
    void x(const std::string &key, const Arg0 &, const Arg1 &, const Arg2 &);

    /*******************************************************************
     * Private registration hooks
     ******************************************************************/
    void _register_call(const std::string &, void *);
    virtual PMCC _handle_call(const std::string &, const PMCC *);
    boost::shared_ptr<void> _call_registry;
};

} //namespace gras

#include <gras/detail/callable.hpp>

#endif /*INCLUDED_GRAS_CALLABLE_HPP*/