var cobbles = {};

function cobbles_bind() {
    // cobbles.c
    cobbles.init = Module.cwrap('cobbles_init', 'number', []);
    cobbles.destroy = Module.cwrap('cobbles_destroy', null, ['number']);
    cobbles.get_error = Module.cwrap('cobbles_get_error', 'number', ['number']);

    // cobbles_font.c
    cobbles.open_font_file = Module.cwrap('cobbles_open_font_file', 'number', ['number', 'string', 'number']);
    cobbles.open_font_bytes = Module.cwrap('cobbles_open_font_bytes', 'number', ['number', 'number', 'number', 'number']);
    cobbles.font_get_error = Module.cwrap('cobbles_font_get_error', null, ['number']);
    cobbles.font_set_size = Module.cwrap('cobbles_font_set_size', null, ['number', 'number', 'number', 'number', 'number']);
    cobbles.font_get_glyph_id = Module.cwrap('cobbles_font_get_glyph_id', 'number', ['number', 'number']);
    cobbles.font_load_glyph = Module.cwrap('cobbles_font_load_glyph', null, ['number', 'number']);
    cobbles.font_get_glyph_info = Module.cwrap('cobbles_font_get_glyph_info', null, ['number', 'number']);
    cobbles.font_get_glyph_bitmap = Module.cwrap('cobbles_font_get_glyph_bitmap', null, ['number', 'number']);
    cobbles.font_close = Module.cwrap('cobbles_font_close', null, ['number']);

    // cobbles_shaper.c
    cobbles.shaper_init = Module.cwrap('cobbles_shaper_init', 'number', []);
    cobbles.shaper_destroy = Module.cwrap('cobbles_shaper_destroy', null, ['number']);
    cobbles.shaper_get_error = Module.cwrap('cobbles_shaper_get_error', 'number', ['number']);
    cobbles.shaper_set_font = Module.cwrap('cobbles_shaper_set_font', null, ['number', 'number']);
    cobbles.shaper_set_text = Module.cwrap('cobbles_shaper_set_text', null, ['number', 'string', 'number']);
    cobbles.shaper_guess_text_properties = Module.cwrap('cobbles_shaper_guess_text_properties', null, ['number']);
    cobbles.shaper_set_direction = Module.cwrap('cobbles_shaper_set_direction', null, ['number', 'string']);
    cobbles.shaper_set_script = Module.cwrap('cobbles_shaper_set_script', null, ['number', 'string']);
    cobbles.shaper_set_language = Module.cwrap('cobbles_shaper_set_language', null, ['number', 'string']);
    cobbles.shaper_shape = Module.cwrap('cobbles_shaper_shape', null, ['number']);
    cobbles.shaper_get_glyph_count = Module.cwrap('cobbles_shaper_get_glyph_count', 'number', ['number']);
    cobbles.shaper_get_glyph_info = Module.cwrap('cobbles_shaper_get_glyph_info', null, ['number', 'number', 'number']);
}
