# first look in pcre-$version or pcre subdirs
if (PCRE2_SOURCE)
    # either provided on cmdline or we've seen it already
    set (PCRE2_BUILD_SOURCE TRUE)
elseif (EXISTS ${PROJECT_SOURCE_DIR}/pcre2-${PCRE2_REQUIRED_VERSION})
    set (PCRE2_SOURCE ${PROJECT_SOURCE_DIR}/pcre2-${PCRE2_REQUIRED_VERSION})
    set (PCRE2_BUILD_SOURCE TRUE)
elseif (EXISTS ${PROJECT_SOURCE_DIR}/pcre2)
    set (PCRE2_SOURCE ${PROJECT_SOURCE_DIR}/pcre2)
    set (PCRE2_BUILD_SOURCE TRUE)
endif()

if (PCRE2_BUILD_SOURCE)
    if (NOT IS_ABSOLUTE ${PCRE2_SOURCE})
        set(PCRE2_SOURCE "${CMAKE_BINARY_DIR}/${PCRE2_SOURCE}")
    endif ()
    set (saved_INCLUDES "${CMAKE_REQUIRED_INCLUDES}")
    set (CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES} ${PCRE2_SOURCE}")

    if (PCRE2_CHECKED)
        set(PCRE2_INCLUDE_DIRS ${PCRE2_SOURCE} ${PROJECT_BINARY_DIR}/pcre2)
        set(PCRE2_LDFLAGS -L"${LIBDIR}" -lpcre2)

        # already processed this file and set up pcre building
        return()
    endif ()

    # first, check version number
    CHECK_C_SOURCE_COMPILES("#include <pcre2.h>
    #if PCRE2_MAJOR != ${PCRE2_REQUIRED_MAJOR_VERSION} || PCRE2_MINOR < ${PCRE2_REQUIRED_MINOR_VERSION}
    #error Incorrect pcre2 version
    #endif
    main() {}" CORRECT_PCRE2_VERSION)
    set (CMAKE_REQUIRED_INCLUDES "${saved_INCLUDES}")

    if (NOT CORRECT_PCRE2_VERSION)
        unset(CORRECT_PCRE2_VERSION CACHE)
        message(STATUS "Incorrect version of pcre2 - version ${PCRE2_REQUIRED_VERSION} or above is required")
        return ()
    else()
        message(STATUS "PCRE version ${PCRE2_REQUIRED_VERSION} or above - building from source.")
    endif()

    # PCRE compile options
    option(PCRE2_BUILD_PCRECPP OFF)
    option(PCRE2_BUILD_PCREGREP OFF)
    option(PCRE2_SHOW_REPORT OFF)
    add_definitions(-DPCRE2_CODE_UNIT_WIDTH=8)
    set(PCRE2_SUPPORT_UNICODE_PROPERTIES ON CACHE BOOL "Build pcre2 with unicode")
    add_subdirectory(${PCRE2_SOURCE} ${PROJECT_BINARY_DIR}/pcre2 EXCLUDE_FROM_ALL)
    set(PCRE2_INCLUDE_DIRS ${PCRE2_SOURCE} ${PROJECT_BINARY_DIR}/pcre2)
    set(PCRE2_LDFLAGS -L"${LIBDIR}" -lpcre2)
else ()
    # pkgconf should save us
    find_package(PkgConfig)
    pkg_check_modules(PCRE2 libpcre2-posix>=${PCRE2_REQUIRED_VERSION})
    if (PCRE2_FOUND)
        add_definitions(-DPCRE2_CODE_UNIT_WIDTH=8)
        set(CORRECT_PCRE2_VERSION TRUE)
        message(STATUS "PCRE2 version ${PCRE2_REQUIRED_VERSION} or above")
    else ()
        message(STATUS "PCRE2 version ${PCRE2_REQUIRED_VERSION} or above not found")
        return ()
    endif ()
endif (PCRE2_BUILD_SOURCE)
