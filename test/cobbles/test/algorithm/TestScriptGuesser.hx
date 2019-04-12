package cobbles.test.algorithm;

import cobbles.Direction;
import cobbles.algorithm.ScriptGuesser;
import utest.Assert;
import utest.Test;

class TestScriptGuesser extends Test {
    public function testGuestScript() {
        var result = ScriptGuesser.guessScript("hello");

        Assert.equals("Latn", result.script);
        Assert.equals(LeftToRight, result.direction);

        result = ScriptGuesser.guessScript("يونيكود");

        Assert.equals("Arab", result.script);
        Assert.equals(RightToLeft, result.direction);
    }
}
