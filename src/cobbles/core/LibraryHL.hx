package cobbles.core;

#if (hl && !doc_gen)
import haxe.io.Bytes;
import cobbles.native.Library as NativeLibrary;
import cobbles.native.LibraryHandle;

class LibraryHL implements Library {
    static final MINIMUM_API_VERSION = 2;

    public var fallbackFont(get, never):FontID;

    @:allow(cobbles)
    final handle:LibraryHandle;

    var _disposed = false;

    public function new() {
        final binaryAPIVersion = NativeLibrary.getAPIVersion();

        if (binaryAPIVersion < MINIMUM_API_VERSION) {
            throw new Exception('Outdated cobbles.hdll version. ' +
                'Expected $MINIMUM_API_VERSION, got $binaryAPIVersion');
        }

        handle = NativeLibrary.new_();
        checkError();
    }

    @:access(String.fromUCS2)
    public function checkError() {
        final errorCode = NativeLibrary.getErrorCode(handle);

        if (errorCode != 0) {
            final message = String.fromUCS2(NativeLibrary.getErrorMessage(handle));
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
        final result = NativeLibrary.loadFont(handle, path);
        checkError();
        return result;
    }

    public function loadFontBytes(data:Bytes, faceIndex:Int = 0):FontID {
        final result = NativeLibrary.loadFontBytes(handle, data, faceIndex);
        checkError();
        return result;
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
}
#end
