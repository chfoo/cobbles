#include "cobbles_hl.h"

vstring * utf8_to_vstring(const char * source, hl_type * vstring_type) {
    vstring * dest = (vstring *) hl_alloc_obj(vstring_type);
    // TODO: It would be nice if we could have access to the length
    // to save a few CPU cycles
    dest->bytes = hl_to_utf16(source);
    dest->length = ustrlen(dest->bytes);
    return dest;
}

const char * vstring_to_utf8(vstring * source) {
    if (source->length == 0) {
        // bytes is garbage pointer in this case
        return "";
    } else {
        // assuming bytes from String has null terminator
        return hl_to_utf8(source->bytes);
        // int size;
        // char * output = (char *) hl_utf16_to_utf8(
        //     (vbyte * )source->bytes, source->length, &size);
        // output[size] = 0;
        // return output;
    }
}

hl_CobbletextLibrary * cobbles_library_new() {
    return cobbletext_library_new();
}

void cobbles_library_delete(hl_CobbletextLibrary * library) {
    cobbletext_library_delete(library);
}

int cobbles_library_get_error_code(hl_CobbletextLibrary * library) {
    return cobbletext_get_error_code(library);
}

vbyte * cobbles_library_get_error_message(hl_CobbletextLibrary * library) {
    return (vbyte *) hl_to_utf16(cobbletext_get_error_message(library));
}

void cobbles_library_clear_error(hl_CobbletextLibrary * library) {
    cobbletext_clear_error(library);
}

int cobbles_library_get_fallback_font(hl_CobbletextLibrary * library) {
    return cobbletext_library_get_fallback_font(library);
}

int cobbles_library_load_font(hl_CobbletextLibrary * library, vstring * path) {
    return cobbletext_library_load_font(library, vstring_to_utf8(path));
}

int cobbles_library_load_font_bytes(hl_CobbletextLibrary * library, vbyte * data, int size, int face_index) {
    return cobbletext_library_load_font_bytes(library, data, size, face_index);
}

void cobbles_library_set_font_alternative(hl_CobbletextLibrary * library, int font_id, int fallback_id) {
    cobbletext_library_set_font_alternative(library, font_id, fallback_id);
}

int cobbles_library_get_font_alternative(hl_CobbletextLibrary * library, int font_id) {
    return cobbletext_library_get_font_alternative(library, font_id);
}

void cobbles_library_get_font_info(hl_CobbletextLibrary * library, int font_id, hl_FontInfo * out_font_info) {
    const struct CobbletextFontInfo * info = cobbletext_library_get_font_info(library, font_id);

    out_font_info->id = info->id;
    out_font_info->familyName = utf8_to_vstring(info->family_name, out_font_info->familyName->t);
    out_font_info->styleName = utf8_to_vstring(info->style_name, out_font_info->styleName->t);
    out_font_info->unitsPerEM = info->units_per_em;
    out_font_info->ascender = info->ascender;
    out_font_info->descender = info->descender;
    out_font_info->height = info->height;
    out_font_info->underlinePosition = info->underline_position;
    out_font_info->underlineThickness = info->underline_thickness;
}

void cobbles_library_get_glyph_info(hl_CobbletextLibrary * library, int glyph_id, hl_GlyphInfo * out_glyph_info) {
    const struct CobbletextGlyphInfo * info = cobbletext_library_get_glyph_info(library, glyph_id);

    out_glyph_info->id = info->id;
    out_glyph_info->image->length = info->image_width * info->image_height;
    out_glyph_info->image->bytes = hl_copy_bytes(info->image, out_glyph_info->image->length);
    out_glyph_info->imageWidth = info->image_width;
    out_glyph_info->imageHeight = info->image_height;
    out_glyph_info->imageOffsetX = info->image_offset_x;
    out_glyph_info->imageOffsetY = info->image_offset_y;
}

void cobbles_library_clear_glyphs(hl_CobbletextLibrary * library) {
    cobbletext_library_clear_glyphs(library);
}

hl_CobbletextEngine * cobbles_engine_new(hl_CobbletextLibrary * library) {
    return cobbletext_engine_new(library);
}

void cobbles_engine_delete(hl_CobbletextEngine * engine) {
    cobbletext_engine_delete(engine);
}

void cobbles_engine_get_properties(hl_CobbletextEngine * engine, hl_EngineProperties * out_properties) {
    const struct CobbletextEngineProperties * properties = cobbletext_engine_get_properties(engine);

    out_properties->lineLength = properties->line_length;
    out_properties->locale = utf8_to_vstring(properties->locale, out_properties->locale->t);
    out_properties->textAlignment = properties->text_alignment;
}

