package cobbles;

import utest.Async;
import utest.ITest;

using Safety;

class BaseTestCase implements ITest {
    #if js
    var fontBytes:Null<haxe.io.Bytes>;
    #end

    public function new() {}

    #if js
    function loadAndRun(asyncHandle:Async, callback:Library->Void, ?fontURL:String) {
        function loadEmscripten() {
            final fakePromise = Library.loadModule();

            fakePromise.then(library -> {
                callback(library);
                asyncHandle.done();
            });
        }

        if (fontURL != null) {
            js.Browser.window.fetch(fontURL)
                .then(response -> response.arrayBuffer())
                .then(data -> {
                    fontBytes = haxe.io.Bytes.ofData(data);

                    loadEmscripten();
                });
        } else {
            loadEmscripten();
        }
    }
    #else
    function loadAndRun(asyncHandle:Async, callback:Library->Void) {
        final library = new Library();
        callback(library);
        asyncHandle.done();
    }
    #end

    #if sys
    function getFontPath():String {
        var fontPath = "DejaVuSans.ttf";

        final envVars = Sys.environment();
        if (envVars.exists("FONT_PATH")) {
            fontPath = envVars.get("FONT_PATH").sure();
        }

        if (!sys.FileSystem.exists(fontPath)) {
            trace('Font $fontPath does not exist. Test will fail!');
        }

        return fontPath;
    }
    #end
}
