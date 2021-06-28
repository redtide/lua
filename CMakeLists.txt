cmake_minimum_required(VERSION 3.16)
project(lua
    VERSION 5.2.4
    LANGUAGES C
    DESCRIPTION "Powerful lightweight programming language designed for extending applications"
    HOMEPAGE_URL "https://www.lua.org/"
)
option(LUA_USE_READLINE "Use readline library" OFF)
option(LUA_SHARED "Build the shared library" ON)
option(LUA_BUILD_INTERPRETERS "Build the lua and luac interpreter" ON)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
include(BuildType)
include(LuaConfig)

set(LUA_HEADERS
    "src/lua.h"
    "src/luaconf.h"
    "src/lualib.h"
    "src/lauxlib.h"
    "src/lua.hpp"
)
set(LUA_CORE_SRC
    "src/lapi.c"
    "src/lcode.c"
    "src/lctype.c"
    "src/ldebug.c"
    "src/ldo.c"
    "src/ldump.c"
    "src/lfunc.c"
    "src/lgc.c"
    "src/llex.c"
    "src/lmem.c"
    "src/lobject.c"
    "src/lopcodes.c"
    "src/lparser.c"
    "src/lstate.c"
    "src/lstring.c"
    "src/ltable.c"
    "src/ltm.c"
    "src/lundump.c"
    "src/lvm.c"
    "src/lzio.c"
)
set(LUA_LIB_SRC
    "src/lauxlib.c"
    "src/lbaselib.c"
    "src/lbitlib.c"
    "src/lcorolib.c"
    "src/ldblib.c"
    "src/liolib.c"
    "src/lmathlib.c"
    "src/loslib.c"
    "src/lstrlib.c"
    "src/ltablib.c"
    "src/loadlib.c"
    "src/linit.c"
)
set(LUA_CFLAGS LUA_COMPAT_ALL)
set(LUA_INCLUDE_DIRS "src")
set(LUA_LINK_LIBS "")

add_library(liblua STATIC
    ${LUA_CORE_SRC}
    ${LUA_LIB_SRC}
)

if(LUA_SHARED)
    add_library(liblua_shared SHARED
        ${LUA_CORE_SRC}
        ${LUA_LIB_SRC}
    )
endif()

if(LUA_BUILD_INTERPRETERS)
    add_executable(lua "src/lua.c")
    add_executable(luac "src/luac.c")
endif()


if(CMAKE_HOST_WIN32)
    list(APPEND LUA_CFLAGS LUA_BUILD_AS_DLL)
    set_target_properties(liblua PROPERTIES OUTPUT_NAME "lua52")

elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD" OR
       CMAKE_SYSTEM_NAME MATCHES "Linux" OR
       CMAKE_HOST_APPLE)

    find_package(Readline)
    if(READLINE_FOUND AND LUA_USE_READLINE)
        if(CMAKE_HOST_APPLE)
             list(APPEND LUA_CFLAGS LUA_USE_MACOSX)
        else()
             list(APPEND LUA_CFLAGS LUA_USE_LINUX)
        endif()
        list(APPEND LUA_INCLUDE_DIRS "${Readline_INCLUDE_DIR}")
        list(APPEND LUA_LINK_LIBS ${Readline_LIBRARY})
    else()
        # Enable all flags except LUA_USE_READLINE.
         list(APPEND LUA_CFLAGS
            LUA_USE_POSIX
            LUA_USE_DLOPEN
            LUA_USE_STRTODHEX
            LUA_USE_AFORMAT
            LUA_USE_LONGLONG
        )
    endif()
elseif(CMAKE_HOST_SOLARIS)
     list(APPEND LUA_CFLAGS LUA_USE_POSIX LUA_USE_DLOPEN _REENTRANT)
else()
    # TODO: if needed test for names OpenBSD, NetBSD, DragonflyBSD
    # CMAKE_(HOST_)SYSTEM_NAME is not well documented.
     list(APPEND LUA_CFLAGS LUA_USE_POSIX DLUA_USE_DLOPEN)
endif()

if(NOT CMAKE_HOST_WIN32)
    set_target_properties(liblua PROPERTIES OUTPUT_NAME "lua")
endif()

list(APPEND LUA_LINK_LIBS m dl)

target_link_libraries(liblua PUBLIC ${LUA_LINK_LIBS})
target_compile_definitions(liblua PUBLIC ${LUA_CFLAGS})
target_include_directories(liblua PRIVATE ${LUA_INCLUDE_DIRS})

if(LUA_SHARED)
    if(CMAKE_HOST_WIN32)
        set_target_properties(liblua_shared PROPERTIES OUTPUT_NAME "lua52")
    else()
        set_target_properties(liblua_shared PROPERTIES OUTPUT_NAME "lua")
    endif()
    target_link_libraries(liblua_shared PUBLIC ${LUA_LINK_LIBS})
    target_compile_definitions(liblua_shared PUBLIC ${LUA_CFLAGS})
    target_include_directories(liblua_shared PRIVATE ${LUA_INCLUDE_DIRS})
endif()

if(LUA_BUILD_INTERPRETERS)
    target_compile_definitions(lua PRIVATE ${LUA_CFLAGS})
    target_compile_definitions(luac PRIVATE ${LUA_CFLAGS})
    target_link_libraries(lua PRIVATE ${LUA_LINK_LIBS} liblua)
    target_link_libraries(luac PRIVATE ${LUA_LINK_LIBS} liblua)
endif()

# TODO: MSVC installation
if(NOT MSVC)
    include(GNUInstallDirs)

    install(FILES ${LUA_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

    if(LUA_SHARED)
        install(TARGETS liblua_shared DESTINATION "${CMAKE_INSTALL_LIBDIR}")
        set(LUA_PKGCONFIG_FILE
            lua${CMAKE_PROJECT_VERSION_MAJOR}.${CMAKE_PROJECT_VERSION_MINOR}.pc
        )
        configure_file(${PROJECT_SOURCE_DIR}/cmake/lua.pc.in
            ${LUA_PKGCONFIG_FILE} @ONLY
        )
        install(FILES ${CMAKE_BINARY_DIR}/${LUA_PKGCONFIG_FILE}
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
        )
    endif()

    if(LUA_BUILD_INTERPRETERS)
        install(TARGETS lua luac DESTINATION "${CMAKE_INSTALL_BINDIR}")
    endif()
endif()

show_build_info_if_needed()
