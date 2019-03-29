package cobbles;

class Runtime {
#if js
    public static function loadEmscripten():js.Promise<Bool> {
        return new js.Promise(function (accept, reject) {
            trace("Loading Emscripten runtime");

            js.Syntax.code("cobbles_runtime()")
                .then(emscriptenLoadCallback.bind(accept));
        });
    }

    static function emscriptenLoadCallback(accept:Dynamic, module:Any) {
        // https://github.com/emscripten-core/emscripten/issues/5820
        js.Syntax.delete(module, "then");

        trace("Binding functions");
        Reflect.setField(js.Browser.window, "Module", module);
        js.Syntax.code("cobbles_bind()");

        trace("Loaded Emscripten runtime");
        accept(true);
    }
#end
}