void cobbles_engine_set_properties(hl_CobbletextEngine * engine, hl_EngineProperties * properties) {
    struct CobbletextEngineProperties dest_properties;

    dest_properties.line_length = properties->lineLength;
    dest_properties.locale = vstring_to_utf8(properties->locale);
    dest_properties.text_alignment = properties->textAlignment;

    cobbletext_engine_set_properties(engine, &dest_properties);
}

void cobbles_engine_get_text_properties(hl_CobbletextEngine * engine, hl_TextProperties * out_text_properties) {
    const struct CobbletextTextProperties * text_properties = cobbletext_engine_get_text_properties(engine);

    out_text_properties->language = utf8_to_vstring(text_properties->language, out_text_properties->language->t);
    out_text_properties->script = utf8_to_vstring(text_properties->script, out_text_properties->script->t);
    out_text_properties->scriptDirection = text_properties->script_direction;
    out_text_properties->font = text_properties->font;
    out_text_properties->fontSize = text_properties->font_size;
    out_text_properties->customProperty = text_properties->custom_property;
}

void cobbles_engine_set_text_properties(hl_CobbletextEngine * engine, hl_TextProperties * text_properties) {
    struct CobbletextTextProperties dest_properties;

    dest_properties.language = vstring_to_utf8(text_properties->language);
    dest_properties.script = vstring_to_utf8(text_properties->script);
    dest_properties.script_direction = text_properties->scriptDirection;
    dest_properties.font = text_properties->font;
    dest_properties.font_size = text_properties->fontSize;
    dest_properties.custom_property = text_properties->customProperty;

    cobbletext_engine_set_text_properties(engine, &dest_properties);
}

void cobbles_engine_add_text(hl_CobbletextEngine * engine, vstring * text) {
    cobbletext_engine_add_text_utf16(engine, text->bytes, text->length);
}

void cobbles_engine_add_inline_object(hl_CobbletextEngine * engine, int id, int size) {
    cobbletext_engine_add_inline_object(engine, id, size);
}

void cobbles_engine_clear(hl_CobbletextEngine * engine) {
    cobbletext_engine_clear(engine);
}

void cobbles_engine_lay_out(hl_CobbletextEngine * engine) {
    cobbletext_engine_lay_out(engine);
}

bool cobbles_engine_tiles_valid(hl_CobbletextEngine * engine) {
    return cobbletext_engine_tiles_valid(engine);
}

void cobbles_engine_rasterize(hl_CobbletextEngine * engine) {
    cobbletext_engine_rasterize(engine);
}

bool cobbles_engine_pack_tiles(hl_CobbletextEngine * engine, int width, int height) {
    return cobbletext_engine_pack_tiles(engine, width, height);
}

void cobbles_engine_prepare_tiles(hl_CobbletextEngine * engine) {
    cobbletext_engine_prepare_tiles(engine);
}

int cobbles_engine_get_tile_count(hl_CobbletextEngine * engine) {
    return cobbletext_engine_get_tile_count(engine);
}

void cobbles_engine_get_tiles(hl_CobbletextEngine * engine, hl_ArrayObj * out_tiles) {
    size_t size = out_tiles->length;
    const struct CobbletextTileInfo ** tiles = cobbletext_engine_get_tiles(engine);

    for (size_t index = 0; index < size; index++) {
        const struct CobbletextTileInfo * source_info = tiles[index];
        hl_TileInfo * dest_info = hl_aptr(out_tiles->array, hl_TileInfo *)[index];

        dest_info->glyphID = source_info->glyph_id;
        dest_info->atlasX = source_info->atlas_x;
        dest_info->atlasY = source_info->atlas_y;
    }
}

void cobbles_engine_prepare_advances(hl_CobbletextEngine * engine) {
    cobbletext_engine_prepare_advances(engine);
}

int cobbles_engine_get_advance_count(hl_CobbletextEngine * engine) {
    return cobbletext_engine_get_advance_count(engine);
}

