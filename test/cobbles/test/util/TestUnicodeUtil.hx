package cobbles.test.util;

import cobbles.Direction;
import cobbles.util.UnicodeUtil;
import utest.Assert;
import utest.Test;

class TestUnicodeUtil extends Test {
    public function testGuestScript() {
        var result = UnicodeUtil.guessScript("hello");

        Assert.equals("Latn", result.script);
        Assert.equals(LeftToRight, result.direction);

        result = UnicodeUtil.guessScript("يونيكود");

        Assert.equals("Arab", result.script);
        Assert.equals(RightToLeft, result.direction);
    }
}
