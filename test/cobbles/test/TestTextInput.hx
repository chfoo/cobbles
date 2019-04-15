package cobbles.test;

import cobbles.layout.InlineObject;
import utest.Assert;
import cobbles.font.FontTable;
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


@:nullSafety(Off)
class TestTextInput extends Test {
    public function testTextInput() {
        var cobbles = new TextInput();

        cobbles.alignment = Alignment.Center;
        cobbles.color = 0xffff0000;
        cobbles.font = FontTable.notdefFont;
        cobbles.fontSize = 20;
        cobbles.language = "en";
        cobbles.script = "latn";
        cobbles.lineBreakLength = 400;
        cobbles.lineSpacing = 1.8;
        cobbles.textDirection = Direction.LeftToRight;
        cobbles.orientation = Orientation.HorizontalTopBottom;

        cobbles.addText("hello ");
        cobbles.addText("world!")
            .color(0xff00ff00)
            .detectFont()
            .detectScript()
            .direction(Direction.RightToLeft)
            .font(FontTable.notdefFont)
            .fontSize(22)
            .language("xx")
            .script("xxxx")
            .data("a", "1");

        cobbles.addLineBreak();
        cobbles.addInlineObject(new MyInlineObject());
        cobbles.layoutText();

        Assert.equals(2, cobbles.layout.lines.length);

        switch cobbles.layout.lines[0].items[0] {
            case PenRunItem(penRun):
                Assert.equals(0xffff0000, penRun.color);
            default:
                Assert.fail();
        }

        switch cobbles.layout.lines[0].items[1] {
            case PenRunItem(penRun):
                Assert.equals(0xff00ff00, penRun.color);
                Assert.equals("1", penRun.data.get("a"));
            default:
                Assert.fail();
        }
    }

    public function testLongString() {
        var cobbles = new TextInput();

        var buf = new StringBuf();

        for (dummy in 0...1000) {
            buf.add("hello😄");
        }

        cobbles.addText(buf.toString()).detectScript();

        cobbles.layoutText();

        Assert.equals(1, cobbles.layout.lines.length);

        switch cobbles.layout.lines[0].items[0] {
            case PenRunItem(penRun):
                Assert.equals(6 * 1000, penRun.glyphShapes.length);
            default:
                Assert.fail();
        }
    }
}
