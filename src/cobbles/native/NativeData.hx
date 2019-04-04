package cobbles.native;

import unifill.InternalEncoding;
import cobbles.native.CobblesExtern;

class NativeData {
    public static var emscriptenModuleName:String = "CobblesModule";

    static var cobblesPointer:Null<CobblesExtern.CobblesPointer>;

    public static function getEncoding():NativeEncoding {
        #if js
        // Emscripten converts UTF-16 string to UTF-8 chars
        return NativeEncoding.Utf8;
        #end

        switch InternalEncoding.internalEncoding {
            case "UTF-8":
                return NativeEncoding.Utf8;
            case "UTF-32":
                return NativeEncoding.Utf32;
            default:
                return NativeEncoding.Utf16;
        }
    }

    public static function getCobblesPointer():CobblesExtern.CobblesPointer {
        if (cobblesPointer == null) {
            var encoding = getEncoding();
            trace('Target native encoding is $encoding');

            cobblesPointer = CobblesExtern.init(encoding);

            if (cobblesPointer == null) {
                throw "Failed to create cobbles struct";
            }
        }

        var errorCode = CobblesExtern.get_error(cobblesPointer);

        if (errorCode != 0) {
            throw 'Cobbles init error $errorCode';
        }

        return cobblesPointer;
    }
}
