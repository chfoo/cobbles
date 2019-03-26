# This GNU makefile is for compiling the dynamic library for targets that use FFI.
# For Linux, MacOS, and Windows with MingGW-w64 and Linux shell (such as Git Bash or Cygwin)

GCC ?= gcc
HL_INCLUDE ?= -I /usr/include -I hl-1.9.0-win/include
INCLUDES ?= $(HL_INCLUDE) -I /usr/include/freetype2 -I /usr/include/harfbuzz
EMCC ?= emcc
FILES = cobbles.c cobbles_font.c cobbles_shaper.c

all:

hdll:
	$(GCC) -O2 -D LIBHL_EXPORTS -fPIC -shared -std=c11 -m32 \
		-o ../out/hl/cobbles.hdll \
		$(FILES) $(INCLUDES)

js:
	$(EMCC) -O2 -fPIC -std=c11 \
		-o ../out/js/cobbles.js $(FILES) \
		-s USE_FREETYPE=1 -s USE_HARFBUZZ=1 \
		-s MODULARIZE=1 -s 'EXPORT_NAME="cobbles_runtime"' \
		-s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap"]' \
		-s EXPORTED_FUNCTIONS='[ "_cobbles_init", "_cobbles_destroy", "_cobbles_get_error", "_cobbles_open_font_file", "_cobbles_open_font_bytes", "_cobbles_font_close", "_cobbles_font_get_error",  "_cobbles_font_set_size", "_cobbles_font_get_glyph_id",  "_cobbles_font_load_glyph", "_cobbles_font_get_glyph_info", "_cobbles_font_get_glyph_bitmap", "_cobbles_shaper_init", "_cobbles_shaper_destroy", "_cobbles_shaper_get_error", "_cobbles_shaper_set_font", "_cobbles_shaper_set_text", "_cobbles_shaper_guess_text_properties", "_cobbles_shaper_set_direction", "_cobbles_shaper_set_script", "_cobbles_shaper_set_language", "_cobbles_shaper_set_direction", "_cobbles_shaper_shape", "_cobbles_shaper_get_glyph_count", "_cobbles_shaper_get_glyph_info" ]'

.PHONEY: all hdll js
