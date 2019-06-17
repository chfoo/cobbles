#include "cobbles.h"

#include <assert.h>
#include <errno.h>
#include <stdlib.h>

CobblesFont * cobbles_open_font_file(Cobbles * cobbles, const char * path, int face_index) {
    assert(cobbles != NULL);
    assert(path != NULL);
    CobblesFont * font = calloc(1, sizeof(CobblesFont));

    if (font == NULL) {
        _cobbles_debug_print("cobbles_open_font_file calloc error %d\n", errno);
        return NULL;
    }

    font->cobbles = cobbles;
    path = _cobbles_get_utf8_string(cobbles, path);
    font->ft_error_code = FT_New_Face(cobbles->ft_library, path, face_index, &(font->face));

    if (font->ft_error_code != 0) {
        _cobbles_debug_print("FT_New_Face error %d\n", font->ft_error_code);
    }

    #ifdef COBBLES_DEBUG
    _cobbles_font_dump(font);
    #endif

    return font;
}

CobblesFont * cobbles_open_font_bytes(Cobbles * cobbles, uint8_t * bytes, size_t length, int face_index) {
    assert(cobbles != NULL);
    assert(bytes != NULL);
    CobblesFont * font = calloc(1, sizeof(CobblesFont));

    if (font == NULL) {
        _cobbles_debug_print("cobbles_open_font_bytes calloc error %d\n", errno);
        return NULL;
    }

    font->cobbles = cobbles;
    font->ft_error_code = FT_New_Memory_Face(cobbles->ft_library, bytes, length, face_index, &(font->face));

    if (font->ft_error_code != 0) {
        _cobbles_debug_print("FT_New_Memory_Face error %d\n", font->ft_error_code);
    }

    #ifdef COBBLES_DEBUG
    _cobbles_font_dump(font);
    #endif

    return font;
}

void cobbles_font_close(CobblesFont * font) {
    assert(font != NULL);

    if (font->face != NULL) {
        FT_Done_Face(font->face);
    }

    free(font);
}

int cobbles_font_get_error(CobblesFont * font) {
    assert(font != NULL);
    return font->ft_error_code;
}

void cobbles_font_set_size(CobblesFont * font, int width, int height, int horizontal_resolution, int vertical_resolution) {
    assert(font != NULL);
    font->ft_error_code = FT_Set_Char_Size(font->face, width, height, horizontal_resolution, vertical_resolution);
}

int cobbles_font_get_glyph_id(CobblesFont * font, int code_point) {
    assert(font != NULL);
    return FT_Get_Char_Index(font->face, code_point);
}

void cobbles_font_load_glyph(CobblesFont * font, int glyph_id) {
    assert(font != NULL);
    font->ft_error_code = FT_Load_Glyph(font->face, glyph_id, FT_LOAD_RENDER);
}

void cobbles_font_get_glyph_info(CobblesFont * font, CobblesFontGlyphInfoArray info) {
    assert(font != NULL);
    assert(info != NULL);

    _cobbles_bytes_write_int(info, 0, font->face->glyph->bitmap.width);
    _cobbles_bytes_write_int(info, 4, font->face->glyph->bitmap.rows);
    _cobbles_bytes_write_int(info, 8, font->face->glyph->bitmap_left);
    _cobbles_bytes_write_int(info, 12, font->face->glyph->bitmap_top);
}

void cobbles_font_get_glyph_bitmap(CobblesFont * font, uint8_t * buffer) {
    assert(font != NULL);
    assert(buffer != NULL);
    int length = font->face->glyph->bitmap.width * font->face->glyph->bitmap.rows;

    if (length < 0) {
        return;
    }

    memcpy(buffer, font->face->glyph->bitmap.buffer, length);
}

void _cobbles_font_dump(CobblesFont * font) {
    FT_ULong charcode;
    FT_UInt gindex;

    charcode = FT_Get_First_Char(font->face, &gindex);
    while (gindex != 0) {
        printf("charcode %lx index %d\n", charcode, gindex);
        charcode = FT_Get_Next_Char(font->face, charcode, &gindex);
    }
}

#ifdef COBBLES_HL
DEFINE_PRIM(_ABSTRACT(CobblesFont), cobbles_open_font_file, _ABSTRACT(Cobbles) _BYTES _I32);
DEFINE_PRIM(_ABSTRACT(CobblesFont), cobbles_open_font_bytes, _ABSTRACT(Cobbles) _BYTES _I32 _I32);
DEFINE_PRIM(_I32, cobbles_font_get_error, _ABSTRACT(CobblesFont));
DEFINE_PRIM(_VOID, cobbles_font_close, _ABSTRACT(CobblesFont));
DEFINE_PRIM(_VOID, cobbles_font_set_size, _ABSTRACT(CobblesFont) _I32 _I32 _I32 _I32);
DEFINE_PRIM(_I32, cobbles_font_get_glyph_id, _ABSTRACT(CobblesFont) _I32);
DEFINE_PRIM(_VOID, cobbles_font_load_glyph, _ABSTRACT(CobblesFont) _I32);
DEFINE_PRIM(_VOID, cobbles_font_get_glyph_info, _ABSTRACT(CobblesFont) _BYTES);
DEFINE_PRIM(_VOID, cobbles_font_get_glyph_bitmap, _ABSTRACT(CobblesFont) _BYTES);
#endif
