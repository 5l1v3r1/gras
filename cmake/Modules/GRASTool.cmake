if(DEFINED __INCLUDED_GRAS_TOOL_CMAKE)
    return()
endif()
set(__INCLUDED_GRAS_TOOL_CMAKE TRUE)

########################################################################
## Set installation constants
## The GRAS_ROOT can be set via arg or environment variable
########################################################################
if(GRAS_ROOT)
    #its already set
elseif($ENV{GRAS_ROOT})
    set(GRAS_ROOT $ENV{GRAS_ROOT})
else()
    set(GRAS_ROOT "@CMAKE_INSTALL_PREFIX@")
endif()

########################################################################
## GRAS_TOOL cmake function - the swiss army knife for GRAS users
##
## Options:
## SOURCES - list of C++, Python, and GRC sources
## TARGET - project name, used for library, and install prefix
## COMPONENT - optional component name for cmake INSTALL function
########################################################################
function(GRAS_TOOL)

    include(CMakeParseArguments)
    cmake_parse_arguments(GRAS_TOOL "" "TARGET;COMPONENT" "SOURCES" ${ARGN})

    unset(GRAS_TOOL_CPP_SOURCES)
    unset(GRAS_TOOL_PY_SOURCES)
    unset(GRAS_TOOL_GRC_SOURCES)
    foreach(source ${GRAS_TOOL_SOURCES})
        get_filename_component(source_ext ${source} EXT)
        if ("${source_ext}" STREQUAL ".cpp")
            list(APPEND GRAS_TOOL_CPP_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".cxx")
            list(APPEND GRAS_TOOL_CPP_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".cc")
            list(APPEND GRAS_TOOL_CPP_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".c")
            list(APPEND GRAS_TOOL_CPP_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".py")
            list(APPEND GRAS_TOOL_PY_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".xml")
            list(APPEND GRAS_TOOL_GRC_SOURCES ${source})
        endif()
        if ("${source_ext}" STREQUAL ".yml")
            list(APPEND GRAS_TOOL_GRC_SOURCES ${source})
        endif()
    endforeach(source)

    #suffix install path for project name
    set(GRAS_TOOL_MOD_DIR lib@LIBSUFFIX@/gras/modules/${GRAS_TOOL_TARGET})
    set(GRAS_TOOL_GRC_DIR share/gnuradio/grc/blocks/${GRAS_TOOL_TARGET})
    set(GRAS_TOOL_PYTHON_DIR @GR_PYTHON_DIR@/gras/modules/${GRAS_TOOL_TARGET})

    #were to look for development files
    set(GRAS_TOOL_INCLUDE_DIR ${GRAS_ROOT}/include)
    set(GRAS_TOOL_LIBRARY_DIR ${GRAS_ROOT}/lib@LIBSUFFIX@)

    include_directories(${CMAKE_CURRENT_SOURCE_DIR})

    #locate PMC and GRAS includes
    if (NOT PMC_INCLUDE_DIRS)
        find_path(
            PMC_INCLUDE_DIRS
            NAMES PMC/PMC.hpp
            PATHS ${GRAS_TOOL_INCLUDE_DIR}
        )
    endif()
    include_directories(${PMC_INCLUDE_DIRS})
    if (NOT GRAS_INCLUDE_DIRS)
        find_path(
            GRAS_INCLUDE_DIRS
            NAMES gras/gras.hpp
            PATHS ${GRAS_TOOL_INCLUDE_DIR}
        )
    endif()
    include_directories(${GRAS_INCLUDE_DIRS})

    #locate PMC and GRAS libraries
    if (NOT PMC_LIBRARIES)
        find_library(
            PMC_LIBRARIES
            NAMES pmc
            PATHS ${GRAS_TOOL_LIBRARY_DIR}
        )
    endif()
    if (NOT GRAS_LIBRARIES)
        find_library(
            GRAS_LIBRARIES
            NAMES gras
            PATHS ${GRAS_TOOL_LIBRARY_DIR}
        )
    endif()

    #and boost includes as well
    if (NOT Boost_FOUND)
        find_package(Boost COMPONENTS)
        if (NOT Boost_FOUND)
            message(FATAL_ERROR "GRAS_TOOL could not find boost headers!")
        endif()
    endif()
    include_directories(${Boost_INCLUDE_DIRS})

    #build and install module to path
    if (GRAS_TOOL_CPP_SOURCES)
        add_library(${GRAS_TOOL_TARGET} MODULE ${GRAS_TOOL_CPP_SOURCES})
        target_link_libraries(${GRAS_TOOL_TARGET} ${PMC_LIBRARIES} ${GRAS_LIBRARIES})
        install(TARGETS ${GRAS_TOOL_TARGET}
            LIBRARY DESTINATION ${GRAS_TOOL_MOD_DIR} COMPONENT ${GRAS_TOOL_COMPONENT} # .so file
            ARCHIVE DESTINATION ${GRAS_TOOL_MOD_DIR} COMPONENT ${GRAS_TOOL_COMPONENT} # .lib file
            RUNTIME DESTINATION ${GRAS_TOOL_MOD_DIR} COMPONENT ${GRAS_TOOL_COMPONENT} # .dll file
        )
    endif()

    #python module install
    if (GRAS_TOOL_PY_SOURCES)
        install(
            FILES ${GRAS_TOOL_PY_SOURCES}
            DESTINATION ${GRAS_TOOL_PYTHON_DIR}
            COMPONENT ${GRAS_TOOL_COMPONENT}
        )
    endif()

    #install GRC files
    if (GRAS_TOOL_GRC_SOURCES)
        install(
            FILES ${GRAS_TOOL_GRC_SOURCES}
            DESTINATION ${GRAS_TOOL_GRC_DIR}
            COMPONENT ${GRAS_TOOL_COMPONENT}
        )
    endif()

    #create uninstall rule for this project
    add_custom_target(uninstall_${GRAS_TOOL_TARGET}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${GRAS_TOOL_MOD_DIR}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${GRAS_TOOL_GRC_DIR}
    )

endfunction(GRAS_TOOL)