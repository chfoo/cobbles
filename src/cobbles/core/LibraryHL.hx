package cobbles.core;

#if (hl && !doc_gen)
import haxe.io.Bytes;
import cobbles.native.Library as NativeLibrary;
import cobbles.native.LibraryHandle;

class LibraryHL implements Library {
    public var fallbackFont(get, never):FontID;

    @:allow(cobbles)
    final handle:LibraryHandle;

    var _disposed = false;

    public function new() {
        handle = NativeLibrary.new_();
        checkError();
    }

    @:access(String.fromUTF8)
    public function checkError() {
        final errorCode = NativeLibrary.getErrorCode(handle);

        if (errorCode != 0) {
            final message = String.fromUTF8(NativeLibrary.getErrorMessage(handle));
            throw new Exception(message);
        }

        NativeLibrary.clearError(handle);
    }

    public function dispose() {
        NativeLibrary.delete_(handle);
        _disposed = true;
    }

    public function isDisposed() {
        return _disposed;
    }

    function get_fallbackFont():FontID {
        return NativeLibrary.getFallbackFont(handle);
    }

    public function loadFont(path:String):FontID {
        return NativeLibrary.loadFont(handle, path);
    }

    public function loadFontBytes(data:Bytes, faceIndex:Int = 0):FontID {
        return NativeLibrary.loadFontBytes(handle, data, faceIndex);
    }

    public function getFontInfo(id:FontID):FontInfo {
        final info:FontInfo = {
            id: 0,
            familyName: "",
            styleName: "",
            unitsPerEM: 0,
            ascender: 0,
            descender: 0,
            height: 0,
            underlinePosition: 0,
            underlineThickness: 0,
        }
        NativeLibrary.getFontInfo(handle, id, info);
        return info;
    }

    public function getGlyphInfo(id:GlyphID):GlyphInfo {
        final info:GlyphInfo = {
            id: 0,
            image: Bytes.alloc(0),
            imageWidth: 0,
            imageHeight: 0,
            imageOffsetX: 0,
            imageOffsetY: 0,
        };
        NativeLibrary.getGlyphInfo(handle, id, info);
        return info;
    }

    public function setFontAlternative(id:FontID, fallbackID:FontID):Void {
        NativeLibrary.setFontAlternative(handle, id, fallbackID);
    }

    public function getFontAlternative(id:FontID):FontID {
        return NativeLibrary.getFontAlternative(handle, id);
    }

    public function clearGlyphs():Void {
        NativeLibrary.clearGlyphs(handle);
    }
}
#end
