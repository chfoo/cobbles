package cobbles;

#if js
import cobbles.native.NativeData;
#end

class Runtime {
#if js
    /**
     * Loads the Enscripten module runtime containing the Cobbles support
     * libraries.
     * @return js.Promise<Bool>
     */
    public static function loadEmscripten():js.Promise<Bool> {
        var moduleName = NativeData.emscriptenModuleName;

        return new js.Promise(function (accept, reject) {
            trace("Loading Emscripten runtime");

            #if haxe4
            js.Syntax.code("cobbles_runtime()")
            #else
            untyped __js__("cobbles_runtime()")
            #end
                .then(emscriptenLoadCallback.bind(moduleName, accept));
        });
    }

    static function emscriptenLoadCallback(moduleName:String, accept:Dynamic, module:Any) {
        // We need to delete the fake `then()`.
        // https://github.com/emscripten-core/emscripten/issues/5820
        #if haxe4
        js.Syntax.delete(module, "then");
        #else
        untyped __js__("delete {0}['then']", module);
        #end

        trace("Binding functions");
        Reflect.setField(js.Browser.window, moduleName, module);

        #if haxe4
        js.Syntax.code
        #else
        untyped __js__
        #end
        ("cobbles_bind({0})", Reflect.field(js.Browser.window, moduleName));

        trace("Loaded Emscripten runtime");
        accept(true);
    }
#end
}
