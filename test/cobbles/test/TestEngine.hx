package cobbles.test;

import haxe.io.Bytes;
import utest.Async;
import utest.Assert;

using Safety;

private class MyInlineObject implements InlineObject {
    public function new() {

    }

    public function getWidth() {
        return 20;
    }

    public function getHeight() {
        return 20;
    }
}

class TestEngine extends BaseTestCase {
    public function testSmoketest(asyncHandle:Async) {
        #if js
        loadAndRun(asyncHandle, _testSmoketest, "out/js/LiberationSerif-Regular.ttf");
        #else
        loadAndRun(asyncHandle, _testSmoketest);
        #end
    }

    function _testSmoketest(library:Library) {
        #if js
        final font = library.loadFontBytes(fontBytes.sure());
        #else
        final font = library.loadFont(getFontPath());
        #end

        library.setFontAlternative(font, library.fallbackFont);
        Assert.equals(library.fallbackFont, library.getFontAlternative(font));

        final engine = new Engine(library);
        final inlineObject = new MyInlineObject();

        engine.fontSize = 14.5;
        Assert.equals(14.5, engine.fontSize);

        engine.addText("hello world😄");
        engine.addInlineObject(inlineObject);

        engine.layOut();
        Assert.isFalse(engine.tilesValid());

        engine.rasterize();
        Assert.isFalse(engine.packTiles(256, 256));

        final tiles = engine.tiles();
        Assert.isTrue(tiles.length > 8);

        for (tile in tiles) {
            library.getGlyphInfo(tile.glyphID);
        }

        final advances = engine.advances();
        Assert.isTrue(advances.length > 10);

        var foundGlyph = false;
        var foundInlineObject = false;

        for (advanceInfo in advances) {
            switch advanceInfo.type {
                case InlineObject:
                    Assert.equals(inlineObject, advanceInfo.inlineObject.sure());
                    foundInlineObject = true;
                case Glyph:
                    foundGlyph = true;
                default:
                    // pass
            }
        }

        Assert.notEquals(0, engine.outputInfo.textWidth);
        Assert.notEquals(0, engine.outputInfo.textHeight);

        Assert.isTrue(foundGlyph);
        Assert.isTrue(foundInlineObject);

        engine.dispose();
        library.dispose();
    }

    public function testPropertiesGetterSetter(asyncHandle:Async) {
        loadAndRun(asyncHandle, _testPropertiesGetterSetter);
    }

    function _testPropertiesGetterSetter(library:Library) {
        final engine = new Engine(library);

        engine.locale = "asdf";
        Assert.equals("asdf", engine.locale);

        engine.script = "aa";
        Assert.equals("aa", engine.script);

        engine.fontSize = 12.3;
        Assert.equals(12.3, engine.fontSize);

        engine.lineLength = 50;
        Assert.equals(50, engine.lineLength);
    }

    public function testException(asyncHandle:Async) {
        loadAndRun(asyncHandle, _testException);
    }

    function _testException(library:Library) {
        #if js
        Assert.raises(() -> {
            library.loadFontBytes(Bytes.alloc(1000));
        });
        #else
        Assert.raises(() -> {
            library.loadFont("non-existent-file");
        },
        Exception);
        Assert.raises(() -> {
            library.loadFontBytes(Bytes.alloc(1000));
        },
        Exception);
        #end
    }
}
