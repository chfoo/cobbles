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
        var module = Reflect.field(js.Browser.window, NativeData.emscriptenModuleName);
        var pointer = #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}._malloc({1})", module, bytes.length);
        var heap8:js.html.Uint8Array =
            #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}.HEAP8", module);
        heap8.set(new js.html.Uint8Array(bytes.getData()), pointer);
        return pointer;

        #else
        return bytes;
        #end
    }

    public static function releaseNativeBytes(bytes:Bytes, pointer:NativeBytes) {
        #if js
        var module = Reflect.field(js.Browser.window, NativeData.emscriptenModuleName);
        var heap8:js.html.Uint8Array =
            #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}.HEAP8", module);
        var view = #if !haxe4 untyped #end heap8.slice(pointer, pointer + bytes.length);

        new js.html.Uint8Array(bytes.getData()).set(view);
        #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}._free({1})", module, pointer);
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
