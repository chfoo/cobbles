package cobbles.native;

#if cpp
    @:include("cobbles.h")
    @:native("Cobbles")
    private extern class _Cobbles {
    }

    @:include("cobbles.h")
    @:native("CobblesFont")
    private extern class _Font {
    }

    @:include("cobbles.h")
    @:native("CobblesShaper")
    private extern class _Shaper {
    }

    typedef CobblesPointer = cpp.RawPointer<_Cobbles>;
    typedef CobblesFontPointer = cpp.RawPointer<_Font>;
    typedef CobblesShaperPointer = cpp.RawPointer<_Shaper>;
    typedef NativeString = cpp.ConstCharStar;
    typedef NativeBytes = cpp.Pointer<cpp.UInt8>;

#elseif hl
    typedef CobblesPointer = hl.Abstract<"Cobbles">;
    typedef CobblesFontPointer = hl.Abstract<"CobblesFont">;
    typedef CobblesShaperPointer = hl.Abstract<"CobblesShaper">;
    typedef NativeString = hl.Bytes;
    typedef NativeBytes = hl.Bytes;

#elseif js
    typedef CobblesPointer = Int;
    typedef CobblesFontPointer = Int;
    typedef CobblesShaperPointer = Int;
    typedef NativeString = String;
    typedef NativeBytes = Int;

#else
    typedef CobblesPointer = Int;
    typedef CobblesFontPointer = Int;
    typedef CobblesShaperPointer = Int;
    typedef NativeString = String;
    typedef NativeBytes = haxe.io.Bytes;

#end

@:enum
abstract NativeEncoding(Int) {
    var Utf8 = 0;
    var Utf16 = 1;
    var Utf32 = 2;
}

#if cpp
    @:include("cobbles.h")

    #if cobbles
    @:buildXml("<include name=\"${haxelib:cobbles}/native/hxcpp_build.xml\" />")
    #else
    // `this_dir` is out/cpp/
    @:buildXml("<include name=\"${this_dir}/../../native/hxcpp_build.xml\" />")
    #end
#elseif js
    @:native("cobbles")
#end
extern class CobblesExtern {
    // cobbles.c
    #if cpp @:native("cobbles_init")
    #elseif hl @:hlNative("cobbles", "cobbles_init") #end
    public static function init(encoding:NativeEncoding):CobblesPointer;

    #if cpp @:native("cobbles_destroy")
    #elseif hl @:hlNative("cobbles", "cobbles_destroy") #end
    public static function destroy(cobbles:CobblesPointer):Void;

    #if cpp @:native("cobbles_get_error")
    #elseif hl @:hlNative("cobbles", "cobbles_get_error") #end
    public static function get_error(cobbles:CobblesPointer):Int;

    // cobbles_font.c
    #if cpp @:native("cobbles_open_font_file")
    #elseif hl @:hlNative("cobbles", "cobbles_open_font_file") #end
    public static function open_font_file(cobbles:CobblesPointer, path:NativeString, faceIndex:Int):Null<CobblesFontPointer>;

    #if cpp @:native("cobbles_open_font_bytes")
    #elseif hl @:hlNative("cobbles", "cobbles_open_font_bytes") #end
    public static function open_font_bytes(cobbles:CobblesPointer, bytes:NativeBytes, length:Int, faceIndex:Int):Null<CobblesFontPointer>;

    #if cpp @:native("cobbles_font_get_error")
    #elseif hl @:hlNative("cobbles", "cobbles_font_get_error") #end
    public static function font_get_error(font:CobblesFontPointer):Int;

    #if cpp @:native("cobbles_font_set_size")
    #elseif hl @:hlNative("cobbles", "cobbles_font_set_size") #end
    public static function font_set_size(font:CobblesFontPointer, width:Int, height:Int, horizontalResolution:Int, verticalResolution:Int):Void;

    #if cpp @:native("cobbles_font_get_glyph_id")
    #elseif hl @:hlNative("cobbles", "cobbles_font_get_glyph_id") #end
    public static function font_get_glyph_id(font:CobblesFontPointer, codePoint:Int):Int;

    #if cpp @:native("cobbles_font_load_glyph")
    #elseif hl @:hlNative("cobbles", "cobbles_font_load_glyph") #end
    public static function font_load_glyph(font:CobblesFontPointer, glyphID:Int):Void;

    #if cpp @:native("cobbles_font_get_glyph_info")
    #elseif hl @:hlNative("cobbles", "cobbles_font_get_glyph_info") #end
    public static function font_get_glyph_info(font:CobblesFontPointer, info:NativeBytes):Void;

    #if cpp @:native("cobbles_font_get_glyph_bitmap")
    #elseif hl @:hlNative("cobbles", "cobbles_font_get_glyph_bitmap") #end
    public static function font_get_glyph_bitmap(font:CobblesFontPointer, buffer:NativeBytes):Void;

    #if cpp @:native("cobbles_font_close")
    #elseif hl @:hlNative("cobbles", "cobbles_font_close") #end
    public static function font_close(font:CobblesFontPointer):Void;

    // cobbles_shaper.c
    #if cpp @:native("cobbles_shaper_init")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_init") #end
    public static function shaper_init(cobbles:CobblesPointer):Null<CobblesShaperPointer>;

    #if cpp @:native("cobbles_shaper_destroy")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_destroy") #end
    public static function shaper_destroy(shaper:CobblesShaperPointer):Void;

    #if cpp @:native("cobbles_shaper_get_error")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_get_error") #end
    public static function shaper_get_error(shaper:CobblesShaperPointer):Int;

    #if cpp @:native("cobbles_shaper_set_font")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_set_font") #end
    public static function shaper_set_font(shaper:CobblesShaperPointer, font:CobblesFontPointer):Void;

    #if cpp @:native("cobbles_shaper_set_text")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_set_text") #end
    public static function shaper_set_text(shaper:CobblesShaperPointer, text:NativeString):Void;

    #if cpp @:native("cobbles_shaper_guess_text_properties")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_guess_text_properties") #end
    public static function shaper_guess_text_properties(shaper:CobblesShaperPointer):Void;

    #if cpp @:native("cobbles_shaper_set_direction")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_set_direction") #end
    public static function shaper_set_direction(shaper:CobblesShaperPointer, direction:NativeString):Void;

    #if cpp @:native("cobbles_shaper_set_script")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_set_script") #end
    public static function shaper_set_script(shaper:CobblesShaperPointer, script:NativeString):Void;

    #if cpp @:native("cobbles_shaper_set_language")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_set_language") #end
    public static function shaper_set_language(shaper:CobblesShaperPointer, language:NativeString):Void;

    #if cpp @:native("cobbles_shaper_shape")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_shape") #end
    public static function shaper_shape(shaper:CobblesShaperPointer):Void;

    #if cpp @:native("cobbles_shaper_get_glyph_count")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_get_glyph_count") #end
    public static function shaper_get_glyph_count(shaper:CobblesShaperPointer):Int;

    #if cpp @:native("cobbles_shaper_get_glyph_info")
    #elseif hl @:hlNative("cobbles", "cobbles_shaper_get_glyph_info") #end
    public static function shaper_get_glyph_info(shaper:CobblesShaperPointer, glyphIndex:Int, info:NativeBytes):Void;

}
