#pragma once

#define HL_NAME(n) n
#include <hl.h>
#define API HL_PRIM
#define HL_DEFINE(name,impl_name,t,args) DEFINE_PRIM_WITH_NAME(t,impl_name,args,name)
#define HL_COBBLES_DEFINE(name,t,args) DEFINE_PRIM_WITH_NAME(t,cobbles_##name,args,name)

#define COBBLES_API_VERSION 1

#include <cobbletext/cobbletext.h>

typedef struct CobbletextLibrary hl_CobbletextLibrary;
typedef struct CobbletextEngine hl_CobbletextEngine;

// copy and pasted from HL string.c because it's not in the public header
// TODO: is this a bug?
extern vbyte *hl_utf16_to_utf8( vbyte *str, int len, int *size );

// haxe.io.BytesData
typedef struct hl_BytesData {
    hl_type *t;
    int length;
    vbyte * bytes;
} hl_BytesData;
#define HAXE_BYTES_DATA _OBJ( _I32 _BYTES )

// hl.types.ArrayObj
typedef struct hl_ArrayObj {
    hl_type *t;
    // hl.types.ArrayBase
    int length;
    // hl.types.ArrayObj
    varray * array;
} hl_ArrayObj;
#define HL_ARRAY_OBJ _OBJ( _ARR )

typedef struct hl_FontInfo {
    hl_type *t;
    int id;
    vstring * familyName;
    vstring * styleName;
    int unitsPerEM;
    int ascender;
    int descender;
    int height;
    int underlinePosition;
    int underlineThickness;
} hl_FontInfo;

//                                             1   2     3    4    5    6
#define FONT_INFO _OBJ( _I32 _STRING _STRING _I32 _I32 _I32 _I32 _I32 _I32 )

typedef struct hl_GlyphInfo {
    hl_type *t;
    int id;
    hl_BytesData * image;
    int imageWidth;
    int imageHeight;
    int imageOffsetX;
    int imageOffsetY;
} hl_GlyphInfo;
#define GLYPH_INFO _OBJ( _I32 HAXE_BYTES_DATA _I32 _I32 _I32 _I32 )

typedef struct hl_EngineProperties {
    hl_type *t;
    int lineLength;
    vstring * locale;
    int textAlignment;
} hl_EngineProperties;
#define ENGINE_PROPERTIES _OBJ( _I32 _STRING _I32 )

typedef struct hl_TextProperties {
    hl_type *t;
    vstring * language;
    vstring * script;
    int scriptDirection;
    int font;
    double fontSize;
    int customProperty;
} hl_TextProperties;
#define TEXT_PROPERTIES _OBJ( _STRING _STRING _I32 _I32 _F64 _I32 )

typedef struct hl_TileInfo {
    hl_type *t;
    int glyphID;
    int atlasX;
    int atlasY;
} hl_TileInfo;
#define TILE_INFO _OBJ( _I32 _I32 _I32 )

typedef struct hl_AdvanceInfo {
    hl_type *t;
    int type;
    int textIndex;
    int advanceX;
    int advanceY;
    int glyphID;
    int glyphOffsetX;
    int glyphOffsetY;
    int inlineObject;
    int customProperty;
} hl_AdvanceInfo;
//                        type      advance   glyph  X   Y
#define ADANCE_INFO _OBJ( _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 _I32 )

typedef struct hl_OutputInfo {
    hl_type *t;
    int textWidth;
    int textHeight;
} hl_OutputInfo;
#define OUTPUT_INFO _OBJ( _I32 _I32 )

vstring * utf8_to_vstring(const char * source, hl_type * vstring_type);

const char * vstring_to_utf8(vstring * source);

API
int cobbles_get_api_version();

API
hl_CobbletextLibrary * cobbles_library_new();

API
void cobbles_library_delete(hl_CobbletextLibrary * library);

API
int cobbles_library_get_error_code(hl_CobbletextLibrary * library);

API
vbyte * cobbles_library_get_error_message(hl_CobbletextLibrary * library);

API
void cobbles_library_clear_error(hl_CobbletextLibrary * library);

API
int cobbles_library_get_fallback_font(hl_CobbletextLibrary * library);

API
int cobbles_library_load_font(hl_CobbletextLibrary * library, vstring * path);

API
int cobbles_library_load_font_bytes(hl_CobbletextLibrary * library, vbyte * data, int size, int face_index);

API
void cobbles_library_set_font_alternative(hl_CobbletextLibrary * library, int font_id, int fallback_id);

API
int cobbles_library_get_font_alternative(hl_CobbletextLibrary * library, int font_id);

API
void cobbles_library_get_font_info(hl_CobbletextLibrary * library, int font_id, hl_FontInfo * out_font_info);

API
void cobbles_library_get_glyph_info(hl_CobbletextLibrary * library, int glyph_id, hl_GlyphInfo * out_glyph_info);

API
void cobbles_library_clear_glyphs(hl_CobbletextLibrary * library);

API
hl_CobbletextEngine * cobbles_engine_new(hl_CobbletextLibrary * library);

API
void cobbles_engine_delete(hl_CobbletextEngine * engine);

API
void cobbles_engine_get_properties(hl_CobbletextEngine * engine, hl_EngineProperties * out_properties);

API
void cobbles_engine_set_properties(hl_CobbletextEngine * engine, hl_EngineProperties * properties);

API
void cobbles_engine_get_text_properties(hl_CobbletextEngine * engine, hl_TextProperties * out_text_properties);

API
void cobbles_engine_set_text_properties(hl_CobbletextEngine * engine, hl_TextProperties * text_properties);

API
void cobbles_engine_add_text(hl_CobbletextEngine * engine, vstring * text);

API
void cobbles_engine_add_inline_object(hl_CobbletextEngine * engine, int id, int size);

API
void cobbles_engine_clear(hl_CobbletextEngine * engine);

API
void cobbles_engine_lay_out(hl_CobbletextEngine * engine);

API
bool cobbles_engine_tiles_valid(hl_CobbletextEngine * engine);

API
void cobbles_engine_rasterize(hl_CobbletextEngine * engine);

API
bool cobbles_engine_pack_tiles(hl_CobbletextEngine * engine, int width, int height);

API
void cobbles_engine_prepare_tiles(hl_CobbletextEngine * engine);

API
int cobbles_engine_get_tile_count(hl_CobbletextEngine * engine);

API
void cobbles_engine_get_tiles(hl_CobbletextEngine * engine, hl_ArrayObj * out_tiles);

API
void cobbles_engine_prepare_advances(hl_CobbletextEngine * engine);

API
int cobbles_engine_get_advance_count(hl_CobbletextEngine * engine);

API
void cobbles_engine_get_advances(hl_CobbletextEngine * engine, hl_ArrayObj * out_advances);

API
void cobbles_engine_get_output_info(hl_CobbletextEngine * engine, hl_OutputInfo * out_output_info);
