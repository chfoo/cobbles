#pragma once

#include <stdio.h>
#include <stdint.h>

#include <ft2build.h>
#include FT_FREETYPE_H

#include <hb.h>

#ifdef LIBHL_EXPORTS
    #include <hl.h>
    #define FUNC HL_PRIM
    #define FUNC_NAME(name) hl_##name
#else
    #define FUNC
    #define FUNC_NAME(name) name
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define COBBLES_UTF8 0
#define COBBLES_UTF16 1
#define COBBLES_UTF32 2
typedef int CobblesEncoding;

typedef struct {
    int error_code;
    FT_Library ft_library;
    CobblesEncoding encoding;
    char * encodingStringBuffer;
} Cobbles;

typedef struct {
    Cobbles * cobbles;
    int ft_error_code;
    FT_Face face;
} CobblesFont;

typedef struct {
    Cobbles * cobbles;
    int hb_error_code;
    hb_buffer_t * buffer;
    hb_font_t * font;
    unsigned int glyph_count;
    hb_glyph_info_t * glyph_infos;
    hb_glyph_position_t * glyph_positions;
} CobblesShaper;

// Array:
// 0 - int32 - Width in bytes of the bitmap buffer
// 4 - int32 - Height in bytes of the bitmap buffer
// 8 - int32 - bitmap_left
// 12 - int32 - bitmap_top
typedef uint8_t * CobblesFontGlyphInfoArray;

// Array:
// 0 - int32 - glyph ID
// 4 - int32  - text index
// 8 - int32 - offset_x
// 12 - int32 - offset_y
// 16 - int32 - advance_x
// 20 - int32 - advance_y
typedef uint8_t * CobblesShaperGlyphInfoArray;

FUNC Cobbles * FUNC_NAME(cobbles_init)(CobblesEncoding encoding);
FUNC void FUNC_NAME(cobbles_destroy)(Cobbles * cobbles);
FUNC int FUNC_NAME(cobbles_get_error)(Cobbles * cobbles);

FUNC CobblesFont * FUNC_NAME(cobbles_open_font_file)(Cobbles * cobbles, const char * path, int face_index);
FUNC CobblesFont * FUNC_NAME(cobbles_open_font_bytes)(Cobbles * cobbles, uint8_t * bytes, size_t length, int face_index);
FUNC void FUNC_NAME(cobbles_font_close)(CobblesFont * font);
FUNC int FUNC_NAME(cobbles_font_get_error)(CobblesFont * font);
FUNC void FUNC_NAME(cobbles_font_set_size)(CobblesFont * font, int width, int height, int horizontal_resolution, int vertical_resolution);
FUNC void FUNC_NAME(cobbles_font_load_glyph)(CobblesFont * font, int glyph_id);
FUNC int FUNC_NAME(cobbles_font_get_glyph_id)(CobblesFont * font, int code_point);
FUNC void FUNC_NAME(cobbles_font_get_glyph_info)(CobblesFont * font, CobblesFontGlyphInfoArray info);
FUNC void FUNC_NAME(cobbles_font_get_glyph_bitmap)(CobblesFont * font, uint8_t * buffer);
void _cobbles_font_dump(CobblesFont * font);


FUNC CobblesShaper * FUNC_NAME(cobbles_shaper_init)(Cobbles * cobbles);
FUNC void FUNC_NAME(cobbles_shaper_destroy)(CobblesShaper * shaper);
FUNC int FUNC_NAME(cobbles_shaper_get_error)(CobblesShaper * shaper);
FUNC void FUNC_NAME(cobbles_shaper_set_font)(CobblesShaper * shaper, CobblesFont * font);
FUNC void FUNC_NAME(cobbles_shaper_set_text)(CobblesShaper * shaper, const char * text);
FUNC void FUNC_NAME(cobbles_shaper_guess_text_properties)(CobblesShaper * shaper);
FUNC void FUNC_NAME(cobbles_shaper_set_direction)(CobblesShaper * shaper, const char * direction);
FUNC void FUNC_NAME(cobbles_shaper_set_script)(CobblesShaper * shaper, const char * script);
FUNC void FUNC_NAME(cobbles_shaper_set_language)(CobblesShaper * shaper, const char * langauge);
FUNC void FUNC_NAME(cobbles_shaper_shape)(CobblesShaper * shaper);
FUNC int FUNC_NAME(cobbles_shaper_get_glyph_count)(CobblesShaper * shaper);
FUNC void FUNC_NAME(cobbles_shaper_get_glyph_info)(CobblesShaper * shaper, int glyph_index, CobblesShaperGlyphInfoArray info);

// Private

int _cobbles_bytes_read_int(uint8_t * bytes, int index);
void _cobbles_bytes_write_int(uint8_t * bytes, int index, int value);
size_t _cobbles_string_length(Cobbles * cobbles, const char * input);
const char* _cobbles_encode_string(Cobbles * cobbles, const char * inputEncoding, const char * outputEncoding, const char * input);
const char* _cobbles_get_utf8_string(Cobbles * cobbles, const char * input);

#ifdef __cplusplus
}
#endif
