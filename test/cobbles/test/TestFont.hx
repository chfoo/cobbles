package cobbles.test;

import utest.Assert;
import cobbles.font.Font;
import utest.Test;

using Safety;

class TestFont extends Test {
    static inline var SERIF_FONT_PATH = "fonts/liberation/LiberationSerif-Regular.ttf";

    #if js
    static var serifData:Null<js.html.ArrayBuffer>;

    public static function preloadFonts():js.Promise<Bool> {
        trace("Preloading fonts..");

        var req = js.Browser.createXMLHttpRequest();
        req.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;

        return new js.Promise((resolve, reject) -> {
            req.open("GET", SERIF_FONT_PATH);
            req.onload = event -> {
                serifData = req.response;

                trace("Fonts loaded.");
                resolve(true);
            }
            req.send();
        });
    }
    #end

    #if sys
    public function testLoad() {
        var font = new Font(SERIF_FONT_PATH);
        font.dispose();

        font = new Font(sys.io.File.getBytes(SERIF_FONT_PATH));
        font.dispose();

        Assert.pass();
    }
    #end

    public static function getSerifFont():Font {
        #if sys
        var font = new Font(SERIF_FONT_PATH);
        #elseif js
        var font = new Font(haxe.io.Bytes.ofData(serifData.sure()));
        #else
        #error "Not implemented"
        #end
        return font;
    }

    public function testGetGlyph() {
        var font = getSerifFont();

        var glyphID = font.getGlyphID("e".code);

        Assert.notEquals(0, glyphID);

        var glyphInfo = font.getGlyphInfo(glyphID);

        Assert.notEquals(0, glyphInfo.bitmapWidth);
        Assert.notEquals(0, glyphInfo.bitmapHeight);

        trace('${glyphInfo.bitmapWidth} ${glyphInfo.bitmapHeight}');

        var buf = new StringBuf();
        buf.add("Glyph:\n");

        for (row in 0...glyphInfo.bitmapHeight) {
            for (col in 0...glyphInfo.bitmapWidth) {
                var index = row * glyphInfo.bitmapWidth + col;
                var value = glyphInfo.bitmap.get(index);

                if (value >= 127) {
                    buf.add("X");
                } else {
                    buf.add(" ");
                }
            }

            buf.add("\n");
        }

        trace(buf.toString());
    }
}
