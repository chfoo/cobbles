package cobbles;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        #if js
        cobbles.test.TestFont.preloadFonts()
        .then(function (success:Bool) {
            return cobbles.Runtime.loadEmscripten();
        })
        .then(function (success:Bool) {
            trace("Running tests...");
            runTests();
        })
        .catchError(function (error) { trace(error); });
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
