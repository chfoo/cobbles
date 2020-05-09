add_executable(test_hlc "${CMAKE_SOURCE_DIR}/out/hl/test/test.c")

if(WIN32)
    find_library(HASHLINK_LIBRARY_PATH "libhl")
else()
    find_library(HASHLINK_LIBRARY_PATH "hl")
endif()

find_library(COBBLETEXT_LIBRARY_PATH "cobbletext")

target_include_directories(test_hlc PRIVATE
    "${CMAKE_SOURCE_DIR}/out/hl/test/")
target_link_libraries(test_hlc PRIVATE
    "${HASHLINK_LIBRARY_PATH}"
    "${COBBLETEXT_LIBRARY_PATH}"
    cobbles_hdll)

set_property(TARGET test_hlc PROPERTY C_STANDARD 11)

install(TARGETS test_hlc DESTINATION bin)
