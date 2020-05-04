package cobbles.native;

#if (cpp && !doc_gen)

import cpp.ConstCharStar;
import cpp.RawConstPointer;
import cpp.UInt8;
import cobbles.native.HxcppConfig;

@:include("cobbletext/cobbletext.h")
@:native("CobbletextLibrary *")
extern class Library {
    @:native("cobbletext_library_new")
    static public function new_():Library;

    @:native("cobbletext_library_delete")
    static public function delete_(library:Library):Void;

    @:native("cobbletext_get_error_code")
    static public function getErrorCode(library:Library):Int;

    @:native("cobbletext_get_error_message")
    static public function getErrorMessage(library:Library):ConstCharStar;

    @:native("cobbletext_clear_error")
    static public function clearError(library:Library):Void;

    @:native("cobbletext_library_get_fallback_font")
    static public function getFallbackFont(library:Library):Int;

    @:native("cobbletext_library_load_font")
    static public function loadFont(library:Library, path:ConstCharStar):Int;

    @:native("cobbletext_library_load_font_bytes")
    static public function loadFontBytes(library:Library, data:RawConstPointer<UInt8>, length:Int, faceIndex:Int):Int;

    @:native("cobbletext_library_set_font_alternative")
    static public function setFontAlternative(library:Library, fontID:Int, fallbackFontID:Int):Void;

    @:native("cobbletext_library_get_font_alternative")
    static public function getFontAlternative(library:Library, fontID:Int):Int;

    @:native("cobbletext_library_get_font_info")
    static public function getFontInfo(library:Library, font:Int):FontInfo;

    @:native("cobbletext_library_get_glyph_info")
    static public function getGlyphInfo(library:Library, glyph:Int):GlyphInfo;

    @:native("cobbletext_library_clear_glyphs")
    static public function clearGlyphs(library:Library):Void;
}

#elseif (hl && !doc_gen)

import haxe.io.Bytes;

extern class Library {
    @:hlNative("cobbles", "library_new")
    static public function new_():LibraryHandle;

    @:hlNative("cobbles", "library_delete")
    static public function delete_(library:LibraryHandle):Void;

    @:hlNative("cobbles", "library_get_error_code")
    static public function getErrorCode(library:LibraryHandle):Int;

    @:hlNative("cobbles", "library_get_error_message")
    static public function getErrorMessage(library:LibraryHandle):hl.Bytes;

    @:hlNative("cobbles", "library_clear_error")
    static public function clearError(library:LibraryHandle):Void;

    @:hlNative("cobbles", "library_get_fallback_font")
    static public function getFallbackFont(library:LibraryHandle):Int;

    @:hlNative("cobbles", "library_load_font")
    static public function loadFont(library:LibraryHandle, path:String):Int;

    @:hlNative("cobbles", "library_load_font_bytes")
    static public function loadFontBytes(library:LibraryHandle, data:Bytes, faceIndex:Int):Int;

    @:hlNative("cobbles", "library_set_font_alternative")
    static public function setFontAlternative(library:LibraryHandle, fontID:Int, fallbackFontID:Int):Void;

    @:hlNative("cobbles", "library_get_font_alternative")
    static public function getFontAlternative(library:LibraryHandle, fontID:Int):Int;

    @:hlNative("cobbles", "library_get_font_info")
    static public function getFontInfo(library:LibraryHandle, fontID:Int, out_fontInfo:FontInfo):Void;

    @:hlNative("cobbles", "library_get_glyph_info")
    static public function getGlyphInfo(library:LibraryHandle, glyphID:Int, out_glyphInfo:GlyphInfo):Void;

    @:hlNative("cobbles", "library_clear_glyphs")
    static public function clearGlyphs(library:LibraryHandle):Void;
}

#elseif (js && !doc_gen)

import js.lib.ArrayBuffer;

extern class Library {
    public function delete():Void;
    public function fallbackFont():Int;
    public function loadFontBytes(bytes:ArrayBuffer, faceIndex:Int):Int;
    public function getFontInfo(fontID:Int):FontInfo;
    public function getGlyphInfo(glyphID:Int):GlyphInfo;
    public function setFontAlternative(fontID:Int, fallbackID:Int):Void;
    public function getFontAlternative(fontID:Int):Int;
    public function clearGlyphs():Void;
}

#else

extern class Library {
}

#end
