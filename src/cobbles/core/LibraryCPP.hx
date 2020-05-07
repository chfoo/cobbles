package cobbles.core;

#if (cpp && !doc_gen)
import cobbles.native.Library as NativeLibrary;
import cpp.Native;
import cpp.NativeArray;
import cpp.NativeGc;
import cpp.Pointer;
import cpp.UInt8;
import haxe.io.Bytes;

class LibraryCPP implements Library {
    public var fallbackFont(get, never):FontID;

    @:allow(cobbles)
    @:unreflective final handle:NativeLibrary;

    var _disposed = false;

    public function new() {
        handle = NativeLibrary.new_();
        checkError();
    }

    public function checkError() {
        final errorCode = NativeLibrary.getErrorCode(handle);

        if (errorCode != 0) {
            final message:String = NativeLibrary.getErrorMessage(handle);
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
        final pointer = cast NativeArray.address(data.getData(), 0);
        final result = NativeLibrary.loadFontBytes(handle, pointer,
            data.length, faceIndex);
        checkError();
        return result;
    }

    public function getFontInfo(id:FontID):FontInfo {
        final nativeInfo = NativeLibrary.getFontInfo(handle, id);
        checkError();

        return {
            id: nativeInfo.id,
            familyName: nativeInfo.familyName,
            styleName: nativeInfo.styleName,
            unitsPerEM: nativeInfo.unitsPerEM,
            ascender: nativeInfo.ascender,
            descender: nativeInfo.descender,
            height: nativeInfo.height,
            underlinePosition: nativeInfo.underlinePosition,
            underlineThickness: nativeInfo.underlineThickness,
        }
    }

    public function getGlyphInfo(id:GlyphID):GlyphInfo {
        final nativeInfo = NativeLibrary.getGlyphInfo(handle, id);
        checkError();

        final imageSize = nativeInfo.imageWidth * nativeInfo.imageHeight;
        final imageCopy:Pointer<UInt8> = cast NativeGc.allocGcBytes(imageSize);
        Native.memcpy(imageCopy, nativeInfo.image, imageSize);

        final image = Bytes.ofData(imageCopy.toUnmanagedArray(imageSize));

        return {
            id: nativeInfo.id,
            image: image,
            imageWidth: nativeInfo.imageWidth,
            imageHeight: nativeInfo.imageHeight,
            imageOffsetX: nativeInfo.imageOffsetX,
            imageOffsetY: nativeInfo.imageOffsetY,
        }
    }

    public function setFontAlternative(id:FontID, fallbackID:FontID):Void {
        NativeLibrary.setFontAlternative(handle, id, fallbackID);
    }

    public function getFontAlternative(id:FontID):FontID {
        return NativeLibrary.getFontAlternative(handle, id);
    }
}
#end
