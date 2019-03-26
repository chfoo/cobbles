package cobbles.test.algorithm;

import utest.Assert;
import cobbles.algorithm.SimpleLineBreaker;
import utest.Test;

class TestSimpleLineBreaker extends Test {
    public function testNewlines() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("01\n34");

        Assert.isFalse(breaks.canBreak(0));
        Assert.isFalse(breaks.canBreak(1));
        Assert.isTrue(breaks.canBreak(2));
        Assert.isFalse(breaks.canBreak(3));
        Assert.isFalse(breaks.canBreak(4));

        Assert.isFalse(breaks.isMandatory(0));
        Assert.isFalse(breaks.isMandatory(1));
        Assert.isTrue(breaks.isMandatory(2));
        Assert.isFalse(breaks.isMandatory(3));
        Assert.isFalse(breaks.isMandatory(4));
    }

    public function testSpace() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("01 34");

        Assert.isFalse(breaks.canBreak(0));
        Assert.isFalse(breaks.canBreak(1));
        Assert.isFalse(breaks.canBreak(2));
        Assert.isTrue(breaks.canBreak(3));
        Assert.isFalse(breaks.canBreak(4));

        for (index in 0...breaks.count()) {
            Assert.isFalse(breaks.isMandatory(index));
        }
    }

    public function testCJK() {
        var breaker = new SimpleLineBreaker();
        var breaks = breaker.getBreaks("一二三");

        Assert.isFalse(breaks.canBreak(0));
        Assert.isTrue(breaks.canBreak(1));
        Assert.isTrue(breaks.canBreak(2));

        for (index in 0...breaks.count()) {
            Assert.isFalse(breaks.isMandatory(index));
        }
    }
}
