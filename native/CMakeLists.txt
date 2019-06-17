cmake_minimum_required(VERSION 3.13)
project(cobbles)

set(FREETYPE_INCLUDE_PATH "/usr/include/freetype2" CACHE PATH "Include directory for Freetype (*.h)")
set(FREETYPE_LIB_PATH "/usr/lib/" CACHE PATH "Link directory for Freetype (*.{so,dll,dynlib})")
set(HARFBUZZ_INCLUDE_PATH "/usr/include/harfbuzz" CACHE PATH "Include directory for Harfbuzz (*.h)")
set(HARFBUZZ_LIB_PATH "/usr/lib/" CACHE PATH "Link directory for Harfbuzz (*.{so,dll,dynlib})")

add_library(cobbles_hdll SHARED cobbles.c cobbles_font.c cobbles_shaper.c)
target_include_directories(cobbles_hdll BEFORE PRIVATE "${FREETYPE_INCLUDE_PATH}")
target_link_directories(cobbles_hdll BEFORE PRIVATE "${FREETYPE_LIB_PATH}")
target_include_directories(cobbles_hdll BEFORE PRIVATE "${HARFBUZZ_INCLUDE_PATH}")
target_link_directories(cobbles_hdll BEFORE PRIVATE "${HARFBUZZ_INCLUDE_PATH}")
target_link_libraries(cobbles_hdll freetype harfbuzz)

if(MSVC)
    target_compile_options(cobbles_hdll PRIVATE /W4)
else()
    target_compile_options(cobbles_hdll PRIVATE -Wall -Wextra -pedantic)
endif()

set_target_properties(cobbles_hdll PROPERTIES
    PREFIX ""
    OUTPUT_NAME "cobbles"
    SUFFIX ".hdll"
    C_STANDARD 99
)
target_compile_definitions(cobbles_hdll PRIVATE COBBLES_HL)
