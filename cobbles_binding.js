var cobbles = {};

function cobbles_bind(Module) {
    'use strict';
    var NUMBER = 'number';
    var STRING = 'string';

    // cobbles.c
    cobbles.init = Module.cwrap('cobbles_init', NUMBER, [NUMBER]);
    cobbles.destroy = Module.cwrap('cobbles_destroy', null, [NUMBER]);
    cobbles.get_error = Module.cwrap('cobbles_get_error', NUMBER, [NUMBER]);
    cobbles.guess_string_script = Module.cwrap('cobbles_guess_string_script', NUMBER, [NUMBER, STRING]);

    // cobbles_font.c
    cobbles.open_font_file = Module.cwrap('cobbles_open_font_file', NUMBER, [NUMBER, STRING, NUMBER]);
    cobbles.open_font_bytes = Module.cwrap('cobbles_open_font_bytes', NUMBER, [NUMBER, NUMBER, NUMBER, NUMBER]);
    cobbles.font_get_error = Module.cwrap('cobbles_font_get_error', null, [NUMBER]);
    cobbles.font_set_size = Module.cwrap('cobbles_font_set_size', null, [NUMBER, NUMBER, NUMBER, NUMBER, NUMBER]);
    cobbles.font_get_glyph_id = Module.cwrap('cobbles_font_get_glyph_id', NUMBER, [NUMBER, NUMBER]);
    cobbles.font_load_glyph = Module.cwrap('cobbles_font_load_glyph', null, [NUMBER, NUMBER]);
    cobbles.font_get_glyph_info = Module.cwrap('cobbles_font_get_glyph_info', null, [NUMBER, NUMBER]);
    cobbles.font_get_glyph_bitmap = Module.cwrap('cobbles_font_get_glyph_bitmap', null, [NUMBER, NUMBER]);
    cobbles.font_close = Module.cwrap('cobbles_font_close', null, [NUMBER]);

    // cobbles_shaper.c
    cobbles.shaper_init = Module.cwrap('cobbles_shaper_init', NUMBER, [NUMBER]);
    cobbles.shaper_destroy = Module.cwrap('cobbles_shaper_destroy', null, [NUMBER]);
    cobbles.shaper_get_error = Module.cwrap('cobbles_shaper_get_error', NUMBER, [NUMBER]);
    cobbles.shaper_set_font = Module.cwrap('cobbles_shaper_set_font', null, [NUMBER, NUMBER]);
    cobbles.shaper_set_text = Module.cwrap('cobbles_shaper_set_text', null, [NUMBER, STRING, NUMBER]);
    cobbles.shaper_set_text_binary = Module.cwrap('cobbles_shaper_set_text', null, [NUMBER, NUMBER, NUMBER]);
    cobbles.shaper_guess_text_properties = Module.cwrap('cobbles_shaper_guess_text_properties', null, [NUMBER]);
    cobbles.shaper_set_direction = Module.cwrap('cobbles_shaper_set_direction', null, [NUMBER, STRING]);
    cobbles.shaper_set_script = Module.cwrap('cobbles_shaper_set_script', null, [NUMBER, STRING]);
    cobbles.shaper_set_language = Module.cwrap('cobbles_shaper_set_language', null, [NUMBER, STRING]);
    cobbles.shaper_shape = Module.cwrap('cobbles_shaper_shape', null, [NUMBER]);
    cobbles.shaper_get_glyph_count = Module.cwrap('cobbles_shaper_get_glyph_count', NUMBER, [NUMBER]);
    cobbles.shaper_get_glyph_info = Module.cwrap('cobbles_shaper_get_glyph_info', null, [NUMBER, NUMBER, NUMBER]);
}
