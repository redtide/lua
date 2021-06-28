# The variable CMAKE_SYSTEM_PROCESSOR is incorrect on Visual studio...
# see https://gitlab.kitware.com/cmake/cmake/issues/15170
if(NOT LUA_SYSTEM_PROCESSOR)
    if(MSVC)
        set(LUA_SYSTEM_PROCESSOR "${MSVC_CXX_ARCHITECTURE_ID}")
    else()
        set(LUA_SYSTEM_PROCESSOR "${CMAKE_SYSTEM_PROCESSOR}")
    endif()
endif()

# Don't show build information when building a different project
function(show_build_info_if_needed)
    if(CMAKE_PROJECT_NAME STREQUAL "liblua")
        message(STATUS "
Project name:              ${PROJECT_NAME}
Build type:                ${CMAKE_BUILD_TYPE}
Build processor:           ${LUA_SYSTEM_PROCESSOR}
Install prefix:            ${CMAKE_INSTALL_PREFIX}

Build as shared library:   ${LUA_SHARED}
Build Lua interpreters:    ${LUA_BUILD_INTERPRETERS}
Use ReadLine:              ${LUA_USE_READLINE}

Compiler C debug flags:    ${CMAKE_C_FLAGS_DEBUG}
Compiler C release flags:  ${CMAKE_C_FLAGS_RELEASE}
Compiler C min size flags: ${CMAKE_C_FLAGS_MINSIZEREL}
")
    endif()
endfunction()
