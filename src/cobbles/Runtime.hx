package cobbles;

import cobbles.native.NativeData;

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

            js.Syntax.code("cobbles_runtime()")
                .then(emscriptenLoadCallback.bind(moduleName, accept));
        });
    }

    static function emscriptenLoadCallback(moduleName:String, accept:Dynamic, module:Any) {
        // https://github.com/emscripten-core/emscripten/issues/5820
        js.Syntax.delete(module, "then");

        trace("Binding functions");
        Reflect.setField(js.Browser.window, moduleName, module);
        js.Syntax.code("cobbles_bind({0})", Reflect.field(js.Browser.window, moduleName));

        trace("Loaded Emscripten runtime");
        accept(true);
    }
#end
}
