package cobbles.test.markup;

import utest.Assert;
import utest.Test;

class TestMarkup extends Test {
    public function testSpan() {
        var cobbles = new TextInput();

        cobbles.textDirection = Direction.LeftToRight;
        cobbles.color = 0;

        cobbles.addMarkup('<span dir="rtl">Hello <span color="#ff0000">world</span>!</span> How are you?');
        cobbles.layoutText();

        Assert.equals(4, cobbles.textSource.items.length);

        switch cobbles.textSource.items[0] {
            case RunItem(textRun):
                Assert.equals(Direction.RightToLeft, textRun.direction);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[1] {
            case RunItem(textRun):
                Assert.equals(Direction.RightToLeft, textRun.direction);
                Assert.equals(0xffff0000, textRun.color);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[2] {
            case RunItem(textRun):
                Assert.equals(Direction.RightToLeft, textRun.direction);
                Assert.equals(0, textRun.color);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[2] {
            case RunItem(textRun):
                Assert.equals(Direction.RightToLeft, textRun.direction);
                Assert.equals(0, textRun.color);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[3] {
            case RunItem(textRun):
                Assert.equals(Direction.LeftToRight, textRun.direction);
                Assert.equals(0, textRun.color);
            default:
                Assert.fail();
        }
    }

    public function testBR() {
        var cobbles = new TextInput();

        cobbles.addMarkup('hello<br/>world!');
        cobbles.layoutText();

        Assert.equals(3, cobbles.textSource.items.length);

        switch cobbles.textSource.items[1] {
            case LineBreakItem(spacing):
                Assert.pass();
            default:
                Assert.fail();
        }
    }

    public function testObject() {
        var cobbles = new TextInput();

        cobbles.addMarkup('hello<object name="h"/>world!');
        cobbles.layoutText();

        Assert.equals(3, cobbles.textSource.items.length);

        switch cobbles.textSource.items[1] {
            case InlineObjectItem(object):
                Assert.pass();
            default:
                Assert.fail();
        }
    }

    public function testScriptDirection() {
        var cobbles = new TextInput();

        cobbles.addMarkup('hello <sa>يونيكود</sa>!');
        cobbles.layoutText();

        Assert.equals(3, cobbles.textSource.items.length);

        switch cobbles.textSource.items[0] {
            case RunItem(textRun):
                Assert.equals(Direction.LeftToRight, textRun.direction);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[1] {
            case RunItem(textRun):
                Assert.equals(Direction.RightToLeft, textRun.direction);
            default:
                Assert.fail();
        }

        switch cobbles.textSource.items[2] {
            case RunItem(textRun):
                Assert.equals(Direction.LeftToRight, textRun.direction);
            default:
                Assert.fail();
        }
    }
}
