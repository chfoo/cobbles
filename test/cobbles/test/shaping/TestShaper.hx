package cobbles.test.shaping;

import cobbles.shaping.Shaper;
import cobbles.test.font.TestFont;
import utest.Assert;
import utest.Test;

class TestShaper extends Test {
    public function testShaper() {
        var shaper = new Shaper();
        var text = "Hello world!";

        shaper.setFont(TestFont.getSerifFont());
        shaper.setText(text);
        shaper.guessScript();
        shaper.setScript("eng", "en");
        shaper.setDirection(Direction.LeftToRight);

        var glyphs = shaper.shape();

        Assert.equals(12, glyphs.length);

        for (glyph in glyphs) {
            Assert.notEquals(0, glyph.glyphID);
        }
    }
}