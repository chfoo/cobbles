package cobbles;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        #if js
        cobbles.test.TestFont.preloadFonts()
        .then((success:Bool) -> {
            trace("Loading runtime...");

            // https://github.com/emscripten-core/emscripten/issues/5820
            return new js.Promise((accept, reject) -> {
                js.Syntax.code("cobbles_runtime()").then(module -> {
                    js.Syntax.delete(module, "then");
                    accept(module);
                });
            });
        })
        .then((module:Any) -> {
            trace("Binding functions...");
            Reflect.setField(js.Browser.window, "Module", module);
            js.Syntax.code("cobbles_bind()");
            trace("Running tests...");
            runTests();
        })
        .catchError(error -> trace(error));
        #else
        runTests();
        #end
    }

    static function runTests() {
        var runner = new Runner();
        runner.addCases(cobbles.test);
        Report.create(runner);
        runner.run();
    }
}
