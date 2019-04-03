package cobbles.test.algorithm;

import cobbles.algorithm.LineBreakingAlgorithm.LineBreakRule;
import utest.Assert;
import cobbles.algorithm.SimpleLineBreaker;
import utest.Test;

using cobbles.util.MoreUnicodeTools;

class TestSimpleLineBreaker extends Test {
    public function testNewlines() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("01\n34".toCodePoints(), true);

        Assert.equals(Prohibited, breaks[0]);
        Assert.equals(Unspecified, breaks[1]);
        Assert.equals(Mandatory, breaks[2]);
        Assert.equals(Unspecified, breaks[3]);
        Assert.equals(Unspecified, breaks[4]);
    }

    public function testSpace() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("01 34".toCodePoints(), true);

        Assert.equals(Prohibited, breaks[0]);
        Assert.equals(Unspecified, breaks[1]);
        Assert.equals(Unspecified, breaks[2]);
        Assert.equals(Opportunity, breaks[3]);
        Assert.equals(Unspecified, breaks[4]);
    }

    public function testCJK() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("一二三".toCodePoints(), true);

        Assert.equals(Prohibited, breaks[0]);
        Assert.equals(Opportunity, breaks[1]);
        Assert.equals(Opportunity, breaks[2]);
    }
}
