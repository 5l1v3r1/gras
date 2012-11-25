// Copyright (C) by Josh Blum. See LICENSE.txt for licensing information.

#ifndef INCLUDED_GRAS_ELEMENT_I
#define INCLUDED_GRAS_ELEMENT_I

%{
#include <gras/element.hpp>
%}

////////////////////////////////////////////////////////////////////////
// remove base class warning
////////////////////////////////////////////////////////////////////////
#pragma SWIG nowarn=401

////////////////////////////////////////////////////////////////////////
// http://www.swig.org/Doc2.0/Library.html#Library_stl_exceptions
////////////////////////////////////////////////////////////////////////
%include <exception.i>

%exception
{
    try{$action}
    catch (const std::exception& e)
    {SWIG_exception(SWIG_RuntimeError, e.what());}
}

////////////////////////////////////////////////////////////////////////
// Export swig element comprehension
////////////////////////////////////////////////////////////////////////
%include <std_string.i>
%include <gras/gras.hpp>
%import <gras/io_signature.i>
%include <gras/element.hpp>

////////////////////////////////////////////////////////////////////////
// Operator overloads for Element
////////////////////////////////////////////////////////////////////////
%extend gras::Element
{
    std::string __str__(void) const
    {
       return ($self)->to_string();
    }

    bool _equal(const Element &rhs) const
    {
        return ($self)->get() == rhs.get();
    }

    %insert("python")
    %{
        def __eq__(self, rhs):
            if not isinstance(rhs, Element): return False
            return self._equal(rhs)
    %}
}

#endif /*INCLUDED_GRAS_ELEMENT_I*/
