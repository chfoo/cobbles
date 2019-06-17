# This GNU makefile is for compiling the dynamic library for targets that use FFI.
# For Linux, MacOS, and Windows with MingGW-w64 and Linux shell (such as Git Bash or Cygwin)

GCC ?= gcc
WIN_PREFIX ?= c:/
HL_INCLUDE ?= -I $(WIN_PREFIX)hl-1.9.0-win/include
INCLUDES ?= $(HL_INCLUDE) \
 	-I /usr/local/include \
 	-I /usr/include \
	-I $(WIN_PREFIX)include \
	-I /usr/local/include/freetype2 \
	-I /usr/include/freetype2 \
	-I $(WIN_PREFIX)include/freetype \
	-I /usr/local/include/harfbuzz \
	-I /usr/include/harfbuzz \
	-I $(WIN_PREFIX)include/harfbuzz
LINK_ICONV ?=
LINKER_FLAGS ?= -lfreetype -lharfbuzz $(LINK_ICONV) \
	-L /usr/local/lib \
	-L $(WIN_PREFIX)bin
EMCC ?= emcc
EMCONFIGURE ?= emconfigure
EMMAKE ?= emmake
OPTIMIZE_FLAGS ?= -O3 -DNDEBUG
CFLAGS ?=
FILES = cobbles.c cobbles_font.c cobbles_shaper.c

all: hdll js

.PHONY: all hdll js

hdll:
	mkdir -p ../out/hl/
	$(GCC) $(OPTIMIZE_FLAGS) $(CFLAGS) -D COBBLES_HL -fPIC -shared -std=c11 \
		-o ../out/hl/cobbles.hdll \
		$(FILES) $(INCLUDES) \
		$(LINKER_FLAGS)
	chmod -x ../out/hl/cobbles.hdll

js:
	mkdir -p ../out/js/
	$(EMCC) $(OPTIMIZE_FLAGS) -fPIC -std=c11 \
		-o ../out/js/cobbles.js $(FILES) \
		-s USE_FREETYPE=1 -s USE_HARFBUZZ=1 \
		-s MODULARIZE=1 -s 'EXPORT_NAME="cobbles_runtime"' \
		-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s EXPORTED_FUNCTIONS='[ "_cobbles_init", "_cobbles_destroy", "_cobbles_get_error", "_cobbles_guess_string_script", "_cobbles_open_font_file", "_cobbles_open_font_bytes", "_cobbles_font_close", "_cobbles_font_get_error",  "_cobbles_font_set_size", "_cobbles_font_get_glyph_id",  "_cobbles_font_load_glyph", "_cobbles_font_get_glyph_info", "_cobbles_font_get_glyph_bitmap", "_cobbles_shaper_init", "_cobbles_shaper_destroy", "_cobbles_shaper_get_error", "_cobbles_shaper_set_font", "_cobbles_shaper_set_text", "_cobbles_shaper_guess_text_properties", "_cobbles_shaper_set_direction", "_cobbles_shaper_set_script", "_cobbles_shaper_set_language", "_cobbles_shaper_set_direction", "_cobbles_shaper_shape", "_cobbles_shaper_get_glyph_count", "_cobbles_shaper_get_glyph_info" ]'
