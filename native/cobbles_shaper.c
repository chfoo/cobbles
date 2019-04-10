#include "cobbles.h"
#include <string.h>
#include <assert.h>
#include <hb-ft.h>

CobblesShaper * FUNC_NAME(cobbles_shaper_init)(Cobbles * cobbles) {
    CobblesShaper * shaper = calloc(1, sizeof(CobblesShaper));

    if (shaper == NULL) {
        return NULL;
    }

    shaper->buffer = hb_buffer_create();
    shaper->cobbles = cobbles;

    if (!hb_buffer_allocation_successful(shaper->buffer)) {
        shaper->hb_error_code = 1;
    } else {
        shaper->hb_error_code = 0;
    }

    return shaper;
}

void FUNC_NAME(cobbles_shaper_destroy)(CobblesShaper * shaper) {
    if (shaper->buffer != NULL) {
        hb_buffer_destroy(shaper->buffer);
    }

    if (shaper->font != NULL) {
        hb_font_destroy(shaper->font);
    }

    free(shaper);
}

int FUNC_NAME(cobbles_shaper_get_error)(CobblesShaper * shaper) {
    return shaper->hb_error_code;
}

void FUNC_NAME(cobbles_shaper_set_font)(CobblesShaper * shaper, CobblesFont * font) {
    if (shaper->font != NULL) {
        hb_font_destroy(shaper->font);
    }

    shaper->font = hb_ft_font_create_referenced(font->face);

    // Set it back to defaults because not sure why
    // https://github.com/harfbuzz/harfbuzz/issues/312
    hb_ft_font_set_load_flags(shaper->font, FT_LOAD_DEFAULT);
}

void FUNC_NAME(cobbles_shaper_set_text)(CobblesShaper * shaper, const char * text, int encoding) {
    hb_buffer_clear_contents(shaper->buffer);

    if (encoding == 0) {
        encoding = shaper->cobbles->encoding;
    }

    switch (encoding) {
        case COBBLES_UTF16:
            // FIXME: check if endian is correct
            hb_buffer_add_utf16(shaper->buffer, (const uint16_t*) text, -1, 0, -1);
            break;
        case COBBLES_UTF32:
            hb_buffer_add_utf32(shaper->buffer, (const uint32_t*) text, -1, 0, -1);
            break;
        default:
            hb_buffer_add_utf8(shaper->buffer, text, -1, 0, -1);
            break;
    }
}

void cobbles_shaper_set_text_binary(CobblesShaper * shaper, const uint8_t * text, int encoding) {
    FUNC_NAME(cobbles_shaper_set_text)(shaper, (const char *) text, encoding);
}

void FUNC_NAME(cobbles_shaper_guess_text_properties)(CobblesShaper * shaper) {
    hb_buffer_guess_segment_properties(shaper->buffer);
}

void FUNC_NAME(cobbles_shaper_set_direction)(CobblesShaper * shaper, const char * direction) {
    direction = _cobbles_get_utf8_string(shaper->cobbles, direction);
    hb_buffer_set_direction(shaper->buffer,
        hb_direction_from_string(direction, -1));
}

void FUNC_NAME(cobbles_shaper_set_script)(CobblesShaper * shaper, const char * script) {
    script = _cobbles_get_utf8_string(shaper->cobbles, script);
    hb_buffer_set_script(shaper->buffer,
        hb_script_from_string(script, -1));
}

void FUNC_NAME(cobbles_shaper_set_language)(CobblesShaper * shaper, const char * language) {
    language = _cobbles_get_utf8_string(shaper->cobbles, language);
    hb_buffer_set_language(shaper->buffer,
        hb_language_from_string(language, -1));
}

void FUNC_NAME(cobbles_shaper_shape)(CobblesShaper * shaper) {
    assert(shaper->buffer != NULL);
    assert(shaper->font != NULL);

    hb_shape(shaper->font, shaper->buffer, NULL, 0);

    shaper->glyph_infos = hb_buffer_get_glyph_infos(shaper->buffer, &(shaper->glyph_count));
    shaper->glyph_positions = hb_buffer_get_glyph_positions(shaper->buffer, &(shaper->glyph_count));
}

int FUNC_NAME(cobbles_shaper_get_glyph_count)(CobblesShaper * shaper) {
    return shaper->glyph_count;
}

void FUNC_NAME(cobbles_shaper_get_glyph_info)(CobblesShaper * shaper, int glyph_index, CobblesShaperGlyphInfoArray info) {
    hb_glyph_info_t hb_info = shaper->glyph_infos[glyph_index];
    hb_glyph_position_t hb_pos = shaper->glyph_positions[glyph_index];

    _cobbles_bytes_write_int(info, 0, hb_info.codepoint);
    _cobbles_bytes_write_int(info, 4, hb_info.cluster);
    _cobbles_bytes_write_int(info, 8, hb_pos.x_offset);
    _cobbles_bytes_write_int(info, 12, hb_pos.y_offset);
    _cobbles_bytes_write_int(info, 16, hb_pos.x_advance);
    _cobbles_bytes_write_int(info, 20, hb_pos.y_advance);
}

#ifdef LIBHL_EXPORTS
DEFINE_PRIM(_ABSTRACT(CobblesShaper), cobbles_shaper_init, _ABSTRACT(Cobbles));
DEFINE_PRIM(_VOID, cobbles_shaper_destroy, _ABSTRACT(CobblesShaper));
DEFINE_PRIM(_I32, cobbles_shaper_get_error, _ABSTRACT(CobblesShaper));
DEFINE_PRIM(_VOID, cobbles_shaper_set_font, _ABSTRACT(CobblesShaper) _ABSTRACT(CobblesFont));
DEFINE_PRIM(_VOID, cobbles_shaper_set_text, _ABSTRACT(CobblesShaper) _BYTES _I32);
DEFINE_PRIM(_VOID, cobbles_shaper_guess_text_properties, _ABSTRACT(CobblesShaper));
DEFINE_PRIM(_VOID, cobbles_shaper_set_direction, _ABSTRACT(CobblesShaper) _BYTES);
DEFINE_PRIM(_VOID, cobbles_shaper_set_script, _ABSTRACT(CobblesShaper) _BYTES);
DEFINE_PRIM(_VOID, cobbles_shaper_set_language, _ABSTRACT(CobblesShaper) _BYTES);
DEFINE_PRIM(_VOID, cobbles_shaper_shape, _ABSTRACT(CobblesShaper));
DEFINE_PRIM(_I32, cobbles_shaper_get_glyph_count, _ABSTRACT(CobblesShaper));
DEFINE_PRIM(_VOID, cobbles_shaper_get_glyph_info, _ABSTRACT(CobblesShaper) _I32 _BYTES);
#endif
