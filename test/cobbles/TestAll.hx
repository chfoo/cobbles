package cobbles;

import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        runTests();
    }

    static function runTests() {
        var runner = new Runner();
        runner.addCases(cobbles.test);
        Report.create(runner);
        runner.run();
    }
}
