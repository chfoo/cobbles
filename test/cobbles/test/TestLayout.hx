package cobbles.test;

import utest.Assert;
import cobbles.layout.InlineObject;
import cobbles.algorithm.SimpleLineBreaker;
import cobbles.layout.TextSource;
import cobbles.layout.Layout;
import cobbles.font.FontTable;
import cobbles.shaping.Shaper;
import utest.Test;

class MyInlineObject implements InlineObject {
    public function new() {

    }
    public function getWidth():Int {
        return 24 * 64;
    }

    public function getHeight():Int {
        return 24 * 64;
    }
}

class TestLayout extends Test {
    public static function getSample():{layout:Layout, fontTable:FontTable} {
        var lineBreaker = new SimpleLineBreaker();
        var fontTable = new FontTable();

        var font = fontTable.addFont(TestFont.getSerifFont());

        var textSource = new TextSource(font, lineBreaker);
        textSource.defaultTextProperties.fontPointSize = 24;
        textSource.addText("ABC 一二三 😂");
        textSource.addLineBreak();
        textSource.addText("The quick brown fox");
        textSource.addInlineObject(new MyInlineObject());
        textSource.addText(" jumps over the lazy dog.");

        var shaper = new Shaper();
        var layout = new Layout(fontTable, textSource, shaper, lineBreaker);
        // layout.alignment = Alignment.Center;
        layout.lineBreakLength = layout.pixelToPoint64(200);
        layout.resolution = 96;

        layout.layout();

        return {
            layout: layout,
            fontTable: fontTable
        };
    }

    public function testLayout() {
        var layout = getSample().layout;

        Assert.notEquals(1, layout.lines);

        var inlineObjectCount = 0;

        for (line in layout.lines) {
            trace('Line: length=${line.length} spacing=${line.spacing} x=${line.x} y=${line.y} items=${line.items.length}');
            Assert.notEquals(0, line.items.length);

            for (item in line.items) {
                switch item {
                    case InlineObjectItem(inlineObject):
                        inlineObjectCount += 1;
                    default:
                        // pass
                }
            }
        }

        Assert.equals(1, inlineObjectCount);
    }
}