void cobbles_engine_get_advances(hl_CobbletextEngine * engine, hl_ArrayObj * out_advances) {
    size_t size = out_advances->length;
    const struct CobbletextAdvanceInfo ** advances = cobbletext_engine_get_advances(engine);

    for (size_t index = 0; index < size; index++) {
        const struct CobbletextAdvanceInfo * source_info = advances[index];
        hl_AdvanceInfo * dest_info = hl_aptr(out_advances->array, hl_AdvanceInfo *)[index];

        dest_info->type = source_info->type;
        dest_info->textIndex = source_info->text_index;
        dest_info->advanceX = source_info->advance_x;
        dest_info->advanceY = source_info->advance_y;
        dest_info->glyphID = source_info->glyph_id;
        dest_info->glyphOffsetX = source_info->glyph_offset_x;
        dest_info->glyphOffsetY = source_info->glyph_offset_y;
        dest_info->inlineObject = source_info->inline_object;
        dest_info->customProperty = source_info->custom_property;
    }
}

void cobbles_engine_get_output_info(hl_CobbletextEngine * engine, hl_OutputInfo * out_output_info) {
    const struct CobbletextOutputInfo * output_info = cobbletext_engine_get_output_info(engine);

    out_output_info->textWidth = output_info->text_width;
    out_output_info->textHeight = output_info->text_height;
}

HL_COBBLES_DEFINE(library_new, _ABSTRACT(hl_CobbletextLibrary), _NO_ARG )
HL_COBBLES_DEFINE(library_delete, _VOID, _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(library_get_error_code, _I32, _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(library_get_error_message, _BYTES, _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(library_clear_error, _VOID, _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(library_get_fallback_font, _I32, _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(library_load_font, _I32, _ABSTRACT(hl_CobbletextLibrary) _STRING )
HL_COBBLES_DEFINE(library_load_font_bytes, _I32, _ABSTRACT(hl_CobbletextLibrary) HAXE_BYTES_DATA _I32 )
HL_COBBLES_DEFINE(library_set_font_alternative, _VOID, _ABSTRACT(hl_CobbletextLibrary) _I32 _I32 )
HL_COBBLES_DEFINE(library_get_font_alternative, _I32, _ABSTRACT(hl_CobbletextLibrary) _I32 )
HL_COBBLES_DEFINE(library_get_font_info, _VOID, _ABSTRACT(hl_CobbletextLibrary) _I32 FONT_INFO )
HL_COBBLES_DEFINE(library_get_glyph_info, _VOID, _ABSTRACT(hl_CobbletextLibrary) _I32 GLYPH_INFO )
HL_COBBLES_DEFINE(library_clear_glyphs, _VOID, _ABSTRACT(hl_CobbletextLibrary) )

HL_COBBLES_DEFINE(engine_new, _ABSTRACT(hl_CobbletextEngine), _ABSTRACT(hl_CobbletextLibrary) )
HL_COBBLES_DEFINE(engine_delete, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_get_properties, _VOID, _ABSTRACT(hl_CobbletextEngine) ENGINE_PROPERTIES )
HL_COBBLES_DEFINE(engine_set_properties, _VOID, _ABSTRACT(hl_CobbletextEngine) ENGINE_PROPERTIES )
HL_COBBLES_DEFINE(engine_get_text_properties, _VOID, _ABSTRACT(hl_CobbletextEngine) TEXT_PROPERTIES )
HL_COBBLES_DEFINE(engine_set_text_properties, _VOID, _ABSTRACT(hl_CobbletextEngine) TEXT_PROPERTIES )
HL_COBBLES_DEFINE(engine_add_text, _VOID, _ABSTRACT(hl_CobbletextEngine) _STRING )
HL_COBBLES_DEFINE(engine_add_inline_object, _VOID, _ABSTRACT(hl_CobbletextEngine) _I32 _I32 )
HL_COBBLES_DEFINE(engine_clear, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_lay_out, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_tiles_valid, _BOOL, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_rasterize, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_pack_tiles, _BOOL, _ABSTRACT(hl_CobbletextEngine) _I32 _I32 )
HL_COBBLES_DEFINE(engine_prepare_tiles, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_get_tile_count, _I32, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_get_tiles, _VOID, _ABSTRACT(hl_CobbletextEngine) HL_ARRAY_OBJ )
HL_COBBLES_DEFINE(engine_prepare_advances, _VOID, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_get_advance_count, _I32, _ABSTRACT(hl_CobbletextEngine) )
HL_COBBLES_DEFINE(engine_get_advances, _VOID, _ABSTRACT(hl_CobbletextEngine) HL_ARRAY_OBJ )
HL_COBBLES_DEFINE(engine_get_output_info, _VOID, _ABSTRACT(hl_CobbletextEngine) OUTPUT_INFO )
