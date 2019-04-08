package cobbles.native;

import haxe.io.Bytes;
import cobbles.native.CobblesExtern;
import haxe.io.BytesData;

using Safety;

class BytesTools {
    public static function toNativeBytes(bytes:Bytes, syncHeap:Bool = true):NativeBytes {
        #if cpp
        return cpp.NativeArray.address(bytes.getData(), 0);
        #elseif hl
        if (bytes.length == 0) {
            throw "0 sized bytes not supported in HL";
        }

        return (bytes.getData():hl.Bytes).sure();

        #elseif js
        var pointer = emscriptenMalloc(bytes.length);

        if (syncHeap) {
            var heap8 = getEmscriptenHeap8();
            heap8.set(new js.html.Uint8Array(bytes.getData()), pointer);
        }

        return pointer;

        #else
        return bytes;
        #end
    }

    public static function releaseNativeBytes(bytes:Bytes, pointer:NativeBytes, syncHeap:Bool = true) {
        #if js

        if (syncHeap) {
            var heap8 = getEmscriptenHeap8();
            var view = #if !haxe4 untyped #end heap8.slice(pointer, pointer + bytes.length);
            new js.html.Uint8Array(bytes.getData()).set(view);
        }

        emscriptenFree(pointer);
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

    #if js
    static inline function getEmscriptenModule() {
        return #if haxe4 js.Syntax.code #else untyped __js__#end
            ("window[{0}]", NativeData.emscriptenModuleName);
    }

    static inline function emscriptenMalloc(length:Int):NativeBytes {
        return #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}._malloc({1})", getEmscriptenModule(), length);
    }

    static inline function emscriptenFree(pointer:NativeBytes) {
        #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}._free({1})", getEmscriptenModule(), pointer);
    }

    static inline function getEmscriptenHeap8():js.html.Uint8Array {
        return #if haxe4 js.Syntax.code #else untyped __js__#end
            ("{0}.HEAP8", getEmscriptenModule());
    }
    #end
}
