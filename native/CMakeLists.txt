add_library(cobbles_hdll SHARED cobbles_hl.c)

find_path(COBBLETEXT_INCLUDE_PATH "cobbletext/cobbletext.h")
find_library(COBBLETEXT_LIBRARY_PATH "cobbletext")

find_path(HASHLINK_INCLUDE_PATH "hl.h")

if(WIN32)
    find_library(HASHLINK_LIBRARY_PATH "libhl")
else()
    find_library(HASHLINK_LIBRARY_PATH "hl")
endif()

target_include_directories(cobbles_hdll PRIVATE
    "${COBBLETEXT_INCLUDE_PATH}"
    "${HASHLINK_INCLUDE_PATH}")
target_link_libraries(cobbles_hdll PRIVATE
    "${COBBLETEXT_LIBRARY_PATH}"
    "${HASHLINK_LIBRARY_PATH}")

if(MSVC)
    target_compile_options(cobbles_hdll PRIVATE /W4)
else()
    target_compile_options(cobbles_hdll PRIVATE -Wall -Wextra -pedantic)
endif()

include(CheckIncludeFile)
CHECK_INCLUDE_FILE("uchar.h" HAS_UCHAR)

if(NOT HAS_UCHAR)
    target_compile_definitions(cobbles_hdll COBBLETEXT_NO_UCHAR_H=1)
endif()

set_target_properties(cobbles_hdll PROPERTIES
    PREFIX ""
    OUTPUT_NAME "cobbles"
    SUFFIX ".hdll"
    C_STANDARD 99
)
target_compile_definitions(cobbles_hdll PRIVATE COBBLES_HL)

install(TARGETS cobbles_hdll DESTINATION lib)
