package cobbles.test;

import utest.Assert;
#if sys
import sys.FileSystem;
import cobbles.render.GrayscaleBitmap;
import cobbles.render.BitmapRenderer;
#end

class TestBitmapRender extends BaseTestCase {
    #if sys
    public function test() {
        final library = new Library();
        final engine = new Engine(library);

        final font = library.loadFont(getFontPath());

        engine.font = font;

        engine.addText("hello world!");
        engine.layOut();

        var width = engine.outputInfo.textWidth;
        var height = engine.outputInfo.textHeight;

        var bitmap = new GrayscaleBitmap(width, height);
        var renderer = new BitmapRenderer(library, engine);

        renderer.setBitmap(bitmap);
        renderer.render();

        FileSystem.createDirectory("out/test");
        bitmap.savePGM("out/test/bitmap_render.pgm");

        engine.dispose();
        library.dispose();

        Assert.pass();
    }
    #end
}
