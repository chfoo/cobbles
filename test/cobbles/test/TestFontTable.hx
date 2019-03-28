package cobbles.test;

import utest.Assert;
import cobbles.font.FontTable;
import utest.Test;

class TestFontTable extends Test {
    public function testNotdefFontGetter() {
        var fontTable = new FontTable();

        Assert.notNull(
            fontTable.getFont(FontTable.notdefFont)
        );
    }

    public function testFindByCodePoint() {
        var fontTable = new FontTable();

        Assert.equals(
            FontTable.notdefFont,
            fontTable.findByCodePoint("a".code));

        var serifFont = TestFont.getSerifFont();
        var serifFontKey = fontTable.addFont(serifFont);

        Assert.equals(
            serifFontKey,
            fontTable.findByCodePoint("a".code));
    }
}
