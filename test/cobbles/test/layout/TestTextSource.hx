package cobbles.test.layout;

import cobbles.algorithm.SimpleLineBreaker;
import utest.Assert;
import cobbles.layout.InlineObject;
import cobbles.layout.TextSource;
import utest.Test;

private class MyInlineObject implements InlineObject {
    public function new() {

    }
    public function getWidth():Int {
        return 24 * 64;
    }

    public function getHeight():Int {
        return 24 * 64;
    }
}

class TestTextSource extends Test {
    public function testTextSource() {
        var textSource = new TextSource();

        textSource.addText("abc");
        textSource.addLineBreak();
        textSource.addInlineObject(new MyInlineObject());

        var customProperties = textSource.defaultTextProperties.copy();
        customProperties.fontPointSize = 200;
        textSource.addText("!!", customProperties);

        Assert.equals(4, textSource.items.length);
        Assert.equals(5, textSource.codePoints.length);

        Assert.isTrue(textSource.items[0].match(RunItem(_)));
        Assert.isTrue(textSource.items[1].match(LineBreakItem(_)));
        Assert.isTrue(textSource.items[2].match(InlineObjectItem(_)));
        Assert.isTrue(textSource.items[3].match(RunItem(_)));
    }

    public function testMandatoryLineBreak() {
        var lineBreaker = new SimpleLineBreaker();
        var textSource = new TextSource(lineBreaker);

        textSource.addText("hello\nworld!");

        Assert.equals(3, textSource.items.length);

        // Length of text less breaking characters
        Assert.equals(11, textSource.codePoints.length);

        Assert.isTrue(textSource.items[0].match(RunItem(_)));
        Assert.isTrue(textSource.items[1].match(LineBreakItem(_)));
        Assert.isTrue(textSource.items[2].match(RunItem(_)));
    }

    public function testClear() {
        var lineBreaker = new SimpleLineBreaker();
        var textSource = new TextSource(lineBreaker);

        textSource.addText("hello\nworld!");
        textSource.clear();

        Assert.equals(0, textSource.items.length);
        Assert.equals(0, textSource.codePoints.length);
        Assert.equals(0, textSource.lineBreakRules.length);
    }
}
