package cobbles.native;

import haxe.io.Bytes;
import cobbles.native.CobblesExtern;
import haxe.io.BytesData;

using Safety;

class BytesTools {
    public static function toNativeBytes(bytes:Bytes):NativeBytes {
        #if cpp
        return cpp.NativeArray.address(bytes.getData(), 0);
        #elseif hl
        if (bytes.length == 0) {
            throw "0 sized bytes not supported in HL";
        }

        return (bytes.getData():hl.Bytes).sure();

        #elseif js
        var pointer = js.Syntax.code("Module._malloc({0})", bytes.length);
        var heap8:js.html.Uint8Array = js.Syntax.code("Module.HEAP8");
        heap8.set(new js.html.Uint8Array(bytes.getData()), pointer);
        return pointer;

        #else
        return bytes;
        #end
    }

    public static function releaseNativeBytes(bytes:Bytes, pointer:NativeBytes) {
        #if js
        var heap8:js.html.Uint8Array = js.Syntax.code("Module.HEAP8");
        var view = heap8.slice(pointer, pointer + bytes.length);

        new js.html.Uint8Array(bytes.getData()).set(view);
        js.Syntax.code("Module._free({0})", pointer);
        #end
    }

    #if hl @:access(String.__string) #end
    public static function toNativeString(string:String):NativeString {
        #if hl
        // UTF-16LE strings
        return  string.__string();
        #else
        // UTF-8 C strings
        return string;
        #end
    }
}
